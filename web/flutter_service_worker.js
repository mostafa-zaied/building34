// Self-destructing stub to cleanly replace and unregister legacy Flutter Service Workers
// without touching firebase-messaging-sw.js.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k.includes('flutter')).map((k) => caches.delete(k))))
      .then(() => self.registration.unregister())
      .then(() => self.clients.matchAll({ type: 'window' }))
      .then((clients) => {
        for (const c of clients) {
          c.navigate(c.url);
        }
      })
  );
});
