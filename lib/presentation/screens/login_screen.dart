// [Presentation Layer] — 로그인/회원가입 화면 렌더링 담당
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../application/view_models/auth_view_model.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUpMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthViewModel auth) async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSignUpMode) {
      await auth.signUp(_emailController.text, _passwordController.text);
    } else {
      await auth.signIn(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 헤더 영역
                  _buildHeader(),
                  const SizedBox(height: 40),

                  // 입력 폼
                  _buildForm(),
                  const SizedBox(height: 12),

                  // 에러 메시지
                  if (auth.errorMessage != null) _buildError(auth.errorMessage!),
                  const SizedBox(height: 20),

                  // 로그인 버튼
                  _buildSubmitButton(isLoading, auth),
                  const SizedBox(height: 16),

                  // 모드 전환
                  _buildToggle(auth),

                  const SizedBox(height: 20),
                  _buildDividerDeco(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // 일기장 아이콘 느낌
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.warmBorder),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: 36,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '장소 기억 아카이브',
          style: GoogleFonts.gaegu(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isSignUpMode ? '새로운 기억을 시작해볼까요 ✦' : '오늘도 기억을 남기러 왔군요 ✦',
          style: GoogleFonts.gaegu(
            fontSize: 15,
            color: AppTheme.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.notoSans(color: AppTheme.textDark),
          decoration: const InputDecoration(
            labelText: '이메일',
            prefixIcon: Icon(Icons.mail_outline_rounded, color: AppTheme.textLight, size: 20),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return '이메일을 입력해주세요';
            if (!v.contains('@')) return '올바른 이메일 형식이 아닙니다';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          style: GoogleFonts.notoSans(color: AppTheme.textDark),
          decoration: InputDecoration(
            labelText: '비밀번호',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textLight, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppTheme.textLight,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return '비밀번호를 입력해주세요';
            if (v.length < 6) return '비밀번호는 6자 이상이어야 합니다';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCDBD)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFB85C38)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.notoSans(
                  fontSize: 13, color: const Color(0xFFB85C38)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading, AuthViewModel auth) {
    return GestureDetector(
      onTap: isLoading ? null : () => _submit(auth),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isLoading ? AppTheme.warmBeige : AppTheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                _isSignUpMode ? '✦  회원가입' : '✦  로그인',
                style: GoogleFonts.gaegu(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildToggle(AuthViewModel auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUpMode ? '이미 계정이 있으신가요?' : '아직 계정이 없으신가요?',
          style: GoogleFonts.notoSans(color: AppTheme.textLight, fontSize: 13),
        ),
        TextButton(
          onPressed: () {
            auth.clearError();
            setState(() => _isSignUpMode = !_isSignUpMode);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            _isSignUpMode ? '로그인' : '회원가입',
            style: GoogleFonts.notoSans(
              color: AppTheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDividerDeco() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.warmBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '· · ·',
            style: TextStyle(color: AppTheme.textLight, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.warmBorder)),
      ],
    );
  }
}
