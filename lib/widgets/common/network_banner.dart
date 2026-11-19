import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/network_status.dart';
import '../../l10n/app_localizations.dart';

/// Wraps a screen with a live connectivity banner:
/// - Red banner whenever the browser goes offline.
/// - Brief green "Back online" banner + triggers [onReconnect] when internet returns.
class NetworkStatusWrapper extends StatefulWidget {
  final Widget child;
  final AppLocalizations s;
  final VoidCallback onReconnect;

  const NetworkStatusWrapper({
    super.key,
    required this.child,
    required this.s,
    required this.onReconnect,
  });

  @override
  State<NetworkStatusWrapper> createState() => _NetworkStatusWrapperState();
}

class _NetworkStatusWrapperState extends State<NetworkStatusWrapper> {
  late bool _isOnline;
  bool _showRestoredBanner = false;
  StreamSubscription<bool>? _sub;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _isOnline = isCurrentlyOnline();
    _sub = onlineStatusStream().listen((online) {
      if (!mounted) return;
      final wasOffline = !_isOnline;
      setState(() {
        _isOnline = online;
        if (online && wasOffline) {
          _showRestoredBanner = true;
        } else if (!online) {
          _showRestoredBanner = false;
        }
      });
      if (online && wasOffline) {
        widget.onReconnect();
        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showRestoredBanner = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showBanner = !_isOnline || _showRestoredBanner;
    final bannerColor = !_isOnline ? AppColors.danger : AppColors.emerald;
    final bannerIcon = !_isOnline ? Icons.wifi_off_rounded : Icons.wifi_rounded;
    final bannerText = !_isOnline
        ? widget.s.offlineBannerMsg
        : widget.s.onlineRestoredToast;

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: showBanner
              ? Material(
                  color: bannerColor,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(bannerIcon, size: 16, color: Colors.white),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              bannerText,
                              textAlign: TextAlign.center,
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
