import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'theme_provider.dart';
import 'auth_provider.dart';

void main() async {
  // 1. Flutter Engine ko ready karna
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase Initialization (Android + Web support)
  try {
    if (kIsWeb) {
      // Sirf Web ke liye ye options use honge
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDfglU2MuDVHFcbNLULRChThb2wsInhRx0",
          authDomain: "holoserve.firebaseapp.com",
          projectId: "holoserve",
          storageBucket: "holoserve.firebasestorage.app",
          messagingSenderId: "376228426676",
          appId: "1:376228426676:web:483a9985db8360ed8538e1",
          measurementId: "G-R06RYY8QHK",
        ),
      );
    } else {
      // Android/iOS ke liye ye khud hi google-services.json se data utha lega
      await Firebase.initializeApp();
    }

    if (kDebugMode) {
      print("Firebase Connection Success: ${Firebase.app().name}");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Firebase Initialization Error: $e");
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()..loadUserData()),
      ],
      child: const HoloServeApp(),
    ),
  );
}

class HoloServeApp extends StatelessWidget {
  const HoloServeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Show loading screen until theme is initialized
        if (!themeProvider.isInitialized) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFF0A0F1C),
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00E5FF),
                  ),
                ),
              ),
            ),
          );
        }
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HoloServe',
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}
