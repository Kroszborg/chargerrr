import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryColor),
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            const SizedBox(height: 30),

            // Profile Stats
            _buildProfileStats(),

            const SizedBox(height: 30),

            // Menu Items
            _buildMenuItems(),

            const SizedBox(height: 30),

            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GetBuilder<AuthController>(
      builder: (controller) {
        final user = controller.currentUser.value;

        return Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  backgroundImage: user?.profileImageUrl != null
                      ? NetworkImage(user!.profileImageUrl!)
                      : null,
                  child: user?.profileImageUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primaryColor,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // User Name
            Text(
              user?.fullName ?? 'User Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            // User Email
            Text(
              user?.email ?? 'user@example.com',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 8),

            // Verification Status
            if (user?.isEmailVerified == false)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.warningColor.withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  'Email not verified',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warningColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.ev_station,
            label: 'Sessions',
            value: '24',
            color: AppColors.primaryColor,
          ),
          _buildStatItem(
            icon: Icons.favorite,
            label: 'Favorites',
            value: '8',
            color: AppColors.errorColor,
          ),
          _buildStatItem(
            icon: Icons.eco,
            label: 'CO₂ Saved',
            value: '142kg',
            color: AppColors.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.history,
          title: 'Charging History',
          subtitle: 'View your past charging sessions',
          onTap: () {
            // TODO: Navigate to history
          },
        ),
        _buildMenuItem(
          icon: Icons.favorite,
          title: 'Favorite Stations',
          subtitle: 'Manage your favorite charging stations',
          onTap: () {
            // TODO: Navigate to favorites
          },
        ),
        _buildMenuItem(
          icon: Icons.payment,
          title: 'Payment Methods',
          subtitle: 'Manage cards and billing',
          onTap: () {
            // TODO: Navigate to payment
          },
        ),
        _buildMenuItem(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Customize your notifications',
          onTap: () {
            // TODO: Navigate to notifications
          },
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App preferences and privacy',
          onTap: () {
            // TODO: Navigate to settings
          },
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help or contact support',
          onTap: () {
            // TODO: Navigate to help
          },
        ),
        _buildMenuItem(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and legal information',
          onTap: () {
            // TODO: Navigate to about
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textLight,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return CustomButton(
          text: AppStrings.logout,
          onPressed: () => _showLogoutDialog(),
          isLoading: controller.isLoading.value,
          backgroundColor: AppColors.errorColor,
          icon: const Icon(Icons.logout, size: 20),
        );
      },
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              final authController = Get.find<AuthController>();
              authController.signOut();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}