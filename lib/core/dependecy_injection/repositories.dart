





//auth
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app_project/auth/data/auth_repository.dart';
import 'package:mobile_app_project/auth/data/auth_web_service.dart';
import 'package:mobile_app_project/onboarding/data/onboarding_repository.dart';


import 'package:mobile_app_project/splash/data/splash_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firebaseAuth = FirebaseAuth.instance;
final googleSignIn = GoogleSignIn.instance;

final authWebService = AuthWebService(firebaseAuth, googleSignIn);
final authRepository = AuthRepository(authWebService);



// Shared Preferences
late SharedPreferences sharedPreferences;

// Splash
late SplashRepository splashRepository;

//onboarding
late OnboardingRepository onboardingRepository;


Future<void> initializeDependencies() async {
  sharedPreferences = await SharedPreferences.getInstance();

  splashRepository = SplashRepository(sharedPreferences);
  onboardingRepository = OnboardingRepository(sharedPreferences);
}