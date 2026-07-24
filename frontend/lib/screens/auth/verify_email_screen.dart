import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/core/widgets/app_button.dart';
import 'package:buildacad/services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _ctrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  int _countdown = 60;
  Timer? _timer;
  bool _verifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length < 6) return;
    setState(() { _verifying = true; _error = null; });
    try {
      final service = AuthService();
      final result = await service.verifyEmail(widget.email, _code);
      if (result.success && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      } else {
        setState(() => _error = 'Invalid verification code');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    try {
      final service = AuthService();
      await service.sendVerificationCode(widget.email);
      _startCountdown();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mail_outline, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 24),
              Text('Verify your email', style: AppTypography.headlineMd.copyWith(
                color: AppColors.textOnSurface(brightness),
              )),
              const SizedBox(height: 8),
              Text('We sent a 6-digit code to', style: AppTypography.bodyMd.copyWith(
                color: AppColors.textOnSurfaceVariant(brightness),
              )),
              Text(widget.email, style: AppTypography.bodyMd.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 32),
              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) => Container(
                  width: 44, height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextField(
                    controller: _ctrls[i],
                    focusNode: _nodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.textOnSurface(brightness),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest(brightness),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.smAll,
                        borderSide: BorderSide(color: AppColors.border(brightness)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.smAll,
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.smAll,
                        borderSide: BorderSide(color: AppColors.border(brightness)),
                      ),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
                      if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
                      if (_code.length == 6) _verify();
                    },
                  ),
                )),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: AppTypography.bodySm.copyWith(color: AppColors.error)),
              ],
              const SizedBox(height: 24),
              AppButton(label: 'Verify', loading: _verifying, onPressed: _verify),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _countdown > 0 ? null : _resend,
                child: Text(
                  _countdown > 0 ? 'Resend code in ${_countdown}s' : 'Resend Code',
                  style: AppTypography.bodySm.copyWith(
                    color: _countdown > 0 ? AppColors.outline(brightness) : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
