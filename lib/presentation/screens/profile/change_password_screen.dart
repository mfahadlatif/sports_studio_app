import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_studio/domain/providers/auth_provider.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/presentation/widgets/custom_text_field.dart';
import 'package:sports_studio/presentation/widgets/primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }

      final success = await context.read<AuthProvider>().changePassword(
        currentPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change password. check your old password'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _oldPasswordController,
                labelText: 'Current Password',
                hintText: 'Enter old password',
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Enter current password' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newPasswordController,
                labelText: 'New Password',
                hintText: 'Enter new password',
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'Minimum 6 characters' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm New Password',
                hintText: 'Re-enter new password',
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Confirm password' : null,
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, provider, _) {
                  return PrimaryButton(
                    text: 'Update Password',
                    onPressed: _changePassword,
                    isLoading: provider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
