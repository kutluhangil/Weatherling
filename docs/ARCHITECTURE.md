# Mimari

Autoload (singleton) + sinyal tabanlı, data-driven. Sistemler birbirini doğrudan
çağırmaz; `EventBus` üzerinden gevşek bağlı haberleşir. (Master Plan §3)

## Autoload yükleme sırası

`project.godot` içinde sırayla yüklenir. Sıra önemli: bir servis `_ready`'de bir
diğerinin verisine **doğrudan** dokunmaz — bunun yerine `EventBus` sinyaline bağlanır.
`GameManager` en sonda yüklenir ve `state_loaded` yayınlayarak diğerlerini besler.

1. `EventBus` — global sinyal merkezi (sadece sinyal tanımı)
2. `Settings` — ConfigFile (user://settings.cfg)
3. `Localization` — TranslationServer sarmalayıcı (tr/en)
4. `SaveService` — yerel şifreli kayıt (AES, tip-güvenli binary)
5. `TimeService` — faz / mevsim / ay evresi (saf hesap + 60sn timer)
6. `WeatherService` — Open-Meteo, WMO→durum eşleme, cache
7. `NeedsService` — 6 ihtiyaç, offline catch-up (taban korumalı), bakım
8. `LifeStageService` — yaş→evre, LifeStageConfig yükleme
9. `FaithService` — opsiyonel gelenek, ritüel zamanlama (iskelet)
10. `SkillService` — bond xp→level, skill unlock
11. `EconomyService` — coin
12. `AuthService` — guest/email/Google (Supabase, iskelet)
13. `NotificationService` — yerel bildirim (iskelet)
14. `AudioManager` — music/ambient/sfx + Settings ses
15. `SceneManager` — fade geçişli sahne yükleme
16. `GameManager` — durum sahibi, orkestratör, autosave

## Veri akışı (özet)

```
GameManager._ready → SaveService.load_state() (yoksa new_game)
        └─ EventBus.state_loaded(state)
              ├─ NeedsService: offline catch-up
              ├─ LifeStageService: yaş→evre
              ├─ FaithService: gelenek
              ├─ SkillService / EconomyService: state ref
              └─ Home: HUD tazele

TimeService (60sn) → time_phase_changed / season_changed / moon_phase_changed
WeatherService.refresh(lat,lon) → weather_changed (Faz 3)
NeedsService.apply_care(kind) → need_changed + creature_interacted + bond_xp_gained
SkillService: bond_xp_gained → (eşik) bond_level_up
```

## Faz 0'da hazır olan saf çekirdek (test edilebilir, GUT — Plan §21)

- `TimeService.phase_for / season_for / _moon_name`
- `WeatherService.state_for_wmo` (WMO kodu → WeatherState)
- `NeedsService.decayed` (offline taban korumalı azalma)
- `LifeStageService.stage_for_age` (yaş → evre)
- `SkillService.level_for_xp` (bond eğrisi)

Ağ/IO bağımlı kısımlar (Weather HTTP, Auth, Notification) iskelet + `TODO(Faz N)`.
