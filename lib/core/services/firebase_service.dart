import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../config/app_config.dart';

class FirebaseService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseFunctions functions;
  final FirebaseMessaging messaging;
  final FirebaseAppCheck appCheck;

  FirebaseService._({
    required this.auth,
    required this.firestore,
    required this.storage,
    required this.functions,
    required this.messaging,
    required this.appCheck,
  });

  static FirebaseService? _instance;
  static FirebaseService get instance {
    if (_instance == null) {
      throw StateError('FirebaseService has not been initialized.');
    }
    return _instance!;
  }

  static Future<FirebaseService> initialize({
    FirebaseOptions? options,
  }) async {
    final effectiveOptions = options ?? DefaultFirebaseOptions.currentPlatform;
    await Firebase.initializeApp(options: effectiveOptions);

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    final functions = FirebaseFunctions.instance;
    final messaging = FirebaseMessaging.instance;
    final appCheck = FirebaseAppCheck.instance;

    if (AppConfig.instance.enableAppCheck && !kIsWeb) {
      await appCheck.activate(
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
      );
    }

    _instance = FirebaseService._(
      auth: auth,
      firestore: firestore,
      storage: storage,
      functions: functions,
      messaging: messaging,
      appCheck: appCheck,
    );

    return _instance!;
  }
}
