import 'package:docflow/Providers/auth_provider.dart';
import 'package:docflow/Widgets/snackbar_widget.dart';
import 'package:docflow/auth/email_verify_view.dart';
import 'package:docflow/auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController firstnameController;
  late TextEditingController lastnameController;

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    firstnameController.clear();
    lastnameController.clear();
  }

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    firstnameController = TextEditingController();
    lastnameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign Up',
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 60),
            TextField(
              controller: firstnameController,
              decoration: InputDecoration(
                labelText: "FirstName",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastnameController,
              decoration: InputDecoration(
                labelText: "LastName",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty &&
                    lastnameController.text.isNotEmpty &&
                    firstnameController.text.isNotEmpty) {
                  await authProvider
                      .signUp(
                        emailController.text,
                        firstnameController.text,
                        lastnameController.text,
                        passwordController.text,
                      )
                      .then((value) {
                        if (authProvider.userModel != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmailVerifyView(),
                            ),
                          );
                        }
                      });
                  clearControllers();
                } else {
                  showMySnackBar(context, 'Please fill all the fields.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 60, 60, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    15,
                  ), // small rounded corners
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 12,
                ), // better spacing
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
