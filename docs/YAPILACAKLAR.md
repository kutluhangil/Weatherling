# Weatherling — Yayına Kadar Senin Yapacakların (Adım Adım)

> Bu dosya **senin elinle** yapman gereken her şeyi sırayla anlatır. Kod tarafı büyük
> ölçüde hazır; burada yazılanlar makinende / Play Console'da / Supabase'de yapılacak işler.
> Her kutuyu sırayla işaretle. Takıldığın maddenin yanındaki dosya/komuta bak.

İlgili hazır dokümanlar: `RELEASE_CHECKLIST.md`, `SECURITY.md`, `DATA_SAFETY.md`,
`STORE_LISTING.md`, `PRIVACY_POLICY.md`, `SUPABASE.md`, `art/ui/store/README.md`.

Mevcut durum (kod): targetSdk=36, minSdk=24, AAB, izinler ve servisler hazır.
Eksikler hep **dış ortam** kaynaklı: ortam kurulumu, imzalama, görseller, Console, test kullanıcıları.

---

## FAZ A — Geliştirme Ortamı Kurulumu (bir kez)

### A1. JDK 17 kur (ZORUNLU)
Godot 4.7 Android Gradle build **JDK 17** ister. Makinende şu an JDK 25 var → çalışmaz.
- [ ] JDK 17 kur (Temurin/Adoptium önerilir): https://adoptium.net → Temurin 17 (LTS), macOS arm64.
- [ ] Kurulumu doğrula:
  ```sh
  /usr/libexec/java_home -V        # 17 listede mi?
  /usr/libexec/java_home -v 17     # 17'nin yolunu verir
  ```
- [ ] Bu oturumda 17'yi aktif et (Godot'u bu terminalden açarsan):
  ```sh
  export JAVA_HOME=$(/usr/libexec/java_home -v 17)
  java -version                    # "17.x" yazmalı
  ```

### A2. Android SDK kur
En kolay yol Android Studio; sadece SDK de olur.
- [ ] Android Studio kur: https://developer.android.com/studio  → aç → SDK Manager.
- [ ] SDK Manager'da kur:
  - [ ] **Android SDK Platform 36** (Android 16)
  - [ ] **Android SDK Build-Tools** (en güncel 36.x)
  - [ ] **Android SDK Platform-Tools** (adb için)
  - [ ] **Android SDK Command-line Tools (latest)**
- [ ] SDK yolunu not al (genelde `~/Library/Android/sdk`).

### A3. Godot 4.7'yi hazırla
- [ ] Godot 4.7 **stable** indir: https://godotengine.org/download  (standart sürüm, .NET değil).
- [ ] Godot'u aç → projeyi seç: `/Volumes/ProjectVault/Weatherling/project.godot`.
- [ ] **Export Templates** indir: Editor → **Manage Export Templates** → Download and Install.
- [ ] **Android Build Template** kur: Project → **Install Android Build Template**
      (gradle build için; `export_presets.cfg` `use_gradle_build=true`).

### A4. Godot'a SDK/JDK yollarını tanıt
Editor → **Editor Settings** → Export → Android:
- [ ] **Android SDK Path** = A2'deki yol (`~/Library/Android/sdk`).
- [ ] **Java SDK Path** (varsa) = `export JAVA_HOME` çıktısındaki JDK 17 yolu.
- [ ] **Debug Keystore**: yoksa Godot "Create" ile otomatik üretebilir (sadece test için).

> ✅ Faz A bitti sayılır: aşağıdaki A5 cihaz testi çalışınca.

### A5. Boş doğrulama (cihazda "çalışıyor")
- [ ] Android telefonu USB ile bağla → Geliştirici Seçenekleri → **USB Hata Ayıklama** açık.
- [ ] `adb devices` → cihaz "device" olarak görünmeli.
- [ ] Godot editöründe sağ üst **One-click deploy** (Android simgesi) → telefonda açılsın.
- [ ] Uygulama açıldı, onboarding göründü → Faz A tamam. 🎉

---

## FAZ B — Yerel Doğrulama + Testler

### B1. Testleri yerelde koş
- [ ] Terminalde Godot binary'sini bul (macOS app içi): örn.
  ```sh
  GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
  cd /Volumes/ProjectVault/Weatherling
  "$GODOT" --headless --import          # ilk sefer .godot cache kurar
  "$GODOT" --headless -s tests/run_tests.gd
  ```
- [ ] Çıktının sonunda `0 failed` görmelisin. Fail varsa bana söyle.

