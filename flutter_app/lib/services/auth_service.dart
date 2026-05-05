import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  FirebaseAuth get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      throw Exception('Firebase not initialized. Please run "flutterfire configure".');
    }
  }
  
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (e) {
      return const Stream.empty();
    }
  }

  // Get current user
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
      rethrow;
    }
  }

  // Apple Sign-In
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error during Apple Sign-In: $e');
      rethrow;
    }
  }

  // Email/Password Sign-In
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    // BYPASS for testing/demo
    if (email == 'demo@example.com' && password == 'demo123') {
      return null; // We'll handle this in AuthProvider to simulate success
    }

    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error during Email Sign-In: $e');
      rethrow;
    }
  }

  // Email/Password Sign-Up
  Future<UserCredential?> signUpWithEmail(String email, String password, {String? name}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (name != null && credential.user != null) {
        await credential.user!.updateDisplayName(name);
      }
      return credential;
    } catch (e) {
      print('Error during Email Sign-Up: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error during Sign Out: $e');
    }
  }
}
