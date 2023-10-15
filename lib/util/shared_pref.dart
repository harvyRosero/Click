import 'package:shared_preferences/shared_preferences.dart';

class Preferences {


  Future<void> savePreferenceLogin(gmail, name, urlPhoto, userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('gmail', gmail);
    prefs.setString('name', name);
    prefs.setString('photo', urlPhoto);
    prefs.setString('userId', userId);
  }

  Future<bool> checkIfDataExists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool flag = prefs.containsKey("gmail");
    return flag;
  }

  Future<String?> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString("name");
    return name;
  }

  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString("gmail");
    return name;
  }

  Future<String?> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    return userId;
  }

  Future<String?> getPhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? photo = prefs.getString("photo");
    return photo;
  }

  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

}

