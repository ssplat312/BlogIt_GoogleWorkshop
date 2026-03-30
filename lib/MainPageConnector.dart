import "SessionInfo.dart";
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'HomePage.dart';
import 'PostingPage.dart';
import 'ProfilePage.dart';
import 'Settings.dart';

class MainPageConnector extends StatefulWidget {
  const MainPageConnector({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // a lways marked "final".

  @override
  State<MainPageConnector> createState() => _MainPageConnectorState();
}

class _MainPageConnectorState extends State<MainPageConnector> {
  bool isLoading = true;
  final Sessioninfo sharedsessioninfo = Sessioninfo(
    (FirebaseAuth.instance.currentUser)!.uid,
  );

  //Changes the index of the page selected
  //The acutaul page selection is based off of the MainPages List

  Future<void> SetSessionInfo() async {
    if (sharedsessioninfo.gotData) {
      return;
    }
    print("Setting seasion info");

    await sharedsessioninfo.SetUpInfo(
      userId: (FirebaseAuth.instance.currentUser)!.uid,
    );

    print("Setting main pages");
    MainPages = [
      MainHomePage(sessioninfo: sharedsessioninfo),
      PostingPage(sessioninfo: sharedsessioninfo),
      ProfilePage(sessioninfo: sharedsessioninfo),
      SettingsPage(sessioninfo: sharedsessioninfo),
    ];
  }

  void ChangePage(int selectedIndex) {
    int curPageIndex = context.read<NavProvider>().curPageIndex;
    if (selectedIndex == curPageIndex) {
      return;
    }

    int prevIndex = curPageIndex;
    setState(() {
      context.read<NavProvider>().setIndex(selectedIndex);
    });
  }

  List<Widget> MainPages =
      []; //Is set in SetSessionInfo(because each page relays on the session info )
  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavProvider>();

    return FutureBuilder(
      future: SetSessionInfo(),
      builder: (context, snapshot) {
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,

            currentIndex: navProvider.curPageIndex,
            onTap: ChangePage,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.add), label: "Post"),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Settings",
              ),
            ],
          ),
          body: Stack(
            children: [
              Scaffold(
                body: IndexedStack(
                  index: navProvider.curPageIndex,
                  children: MainPages,
                ),
              ),
              if (snapshot.connectionState != ConnectionState.done)
                IgnorePointer(ignoring: false, child: LoadingPage()),
            ],
          ),
        );
      },
    );
  }
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
      appBar: AppBar(title: Text("Loading..."), backgroundColor: Colors.white),
    );
  }
}
