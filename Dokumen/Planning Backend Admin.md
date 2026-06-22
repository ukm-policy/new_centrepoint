# Planning: Integrasi Backend & Supabase — Panel Admin

> Dokumen ini adalah roadmap teknis untuk menyelesaikan integrasi seluruh fitur/screen pada **Panel Admin** aplikasi CentrePoint. Dibuat 22 Juni 2026.

---

## 1. Status Integrasi Saat Ini

| # | Screen | File | Status | Keterangan |
|---|--------|------|--------|------------|
| 1 | Dashboard Admin | `admin_screen.dart` | ✅ **SELESAI** | Stat badge realtime dari Supabase |
| 2 | Kelola Akun | `kelola_akun_screen.dart` | ✅ **SELESAI** | CRUD via UserRepository |
| 3 | Assign Jabatan | `assign_jabatan_screen.dart` | ✅ **SELESAI** | Kepengurusan + Jabatan terintegrasi |
| 4 | Kelola Berita | `kelola_berita_screen.dart` | ✅ **SELESAI** | BeritaRepository penuh |
| 5 | Kelola Kegiatan | `kelola_kegiatan_screen.dart` | ✅ **SELESAI** | KegiatanRepository + panitia/sie |
| 6 | Uang Kas Admin | `uang_khas_admin_screen.dart` | ✅ **SELESAI** | UangKhasRepository |
| 7 | Verifikasi Kas | `verifikasi_khas_screen.dart` | ✅ **SELESAI** | Verifikasi bukti bayar |
| 8 | Buat Pengumuman | `buat_pengumuman_screen.dart` | ✅ **SELESAI** | `_submit()` inject InboxRepository → Supabase `pengumuman` |
| 9 | Kelola Poin | `kelola_poin_screen.dart` | ✅ **SELESAI** | PoinRepository untuk riwayat & mutasi; division filter dinamis |
| 10 | QR Generator | `qr_generator_screen.dart` | ✅ **SELESAI** | QrSessionRepository → Supabase `qr_session`; QR real via qr_flutter; Timer dari expired_at |
| 11 | Verifikasi Anggota | `verifikasi_anggota_screen.dart` | ✅ **SELESAI** | ORRepository — reviewApplicant() ke Supabase `or_pelamar` |
| 12 | Kelola Periode | `kelola_periode_screen.dart` | ✅ **SELESAI** | Consumer<PeriodeRepository> — addPeriode/setActivePeriode realtime |
| 13 | Rekap Keuangan | `rekap_keuangan_screen.dart` | ✅ **SELESAI** | RPC `get_rekap_keuangan` → agregasi per bidang; export CSV via share_plus |
| 14 | Audit Log | `audit_log_screen.dart` | ✅ **SELESAI** | Tabel `audit_log` di Supabase; AuditLogRepository; injected di 5 screen admin |

**Summary:** 14 selesai · 0 partial · 0 dummy ✅ **SEMUA SELESAI** *(update: 22 Juni 2026)*

---

## 2. Arsitektur Referensi

```
Screen → Provider.of<XRepository>(context) → SupabaseXRepository → Supabase DB
                                                      ↓
                                          notifyListeners() → rebuild UI
```

Semua repository sudah menggunakan **ChangeNotifier + Realtime subscription**. Pola ini harus diikuti konsisten di setiap integrasi baru.

---

## 3. Roadmap Berdasarkan Prioritas

### FASE 1 — Quick Win (Repository sudah siap, tinggal wiring)
> Estimasi: 1–2 hari ✅ **SELESAI** — Buat Pengumuman & Kelola Periode selesai 22 Juni 2026

---

### FASE 2 — Integrasi Data Lokal ke Repository
> Estimasi: 2–3 hari ✅ **SELESAI** — Verifikasi Anggota & Kelola Poin selesai 22 Juni 2026

---

### FASE 3 — Infrastruktur Baru (butuh tabel/schema baru di Supabase)
> Estimasi: 3–5 hari ⏳ **BELUM DIKERJAKAN**

---

## 4. Detail Per Screen

---

### [FASE 1] Screen 8 — Buat Pengumuman

**File:** `lib/features/admin/screens/buat_pengumuman_screen.dart`

