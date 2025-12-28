import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  static const _keyToken = 'token';
  static const _keyUserID = 'userID';
  static const _keyRole = 'role';
  static const _keyUserName = 'userName';

  // Simpan Token
  static Future<void> setToken(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(_keyToken, value);
  }

  // Ambil Token
  static Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(_keyToken);
  }

  // Simpan UserID
  static Future<void> setUserID(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(_keyUserID, value);
  }

  // Ambil UserID
  static Future<String?> getUserID() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(_keyUserID);
  }

  // Simpan Role (Admin/Petugas/Dokter/Pasien)
  static Future<void> setRole(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(_keyRole, value);
  }

  // Ambil Role
  static Future<String?> getRole() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(_keyRole);
  }

  // Simpan UserName
  static Future<void> setUserName(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(_keyUserName, value);
  }

  // Ambil UserName
  static Future<String?> getUserName() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(_keyUserName);
  }

  // Alias for getUserName (for consistency)
  static Future<String?> getUsername() async {
    return getUserName();
  }

  // Logout (Hapus Semua Data Sesi)
  static Future<void> logout() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}
