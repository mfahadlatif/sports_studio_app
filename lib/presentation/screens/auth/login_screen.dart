import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_studio/domain/providers/auth_provider.dart';
import 'package:sports_studio/presentation/screens/root_screen.dart';
import 'package:sports_studio/presentation/screens/auth/signup_screen.dart';
import 'package:sports_studio/presentation/screens/auth/forgot_password_screen.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/presentation/widgets/custom_text_field.dart';
import 'package:sports_studio/presentation/widgets/primary_button.dart';
import 'package:sports_studio/presentation/widgets/glass_container.dart';
import 'package:sports_studio/presentation/widgets/social_auth_button.dart';
import 'package:sports_studio/presentation/widgets/app_logo.dart';

import 'package:sports_studio/core/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RootScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(),
                const SizedBox(height: 32),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 32,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome Back',
                          style: AppTextStyles.heading1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your account',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email Address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return PrimaryButton(
                              text: 'Sign In',
                              onPressed: _handleLogin,
                              isLoading: auth.status == AuthStatus.loading,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SocialAuthButton(
                          text: 'Continue with Google',
                          icon: Icons.g_mobiledata,
                          backgroundColor: Colors.white,
                          textColor: Colors.black87,
                          onPressed: () async {
                            try {
                              // final GoogleSignIn googleSignIn = GoogleSignIn();
                              // final GoogleSignInAccount? account = await googleSignIn.signIn();
                              // if (account != null) {
                              //   final GoogleSignInAuthentication auth = await account.authentication;
                              //   if (auth.idToken != null) {
                              //      final success = await context.read<AuthProvider>().googleLogin(auth.idToken!);
                              //      if (success && mounted) {
                              //        Navigator.of(context).pushReplacement(
                              //          MaterialPageRoute(builder: (_) => const RootScreen()),
                              //        );
                              //      }
                              //   }
                              // }
                              // NOTE: GoogleSignIn requires platform configuration (GoogleService-Info.plist / google-services.json)
                              // which might not be set up in this environment yet.
                              // Implementing mock behavior for demonstration if dev mode, or real call if config exists.

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Google Sign-In: Requires GoogleService-Info.plist configuration.',
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Google Sign-In failed: $e'),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        SocialAuthButton(
                          text: 'Continue with Apple',
                          icon: Icons.apple,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          onPressed: () async {
                            try {
                              // final credential = await SignInWithApple.getAppleIDCredential(
                              //   scopes: [
                              //     AppleIDAuthorizationScopes.email,
                              //     AppleIDAuthorizationScopes.fullName,
                              //   ],
                              // );
                              // if (credential.identityToken != null) {
                              //    final success = await context.read<AuthProvider>().appleLogin(
                              //      credential.identityToken!,
                              //      name: '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim(),
                              //    );
                              //    if (success && mounted) {
                              //      Navigator.of(context).pushReplacement(
                              //        MaterialPageRoute(builder: (_) => const RootScreen()),
                              //      );
                              //    }
                              // }

                              // NOTE: Apple Sign-In requires Developer Account & Capabilities.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Apple Sign-In: Requires iOS Developer Capabilities.',
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Apple Sign-In failed: $e'),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
