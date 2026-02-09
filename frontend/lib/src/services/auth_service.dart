import '../models/user.dart';
import '../state/session.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<void> login({required String username, required String password}) async {
    final data = await _api.post('/auth/login', {'username': username, 'password': password});
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    Session.setSession(token: token, user: user);
  }
}
