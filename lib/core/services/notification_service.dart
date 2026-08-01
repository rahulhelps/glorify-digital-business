import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:global_earn/core/constants/app_strings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TOP-LEVEL BACKGROUND MESSAGE HANDLER
// Must be a top-level (non-class) function annotated with @pragma so the Dart
// VM can locate and invoke it from an isolate when the app is terminated/bg.
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // NOTE: Firebase is already initialized before this handler fires on Android.
  // Do NOT call Firebase.initializeApp() here — it causes a double-init crash.
  debugPrint(
    '[NotificationService] Background message received: ${message.messageId}',
  );
  // The system notification is shown automatically by the OS for data+notification
  // messages. For data-only messages you can do light processing here (no UI).
}

// ─────────────────────────────────────────────────────────────────────────────
// HIGH-IMPORTANCE ANDROID NOTIFICATION CHANNEL
// ─────────────────────────────────────────────────────────────────────────────
const AndroidNotificationChannel _highImportanceChannel =
    AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name shown in settings
      description:
          'This channel is used for important push notifications from ${AppStrings.appNameShort}.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION SERVICE
// ─────────────────────────────────────────────────────────────────────────────
class NotificationService {
  NotificationService._(); // prevent instantiation

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Optional callback that consumer code (main.dart) can set to handle
  /// navigation when a notification is tapped from background/terminated state.
  static void Function(RemoteMessage message)? onNotificationTap;

  // ───────────────────────────────────────────────────────────────────────────
  // PUBLIC INITIALIZER
  // Call once in main() AFTER Firebase.initializeApp().
  // ───────────────────────────────────────────────────────────────────────────

