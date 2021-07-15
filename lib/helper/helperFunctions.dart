import 'package:shared_preferences/shared_preferences.dart';

//todo: is class k through hum user logged-in rakhen gy jb tk khod se logout nah kr dem
class HelperFunctions{

  static String sharedPrefrenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPrefrenceUserNameKey = "USERNAMEKEY";
  static String sharedPrefrenceUserEmailKey = "EMAILKEY";

  /// saving data to SharedPrefrence / ye data ko accept kren gy
  //todo: is static k through hum kahin se is function ko call kr sakte hen
  static Future<bool> saveUserLoggedInSharePrefrence (bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPrefrenceUserLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSharePrefrence (String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPrefrenceUserNameKey, userName);
  }

  static Future<bool> saveUserEmailSharePrefrence (String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPrefrenceUserEmailKey, userEmail);
  }

  /// get data from SharedPrefrence / ye data ko get kren gy
  static Future<bool> getUserLoggedInSharePrefrence () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getBool(sharedPrefrenceUserLoggedInKey);
  }

  static Future<String> getUserNameSharePrefrence () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getString(sharedPrefrenceUserNameKey);
  }

  static Future<String> getUserEmailSharePrefrence () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getString(sharedPrefrenceUserEmailKey);
  }

}