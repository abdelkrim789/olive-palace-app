import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.loading;
  String? _token;
  String? _userType;
  UserModel? _user;
  String? _error;

  AuthStatus get status    => _status;
  bool get isLoading       => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get token        => _token;
  String? get userType     => _userType;
  UserModel? get user      => _user;
  String? get error        => _error;
  bool get isSuperAdmin    => _userType == 'super_admin';
  bool get isAdmin         => _userType == 'admin' || _userType == 'super_admin';

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token    = prefs.getString('access_token');
    _userType = prefs.getString('user_type');

    if (_token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final endpoints = {
        'super_admin': '/api/super-admin/profile',
        'admin': '/api/admin/profile',
        'web': '/api/user/profile',
      };
      final endpoint = endpoints[_userType] ?? endpoints['web']!;
      final res = await ApiClient.instance.get(endpoint);
      final data = res.data;
      _user   = UserModel.fromJson(data['profile'] ?? data['user']?['profile'] ?? data);
      _status = AuthStatus.authenticated;
    } catch (_) {
      await _clearStorage();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    try {
      final res = await ApiClient.instance.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = res.data;
      _token    = data['access_token'];
      _userType = data['user_type'];
      await _saveStorage();
      await checkAuth();
      return true;
    } catch (e) {
      _error  = _parseError(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle(String token, String userType) async {
    _error = null;
    _token    = token;
    _userType = userType;
    await _saveStorage();
    await checkAuth();
    return _status == AuthStatus.authenticated;
  }

  Future<bool> register(Map<String, dynamic> form) async {
    _error = null;
    try {
      final res = await ApiClient.instance.post('/api/auth/register', data: form);
      final data = res.data['data'] ?? res.data;
      _token    = data['access_token'];
      _userType = data['user_type'];
      await _saveStorage();
      await checkAuth();
      return true;
    } catch (e) {
      _error  = _parseError(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/api/logout');
    } catch (_) {}
    await _clearStorage();
    ApiClient.reset();
    _token    = null;
    _userType = null;
    _user     = null;
    _status   = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final endpoints = {
        'super_admin': '/api/super-admin/profile',
        'admin': '/api/admin/profile',
        'web': '/api/user/profile',
      };
      await ApiClient.instance.put(endpoints[_userType] ?? '/api/user/profile', data: data);
      await checkAuth();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _saveStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null)    prefs.setString('access_token', _token!);
    if (_userType != null) prefs.setString('user_type', _userType!);
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
    prefs.remove('user_type');
  }

  String _parseError(dynamic e) {
    try {
      final data = (e as dynamic).response?.data;
      if (data is Map) {
        if (data['errors'] != null) {
          final errs = data['errors'] as Map;
          return errs.values.expand((v) => v is List ? v : [v]).join('\n');
        }
        return data['message'] ?? 'حدث خطأ ما';
      }
    } catch (_) {}
    return 'تعذر الاتصال بالخادم';
  }
}