  /// Bootstraps the entire notification system:
  /// 1. Requests OS permissions
  /// 2. Registers the background handler
  /// 3. Creates the Android high-importance channel
  /// 4. Initialises flutter_local_notifications
  /// 5. Starts foreground & background-opened listeners
  /// 6. Checks for an initial message (terminated-state launch)
  static Future<void> initialize() async {
    // Register the top-level background handler first.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestPermissions();
    await _setupLocalNotifications();
    _setupForegroundHandler();
    _setupBackgroundOpenedHandler();
    await handleInitialMessage();

    // Suppress foreground notification display on iOS (we show our own).
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    debugPrint('[NotificationService] Initialized successfully.');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // PERMISSION REQUEST
  // ───────────────────────────────────────────────────────────────────────────

  static Future<void> _requestPermissions() async {
    // Firebase Messaging permission (covers iOS + Android 13+).
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('[NotificationService] Notification permission: GRANTED');
      await subscribeToAllUsersTopic();
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint(
        '[NotificationService] Notification permission: PROVISIONAL (iOS)',
      );
      await subscribeToAllUsersTopic();
    } else {
      debugPrint(
        '[NotificationService] Notification permission: DENIED — '
        'status=${settings.authorizationStatus}',
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ANDROID NOTIFICATION CHANNEL + LOCAL NOTIFICATIONS SETUP
  // ───────────────────────────────────────────────────────────────────────────

  static Future<void> _setupLocalNotifications() async {
    // Create the Android high-importance channel.
    final androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.createNotificationChannel(_highImportanceChannel);

    // Initialise the plugin.
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher', // uses app launcher icon as notification icon
    );

    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false, // already requested via firebase_messaging
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    debugPrint('[NotificationService] Local notifications channel created.');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // FOREGROUND HANDLER — App is open & active
  // ───────────────────────────────────────────────────────────────────────────

  static void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '[NotificationService] Foreground message: ${message.messageId}',
      );
      final notification = message.notification;
      if (notification == null) return; // data-only message, skip display

      // Show a heads-up notification manually (Android suppresses FCM in fg).
      _localNotifications.show(
        notification.hashCode,
        notification.title ?? AppStrings.appNameShort,
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _highImportanceChannel.id,
            _highImportanceChannel.name,
            channelDescription: _highImportanceChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            // Large icon from the notification's Android image if present.
            styleInformation: BigTextStyleInformation(
              notification.body ?? '',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['route'], // optional deep-link payload
      );
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BACKGROUND OPENED HANDLER — App in bg; user taps notification
  // ───────────────────────────────────────────────────────────────────────────

  static void _setupBackgroundOpenedHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '[NotificationService] Notification opened (background): '
        '${message.messageId}',
      );
      onNotificationTap?.call(message);
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LOCAL NOTIFICATION TAP — Foreground notification tapped
  // ───────────────────────────────────────────────────────────────────────────

  static void _onLocalNotificationTap(NotificationResponse response) {
    debugPrint(
      '[NotificationService] Local notification tapped — payload: '
      '${response.payload}',
    );
    // Wrap payload in a minimal RemoteMessage for a unified tap callback.
    if (response.payload != null && onNotificationTap != null) {
      final syntheticMessage = RemoteMessage(
        data: {'route': response.payload!},
      );
      onNotificationTap?.call(syntheticMessage);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TERMINATED STATE — App launched by tapping a notification
  // ───────────────────────────────────────────────────────────────────────────

  /// Call this in main() after initialize(). If the app was launched by
  /// clicking a push notification while terminated, this returns the message
  /// and fires [onNotificationTap] for routing.
  static Future<void> handleInitialMessage() async {
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
        '[NotificationService] App launched from terminated state via '
        'notification: ${initialMessage.messageId}',
      );
      // Delay to let the widget tree mount before navigating.
      Future.delayed(const Duration(milliseconds: 500), () {
        onNotificationTap?.call(initialMessage);
      });
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TOKEN MANAGEMENT
  // ───────────────────────────────────────────────────────────────────────────

  /// Fetches the current FCM token and saves/updates it in Firestore at
  /// `users/{uid}/fcmToken`. Safe to call on every login — Firestore merge
  /// prevents unnecessary writes if the token hasn't changed.
  static Future<void> updateUserFcmToken(String userId) async {
    if (userId.isEmpty) return;

    try {
      // Request notification permissions first
      await _messaging.requestPermission();

      // On web FCM tokens require a VAPID key; skip gracefully on non-web.
      final String? token =
          kIsWeb
              ? null
              : Platform.isAndroid || Platform.isIOS
              ? await _messaging.getToken()
              : null;

      if (token == null) {
        debugPrint('[NotificationService] FCM token unavailable on this platform.');
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {'fcmToken': token},
        SetOptions(merge: true), // only update this field, keep others intact
      );

      debugPrint(
        '[NotificationService] FCM token saved to Firestore for uid=$userId',
      );
    } catch (e) {
      debugPrint('[NotificationService] Failed to save FCM token: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TOKEN REFRESH LISTENER
  // ───────────────────────────────────────────────────────────────────────────

  /// Keeps Firestore always in sync with the latest token.
  /// FCM may rotate tokens (e.g. after app reinstall, token expiry).
  /// Call this once after a successful login.
  static void setupTokenRefreshListener(String uid) {
    if (uid.isEmpty) return;

    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('[NotificationService] FCM token refreshed for uid=$uid');
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {'fcmToken': newToken},
          SetOptions(merge: true),
        );
        debugPrint('[NotificationService] Refreshed token saved to Firestore.');
      } catch (e) {
        debugPrint(
          '[NotificationService] Failed to save refreshed FCM token: $e',
        );
      }
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TOPIC SUBSCRIPTION
  // ───────────────────────────────────────────────────────────────────────────

  /// Subscribes device to the 'all_users' topic so the Admin Panel can send
  /// broadcast notifications without iterating individual tokens.
  static Future<void> subscribeToAllUsersTopic() async {
    try {
      await _messaging.subscribeToTopic('all_users');
      debugPrint(
        "[NotificationService] Subscribed to topic: 'all_users'",
      );
    } catch (e) {
      debugPrint('[NotificationService] Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribes from the 'all_users' topic (e.g. on logout).
  static Future<void> unsubscribeFromAllUsersTopic() async {
    try {
      await _messaging.unsubscribeFromTopic('all_users');
      debugPrint(
        "[NotificationService] Unsubscribed from topic: 'all_users'",
      );
    } catch (e) {
      debugPrint(
        '[NotificationService] Failed to unsubscribe from topic: $e',
      );
    }
  }
}
