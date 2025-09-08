import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isForgotPassword ? 'Reset Password' : 'Verify Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          if (authController.isLoading) {
            return LoadingWidget(
              message: 'Verifying OTP...',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        widget.isForgotPassword ? Icons.lock_reset : Icons.verified_user,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    widget.isForgotPassword ? 'Reset Password' : 'Verify Your Email',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isForgotPassword
                        ? 'Enter OTP to reset your password'
                        : 'Enter the verification code sent to ${widget.email}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // OTP Field
                  CustomTextField(
                    label: 'OTP Code',
                    hint: 'Enter the 6-digit code',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.security),
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
                  const SizedBox(height: 16),

                  // New Password Field (only for forgot password)
                  if (widget.isForgotPassword) ...[
                    CustomTextField(
                      label: 'New Password',
                      hint: 'Enter your new password',
                      controller: _newPasswordController,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
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

                  // Verify/Reset Button
                  CustomButton(
                    text: widget.isForgotPassword ? 'Reset Password' : 'Verify OTP',
                    icon: widget.isForgotPassword ? Icons.lock_reset : Icons.verified_user,
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
                            SnackBar(content: Text(widget.isForgotPassword 
                                ? 'Password reset successfully!' 
                                : 'Email verified successfully!')),
                          );
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(authController.errorMessage ?? 'Verification failed')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Resend OTP
                  TextButton(
                    onPressed: () async {
                      final success = await authController.sendOtp(widget.email);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OTP resent to your email')),
                        );
                      }
                    },
                    child: const Text('Resend OTP'),
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