# Güvenlik & Gizlilik Kontrol Listesi (Faz 11)

Master Plan §16. Yayın öncesi her madde doğrulanır.

## Güvenlik — uygulanan
- [x] **İstemcide gizli sır yok.** Open-Meteo/Aladhan anahtarsız. Supabase yalnızca
      **anon key** (public) — **RLS** ile korunur (`supabase/migrations/0001_init.sql`).
      service_role anahtarı asla istemcide; gerekirse Edge Function proxy.
- [x] **HTTPS zorunlu.** Tüm istekler `https://` (Open-Meteo, geocoding, Supabase).
- [x] **Şifreli yerel kayıt.** `FileAccess.open_encrypted_with_pass()` (AES) — `SaveService`.
- [x] **İzin minimizasyonu.** Sadece INTERNET + ACCESS_COARSE_LOCATION + POST_NOTIFICATIONS
      (`export_presets.cfg`). Konum tamamen opsiyonel (manuel şehir alternatifi).
- [x] **RLS.** Her tabloda "yalnızca kendi satırı" politikası. (Plan §8 DoD: iki hesapla test et.)

## Sertleştirilecek (TODO)
- [ ] **Token saklama:** şu an oturum token'ı `user://session.dat` (binary). Faz 11+:
      Android Keystore köprüsü (`AuthService._save_session` TODO).
- [ ] **Yerel kayıt anahtarı:** `SaveService._PASS` sabit; cihaz/Keystore türevli anahtara geçir.
- [ ] Düşük donanım cihaz testi (ucuz Android) — akıcılık + ısı.
- [ ] Orphan node kontrolü (sahne geçişlerinde), bellek profili (Godot ObjectDB diff).

## Performans — uygulanan
- [x] `application/run/low_processor_mode=true` (boşta render durur).
- [x] `Engine.max_fps=60`; odak dışı → 10 (`GameManager._notification`).
- [x] Partikül havuzlama (CPUParticles2D), hareket azaltma → partikül %40 (`weather_vfx`).
- [x] Pixel-perfect import (nearest, mipmap kapalı), Compatibility renderer.

## Gizlilik & yasal (Plan §16)
- [ ] Gizlilik Politikası URL'si (konum/hesap verisi var → Play zorunlu).
- [x] KVKK/GDPR: açık rıza (konum/giriş opt-in), **veri dışa aktarma** (`SaveService.export_json`),
      **hesap silme** (`AuthService.delete_account` + `delete_me()` RPC).
- [ ] Play **Data Safety** formu: konum (yalnızca işlev, paylaşılmıyor), e-posta (hesap).
- [x] Reklam yok (MVP) → reklam SDK izin/veri yükü yok.
- [ ] Çocuk verisi: "çocuklara yönelik değil"; küçük yaşta yalnızca yerel, bulut için yetişkin onayı
      (bkz. DECISIONS.md #7).
