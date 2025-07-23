import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardians_eye/admin_page.dart';
import 'package:guardians_eye/registered_cases_screen.dart';
import 'package:nb_utils/nb_utils.dart';

class AuthViewModel extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var showPassword = false.obs;
  var isLoading = false.obs;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      isLoading(true);

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        throw "Please enter both email and password";
      }

      // Authenticate user
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user role from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (!userDoc.exists) {
        throw "User not registered in the system";
      }
      final userRole = userDoc.data()?['role'] ?? 'staff';
      final userName = userDoc.data()?['name'] ?? 'User';
      await setValue('user_role', userRole);
      // Check authorization
      if (userRole != 'staff' && userRole != 'admin') {
        throw "Not authorized as staff";
      }

      if (userRole != 'admin' && userRole != 'staff') {
        throw "Admin privileges required";
      }

      // Successful login
      Get.offAll(
          () => userRole == 'admin' ? AdminPage() : RegisteredCasesScreen());
      Get.snackbar(
        "Welcome $userName",
        "Logged in as ${userRole.toUpperCase()}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Login Failed",
        e.message ?? "Authentication error",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
