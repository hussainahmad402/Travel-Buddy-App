import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import 'package:travelbuddy/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/common_widgets.dart';
import '../home/home_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final bool isForgotPassword;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    this.isForgotPassword = false,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.back_circle.withOpacity(0.1),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          if (authController.isLoading) {
            return LoadingWidget(
              message: widget.isForgotPassword
                  ? 'Resetting your password...'
                  : 'Verifying OTP...',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    widget.isForgotPassword
                        ? 'Reset Password'
                        : 'Verify Your Email',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    widget.isForgotPassword
                        ? 'Enter the OTP sent to your email to reset password'
                        : 'Please enter the OTP code sent to ${widget.email}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // OTP Code Input (6 boxes)
                  Center(
                    child: Pinput(
                      length: 6,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      defaultPinTheme: defaultPinTheme,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the OTP code';
                        }
                        if (value.length != 6) {
                          return 'OTP must be 6 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // New Password (only for Forgot Password)
                  if (widget.isForgotPassword) ...[
                    CustomTextField(
                      label: 'New Password',
                      hint: 'Enter your new password',
                      controller: _newPasswordController,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Verify / Reset Button
                  CustomButton(
                    text: widget.isForgotPassword
                        ? 'Reset Password'
                        : 'Verify OTP',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        bool success;
                        if (widget.isForgotPassword) {
                          success = await authController.resetPassword(
                            email: widget.email,
                            otp: _otpController.text.trim(),
                            newPassword: _newPasswordController.text,
                          );
                        } else {
                          success = await authController.verifyOtp(
                            widget.email,
                            _otpController.text.trim(),
                          );
                        }

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.isForgotPassword
                                    ? 'Password reset successfully!'
                                    : 'Email verified successfully!',
                              ),
                            ),
                          );
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                authController.errorMessage ??
                                    'Verification failed. Please try again.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    backgroundColor: AppColors.primary,
                  ),
                  const SizedBox(height: 24),

                  // Resend OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Didn't receive code? "),
                      TextButton(
                        onPressed: () async {
                          final success = await authController.sendOtp(
                            widget.email,
                          );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'OTP has been resent to your email',
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
