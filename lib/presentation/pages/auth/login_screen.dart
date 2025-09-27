import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authController = Get.find<AuthController>();

      final success = await authController.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        // Navigation handled by auth controller
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo and Title
                _buildHeader(),

                const SizedBox(height: 50),

                // Login Form
                _buildLoginForm(),

                const SizedBox(height: 30),

                // Login Button
                _buildLoginButton(),

                const SizedBox(height: 20),

                // Forgot Password
                _buildForgotPassword(),

                const SizedBox(height: 40),

                // Divider
                _buildDivider(),

                const SizedBox(height: 30),

                // Sign Up Link
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.electric_car,
            size: 40,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to your account',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          label: AppStrings.email,
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _passwordController,
          label: AppStrings.password,
          hintText: 'Enter your password',
          obscureText: _obscurePassword,
          validator: Validators.validatePassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: AppColors.primaryColor,
            ),
            const Text(
              AppStrings.rememberMe,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return CustomButton(
          text: AppStrings.login,
          onPressed: _handleLogin,
          isLoading: controller.isLoading.value,
        );
      },
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
      child: const Text(
        AppStrings.forgotPassword,
        style: TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          AppStrings.dontHaveAccount,
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.signup),
          child: const Text(
            AppStrings.signup,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}