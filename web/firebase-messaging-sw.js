importScripts('https://www.gstatic.com/firebasejs/11.6.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.6.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyByMxwr0zs8X_YbnVcAjWOAGHMyqYR1M3w",
  authDomain: "mabna-care.firebaseapp.com",
  projectId: "mabna-care",
  storageBucket: "mabna-care.firebasestorage.app",
  messagingSenderId: "826365542912",
  appId: "1:826365542912:web:d2ecd5645fcf29cf820ee5",
  measurementId: "G-RE2XWQB14T"
});

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload?.data?.title || payload?.notification?.title || 'MABNA CARE';
  const body = payload?.data?.body || payload?.notification?.body || '';
  const icon = payload?.data?.icon || payload?.notification?.icon || 'https://mabna-care.web.app/icons/Icon-192.png';
  const badge = payload?.data?.badge || payload?.notification?.badge || 'https://mabna-care.web.app/icons/notification-badge.png';
  const url = payload?.data?.url || 'https://mabna-care.web.app/';

  self.registration.showNotification(title, {
    body,
    icon,
    badge,
    data: { url },
  });
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const targetUrl = event.notification?.data?.url || 'https://mabna-care.web.app/';
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      for (const client of windowClients) {
        if (client.url.includes('mabna-care') && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }
    })
  );
});
