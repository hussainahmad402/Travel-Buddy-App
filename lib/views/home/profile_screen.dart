import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/common_widgets.dart' as common;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final profileController = Provider.of<ProfileController>(context, listen: false);
    
    if (authController.token != null) {
      await profileController.loadUserProfile(authController.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditProfileDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _showLogoutDialog();
            },
          ),
        ],
      ),
      body: Consumer2<ProfileController, AuthController>(
        builder: (context, profileController, authController, child) {
          if (profileController.isLoading) {
            return const common.LoadingWidget(message: 'Loading profile...');
          }

          if (profileController.errorMessage != null) {
            return common.ErrorWidget(
              message: profileController.errorMessage!,
              onRetry: _loadProfile,
            );
          }

          final user = profileController.userProfile ?? authController.currentUser;

          if (user == null) {
            return const common.EmptyStateWidget(
              message: 'Unable to load profile information',
              icon: Icons.person_off,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                CustomCard(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Profile Details
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone
                      if (user.phone != null && user.phone!.isNotEmpty) ...[
                        _buildInfoRow(
                          context,
                          Icons.phone,
                          'Phone',
                          user.phone!,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Address
                      if (user.address != null && user.address!.isNotEmpty) ...[
                        _buildInfoRow(
                          context,
                          Icons.location_on,
                          'Address',
                          user.address!,
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Member Since
                      _buildInfoRow(
                        context,
                        Icons.calendar_today,
                        'Member Since',
                        user.createdAt != null 
                            ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                            : 'Unknown',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Actions
                CustomCard(
                  child: Column(
                    children: [
                      CustomButton(
                        text: 'Edit Profile',
                        icon: Icons.edit,
                        onPressed: () {
                          _showEditProfileDialog();
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Delete Account',
                        icon: Icons.delete_forever,
                        backgroundColor: Colors.red,
                        onPressed: () {
                          _showDeleteAccountDialog();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    final profileController = Provider.of<ProfileController>(context, listen: false);
    final user = profileController.userProfile;
    
    final nameController = TextEditingController(text: user?.name ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Name',
                controller: nameController,
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone',
                controller: phoneController,
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Address',
                controller: addressController,
                prefixIcon: const Icon(Icons.location_on),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final authController = Provider.of<AuthController>(context, listen: false);
              
              final success = await profileController.updateUserProfile(
                token: authController.token!,
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                address: addressController.text.trim(),
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(profileController.errorMessage ?? 'Failed to update profile')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authController = Provider.of<AuthController>(context, listen: false);
      await authController.logout();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final profileController = Provider.of<ProfileController>(context, listen: false);
      
      final success = await profileController.deleteUserProfile(authController.token!);
      
      if (success) {
        await authController.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/welcome');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(profileController.errorMessage ?? 'Failed to delete account')),
          );
        }
      }
    }
  }
}
