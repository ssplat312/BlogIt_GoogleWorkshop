import 'BlogInfo.dart';
import 'TagInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'PersonalInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Contains all the information that isn't being constantly updated(user data, settings, etc)

//For Session info stuff(combing all the information for ease of use)
class Sessioninfo {
  String userId = ""; //How the user will be identified
  bool gotData = false;
  var userData = FirebaseFirestore.instance.collection(
    "UsersData",
  ); //The collection of user data
  var tagsData = FirebaseFirestore.instance.collection("TagsData");
  var postData = FirebaseFirestore.instance.collection("PostsData");
  Personalinfo userInfo = Personalinfo();
  List<Bloginfo> blogsUsed = [];

  Sessioninfo(this.userId);

  Size GetScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double GetHeight(double curHeight, double heightPercentage) {
    return curHeight * Clamp01(heightPercentage);
  }

  double GetWidth(double curWidth, double widthPercentage) {
    return curWidth * Clamp01(widthPercentage);
  }

  double Clamp01(double input) {
    if (input < 0) {
      return 0;
    }

    if (input > 1) {
      return 1;
    }

    return input;
  }

  Future<void> SetUpInfo({String userId = ""}) async {
    gotData = false;
    if (userId.trim() != "") {
      this.userId = userId;
    }

    await userInfo.SetUserData(userId);
    print("Set up user data");
    await SetPostsData();

    print("Set up post data");
    gotData = true;
  }

  Future<void> SetPostsData() async {
    var tempPostData = await postData.limit(2000).get();
    for (int i = 0; i < tempPostData.docs.length; i++) {
      Bloginfo tempBlog = Bloginfo();
      print("Got Blog Data");
      bool canUse = true;

      try {
        tempPostData.docs[i].data();
      } catch (e) {
        print(e);
        canUse = false;
      }
      if (canUse == false) {
        continue;
      }
      tempBlog.SetBlogInfo(
        tempPostData.docs[i].data(),
        tempPostData.docs[i].id,
      );
      print("Convert Blog Data");

      blogsUsed.add(tempBlog);
      print(tempBlog.title);
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return userInfo.toString() + "\n" + userInfo.settingsInfo.toString();
  }

  void UpdateUserDatabase() async {
    Map<String, dynamic> currentData = userInfo.GetUserMap();
    await userData.doc(userInfo.userDocumentId).update(currentData);
  }

  void AddNewBlog(Bloginfo blogInfo) async {
    var tempData = await postData.add(blogInfo.ConvertBlogToMap());
    blogInfo.blogID = tempData.id;
    blogsUsed.insert(0, blogInfo);
  }

  void UpdateBlogDatabase(Bloginfo blogInfo) async {
    postData.doc(blogInfo.blogID).update(blogInfo.ConvertBlogToMap());
  }

  void AddNewTag(Taginfo tagInfo) async {
    tagsData.add(tagInfo.ConvertToMap());
  }

  void UpdateTagDatabase(Taginfo tagInfo) async {
    tagsData.doc(tagInfo.tagID).update(tagInfo.ConvertToMap());
  }

  void signout() async {
    await FirebaseAuth.instance.signOut();
  }
}
