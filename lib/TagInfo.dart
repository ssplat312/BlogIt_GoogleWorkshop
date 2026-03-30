import 'package:cloud_firestore/cloud_firestore.dart';

class Taginfo {
  String tagName = "";
  DateTime lastTimeUsed = DateTime.now();
  int usedAmount = 0;
  String tagID = ""; //Document ID

  Map<String, dynamic> ConvertToMap() {
    return {
      "TagName": tagName,
      "LastUsed": Timestamp.fromDate(lastTimeUsed),
      "UsedAmount": usedAmount,
    };
  }

  void SetTagInfo(Map<String, dynamic> tagMap) {
    tagName = tagMap.containsKey("TagName") ? tagMap["TagName"] : "";
    lastTimeUsed = tagMap.containsKey("LastUsed")
        ? (tagMap["LastUsed"] as Timestamp).toDate()
        : DateTime.now();
    usedAmount = tagMap.containsKey("UsedAmount") ? tagMap["UsedAmount"] : 0;
  }
}
