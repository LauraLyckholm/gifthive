import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hive.dart';
import '../models/gift.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://gifthivebackend.onrender.com';

  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Auth': token,
      };

  // ---------- AUTH ----------

  Future<User> register(String username, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/user-routes/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(body['response'] ?? 'Registration failed');
    }
    return User.fromJson(body['response']);
  }

  Future<User> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/user-routes/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(body['response'] ?? 'Login failed');
    }
    return User.fromJson(body['response']);
  }

  // ---------- HIVES ----------

  Future<List<Hive>> getHives(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/gift-routes/hives'),
      headers: {'Auth': token},
    );
    if (res.statusCode != 200) throw Exception('Failed to load hives');
    final List data = jsonDecode(res.body);
    return data.map((h) => Hive.fromJson(h)).toList();
  }

  Future<Hive> createHive(String token, String name) async {
    final res = await http.post(
      Uri.parse('$baseUrl/gift-routes/hives'),
      headers: _authHeaders(token),
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to create hive');
    }
    // createNewController returns {hive, gift} or just the hive object
    final data = jsonDecode(res.body);
    return Hive.fromJson(data is Map && data.containsKey('hive') ? data['hive'] : data);
  }

  Future<Hive> updateHive(String token, String hiveId, String name) async {
    final res = await http.put(
      Uri.parse('$baseUrl/gift-routes/hives/$hiveId'),
      headers: _authHeaders(token),
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode != 200) throw Exception('Failed to update hive');
    return Hive.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteHive(String token, String hiveId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/gift-routes/hives/$hiveId'),
      headers: {'Auth': token},
    );
    if (res.statusCode != 200) throw Exception('Failed to delete hive');
  }

  Future<void> deleteUser(String token, String userId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/user-routes/users/$userId'),
      headers: {'Auth': token},
    );
    if (res.statusCode != 200) throw Exception('Failed to delete account');
  }

  Future<void> updateUser(String token, String userId, Map<String, dynamic> fields) async {
    final res = await http.put(
      Uri.parse('$baseUrl/user-routes/users/$userId'),
      headers: _authHeaders(token),
      body: jsonEncode(fields),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['error'] ?? 'Failed to update account');
    }
  }

  Future<List<Hive>> getSharedHives(String token, String userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/gift-routes/hives/shared-with/$userId'),
      headers: {'Auth': token},
    );
    if (res.statusCode != 200) throw Exception('Failed to load shared hives');
    final body = jsonDecode(res.body);
    final List data = body['hives'] ?? [];
    return data.map((h) => Hive.fromJson(h)).toList();
  }

  // ---------- GIFTS ----------

  Future<Gift> addGift(String token, String hiveId, String giftName, List<String> tags, {DateTime? dueDate}) async {
    final body = <String, dynamic>{'gift': giftName, 'tags': tags, 'hiveId': hiveId};
    if (dueDate != null) body['dueDate'] = dueDate.toIso8601String();
    final res = await http.post(
      Uri.parse('$baseUrl/gift-routes/gifts'),
      headers: _authHeaders(token),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to add gift');
    }
    return Gift.fromJson(jsonDecode(res.body));
  }

  Future<Gift> updateGift(String token, String giftId, Map<String, dynamic> fields) async {
    final res = await http.put(
      Uri.parse('$baseUrl/gift-routes/gifts/$giftId'),
      headers: _authHeaders(token),
      body: jsonEncode(fields),
    );
    if (res.statusCode != 200) throw Exception('Failed to update gift');
    return Gift.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteGift(String token, String giftId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/gift-routes/gifts/$giftId'),
      headers: {'Auth': token},
    );
    if (res.statusCode != 200) throw Exception('Failed to delete gift');
  }
}
