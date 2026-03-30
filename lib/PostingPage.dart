import 'BlogInfo.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:provider/provider.dart';
import 'SessionInfo.dart';

class PostingPage extends StatefulWidget {
  const PostingPage({super.key, required this.sessioninfo});

  final Sessioninfo sessioninfo;
  @override
  _PostingPageState createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  TextEditingController titleInput = TextEditingController();
  TextEditingController messageInput = TextEditingController();
  void PostBlog() {
    Bloginfo blogInfo = Bloginfo();
    String titleText = titleInput.text.trim();
    String bodyText = messageInput.text.trim();
    if (titleText.length < 3 || titleText.length > 32) {
      return;
    }

    if (bodyText.length < 64 || bodyText.length > 65536) {
      return;
    }
    blogInfo.title = titleText;
    blogInfo.mainMessage = bodyText;
    blogInfo.mainUser = widget.sessioninfo.userInfo.userName;
    setState(() {
      widget.sessioninfo.AddNewBlog(blogInfo);
      titleInput.text = "";
      messageInput.text = "";
    });
    context.read<NavProvider>().setIndex(0);
  }

  Color appbarColor = Colors.red;
  Color backgroundColor = Colors.grey;

  //Title UI
  InputDecoration titleDecoration = InputDecoration(
    border: OutlineInputBorder(),
    filled: true,
    fillColor: Colors.blueGrey,
    labelText: "Enter Your Title(Between 3 and 32 characters)",
    labelStyle: TextStyle(color: Colors.blue),
  );
  TextAlign titleTextAlignment = TextAlign.left;

  //Blog UI
  InputDecoration blogDecoration = InputDecoration(
    border: OutlineInputBorder(),
    filled: true,
    fillColor: Colors.blueGrey,
    labelText: "Enter Your Blog (Between 64 and 65536 characters)",
    labelStyle: TextStyle(color: Colors.blue),
  );
  TextAlign blogTextAlignment = TextAlign.left;
  @override
  Widget build(BuildContext context) {
    Size size = widget.sessioninfo.GetScreenSize(context);
    double marginTop = widget.sessioninfo.GetHeight(size.height, .05);
    double messageHeight = widget.sessioninfo.GetHeight(size.height, .58);
    print(size);
    return Scaffold(
      appBar: AppBar(title: Text("Posting Page"), backgroundColor: appbarColor),
      backgroundColor: backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.only(top: marginTop),
            child: TextField(
              controller: titleInput,

              textAlign: titleTextAlignment,
              maxLength: 32,
              decoration: titleDecoration,
            ),
          ),
          SizedBox(
            height: messageHeight,

            child: TextField(
              controller: messageInput,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlign: blogTextAlignment,
              maxLength: 65536,
              decoration: blogDecoration,
            ),
          ),
          FloatingActionButton(onPressed: PostBlog, child: Icon(Icons.add)),
        ],
      ),
    );
  }
}
