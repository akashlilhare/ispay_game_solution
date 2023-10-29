import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_user.dart';
import '../services/database_service.dart';
import '../services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

  late ChatUser user;
  bool isLoading = false;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();

    // _auth.signOut();
    _auth.authStateChanges().listen((_user) {
      if (_user != null) {
        isLoading = true;
        notifyListeners();
        _databaseService.updateUserLastSeenTime(_user.uid);
        _databaseService.getUser(_user.uid).then((_snapshot) {
          Map<String, dynamic> _userData =
              _snapshot.data()! as Map<String, dynamic>;

          user = ChatUser.fromJson({
            "uid": _user.uid,
            "name": _userData["name"],
            "email": _userData["email"],
            "last_active": _userData["last_active"],
            "image": _userData["image"]
          });

          log("navigate to home");
          _navigationService.removeAndNavigateToRoute("/home");

          isLoading = false;
          notifyListeners();
        });
      } else {
        _navigationService.removeAndNavigateToRoute("/login");
      }
    });
  }

  Future<void> loginWithEmail(String _email, String _password) async {
    try {
      isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      log(_auth.currentUser.toString());
    } on FirebaseAuthException {
      log("Error logging user into Firebase");
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> regiSterUserUsingEmai(
      String _name, String _password, String _email) async {
    isLoading = true;
    notifyListeners();
    try {
      UserCredential _credential = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      return _credential.user!.uid;
    } on FirebaseAuthException {
      log("Error registering user");
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log(e.toString());
    }
  }
}
