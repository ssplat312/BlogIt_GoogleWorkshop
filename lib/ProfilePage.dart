import 'package:flutter/material.dart';
import 'SessionInfo.dart';
//Should be able to change user name
//Should be able to change biography
//Max Icon size is 600X600

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.sessioninfo});

  final Sessioninfo sessioninfo;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String curBiography = "";
  String username = "";
  TextEditingController biographyInput = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SetBaseInfo();
  }

  void SetBaseInfo() {
    setState(() {
      curBiography = widget.sessioninfo.userInfo.biography;
      username = widget.sessioninfo.userInfo.userName;
      biographyInput.text = curBiography;
    });
  }

  void UpdateBiography() {
    String newBiography = biographyInput.text.trim();
    if (newBiography == "") {
      return;
    }
    if (curBiography == newBiography) {
      return;
    }

    setState(() {
      curBiography = newBiography;
      widget.sessioninfo.userInfo.biography = curBiography;
      widget.sessioninfo.UpdateUserDatabase();
    });
  }

  //UI elments variables'
  TextAlign biographyTextAlignment = TextAlign.left;
  InputDecoration biographyDecoration = InputDecoration(
    border: OutlineInputBorder(),
    fillColor: Colors.white,
    filled: true,
    labelText: "Enter Your Biography",
  );
  Color appbarColor = Colors.blue;
  Color backgroundColor = Colors.redAccent;
  @override
  Widget build(BuildContext context) {
    Size size = widget.sessioninfo.GetScreenSize(context);
    print(size);

    //These variables control the how the UI looks that need to be updated real time
    double biographyHeight = widget.sessioninfo.GetHeight(size.height, .5);

    print("New Biography Height: ${biographyHeight.toString()}");
    return Scaffold(
      appBar: AppBar(title: Text("User Page"), backgroundColor: appbarColor),
      backgroundColor: backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("You are $username", style: TextStyle(fontSize: 20)),
          SizedBox(
            height: biographyHeight,
            child: TextField(
              expands: true,
              maxLines: null,
              minLines: null,
              controller: biographyInput,
              textAlign: biographyTextAlignment,
              maxLength: 65536,
              decoration: biographyDecoration,
            ),
          ),
          FloatingActionButton(
            onPressed: UpdateBiography,
            child: Icon(Icons.update),
          ),
          Text("Update Biography"),
          FloatingActionButton(
            onPressed: (() => {widget.sessioninfo.signout()}),
            child: Icon(Icons.door_back_door),
          ),
          Text("Sign Out"),
        ],
      ),
    );
  }
}
