import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'shared/models/user_profile.dart';
import 'features/home/presentation/landing_page.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/home/presentation/personalized_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MausamApp()));
}

enum AppScreenState { landing, onboarding, home }

class MausamApp extends StatefulWidget {
  const MausamApp({super.key});

  @override
  State<MausamApp> createState() => _MausamAppState();
}

class _MausamAppState extends State<MausamApp> {
  final StorageService _storageService = StorageService();
  AppScreenState _screenState = AppScreenState.landing;
  AppScreenState _previousScreenState = AppScreenState.landing;
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSavedSession();
  }

  Future<void> _checkSavedSession() async {
    final profile = await _storageService.getUserProfile();
    setState(() {
      if (profile != null && profile.isAuthenticated) {
        _userProfile = profile;
        _screenState = AppScreenState.home;
      } else {
        _screenState = AppScreenState.landing;
      }
      _isLoading = false;
    });
  }

  void _onStartPersona(UserProfile profile) async {
    await _storageService.saveUserProfile(profile);
    await _storageService.saveSessionToken('demo_token_${profile.id}');
    setState(() {
      _userProfile = profile;
      _screenState = AppScreenState.home;
    });
  }

  void _onCompleteOnboarding(UserProfile profile) async {
    await _storageService.saveUserProfile(profile);
    await _storageService.saveSessionToken('user_token_${profile.id}');
    setState(() {
      _userProfile = profile;
      _screenState = AppScreenState.home;
    });
  }

  void _onSignOut() async {
    await _storageService.clearSession();
    setState(() {
      _userProfile = null;
      _screenState = AppScreenState.landing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mausam - Personalized Weather Portal',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_screenState) {
      case AppScreenState.landing:
        return LandingPage(
          onStartPersona: _onStartPersona,
          onStartCustomOnboarding: () {
            setState(() {
              _previousScreenState = AppScreenState.landing;
              _screenState = AppScreenState.onboarding;
            });
          },
        );
      case AppScreenState.onboarding:
        return OnboardingScreen(
          onOnboardingComplete: _onCompleteOnboarding,
          onCancelOnboarding: () {
            setState(() {
              _screenState = _previousScreenState;
            });
          },
        );
      case AppScreenState.home:
        return PersonalizedHomeScreen(
          initialProfile: _userProfile ?? UserProfile.defaultProfile('general'),
          onOpenOnboarding: () {
            setState(() {
              _previousScreenState = AppScreenState.home;
              _screenState = AppScreenState.onboarding;
            });
          },
          onSignOut: _onSignOut,
        );
    }
  }
}
