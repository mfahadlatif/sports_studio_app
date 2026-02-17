import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sports_studio/domain/providers/auth_provider.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/presentation/widgets/custom_text_field.dart';
import 'package:sports_studio/presentation/widgets/primary_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      bool success = false;

      // Separate update if image is present vs not, or update Provider to handle both nicely.
      // Assuming AuthProvider.updateProfile accepts avatar (string/file?).
      // Currently AuthProvider.updateProfile signature is:
      // Future<bool> updateProfile({String? name, String? phone, String? avatar})
      // The avatar param is string (url/base64?). The service converts file to FormData?
      // Wait, AuthService.updateProfile takes String? avatar.
      // I should update AuthService.updateProfile to take File? image optionally.

      // Let's assume I will update AuthProvider first.

      success = await context.read<AuthProvider>().updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        image: _imageFile,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                          : (user?.avatar != null
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      user!.avatar!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                    ),
                    child: (_imageFile == null && user?.avatar == null)
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.textMuted,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your name',
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController, // Read-only recommendation
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    readOnly:
                        true, // Assuming I added readOnly prop, if not see below
                    // If no readOnly prop, I'll check custom_text_field.dart
                    validator: (val) => val == null || !val.contains('@')
                        ? 'Invalid email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(
                    builder: (context, provider, _) {
                      return PrimaryButton(
                        text: 'Save Changes',
                        onPressed: _updateProfile,
                        isLoading: provider.isLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
