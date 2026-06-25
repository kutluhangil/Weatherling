# Yayın Kontrol Listesi (Android / Google Play)

Master Plan §17. Her sürümde tekrar gözden geçir.

## Hedef sürümler (Haziran 2026)

- `targetSdk = 36` (Android 16) — 31 Ağu 2026'dan sonra yeni uygulamalar için zorunlu.
- `minSdk = 24` (Android 7) — geniş kapsam.
- **AAB** (App Bundle) zorunlu; tek APK değil.
- **Play App Signing** zorunlu: upload key üret, Google imzalamayı yönetir.

## Export ön koşulları (yerel makine)

- [ ] JDK 17 (Godot 4.7 Android build için). ⚠️ Şu an makinede JDK 25 var — Android
      Gradle build JDK 17 ister; `JAVA_HOME`'u 17'ye ayarla veya 17 kur.
- [ ] Android SDK + Build Tools + Platform Tools (+ gerekirse NDK).
- [ ] Godot → Editor → **Manage Export Templates** indir.
- [ ] Godot → Project → **Install Android Build Template** (gradle build için).
- [ ] `export_presets.cfg` zaten hazır: paket `com.rebuildrebreak.weatherling`,
      min24/target36, izinler INTERNET + ACCESS_COARSE_LOCATION + POST_NOTIFICATIONS.

## İmzalama

- [ ] `keytool` ile upload keystore üret. **Yedekle** (kaybolursa güncelleme yok).
- [ ] Keystore repoya **asla** girmez (`.gitignore` korur).

## Mağaza listesi

- [ ] İkon 512×512 (adaptive: foreground+background) · Feature graphic 1024×500.
- [ ] ≥2 telefon ekran görüntüsü (yağmurlu sahne, gece uyuyan yaratık, besleme).
- [ ] Kısa açıklama (≤80) + tam açıklama (≤4000) · TR + EN · (opsiyonel) cozy fragman.
- [ ] Kategori: Casual / Simulation.

## Politika & uyum

- [ ] İçerik derecelendirme (IARC) → muhtemelen "Herkes".
- [ ] Data Safety formu (konum: yalnızca işlev, paylaşılmıyor; e-posta: hesap).
- [ ] Gizlilik Politikası URL'si (konum/hesap verisi olduğu için zorunlu).
- [ ] Hedef kitle & içerik; çocuk verisi yaklaşımı (bkz. DECISIONS.md #7).
- [ ] App access: incelemeciye gerekirse test hesabı (misafir mod bunu kısmen çözer).

## Yayın yolu

Internal → **Closed test (kişisel hesap: ≥12 kişi / 14 gün kesintisiz)** →
production başvuru/anket → (open) → Production.
⚠️ Test kullanıcısı satan servis / emülatör çiftliği = hesap kapatma riski. Gerçek kişi topla.

## Son kontrol

- [ ] Pre-launch report (Play Console) incele · ANR/çökme (vitals) temiz.
- [ ] İzin gerekçeleri ve gizlilik formu tutarlı.
