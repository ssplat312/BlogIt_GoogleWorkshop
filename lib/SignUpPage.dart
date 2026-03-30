import 'Connector.dart';
import 'PersonalInfo.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'PersonalInfo.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController passwordInput = TextEditingController();
  TextEditingController emailInput = TextEditingController();
  TextEditingController userInput = TextEditingController();
  int minpasswordLength = 6;
  //The collection of user data
  var userData = FirebaseFirestore.instance.collection("UsersData");

  String? userNameCheckAsync = null;
  Future<void> CheckUserName(String? value) async {
    var tempData = await userData
        .where("Username", isEqualTo: value!.trim())
        .limit(1)
        .get();

    setState(() {
      if (tempData.docs.length >= 1) {
        userNameCheckAsync = "Username Taken";
      } else {
        userNameCheckAsync = null;
      }
    });
  }

  void signin() async {
    print(emailInput.text);
    print(passwordInput.text);
    if (emailInput.text.trim() == "" || passwordInput.text.trim() == "") {
      ClearEmptyInputs();
      return;
    }

    var tempData = await userData
        .where("Username", isEqualTo: userInput.text.trim())
        .limit(1)
        .get();

    if (tempData.size == 1) {
      print("This username is taken");
      return;
    }
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailInput.text,
      password: passwordInput.text,
    );

    String userId = (FirebaseAuth.instance.currentUser)!.uid;
    print(userId);

    Personalinfo tempInfo = Personalinfo();
    tempInfo.userName = userInput.text.trim();
    tempInfo.userId = userId;
    userData.add(tempInfo.GetUserMap());

    Get.offAll(WrapperPage());
  }

  void ClearEmptyInputs() {
    if (emailInput.text.trim() == "") {
      emailInput.clear();
    }

    if (passwordInput.text.trim() == "") {
      passwordInput.clear();
    }
  }

  bool IsValidPassword() {
    return true;
  }

  bool IsValidEmail() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Blog It Sign up"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sign up"),
            TextFormField(
              onChanged: (value) {
                // You can add synchronous validation here first
                if (value.isNotEmpty) {
                  CheckUserName(value);
                } else {
                  setState(() {
                    userNameCheckAsync = null;
                  });
                }
              },
              controller: userInput,
              validator: (value) {
                return userNameCheckAsync;
              },
              decoration: InputDecoration(
                labelText: "Enter Username",

                border: OutlineInputBorder(),
              ),
            ),
            TextFormField(
              controller: emailInput,
              decoration: InputDecoration(
                labelText: "Enter Email",

                border: OutlineInputBorder(),
              ),
            ),
            TextFormField(
              controller: passwordInput,
              decoration: InputDecoration(
                labelText: "Enter Password",
                errorStyle: TextStyle(color: Colors.red),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.length < minpasswordLength) {
                  return "Password must be atlest 6 characters";
                }

                return null;
              },
            ),

            FloatingActionButton(onPressed: signin, child: Text("Sign in")),
          ],
        ),
      ),
    );
  }
}
