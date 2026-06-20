import 'dart:async';
import 'dart:math' as math;

import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LumiSplashScreen extends StatefulWidget {
  const LumiSplashScreen({super.key});

  @override
  State<LumiSplashScreen> createState() => _LumiSplashScreenState();
}

class _LumiSplashScreenState extends State<LumiSplashScreen>
    with SingleTickerProviderStateMixin {
  static const _messages = <String>[
    'Warming up your movie universe...',
    'Tuning into your vibe...',
    'Rolling out fresh picks...',
  ];

  late final AnimationController _controller;
  Timer? _messageTimer;
  Timer? _navigateTimer;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _messageTimer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
    });

    _navigateTimer = Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) {
        return;
      }
      context.go(AppRoute.explore.path);
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _navigateTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final wave = _controller.value;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0E1320),
                  Color.lerp(
                    const Color(0xFF131B2A),
                    const Color(0xFF1B2438),
                    wave,
                  )!,
                  const Color(0xFF0B111D),
                ],
              ),
            ),
            child: Stack(
              children: [
                _FloatingBlob(
                  alignment: const Alignment(-0.9, -0.8),
                  color: const Color(0xFF6EC6FF).withValues(alpha: 0.12),
                  scale: 1 + (wave * 0.22),
                  size: 220,
                ),
                _FloatingBlob(
                  alignment: Alignment(0.9, -0.45 + (wave * 0.08)),
                  color: const Color(0xFFA8E6CF).withValues(alpha: 0.14),
                  scale: 1 + ((1 - wave) * 0.18),
                  size: 180,
                ),
                _FloatingBlob(
                  alignment: Alignment(-0.35 + (wave * 0.25), 0.95),
                  color: const Color(0xFF6EC6FF).withValues(alpha: 0.1),
                  scale: 1 + (wave * 0.12),
                  size: 300,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: Offset(0, math.sin(wave * math.pi * 2) * 4),
                          child: SizedBox(
                            width: 210,
                            child: SvgPicture.asset(
                              'assets/logos/logo.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          context.l10n.movieDiscoveryMadePersonal,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 420),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.2),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _messages[_messageIndex],
                            key: ValueKey(_messageIndex),
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: SizedBox(
                            height: 5,
                            width: 180,
                            child: LinearProgressIndicator(
                              value: null,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.12,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.lerp(
                                  const Color(0xFFA8E6CF),
                                  const Color(0xFF6EC6FF),
                                  wave,
                                )!,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FloatingBlob extends StatelessWidget {
  const _FloatingBlob({
    required this.alignment,
    required this.color,
    required this.scale,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double scale;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color, blurRadius: 80, spreadRadius: 2),
            ],
          ),
        ),
      ),
    );
  }
}