**Masalah:**
- Fungsi `_submit()` hanya `await Future.delayed(900ms)` — tidak ada call ke Supabase.
- `InboxRepository` (`SupabaseInboxRepository`) **sudah punya** method `addPengumuman(PengumumanModel)` yang langsung insert ke tabel `pengumuman`.

**Langkah Integrasi:**

1. Inject `InboxRepository` via `context.read<InboxRepository>()` di `_BuatPengumumanScreenState`.

2. Ganti isi `_submit()`:
   ```dart
   Future<void> _submit() async {
     if (!_formKey.currentState!.validate()) return;
     setState(() => _sending = true);
     try {
       final repo = context.read<InboxRepository>();
       final now = DateTime.now();
       repo.addPengumuman(PengumumanModel(
         id: '', // Supabase generates UUID
         kategori: _selectedCat,
         judul: _titleCtrl.text.trim(),
         ringkasan: _contentCtrl.text.trim().substring(0, min(100, _contentCtrl.text.length)),
         konten: [_contentCtrl.text.trim()],
         tanggal: now,
         isNew: true,
         actionLabel: _showActionCard ? _actionLabelCtrl.text.trim() : null,
         actionRoute: _showActionCard ? _actionRouteCtrl.text.trim() : null,
       ));
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(/* success */);
       context.pop();
     } catch (e) {
       // show error snackbar
     } finally {
       if (mounted) setState(() => _sending = false);
     }
   }
   ```

3. Tambah import `inbox_repository.dart` dan `inbox_model.dart`.

4. Pastikan field `ringkasan` di model diisi (substring 100 char pertama dari konten).

**Tabel Supabase terdampak:** `pengumuman`
**Tidak perlu migrasi baru** — tabel sudah ada.

---

### [FASE 1] Screen 12 — Kelola Periode

**File:** `lib/features/admin/screens/kelola_periode_screen.dart`

**Masalah:**
- Menggunakan class lokal `_LocalPeriod` dengan `List<_LocalPeriod> _periods` yang diinisiasi di `initState()`.
- `SupabasePeriodeRepository` **sudah lengkap**: `addPeriode()`, `setActivePeriode()`, load realtime.

**Langkah Integrasi:**

1. Ubah widget dari `StatefulWidget` ke `StatelessWidget` (atau tetap StatefulWidget tapi tanpa `_periods`).

2. Wrap build dengan `Consumer<PeriodeRepository>`:
   ```dart
   Consumer<PeriodeRepository>(
     builder: (context, repo, _) {
       final periods = repo.periodes;
       final active = repo.activePeriode;
       // render list dari periods
     }
   )
   ```

3. Ganti `_setActive(id)`:
   ```dart
   void _setActive(String id) {
     context.read<PeriodeRepository>().setActivePeriode(id);
     // snackbar tetap sama
   }
   ```

4. Ganti `_showCreateDialog()` — saat user submit:
   ```dart
   final repo = context.read<PeriodeRepository>();
   repo.addPeriode(PeriodeModel(
     id: '',
     nama: nameCtrl.text.trim(),
     tanggalMulai: DateTime(int.parse(yearCtrl.text), 1, 1),
     tanggalSelesai: DateTime(int.parse(yearCtrl.text) + 1, 12, 31),
     isActive: false,
   ));
   ```

5. Hapus class `_LocalPeriod` dan field `_periods`.

**Tabel Supabase terdampak:** `periode`
**Tidak perlu migrasi baru.**

---

### [FASE 2] Screen 11 — Verifikasi Anggota

**File:** `lib/features/admin/screens/verifikasi_anggota_screen.dart`

**Masalah:**
- List `_applicants` berisi 6 objek hardcoded.
- `_handleApprove()` dan `_handleReject()` hanya mengubah state lokal.
- Tidak ada koneksi ke repository manapun.

**Analisis Data:**
Pendaftar anggota bisa berasal dari dua sumber:
- **OR Applicants** (`or_applicant` table) — pendaftar open recruitment
- **Profil baru yang belum diverifikasi** — user register tapi statusnya `pending`

Rekomendasi: gunakan tabel `or_applicant` (sudah ada `ORRepository`), **atau** tambahkan field `is_verified: bool` di tabel `profiles`.

**Pilihan Implementasi (pilih salah satu sesuai flow bisnis):**

