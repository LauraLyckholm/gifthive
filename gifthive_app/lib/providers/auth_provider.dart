import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_services.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  final ApiService _api = ApiService();

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  String get token => _user?.accessToken ?? '';

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final username = prefs.getString('username');
    final email = prefs.getString('email');
    final id = prefs.getString('userId');
    if (token != null && username != null && email != null && id != null) {
      _user = User(id: id, username: username, email: email, accessToken: token);
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    final user = await _api.login(username, password);
    _user = user;
    await _saveToPrefs(user);
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    final user = await _api.register(username, email, password);
    _user = user;
    await _saveToPrefs(user);
    notifyListeners();
  }

  Future<void> updateUsername(String newUsername) async {
    await _api.updateUser(token, _user!.id, {'username': newUsername});
    _user = User(id: _user!.id, username: newUsername, email: _user!.email, accessToken: _user!.accessToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    await _api.updateUser(token, _user!.id, {'password': newPassword});
  }

  Future<void> deleteAccount() async {
    await _api.deleteUser(token, _user!.id);
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _saveToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('userId', user.id);
  }
}
