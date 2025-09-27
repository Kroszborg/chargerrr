import 'package:get/get.dart';
import '../../core/constants/app_strings.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/authenticate_user.dart';

class AuthController extends GetxController {
  final AuthenticateUser authenticateUser;

  AuthController({required this.authenticateUser});

  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSignedIn = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthState();
    _checkCurrentUser();
  }

  void _listenToAuthState() {
    authenticateUser.authStateChanges.listen((result) {
      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          currentUser.value = null;
          isSignedIn.value = false;
        },
        (user) {
          currentUser.value = user;
          isSignedIn.value = user != null;
          if (user != null) {
            errorMessage.value = '';
          }
        },
      );
    });
  }

  Future<void> _checkCurrentUser() async {
    isLoading.value = true;
    final result = await authenticateUser.getCurrentUser();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        currentUser.value = null;
        isSignedIn.value = false;
      },
      (user) {
        currentUser.value = user;
        isSignedIn.value = user != null;
      },
    );
    isLoading.value = false;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await authenticateUser.signIn(
      AuthenticateUserParams(email: email, password: password),
    );

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        _showError(failure.message);
        return false;
      },
      (user) {
        currentUser.value = user;
        isSignedIn.value = true;
        isLoading.value = false;
        _showSuccess(AppStrings.loginSuccess);
        Get.offAllNamed('/home');
        return true;
      },
    );
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await authenticateUser.signUp(
      SignUpUserParams(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      ),
    );

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        _showError(failure.message);
        return false;
      },
      (user) {
        currentUser.value = user;
        isSignedIn.value = true;
        isLoading.value = false;
        _showSuccess(AppStrings.signupSuccess);
        Get.offAllNamed('/home');
        return true;
      },
    );
  }

  Future<void> signOut() async {
    isLoading.value = true;

    final result = await authenticateUser.signOut();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        _showError(failure.message);
      },
      (_) {
        currentUser.value = null;
        isSignedIn.value = false;
        _showSuccess(AppStrings.logoutSuccess);
        Get.offAllNamed('/login');
      },
    );

    isLoading.value = false;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await authenticateUser.sendPasswordResetEmail(email);

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        _showError(failure.message);
        return false;
      },
      (_) {
        isLoading.value = false;
        _showSuccess(AppStrings.resetPasswordSuccess);
        return true;
      },
    );
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await authenticateUser.updateUserProfile(
      UpdateUserProfileParams(
        fullName: fullName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      ),
    );

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        _showError(failure.message);
        return false;
      },
      (user) {
        currentUser.value = user;
        isLoading.value = false;
        _showSuccess('Profile updated successfully');
        return true;
      },
    );
  }

  Future<void> deleteAccount() async {
    isLoading.value = true;

    final result = await authenticateUser.deleteAccount();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        _showError(failure.message);
      },
      (_) {
        currentUser.value = null;
        isSignedIn.value = false;
        _showSuccess('Account deleted successfully');
        Get.offAllNamed('/login');
      },
    );

    isLoading.value = false;
  }

  Future<void> sendEmailVerification() async {
    isLoading.value = true;

    final result = await authenticateUser.sendEmailVerification();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        _showError(failure.message);
      },
      (_) {
        _showSuccess('Verification email sent');
      },
    );

    isLoading.value = false;
  }

  Future<void> reloadUser() async {
    final result = await authenticateUser.reloadUser();
    result.fold(
      (failure) => _showError(failure.message),
      (_) => _checkCurrentUser(),
    );
  }

  void clearError() {
    errorMessage.value = '';
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  bool get hasError => errorMessage.value.isNotEmpty;
  bool get isAuthenticated => isSignedIn.value && currentUser.value != null;
  String get userName => currentUser.value?.fullName ?? '';
  String get userEmail => currentUser.value?.email ?? '';
}