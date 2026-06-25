## Global sinyal merkezi. Sistemler birbirini doğrudan çağırmaz; buradan haberleşir.
## (Plan §3.2, §3.3) Loose coupling = test edilebilirlik. Burada SADECE sinyal tanımı
## bulunur, mantık yok.
extends Node

# --- Zaman / mevsim / gökyüzü --------------------------------------
signal time_phase_changed(phase: String)              # "dawn" | "day" | "dusk" | "night"
signal season_changed(season: String)                 # "spring" | "summer" | "autumn" | "winter"
signal moon_phase_changed(phase_name: String, illumination: float)

# --- Hava -----------------------------------------------------------
signal weather_changed(state: int, temp_c: float, is_day: bool)  # state = WeatherService.WeatherState
signal offline_mode_changed(is_offline: bool)

# --- İhtiyaçlar / ruh hali -----------------------------------------
signal need_changed(key: String, value: float)
signal needs_recalculated()                            # offline catch-up sonrası
signal mood_changed(mood: String)
signal creature_interacted(kind: String)               # "feed" | "pet" | "play" | "clean" | "sleep"

# --- Bağ / ekonomi / skill -----------------------------------------
signal bond_xp_gained(amount: int)
signal bond_level_up(level: int)
signal coins_changed(total: int)
signal item_purchased(item_id: String)
signal skill_unlocked(skill_id: String)

# --- İnanç ----------------------------------------------------------
signal devotion_time(faith: String, ritual: String)

# --- Olaylar --------------------------------------------------------
signal random_event(event_id: String)
signal seasonal_event(event_id: String)

# --- Kayıt / hesap --------------------------------------------------
signal state_loaded(state: Resource)                   # CreatureState — GameManager yayar
signal save_requested()
signal save_completed()
signal auth_state_changed(status: String)              # "guest" | "signed_in" | "signed_out"
signal sync_started()
signal sync_completed(success: bool)

# --- Sistem / UI ----------------------------------------------------
signal settings_changed(key: String, value: Variant)
signal locale_changed(locale: String)
signal notification_permission_changed(granted: bool)
signal scene_change_started(path: String)
signal scene_change_finished(path: String)
