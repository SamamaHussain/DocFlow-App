import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docflow/Models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? userModel;
  bool? isEmailVerified;
  bool loggedIn = false;
  bool isLoading = false;
  String? errorCode;

  AuthProvider() {
    checkSession();
  }

  void checkSession() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await getUserData(currentUser.uid);
      dev.log('User is currently logged in: ${userModel?.uId}');
    } else {
      dev.log('No user is currently logged in.');
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    userModel = UserModel(email: email);
    isLoading = true;
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userModel!.email!,
        password: password,
      );
      dev.log('Logged in successfully');
      loggedIn = true;

      if (credential.user?.uid != null) {
        userModel?.uId = credential.user!.uid;
        print(userModel);

        isEmailVerified = credential.user!.emailVerified;
        notifyListeners();
        if (credential.user != null) {
          if (credential.user!.emailVerified == true) {
            await getUserData(userModel!.uId!);
            isEmailVerified = true;
          } else {
            isEmailVerified = false;
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        dev.log('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        dev.log('Wrong password provided for that user.');
      }
      dev.log('${e.code}');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> signUp(
    String email,
    String firstname,
    String lastname,
    String password,
  ) async {
    userModel = UserModel(
      email: email,
      FirstName: firstname,
      LastName: lastname,
    );
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: userModel!.email!,
            password: password,
          );
      if (credential.user != null) {
        userModel!.uId = credential.user!.uid;
        await SaveUserData(userModel!.uId!, email, firstname, lastname);
      }
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        dev.log('The password provided is too weak.');
        errorCode = 'weak-password';
      } else if (e.code == 'email-already-in-use') {
        dev.log('The account already exists for that email.');
        errorCode = 'email-already-in-use';
      }
    } catch (e) {
      dev.log('$e');
      errorCode = e as String;
    }
    notifyListeners();
  }

  Future<void> reloadUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    isEmailVerified = user?.emailVerified;
    userModel = UserModel(uId: user?.uid);
    await getUserData(userModel!.uId!);
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      notifyListeners();
    } catch (e) {
      dev.log('Error while signing out: $e');
      notifyListeners();
    }
  }

  Future<void> SaveUserData(
    String UserId,
    String email,
    String FirstName,
    String Lastname,
  ) async {
    userModel = UserModel(
      uId: UserId,
      email: email,
      FirstName: FirstName,
      LastName: Lastname,
    );

    final userData = {
      'uId': userModel?.uId,
      'email': userModel?.email,
      'firstname': userModel?.FirstName,
      'lastname': userModel?.LastName,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel?.uId)
          .set(userData);

      dev.log('User data is saved successfully');
      ChangeNotifier();
    } catch (e) {
      dev.log('Error while saving data: ${e}');
    }
    notifyListeners();
  }

  Future<void> getUserData(String uId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data(); // returns Map<String, dynamic>
        userModel = UserModel(
          FirstName: data!['firstname'],
          LastName: data['lastname']!,
          email: data['email']!,
          uId: uId,
        );
      } else {
        print("No user found with this ID");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    notifyListeners();
  }

  Future<List<String>> fetchEmails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      final emails = snapshot.docs
          .map((doc) => doc['email'] as String)
          .where((email) => email.isNotEmpty)
          .toList();

      return emails;
    } catch (e) {
      debugPrint('Error fetching emails: $e');
      return [];
    }
  }

  Future<void> sendVerifyEmail() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    await currentUser?.sendEmailVerification();
  }
}
