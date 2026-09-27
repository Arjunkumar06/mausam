import '../../../shared/models/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> getCurrentUser();
  Future<UserProfile> signInWithGoogle({required String preferredRole});
  Future<void> signOut();
  Future<bool> isSessionValid();
}