### B2. CI'ı doğrula (GitHub'a push'ladıysan)
- [ ] GitHub → repo → **Actions** sekmesi → `CI` workflow yeşil mi?
- [ ] Kırmızıysa: çoğu zaman Godot indirme linkindeki sürüm etiketi. `.github/workflows/ci.yml`
      içindeki `GODOT_VERSION` değerini gerçek release tag'iyle eşle (örn. `4.7-stable`).

### B3. Elle duman testi (cihazda/editörde)
Sırayla dene, hepsi çalışmalı:
- [ ] Onboarding: isim → yaş → inanç(atla) → şehir gir → Home'a geç.
- [ ] Yaratığa dokun → kalpler + zıplama (FPS kısa süre 60'a çıkar).
- [ ] Menü → **Günlük** açılır (ilk gün notu görünür).
- [ ] Menü → **Başarımlar** açılır ("İlk Gün" açık olmalı).
- [ ] Ayarlar → **Hareket azaltma** aç → yaratığın nefesi durur (pil testi).
- [ ] Uygulamayı arka plana al → geri getir → çökme yok, kayıt duruyor.
- [ ] Çentikli telefon varsa: üst rozet/alt bar çentik/nav çubuğu altında kalmıyor (safe-area).

---

## FAZ C — Store Görselleri (PNG + Ekran Görüntüsü)

### C1. SVG → PNG raster
- [ ] `librsvg` kur: `brew install librsvg`
- [ ] PNG klasörü aç ve üret:
  ```sh
  cd /Volumes/ProjectVault/Weatherling/art/ui/store
  mkdir -p png
  rsvg-convert -w 512  -h 512  icon_play_512.svg   -o png/icon_512.png
  rsvg-convert -w 432  -h 432  icon_foreground.svg -o png/ic_fg_432.png
  rsvg-convert -w 432  -h 432  icon_background.svg -o png/ic_bg_432.png
  rsvg-convert -w 432  -h 432  icon_monochrome.svg -o png/ic_mono_432.png
  rsvg-convert -w 192  -h 192  icon_play_512.svg   -o png/ic_launcher_192.png
  rsvg-convert -w 1024 -h 500  feature_graphic.svg -o png/feature_1024x500.png
  ```
- [ ] `png/` içindeki dosyaları aç, gözle kontrol et (yaratık ortada, kırpılmıyor mu?).
- [ ] Beğenmezsen SVG'leri düzenlememi iste (renk/şekil/konum).

### C2. Ekran görüntüleri (en az 2, öneri 4)
- [ ] Telefonda güzel anları yakala (güç+ses-kıs tuşu). Önerilen kareler:
  - [ ] Yağmurlu/karlı sahne (gerçek hava denk gelmezse Ayarlar'dan manuel şehir gir).
  - [ ] Gece uyuyan yaratık.
  - [ ] Besleme paneli açık.
  - [ ] Günlük veya Başarımlar paneli.
- [ ] Çözünürlük portre, en az 1080×1920. Telefon screenshot'ı zaten uygun.
- [ ] (Opsiyonel) 7"/10" tablet görüntüsü = mağaza kalite puanı artışı.

---

## FAZ D — İmzalama (Upload Keystore) ⚠️ KRİTİK

> Bu keystore'u **kaybedersen uygulamanı bir daha güncelleyemezsin.** Yedekle.

### D1. Upload keystore üret
- [ ] Repo DIŞINDA güvenli bir klasörde üret (repoya asla girmez):
  ```sh
  cd ~/keys   # repo dışı bir yer
  keytool -genkey -v -keystore weatherling-upload.jks \
    -alias upload -keyalg RSA -keysize 2048 -validity 10000
  ```
- [ ] Sorulan parolaları ve "alias" (upload) bilgisini bir parola yöneticisine kaydet.
- [ ] Keystore dosyasını **2 ayrı yere yedekle** (parola yöneticisi + şifreli bulut/USB).

### D2. Godot'a release imzalamayı tanıt
Project → Export → **Android** preset → Release bölümü:
- [ ] **Release** keystore = `~/keys/weatherling-upload.jks`
- [ ] **Release User** = `upload`
- [ ] Parolayı Godot sorduğunda gir. Godot bunu `export_credentials.cfg` dosyasına yazar
      (bu dosya `.gitignore`'da → repoya girmez, doğru davranış).
- [ ] `export_presets.cfg` içine parola YAZMA (o dosya commit ediliyor).

---

## FAZ E — İkonları Bağla + AAB Üret

### E1. Launcher ikonlarını export_presets'e bağla
- [ ] C1'deki PNG'leri `res://art/ui/store/png/` altında bırak (zaten orada).
- [ ] `export_presets.cfg` → `[preset.0.options]` içinde şu 4 satırı doldur:
  ```
  launcher_icons/main_192x192="res://art/ui/store/png/ic_launcher_192.png"
  launcher_icons/adaptive_foreground_432x432="res://art/ui/store/png/ic_fg_432.png"
  launcher_icons/adaptive_background_432x432="res://art/ui/store/png/ic_bg_432.png"
  launcher_icons/adaptive_monochrome_432x432="res://art/ui/store/png/ic_mono_432.png"
  ```
  > Not: PNG'ler `art/ui/store/png/` `.gitignore`'da. Build yapan makinede dosyalar
  > fiziksel olarak bulunmalı (C1'i o makinede çalıştır). Yol verip dosya yoksa export HATA verir.

### E2. Sürüm numarasını ayarla
İlk yayın için `export_presets.cfg`:
- [ ] `version/code=1`  (her yeni yüklemede +1 artır)
- [ ] `version/name="1.0.0"`  (kullanıcının gördüğü sürüm)
- [ ] `project.godot` → `config/version` da `1.0.0` yap (tutarlılık).

### E3. AAB üret
- [ ] Editörden: Project → Export → Android → **Export Project** → `build/weatherling.aab`.
      "Export With Debug" KAPALI olsun (release).
- [ ] Veya terminalden:
  ```sh
  export JAVA_HOME=$(/usr/libexec/java_home -v 17)
  "$GODOT" --headless --export-release "Android" build/weatherling.aab
  ```
- [ ] `build/weatherling.aab` oluştu mu? (klasör `.gitignore`'da, normal.)

---

## FAZ F — (Opsiyonel) Supabase Bulut Kayıt + Giriş

> Atlanabilir: uygulama **misafir modda tam çalışır** (yerel şifreli kayıt). Bulut yedek
> istersen bunu yap. İncelemeci için misafir mod yeterli olduğundan yayını bloke ETMEZ.

### F1. Supabase projesi
- [ ] https://supabase.com → yeni proje aç (ücretsiz tier yeter).
- [ ] Project Settings → API → **Project URL** ve **anon public key**'i kopyala.

### F2. Şemayı uygula (RLS dahil)
- [ ] Supabase → SQL Editor → `supabase/migrations/0001_init.sql` içeriğini yapıştır → çalıştır.
- [ ] `SUPABASE.md`'deki adımları izle (RLS politikaları + `delete_me` RPC).
- [ ] RLS testi: iki farklı hesapla giriş yap, biri diğerinin satırını GÖREMEMELI.

### F3. Anahtarları koda gir
- [ ] `autoload/auth_service.gd`:
  ```gdscript
  const SUPABASE_URL := "https://xxxx.supabase.co"   # senin URL
  const SUPABASE_ANON := "eyJ..."                     # anon public key
  ```
  > Bunlar **public** (RLS korur), repoya girmesi güvenlik açığı değil. Yine de istersen
  > gizli tutmak için bana söyle, environment/edge-function yöntemine çeviririm.

### F4. Google ile giriş (deep link) — istersen
- [ ] Supabase → Auth → Providers → Google'ı aç (Google Cloud OAuth client gerekir).
- [ ] Redirect URL'e deep link ekle: `weatherling://auth-callback`.
- [ ] `SUPABASE.md`'deki Android App Link / custom scheme adımları (build sırasında doğrula).
- [ ] Bu kısım eklenti/manifest işi — takılırsan bana söyle, `auth_service.gd` tarafını bağlarım.

---

## FAZ G — Gizlilik Politikası URL'si (ZORUNLU)

Play, konum + hesap verisi olduğu için **canlı bir URL** ister.
- [ ] `docs/PRIVACY_POLICY.md` içindeki şirket/iletişim alanlarını doldur.
- [ ] Bir yerde yayınla (herhangi biri):
  - [ ] GitHub Pages (ücretsiz), veya
  - [ ] ReBuildReBreak alan adında basit bir sayfa, veya
  - [ ] Notion/Google Sites public sayfa.
- [ ] Çıkan URL'i not al → Console'da kullanacaksın.

---

## FAZ H — Google Play Console Kurulumu

### H1. Geliştirici hesabı
- [ ] https://play.google.com/console → kayıt ($25 tek seferlik).
- [ ] ⚠️ **Kişisel hesap** açtıysan: production öncesi **12 test kullanıcısı / 14 gün kapalı test**
      zorunlu (13 Kas 2023 sonrası kişisel hesaplar). Organizasyon hesabı muaf. (Faz J).

### H2. Uygulama oluştur
- [ ] Create app → İsim: Weatherling, dil: Türkçe, tip: Game, ücretsiz.

### H3. Store listing (Main store listing)
`STORE_LISTING.md`'den kopyala:
- [ ] Kısa açıklama (TR + EN).
- [ ] Tam açıklama (TR + EN).
- [ ] App icon = `png/icon_512.png`.
- [ ] Feature graphic = `png/feature_1024x500.png`.
- [ ] Telefon ekran görüntüleri (Faz C2, ≥2).
- [ ] Kategori: **Casual** (veya Simulation).
- [ ] İletişim e-postası.

### H4. App content (politika formları)
- [ ] **Privacy policy** = Faz G URL'si.
- [ ] **Data safety** = `DATA_SAFETY.md`'deki cevapları gir (konum opsiyonel/işlev,
      e-posta hesap, paylaşım yok, aktarımda şifreli, silme/dışa aktarma var).
- [ ] **Content rating** (IARC anketi) → muhtemelen "Herkes/Everyone".
- [ ] **Target audience & content** → yetişkin/genel; çocuklara yönelik DEĞİL.
- [ ] **App access** → tüm içerik girişsiz erişilebilir mi? "Misafir mod var" de;
      giriş gerektiren akış için incelemeciye test hesabı vermen gerekmez.
- [ ] **Ads** → "Bu uygulama reklam içermiyor" işaretle.

### H5. App signing
- [ ] Play App Signing'i kabul et (Google imzalamayı yönetir, sen upload key kullanırsın).

---

## FAZ I — Test Yayınları

### I1. Internal testing (hızlı, kendi cihazların)
- [ ] Release → Testing → **Internal testing** → Create release → `weatherling.aab` yükle.
- [ ] Test kullanıcısı e-postaları ekle (kendin + birkaç kişi) → opt-in linkini aç → kur.
- [ ] **Pre-launch report** otomatik çalışır → çökme/uyarı var mı bak.

### I2. Closed testing (KİŞİSEL HESAP İSE ZORUNLU)
- [ ] Closed testing track aç → `.aab` yükle.
- [ ] **En az 12 gerçek test kullanıcısı** opt-in etsin.
- [ ] **14 gün KESİNTİSİZ** sürmeli (kullanıcı sayısı 12'nin altına düşmemeli).
- [ ] ⚠️ Test kullanıcısı satan servis / emülatör çiftliği KULLANMA → hesap kapatma riski.
      Gerçek kişi topla: arkadaş, aile, r/AndroidGaming, indie/cozy Discord toplulukları.
- [ ] 14 gün sonunda **production access** başvurusu (10 soruluk anket) açılır → doldur.

---

## FAZ J — Production Yayını

- [ ] Release → Production → Create release → `.aab` yükle.
- [ ] "What's new" = `STORE_LISTING.md` sürüm notu (TR + EN).
- [ ] Tüm bölümler yeşil (listing, data safety, rating, access) → **Review'a gönder**.
- [ ] Google incelemesi (genelde birkaç saat–birkaç gün) → onaylanınca canlı. 🎉

---

## FAZ K — Yayın Sonrası

- [ ] Play Console → **Vitals** → ANR/çökme oranını izle (temiz olmalı).
- [ ] Kullanıcı yorumlarına bak.
- [ ] **Güncelleme döngüsü:** kod değiştir → `version/code` +1 → `version/name` artır →
      yeni `.aab` → Internal → (gerekiyorsa Closed) → Production. Her seferinde
      `RELEASE_CHECKLIST.md`'i tekrar geç.

---

## Hâlâ açık olan kod işleri (istersen ben yaparım, söyle)
- [ ] **Android Keystore köprüsü** — token/kayıt anahtarını donanım-destekli sakla
      (şu an `device_pass` ara çözümü var). Native eklenti + build ortamı ister.
- [ ] **Bildirim eklentisi** — `addons/` altına gerçek Android local-notification eklentisi;
      yoksa bildirimler sessizce no-op (`notification_service.gd` hazır bekliyor).
- [ ] **GPS otomatik konum** — şu an manuel şehir çalışıyor; coarse-location eklentisi opsiyonel.
- [ ] **Ek özellikler** — foto modu, hava mini-oyunları, nazik streak (Plan §22).
