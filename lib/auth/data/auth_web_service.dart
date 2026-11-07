import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthWebService {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  AuthWebService(this.firebaseAuth, this.googleSignIn);

  Future<void>? _googleSignInInitialization;

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??= googleSignIn.initialize();
  }

  //sign up
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  //sign in
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  //send verification email
  Future<void> sendEmailVerif() async {
    try {
      await firebaseAuth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    try {
      await firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();

      await _ensureGoogleSignInInitialized();

      await googleSignIn.signOut();
    } on FirebaseAuthException {
      rethrow;
    } on GoogleSignInException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    try {
      // 1. Authenticate with Google
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // 2. Retrieve authentication information
      final googleAuth = googleUser.authentication;

      // 3. Get the ID token
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Google ID token is missing.');
      }

      // 4. Create Firebase credential
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      // 5. Authenticate with Firebase
      return await firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await firebaseAuth.currentUser?.updateDisplayName(name);
      await firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    try {
      await firebaseAuth.currentUser?.updatePhotoURL(photoUrl);

      await firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> deletePhotoUrl() async {
    try {
      await firebaseAuth.currentUser?.updatePhotoURL(null);
      await firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
