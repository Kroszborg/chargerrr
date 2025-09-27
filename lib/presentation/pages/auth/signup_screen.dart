import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        Get.snackbar(
          'Terms Required',
          'Please accept the terms and conditions to continue',
          backgroundColor: AppColors.errorColor,
          colorText: AppColors.textWhite,
        );
        return;
      }

      final authController = Get.find<AuthController>();

      final success = await authController.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),

                const SizedBox(height: 40),

                // Sign Up Form
                _buildSignUpForm(),

                const SizedBox(height: 20),

                // Terms and Conditions
                _buildTermsCheckbox(),

                const SizedBox(height: 30),

                // Sign Up Button
                _buildSignUpButton(),

                const SizedBox(height: 30),

                // Sign In Link
                _buildSignInLink(),
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
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.person_add,
            size: 40,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Join us and start your EV charging journey',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _nameController,
          label: AppStrings.fullName,
          hintText: 'Enter your full name',
          validator: Validators.validateName,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
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
          controller: _phoneController,
          label: AppStrings.phoneNumber,
          hintText: 'Enter your phone number (optional)',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              return Validators.validatePhoneNumber(value);
            }
            return null;
          },
          prefixIcon: Icons.phone_outlined,
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
        const SizedBox(height: 20),
        CustomTextField(
          controller: _confirmPasswordController,
          label: AppStrings.confirmPassword,
          hintText: 'Confirm your password',
          obscureText: _obscureConfirmPassword,
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _passwordController.text,
          ),
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: AppColors.primaryColor,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: const Text(
              'I agree to the Terms of Service and Privacy Policy',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return CustomButton(
          text: AppStrings.createAccount,
          onPressed: _handleSignUp,
          isLoading: controller.isLoading.value,
          backgroundColor: AppColors.secondaryColor,
        );
      },
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          AppStrings.alreadyHaveAccount,
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            AppStrings.login,
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