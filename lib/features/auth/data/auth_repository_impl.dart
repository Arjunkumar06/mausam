import '../../../core/storage/storage_service.dart';
import '../../../shared/models/user_profile.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final StorageService _storageService;

  AuthRepositoryImpl(this._storageService);

  @override
  Future<UserProfile?> getCurrentUser() async {
    return await _storageService.getUserProfile();
  }

  @override
  Future<UserProfile> signInWithGoogle({required String preferredRole}) async {
    // Generate persona based on preferredRole or user preference
    final profile = UserProfile.defaultProfile(preferredRole);
    await _storageService.saveUserProfile(profile);
    await _storageService.saveSessionToken('auth_token_${profile.id}_${DateTime.now().millisecondsSinceEpoch}');
    return profile;
  }

  @override
  Future<void> signOut() async {
    await _storageService.clearSession();
  }

  @override
  Future<bool> isSessionValid() async {
    final token = await _storageService.getSessionToken();
    return token != null && token.isNotEmpty;
  }
}
