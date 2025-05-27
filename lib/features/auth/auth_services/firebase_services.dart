import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  success,
  emailAlreadyInUse,
  invalidEmail,
  weakPassword,
  userNotFound,
  wrongPassword,
  unknownError,
}

class AuthResult {
  final AuthStatus status;
  final String message;
  final String? userId;

  AuthResult({required this.status, required this.message, this.userId});
}

Future<AuthResult> signUp(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AuthResult(
      status: AuthStatus.success,
      message: "User Signed up Successfully",
      userId: userCredential.user?.uid,
    );
  } catch (e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return AuthResult(
            status: AuthStatus.emailAlreadyInUse,
            message: "The email address is already in use.",
          );
        case 'invalid-email':
          return AuthResult(
            status: AuthStatus.invalidEmail,
            message: "The email address is invalid.",
          );
        case 'weak-password':
          return AuthResult(
            status: AuthStatus.weakPassword,
            message: "The password is too weak.",
          );
        default:
          return AuthResult(
            status: AuthStatus.unknownError,
            message: "An unknown error occurred: ${e.message}",
          );
      }
    }
    return AuthResult(
      status: AuthStatus.unknownError,
      message: "An error occurred: $e",
    );
  }
}

Future<AuthResult> signIn(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AuthResult(
      status: AuthStatus.success,
      message: "User Signed in Successfully",
      userId: userCredential.user?.uid,
    );
  } catch (e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return AuthResult(
            status: AuthStatus.userNotFound,
            message: "No user found for this email.",
          );
        case 'wrong-password':
          return AuthResult(
            status: AuthStatus.wrongPassword,
            message: "Incorrect password.",
          );
        case 'invalid-email':
          return AuthResult(
            status: AuthStatus.invalidEmail,
            message: "The email address is invalid.",
          );
        default:
          return AuthResult(
            status: AuthStatus.unknownError,
            message: "An unknown error occurred: ${e.message}",
          );
      }
    }
    return AuthResult(
      status: AuthStatus.unknownError,
      message: "An error occurred: $e",
    );
  }
}
