# Gizlilik Politikası / Privacy Policy — Weatherling

> Taslak. Yayından önce bir URL'de barındır (Play zorunlu). Şirket/iletişim adını doldur.
> Draft. Host at a public URL before release (required by Play). Fill company/contact.

Son güncelleme / Last updated: 2026-06-25

---

## Türkçe

**Toplanan veriler**
- **Konum (yaklaşık/şehir, opsiyonel):** Gerçek havanı göstermek için kullanılır.
  İzin vermezsen manuel şehir seçebilirsin; konum hiç paylaşılmaz.
- **E-posta (yalnızca hesap açarsan):** Bulut yedek/senkron için. Hesap açmak zorunlu değil
  (misafir mod tam çalışır).
- **Oyun durumu:** Yaratığının verisi cihazında **şifreli** saklanır; giriş yaparsan
  Supabase'de yalnızca senin erişebildiğin (RLS korumalı) bir satırda yedeklenir.

**Kullanım amacı:** Yalnızca uygulamanın çalışması (hava, vakit, bulut yedek). Reklam yok,
veri satışı yok, üçüncü taraflarla paylaşım yok.

**Hizmet sağlayıcılar:** Open-Meteo (hava, anahtarsız), Supabase (auth + yedek).

**Haklarınız (KVKK/GDPR):** Verini **dışa aktar** (Ayarlar → Hesap) ve **hesabını sil**
(bulut + yerel veri tamamen silinir).

**Çocuklar:** Uygulama çocuklara yönelik değildir. Küçük yaştaki kullanıcılar için bulut
hesabı yetişkin onayı gerektirir; onaysız yalnızca yerel oyun.

**İletişim:** <e-posta/şirket buraya>

---

## English

**Data we collect**
- **Location (approximate/city, optional):** Used to show your real weather. You may pick a
  city manually instead; location is never shared.
- **Email (only if you create an account):** For cloud backup/sync. Accounts are optional
  (guest mode works fully).
- **Game state:** Your companion's data is stored **encrypted** on your device; if you sign
  in, it is backed up to a Supabase row only you can access (protected by RLS).

**Purpose:** Solely to run the app (weather, time, cloud backup). No ads, no data sales, no
sharing with third parties.

**Service providers:** Open-Meteo (weather, keyless), Supabase (auth + backup).

**Your rights (GDPR/KVKK):** **Export** your data (Settings → Account) and **delete your
account** (cloud + local data fully removed).

**Children:** This app is not directed at children. Cloud accounts for minors require adult
consent; without it, local-only play.

**Contact:** <email/company here>
