import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface PushRequest {
  building_id?: number;
  title?: string;
  body?: string;
  audience?: "all" | "admins" | "apartments";
  target_apt_nums?: number[];
  admin_pass?: string;
  event_type?: string;
}

function base64UrlEncode(data: Uint8Array | string): string {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : data;
  let binary = "";
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const cleaned = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  const binary = atob(cleaned);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

async function getFirebaseAccessToken(sa: { client_email: string; private_key: string }): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = base64UrlEncode(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const payload = base64UrlEncode(
    JSON.stringify({
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    }),
  );
  const unsigned = `${header}.${payload}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${base64UrlEncode(new Uint8Array(sig))}`;

  const tokenResp = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!tokenResp.ok) {
    throw new Error(`OAuth token exchange failed: ${await tokenResp.text()}`);
  }
  const json = await tokenResp.json();
  return json.access_token as string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload: PushRequest = await req.json();
    const rawBuildingId = Number(payload.building_id);
    const buildingId = Number.isInteger(rawBuildingId) && rawBuildingId > 0 ? rawBuildingId : 1;
    const title = (payload.title ?? "").trim().slice(0, 120);
    const body = (payload.body ?? "").trim().slice(0, 400);
    const audience =
      payload.audience === "admins"
        ? "admins"
        : payload.audience === "apartments"
        ? "apartments"
        : "all";
    const targetAptNums = Array.isArray(payload.target_apt_nums)
      ? Array.from(
          new Set(
            payload.target_apt_nums
              .map((n) => Number(n))
              .filter((n) => Number.isInteger(n) && n > 0),
          ),
        )
      : [];
    const eventType = (payload.event_type ?? "manual_broadcast").trim().slice(0, 50);

    if (!title || !body) {
      return new Response(
        JSON.stringify({ ok: false, error: "Missing title or body" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (audience === "apartments" && targetAptNums.length === 0) {
      return new Response(
        JSON.stringify({ ok: false, error: "Missing target apartments" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const sb = createClient(supabaseUrl, serviceKey);

    const { data: building } = await sb
      .from("buildings")
      .select("id, code, name, admin_password")
      .eq("id", buildingId)
      .maybeSingle();

    if (!building) {
      return new Response(
        JSON.stringify({ ok: false, error: "Building not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (audience === "all" || audience === "apartments" || eventType === "admin_test") {
      if ((payload.admin_pass ?? "").trim() !== building.admin_password) {
        return new Response(
          JSON.stringify({ ok: false, error: "Unauthorized" }),
          { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
    }

    // Record notification in app_notifications history table scoped to building_id
    await sb.from("app_notifications").insert({
      building_id: buildingId,
      title,
      body,
      audience,
      target_apt_nums: audience === "apartments" ? targetAptNums : [],
      event_type: eventType,
    });

    const saRaw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!saRaw || saRaw.trim().length < 20) {
      return new Response(
        JSON.stringify({
          ok: false,
          not_configured: true,
          sent: 0,
          message: "FIREBASE_SERVICE_ACCOUNT secret not configured yet",
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const sa = JSON.parse(saRaw) as {
      project_id: string;
      client_email: string;
      private_key: string;
    };

    let query = sb
      .from("building_push_tokens")
      .select("token")
      .eq("building_id", buildingId);

    if (audience === "admins") {
      query = query.eq("is_admin", true);
    } else if (audience === "apartments") {
      query = query.in("apt_num", targetAptNums);
    }
    const { data: rows, error: dbErr } = await query;
    if (dbErr) throw dbErr;

    const tokens = (rows ?? []).map((r: { token: string }) => r.token).filter(Boolean);
    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({ ok: true, sent: 0, total: 0 }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const accessToken = await getFirebaseAccessToken(sa);
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`;
    const targetLink =
      buildingId === 1
        ? "https://mabna-care.web.app/"
        : `https://mabna-care.web.app/?b=${encodeURIComponent(building.code)}`;

    let sent = 0;
    const staleTokens: string[] = [];

    await Promise.all(
      tokens.map(async (token: string) => {
        const resp = await fetch(fcmUrl, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token,
              notification: { title, body },
              webpush: {
                headers: {
                  Urgency: "high",
                },
                notification: {
                  title,
                  body,
                  icon: "https://mabna-care.web.app/icons/Icon-192.png",
                  badge: "https://mabna-care.web.app/icons/notification-badge.png",
                },
                fcm_options: {
                  link: targetLink,
                },
              },
            },
          }),
        });
        if (resp.ok) {
          sent += 1;
        } else {
          const errTxt = await resp.text();
          if (errTxt.includes("UNREGISTERED") || errTxt.includes("INVALID_ARGUMENT")) {
            staleTokens.push(token);
          }
        }
      }),
    );

    if (staleTokens.length > 0) {
      await sb
        .from("building_push_tokens")
        .delete()
        .eq("building_id", buildingId)
        .in("token", staleTokens);
    }

    return new Response(
      JSON.stringify({ ok: true, sent, total: tokens.length }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ ok: false, error: String(err) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