**Opsi A — Gunakan OR Applicant** (jika verifikasi = menerima pelamar OR):
```dart
Consumer<ORRepository>(
  builder: (context, repo, _) {
    final applicants = repo.applicants.where((a) => a.status == 'pending').toList();
    // render dari sini
  }
)
```
Approve: `repo.updateApplicantStatus(id, 'diterima')`
Reject: `repo.updateApplicantStatus(id, 'ditolak')`

**Opsi B — Field `is_verified` di `profiles`** (jika verifikasi = konfirmasi akun baru):
1. Tambah kolom `is_verified BOOLEAN DEFAULT false` di tabel `profiles`.
2. Di `SupabaseUserRepository`, tambah method `verifyUser(id)` dan `rejectUser(id)`.
3. `UserRepository` diperluas dengan `getUnverifiedUsers()`.
4. Screen mengkonsumsi `UserRepository`.

**Langkah umum (setelah pilih opsi):**

1. Hapus class `_Applicant` lokal dan field `_applicants`.
2. Inject repository yang dipilih.
3. Tampilkan `CircularProgressIndicator` saat loading.
4. `_handleApprove(id)` → call repository method → otomatis re-render via notifyListeners.
5. `_handleReject(id)` → call repository method.
6. Badge `_pendingCount` dihitung dari data repository.

**Tabel Supabase terdampak:** `or_applicant` atau `profiles`

---

### [FASE 2] Screen 9 — Kelola Poin

**File:** `lib/features/admin/screens/kelola_poin_screen.dart`

**Masalah:**
- `_pointsMap` dan `_mutationHistory` adalah state lokal yang tidak dipersist.
- Riwayat poin tiap member berisi 3 entry dummy yang sama untuk semua member.
- Adjusment poin tidak pernah ditulis ke `poin_entry` table.
- `PoinRepository` sudah ada dengan method `addPoinEntry()`.

**Langkah Integrasi:**

1. **Hapus** field `_pointsMap`, `_mutationHistory`, `_initialized`, dan method `_initMaps()`.

2. Inject `PoinRepository` untuk riwayat per member:
   ```dart
   final poinRepo = context.read<PoinRepository>();
   final history = poinRepo.poinEntries.where((e) => e.memberId == member.id).toList();
   ```

3. `totalPoin` member diambil dari `MemberModel.totalPoin` yang sudah dihitung di `SupabasePoinRepository` (aggregate dari `poin_entry`).

4. Di modal adjust poin, ganti `setState` lokal dengan call ke repository:
   ```dart
   Future<void> _submitAdjust(MemberModel member, int amount, String reason) async {
     final repo = context.read<PoinRepository>();
     final entry = PoinEntryModel(
       id: '',
       memberId: member.id,
       memberNama: member.nama,
       label: reason,
       tipe: amount >= 0 ? TipePoin.bonus : TipePoin.penalti,
       poin: amount.abs(),
       tanggal: DateTime.now(),
       kegiatanId: null,
     );
     await repo.addPoinEntry(entry);
     // Supabase realtime akan trigger reload otomatis
   }
   ```

5. Pastikan `SupabasePoinRepository.addPoinEntry()` ada — jika belum, tambahkan:
   ```dart
   @override
   Future<void> addPoinEntry(PoinEntryModel entry) async {
     await _db.from('poin_entry').insert({
       'member_id': entry.memberId,
       'member_nama': entry.memberNama,
       'label': entry.label,
       'tipe': entry.tipe.toString().split('.').last,
       'poin': entry.tipe == TipePoin.penalti ? -entry.poin : entry.poin,
       'tanggal': entry.tanggal.toIso8601String(),
       'kegiatan_id': entry.kegiatanId,
     });
   }
   ```

6. Hapus filter division hardcoded `_divisions` — ganti dengan list bidang dari data member aktual.

**Tabel Supabase terdampak:** `poin_entry`
**Tidak perlu migrasi** jika kolom poin sudah support nilai negatif (penalti).

---

### [FASE 2] Screen 10 — QR Generator

**File:** `lib/features/admin/screens/qr_generator_screen.dart`

