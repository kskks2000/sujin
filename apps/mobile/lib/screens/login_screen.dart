import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms_mobile/core/formatters/tms_labels.dart';
import 'package:tms_mobile/core/network/tms_api_client.dart';
import 'package:tms_mobile/core/theme/app_theme.dart';
import 'package:tms_mobile/models/session.dart';
import 'package:tms_mobile/widgets/tms_ui.dart';

String _resolveDefaultBaseUrl() {
  if (kIsWeb) {
    final current = Uri.base;
    final host = current.host;
    final isRemoteHost = host.isNotEmpty && host != 'localhost' && host != '127.0.0.1';
    if (isRemoteHost) {
      return '${current.origin}/api/v1';
    }
  }
  return 'http://localhost:8000/api/v1';
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.client, required this.onLogin});

  final TmsApiClient client;
  final ValueChanged<Session> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController(text: _resolveDefaultBaseUrl());
  final _loginIdController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _usesLockedRemoteApi {
    if (!kIsWeb) {
      return false;
    }

    final host = Uri.base.host;
    return host.isNotEmpty && host != 'localhost' && host != '127.0.0.1';
  }

  String get _effectiveBaseUrl {
    if (_usesLockedRemoteApi) {
      return _resolveDefaultBaseUrl();
    }
    return _baseUrlController.text.trim();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final session = await widget.client.login(
        baseUrl: _effectiveBaseUrl,
        loginId: _loginIdController.text.trim(),
        password: _passwordController.text,
      );
      widget.onLogin(session);
    } catch (error) {
      setState(() {
        _errorMessage = localizeErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 960;

    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: PageReveal(
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _StoryPanel(baseUrl: _effectiveBaseUrl),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              flex: 5,
                              child: _LoginPanel(
                                formKey: _formKey,
                                baseUrlController: _baseUrlController,
                                baseUrlLocked: _usesLockedRemoteApi,
                                loginIdController: _loginIdController,
                                passwordController: _passwordController,
                                isSubmitting: _isSubmitting,
                                errorMessage: _errorMessage,
                                onSubmit: _submit,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _StoryPanel(baseUrl: _effectiveBaseUrl),
                            const SizedBox(height: 18),
                            _LoginPanel(
                              formKey: _formKey,
                              baseUrlController: _baseUrlController,
                              baseUrlLocked: _usesLockedRemoteApi,
                              loginIdController: _loginIdController,
                              passwordController: _passwordController,
                              isSubmitting: _isSubmitting,
                              errorMessage: _errorMessage,
                              onSubmit: _submit,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel({required this.baseUrl});

  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(28),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2E8F88),
          Color(0xFF69CABB),
          Color(0xFFA1F0DE),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: TmsBrandPlate(
              width: MediaQuery.sizeOf(context).width >= 960 ? 350 : 300,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.midnight.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '프리미엄 운영 경험',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '배차, 오더, 차량 흐름을\n한 화면에서 관리합니다.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.midnight,
              fontSize: 38,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '모바일에서도 관제 흐름이 자연스럽게 이어지도록, 공개 접속 주소와 운영 API를 같은 기준으로 맞춰두었습니다.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.midnight.withValues(alpha: 0.76),
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _SignalTile(
                label: '오더 흐름',
                value: '실시간',
                icon: Icons.inventory_2_rounded,
              ),
              _SignalTile(
                label: '차량 관제',
                value: '모바일',
                icon: Icons.route_rounded,
              ),
              _SignalTile(
                label: '브랜드 경험',
                value: '일관성',
                icon: Icons.query_stats_rounded,
              ),
            ],
          ),
          const SizedBox(height: 26),
          Divider(color: AppColors.midnight.withValues(alpha: 0.18)),
          const SizedBox(height: 18),
          Text(
            '현재 연결된 API',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.midnight.withValues(alpha: 0.64),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            baseUrl,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.midnight,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.formKey,
    required this.baseUrlController,
    required this.baseUrlLocked,
    required this.loginIdController,
    required this.passwordController,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController baseUrlController;
  final bool baseUrlLocked;
  final TextEditingController loginIdController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final String? errorMessage;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                DetailChip(
                  label: '브랜드 적용',
                  icon: Icons.layers_rounded,
                ),
                DetailChip(
                  label: '웹 관제',
                  icon: Icons.language_rounded,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const TmsLogo(size: 56),
            const SizedBox(height: 16),
            Text('운영 포털', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              '시드된 운영 계정으로 SJ 관제 환경에 접속하세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: baseUrlController,
              readOnly: baseUrlLocked,
              decoration: InputDecoration(
                labelText: 'API 기본 URL',
                prefixIcon: const Icon(Icons.link_rounded),
                helperText: baseUrlLocked
                    ? '현재 접속 주소에 맞게 자동으로 고정됩니다.'
                    : '로컬 개발 시 직접 수정할 수 있습니다.',
              ),
              validator: (value) => value == null || value.isEmpty ? '필수 입력 항목입니다.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: loginIdController,
              decoration: const InputDecoration(
                labelText: '로그인 ID',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              validator: (value) => value == null || value.isEmpty ? '필수 입력 항목입니다.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                prefixIcon: Icon(Icons.lock_rounded),
              ),
              validator: (value) => value == null || value.isEmpty ? '필수 입력 항목입니다.' : null,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.clay.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.clay,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                icon: Icon(
                  isSubmitting ? Icons.sync_rounded : Icons.arrow_forward_rounded,
                ),
                label: Text(
                  isSubmitting ? '접속 중입니다...' : '대시보드 입장',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(height: 14),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.midnight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.midnight.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}
