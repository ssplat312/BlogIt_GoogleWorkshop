import 'SignUpPage.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainLoginPage extends StatefulWidget {
  const MainLoginPage({super.key});

  @override
  State<MainLoginPage> createState() => _MainLoginPageState();
}

class _MainLoginPageState extends State<MainLoginPage> {
  TextEditingController passwordInput = TextEditingController();
  TextEditingController emailInput = TextEditingController();

  void login() async {
    print(emailInput.text);
    print(passwordInput.text);
    if (emailInput.text.trim() == "" || passwordInput.text.trim() == "") {
      ClearEmptyInputs();
      return;
    }

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailInput.text,
      password: passwordInput.text,
    );
  }

  void ClearEmptyInputs() {
    if (emailInput.text.trim() == "") {
      emailInput.clear();
    }

    if (passwordInput.text.trim() == "") {
      passwordInput.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Blog It Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Login"),
            TextField(
              controller: emailInput,
              decoration: InputDecoration(
                labelText: "Enter Email",

                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: passwordInput,
              decoration: InputDecoration(
                labelText: "Enter Password",
                border: OutlineInputBorder(),
              ),
            ),

            ElevatedButton(onPressed: login, child: Icon(Icons.login_outlined)),
            ElevatedButton(
              onPressed: (() => Get.to(SignUpPage())),
              child: Text("Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
