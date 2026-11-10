# Panduan Lengkap Pasang Flutter di Windows 10

Untuk: Mark — laptop Windows 10, target aplikasi Android (aplikasi guru myschool)
Versi acuan saat panduan ini ditulis: **Flutter 3.47.9 stable** (Dart 3.13.7).
Selalu unduh rilis **stable terbaru** dari situs resmi; nomor persisnya boleh berbeda.

## Gambaran: tiga hal yang dipasang

1. **Flutter SDK** — peralatan utama (termasuk bahasa Dart, tidak perlu pasang Dart terpisah).
2. **Android Studio** — bukan untuk menulis kode, tapi untuk mendapatkan **Android SDK**
   (alat build Android) dan **emulator**. Wajib ada walau tidak dipakai sehari-hari.
3. **VS Code** — editor tempat kita menulis kode Flutter (lebih ringan dari Android Studio).

Git sudah terpasang di laptopmu (selama ini dipakai untuk proyek Laravel) — tinggal dicek.
Siapkan ruang kosong sekitar **15 GB** (Flutter ±1,5 GB, Android Studio + SDK + emulator bisa 10 GB lebih).
Unduhan besar semua; lakukan saat internet stabil.

---

## Langkah 1 — Cek Git

Buka Command Prompt atau PowerShell baru, jalankan:

```bat
git --version
```

Bila muncul nomor versi, lanjut. (Kamu pasti sudah punya dari pekerjaan Laravel.)

## Langkah 2 — Pasang Flutter SDK

1. Buka halaman resmi **https://docs.flutter.dev/get-started/install/windows**,
   unduh berkas `flutter_windows_<versi>-stable.zip`.
2. Ekstrak ZIP itu ke folder **tanpa spasi dan bukan Program Files**. Saran:
   **`D:\flutter`** (satu drive dengan proyekmu). Hasilnya harus ada folder
   `D:\flutter\bin` berisi `flutter.bat`. Jangan ekstrak ke `C:\Program Files`.
3. Daftarkan ke PATH:
   - Tekan tombol Windows, ketik **"environment variables"**, pilih
     *Edit environment variables for your account*.
   - Pada daftar **User variables**, pilih **Path** → **Edit** → **New** →
     isi `D:\flutter\bin` → OK semua jendela.
4. **Tutup dan buka terminal baru** (PATH hanya dibaca terminal yang baru dibuka), lalu:

```bat
flutter --version
```

Muncul versi Flutter + Dart = SDK terpasang benar. Perintah pertama ini juga
mengunduh kelengkapan Dart; tunggu sampai selesai.

## Langkah 3 — Pasang Android Studio + Android SDK

1. Unduh **Android Studio** dari **https://developer.android.com/studio**, pasang
   dengan pilihan bawaan (pastikan komponen **Android Virtual Device** ikut tercentang).
2. Jalankan Android Studio pertama kali — wizard *Setup* akan mengunduh **Android SDK**
   secara otomatis. Ikuti sampai selesai (ini unduhan besar kedua).
3. Masih di Android Studio: menu **More Actions → SDK Manager** (atau
   *File → Settings → Languages & Frameworks → Android SDK*):
   - Tab **SDK Platforms**: pastikan ada minimal satu Android terbaru tercentang.
   - Tab **SDK Tools**: pastikan tercentang **Android SDK Build-Tools**,
     **Android SDK Platform-Tools**, dan **Android SDK Command-line Tools (latest)**
     — yang terakhir ini sering belum tercentang dan menjadi penyebab error
     "cmdline-tools not found" belakangan. Terapkan (**Apply**) bila ada perubahan.
4. Kembali ke terminal, terima semua lisensi Android:

```bat
flutter doctor --android-licenses
```

Jawab `y` pada setiap pertanyaan sampai habis.

## Langkah 4 — Pasang VS Code + ekstensi Flutter

1. Pasang **VS Code** dari **https://code.visualstudio.com** bila belum ada.
2. Di VS Code, buka panel **Extensions** (Ctrl+Shift+X), cari **Flutter**
   (oleh Dart Code) → **Install**. Ekstensi Dart ikut terpasang otomatis.
3. Aktifkan **Developer Mode** Windows (dibutuhkan Flutter untuk symlink plugin):
   *Settings → Update & Security → For developers → Developer Mode* → **On**.

