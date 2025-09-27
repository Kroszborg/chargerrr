import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authController = Get.find<AuthController>();

      final success = await authController.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (success) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.successColor,
              size: 24,
            ),
            SizedBox(width: 8),
            Text('Email Sent'),
          ],
        ),
        content: Text(
          'Password reset instructions have been sent to ${_emailController.text.trim()}. Please check your email and follow the instructions.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text(
              'Back to Login',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
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
                const SizedBox(height: 40),

                // Header
                _buildHeader(),

                const SizedBox(height: 50),

                // Email Input
                _buildEmailForm(),

                const SizedBox(height: 30),

                // Reset Button
                _buildResetButton(),

                const SizedBox(height: 20),

                // Instructions
                _buildInstructions(),
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
            color: AppColors.accentColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 40,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your email address and we\'ll send you instructions to reset your password.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return CustomTextField(
      controller: _emailController,
      label: AppStrings.email,
      hintText: 'Enter your email address',
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
      prefixIcon: Icons.email_outlined,
    );
  }

  Widget _buildResetButton() {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return CustomButton(
          text: 'Send Reset Instructions',
          onPressed: _handleResetPassword,
          isLoading: controller.isLoading.value,
          backgroundColor: AppColors.accentColor,
        );
      },
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.infoColor.withOpacity(0.3),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.infoColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Instructions',
                style: TextStyle(
                  color: AppColors.infoColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Check your email inbox and spam folder\n'
            '• Click the reset link in the email\n'
            '• Create a new password\n'
            '• Sign in with your new password',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}