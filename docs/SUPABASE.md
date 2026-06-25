# Supabase Kurulumu (Faz 8 — bulut kayıt)

Bulut **opsiyonel**. Yapılandırılmazsa oyun tamamen yerel çalışır (misafir mod).
Bağlamak için:

## 1. Proje oluştur
- [supabase.com](https://supabase.com) → yeni proje.
- **Project URL** ve **anon (public) key**'i not al (Settings → API).
  Bunlar public; gizli değil — **RLS** korur. service_role anahtarını **asla** istemciye koyma.

## 2. Şemayı uygula
- SQL Editor'a `supabase/migrations/0001_init.sql` içeriğini yapıştır → çalıştır.
- Üretilen: `profiles`, `creature_saves` (+ RLS politikaları), `delete_me()` RPC.

## 3. İstemciye bağla
`autoload/auth_service.gd`:
```gdscript
const SUPABASE_URL := "https://<proj>.supabase.co"
const SUPABASE_ANON := "<anon-key>"
```
Doldurunca `is_configured()` true olur; Hesap panelinden e-posta giriş/kayıt çalışır,
`SaveService` bulutla last-write-wins senkron olur.

## 4. Auth ayarları (Supabase Dashboard → Authentication)
- **Email**: aç. Magic link için "Confirm email" akışı.
- **Redirect URLs**: deep link ekle → `weatherling://auth-callback`.

## 5. Google ile giriş (sonra)
- Authentication → Providers → Google: Client ID/secret gir.
- Android: `AndroidManifest`'e intent-filter (App Link / custom scheme `weatherling://`).
- Akış: uygulama → sistem tarayıcı (Supabase OAuth) → Google → callback deep link → token.
- `AuthService.sign_in_google()` içindeki TODO burada tamamlanır (Godot OAuth eklenti/sürüm bağımlı).

## 6. Doğrula (RLS testi — Plan §8 DoD)
- İki farklı hesapla gir; A'nın verisi B'den **erişilemez** olmalı (RLS).
- Çıkış/giriş arası ilerleme korunur (sync).

## Güvenlik
- İstemcide yalnızca anon key (public). service_role yalnızca sunucu/Edge Function.
- Anahtarlı 3. parti gerekiyorsa Edge Function proxy (Plan §3.4).
