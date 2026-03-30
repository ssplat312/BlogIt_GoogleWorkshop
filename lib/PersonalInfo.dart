import 'package:cloud_firestore/cloud_firestore.dart';

//For User Related Stuffs
class Personalinfo {
  String userName = "";
  String userId = "";
  String userDocumentId = "";
  String biography = "";
  String status = "Online"; //If you're online, offline, etc.
  bool isSuppended = false;
  List<String> blogsPosted = []; //Ids of the blogs someone posted
  List<String> responsedMade = []; //Ids of the reponses someone posted
  SettingsInfo settingsInfo = SettingsInfo();
  Future<void> SetUserData(String userId) async {
    var tempUserData = await FirebaseFirestore.instance
        .collection("UsersData")
        .where("ID", isEqualTo: userId)
        .limit(1)
        .get();

    if (tempUserData.docs.isEmpty) {
      print("found nothing");
      return;
    }
    userDocumentId = tempUserData.docs.first.id;
    var userData = tempUserData.docs.first.data();

    //Setting the username
    if (userData.containsKey("Username") == false) {
      this.userName = "";
    } else {
      this.userName = userData["Username"];
    }
    //Setting the biography
    if (userData.containsKey("Biography") == false) {
      this.biography = "Test Biop";
    } else {
      this.biography = userData["Biography"];
    }

    if (userData.containsKey("ID") == false) {
      this.userId = "";
    } else {
      this.userId = userData["ID"];
    }

    if (userData.containsKey("Status") == false) {
      this.status = "";
    } else {
      this.status = userData["Status"];
    }

    if (userData.containsKey("isSuppended") == false) {
      this.isSuppended = false;
    } else {
      this.isSuppended = userData["isSuppended"];
    }
    blogsPosted = userData.containsKey("BlogsPosted")
        ? userData["BlogsPosted"]
        : [];
    responsedMade = userData.containsKey("ResponsesMade")
        ? userData["ResponsesMade"]
        : [];

    SetSettingInfo(userData);

    SafeGuardValues();
  }

  void SafeGuardValues() {
    if (status.trim() == "") {
      status = "Online";
    }
  }

  void SetSettingInfo(Map<String, dynamic> userData) {
    this.settingsInfo = SettingsInfo();
    if (userData.containsKey("Settings") == false) {
      return;
    }
    Map<String, dynamic> settingsData = userData["Settings"];
    settingsInfo.isHidden = settingsData.containsKey("IsHidden")
        ? settingsData["IsHidden"]
        : false;

    settingsInfo.postVisibility = settingsData.containsKey("PostVisibility")
        ? StringToVisibilityEnum(settingsData["PostVisibility"])
        : VisibilityAllowance.everyone;
    settingsInfo.statusChoice = settingsData.containsKey("StatusChoice")
        ? StringToVisibilityEnum(settingsData["StatusChoice"])
        : VisibilityAllowance.everyone;
  }

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }

  Map<String, dynamic> GetUserMap() {
    return {
      "Username": userName,
      "ID": userId,
      "Biography": biography,
      "Status": status,
      "isSuppended": isSuppended,
      "Settings": settingsInfo.GetSettingsMap(),
    };
  }
}

enum VisibilityAllowance { hidden, groupsOnly, everyone }

String VisibilityEnumToString(VisibilityAllowance statusChoice) {
  switch (statusChoice) {
    case VisibilityAllowance.everyone:
      return "Everyone";
    case VisibilityAllowance.groupsOnly:
      return "Groups Only";
    case VisibilityAllowance.hidden:
      return "Hidden";
  }
}

VisibilityAllowance StringToVisibilityEnum(String visibilityString) {
  switch (visibilityString) {
    case "Everyone":
      return VisibilityAllowance.everyone;
    case "Groups Only":
      return VisibilityAllowance.groupsOnly;
    case "Hidden":
      return VisibilityAllowance.hidden;
    default:
      return VisibilityAllowance.everyone;
  }
}

class SettingsInfo {
  bool isHidden = false; //Is your account hidden or not
  VisibilityAllowance postVisibility = VisibilityAllowance.everyone;
  VisibilityAllowance statusChoice = VisibilityAllowance.everyone;
  //SettingsInfo(this.statusChoice, this.isHidden, this.postVisibility);

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }

  void SetPostVisibilityWithString(String input) {
    postVisibility = StringToVisibilityEnum(input);
  }

  void SetStatusVisibilityWithString(String input) {
    statusChoice = StringToVisibilityEnum(input);
  }

  String GetPostVisibilityToString() {
    return VisibilityEnumToString(postVisibility);
  }

  String GetStatusVisibilityToString() {
    return VisibilityEnumToString(statusChoice);
  }

  Map<String, dynamic> GetSettingsMap() {
    return {
      "IsHidden": isHidden,
      "PostVisibility": VisibilityEnumToString(postVisibility),
      "StatusChoice": VisibilityEnumToString(statusChoice),
    };
  }
}
