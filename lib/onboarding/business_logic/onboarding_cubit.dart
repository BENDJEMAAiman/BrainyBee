import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_project/onboarding/business_logic/onboarding_state.dart';
import 'package:mobile_app_project/onboarding/data/onboarding_repository.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRepository onboardingRepository;

  OnboardingCubit(this.onboardingRepository)
      : super(const OnboardingInitial());

  Future<void> finishOnboarding() async {
    try {
      await onboardingRepository.completeOnboarding();

      emit(const OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}