## Langkah 5 — Pemeriksaan dokter: `flutter doctor`

Di terminal:

```bat
flutter doctor
```

Target hasil untuk kebutuhan kita:

- `[✓] Flutter` — wajib.
- `[✓] Android toolchain` — wajib (dari Langkah 3 + lisensi).
- `[✓] VS Code` — wajib.
- `[!] Visual Studio` / aplikasi desktop Windows — **abaikan**; itu hanya untuk
  membuat aplikasi Windows, target kita Android.
- `[✓] Connected device` — muncul setelah emulator/HP disiapkan (Langkah 6).

Bila ada `[✗]` pada Android toolchain, baca baris alasannya — hampir selalu soal
lisensi (ulangi perintah lisensi) atau Command-line Tools (ulangi Langkah 3.3).

## Langkah 6 — Uji coba pertama (membuktikan instalasi beres)

Pilih salah satu alat uji:

**A. Emulator (tanpa HP):** di Android Studio buka **More Actions → Virtual
Device Manager → Create device** → pilih ponsel Pixel mana pun → unduh *system
image* terbaru yang ditawarkan → **Finish**, lalu jalankan (tombol ▶).
Emulator pertama kali menyala memang lambat. Bila sangat lambat/gagal, biasanya
virtualisasi (VT-x) belum aktif di BIOS — alternatif termudah: pakai HP fisik.

**B. HP Android fisik:** di HP, buka *Pengaturan → Tentang ponsel* → ketuk
**Nomor build** 7 kali sampai "Mode pengembang aktif" → kembali ke
*Opsi pengembang* → aktifkan **USB debugging** → colokkan kabel USB →
izinkan sidik jari komputer bila ditanya.

Cek alat terdeteksi, lalu buat & jalankan aplikasi contoh:

```bat
flutter devices
cd D:\My-Project
flutter create proyek_uji
cd proyek_uji
flutter run
```

Build pertama lama (Gradle mengunduh banyak hal) — itu normal. Bila aplikasi
contoh penghitung (counter) tampil di emulator/HP, **instalasi selesai**.
Folder `proyek_uji` boleh dihapus sesudahnya.

## Langkah 7 — Siapkan proyek aplikasi sekolah kita

1. Di GitHub, buat repo baru kosong bernama **`myschool-mobile`**
   (jangan centang README/gitignore — biarkan benar-benar kosong).
2. Di terminal:

```bat
cd D:\My-Project
git clone https://github.com/masozin/myschool-mobile.git
cd myschool-mobile
flutter create --project-name myschool_mobile --org id.my.ozinsq .
flutter run
git add .
git commit -m "Kerangka awal aplikasi myschool mobile"
git push -u origin main
```

(`--org id.my.ozinsq` berasal dari domainmu ozinsq.my.id dibalik — ini menjadi
awalan identitas aplikasi Android-nya. Nama proyek memakai garis bawah:
`myschool_mobile`.)

Sampai di sini berhenti dulu — setelah repo ini ter-push, **kode aplikasinya
(login, presensi, data siswa) kutuliskan lewat patch seperti biasa**,
kamu tinggal apply & run.

## Masalah yang paling sering muncul

| Gejala | Obat |
|---|---|
| `'flutter' is not recognized` | PATH belum terbaca — tutup semua terminal, buka yang baru. Bila tetap, cek ulang isi Path di Langkah 2.3 (harus persis folder `bin`). |
| `Android license status unknown` | Jalankan lagi `flutter doctor --android-licenses`, jawab `y` sampai habis. |
| `cmdline-tools component is missing` | Pasang **Android SDK Command-line Tools (latest)** lewat SDK Manager (Langkah 3.3). |
| Emulator gagal/lambat sekali | Coba HP fisik dulu (Langkah 6B); atau aktifkan virtualisasi VT-x di BIOS. |
| Build pertama terasa menggantung | Normal — Gradle + SDK mengunduh banyak berkas. Tunggu; jangan tutup. |
| Antivirus memperlambat semua | Tambahkan pengecualian untuk folder `D:\flutter` dan folder proyek. |

## Yang perlu kamu laporkan ke Qeenan setelah selesai

Tempelkan hasil dua perintah ini ke chat:

```bat
flutter --version
flutter doctor
```

Dari situ Qeenan bisa memastikan peralatanmu lengkap sebelum kode aplikasi
sekolah mulai ditulis.
