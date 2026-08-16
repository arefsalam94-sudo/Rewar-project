import 'package:flutter/material.dart';

import '../services/password_reset_service.dart';

/// Loud, debug-only marker shown on screens whose backend calls are being
/// faked because Firebase isn't configured yet.
///
/// Renders nothing at all when the backend is real, and can never appear in a
/// release build — [PasswordResetService.isPreviewMode] is gated on
/// `kDebugMode`.
class PreviewModeBanner extends StatelessWidget {
  const PreviewModeBanner({super.key, required this.message});

  /// What is being faked on this particular screen.
  final String message;

  @override
  Widget build(BuildContext context) {
    if (!PasswordResetService.isPreviewMode) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE08A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8A6D00), width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: Color(0xFF6B5400),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A3A00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
