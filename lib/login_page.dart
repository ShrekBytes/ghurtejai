import 'package:flutter/material.dart';
import 'gj_colors.dart';
import 'signup_page.dart';
import 'profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _submitted = false;

  // ── Validation ────────────────────────────────────────────
  String? get _emailError {
    if (!_submitted) return null;
    final v = _emailCtrl.text.trim();
    if (v.isEmpty) return 'Email or username is required';

    final isEmail = v.contains('@');
    if (isEmail) {
      final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w]{2,}$');
      if (!emailRegex.hasMatch(v)) return 'Enter a valid email address';
    } else {
      if (v.length < 3) return 'Username must be at least 3 characters';
      if (v.contains(' ')) return 'Username cannot contain spaces';
    }
    return null;
  }

  String? get _passwordError {
    if (!_submitted) return null;
    if (_passwordCtrl.text.isEmpty) return 'Password is required';
    if (_passwordCtrl.text.length < 8) return 'Must be at least 8 characters';
    return null;
  }

  bool get _isValid => _emailError == null && _passwordError == null;

  void _onSubmit() {
    setState(() => _submitted = true);
    if (_isValid) {
      // Remove all previous routes (covers both direct login AND
      // the Create Account → Login → Profile flow)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GJ.blue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ──
              const GJHeader(),

              // ── Hero Card ──
              Container(
                margin: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                height: 210,
                decoration: BoxDecoration(
                  color: GJ.pink,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GJ.dark, width: 3),
                  boxShadow: const [
                    BoxShadow(offset: Offset(5, 5), color: GJ.dark),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: const CustomPaint(painter: DotPatternPainter()),
                      ),
                    ),
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: CustomPaint(painter: MountainPainter()),
                      ),
                    ),
                    const Positioned(
                      left: 22,
                      top: 26,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome\nBack! ✈️',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: GJ.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Your next adventure\nawaits you',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: GJ.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 18,
                      top: 16,
                      child: Transform.rotate(
                        angle: -0.5,
                        child: const Text('🛫', style: TextStyle(fontSize: 48)),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Transform.rotate(
                        angle: 0.25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: GJ.yellow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: GJ.dark, width: 2),
                          ),
                          child: const Text(
                            'EXPLORE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Courier',
                              color: GJ.dark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form Card ──
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
                            color: GJ.pink,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: GJ.dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Email
                    GJTextField(
                      controller: _emailCtrl,
                      label: 'Email / Username',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.text,
                      focusColor: GJ.pink,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 14),

                    // Password
                    GJTextField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                      focusColor: GJ.pink,
                      errorText: _passwordError,
                    ),
                    const SizedBox(height: 10),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Forgot password? ↗',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: GJ.pink,
                            decoration: TextDecoration.underline,
                            decorationColor: GJ.pink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Let's Go
                    GJButton(
                      label: "Let's Go! →",
                      color: GJ.yellow,
                      onTap: _onSubmit,
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color: GJ.dark.withOpacity(0.12),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'or',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: GJ.dark.withOpacity(0.12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Create Account
                    GJButton(
                      label: 'Create an Account ↗',
                      color: GJ.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      ),
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
