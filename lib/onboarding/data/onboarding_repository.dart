
import 'package:mobile_app_project/core/constants/app_assets.dart';
import 'package:mobile_app_project/onboarding/model/onboarding_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  static const _onboardingKey = 'has_seen_onboarding';

  final SharedPreferences sharedPreferences;

  OnboardingRepository(this.sharedPreferences);

  List<OnboardingModel> getPages() {
    return const [
      OnboardingModel(
        image: AppAssets.onboarding1,
        description:
            "Learn, play, grow with BrainyBee!",
      ),
      OnboardingModel(
        image: AppAssets.onboarding2,
        description:
            "Everyday is a little adventure",
      ),
      OnboardingModel(
        image: AppAssets.onboarding3,
        description:
            "Buzz into Learning!",
      ),
    ];
  }

  Future<void> completeOnboarding() async {
    await sharedPreferences.setBool(_onboardingKey, true);
  }
}
