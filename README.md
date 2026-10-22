# ENLife — All-in-One Daily Life & Productivity Hub

Aplikasi asisten produktivitas dan utilitas sehari-hari terlengkap berbasis **Flutter (Dart Native)** dengan tema **Tactile Obsidian**, performa tinggi, dan arsitektur *Offline-First* (100% data tersimpan privat di perangkat lokal Anda).

---

## 🌟 4 Modul Fitur Utama

### 1. 💰 Keuangan & Anggaran (Smart Expense Tracker)
- **Pencatatan Cepat:** Catat pemasukan dan pengeluaran harian dalam hitungan detik.
- **Visualisasi Anggaran:** Grafik pai dinamis (`fl_chart`) alokasi pengeluaran berdasarkan kategori (Makan, Transport, Belanja, Tagihan, Gaji, dll).
- **Format Rupiah Asli:** Format angka mata uang standar Indonesia (`Rp`).

### 2. ⚡ Fokus & Produktivitas (Habit Tracker & Pomodoro)
- **Pelacak Kebiasaan Harian:** Sistem centang kebiasaan harian dengan penghitung streak berturut-turut (*Daily Streak Counter*).
- **Daftar Tugas Berprioritas:** Pengelompokan tugas harian dengan tingkat prioritas (Tinggi, Sedang, Rendah).
- **Timer Fokus Pomodoro:** Siklus 25 menit fokus dan 5 menit istirahat dengan notifikasi visual.

### 3. 🛡️ Brankas Identitas & Dokumen (ID Vault)
- **Brankas Kartu Terenkripsi:** Simpan nomor identitas penting (KTP Elektronik, SIM, Rekening Bank, BPJS) secara aman di memori lokal.
- **Salin 1-Klik:** Salin nomor kartu langsung ke clipboard tanpa repot membuka dompet fisik.
- **Deteksi Kedaluwarsa Otomatis:** Peringatan visual dini saat masa berlaku dokumen (seperti SIM/STNK) mendekati 30 hari sebelum habis.

### 4. 🧰 Utilitas Cepat Sehari-hari (Daily Tools)
- **Kalkulator Split Bill:** Hitung pembagian tagihan makan bersama beserta pajak/service secara presisi per orang.
- **Kalkulator Diskon Belanja:** Hitung harga asli, persentase diskon %, dan nominal potongan harga instan.

---

## 🏗️ Struktur Arsitektur

```text
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart          # Palet Tactile Obsidian (#0B0D11, #12151C, #222631)
│   └── utils/
│       └── formatters.dart         # Format mata uang IDR & tanggal
├── data/
│   ├── models/                     # Transaction, Habit, Task, Vault Models
│   └── services/
│       └── storage_service.dart    # SharedPreferences Local Persistence (Offline-First)
├── providers/                      # State Management (Finance, Habit, Task, Vault)
└── ui/
    └── screens/
        ├── main_navigation_screen.dart # 4 Bottom Nav Tabs
        ├── dashboard_tab.dart          # Ringkasan harian & quick shortcuts
        ├── finance_tab.dart            # Manajer keuangan & grafik
        ├── habits_tasks_tab.dart       # Habit streak, to-do list, pomodoro
        └── vault_tools_tab.dart        # Brankas kartu & kalkulator cepat
```

---

## 🚀 Cara Menjalankan Proyek

Pastikan Flutter SDK telah terpasang:

```bash
# Masuk ke direktori proyek
cd D:\ProjekAntigravity\enlife

# Ambil seluruh dependensi
flutter pub get

# Jalankan di Chrome Web (atau Emulator / Device HP)
flutter run -d chrome

# Jalankan di Desktop Windows
flutter run -d windows

# Build APK Android siap pakai
flutter build apk --debug
```

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah lisensi resmi **Apache License 2.0** — lihat berkas [LICENSE](LICENSE) untuk informasi lebih lanjut.
