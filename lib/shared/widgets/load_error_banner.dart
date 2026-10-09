import 'package:flutter/material.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/load_error_hub.dart';

/// Menampilkan banner di atas [child] ketika ada data yang gagal dimuat,
/// lengkap dengan tombol "Coba lagi".
class LoadErrorBanner extends StatefulWidget {
  const LoadErrorBanner({super.key, required this.child});

  final Widget child;

  @override
  State<LoadErrorBanner> createState() => _LoadErrorBannerState();
}

class _LoadErrorBannerState extends State<LoadErrorBanner> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    await LoadErrorHub.instance.retryAll();
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LoadErrorHub.instance,
      builder: (context, child) {
        final hub = LoadErrorHub.instance;
        if (!hub.hasError) return child!;
        return Column(
          children: [
            Material(
              color: AppColors.error,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.marginPage, 8, 8, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Gagal memuat data: ${friendlyError(hub.latestError!)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMd.copyWith(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: _retrying ? null : _retry,
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        child: _retrying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('COBA LAGI'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Banner sudah memakan area status bar, jadi layar di bawahnya
            // tidak perlu padding atas lagi.
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: child!,
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
