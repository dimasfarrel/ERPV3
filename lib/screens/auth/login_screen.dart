import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController(text: 'admin_malang');
  final _passwordCtrl = TextEditingController(text: '••••••••••••');
  final _portCtrl = TextEditingController(text: '8080');
  final _ipCtrl = TextEditingController(text: '192.168.1.100');
  bool _obscurePassword = true;
  bool _showAdvancedSettings = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
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
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            // Background blobs
            Positioned(top: -100, right: -80, child: _blob(400, AppColors.primary.withOpacity(0.08))),
            Positioned(bottom: -120, left: -100, child: _blob(350, AppColors.primary.withOpacity(0.05))),
            // Content
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        _buildLoginCard(provider),
                        const SizedBox(height: 40),
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

  Widget _blob(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }



  Widget _buildLoginCard(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Masuk ke Sistem', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            const SizedBox(height: 4),
            Text('Masukkan kredensial dan konfigurasi database Anda', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 28),
            _buildField(controller: _usernameCtrl, label: 'Username', icon: Icons.person_outline_rounded, hint: 'Enter your username'),
            const SizedBox(height: 16),
            _buildField(
              controller: _passwordCtrl, label: 'Password',
              icon: Icons.lock_outline_rounded, hint: 'Enter your password',
              isPassword: true,
              obscure: _obscurePassword,
              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _showAdvancedSettings = !_showAdvancedSettings),
                icon: Icon(_showAdvancedSettings ? Icons.keyboard_arrow_up_rounded : Icons.settings_outlined, size: 16, color: AppColors.textMuted),
                label: Text('Advanced Setup', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              ),
            ),
            if (_showAdvancedSettings) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildField(controller: _ipCtrl, label: 'IP Address / Host', icon: Icons.wifi, hint: '192.168.1.1')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(controller: _portCtrl, label: 'Port', icon: Icons.dns_outlined, hint: '8080')),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : _onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: provider.isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Login', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword && obscure,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
            suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: AppColors.textMuted),
                  onPressed: onToggle,
                )
              : null,
          ),
        ),
      ],
    );
  }



  void _onLogin() {
    if (_formKey.currentState?.validate() ?? true) {
      context.read<AppProvider>().login(_usernameCtrl.text);
    }
  }
}
