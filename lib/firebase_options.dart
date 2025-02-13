import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCyFf2ikOQwF_5kzi2DMjQuUe1b38T2_z8',
    appId: '1:346960868478:web:8e4f55e803a3206c9a942f',
    messagingSenderId: '346960868478',
    projectId: 'project-flutter-80f53',
    authDomain: 'project-flutter-80f53.firebaseapp.com',
    storageBucket: 'project-flutter-80f53.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8SdXE1iuNXMTrotBkT2IciPH7Im-RwWM',
    appId: '1:346960868478:android:0200808b90f787389a942f',
    messagingSenderId: '346960868478',
    projectId: 'project-flutter-80f53',
    storageBucket: 'project-flutter-80f53.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA6Wyz8_JkT3QJKceO07nKVztlfjYgw3b4',
    appId: '1:346960868478:ios:31e1c42997b3f7649a942f',
    messagingSenderId: '346960868478',
    projectId: 'project-flutter-80f53',
    storageBucket: 'project-flutter-80f53.firebasestorage.app',
    iosBundleId: 'com.example.projectFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA6Wyz8_JkT3QJKceO07nKVztlfjYgw3b4',
    appId: '1:346960868478:ios:31e1c42997b3f7649a942f',
    messagingSenderId: '346960868478',
    projectId: 'project-flutter-80f53',
    storageBucket: 'project-flutter-80f53.firebasestorage.app',
    iosBundleId: 'com.example.projectFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCyFf2ikOQwF_5kzi2DMjQuUe1b38T2_z8',
    appId: '1:346960868478:web:5fcd3ae50739527e9a942f',
    messagingSenderId: '346960868478',
    projectId: 'project-flutter-80f53',
    authDomain: 'project-flutter-80f53.firebaseapp.com',
    storageBucket: 'project-flutter-80f53.firebasestorage.app',
  );
}
