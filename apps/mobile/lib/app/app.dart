import 'package:flutter/material.dart';
import 'package:tms_mobile/core/formatters/tms_labels.dart';
import 'package:tms_mobile/core/network/tms_api_client.dart';
import 'package:tms_mobile/core/theme/app_theme.dart';
import 'package:tms_mobile/models/session.dart';
import 'package:tms_mobile/screens/dashboard_screen.dart';
import 'package:tms_mobile/screens/dispatch_board_screen.dart';
import 'package:tms_mobile/screens/login_screen.dart';
import 'package:tms_mobile/screens/orders_screen.dart';
import 'package:tms_mobile/widgets/tms_ui.dart';

class TmsApp extends StatelessWidget {
  const TmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '수진 TMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final TmsApiClient _client = TmsApiClient();
  Session? _session;

  void _handleLogin(Session session) {
    setState(() {
      _session = session;
    });
  }

  void _logout() {
    setState(() {
      _session = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return LoginScreen(client: _client, onLogin: _handleLogin);
    }

    return HomeShell(
      session: _session!,
      client: _client,
      onLogout: _logout,
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.session,
    required this.client,
    required this.onLogout,
  });

  final Session session;
  final TmsApiClient client;
  final VoidCallback onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final tabs = const [
      _ShellTab(
        title: '관제 타워',
        subtitle: '실시간 오더, 배차, 가동 현황을 한눈에 확인합니다.',
        icon: Icons.space_dashboard_rounded,
      ),
      _ShellTab(
        title: '오더 데스크',
        subtitle: '접수, 경로, 청구 주체를 함께 관리합니다.',
        icon: Icons.receipt_long_rounded,
      ),
      _ShellTab(
        title: '배차 보드',
        subtitle: '운송사 실행, 자산, 마진 흐름을 추적합니다.',
        icon: Icons.local_shipping_rounded,
      ),
    ];

    final pages = [
      DashboardScreen(client: widget.client, session: widget.session),
      OrdersScreen(client: widget.client),
      DispatchBoardScreen(client: widget.client),
    ];
    final isWide = screenSize.width >= 980;
    final isCompact = !isWide && (screenSize.height < 860 || screenSize.width < 460);
    final bodyPadding = isWide
        ? const EdgeInsets.all(24)
        : EdgeInsets.fromLTRB(10, isCompact ? 8 : 12, 10, isCompact ? 8 : 12);

    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: bodyPadding,
            child: Column(
              children: [
                _ShellHeader(
                  title: tabs[_currentIndex].title,
                  subtitle: tabs[_currentIndex].subtitle,
                  session: widget.session,
                  onLogout: widget.onLogout,
                  compact: isCompact,
                ),
                SizedBox(height: isCompact ? 10 : 16),
                Expanded(
                  child: isWide
                      ? Row(
                          children: [
                            _RailPanel(
                              currentIndex: _currentIndex,
                              tabs: tabs,
                              onSelected: (index) => setState(() => _currentIndex = index),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ScreenFrame(
                                child: pages[_currentIndex],
                              ),
                            ),
                          ],
                        )
                      : _ScreenFrame(
                          child: pages[_currentIndex],
                        ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: isWide
            ? null
            : Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, isCompact ? 8 : 12),
                child: AppSurface(
                  padding: EdgeInsets.zero,
                  radius: 26,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.midnight.withValues(alpha: 0.16),
                      AppColors.teal.withValues(alpha: 0.18),
                      Colors.white.withValues(alpha: 0.18),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      navigationBarTheme: NavigationBarThemeData(
                        backgroundColor: Colors.transparent,
                        indicatorColor: AppColors.gold.withValues(alpha: 0.24),
                        elevation: 0,
                        labelTextStyle: WidgetStateProperty.resolveWith(
                          (states) => Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: states.contains(WidgetState.selected)
                                ? AppColors.ink
                                : AppColors.ink.withValues(alpha: 0.68),
                          ),
                        ),
                      ),
                    ),
                    child: NavigationBar(
                      height: isCompact ? 64 : 72,
                      selectedIndex: _currentIndex,
                      onDestinationSelected: (index) => setState(() => _currentIndex = index),
                      destinations: tabs
                          .map(
                            (tab) => NavigationDestination(
                              icon: Icon(tab.icon),
                              label: tab.title,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ScreenFrame extends StatelessWidget {
  const _ScreenFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: EdgeInsets.zero,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.72),
          AppColors.shell.withValues(alpha: 0.9),
          AppColors.mintWash.withValues(alpha: 0.8),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: child,
      ),
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({
    required this.title,
    required this.subtitle,
    required this.session,
    required this.onLogout,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final Session session;
  final VoidCallback onLogout;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    return AppSurface(
      padding: EdgeInsets.all(isWide ? 22 : (compact ? 12 : 18)),
      radius: compact ? 28 : 32,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.74),
          AppColors.skyWash.withValues(alpha: 0.8),
          AppColors.mintWash.withValues(alpha: 0.82),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(
                  child: _HeaderCopy(
                    title: title,
                    subtitle: subtitle,
                    compact: compact,
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DetailChip(
                      label: localizeUserRole(session.userRole),
                      icon: Icons.badge_rounded,
                      dense: compact,
                    ),
                    DetailChip(
                      label: session.loginId,
                      icon: Icons.person_rounded,
                      dense: compact,
                    ),
                    DetailChip(
                      label: session.baseUrl.replaceFirst('http://', ''),
                      icon: Icons.link_rounded,
                      dense: compact,
                    ),
                    OutlinedButton.icon(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout_rounded),
                      style: compact
                          ? OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            )
                          : null,
                      label: const Text('로그아웃'),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderCopy(
                  title: title,
                  subtitle: subtitle,
                  compact: compact,
                ),
                SizedBox(height: compact ? 10 : 14),
                Wrap(
                  spacing: compact ? 8 : 10,
                  runSpacing: compact ? 8 : 10,
                  children: [
                    DetailChip(
                      label: localizeUserRole(session.userRole),
                      icon: Icons.badge_rounded,
                      dense: compact,
                    ),
                    DetailChip(
                      label: session.loginId,
                      icon: Icons.person_rounded,
                      dense: compact,
                    ),
                    OutlinedButton.icon(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout_rounded),
                      style: compact
                          ? OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            )
                          : null,
                      label: const Text('로그아웃'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _HeaderCopy extends StatelessWidget {
  const _HeaderCopy({
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TmsLogo(size: compact ? 34 : 44),
        SizedBox(height: compact ? 8 : 12),
        Text(
          title,
          style: compact
              ? Theme.of(context).textTheme.headlineSmall
              : Theme.of(context).textTheme.displaySmall,
        ),
        SizedBox(height: compact ? 4 : 8),
        Text(
          subtitle,
          maxLines: compact ? 1 : 3,
          overflow: TextOverflow.ellipsis,
          style: (compact
                  ? Theme.of(context).textTheme.bodyMedium
                  : Theme.of(context).textTheme.bodyLarge)
              ?.copyWith(color: AppColors.ink.withValues(alpha: 0.82)),
        ),
      ],
    );
  }
}

class _RailPanel extends StatelessWidget {
  const _RailPanel({
    required this.currentIndex,
    required this.tabs,
    required this.onSelected,
  });

  final int currentIndex;
  final List<_ShellTab> tabs;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: AppSurface(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.72),
            AppColors.shell.withValues(alpha: 0.88),
            AppColors.skyWash.withValues(alpha: 0.82),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text('워크스페이스'),
            ),
            Expanded(
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                selectedIndex: currentIndex,
                onDestinationSelected: onSelected,
                labelType: NavigationRailLabelType.all,
                leading: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.midnight,
                        AppColors.teal,
                        Color(0xFF8ADFD0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TmsLogo(
                        size: 40,
                        light: true,
                        showCaption: false,
                      ),
                      SizedBox(height: 12),
                      Text(
                        '운영 레인',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '실시간 관제',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                destinations: tabs
                    .map(
                      (tab) => NavigationRailDestination(
                        icon: Icon(tab.icon),
                        label: Text(tab.title),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
