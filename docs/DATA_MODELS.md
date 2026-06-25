# Veri Modelleri

Tüm sayısal/davranışsal parametreler data-driven `.tres` kaynaklarında; koda gömülmez.
(Master Plan §5)

## Resource sınıfları (`resources/`)

| Sınıf | Dosya | Rol |
|-------|-------|-----|
| `CreatureState` | creature_state.gd | Kalıcı yaratık durumu (yerel + bulut). `version` ile şema migrasyonu. |
| `LifeStageConfig` | life_stage_config.gd | Bir yaşam evresinin tüm parametreleri (`data/life_stages/<id>.tres`). |
| `FoodItem` | food_item.gd | Yemek item'ı (`data/foods/<id>.tres`). |
| `SkillNode` | skill_node.gd | Skill ağacı düğümü (`data/skills/<id>.tres`). |
| `FaithProfile` | faith_profile.gd | İnanç/gelenek ritim tanımı (`data/faiths/<id>.tres`). |

## CreatureState — kalıcı alanlar

Kimlik (name, user_age, life_stage, faith, birth_unix) · bağ (bond_level, bond_xp) ·
6 ihtiyaç 0–100 (hunger, energy, hygiene, happiness, health, social) ·
ekonomi/koleksiyon (coins, inventory, unlocked_skills, equipped_cosmetics, home_decor) ·
zaman/stat/tercih (last_seen_unix, stats, settings, version).

Serileştirme: `SaveService.PROPS` açık listesi (migrasyon-dostu). Yerelde AES binary;
bulutta (Faz 8) JSON.

## Yaş → evre tablosu (Plan §7)

| Yaş | id | İsim |
|-----|----|------|
| 4–12 | filiz | Filiz |
| 13–17 | tomurcuk | Tomurcuk |
| 18–29 | cicek | Çiçek |
| 30–44 | meyve | Meyve |
| 45–59 | hasat | Hasat |
| 60–74 | kok | Kök |
| 75+ | cinar | Çınar |

## Supabase şeması (Faz 8 — Plan §5.3)

`public.profiles` (id ↔ auth.users) ve `public.creature_saves` (user_id, state jsonb,
schema_version, updated_at). Her ikisinde de **RLS**: kullanıcı yalnızca kendi satırını
görür/yazar. Çakışma: last-write-wins (en yeni `updated_at`).
