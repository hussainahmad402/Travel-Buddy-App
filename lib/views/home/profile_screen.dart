import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travelbuddy/routes/app_routes.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final profileController = Provider.of<ProfileController>(
      context,
      listen: false,
    );

    if (authController.token != null) {
      await profileController.loadUserProfile(authController.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Provider.of<ProfileController>(context);
    final authController = Provider.of<AuthController>(context);
    final user = profileController.userProfile ?? authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Top Bar

            // const SizedBox(height: 20),

            // ✅ Profile Picture
            CircleAvatar(radius: 45, backgroundImage: user?.getProfileImage()),

            const SizedBox(height: 10),
            Text(
              user?.first_name ?? 'Imane fh',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'imanehfh29@gmail.com',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // ✅ Stats row (Reward, Trips, Bucket)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _ProfileStat(title: 'Reward Points', value: '50'),

                  _ProfileStat(title: 'Travel Trips', value: '40'),

                  _ProfileStat(title: 'Bucket List', value: '200'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Menu list
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    offset: const Offset(1, 1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.person_outline_outlined,
                    title: 'Profile',
                    ontap: _showEditProfileDialog,
                  ),
                  _ProfileMenuItem(
                    icon: Icons.bookmark_border,
                    title: 'Bookmarked',
                  ),
                  _ProfileMenuItem(
                    icon: Icons.favorite_outline,
                    title: 'Favorites',
                    ontap: () =>
                        Navigator.pushNamed(context, AppRoutes.favourites),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.flight_takeoff,
                    title: 'Previous Trips',
                  ),
                  _ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                  ),
                  _ProfileMenuItem(icon: Icons.info_outline, title: 'Version'),
                  _ProfileMenuItem(
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    ontap: _showLogoutDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // // ✅ Logout Button
            // ElevatedButton.icon(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.orange,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 30,
            //       vertical: 12,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //   ),
            //   icon: const Icon(Icons.logout),
            //   label: const Text('Logout'),
            //   onPressed: _showLogoutDialog,
            // ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper: Edit Profile Dialog

  void _showEditProfileDialog() {
    final profileController = Provider.of<ProfileController>(
      context,
      listen: false,
    );
    final user = profileController.userProfile;

    final nameController = TextEditingController(text: user?.first_name ?? '');
    final lastNameController = TextEditingController(
      text: user?.lastName ?? '',
    );
    final locationController = TextEditingController(text: user?.address ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Helper to pick image
          Future<void> pickImage() async {
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? pickedFile = await picker.pickImage(
                source: ImageSource.gallery,
              );

              if (pickedFile != null) {
                setState(() {
                  _selectedImage = File(pickedFile.path);
                });
              }
            } catch (e) {
              print("Error picking image: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to pick image: $e")),
              );
            }
          }

          Widget _buildTextField(
            TextEditingController controller,
            String label, {
            TextInputType keyboard = TextInputType.text,
          }) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                controller: controller,
                keyboardType: keyboard,
                decoration: InputDecoration(
                  labelText: label,
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  suffixIcon: controller.text.isNotEmpty
                      ? const Icon(Icons.check, color: Colors.orange)
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) {
                  setModalState(() {}); // Refresh icon
                },
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile picture
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: user?.getProfileImage(),
                  ),

                  TextButton(
                    onPressed: pickImage,
                    child: const Text(
                      'Change Profile Picture',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Text fields
                  _buildTextField(nameController, 'First Name'),
                  _buildTextField(lastNameController, 'Last Name'),
                  _buildTextField(locationController, 'Location'),
                  _buildTextField(
                    phoneController,
                    'Mobile Number',
                    keyboard: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final authController = Provider.of<AuthController>(
                        context,
                        listen: false,
                      );

                      final success = await profileController.updateUserProfile(
                        token: authController.token!,
                        firstName: nameController.text.trim(),
                        lastName: lastNameController.text.trim(),
                        address: locationController.text.trim(),
                        phone: phoneController.text.trim(),
                        profilePicture: _selectedImage, // send File here
                      );

                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                          ),
                        );
                        Navigator.pop(context);
                        setState(() {}); // Refresh main profile
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              profileController.errorMessage ??
                                  'Failed to update profile',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper to build input field with optional check icon
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8F8F8),
          suffixIcon: controller.text.isNotEmpty
              ? const Icon(Icons.check, color: Colors.orange)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (_) {
          // Refresh to show/hide check icon
          (controller as dynamic).notifyListeners?.call();
        },
      ),
    );
  }

  // ✅ Helper: Logout confirmation
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
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      await authController.logout();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }
}

// ✅ Reusable widgets for stats and menu items
class _ProfileStat extends StatelessWidget {
  final String title;
  final String value;

  const _ProfileStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? ontap;

  const _ProfileMenuItem({required this.icon, required this.title, this.ontap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 6),
        ListTile(
          leading: Icon(icon, color: Colors.black45),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: ontap,
        ),
        Divider(height: 0.5, color: Colors.grey[200]),
        //  SizedBox(height: 6),
      ],
    );
  }
}