**Masalah:**
- QR code yang ditampilkan hanya UI visual (tidak ada token/data valid).
- Timer countdown berjalan di state lokal, tidak tersimpan ke DB.
- Jika admin tutup app, session QR hilang.
- Absensi via QR tidak terhubung ke tabel `absensi`.

**Langkah Integrasi:**

1. **Buat tabel baru di Supabase:**
   ```sql
   CREATE TABLE qr_session (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     kegiatan_id UUID REFERENCES kegiatan(id),
     token TEXT UNIQUE NOT NULL,
     expires_at TIMESTAMPTZ NOT NULL,
     created_by UUID REFERENCES profiles(id),
     created_at TIMESTAMPTZ DEFAULT now()
   );
   ```

2. **Buat `QrSessionRepository`** (abstract + Supabase implementation):
   - `createSession(kegiatanId, durationMinutes)` → insert ke `qr_session`, return token + expires_at
   - `getActiveSession(kegiatanId)` → query session yang belum expired
   - `deleteSession(id)` → delete/expire session

3. **Update `_generate()` di screen:**
   ```dart
   Future<void> _generate() async {
     if (!_formKey.currentState!.validate()) return;
     setState(() => _loading = true);
     final mins = int.tryParse(_durationCtrl.text) ?? 30;
     final repo = context.read<QrSessionRepository>();
     final session = await repo.createSession(_selectedKegiatanId!, mins);
     setState(() {
       _qrToken = session.token;         // embed token ke QR widget
       _expiresAt = session.expiresAt;   // hitung countdown dari ini
       _generated = true;
       _loading = false;
     });
   }
   ```

4. **Gunakan package `qr_flutter`** untuk render QR dari token:
   ```dart
   QrImageView(
     data: _qrToken!,
     size: 220,
   )
   ```

5. Countdown timer berbasis `expiresAt - DateTime.now()` via `Timer.periodic`, bukan dari state manual.

6. Di sisi anggota (scan QR), endpoint verifikasi token dan insert ke `absensi` table (bisa Supabase Edge Function atau RPC).

**Tabel Supabase terdampak:** `qr_session` (baru), `absensi` (existing)
**Butuh migrasi baru.**

---

### [FASE 3] Screen 14 — Audit Log

**File:** `lib/features/admin/screens/audit_log_screen.dart`

**Masalah:**
- Seluruh log hardcoded sebagai `const List<_AuditLog>`.
- Tidak ada tabel `audit_log` di Supabase.
- Tidak ada mekanisme pencatatan otomatis saat admin melakukan aksi.

**Langkah Integrasi:**

**Step 1 — Buat tabel `audit_log` di Supabase:**
```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID REFERENCES profiles(id),
  admin_nama TEXT NOT NULL,
  aksi TEXT NOT NULL,
  tipe TEXT NOT NULL CHECK (tipe IN ('Verifikasi','Poin','Keuangan','Kegiatan','Sistem','OR')),
  entity_id TEXT,         -- ID entitas yang diubah (opsional)
  entity_type TEXT,       -- Tipe entitas ('member', 'kegiatan', dll)
  metadata JSONB,         -- Data tambahan
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS: admin bisa read semua, insert only (no update/delete)
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "admin can read audit_log" ON audit_log FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true));
CREATE POLICY "service can insert audit_log" ON audit_log FOR INSERT TO authenticated
  WITH CHECK (true);
```

**Step 2 — Buat `AuditLogRepository`:**
```dart
abstract class AuditLogRepository extends ChangeNotifier {
  List<AuditLogModel> get logs;
  Future<void> logAction({
    required String aksi,
    required String tipe,
    String? entityId,
    String? entityType,
    Map<String, dynamic>? metadata,
  });
}
```

**Step 3 — Buat `AuditLogModel`:**
```dart
class AuditLogModel {
  final String id;
  final String adminId;
  final String adminNama;
  final String aksi;
  final String tipe;
  final String? entityId;
  final DateTime createdAt;
  // ...
}
```

**Step 4 — Inject logging di setiap aksi admin:**

Setiap kali admin melakukan aksi di screen lain, panggil `AuditLogRepository.logAction()`:

