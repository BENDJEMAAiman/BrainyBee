





//auth
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app_project/auth/data/auth_repository.dart';
import 'package:mobile_app_project/auth/data/auth_web_service.dart';

final firebaseAuth = FirebaseAuth.instance;
final googleSignIn = GoogleSignIn.instance;

final authWebService = AuthWebService(firebaseAuth, googleSignIn);
final authRepository = AuthRepository(authWebService);