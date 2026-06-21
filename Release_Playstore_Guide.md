# 🚀 Panduan Rilis Aplikasi Flutter ke Google Play Store

Dokumen ini berisi panduan langkah demi langkah untuk merilis aplikasi **Policy Centrepoint** ke Google Play Store, mulai dari penandatanganan aplikasi (app signing) hingga pengunggahan ke Google Play Console.

---

## 📋 Daftar Langkah Utama
1. [Membuat Keystore (Kunci Penandatanganan)](#1-membuat-keystore-kunci-penandatanganan)
2. [Mengonfigurasi Gradle untuk Release Signing](#2-mengonfigurasi-gradle-untuk-release-signing)
3. [Memperbarui Versi Aplikasi](#3-memperbarui-versi-aplikasi)
4. [Membangun App Bundle (.aab)](#4-membangun-app-bundle-aab)
5. [Mempersiapkan Google Play Console](#5-mempersiapkan-google-play-console)

---

## 1. Membuat Keystore (Kunci Penandatanganan)
Keystore adalah file sertifikat digital keamanan yang digunakan untuk menandatangani aplikasi Android agar dapat diidentifikasi oleh Google Play.

Buka terminal dan jalankan perintah berikut untuk membuat file keystore baru:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> [!WARNING]
> - Simpan file `upload-keystore.jks` ini dengan aman. Jangan pernah menghapusnya karena file ini diperlukan untuk mengunggah pembaruan (update) aplikasi di masa mendatang.
> - Tambahkan file keystore ini ke `.gitignore` agar tidak ter-push ke repository publik.

---

## 2. Mengonfigurasi Gradle untuk Release Signing
Untuk mengaitkan keystore dengan build sistem Android, kita akan membuat file konfigurasi kredensial lokal dan memperbarui Gradle.

### Langkah A: Buat File Kredensial Lokasi
Buat file baru bernama `key.properties` di dalam direktori `android/` (misalnya: `android/key.properties`) dan isi dengan detail berikut:

```properties
storePassword=password_keystore_anda
keyPassword=password_kunci_anda
keyAlias=upload
storeFile=upload-keystore.jks
```

> [!IMPORTANT]
> Pastikan file `key.properties` terdaftar di dalam file `.gitignore` proyek Anda agar kredensial Anda tidak bocor.

### Langkah B: Perbarui `android/app/build.gradle.kts`
Karena proyek Anda menggunakan Kotlin DSL (`.gradle.kts`), modifikasi file [`build.gradle.kts`](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/android/app/build.gradle.kts) untuk membaca file `key.properties` dan menerapkan konfigurasi penandatanganan rilis.

Muat properti kunci di bagian paling atas file (sebelum blok `android {`):

```kotlin
import java.io.FileInputStream
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Kemudian tambahkan konfigurasi `signingConfigs` dan ubah `signingConfig` pada `release` build type di dalam blok `android {`:

```kotlin
android {
    // ... namespace & compileSdk

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as? String
        }
    }

    buildTypes {
        release {
            // Menggunakan signing config release yang sudah dibuat di atas
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

---

## 3. Memperbarui Versi Aplikasi
Sebelum melakukan build, sesuaikan versi aplikasi di file [`pubspec.yaml`](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/pubspec.yaml):

```yaml
version: 1.0.0+1
```
* **`1.0.0`** (Version Name): Versi yang terlihat oleh pengguna di toko aplikasi.
* **`1`** (Version Code): Nomor versi internal. Setiap kali Anda melakukan update ke Play Store, nomor ini **wajib** dinaikkan secara berurutan (misal: `1.0.0+2`, `1.0.1+3`, dsb).

---

## 4. Membangun App Bundle (.aab)
Google Play Store mewajibkan pengunggahan aplikasi menggunakan format Android App Bundle (`.aab`) alih-alih `.apk` karena ukurannya yang lebih efisien dan teroptimasi secara dinamis untuk perangkat pengguna.

Jalankan perintah berikut di direktori utama proyek Flutter Anda:

```bash
flutter build appbundle --release
```

Setelah build selesai, file bundle rilis akan berada di lokasi:
`build/app/outputs/bundle/release/app-release.aab`

---

## 5. Mempersiapkan Google Play Console
1. **Daftar Akun Developer:** Masuk ke [Google Play Console](https://play.google.com/console/signup) dan daftarkan akun (biaya pendaftaran sekali bayar senilai $25).
2. **Buat Aplikasi Baru:** Klik **Create App**, lalu lengkapi informasi dasar seperti nama aplikasi, bahasa utama, jenis aplikasi (App/Game), dan metode harga (Free/Paid).
3. **Lengkapi Tugas Dasbor (Set up your app):**
   * Masukkan URL Kebijakan Privasi (Privacy Policy).
   * Konfigurasi akses aplikasi (apakah memerlukan login/kredensial khusus).
   * Isi kuesioner Rating Konten (Content Rating).
   * Tentukan Target Audiens & Konten (Target Audience).
   * Masukkan kategori aplikasi dan detail kontak.
4. **Desain Main Store Listing:**
   * Tulis deskripsi singkat & deskripsi lengkap aplikasi.
   * Unggah Ikon Aplikasi (ukuran 512x512 piksel, format PNG).
   * Unggah Feature Graphic (ukuran 1024x500 piksel, format PNG).
   * Unggah tangkapan layar (screenshots) aplikasi untuk HP, tablet 7-inci, dan tablet 10-inci.
5. **Unggah File Rilis:**
   * Di menu navigasi kiri, pilih **Production** atau **Testing** (direkomendasikan mulai dari *Internal Testing* terlebih dahulu).
   * Buat rilis baru (Create new release).
   * Aktifkan fitur **Play App Signing** jika diminta.
   * Unggah file `app-release.aab` yang telah di-build sebelumnya.
   * Isi catatan rilis (Release Notes) yang menjelaskan pembaruan pada versi ini.
   * Klik **Save and Review Release**, lalu klik **Start Rollout** untuk mengirimkan aplikasi ke Google agar ditinjau (review).
