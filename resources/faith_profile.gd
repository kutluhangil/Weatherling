## Bir inanç / gelenek profili (data-driven). Plan §8.
## data/faiths/<id>.tres. Saygı ilkeleri: ceza yok, eşlik opsiyonel, yargısız.
class_name FaithProfile
extends Resource

## id: "islam" | "christianity" | "judaism" | "hinduism" | "buddhism" | "spiritual" | "none"
@export var id: String = "none"
@export var display_name_key: String = ""

## Ritüel zamanlama tipi:
## "prayer_times" (konumdan 5 vakit), "weekday" (haftanın günü),
## "sunset_window" (gün batımı–gün batımı / Shabbat), "daily_times" (sabit saatler),
## "none" (mekanik yok — yalnızca opsiyonel minnettarlık anı).
@export var rhythm_type: String = "none"

## rhythm_type'a göre yorumlanan ritüel tanımları.
## Örn. prayer_times: ["fajr","dhuhr","asr","maghrib","isha"]
## weekday: {"day":0,"ritual":"service"}  (0=Pazar)
@export var rituals: Array = []

@export var decor_keys: Array[String] = []    # "prayer_corner","christmas",...
@export var notification_enabled_default: bool = false  # nazik, opt-in
@export var uses_location: bool = false       # vakitler konuma bağlı mı
