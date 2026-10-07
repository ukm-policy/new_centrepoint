import 'package:flutter/material.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

void _showSnack(ScaffoldMessengerState messenger, String message, Color color) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: const BorderSide(color: AppColors.blackCharcoal, width: 2),
        ),
      ),
    );
}

void showSuccessSnack(BuildContext context, String message) =>
    _showSnack(ScaffoldMessenger.of(context), message, AppColors.success);

void showErrorSnack(BuildContext context, Object error, {String? prefix}) {
  final text = friendlyError(error);
  _showSnack(ScaffoldMessenger.of(context), prefix == null ? text : '$prefix: $text', AppColors.error);
}

/// Jalankan [action]; tampilkan [success] bila berhasil atau pesan error bila
/// gagal. Mengembalikan true jika berhasil.
Future<bool> runWithFeedback(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
  String? errorPrefix,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    if (success != null) _showSnack(messenger, success, AppColors.success);
    return true;
  } catch (e) {
    final text = friendlyError(e);
    _showSnack(messenger, errorPrefix == null ? text : '$errorPrefix: $text', AppColors.error);
    return false;
  }
}
