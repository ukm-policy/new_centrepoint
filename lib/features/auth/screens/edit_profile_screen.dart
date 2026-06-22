import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../core/session/app_session.dart';
import '../../../data/repositories/user_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _nimCtrl;
  late final TextEditingController _angkatanCtrl;
  late final TextEditingController _noHpCtrl;
  late final TextEditingController _bioCtrl;

  String? _selectedProdi = 'D4 Sarjana Terapan Teknik Informatika';
  String? _selectedJenisKelamin = 'L';
  bool _loading = false;

  XFile? _imageFile;
  final _picker = ImagePicker();
  String? _avatarUrl;

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
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: AppSession.nama);
    _nimCtrl = TextEditingController(text: AppSession.nim);
    _angkatanCtrl = TextEditingController(text: AppSession.angkatan.isEmpty ? '2021' : AppSession.angkatan);
    _noHpCtrl = TextEditingController(text: AppSession.noHp.isEmpty ? '081234567890' : AppSession.noHp);
    _bioCtrl = TextEditingController(text: 'Aktif, kritis, dan berintegritas tinggi.');
    _avatarUrl = AppSession.currentUser.avatarUrl;
    
    if (AppSession.prodi.isNotEmpty && _prodiList.contains(AppSession.prodi)) {
      _selectedProdi = AppSession.prodi;
    } else {
      _selectedProdi = 'D4 Sarjana Terapan Teknik Informatika';
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = pickedFile);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _angkatanCtrl.dispose();
    _noHpCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final userRepo = Provider.of<UserRepository>(context, listen: false);
      
      String? avatarUrl = _avatarUrl;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final fileExt = _imageFile!.name.split('.').last;
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '${AppSession.id}/$fileName';

        await Supabase.instance.client.storage.from('avatars').uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
        );
        avatarUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(filePath);
      }

      final updatedUser = AppSession.currentUser.copyWith(
        nama: _namaCtrl.text.trim(),
        nim: _nimCtrl.text.trim(),
        noHp: _noHpCtrl.text.trim(),
        prodi: _selectedProdi,
        angkatan: _angkatanCtrl.text.trim(),
        avatarUrl: avatarUrl,
      );
      
      userRepo.updateUser(updatedUser);
      
      // Delay slightly for the update to reflect
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil disimpan!',
              style: AppTypography.bodyMd.copyWith(color: Colors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.marginPage),
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profil: $e',
              style: AppTypography.bodyMd.copyWith(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.marginPage),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginPage,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button (left aligned)
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      border: Border.all(color: AppColors.blackCharcoal, width: 2),
                      boxShadow: const [AppColors.hardShadowSm],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.arrow_back, size: 16, color: AppColors.onSurface),
                      const SizedBox(width: 6),
                      Text('Kembali', style: AppTypography.labelBold),
                    ]),
                  ),
                ),
                // Title (right aligned)
                Text(
                  'Edit Profil',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginPage),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar picker placeholder
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
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
                              : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: _avatarUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) => const Icon(
                                          Icons.person_outline,
                                          size: 44,
                                          color: AppColors.tertiary,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_outline,
                                      size: 44,
                                      color: AppColors.tertiary,
                                    )),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
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
                              size: 16,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nama Lengkap
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
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.stackGap),

                // NIM & Angkatan
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
                          return null;
                        },
                      ),
                    ]),
                  ),
                ]),
                const SizedBox(height: AppSpacing.stackGap),

                // Program Studi
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

                // Jenis Kelamin
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

                // No. WhatsApp
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
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.stackGap),

                // Bio
                const _FieldLabel(label: 'BIO / DESKRIPSI DIRI'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTypography.bodyMd,
                  decoration: const InputDecoration(
                    hintText: 'Tulis deskripsi singkat tentang diri Anda...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.edit_note, size: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : BrutalistButton(
                        label: 'SIMPAN PERUBAHAN',
                        icon: Icons.save_outlined,
                        onPressed: _submit,
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
