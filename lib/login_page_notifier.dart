import 'package:flutter/material.dart';

class LoginPageNotifier extends ChangeNotifier {
  static final LoginPageNotifier instance = LoginPageNotifier._internal();

  factory LoginPageNotifier() => instance;

  LoginPageNotifier._internal();

  String _username = "";

  String get username => _username;

  void loggedIn(String username) {
    _username = username.toLowerCase().replaceAll(' ', '');
    print("User logged in: $_username");
    notifyListeners();
  }
}