| Aksi Admin | Tipe Log | Contoh Pesan |
|-----------|---------|-------------|
| Approve/reject anggota | `Verifikasi` | "Menerima pendaftaran anggota (Nama)" |
| Adjust poin | `Poin` | "Menambahkan +50 poin ke (Nama)" |
| Verifikasi pembayaran kas | `Keuangan` | "Verifikasi iuran kas (Nama - Bulan)" |
| Buat/edit kegiatan | `Kegiatan` | "Membuat kegiatan baru: (Judul)" |
| Buat pengumuman | `Sistem` | "Menyebarkan pengumuman: (Judul)" |
| Set periode aktif | `Sistem` | "Mengaktifkan periode (Nama Periode)" |
| Generate QR | `Kegiatan` | "Membuat QR absensi untuk (Kegiatan)" |

**Step 5 — Update `AuditLogScreen` konsumsi repository:**
```dart
Consumer<AuditLogRepository>(
  builder: (context, repo, _) {
    final logs = repo.logs;
    // render timeline dari logs
  }
)
```

**Tabel Supabase terdampak:** `audit_log` (baru)
**Butuh migrasi + update di semua screen admin yang punya aksi.**

---

### [FASE 3] Screen 13 — Rekap Keuangan

**File:** `lib/features/admin/screens/rekap_keuangan_screen.dart`

**Masalah:**
- `_rekapData` hardcoded 7 baris dengan nominal palsu.
- Filter tahun & semester tidak ada efeknya.
- Tombol "Export" hanya simulasi.

**Langkah Integrasi:**

**Step 1 — Extend `UangKhasRepository`** dengan method agregasi:
```dart
abstract class UangKhasRepository {
  // existing...
  
  // NEW: Rekap per bidang untuk tahun & semester tertentu
  Future<List<RekapBidangModel>> getRekapByPeriode({
    required int tahun,
    required int semesterStart, // bulan mulai (1 atau 7)
    required int semesterEnd,   // bulan selesai (6 atau 12)
  });
  
  // Totals
  Future<RekapSummaryModel> getSummary({required int tahun, required String semester});
}
```

**Step 2 — Buat `RekapBidangModel`:**
```dart
class RekapBidangModel {
  final String bidang;
  final int jumlahAnggota;
  final int targetIuran;   // jumlahAnggota * nominal per bulan * jumlah bulan
  final int terkumpul;     // SUM transaksi lunas
  // computed: sisa, persentase
}
```

**Step 3 — Query di `SupabaseUangKhasRepository`:**
```dart
Future<List<RekapBidangModel>> getRekapByPeriode({...}) async {
  // Query agregasi transaksi berdasarkan bidang + filter bulan/tahun
  final data = await _db.rpc('get_rekap_keuangan', params: {
    'p_tahun': tahun,
    'p_bulan_mulai': semesterStart,
    'p_bulan_selesai': semesterEnd,
  });
  return data.map<RekapBidangModel>(...).toList();
}
```

**Step 4 — Buat Supabase RPC function:**
```sql
CREATE OR REPLACE FUNCTION get_rekap_keuangan(
  p_tahun INT, p_bulan_mulai INT, p_bulan_selesai INT
)
RETURNS TABLE (bidang TEXT, target INT, terkumpul INT, jumlah_anggota INT)
LANGUAGE sql SECURITY DEFINER AS $$
  SELECT 
    COALESCE(b.nama, 'Umum') as bidang,
    COUNT(DISTINCT p.id) * (p_bulan_selesai - p_bulan_mulai + 1) * 50000 as target,
    COALESCE(SUM(tk.jumlah) FILTER (WHERE tk.status = 'lunas'), 0) as terkumpul,
    COUNT(DISTINCT p.id) as jumlah_anggota
  FROM profiles p
  LEFT JOIN kepengurusan kp ON kp.user_id = p.id
  LEFT JOIN jabatan j ON j.id = kp.jabatan_id
  LEFT JOIN bidang b ON b.id = j.bidang_id
  LEFT JOIN transaksi_khas tk ON tk.member_id = p.id
    AND EXTRACT(YEAR FROM tk.tanggal) = p_tahun
    AND EXTRACT(MONTH FROM tk.tanggal) BETWEEN p_bulan_mulai AND p_bulan_selesai
  WHERE p.role = 'member'
  GROUP BY b.nama
  ORDER BY b.nama;
$$;
```

