import 'dart:developer' as dev;

import 'package:docflow/Home/home_view.dart';
import 'package:docflow/Providers/auth_provider.dart';
import 'package:docflow/Widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmailVerifyView extends StatelessWidget {
  const EmailVerifyView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verify Email"),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () async {
            await authProvider.signOut().then((value) {
              Navigator.pop(context);
              dev.log('User Signed out');
            });
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.email_outlined,
              size: 100,
              color: Color.fromARGB(255, 60, 60, 60),
            ),
            const SizedBox(height: 20),
            const Text(
              "Please Verify Your Email",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "We have sent a verification link to your email address. "
              "Please check your inbox or click below to resend the email.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async =>
                    await authProvider.sendVerifyEmail().then((value) {
                      showMySnackBar(
                        context,
                        'A verification email is sent to your inbox',
                      );
                    }),
                icon: const Icon(Icons.send),
                label: const Text("Send Verification Email"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color.fromARGB(255, 60, 60, 60),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
            GestureDetector(
              child: Text('I have verified, continue!'),
              onTap: () async {
                await authProvider.reloadUser();
                dev.log('${authProvider.userModel?.uId}');
                if (authProvider.userModel?.uId != null &&
                    authProvider.isEmailVerified!) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeView()),
                    (route) => false,
                  );
                } else {
                  showMySnackBar(context, 'Email not verified yet.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
