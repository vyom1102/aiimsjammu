// ─────────────────────────────────────────────────────────────────────────────
// left_floating_action_menu.dart
//
// FULLY STANDALONE – zero dependencies outside of Flutter's material package.
// Drop this file into any Flutter project and import it; it works on its own.
//
// Usage in a Scaffold:
//
//   floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
//   floatingActionButton: LeftFloatingActionMenu(
//     primaryColor: Colors.amber,
//     mainButtonChild: Icon(Icons.menu),   // or Lottie / any widget
//     tiles: [
//       FloatingActionTile(
//         icon: Icons.crisis_alert,
//         title: 'SOS',
//         backgroundColor: Colors.red,
//         iconColor: Colors.white,
//         confirm: TileConfirmConfig(
//           title: 'Send SOS?',
//           message: 'This will alert the admin immediately.',
//         ),
//         onTap: () => mySosService.send(),
//       ),
//     ],
//   ),
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TileConfirmConfig
// ─────────────────────────────────────────────────────────────────────────────

/// Configuration for an optional confirmation dialog that is shown
/// **before** a [FloatingActionTile]'s [onTap] fires.
///
/// Set this on any tile where the action is irreversible (e.g. SOS, delete).
class TileConfirmConfig {
  /// Dialog title – shown in bold at the top.
  final String title;

  /// Supporting message explaining what will happen.
  final String message;

  /// Label for the affirmative button. Defaults to "Confirm".
  final String confirmLabel;

  /// Label for the dismiss button. Defaults to "Cancel".
  final String cancelLabel;

  /// Color of the affirmative button. Defaults to [Colors.red].
  final Color confirmColor;

  /// Optional icon shown above the title inside the dialog.
  final IconData? dialogIcon;

  /// Color of [dialogIcon]. Defaults to [Colors.red].
  final Color iconColor;

  const TileConfirmConfig({
    required this.title,
    required this.message,
    this.confirmLabel = 'Send',
    this.cancelLabel = 'Cancel',
    this.confirmColor = Colors.red,
    this.dialogIcon,
    this.iconColor = Colors.red,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// LeftFloatingActionMenu
// ─────────────────────────────────────────────────────────────────────────────

/// A left-aligned expandable FAB menu.
///
/// Place inside a [Scaffold]'s `floatingActionButton` slot and set
/// `floatingActionButtonLocation` to [FloatingActionButtonLocation.startFloat].
///
/// Tapping the main FAB toggles the tile list open / closed.
/// Each [FloatingActionTile] handles its own action independently.
class LeftFloatingActionMenu extends StatefulWidget {
  /// List of action tiles shown when the menu is expanded.
  final List<FloatingActionTile> tiles;

  /// Icon displayed on the main FAB when it is collapsed AND [mainButtonChild]
  /// is null. Defaults to [Icons.menu].
  final IconData mainIcon;

  /// Icon displayed on the main FAB when it is *expanded*. Defaults to
  /// [Icons.close].
  final IconData closeIcon;

  /// Background colour of the main FAB.
  final Color? primaryColor;

  /// Optional custom widget to show inside the main FAB when it is collapsed
  /// (e.g. a Lottie animation). Overrides [mainIcon] when set.
  final Widget? mainButtonChild;

  const LeftFloatingActionMenu({
    Key? key,
    required this.tiles,
    this.mainIcon = Icons.menu,
    this.closeIcon = Icons.close,
    this.primaryColor,
    this.mainButtonChild,
  }) : super(key: key);

  @override
  State<LeftFloatingActionMenu> createState() => _LeftFloatingActionMenuState();
}

class _LeftFloatingActionMenuState extends State<LeftFloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiles (reversed so tile[0] sits closest to the FAB)
        ...widget.tiles.reversed.map(
          (tile) => SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: 1.0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: tile,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Main toggle FAB
        FloatingActionButton(
          heroTag: 'left_floating_menu_main',
          onPressed: _toggle,
          backgroundColor:
              widget.primaryColor ?? Theme.of(context).primaryColor,
          shape: const CircleBorder(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: _isExpanded
                ? Icon(widget.closeIcon,
                    key: const ValueKey('__close__'),
                    color: Colors.white)
                : (widget.mainButtonChild != null
                    ? KeyedSubtree(
                        key: const ValueKey('__custom__'),
                        child: widget.mainButtonChild!,
                      )
                    : Icon(widget.mainIcon,
                        key: const ValueKey('__menu__'),
                        color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FloatingActionTile
// ─────────────────────────────────────────────────────────────────────────────

/// A single action row shown when [LeftFloatingActionMenu] is expanded.
///
/// Renders as a small circular FAB on the left with a dark pill label on the
/// right.  When [confirm] is set, tapping the tile shows a confirmation dialog
/// first; [onTap] only fires if the user confirms.
class FloatingActionTile extends StatelessWidget {
  /// Icon shown inside the small circular FAB.
  final IconData icon;

  /// Label shown in the dark pill to the right of the FAB.
  final String title;

  /// Called when the tile is tapped (and confirmed, if [confirm] is set).
  final VoidCallback onTap;

  /// Background colour of the small circular FAB.
  final Color? backgroundColor;

  /// Icon colour inside the small circular FAB.
  final Color? iconColor;

  /// When non-null, a confirmation dialog is shown before [onTap] fires.
  final TileConfirmConfig? confirm;

  const FloatingActionTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.confirm,
  }) : super(key: key);

  Future<void> _handleTap(BuildContext context) async {
    if (confirm == null) {
      onTap();
      return;
    }

    final approved = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ConfirmDialog(config: confirm!, tileTitle: title),
    );

    if (approved == true) {
      onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FloatingActionButton.small(
          heroTag: null,
          onPressed: () => _handleTap(context),
          backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _handleTap(context),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ConfirmDialog  (private – internal to this file)
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final TileConfirmConfig config;
  final String tileTitle;

  const _ConfirmDialog({
    required this.config,
    required this.tileTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──────────────────────────────────────────────────────
            if (config.dialogIcon != null) ...[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: config.iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.dialogIcon,
                  size: 38,
                  color: config.iconColor,
                ),
              ),
              const SizedBox(height: 18),
            ],

            // ── Title ─────────────────────────────────────────────────────
            Text(
              config.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),

            // ── Message ───────────────────────────────────────────────────
            Text(
              config.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),

            // ── Actions ───────────────────────────────────────────────────
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      config.cancelLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: config.confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      config.confirmLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
