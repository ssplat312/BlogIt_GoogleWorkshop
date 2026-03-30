import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Bloginfo extends ResponseInfo {
  String blogID = ""; //Is just the document id.
  bool isHidden = false;
  String title = "";
  int views = 0;
  List<String> tags = [];
  Bloginfo() : super();
  void SetBlogInfo(Map<String, dynamic> blogMap, String blogId) {
    this.blogID = blogId;
    isHidden = blogMap.containsKey("isHidden") ? blogMap["isHidden"] : false;
    title = blogMap.containsKey("Title") ? blogMap["Title"] : "Title";
    views = blogMap.containsKey("Views") ? blogMap["Views"] : 0;
    tags = blogMap.containsKey("Tags") ? List.from(blogMap["Tags"]) : [];

    super.SetResponseInfo(blogMap);
  }

  Map<String, dynamic> ConvertBlogToMap() {
    Map<String, dynamic> baseMap = ConvertToMap();

    baseMap.addAll({
      "isHidden": isHidden,
      "Title": title,
      "Views": views,
      "Tags": tags,
    });

    return baseMap;
  }

  String TagsToStringFormat() {
    String output = "";

    for (String tag in tags) {
      output += "#" + tag + " ";
    }

    return output;
  }
}

class ResponseInfo {
  DateTime timePosted = DateTime.now();

  List<String> userUpvotes = [];
  List<String> userDownvotes = [];

  String mainUser = "";
  String mainMessage = "";
  List<ResponseInfo> responses = [];

  void AddComment(String userName, String comemnt) {
    ResponseInfo newComment = ResponseInfo();
    newComment.mainMessage = comemnt;
    newComment.mainUser = userName;

    responses.add(newComment);
  }

  void AddCommentWithPath(
    List<int> layerPath,
    String userName,
    String comemnt,
  ) {
    if (layerPath.length == 0) {
      AddComment(userName, comemnt);
      return;
    }
    ResponseInfo curInfo = responses[layerPath[0]];
    for (int i = 1; i < layerPath.length; i++) {
      curInfo = curInfo.responses[layerPath[i]];
    }
    ResponseInfo newComment = ResponseInfo();
    newComment.mainMessage = comemnt;
    newComment.mainUser = userName;

    curInfo.responses.add(newComment);
  }

  ResponseInfo GetResponse(List<int> layerPath) {
    if (layerPath.isEmpty) {
      return this;
    }
    ResponseInfo curInfo = responses[layerPath[0]];
    for (int i = 1; i < layerPath.length; i++) {
      curInfo = curInfo.responses[layerPath[i]];
    }

    return curInfo;
  }

  void SetResponseInfo(Map<String, dynamic> responseMap) {
    this.timePosted = responseMap.containsKey("DatePosted")
        ? (responseMap["DatePosted"] as Timestamp).toDate()
        : DateTime.now();

    this.userUpvotes = responseMap.containsKey("UserUpvotes")
        ? List.from(responseMap["UserUpvotes"])
        : [];
    this.userDownvotes = responseMap.containsKey("UserDownvotes")
        ? List.from(responseMap["UserDownvotes"])
        : [];
    this.mainUser = responseMap.containsKey("MainUser")
        ? responseMap["MainUser"]
        : "";
    this.mainMessage = responseMap.containsKey("MainMessage")
        ? responseMap["MainMessage"]
        : "";

    List<Map<String, dynamic>> responses = responseMap.containsKey("Responses")
        ? List.from(responseMap["Responses"])
        : [];

    for (int i = 0; i < responses.length; i++) {
      this.responses.add(MakeResponseInfo(responses[i]));
    }
  }

  ResponseInfo MakeResponseInfo(Map<String, dynamic> responseMap) {
    ResponseInfo newInfo = ResponseInfo();

    newInfo.timePosted = responseMap.containsKey("DatePosted")
        ? (responseMap["DatePosted"] as Timestamp).toDate()
        : DateTime.now();
    newInfo.userUpvotes = responseMap.containsKey("UserUpvotes")
        ? List.from(responseMap["UserUpvotes"])
        : [];
    newInfo.userDownvotes = responseMap.containsKey("UserDownvotes")
        ? List.from(responseMap["UserDownvotes"])
        : [];
    newInfo.mainUser = responseMap.containsKey("MainUser")
        ? responseMap["MainUser"]
        : "";
    newInfo.mainMessage = responseMap.containsKey("MainMessage")
        ? responseMap["MainMessage"]
        : "";

    List<Map<String, dynamic>> responses = responseMap.containsKey("Responses")
        ? List.from(responseMap["Responses"])
        : [];
    for (int i = 0; i < responses.length; i++) {
      newInfo.responses.add(MakeResponseInfo(responses[i]));
    }
    return newInfo;
  }

  int GetTotalVotes() {
    return GetUpVotesAmount() + GetDownVotesAmount();
  }

  int GetUpVotesAmount() {
    return userUpvotes.length;
  }

  int GetDownVotesAmount() {
    return userDownvotes.length;
  }

  void UpVoteBlog(String userID) {
    if (userUpvotes.contains(userID)) {
      userUpvotes.remove(userID);
    } else {
      userUpvotes.add(userID);
      if (userDownvotes.contains(userID)) {
        userDownvotes.remove(userID);
      }
    }
  }

  bool HasUserLiked(String userID) {
    return userUpvotes.contains(userID);
  }

  void DownVoteBlog(String userID) {
    if (userDownvotes.contains(userID)) {
      userDownvotes.remove(userID);
    } else {
      userDownvotes.add(userID);
      if (userUpvotes.contains(userID)) {
        userUpvotes.remove(userID);
      }
    }
  }

  bool HasUserDisLiked(String userID) {
    return userDownvotes.contains(userID);
  }

  String DateNumFormatString(int num) {
    if (num < 10) {
      return "0" + num.toString();
    }

    return num.toString();
  }

  String GetPostDateToString() {
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    String month = months[timePosted.month - 1];
    String dateStr =
        month +
        " " +
        DateNumFormatString(timePosted.day) +
        ", " +
        timePosted.year.toString();

    int hour = timePosted.hour > 12 ? timePosted.hour - 12 : timePosted.hour;
    if (timePosted.hour == 0) {
      hour = 12;
    }
    String timePeriod = timePosted.hour >= 12 ? "PM" : "AM";
    dateStr +=
        " " +
        DateNumFormatString(hour) +
        ":" +
        DateNumFormatString(timePosted.minute) +
        " " +
        timePeriod;
    return dateStr;
  }

  Map<String, dynamic> ConvertToMap() {
    Map<String, dynamic> tempMap = {
      "DatePosted": timePosted,
      "UserUpvotes": userUpvotes,
      "UserDownvotes": userDownvotes,
      "MainUser": mainUser,
      "MainMessage": mainMessage,
      "Responses": [],
    };

    for (int i = 0; i < responses.length; i++) {
      tempMap["Responses"].add(ConvertResponseToMap(responses[i]));
    }
    return tempMap;
  }

  Map<String, dynamic> ConvertResponseToMap(ResponseInfo responseInfo) {
    Map<String, dynamic> tempMap = {
      "DatePosted": responseInfo.timePosted,

      "UserUpvotes": responseInfo.userUpvotes,
      "UserDownvotes": responseInfo.userDownvotes,
      "MainUser": responseInfo.mainUser,
      "MainMessage": responseInfo.mainMessage,
      "Responses": [],
    };
    for (int i = 0; i < responseInfo.responses.length; i++) {
      tempMap["Responses"].add(ConvertResponseToMap(responseInfo.responses[i]));
    }
    return tempMap;
  }
}
