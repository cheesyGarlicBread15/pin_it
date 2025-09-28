import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:house_pin/widgets/auth_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  void _signIn() {
    // TODO: auth
    context.go('/home');
  }

  // responsive breakpoints
  bool _isMobileView(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  bool _isTabletView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  bool _isDesktopView(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  // get dimensions
  double _getImageHeight(BuildContext context) {
    if (_isMobileView(context)) return 200;
    if (_isTabletView(context)) return 280;
    return 400;
  }

  double _getTitleFontSize(BuildContext context) {
    if (_isMobileView(context)) return 24;
    if (_isTabletView(context)) return 28;
    return 32;
  }

  double _getVerticalSpacing(BuildContext context, {bool large = false}) {
    final base = large ? 24 : 16;
    if (_isMobileView(context)) return base * 1.0;
    if (_isTabletView(context)) return base * 1.2;
    return base * 1.5;
  }

  double _getHorizontalPadding(BuildContext context) {
    if (_isMobileView(context)) return 32;
    if (_isTabletView(context)) return 48;
    return 64;
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = _isMobileView(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pin It',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _getTitleFontSize(context),
              color: Colors.black,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pin your house and stay safe!',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _getVerticalSpacing(context, large: true) * 1.5),

          // email field
          _buildModernTextField(
            controller: _emailController,
            labelText: 'Your email address',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: _getVerticalSpacing(context)),

          // password field
          _buildModernTextField(
            controller: _passwordController,
            labelText: 'Choose a password',
            hintText: 'Enter your password',
            obscureText: !_isPasswordVisible,
            validator: (v) =>
                v == null || v.isEmpty ? 'Password is required' : null,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade400,
                size: 20,
              ),
              onPressed: () => setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              }),
            ),
          ),

          //error
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: _getVerticalSpacing(context),
              ),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          SizedBox(height: _getVerticalSpacing(context, large: true)),

          // sign in button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4BDF7F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Continue'),
            ),
          ),

          SizedBox(height: _getVerticalSpacing(context, large: true)),

          Row(
            children: [
              Expanded(
                child: Container(height: 1, color: Colors.grey.shade300),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: Colors.grey.shade300),
              ),
            ],
          ),

          SizedBox(height: _getVerticalSpacing(context, large: true)),

          // sign up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey.shade600,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/signup'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4BDF7F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // mobile
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // header
        RoundedHeaderWidget(
          height: _getImageHeight(context),
          backgroundColor: const Color(0xFF101B30),
          borderRadius: 80,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4BDF7F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'House Pin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // forms
        Expanded(
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: _getHorizontalPadding(context),
                vertical: 32,
              ),
              child: _buildForm(context),
            ),
          ),
        ),
      ],
    );
  }

  // desktop
  Widget _buildDesktopLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(context),
            vertical: 48,
          ),
          child: Row(
            children: [
              // left side
              Expanded(
                flex: _isDesktopView(context) ? 5 : 4,
                child: Container(
                  height: 600,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF101B30),
                              const Color(0xFF101B30).withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      // Content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4BDF7F),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'House Pin',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 36,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: _isDesktopView(context) ? 64 : 48),

              // right side (form)
              Expanded(
                flex: _isDesktopView(context) ? 4 : 5,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(
                        _isDesktopView(context) ? 48 : 40,
                      ),
                      child: _buildForm(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(context),
            vertical: 32,
          ),
          child: Column(
            children: [
              //header
              RoundedHeaderWidget(
                height: _getImageHeight(context),
                backgroundColor: const Color(0xFF101B30),
                borderRadius: 35,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4BDF7F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'House Pin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: _getVerticalSpacing(context, large: true)),

              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(40),
                child: _buildForm(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_isMobileView(context)) {
            return _buildMobileLayout(context);
          } else if (_isTabletView(context)) {
            return _buildTabletLayout(context);
          } else {
            return _buildDesktopLayout(context);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// cutomization
class RoundedBottomClipper extends CustomClipper<Path> {
  final double borderRadius;

  RoundedBottomClipper({this.borderRadius = 30});

  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - borderRadius);
    path.arcToPoint(
      Offset(size.width - borderRadius, size.height),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );

    path.lineTo(borderRadius, size.height);

    path.arcToPoint(
      Offset(0, size.height - borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );

    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// header rounded (custominzation)
class RoundedHeaderWidget extends StatelessWidget {
  final double height;
  final Widget? child;
  final Color? backgroundColor;
  final double borderRadius;

  const RoundedHeaderWidget({
    super.key,
    this.height = 300,
    this.child,
    this.backgroundColor,
    this.borderRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: RoundedBottomClipper(borderRadius: borderRadius),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor ?? const Color(0xFF101B30),
              backgroundColor?.withOpacity(0.9) ??
                  const Color(0xFF101B30).withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
