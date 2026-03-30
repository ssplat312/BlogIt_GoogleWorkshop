import 'MainLogin.dart';
import 'HomePage.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MainPageConnector.dart';

class WrapperPage extends StatelessWidget {
  const WrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainPageConnector();
          } else {
            return MainLoginPage();
          }
        },
      ),
    );
  }
}
