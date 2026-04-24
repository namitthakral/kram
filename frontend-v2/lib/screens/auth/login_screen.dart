import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/auth_models.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../widgets/auth/primary_button.dart';
import '../../widgets/auth/sso_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _staySignedIn = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // Clear errors when user starts typing
    _emailController.addListener(() {
      if (_emailError != null) {
        setState(() => _emailError = null);
      }
    });
    
    _passwordController.addListener(() {
      if (_passwordError != null) {
        setState(() => _passwordError = null);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (_emailError == null && _passwordError == null) {
      setState(() => _isLoading = true);
      
      try {
        final authService = AuthService();
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        // Login with email and password
        final response = await authService.loginWithEmail(
          email: email,
          password: password,
        );

        setState(() => _isLoading = false);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${response.user.name.split(' ').first}!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to dashboard (router will redirect to correct home based on role)
          context.go('/dashboard');
        }
      } on AuthException catch (e) {
        setState(() => _isLoading = false);
        
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        
        // Show generic error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An unexpected error occurred. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your password';
    }
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleForgotPassword() {
    // Handle forgot password
    print('Forgot password tapped');
  }

  void _handleGoogleSSO() {
    // Handle Google SSO
    print('Google SSO tapped');
  }

  void _handleCreateAccount() {
    // Handle create account navigation
    print('Create account tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Hero Background Context with blur effects
            Positioned.fill(
              child: Stack(
                children: [
                  // Purple blur - top left
                  Positioned(
                    left: -128,
                    top: -102,
                    child: Container(
                      width: 512,
                      height: 410,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryPurple.withValues(alpha: 0.1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withValues(
                              alpha: 0.15,
                            ),
                            blurRadius: 120,
                            spreadRadius: 60,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Blue blur - bottom right
                  Positioned(
                    right: -128,
                    bottom: -102,
                    child: Container(
                      width: 640,
                      height: 512,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF005479).withValues(alpha: 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF005479,
                            ).withValues(alpha: 0.08),
                            blurRadius: 120,
                            spreadRadius: 60,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Branding Header
                        _buildBrandingHeader(),

                        const SizedBox(height: 32),

                        // Glass Login Card
                        _buildGlassLoginCard(),

                        const SizedBox(height: 24),

                        // Footer Link
                        _buildFooterLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingHeader() {
    return Column(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lavenderPlaceholder,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 24,
            color: AppColors.primaryPurple,
          ),
        ),

        const SizedBox(height: 24),

        // App Name
        Text(
          'Kram',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.8,
            color: AppColors.textDark,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Login to Intelligence Center',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.45,
            color: const Color(0xFF64748B),
            height: 1.56,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassLoginCard() {
    return Container(
      padding: const EdgeInsets.all(41),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.9),
        border: Border.all(
          color: const Color(0xFFCCC3D8).withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 10),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form Fields
          _buildFormFields(),

          const SizedBox(height: 32),

          // Divider
          _buildDivider(),

          const SizedBox(height: 32),

          // SSO Buttons
          _buildSSOButtons(),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Email Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'Email',
              hint: 'Email',
              controller: _emailController,
              prefixIcon: const Icon(
                Icons.email_outlined,
                size: 16,
                color: Color(0xFF7B7487),
              ),
            ),
            if (_emailError != null) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  _emailError!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 24),

        // Password Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'Password',
              hint: 'Password',
              controller: _passwordController,
              isPassword: true,
              forgotPasswordText: 'Forgot Password?',
              onForgotPassword: _handleForgotPassword,
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: Color(0xFF7B7487),
              ),
            ),
            if (_passwordError != null) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  _passwordError!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 24),

        // Stay Signed In Checkbox
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: Checkbox(
                  value: _staySignedIn,
                  onChanged: (value) =>
                      setState(() => _staySignedIn = value ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(color: Color(0xFFCCC3D8), width: 1),
                  activeColor: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Stay Signed In',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textMuted,
                  height: 1.43,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Login Button
        PrimaryButton(
          text: 'Access Workspace',
          isLoading: _isLoading,
          onPressed: _handleLogin,
          suffixIcon: const Icon(
            Icons.arrow_forward_rounded,
            size: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFCCC3D8).withValues(alpha: 0.3),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white,
          child: Text(
            'OR',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: const Color(0xFF7B7487),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFCCC3D8).withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSSOButtons() {
    return SsoButton(
      text: 'Continue with Google',
      icon: SvgPicture.asset(
        'assets/images/auth/ic_google.svg',
        width: 18,
        height: 18,
      ),
      onPressed: _handleGoogleSSO,
    );
  }

  Widget _buildFooterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: AppColors.textMuted,
            height: 1.43,
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _handleCreateAccount,
            child: Text(
              'Create an Account',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPurple,
                height: 1.43,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
