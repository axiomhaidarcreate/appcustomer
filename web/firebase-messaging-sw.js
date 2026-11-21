importScripts("https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging-compat.js");

const firebaseConfig = {
  apiKey: "AIzaSyB_nATFwYcieUZAcdS9JyY1kctYwkpDbC0",
  authDomain: "shash-c7c31.firebaseapp.com",
  projectId: "shash-c7c31",
  storageBucket: "shash-c7c31.firebasestorage.app",
  messagingSenderId: "5639673711",
  appId: "1:5639673711:web:dummydummydummydummy"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification?.title || 'إشعار جديد';
  const notificationOptions = {
    body: payload.notification?.body || payload.data?.message || 'لديك رسالة جديدة',
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
