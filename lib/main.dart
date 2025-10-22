import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' show PointerDeviceKind;

import 'brand_palette.dart';
import 'navpage.dart';

void main() {
  runApp(
    DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()),
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = BrandPalette();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      scrollBehavior: const AppScrollBehavior(),
      title: 'Profile App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: brand.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brand.primary,
          brightness: Brightness.light,
        ),
        textTheme: Typography.blackCupertino.apply(
          bodyColor: brand.text,
          displayColor: brand.text,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: ProfilePage(brand: brand),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final BrandPalette brand;
  const ProfilePage({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'avatarHero',
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Transform.scale(
                    scale: 1.00,
                    child: Image.asset(
                      'assets/avatar.png',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.70),
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Lorem Ipsum",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              "QA / Mobile & Web",
              style: TextStyle(fontSize: 16, color: brand.subtext),
            ),
            const SizedBox(height: 30),
            PressableScale(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: brand.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () {
                  precacheImage(const AssetImage('assets/avatar.png'), context);
                  Navigator.of(context).push(_ExpandRoute(brand: brand));
                },
                icon: const Icon(Icons.explore),
                label: const Text("Explore"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandRoute extends PageRouteBuilder<void> {
  final BrandPalette brand;
  _ExpandRoute({required this.brand})
    : super(
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => ExpandedAvatarStage(brand: brand),
        transitionsBuilder: (_, animation, __, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final scale = Tween(begin: 0.985, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutQuad),
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
      );
}

class ExpandedAvatarStage extends StatefulWidget {
  final BrandPalette brand;
  const ExpandedAvatarStage({super.key, required this.brand});

  @override
  State<ExpandedAvatarStage> createState() => _ExpandedAvatarStageState();
}

class _ExpandedAvatarStageState extends State<ExpandedAvatarStage>
    with SingleTickerProviderStateMixin {
  late final ScrollController _sc = ScrollController();
  late final AnimationController _hint = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _sc.dispose();
    _hint.dispose();
    super.dispose();
  }

  double get _hintOpacity {
    if (!_sc.hasClients) return 1.0;
    final off = _sc.offset;
    if (off <= 0) return 1.0;
    if (off < 60) return 1.0 - (off / 60);
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final brand = widget.brand;

    return Scaffold(
      backgroundColor: brand.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [brand.bg, Colors.white],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) {
                setState(() {});
                final h = MediaQuery.sizeOf(context).height;
                if (_sc.hasClients && _sc.offset > h * 0.35) {
                  if (mounted) {
                    Future.microtask(() {
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => NavPage(brand: widget.brand),
                        ),
                      );
                    });
                  }
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: _sc,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height,
                  ),
                  child: Hero(
                    tag: 'avatarHero',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final w = c.maxWidth;
                          final bool isPhone = w < 600;
                          final bool isTablet = w >= 600 && w < 1024;

                          final Alignment align = isPhone
                              ? const Alignment(0, -0.22)
                              : (isTablet
                                    ? const Alignment(0, -0.12)
                                    : const Alignment(0, -0.06));

                          final double padBottom = isPhone
                              ? 120.0
                              : (isTablet ? 220.0 : 320.0);

                          return Padding(
                            padding: EdgeInsets.fromLTRB(12, 12, 12, padBottom),
                            child: FittedBox(
                              fit: BoxFit.cover,
                              alignment: align,
                              child: Image.asset(
                                'assets/avatar.png',
                                errorBuilder:
                                    (
                                      BuildContext context,
                                      Object error,
                                      StackTrace? stackTrace,
                                    ) {
                                      return const SizedBox(
                                        width: 300,
                                        height: 400,
                                        child: Center(
                                          child: Text(
                                            'assets/avatar.png not found',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      );
                                    },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _hintOpacity,
                duration: const Duration(milliseconds: 180),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Scroll to continue",
                      style: TextStyle(color: brand.subtext, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0),
                            end: const Offset(0, 0.12),
                          ).animate(
                            CurvedAnimation(
                              parent: _hint,
                              curve: Curves.easeInOut,
                            ),
                          ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: brand.subtext,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PressableScale extends StatefulWidget {
  final Widget child;
  const PressableScale({required this.child, super.key});
  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    lowerBound: 0.0,
    upperBound: 1.0,
  )..value = 1.0;

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _ac.animateTo(0.97, curve: Curves.easeOut),
      onPointerUp: (_) => _ac.animateTo(1.0, curve: Curves.easeOut),
      child: AnimatedScale(
        scale: _ac.value,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}
