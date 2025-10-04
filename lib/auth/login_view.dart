import 'dart:developer' as dev;
import 'package:docflow/Home/home_view.dart';
import 'package:docflow/Providers/auth_provider.dart';
import 'package:docflow/Utils/colors.dart';
import 'package:docflow/Widgets/snackbar_widget.dart';
import 'package:docflow/auth/email_verify_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TabController _tabController;
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _lastnameController = TextEditingController();
    _firstnameController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        // <-- ADD THIS CONTAINER FOR GRADIENT
        width: double.infinity, // Full width
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, // Gradient starts from top-left
            end: Alignment.bottomRight, // Ends at bottom-right
            colors: [
              Color.fromARGB(255, 245, 247, 255), // Deep blue
              Color.fromARGB(255, 235, 255, 252), // Purple
              Color.fromARGB(255, 254, 241, 255), // Pink
              Color.fromARGB(255, 255, 247, 232), // Reddish-pink
            ],
            stops: [0.0, 0.3, 0.7, 1.0], // Optional: Controls color intensity
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 25, 23, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Doc ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFB0A8FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Flow',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  const Text(
                    'Log in to share and collaborate!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'manage all your documents with ease.',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.2,
                      color: greyColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: purpleColor.withOpacity(0.2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(23, 30, 23, 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 55,
                      // Same padding as original
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: purpleColor),
                        color: Colors.grey.shade200.withOpacity(
                          0.3,
                        ), // Background for the whole bar
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: purpleColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        labelColor: Colors.black, // Active tab text color
                        unselectedLabelColor:
                            Colors.black, // Inactive tab text color
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                        indicatorPadding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        tabs: const [
                          Tab(text: 'Login'),
                          Tab(text: 'SignUp'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                          _buildLoginForm(
                            _emailController,
                            _passwordController,
                            authProvider,
                            context,
                          ),
                          _buildSignUpForm(
                            _firstnameController,
                            _lastnameController,
                            _emailController,
                            _passwordController,
                            authProvider,
                            context,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ), // <-- YOUR EXISTING CONTENT HERE
      ),
    );
  }
}

Widget _buildLoginForm(
  TextEditingController emailController,
  TextEditingController passwordController,
  AuthProvider authProvider,
  BuildContext context,
) {
  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: "abc@abc.com",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide(color: Colors.black, width: 50),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: purpleColor),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Password',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: purpleColor),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        SizedBox(height: 15),
        Align(
          alignment: Alignment.centerRight,
          child: const Text(
            'Forgot your Password?  ',
            style: TextStyle(fontSize: 15),
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: GestureDetector(
            onTap: () async {
              await authProvider.login(
                emailController.text,
                passwordController.text,
              );
              dev.log('${authProvider.isEmailVerified}');
              if (authProvider.loggedIn &&
                  authProvider.isEmailVerified == true) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeView()),
                  (route) => false,
                );
              } else if (authProvider.loggedIn == true &&
                  authProvider.isEmailVerified == false) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmailVerifyView()),
                );
                showMySnackBar(context, 'Your email is not verified.');
              }
            },
            child: Container(
              width: double.infinity,
              height: 47,
              // Same padding as original
              decoration: BoxDecoration(
                color: purpleColor, // Same background color
                borderRadius: BorderRadius.circular(40), // Same rounded corners
              ),
              child: const Center(
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        Center(
          child: const Text(
            "Sign Up first if you don't have an account!",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSignUpForm(
  TextEditingController firstNameController,
  TextEditingController lastNameController,
  TextEditingController emailController,
  TextEditingController passwordController,
  AuthProvider authProvider,
  BuildContext context,
) {
  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'First Name',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 8),
        TextField(
          controller: firstNameController,
          decoration: InputDecoration(
            hintText: "abc",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: purpleColor),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Last Name',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 8),
        TextField(
          controller: lastNameController,
          decoration: InputDecoration(
            hintText: "def",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: purpleColor),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Email',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 8),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: "abc@abc.com",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: purpleColor),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Password',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Enter a password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: purpleColor),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: GestureDetector(
            onTap: () async {
              if (emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty &&
                  lastNameController.text.isNotEmpty &&
                  firstNameController.text.isNotEmpty) {
                await authProvider
                    .signUp(
                      emailController.text,
                      firstNameController.text,
                      lastNameController.text,
                      passwordController.text,
                    )
                    .then((value) {
                      if (authProvider.userModel != null) {
                        if (authProvider.errorCode == 'email-already-in-use') {
                          showMySnackBar(
                            context,
                            'This email is already registered.',
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmailVerifyView(),
                            ),
                          );
                        }
                      }
                    });
                emailController.clear();
                passwordController.clear();
                firstNameController.clear();
                lastNameController.clear();
              } else {
                showMySnackBar(context, 'Please fill all the fields.');
              }
            },
            child: Container(
              width: double.infinity,
              height: 47,
              decoration: BoxDecoration(
                color: purpleColor, // Same background color
                borderRadius: BorderRadius.circular(40), // Same rounded corners
              ),
              child: const Center(
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        Center(
          child: const Text(
            "Login if you already have an account!",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}
