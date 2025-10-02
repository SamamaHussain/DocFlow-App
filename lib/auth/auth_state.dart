import 'package:docflow/Home/home_view.dart';
import 'package:docflow/auth/email_verify_view.dart';
import 'package:docflow/auth/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final user = snapshot.data;

        // Not logged in
        if (user == null) {
          return const LoginView();
        }

        // Logged in but not verified
        if (!user.emailVerified) {
          return const EmailVerifyView();
        }

        // Logged in and verified
        return const HomeView();
      },
    );
  }
}
