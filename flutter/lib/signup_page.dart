import 'package:flutter/material.dart';
import 'gj_colors.dart';
import 'profile_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _submitted = false;

  // ── Validation ────────────────────────────────────────────
  String? get _nameError {
    if (!_submitted) return null;
    if (_nameCtrl.text.trim().isEmpty) return 'Full name is required';
    return null;
  }

  String? get _usernameError {
    if (!_submitted) return null;
    final v = _userCtrl.text.trim();
    if (v.isEmpty) return 'Username is required';
    if (v.length < 3) return 'At least 3 characters';
    return null;
  }

  String? get _emailError {
    if (!_submitted) return null;
    final v = _emailCtrl.text.trim();
    if (v.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w]{2,}$').hasMatch(v);
    if (!ok) return 'Enter a valid email address';
    return null;
  }

  String? get _passwordError {
    if (!_submitted) return null;
    if (_passCtrl.text.isEmpty) return 'Password is required';
    if (_passCtrl.text.length < 8) return 'Must be at least 8 characters';
    return null;
  }

  String? get _confirmError {
    if (!_submitted) return null;
    if (_confirmCtrl.text.isEmpty) return 'Please confirm your password';
    if (_confirmCtrl.text != _passCtrl.text) return 'Passwords do not match';
    return null;
  }

  bool get _isValid =>
      _nameError == null &&
      _usernameError == null &&
      _emailError == null &&
      _passwordError == null &&
      _confirmError == null;

  void _onCreate() {
    setState(() => _submitted = true);
    if (_isValid) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
        (_) => false,
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GJ.green,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── HEADER ────────────────────────────────────
              const GJHeader(showBack: true),

              // ── HERO CARD ─────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                height: 190,
                decoration: BoxDecoration(
                  color: GJ.yellow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GJ.dark, width: 3),
                  boxShadow: const [
                    BoxShadow(offset: Offset(5, 5), color: GJ.dark),
                  ],
                ),
                child: Stack(
                  children: [
                    // Dot pattern
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: CustomPaint(
                          painter: DotPatternPainter(
                            color: GJ.dark.withValues(alpha: 0.07),
                          ),
                        ),
                      ),
                    ),
                    // Map illustration
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: CustomPaint(painter: MapPainter()),
                      ),
                    ),
                    // Text
                    const Positioned(
                      left: 22,
                      top: 26,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Your\nJourney! 🗺️',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: GJ.dark,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Join thousands of\ntravellers on GhurteJai',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: GJ.dark,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Compass
                    const Positioned(
                      right: 16,
                      bottom: 8,
                      child: Text('🧭', style: TextStyle(fontSize: 68)),
                    ),
                    // Badge
                    Positioned(
                      top: 14,
                      right: 100,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: GJ.pink,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: GJ.dark, width: 2),
                          ),
                          child: const Text(
                            'FREE!',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Courier',
                              color: GJ.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── FORM CARD ─────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: GJ.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GJ.dark, width: 3),
                  boxShadow: const [
                    BoxShadow(offset: Offset(5, 5), color: GJ.dark),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 34,
                          decoration: BoxDecoration(
                            color: GJ.green,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: GJ.dark, width: 1.5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: GJ.dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Full Name
                    GJTextField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      focusColor: GJ.green,
                      errorText: _nameError,
                    ),
                    const SizedBox(height: 12),

                    // Username
                    GJTextField(
                      controller: _userCtrl,
                      label: 'Username',
                      icon: Icons.tag_rounded,
                      focusColor: GJ.green,
                      errorText: _usernameError,
                    ),
                    const SizedBox(height: 12),

                    // Email
                    GJTextField(
                      controller: _emailCtrl,
                      label: 'Email Address',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      focusColor: GJ.green,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 12),

                    // Password
                    GJTextField(
                      controller: _passCtrl,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePass,
                      onToggleObscure: () =>
                          setState(() => _obscurePass = !_obscurePass),
                      focusColor: GJ.green,
                      errorText: _passwordError,
                    ),
                    const SizedBox(height: 12),

                    // Confirm Password
                    GJTextField(
                      controller: _confirmCtrl,
                      label: 'Confirm Password',
                      icon: Icons.lock_rounded,
                      obscure: _obscureConfirm,
                      onToggleObscure: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      focusColor: GJ.green,
                      errorText: _confirmError,
                    ),
                    const SizedBox(height: 24),

                    // Create Account button
                    GJButton(
                      label: 'Create Account 🚀',
                      color: GJ.green,
                      onTap: _onCreate,
                    ),
                    const SizedBox(height: 16),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: GJ.dark,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Login ↗',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: GJ.pink,
                              decoration: TextDecoration.underline,
                              decorationColor: GJ.pink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
