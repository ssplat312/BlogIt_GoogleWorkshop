import 'dart:ffi';
import 'dart:math';
import 'dart:ui' as DartUI;

import 'SessionInfo.dart';
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
import "BlogInfo.dart";

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key, required this.sessioninfo});

  final Sessioninfo sessioninfo;
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final user = FirebaseAuth.instance.currentUser;
  Random randGenerator = Random();
  var userData = null;
  List<Bloginfo> blogsUsed = [];
  List<List<Container>> blogsContainers = [[]];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> postData = [];
  int maxPostsPerPage = 20;
  List<Container> recentPosts = [];
  final ScrollController mainScrollControler = ScrollController();
  String userName = "";
  int refreshTime = 1;
  int blogsAmount = 0;
  Map<String, bool> isResponseVisible = {
    "": false,
  }; //Response path to visiblelity state
  @override
  void initState() {
    super.initState();
    SetUpPage();
  }

  @override
  void dispose() {
    mainScrollControler.dispose();
    super.dispose();
  }

  Future<void> SetUpPage() async {
    setState(() {
      userName = GetUserName();
      blogsAmount = widget.sessioninfo.blogsUsed.length;
    });
    RefreshPostsTimer();
  }

  //A timer that when finished refreshes the posts
  Future<void> RefreshPostsTimer() async {
    await Future.delayed(Duration(seconds: refreshTime));
    RefreshPosts();
  }

  //Refreshs the posts to show new ones
  void RefreshPosts() async {
    int curblogsAmount = widget.sessioninfo.blogsUsed.length;

    if (blogsAmount == curblogsAmount) {
      RefreshPostsTimer();
      return;
    }
    blogsAmount = curblogsAmount;
    setState(() {
      print("Refreshing Posts");
    });
    RefreshPostsTimer();
  }

  void ShowPosts(int curIndex) {
    if (curIndex < 0) {
      return;
    }
    int startIndex = curIndex * maxPostsPerPage;
    if (startIndex >= widget.sessioninfo.blogsUsed.length) {
      return;
    }
    int endIndex = (curIndex + 1) * maxPostsPerPage;
    if (endIndex >= widget.sessioninfo.blogsUsed.length) {
      endIndex = widget.sessioninfo.blogsUsed.length;
    }

    recentPosts.clear();

    for (int i = startIndex; i < endIndex; i++) {
      recentPosts.add(
        Container(child: Center(child: CircularProgressIndicator())),
      );
      Container tempPost = ConvertInfoToPost(
        widget.sessioninfo.blogsUsed[i],
        i,
      );
      recentPosts.removeLast();
      recentPosts.add(tempPost);
    }
  }

  List<Container> GetPosts(int curIndex) {
    if (curIndex < 0) {
      return [];
    }
    int startIndex = curIndex * maxPostsPerPage;
    if (startIndex >= widget.sessioninfo.blogsUsed.length) {
      return [Container(child: Text("No Blogs Found"))];
    }
    int endIndex = (curIndex + 1) * maxPostsPerPage;
    print(widget.sessioninfo.blogsUsed.length);
    if (endIndex >= widget.sessioninfo.blogsUsed.length) {
      endIndex = widget.sessioninfo.blogsUsed.length;
    }

    List<Container> tempPosts = [];
    for (int i = startIndex; i < endIndex; i++) {
      tempPosts.add(
        Container(child: Center(child: CircularProgressIndicator())),
      );
      Container tempPost = ConvertInfoToPost(
        widget.sessioninfo.blogsUsed[i],
        i,
      );
      tempPosts.removeLast();
      tempPosts.add(tempPost);
    }

    return tempPosts;
  }

  void UpVoteAction(List<int> layerPath) {
    Bloginfo curInfo = widget.sessioninfo.blogsUsed[layerPath[0]];
    layerPath.removeAt(0);
    ResponseInfo responseInfo = curInfo.GetResponse(layerPath);
    setState(() {
      responseInfo.UpVoteBlog(widget.sessioninfo.userId);
      widget.sessioninfo.UpdateBlogDatabase(curInfo);
    });
  }

  void DownVoteAction(List<int> layerPath) {
    Bloginfo curInfo = widget.sessioninfo.blogsUsed[layerPath[0]];
    layerPath.removeAt(0);
    ResponseInfo responseInfo = curInfo.GetResponse(layerPath);
    setState(() {
      responseInfo.DownVoteBlog(widget.sessioninfo.userId);
      widget.sessioninfo.UpdateBlogDatabase(curInfo);
    });
  }

  void SeeComments(List<int> layerPath) {
    setState(() {
      isResponseVisible[layerPath.join(",")] =
          !(isResponseVisible[layerPath.join(",")] ?? false);
    });
  }

  void AddComment(List<int> layerPath, TextEditingController inputText) {
    String comment = inputText.text.trim();
    if (comment == "") {
      return;
    }
    int startIndex = layerPath[0];
    layerPath.removeAt(0);
    Bloginfo curBlog = widget.sessioninfo.blogsUsed[startIndex];

    setState(() {
      curBlog.AddCommentWithPath(layerPath, userName, comment);
      widget.sessioninfo.UpdateBlogDatabase(curBlog);
    });
  }

  Row GetSelectedRow(List<int> layerPath) {
    Row row = Row();
    List<Container> curContainers = [];
    for (int i = 0; i < layerPath.length; i++) {
      if (i == 0) {
        row = recentPosts[layerPath[i]].child as Row;
      } else {
        row = curContainers[layerPath[i]].child as Row;
      }

      Visibility tempVisibility = row.children.last as Visibility;
      Align tempAlign = tempVisibility.child as Align;
      Column tempColumn = tempAlign.child as Column;
      curContainers = tempColumn.children[0] as List<Container>;
    }
    return row;
  }

  Container ConvertInfoToPost(Bloginfo postInfo, int index) {
    Container titleContainer = Container(
      width: postWidth,

      color: titleColor,
      child: Text(postInfo.title, style: blogTitleStyle),
    );

    Container userContainer = Container(
      width: postWidth,

      color: userColor,
      child: Text(postInfo.mainUser, style: blogUsernameStyle),
    );
    Container dateContainer = Container(
      width: postWidth,

      color: dateColor,
      child: Text(
        ("Posted: " + postInfo.GetPostDateToString()),
        style: blogDateStyle,
      ),
    );

    String tagsText = postInfo.TagsToStringFormat();
    if (tagsText.trim() != "") {
      tagsText = "\n" + tagsText;
    }
    Container messageContainer = Container(
      width: postWidth,

      color: messageColor,
      child: Text((postInfo.mainMessage + tagsText), style: blogMessageStyle),
    );
    List<int> layerPath = [index];
    FloatingActionButton upVoteButton = FloatingActionButton(
      onPressed: (() => {UpVoteAction(layerPath)}),
      backgroundColor: postInfo.HasUserLiked(widget.sessioninfo.userId)
          ? voteSelectColor
          : voteNotSelectColor,
      child: Column(
        children: [
          Icon(Icons.arrow_upward),
          Text(postInfo.GetUpVotesAmount().toString()),
        ],
      ),
    );
    FloatingActionButton downVoteButton = FloatingActionButton(
      onPressed: (() => {DownVoteAction(layerPath)}),
      backgroundColor: postInfo.HasUserDisLiked(widget.sessioninfo.userId)
          ? voteSelectColor
          : voteNotSelectColor,

      child: Column(
        children: [
          Icon(Icons.arrow_downward),
          Text(postInfo.GetDownVotesAmount().toString()),
        ],
      ),
    );

    FloatingActionButton checkCommentsButton = FloatingActionButton(
      onPressed: (() => {SeeComments(layerPath)}),
      backgroundColor: commentButtonColor,

      child: Column(
        children: [
          Icon(Icons.comment),
          Text(postInfo.responses.length.toString()),
        ],
      ),
    );
    Container viewsContainer = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: .5,
        mainAxisSize: MainAxisSize.min,
        children: [
          upVoteButton,
          downVoteButton,
          checkCommentsButton,
          Icon(Icons.remove_red_eye),
          Text(postInfo.views.toString()),
        ],
      ),
    );

    if (isResponseVisible.containsKey(layerPath.join((","))) == false) {
      isResponseVisible.addAll({layerPath.join(","): false});
    }
    Visibility responses = GetResponsesVisibility(layerPath);
    Column postColumn = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        titleContainer,
        userContainer,
        dateContainer,
        messageContainer,
        viewsContainer,
        responses,
      ],
    );
    Container postContainer = Container(
      decoration: BoxDecoration(
        border: Border.all(color: postBorderColor, width: 2),
        borderRadius: BorderRadius.circular(10.0),
        color: postBackgroundColor,
      ),
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 5),
      child: SelectionArea(child: postColumn),
    );

    return postContainer;
  }

  Visibility GetResponsesVisibility(List<int> layerPath) {
    ResponseInfo curInfo = widget.sessioninfo.blogsUsed[layerPath[0]];
    for (int i = 1; i < layerPath.length; i++) {
      curInfo = curInfo.responses[layerPath[i]];
    }

    List<Container> responseContainers = [];
    for (int i = 0; i < curInfo.responses.length; i++) {
      List<int> tempPath = List.from(layerPath);
      tempPath.add(i);
      if (isResponseVisible.containsKey(tempPath.join(",")) == false) {
        isResponseVisible.addAll({tempPath.join(","): false});
      }
      responseContainers.add(
        MakeResponseContainer(curInfo.responses[i], tempPath),
      );
    }

    TextEditingController textInputControler = TextEditingController();
    TextField commentInput = TextField(
      controller: textInputControler,
      expands: true,
      maxLines: null,
      minLines: null,
      maxLength: 8192,
      decoration: InputDecoration(
        labelText: "Enter Comment",
        border: OutlineInputBorder(),
      ),
    );
    SizedBox commentInputBox = SizedBox(
      width: GetCommentInputWidth(),
      child: commentInput,
    );
    FloatingActionButton addCommentButton = FloatingActionButton(
      onPressed: () {
        AddComment(layerPath, textInputControler);
      },
      child: Icon(Icons.send),
    );

    Row addCommentRow = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [commentInputBox, addCommentButton],
    );
    Container addCommentContainer = Container(
      width: GetCommentContainerWidth(),
      height: 100,
      child: addCommentRow,
    );
    responseContainers.add(addCommentContainer);
    Column column = Column(
      children: responseContainers,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );

    Align align = Align(
      alignment: Alignment.centerRight,
      widthFactor: 1.2,
      child: column,
    );

    Visibility responses = Visibility(
      visible: isResponseVisible[layerPath.join(",")] ?? false,
      maintainSize: false,
      child: align,
    );

    return responses;
  }

  Container MakeResponseContainer(
    ResponseInfo responseInfo,
    List<int> layerPath,
  ) {
    Container userContainer = Container(
      child: Text(responseInfo.mainUser, style: commentUsernameStyle),
      width: GetCommentWidth(),
      color: userColor,
    );

    Container dateContainer = Container(
      child: Text(
        "Posted: " + responseInfo.GetPostDateToString(),
        style: commentDateStyle,
      ),
      width: GetCommentWidth(),
      color: dateColor,
    );
    Container messageContainer = Container(
      child: Text(responseInfo.mainMessage, style: commentMessageStyle),
      width: GetCommentWidth(),
      color: messageColor,
    );
    FloatingActionButton upVoteButton = FloatingActionButton(
      onPressed: (() => {UpVoteAction(layerPath)}),
      backgroundColor: responseInfo.HasUserLiked(widget.sessioninfo.userId)
          ? voteSelectColor
          : voteNotSelectColor,
      child: Column(
        children: [
          Icon(Icons.arrow_upward),
          Text(responseInfo.GetUpVotesAmount().toString()),
        ],
      ),
    );
    FloatingActionButton downVoteButton = FloatingActionButton(
      onPressed: (() => {DownVoteAction(layerPath)}),
      backgroundColor: responseInfo.HasUserDisLiked(widget.sessioninfo.userId)
          ? voteSelectColor
          : voteNotSelectColor,
      child: Column(
        children: [
          Icon(Icons.arrow_downward),
          Text(responseInfo.GetDownVotesAmount().toString()),
        ],
      ),
    );

    FloatingActionButton checkCommentsButton = FloatingActionButton(
      onPressed: (() => {SeeComments(layerPath)}),
      backgroundColor: commentButtonColor,

      child: Column(
        children: [
          Icon(Icons.comment),
          Text(responseInfo.responses.length.toString()),
        ],
      ),
    );
    Container viewsContainer = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: .5,
        mainAxisSize: MainAxisSize.min,
        children: [upVoteButton, downVoteButton, checkCommentsButton],
      ),
    );

    Visibility responses = GetResponsesVisibility(layerPath);
    Column postColumn = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        userContainer,
        dateContainer,
        messageContainer,
        viewsContainer,
        responses,
      ],
    );
    Container postContainer = Container(
      color: postBackgroundColor,
      child: postColumn,
    );

    return postContainer;
  }

  void signout() async {
    await FirebaseAuth.instance.signOut();
  }

  String GetUserName() {
    return widget.sessioninfo.userInfo.userName;
  }

  String GetUserID() {
    return userData["ID"];
  }

  double GetCommentWidth() {
    return widget.sessioninfo.GetWidth(postWidth, .5);
  }

  double GetCommentInputWidth() {
    return widget.sessioninfo.GetWidth(
      GetCommentWidth(),
      commentInputWidthPercentage,
    );
  }

  double GetCommentContainerWidth() {
    return widget.sessioninfo.GetWidth(
      GetCommentWidth(),
      ((1.0 - commentInputWidthPercentage) / 2 + commentInputWidthPercentage),
    );
  }

  //UI elments variables
  Color appbarColor = Colors.blue;
  Color backgroundColor = Colors.amber;

  Color titleColor = Colors.grey;
  Color userColor = Colors.grey;
  Color dateColor = Colors.grey;
  Color messageColor = Colors.cyan;
  Color voteSelectColor = Colors.blueGrey;
  Color voteNotSelectColor = Colors.white10;
  Color commentButtonColor = Colors.white10;
  Color postBorderColor = Colors.black;
  Color postBackgroundColor = Colors.limeAccent;

  double postWidth = 0; //Final value is set in build function
  double commentInputWidthPercentage = .75;
  double postWidthPercentage = .75;

  TextStyle? userNameStyle = TextStyle();
  TextStyle? blogTitleStyle = TextStyle();
  TextStyle? blogUsernameStyle = TextStyle();
  TextStyle? blogMessageStyle = TextStyle();
  TextStyle? blogDateStyle = TextStyle();

  TextStyle? commentUsernameStyle = TextStyle();
  TextStyle? commentMessageStyle = TextStyle();
  TextStyle? commentDateStyle = TextStyle();

  @override
  Widget build(BuildContext context) {
    DartUI.Size size = widget.sessioninfo.GetScreenSize(context);
    userNameStyle = Theme.of(context).textTheme.displayLarge;
    blogTitleStyle = Theme.of(context).textTheme.displayLarge;
    blogUsernameStyle = Theme.of(context).textTheme.displaySmall;
    blogMessageStyle = Theme.of(context).textTheme.bodyLarge;
    blogDateStyle = Theme.of(context).textTheme.bodyLarge;
    commentUsernameStyle = Theme.of(context).textTheme.bodyLarge;
    commentDateStyle = Theme.of(context).textTheme.bodySmall;
    commentMessageStyle = Theme.of(context).textTheme.bodyMedium;
    postWidth = widget.sessioninfo.GetWidth(size.width, postWidthPercentage);
    print(postWidth);
    List<Container> curPosts = GetPosts(0);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarColor,
        title: const Text("Blog It"),
      ),
      backgroundColor: backgroundColor,
      body: Scrollbar(
        controller: mainScrollControler,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: mainScrollControler,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Welcome $userName!!!", style: userNameStyle),
                ...curPosts,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
