# Play Data Safety — Form Cevapları (Faz 12)

Master Plan §16. Google Play Console → App content → Data safety formuna bunları gir.
Gizlilik Politikası (`docs/PRIVACY_POLICY.md`) ile **tutarlı** olmalı.

## Özet beyan
- **Reklam yok, üçüncü taraf analytics yok, takip için cihaz kimliği toplanmaz.**
- Toplanan her veri yalnızca **uygulama işlevi** için; **hiçbiri paylaşılmaz/satılmaz**.
- Aktarımda **şifreli** (HTTPS). Kullanıcı **silme** ve **dışa aktarma** talep edebilir.

## Toplanan veri türleri

| Veri | Toplanıyor? | Amaç | Zorunlu? | Paylaşılıyor? | Notlar |
|------|-------------|------|----------|---------------|--------|
| Konum (yaklaşık / şehir) | Evet (opsiyonel) | Uygulama işlevi (gerçek hava) | Hayır | Hayır | İzin verilmezse manuel şehir; konum hiç gönderilmez, sadece hava API'sine koordinat sorgusu |
| E-posta adresi | Evet (yalnızca hesap açılırsa) | Hesap yönetimi / bulut yedek | Hayır | Hayır | Misafir mod tam çalışır |
| Uygulama içi etkinlik (oyun durumu) | Evet | Uygulama işlevi (kayıt/senkron) | Hayır | Hayır | Cihazda **şifreli**; girişte Supabase'de yalnızca kullanıcıya açık (RLS) satır |

## Toplanmayanlar (form: "No")
- Kişi listesi, mesajlar, fotoğraf/medya, kişiler, arama geçmişi, SMS.
- Reklam kimliği (AAID), takip amaçlı tanımlayıcılar.
- Üçüncü taraf analytics/crash SDK (MVP'de yok).

## Güvenlik uygulamaları (form bölümü)
- [x] Veri aktarımda şifreli (HTTPS / TLS).
- [x] Kullanıcı veri **silme** talep edebilir (Ayarlar → Hesap sil; `AuthService.delete_account`).
- [x] Kullanıcı veri **dışa aktarabilir** (`SaveService.export_json`).
- Yerel kayıt cihazda AES şifreli (`SaveService.device_pass`).

## Hedef kitle / çocuklar
- Uygulama **çocuklara yönelik değil**. İçerik derecelendirme: Herkes/Everyone.
- Küçük yaşta yalnızca yerel oyun; bulut/hesap için yetişkin onayı (bkz. DECISIONS.md #7).

---

# English (summary)

- No ads, no third-party analytics, no tracking identifiers.
- Collected: approximate location (optional, app function), email (only if account, account mgmt),
  app activity/game state (app function). **None shared or sold.**
- Encrypted in transit (HTTPS). Users can **delete** and **export** their data.
- Not directed to children; content rating Everyone.
