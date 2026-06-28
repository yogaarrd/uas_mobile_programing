

---

# PRODUCT REQUIREMENTS DOCUMENT (PRD)

**Nama Produk:** Moreps
**Versi Dokumen:** 1.0
**Platform:** Mobile (Android & iOS)

---

## 1. Ringkasan Produk (Product Overview)

**Moreps** adalah aplikasi pelacak kebugaran (*workout tracker*) komprehensif yang dirancang untuk membantu pengguna mencatat sesi angkat beban, melacak perkembangan kekuatan fisik, dan memonitor perubahan berat badan. Aplikasi ini menonjolkan fitur deteksi *Personal Record* (PR) otomatis dan sistem analitik visual berbasis grafik untuk memotivasi pengguna mencapai target kebugaran mereka.

## 2. Tujuan & Sasaran (Objectives)

* **Akurasi Pencatatan:** Menyediakan antarmuka yang cepat dan intuitif bagi pengguna untuk mencatat set, repetisi, beban, dan waktu istirahat saat berada di gym.


* **Analisis Progresif:** Memvisualisasikan data latihan mentah menjadi metrik yang mudah dipahami (Volume Total, Durasi, Konsistensi) menggunakan grafik interaktif.


* **Retensi Pengguna:** Mendorong konsistensi latihan melalui lencana pencapaian (PR) dan layar transisi motivasional.



---

## 3. Kebutuhan Fungsional (Functional Requirements)

### 3.1. Autentikasi & Onboarding (User Access)

* **Sign Up & Sign In:** Pengguna dapat mendaftar dan masuk menggunakan Email/Password atau Google OAuth.


* **Smart Session Check:** Pengecekan otomatis di *Splash Screen* untuk mengarahkan pengguna ke *Home* (jika sudah memiliki profil) atau *Onboarding* (jika baru mendaftar).


* **Onboarding Profil:** Pengumpulan data awal pengguna meliputi Nama Lengkap, Tanggal Lahir, Berat Badan (kg), Tinggi Badan (cm), dan *Fitness Goal* (Strength, Hypertrophy, Weight Loss, General Fitness).



### 3.2. Dashboard Utama (Home)

* **Premium Greeting Card:** *Header* interaktif dengan sapaan pintar yang menyesuaikan jam (Pagi/Siang/Malam), tanggal berbahasa Indonesia, dan teks tebal untuk nama pengguna.


* **Workout Templates:** Daftar *template* latihan yang bisa dibuat, diedit, atau dihapus oleh pengguna. Menampilkan estimasi durasi dan target grup otot.


* **Library:** Pencarian direktori gerakan latihan dengan filter *ChoiceChips* berdasarkan grup otot (Chest, Back, Legs, dll).



### 3.3. Manajemen Sesi Latihan (Active Session & Builder)

* **Workout Builder:** Fitur untuk merakit *template* latihan dengan kemampuan *drag-and-drop* (reorder), penambahan set, dan *toggle* konversi visual metrik KG ke LBS.


* **Active Tracker:** Halaman pencatatan *real-time* saat berolahraga yang mencakup:
* *Timer* durasi total latihan.


* Pencatatan aktual untuk Repetisi dan Beban pada setiap set.


* Penambahan latihan ekstra (*Spontaneous Exercise*) di tengah sesi.




* **Rest Timer & Motivasi:** Penghitung waktu mundur istirahat antar set yang dilengkapi notifikasi sistem dan getaran saat waktu habis. Layar transisi dinamis yang menampilkan kutipan motivasi acak.


* **Session Summary:** Halaman ringkasan pasca-latihan yang menampilkan total volume, durasi, jumlah set selesai, dan *highlight* jika ada *Personal Record* (PR) baru yang terpecahkan.



### 3.4. Riwayat Latihan (History)

* **Workout Calendar:** Kalender visual (TableCalendar) dengan *marker* titik neon pada tanggal di mana pengguna melakukan latihan.


* **Infinite Scroll History:** Daftar riwayat sesi latihan dengan sistem *pagination* (memuat data tambahan saat di-*scroll* ke bawah) untuk menjaga performa aplikasi.


* **Detail Sesi:** Halaman rincian untuk melihat kembali daftar gerakan, set, repetisi, dan beban pada sesi di masa lalu.



### 3.5. Pelacakan Progres (Progress & Analytics)

* **Statistik Keseluruhan:** *Overview* metrik seumur hidup pengguna (Total Sesi, Volume Angkatan, Total Durasi, Konsistensi per Minggu).


* **Body Weight Tracker:** Pencatatan fluktuasi berat badan (dengan opsi penambahan catatan teks) yang divisualisasikan menggunakan grafik garis (*fl_chart*) dengan filter rentang waktu 1 Bulan, 3 Bulan, dan Semua.


* **Exercise PR Chart:** Halaman khusus per gerakan latihan yang menampilkan *banner* *Personal Record* tertinggi dan grafik lintasan beban maksimal untuk gerakan tersebut. Penyorotan warna (Amber) pada tabel historis jika set tersebut memecahkan rekor.



### 3.6. Profil Pengguna (Profile)

* **Manajemen Akun:** Pengguna dapat memperbarui metrik fisik (Berat/Tinggi), *Goal* kebugaran, serta mengunggah foto profil (Avatar).


* **Kalkulator BMI:** Perhitungan otomatis *Body Mass Index* berdasarkan tinggi dan berat badan terkini.



---

## 4. Kebutuhan Non-Fungsional (Non-Functional Requirements)

* **Arsitektur Kode & Maintainability:** Menggunakan *Repository/Service Pattern* untuk memisahkan logika bisnis dan akses *database* dari UI, memastikan penulisan kode yang sangat bersih, dapat digunakan kembali (*reusable*), dan terstruktur untuk skalabilitas jangka panjang.


* **State Management:** Mengimplementasikan **Riverpod** secara penuh (*NotifierProvider*, *FutureProvider*, *AsyncNotifier*) untuk memastikan *state* UI reaktif dan terisolasi dengan baik dari *business logic*.


* **Performa Navigasi:** Menggunakan **GoRouter** untuk perutean deklaratif yang mendukung *deep linking* (penting untuk autentikasi OAuth).


* **Desain UI/UX (High Contrast):** Menggunakan palet warna *Dark Mode* (`#010102`) dengan aksen hijau neon (`#CFFF4B`) dan elemen *Glassmorphism* transparan untuk memberikan nuansa premium dan keterbacaan tinggi di lingkungan *gym*.



---

## 5. Tumpukan Teknologi (Tech Stack)

* **Frontend Mobile:** Flutter (Dart).


* **Backend as a Service (BaaS):** Supabase (PostgreSQL Database, Authentication, Storage untuk Avatar).


* **Penyimpanan Lingkungan:** `flutter_dotenv` untuk keamanan API Key.


* **Komponen UI Pihak Ketiga:** `fl_chart` (Grafik), `table_calendar` (Kalender Riwayat).


* **Interaksi Sistem:** `flutter_local_notifications` & `vibration` (Manajemen *Rest Timer*).