**Step 5 — Export ke CSV/Excel:**
Gunakan package `csv` atau `excel`:
```dart
Future<void> _exportToCSV(List<RekapBidangModel> data) async {
  final rows = [
    ['Bidang', 'Target', 'Terkumpul', 'Sisa', 'Persentase'],
    ...data.map((r) => [r.bidang, r.targetIuran, r.terkumpul, r.sisa, '${(r.pct * 100).toStringAsFixed(1)}%']),
  ];
  final csv = const ListToCsvConverter().convert(rows);
  // save file via path_provider + share_plus
}
```

**Tabel Supabase terdampak:** `transaksi_khas`, `profiles`, `bidang`, `kepengurusan`
**Butuh Supabase RPC function baru.**

---

## 5. Checklist Supabase Migrations

| Migrasi | Untuk Screen | Status |
|---------|-------------|--------|
| — | Semua fase 1 | Tidak diperlukan |
| `ALTER TABLE profiles ADD COLUMN is_verified BOOLEAN DEFAULT false` | Verifikasi Anggota (Opsi B) | Perlu |
| `CREATE TABLE qr_session (...)` | QR Generator | Perlu |
| `CREATE TABLE audit_log (...)` | Audit Log | Perlu |
| `CREATE FUNCTION get_rekap_keuangan(...)` | Rekap Keuangan | Perlu |
| Pastikan `poin_entry.poin` support nilai negatif | Kelola Poin | Cek |

---

## 6. Dependencies Package Tambahan

| Package | Kegunaan | Screen |
|---------|---------|--------|
| `qr_flutter` | Render QR code dari token | QR Generator |
| `csv` | Export rekap ke CSV | Rekap Keuangan |
| `share_plus` | Bagikan file export | Rekap Keuangan |
| `path_provider` | Simpan file sementara | Rekap Keuangan |

Tambahkan ke `pubspec.yaml`:
```yaml
dependencies:
  qr_flutter: ^4.1.0
  csv: ^6.0.0
  share_plus: ^10.0.0
  path_provider: ^2.1.5
```

---

## 7. Urutan Pengerjaan (Rekomendasi)

```
MINGGU 1
├─ [FASE 1] Buat Pengumuman        ← 2-3 jam
├─ [FASE 1] Kelola Periode         ← 3-4 jam
├─ [FASE 2] Kelola Poin            ← 1 hari
└─ [FASE 2] Verifikasi Anggota     ← 1 hari

MINGGU 2
├─ [FASE 3] Skema Audit Log        ← 0.5 hari (migrasi + model + repo)
├─ [FASE 3] Inject logging tiap screen ← 1 hari
├─ [FASE 3] QR Generator           ← 1.5 hari (migrasi + repo + UI update)
└─ [FASE 3] Rekap Keuangan         ← 1.5 hari (RPC + agregasi + export)
```

**Total Estimasi: ~8–10 hari kerja**

---

## 8. Pola Penanganan Error (Standard)

Semua screen yang terintegrasi harus mengikuti pola ini:

```dart
// Di _submit() / action handler
try {
  setState(() => _loading = true);
  await repo.doSomething(...);
  if (!mounted) return;
  _showSuccessSnackBar('Berhasil!');
  context.pop(); // atau setState refresh
} catch (e) {
  if (!mounted) return;
  _showErrorSnackBar('Gagal: ${e.toString()}');
} finally {
  if (mounted) setState(() => _loading = false);
}
```

Dan untuk loading state di list view:
```dart
Consumer<XRepository>(
  builder: (context, repo, _) {
    if (repo.isLoading) return const Center(child: CircularProgressIndicator());
    if (repo.items.isEmpty) return _buildEmptyState();
    return ListView.builder(...);
  }
)
```

---

## 9. RLS (Row Level Security) yang Perlu Dikonfigurasi

| Tabel | Policy |
|-------|--------|
| `pengumuman` | INSERT: hanya `is_admin = true` |
| `audit_log` | SELECT: hanya admin; INSERT: semua authenticated |
| `qr_session` | INSERT/SELECT: hanya admin; token diverifikasi via service role |
| `poin_entry` | INSERT: hanya admin (untuk manual adjust) |
| `periode` | INSERT/UPDATE: hanya admin |

---

*Planning ini akan diupdate seiring progres implementasi.*
