import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/list_status.dart';
import '../../../shared/widgets/my_divider.dart';

/// Menampilkan `Privacy.md` (dibundel sebagai asset) dengan renderer
/// markdown sederhana: heading, bullet, garis, dan **tebal**.
class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: const PageAppBar(title: 'Kebijakan Privasi', trailing: SizedBox(width: 40)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('Privacy.md'),
        builder: (context, snap) {
          if (!snap.hasData) {
            return ListStatus(
              loading: !snap.hasError,
              icon: Icons.privacy_tip_outlined,
              message: 'Kebijakan privasi tidak dapat dimuat.',
            );
          }
          final blocks = _parse(snap.data!);
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginPage, 8, AppSpacing.marginPage, 32,
            ),
            itemCount: blocks.length,
            itemBuilder: (_, i) => blocks[i],
          );
        },
      ),
    );
  }

  static List<Widget> _parse(String md) {
    final out = <Widget>[];
    for (final raw in md.split('\n')) {
      final line = raw.trimRight();
      if (line.isEmpty) {
        out.add(const SizedBox(height: 8));
      } else if (line.startsWith('---')) {
        out.add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: MyDivider(color: AppColors.borderSlate),
        ));
      } else if (line.startsWith('#')) {
        final level = line.indexOf(' ');
        final text = line.substring(level + 1);
        final style = switch (level) {
          1 => AppTypography.headlineMd,
          2 => AppTypography.headlineSm,
          _ => AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w800),
        };
        out.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: _rich(text, style),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        out.add(Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('•  ', style: AppTypography.bodyMd),
            Expanded(child: _rich(line.substring(2), AppTypography.bodyMd)),
          ]),
        ));
      } else {
        out.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _rich(line, AppTypography.bodyMd),
        ));
      }
    }
    return out;
  }

  /// Teks dengan dukungan **tebal**.
  static Widget _rich(String text, TextStyle style) {
    final parts = text.split('**');
    return Text.rich(TextSpan(
      style: style.copyWith(color: AppColors.onSurface),
      children: [
        for (var i = 0; i < parts.length; i++)
          TextSpan(
            text: parts[i],
            style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w800) : null,
          ),
      ],
    ));
  }
}
