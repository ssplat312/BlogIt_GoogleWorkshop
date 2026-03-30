import 'package:flutter/material.dart';
import 'SessionInfo.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.sessioninfo});

  final Sessioninfo sessioninfo;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isHidden = false;
  String statusVisibility = "Everyone";
  String postVisibility = "Everyone";
  List<String> visibilityOptions = ["Everyone", "Groups Only", "Hidden"];
  void OnIsHiddenCheckBox(bool? newVal) {
    setState(() {
      isHidden = newVal ?? false;
    });
  }

  void OnStatusVisibilityChange(String? newStatus) {
    setState(() {
      statusVisibility = newStatus ?? "Everyone";
    });
  }

  void OnPostVisibilityChange(String? newStatus) {
    setState(() {
      postVisibility = newStatus ?? "Everyone";
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SetBaseSettings();
  }

  void SetBaseSettings() {
    setState(() {
      isHidden = widget.sessioninfo.userInfo.settingsInfo.isHidden;
      postVisibility = widget.sessioninfo.userInfo.settingsInfo
          .GetPostVisibilityToString();
      statusVisibility = widget.sessioninfo.userInfo.settingsInfo
          .GetStatusVisibilityToString();
    });
  }

  void UpdateSettings() {
    setState(() {
      widget.sessioninfo.userInfo.settingsInfo.isHidden = isHidden;
      widget.sessioninfo.userInfo.settingsInfo.SetPostVisibilityWithString(
        postVisibility,
      );
      widget.sessioninfo.userInfo.settingsInfo.SetStatusVisibilityWithString(
        statusVisibility,
      );
      widget.sessioninfo.UpdateUserDatabase();
    });
  }

  List<DropdownMenuItem<String>> GetVisibilityOptoins() {
    return visibilityOptions.map<DropdownMenuItem<String>>((String value) {
      // Map list items to DropdownMenuItem widgets
      return DropdownMenuItem<String>(value: value, child: Text(value));
    }).toList();
  }

  //UI elements value
  Color appbarColor = Colors.grey;
  Color backgroundColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    Size size = widget.sessioninfo.GetScreenSize(context);
    print(size);
    return Scaffold(
      appBar: AppBar(title: Text("Settings"), backgroundColor: appbarColor),
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Is Acount Hidden"),
                Checkbox(value: isHidden, onChanged: OnIsHiddenCheckBox),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Status Visibility"),
                DropdownButton(
                  value: statusVisibility,
                  items: GetVisibilityOptoins(),
                  onChanged: OnStatusVisibilityChange,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Post Visbiility"),
                DropdownButton(
                  value: postVisibility,
                  items: GetVisibilityOptoins(),
                  onChanged: OnPostVisibilityChange,
                ),
              ],
            ),
            Text("Save Changes"),
            FloatingActionButton(
              onPressed: UpdateSettings,
              tooltip: "Settings aren't saved unless you press this",
              child: Icon(Icons.save),
            ),
          ],
        ),
      ),
    );
  }
}
