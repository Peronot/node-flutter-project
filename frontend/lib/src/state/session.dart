import '../models/user.dart';

class Session {
  static String? _token;
  static UserModel? _user;

  static String? get token => _token;
  static UserModel? get user => _user;

  static void setSession({required String token, required UserModel user}) {
    _token = token;
    _user = user;
  }

  static void clear() {
    _token = null;
    _user = null;
  }
}
