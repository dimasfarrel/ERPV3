import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController(text: 'FARREL');
  final _passwordCtrl = TextEditingController(text: '123');
  final _portCtrl = TextEditingController(text: '8084');
  final _ipCtrl = TextEditingController(text: '192.168.0.169');
  bool _obscurePassword = true;
  bool _showAdvancedSettings = false;

  // Design Tokens (Light Mode from MD)
  final Color _canvasColor = const Color(0xFFF6F8FA);
  final Color _baseColor = const Color(0xFFFFFFFF);
  final Color _textPrimary = const Color(0xFF18232D);
  final Color _textSecondary = const Color(0xFF53616D);
  final Color _borderColor = const Color(0xFFD9E1E6);
  final Color _primaryColor = const Color(0xFF1259A7);
  final Color _onPrimaryColor = const Color(0xFFFFFFFF);

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _portCtrl.dispose();
    _ipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: _canvasColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: BoxDecoration(
                color: _baseColor,
                borderRadius: BorderRadius.circular(8), // Enterprise radius
                border: Border.all(color: _borderColor, width: 1), // Thin border
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Text(
                      'Log In',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masuk ke sistem Enterprise ERP',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        color: _textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Username Field
                    _buildLabel('Username'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _usernameCtrl,
                      hint: 'Masukkan username',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    _buildLabel('Password'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordCtrl,
                      hint: 'Masukkan password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 12),

                    // Advanced Setup Toggle
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _showAdvancedSettings = !_showAdvancedSettings),
                        icon: Icon(
                          _showAdvancedSettings ? Icons.keyboard_arrow_up : Icons.settings_outlined,
                          size: 16,
                          color: _textSecondary,
                        ),
                        label: Text(
                          'Koneksi Database',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 13,
                            color: _textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),

                    // Advanced Settings Fields
                    if (_showAdvancedSettings) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('IP Address / Host'),
                                const SizedBox(height: 8),
                                _buildTextField(controller: _ipCtrl, hint: '192.168.1.1', icon: Icons.computer_outlined),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Port'),
                                const SizedBox(height: 8),
                                _buildTextField(controller: _portCtrl, hint: '8080'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Login Button
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: _onPrimaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6), // Consistent with enterprise look
                          ),
                        ),
                        child: provider.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _onPrimaryColor,
                                ),
                              )
                            : Text(
                                'Masuk ke Sistem',
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Demo Button
                    SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: provider.isLoading ? null : () => provider.loginAsDemo(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textPrimary,
                          side: BorderSide(color: _borderColor),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Mode Demo (Offline Mock)',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.ibmPlexSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      style: GoogleFonts.ibmPlexSans(
        fontSize: 14,
        color: _textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          color: _textSecondary.withOpacity(0.5),
        ),
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: _textSecondary)
            : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                  color: _textSecondary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                splashRadius: 20,
              )
            : null,
        filled: true,
        fillColor: _baseColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: _primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFB3363B)), // danger color from MD
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFB3363B), width: 1.5),
        ),
      ),
    );
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? true) {
      context.read<AppProvider>().login(
        username: _usernameCtrl.text,
        password: _passwordCtrl.text,
        ip: _ipCtrl.text,
        port: _portCtrl.text,
        context: context,
      );
    }
  }
}
