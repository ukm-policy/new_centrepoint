import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _angkatanCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();

  String? _selectedProdi;
  String? _selectedJenisKelamin;
  bool _loading = false;
  XFile? _imageFile;
  final _picker = ImagePicker();

  static const _prodiList = [
    // 1. Jurusan Teknik Sipil
    'D3 Teknologi Konstruksi Bangunan Air',
    'D3 Teknologi Konstruksi Jalan dan Jembatan',
    'D4 Sarjana Terapan Teknologi Konstruksi Bangunan Gedung',
    'D4 Sarjana Terapan Teknologi Rekayasa Konstruksi Jalan dan Jembatan',
    // 2. Jurusan Teknik Mesin
    'D3 Teknologi Industri',
    'D3 Teknologi Mesin',
    'D4 Sarjana Terapan Teknologi Rekayasa Manufaktur',
    'D4 Sarjana Terapan Teknologi Rekayasa Pengelasan dan Fabrikasi',
    // 3. Jurusan Teknik Kimia
    'D3 Teknologi Kimia',
    'D3 Teknologi Pengolahan Minyak dan Gas',
    'D4 Sarjana Terapan Teknologi Rekayasa Kimia Industri',
    // 4. Jurusan Teknik Elektro
    'D3 Teknologi Listrik',
    'D3 Teknologi Telekomunikasi',
    'D3 Teknologi Elektronika',
    'D4 Sarjana Terapan Teknologi Rekayasa Pembangkit Energi',
    'D4 Sarjana Terapan Teknologi Rekayasa Jaringan Telekomunikasi',
    'D4 Sarjana Terapan Teknologi Rekayasa Instrumentasi dan Kontrol',
    // 5. Jurusan Bisnis / Tata Niaga
    'D3 Akuntansi',
    'D3 Administrasi Bisnis',
    'D4 Sarjana Terapan Manajemen Keuangan Sektor Publik',
    'D4 Sarjana Terapan Akuntansi Lembaga Keuangan Syariah',
    // 6. Jurusan Teknologi Informasi dan Komputer (TIK)
    'D4 Sarjana Terapan Teknologi Rekayasa Multimedia',
    'D4 Sarjana Terapan Teknologi Rekayasa Komputer Jaringan',
    'D4 Sarjana Terapan Teknik Informatika',
  ];

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _angkatanCtrl.dispose();
    _noHpCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      String? avatarUrl;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final fileExt = _imageFile!.name.split('.').last;
        final fileName = 'avatar.$fileExt';
        final filePath = '${user.id}/$fileName';

        await Supabase.instance.client.storage.from('avatars').uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
        );
        avatarUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(filePath);
      }

      // Update profiles table
      await Supabase.instance.client.from('profiles').update({
        'nama': _namaCtrl.text.trim(),
        'nim': _nimCtrl.text.trim(),
        'no_hp': _noHpCtrl.text.trim(),
        'prodi': _selectedProdi,
        'angkatan': _angkatanCtrl.text.trim(),
        'avatar_url': ?avatarUrl,
      }).eq('id', user.id);

      // Synchronize auth metadata
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'nama': _namaCtrl.text.trim(),
            'nim': _nimCtrl.text.trim(),
            'no_hp': _noHpCtrl.text.trim(),
            'prodi': _selectedProdi,
            'angkatan': _angkatanCtrl.text.trim(),
            'avatar_url': ?avatarUrl,
          },
        ),
      );

      if (!mounted) return;
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _skip() => context.go('/');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: Column(
          children: [

            // ── Top bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginPage, 16, AppSpacing.marginPage, 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kosong — tidak ada back (akun sudah dibuat)
                  const SizedBox(width: 60),
                  Text(
                    'Lengkapi Profil',
                    style: AppTypography.headlineSm,
                  ),
                  // Skip
                  GestureDetector(
                    onTap: _skip,
                    child: Text(
                      'Lewati',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.tertiary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.marginPage),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // ── Avatar placeholder ─────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.blackCharcoal,
                                    width: 2.5,
                                  ),
                                  boxShadow: const [AppColors.hardShadow],
                                ),
                                child: _imageFile != null
                                    ? ClipOval(
                                        child: Image.file(
                                          File(_imageFile!.path),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person_outline,
                                        size: 40,
                                        color: AppColors.tertiary,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.blackCharcoal,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 14,
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Foto Profil (opsional)',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.tertiary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Nama Lengkap ───────────────────────────────────────
                      const _FieldLabel(label: 'NAMA LENGKAP'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _namaCtrl,
                        textCapitalization: TextCapitalization.words,
                        style: AppTypography.bodyMd,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama lengkap',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
                          if (v.trim().length < 3) return 'Nama minimal 3 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.stackGap),

                      // ── NIM & Angkatan ─────────────────────────────────────
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                          flex: 3,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const _FieldLabel(label: 'NIM'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nimCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: AppTypography.bodyMd,
                              decoration: const InputDecoration(
                                hintText: '2024010001',
                                prefixIcon: Icon(Icons.badge_outlined, size: 20),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'NIM wajib diisi';
                                if (v.length < 8) return 'NIM tidak valid';
                                return null;
                              },
                            ),
                          ]),
                        ),
                        const SizedBox(width: AppSpacing.gutterGrid),
                        Expanded(
                          flex: 2,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const _FieldLabel(label: 'ANGKATAN'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _angkatanCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              style: AppTypography.bodyMd,
                              decoration: const InputDecoration(
                                hintText: '2024',
                                prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Wajib';
                                if (v.length != 4) return 'YYYY';
                                final y = int.tryParse(v);
                                if (y == null || y < 2010 || y > 2030) return 'Tidak valid';
                                return null;
                              },
                            ),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.stackGap),

                      // ── Program Studi ──────────────────────────────────────
                      const _FieldLabel(label: 'PROGRAM STUDI'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedProdi,
                        onChanged: (v) => setState(() => _selectedProdi = v),
                        style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                        isExpanded: true,
                        decoration: const InputDecoration(
                          hintText: 'Pilih program studi',
                          prefixIcon: Icon(Icons.school_outlined, size: 20),
                        ),
                        items: _prodiList.map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            p,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )).toList(),
                        validator: (v) => v == null ? 'Program studi wajib dipilih' : null,
                      ),
                      const SizedBox(height: AppSpacing.stackGap),

                      // ── Jenis Kelamin ──────────────────────────────────────
                      const _FieldLabel(label: 'JENIS KELAMIN'),
                      const SizedBox(height: 6),
                      Row(children: [
                        _GenderOption(
                          label: 'Laki-laki',
                          icon: Icons.male,
                          selected: _selectedJenisKelamin == 'L',
                          onTap: () => setState(() => _selectedJenisKelamin = 'L'),
                        ),
                        const SizedBox(width: AppSpacing.gutterGrid),
                        _GenderOption(
                          label: 'Perempuan',
                          icon: Icons.female,
                          selected: _selectedJenisKelamin == 'P',
                          onTap: () => setState(() => _selectedJenisKelamin = 'P'),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.stackGap),

                      // ── No. WhatsApp ───────────────────────────────────────
                      const _FieldLabel(label: 'NO. WHATSAPP'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _noHpCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: AppTypography.bodyMd,
                        decoration: const InputDecoration(
                          hintText: '08xxxxxxxxxx',
                          prefixIcon: Icon(Icons.phone_outlined, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'No. WhatsApp wajib diisi';
                          if (v.length < 10) return 'Nomor tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // ── Submit ─────────────────────────────────────────────
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : BrutalistButton(
                              label: 'SIMPAN',
                              icon: Icons.check,
                              onPressed: _submit,
                            ),
                      const SizedBox(height: 14),

                      // ── Skip ───────────────────────────────────────────────
                      GestureDetector(
                        onTap: _skip,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Isi nanti saja',
                                style: AppTypography.labelBold.copyWith(
                                  color: AppColors.tertiary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: AppColors.tertiary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gender Option ─────────────────────────────────────────────────────────────

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(color: AppColors.blackCharcoal, width: 2),
            boxShadow: [BoxShadow(
              color: AppColors.blackCharcoal,
              offset: selected ? const Offset(2, 2) : const Offset(3, 3),
              blurRadius: 0,
            )],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18,
              color: selected ? AppColors.onPrimary : AppColors.tertiary),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.labelBold.copyWith(
              color: selected ? AppColors.onPrimary : AppColors.onSurface,
            )),
          ]),
        ),
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: AppTypography.labelBold.copyWith(
      color: AppColors.onSurface,
      letterSpacing: 0.5,
    ),
  );
}
