import 'package:get/get.dart';
import '../presentation/pages/splash/splash_screen.dart';
import '../presentation/pages/auth/login_screen.dart';
import '../presentation/pages/auth/signup_screen.dart';
import '../presentation/pages/auth/forgot_password_screen.dart';
import '../presentation/pages/home/home_screen.dart';
import '../presentation/pages/station_details/station_details_screen.dart';
import '../presentation/pages/profile/profile_screen.dart';
import '../presentation/bindings/initial_binding.dart';
import '../presentation/bindings/auth_binding.dart';
import '../presentation/bindings/home_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.stationDetails,
      page: () => const StationDetailsScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}