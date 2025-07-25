import 'package:flutter/material.dart';
import 'package:iwaymaps/AiimsJammu/Screens/SplashScreen.dart';
import 'package:upgrader/upgrader.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import '../../MainScreen.dart';

class CoolUpgradeAlert extends StatefulWidget {
  final Widget child;
  final bool mandatory;
  final String? customTitle;
  final String? customMessage;
  final Color primaryColor;
  final Color secondaryColor;

  const CoolUpgradeAlert({
    Key? key,
    required this.child,
    this.mandatory = false,
    this.customTitle,
    this.customMessage,
    this.primaryColor = const Color(0xFF6366F1), // Indigo
    this.secondaryColor = const Color(0xFF8B5CF6), // Purple
  }) : super(key: key);

  @override
  State<CoolUpgradeAlert> createState() => _CoolUpgradeAlertState();
}

class _CoolUpgradeAlertState extends State<CoolUpgradeAlert>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    checkForUpdates();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  widget.child;

  }


  Future<void> checkForUpdates() async {
    final upgrader = Upgrader();
    await upgrader.initialize();

    // Force the dialog to be shown every time

    if (upgrader.isUpdateAvailable()) {
      _showCoolUpgradeDialog(context);
    }
  }

  Future<bool?> _showCoolUpgradeDialog(BuildContext context) {
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();

    return showDialog<bool>(
      context: context,
      barrierDismissible: !widget.mandatory,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return PopScope(
          canPop: !widget.mandatory,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: AlertDialog(
                  backgroundColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  content: _buildCoolDialogContent(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoolDialogContent(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.primaryColor,
            widget.secondaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Floating circles decoration
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 0.1,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.system_update_alt_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  widget.customTitle ?? 'Update Available! 🚀',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Message
                Text(
                  widget.customMessage ??
                      'A newer version of the app is available with amazing new features and improvements!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Buttons
                Row(
                  children: [
                    if (!widget.mandatory) ...[
                      Expanded(
                        child: _buildButton(
                          context,
                          'Later',
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.8),
                              () => Navigator.of(context).pop(false),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: widget.mandatory ? 1 : 1,
                      child: _buildButton(
                        context,
                        'Update Now',
                        Colors.white,
                        widget.primaryColor,
                            () {
                          Navigator.of(context).pop(true);
                          // Launch store URL here
                          _launchStore();
                        },
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      BuildContext context,
      String text,
      Color backgroundColor,
      Color textColor,
      VoidCallback onPressed, {
        bool isPrimary = false,
      }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isPrimary
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _launchStore() async {
    try {
      final uri = Platform.isAndroid
          ? Uri.parse('https://play.google.com/store/apps/details?id=com.iwayplus.aiimsjammu')
          : Uri.parse('https://apps.apple.com/in/app/aiims-jammu-navigation/id6677034083');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) =>  MainScreen(initialIndex: 0,)),
              (route) => false,
        );
      });

    } catch (e) {
      print('Error launching store: $e');
    }
  }
}
