// import 'package:shared_preferences/shared_preferences.dart';
//
// enum PrefKeys { loggedIn, token, email, isAdmin }
//
// class SharedPrefController {
//   late final SharedPreferences _sharedPreferences;
//
//   static final SharedPrefController _instance = SharedPrefController._();
//
//   factory SharedPrefController() => _instance;
//
//   SharedPrefController._();
//
//   Future<void> initPreferences() async {
//     _sharedPreferences = await SharedPreferences.getInstance();
//   }
//
//   // Save user token and login state
//   Future<void> save({required String token}) async {
//     await _sharedPreferences.setBool(PrefKeys.loggedIn.name, true);
//     await _sharedPreferences.setString(PrefKeys.token.name, token);
//   }
//
//   // Save admin flag
//   Future<void> saveBool({required bool admin}) async {
//     await _sharedPreferences.setBool(PrefKeys.isAdmin.name, admin);
//   }
//
//   // Read login state
//   bool get loggedIn =>
//       _sharedPreferences.getBool(PrefKeys.loggedIn.name) ?? false;
//
//   // Read token
//   String get token => _sharedPreferences.getString(PrefKeys.token.name) ?? '';
//
//   // Read admin flag
//   bool get isAdmin =>
//       _sharedPreferences.getBool(PrefKeys.isAdmin.name) ?? false;
//
//   // Clear all stored preferences
//   Future<bool> clear() async => await _sharedPreferences.clear();
// }
