import 'package:docflow/Providers/auth_provider.dart';
import 'package:docflow/Providers/firestore_provider.dart';
import 'package:docflow/auth/auth_state.dart';
import 'package:docflow/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => FirestoreProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocFLow',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          bodyLarge: GoogleFonts.poppins(
            letterSpacing: -0.7, // space between characters
          ),
          bodyMedium: GoogleFonts.poppins(letterSpacing: -0.8),
          labelLarge: GoogleFonts.poppins(letterSpacing: -0.5),
        ),
        primarySwatch: Colors.cyan,
        primaryColor: Colors.cyan,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFB0A8FF), // 👈 pick your own brand color
        ),
      ),

      home: AuthView(),
    );
  }
}
