# Pixel-Prime Foundation (F0+F1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Lay the Pixel-Prime visual foundation (palette, stylebox factory, theme, icons) and swap the dynamic weather-VFX engine for a data-driven SceneBackground, while removing the faith subsystem — all without breaking saves or existing features.

**Architecture:** A single-source `Palette` const script + a `UiFactory` stylebox builder feed both `theme.tres` and code-built UI. `SceneBackground` selects an illustration from `WeatherService.state` × `TimeService` phase with a flat-color fallback when art is absent. Faith is excised from autoloads/UI/flow; `CreatureState.faith` stays for save back-compat.

**Tech Stack:** Godot 4.7 stable (GDScript), GL Compatibility renderer, portrait. Dependency-free headless test runner.

## Global Constraints

- Engine: Godot 4.7 stable. Binary on this machine: `/Volumes/PixelVault/Applications/Godot.app/Contents/MacOS/Godot`.
- Renderer `gl_compatibility`; portrait 540×960 design; mobile (Android) target.
- Palette hex (verbatim from spec, exact): `surface=#1d0c24`, `deep-plum=#1A0F1F`, `surface-container=#2b1931`, `surface-container-high=#36233c`, `dusk-amber=#E87C3E`, `horizon-glow=#FFC078`, `primary-container=#ff9d5c`, `on-surface=#f6d9fa`, `secondary-container=#622f91`, `on-secondary-container=#d4a5ff`, `tertiary=#f8ca60`, `status-hunger=#FF4D6D`, `status-energy=#4CC9F0`, `status-love=#F72585`, `outline-variant=#544339`.
- `WeatherService` and `TimeService` DATA are preserved; only the VFX rendering nodes/shaders are retired.
- Any new user-facing string ships in TR + EN (`localization/tr.po`, `localization/en.po`).
- Missing art must not break the build: every art path has a flat-color/placeholder fallback.
- Tests: `"$GODOT" --headless -s tests/run_tests.gd` must end `0 failed`. CI workflow unchanged.
- **Commits are the USER's job.** Do NOT run `git commit`. Treat each "Commit" step as a checkpoint: stop, summarize what changed, let the user commit.

Define once per shell session:
```bash
GODOT="/Volumes/PixelVault/Applications/Godot.app/Contents/MacOS/Godot"
cd /Volumes/ProjectVault/Weatherling
```

---

## File Structure

- Create `theme/palette.gd` — single source of palette `Color` constants (testable).
- Create `theme/ui_factory.gd` — StyleBoxFlat builders (panel, button, bar track/fill, fab, chip).
- Modify `theme.tres` — base control defaults built from palette values.
- Create `art/ui/icons/*.svg` — icon set (home, play, shop, menu, feed, sleep, clean, bolt, coin, weather, close, lock, star).
- Create `scenes/scene_background/scene_background.gd` (+ `.tscn`) — weather×phase illustration with fallback; replaces weather VFX in Home.
- Modify `scenes/home/home.tscn`, `scenes/home/home.gd` — swap weather_vfx/sky/DayNight for SceneBackground.
- Delete `scenes/weather_vfx/*`, `shaders/fog.gdshader*`, `shaders/moon.gdshader*`.
- Remove faith: `autoload/faith_service.gd`, `resources/faith_profile.gd`, `data/faiths/*`, `scenes/ui/panel_faith/*`; edit `project.godot`, `scenes/onboarding/onboarding.gd/.tscn`, `scenes/creature/creature.gd`, `autoload/notification_service.gd`, `scenes/ui/menu_main/menu_main.gd/.tscn`, `scenes/home/home.gd/.tscn`, `autoload/game_manager.gd` (new_game signature), `autoload/settings.gd` (notify/faith default).
- Modify `tests/run_tests.gd` — add Palette, UiFactory, SceneBackground tests.

---

### Task 1: Palette single-source

**Files:**
- Create: `theme/palette.gd`
- Test: `tests/run_tests.gd` (append)

**Interfaces:**
- Produces: `Palette` (class_name) with `const` Colors: `SURFACE, DEEP_PLUM, SURFACE_CONTAINER, SURFACE_CONTAINER_HIGH, DUSK_AMBER, HORIZON_GLOW, PRIMARY_CONTAINER, ON_SURFACE, SECONDARY_CONTAINER, ON_SECONDARY_CONTAINER, TERTIARY, STATUS_HUNGER, STATUS_ENERGY, STATUS_LOVE, OUTLINE_VARIANT`. Also `static func need_color(key: String) -> Color`.

- [ ] **Step 1: Write the failing test** — append to `tests/run_tests.gd` member loads and a test fn.

In `_initialize()` add `var PAL := load("res://theme/palette.gd")` (after other loads) and call `_test_palette()`.

```gdscript
func _test_palette() -> void:
	var PAL := load("res://theme/palette.gd")
	_eq(PAL.DUSK_AMBER, Color("#E87C3E"), "palette dusk_amber")
	_eq(PAL.HORIZON_GLOW, Color("#FFC078"), "palette horizon_glow")
	_eq(PAL.SURFACE, Color("#1d0c24"), "palette surface")
	# need_color maps the 6 needs to status hues (fallback = ON_SURFACE).
	_eq(PAL.need_color("hunger"), PAL.STATUS_HUNGER, "palette need hunger")
	_eq(PAL.need_color("energy"), PAL.STATUS_ENERGY, "palette need energy")
	_eq(PAL.need_color("happiness"), PAL.STATUS_LOVE, "palette need happiness")
	_eq(PAL.need_color("nope"), PAL.ON_SURFACE, "palette need fallback")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `"$GODOT" --headless -s tests/run_tests.gd`
Expected: FAIL — `res://theme/palette.gd` does not exist / null.

- [ ] **Step 3: Write minimal implementation** — `theme/palette.gd`:

```gdscript
## Tek kaynak renk paleti (DESIGN.md Pixel-Prime). Kod + theme.tres bunu kullanır.
class_name Palette
extends RefCounted

const SURFACE := Color("#1d0c24")
const DEEP_PLUM := Color("#1A0F1F")
const SURFACE_CONTAINER := Color("#2b1931")
const SURFACE_CONTAINER_HIGH := Color("#36233c")
const SURFACE_CONTAINER_LOWEST := Color("#18071e")
const DUSK_AMBER := Color("#E87C3E")
const HORIZON_GLOW := Color("#FFC078")
const PRIMARY_CONTAINER := Color("#ff9d5c")
const ON_PRIMARY_CONTAINER := Color("#743500")
const ON_SURFACE := Color("#f6d9fa")
const ON_SURFACE_VARIANT := Color("#dac2b4")
const SECONDARY_CONTAINER := Color("#622f91")
const ON_SECONDARY_CONTAINER := Color("#d4a5ff")
const TERTIARY := Color("#f8ca60")
const OUTLINE_VARIANT := Color("#544339")
const STATUS_HUNGER := Color("#FF4D6D")
const STATUS_ENERGY := Color("#4CC9F0")
const STATUS_LOVE := Color("#F72585")

# 6 ihtiyaç → bar rengi. Hijyen/sağlık/sosyal için türev tonlar.
const _NEED := {
	"hunger": STATUS_HUNGER, "energy": STATUS_ENERGY, "happiness": STATUS_LOVE,
	"hygiene": STATUS_ENERGY, "health": Color("#8fd089"), "social": Color("#deb7ff"),
}

static func need_color(key: String) -> Color:
	return _NEED.get(key, ON_SURFACE)
```

- [ ] **Step 4: Run test to verify it passes**

Run: `"$GODOT" --headless -s tests/run_tests.gd`
Expected: PASS — ends `0 failed`.

- [ ] **Step 5: Commit** (checkpoint — user commits)

Changed: `theme/palette.gd`, `tests/run_tests.gd`. Suggested message: `feat(theme): add Pixel-Prime palette single-source + tests`.

---

### Task 2: UI stylebox factory

**Files:**
- Create: `theme/ui_factory.gd`
- Test: `tests/run_tests.gd` (append)

**Interfaces:**
- Consumes: `Palette`.
- Produces: `UiFactory` (class_name) statics returning `StyleBoxFlat`:
  `panel() -> StyleBoxFlat`, `button(bg: Color) -> StyleBoxFlat`, `bar_track() -> StyleBoxFlat`, `bar_fill(c: Color) -> StyleBoxFlat`, `chip() -> StyleBoxFlat`.

- [ ] **Step 1: Write the failing test** — add `_test_ui_factory()` (call it in `_initialize`).

```gdscript
func _test_ui_factory() -> void:
	var UF := load("res://theme/ui_factory.gd")
	var PAL := load("res://theme/palette.gd")
	var panel: StyleBoxFlat = UF.panel()
	_eq(panel.bg_color, PAL.SURFACE_CONTAINER, "uifactory panel bg")
	_eq(panel.border_color, PAL.DUSK_AMBER, "uifactory panel border")
	_eq(panel.border_width_left, 4, "uifactory panel border width")
	var fill: StyleBoxFlat = UF.bar_fill(PAL.STATUS_ENERGY)
	_eq(fill.bg_color, PAL.STATUS_ENERGY, "uifactory bar_fill color")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `"$GODOT" --headless -s tests/run_tests.gd`
Expected: FAIL — `ui_factory.gd` missing.

- [ ] **Step 3: Write minimal implementation** — `theme/ui_factory.gd`:

```gdscript
## 9-patch hissi veren StyleBoxFlat üreticileri (Pixel-Prime). Kod-tabanlı UI burayı kullanır.
class_name UiFactory
extends RefCounted

const _R := 8  # 2-step köşe (DESIGN.md large panel)

static func panel() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Palette.SURFACE_CONTAINER
	s.border_color = Palette.DUSK_AMBER
	s.set_border_width_all(4)
	s.set_corner_radius_all(_R)
	s.set_content_margin_all(14)
	return s

static func button(bg: Color = Palette.PRIMARY_CONTAINER) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(4)
	s.set_content_margin_all(10)
	s.shadow_color = Palette.ON_PRIMARY_CONTAINER
	s.shadow_offset = Vector2(0, 4)  # chunky alt gölge
	return s

static func bar_track() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Palette.SURFACE_CONTAINER_LOWEST
	s.border_color = Palette.SURFACE_CONTAINER_HIGH
	s.set_border_width_all(2)
	s.set_corner_radius_all(6)
	return s

static func bar_fill(c: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(6)
	return s

static func chip() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Palette.SURFACE_CONTAINER_HIGH
	s.border_color = Palette.PRIMARY_CONTAINER
	s.set_border_width_all(2)
	s.set_corner_radius_all(999)
	s.set_content_margin_all(6)
	return s
```

- [ ] **Step 4: Run test to verify it passes**

Run: `"$GODOT" --headless -s tests/run_tests.gd` → PASS.

- [ ] **Step 5: Commit** (checkpoint) — `theme/ui_factory.gd`, `tests/run_tests.gd`. Msg: `feat(theme): add UiFactory styleboxes + tests`.

---

### Task 3: Rewrite theme.tres from palette

**Files:**
- Modify: `theme.tres` (full replace)

**Interfaces:** none (Godot theme resource consumed by all Controls).

- [ ] **Step 1: Replace `theme.tres`** with palette-driven styles (colors verbatim from Global Constraints):

```
[gd_resource type="Theme" load_steps=6 format=3]

[sub_resource type="StyleBoxFlat" id="btn_normal"]
bg_color = Color(1, 0.615686, 0.360784, 1)
corner_radius_top_left = 4
corner_radius_top_right = 4
corner_radius_bottom_right = 4
corner_radius_bottom_left = 4
shadow_color = Color(0.454902, 0.207843, 0, 1)
shadow_offset = Vector2(0, 4)
content_margin_left = 14.0
content_margin_top = 10.0
content_margin_right = 14.0
content_margin_bottom = 10.0

[sub_resource type="StyleBoxFlat" id="btn_pressed"]
bg_color = Color(0.909804, 0.486275, 0.243137, 1)
corner_radius_top_left = 4
corner_radius_top_right = 4
corner_radius_bottom_right = 4
corner_radius_bottom_left = 4
content_margin_left = 14.0
content_margin_top = 12.0
content_margin_right = 14.0
content_margin_bottom = 8.0

[sub_resource type="StyleBoxFlat" id="panel"]
bg_color = Color(0.168627, 0.0980392, 0.192157, 1)
border_width_left = 4
border_width_top = 4
border_width_right = 4
border_width_bottom = 4
border_color = Color(0.909804, 0.486275, 0.243137, 1)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
content_margin_left = 16.0
content_margin_top = 16.0
content_margin_right = 16.0
content_margin_bottom = 16.0

[sub_resource type="StyleBoxFlat" id="pb_bg"]
bg_color = Color(0.0941176, 0.027451, 0.117647, 1)
corner_radius_top_left = 6
corner_radius_top_right = 6
corner_radius_bottom_right = 6
corner_radius_bottom_left = 6

[sub_resource type="StyleBoxFlat" id="pb_fill"]
bg_color = Color(1, 0.752941, 0.470588, 1)
corner_radius_top_left = 6
corner_radius_top_right = 6
corner_radius_bottom_right = 6
corner_radius_bottom_left = 6

[resource]
default_font_size = 16
Button/colors/font_color = Color(0.454902, 0.207843, 0, 1)
Button/colors/font_pressed_color = Color(0.454902, 0.207843, 0, 1)
Button/styles/normal = SubResource("btn_normal")
Button/styles/hover = SubResource("btn_normal")
Button/styles/pressed = SubResource("btn_pressed")
Button/styles/focus = SubResource("btn_normal")
Label/colors/font_color = Color(0.964706, 0.85098, 0.980392, 1)
PanelContainer/styles/panel = SubResource("panel")
ProgressBar/styles/background = SubResource("pb_bg")
ProgressBar/styles/fill = SubResource("pb_fill")
```

- [ ] **Step 2: Verify import is clean**

Run: `"$GODOT" --headless --import 2>&1 | grep -iE "error|parse" | grep -iv "errors=" ; echo done`
Expected: no `theme.tres` errors; `done` printed.

- [ ] **Step 3: Run tests (regression)**

Run: `"$GODOT" --headless -s tests/run_tests.gd` → `0 failed`.

- [ ] **Step 4: Commit** (checkpoint) — `theme.tres`. Msg: `feat(theme): retheme controls to Pixel-Prime palette`.

---

### Task 4: Icon SVG set

**Files:**
- Create: `art/ui/icons/{home,play,shop,menu,feed,sleep,clean,bolt,coin,weather,close,lock,star}.svg`

**Interfaces:** none (loaded as Texture2D by later UI tasks).

- [ ] **Step 1: Create the 13 icon SVGs.** Each 24×24, single-color `#f6d9fa` (tinted at use). Use simple pixel-friendly shapes. Example `feed.svg`:

```xml
<svg width="24" height="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <rect x="4" y="3" width="3" height="9" rx="1.5" fill="#f6d9fa"/>
  <rect x="10.5" y="3" width="3" height="9" rx="1.5" fill="#f6d9fa"/>
  <rect x="6" y="11" width="2" height="10" rx="1" fill="#f6d9fa"/>
  <path d="M17 3c2 0 3 3 3 7s-1 4-2 4v7h-2V3z" fill="#f6d9fa"/>
</svg>
```

Create the remaining 12 with comparable simple geometry (home = house, play = controller/▶, shop = bag, menu = 3 lines, sleep = moon, clean = sparkle, bolt = lightning, coin = circle+star, weather = cloud+rain, close = ✕, lock = padlock, star = ★).

- [ ] **Step 2: Verify import**

Run: `"$GODOT" --headless --import 2>&1 | grep -iE "art/ui/icons.*error" ; echo done`
Expected: only `done` (no icon import errors).

- [ ] **Step 3: Commit** (checkpoint) — `art/ui/icons/*`. Msg: `feat(art): add Pixel-Prime UI icon SVGs`.

---

### Task 5: SceneBackground key + node with fallback

**Files:**
- Create: `scenes/scene_background/scene_background.gd`, `scenes/scene_background/scene_background.tscn`
- Test: `tests/run_tests.gd` (append)

**Interfaces:**
- Consumes: `WeatherService.WeatherState` (int 0..6), `TimeService.get_phase()` (String).
- Produces: `SceneBackground` (class_name) `static func bg_key(state: int, phase: String) -> String` returning `"res://art/backgrounds/{name}_{phase}.png"`; instance method `refresh()`.

- [ ] **Step 1: Write the failing test** — add `_test_scene_bg()` (call in `_initialize`).

```gdscript
func _test_scene_bg() -> void:
	var SB := load("res://scenes/scene_background/scene_background.gd")
	_eq(SB.bg_key(3, "day"), "res://art/backgrounds/rain_day.png", "bg rain_day")
	_eq(SB.bg_key(4, "night"), "res://art/backgrounds/snow_night.png", "bg snow_night")
	_eq(SB.bg_key(0, "dusk"), "res://art/backgrounds/clear_dusk.png", "bg clear_dusk")
	# Bilinmeyen state → clear; bilinmeyen phase → day.
	_eq(SB.bg_key(99, "zzz"), "res://art/backgrounds/clear_day.png", "bg fallback key")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `"$GODOT" --headless -s tests/run_tests.gd` → FAIL (missing script).

- [ ] **Step 3: Write implementation** — `scenes/scene_background/scene_background.gd`:

```gdscript
## Hava (WeatherService.state) × gün-zamanı (TimeService phase) → tam ekran illüstrasyon.
## Dosya yoksa palet düz renge düşer (asset gelmeden çalışır). VFX motorunun yerini alır.
class_name SceneBackground
extends TextureRect

const _STATE_NAMES := ["clear", "clouds", "fog", "rain", "snow", "thunder", "windy"]
const _PHASES := ["dawn", "day", "dusk", "night"]

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	EventBus.weather_changed.connect(func(_s, _t, _d): refresh())
	EventBus.time_phase_changed.connect(func(_p): refresh())
	refresh()

## state×phase → asset yolu. Bilinmeyen state→clear, phase→day. (Saf — test edilir.)
static func bg_key(state: int, phase: String) -> String:
	var name: String = _STATE_NAMES[state] if state >= 0 and state < _STATE_NAMES.size() else "clear"
	var ph: String = phase if phase in _PHASES else "day"
	return "res://art/backgrounds/%s_%s.png" % [name, ph]

func refresh() -> void:
	var path := bg_key(WeatherService.state, TimeService.get_phase())
	if ResourceLoader.exists(path):
		texture = load(path)
		self_modulate = Color.WHITE
	else:
		texture = null
		# Fallback: faza göre palet düz rengi.
		color_fallback()

func color_fallback() -> void:
	# TextureRect texture yokken arkada ColorRect kullanmak yerine self_modulate + 1px doku
	# karmaşası olmasın diye basit: arka rengi parent (Home) belirler; burada şeffaf kal.
	pass
```

Note: actual flat-color fill is provided by a sibling `ColorRect` placed behind in the `.tscn` (Step 4), so `SceneBackground` only shows art when present.

- [ ] **Step 4: Create `scene_background.tscn`** — a `ColorRect` (deep-plum fallback) with the script-bearing `TextureRect` child:

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scenes/scene_background/scene_background.gd" id="1_sb"]

[node name="SceneBackground" type="ColorRect"]
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
color = Color(0.101961, 0.058824, 0.121569, 1)

[node name="Illustration" type="TextureRect" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
script = ExtResource("1_sb")
```

- [ ] **Step 5: Run test to verify it passes**

Run: `"$GODOT" --headless -s tests/run_tests.gd` → PASS.

- [ ] **Step 6: Commit** (checkpoint) — `scenes/scene_background/*`, `tests/run_tests.gd`. Msg: `feat(home): add SceneBackground (weather×phase illustration + fallback)`.

---

### Task 6: Wire SceneBackground into Home; retire weather VFX

**Files:**
- Modify: `scenes/home/home.tscn` (replace Background/DayNight/Sky/WeatherVFX with SceneBackground instance)
- Modify: `scenes/home/home.gd` (drop WEATHER refs only if tied to removed nodes — keep `_refresh()` text badge)
- Delete: `scenes/weather_vfx/weather_vfx.gd/.tscn/.uid`, `scenes/weather_vfx/sky.gd/.tscn`, `scenes/weather_vfx/day_night.gd`, `shaders/fog.gdshader*`, `shaders/moon.gdshader*`

**Interfaces:**
- Consumes: `SceneBackground` (Task 5).

- [ ] **Step 1: Read current `scenes/home/home.tscn`.** Identify ext_resources `3_sky`, `4_daynight`, `5_vfx` and nodes `Background`, `DayNight`, `Sky`, `WeatherVFX`.

- [ ] **Step 2: Edit `home.tscn`** — remove the three ext_resource lines (`3_sky`, `4_daynight`, `5_vfx`) and the `Background`, `DayNight`, `Sky`, `WeatherVFX` nodes. Add one ext_resource for SceneBackground and instance it as the first child (behind HUD/creature):

Add ext_resource: `[ext_resource type="PackedScene" path="res://scenes/scene_background/scene_background.tscn" id="2_bg"]`
Add node (right after the root `Home` node, before `CreatureAnchor`):
```
[node name="SceneBackground" parent="." instance=ExtResource("2_bg")]
```
Decrement `load_steps` accordingly (removed 3 ext_resources, added 1 → net −2).

- [ ] **Step 3: Delete retired files**

```bash
rm -rf scenes/weather_vfx
rm -f shaders/fog.gdshader shaders/fog.gdshader.uid shaders/moon.gdshader shaders/moon.gdshader.uid
```

- [ ] **Step 4: Verify import + no dangling refs**

Run: `"$GODOT" --headless --import 2>&1 | grep -iE "error|missing|weather_vfx|sky.tscn|gdshader" ; echo done`
Expected: only `done` (no missing-resource errors).

- [ ] **Step 5: Headless smoke (scene loads)**

Run: `"$GODOT" --headless -s tests/run_tests.gd` → `0 failed`.

- [ ] **Step 6: Visual check (user/manual)** — launch app: `"$GODOT" --path .` → Home shows deep-plum fallback bg (no art yet), creature + HUD intact, no errors in console.

- [ ] **Step 7: Commit** (checkpoint) — `scenes/home/*`, deleted `scenes/weather_vfx/*`, `shaders/*`. Msg: `refactor(home): replace weather-VFX engine with SceneBackground`.

---

### Task 7: Remove faith subsystem

**Files:**
- Modify: `project.godot` (drop `FaithService` autoload line)
- Delete: `autoload/faith_service.gd(.uid)`, `resources/faith_profile.gd(.uid)`, `scenes/ui/panel_faith/*`, `data/faiths/*`
- Modify: `scenes/onboarding/onboarding.gd` + `.tscn` (remove faith step), `autoload/game_manager.gd` (`new_game` faith param default), `scenes/creature/creature.gd` (devotion handler), `autoload/notification_service.gd` (`faith` category), `autoload/settings.gd` (`notify/faith` default), `scenes/ui/menu_main/menu_main.gd` + `.tscn` (Faith button/signal), `scenes/home/home.gd` + `.tscn` (PanelFaith)

**Interfaces:**
- `GameManager.new_game(creature_name, age)` — faith param dropped (callers updated). `CreatureState.faith` stays default `"none"`.

- [ ] **Step 1: Remove autoload** — in `project.godot` delete the line `FaithService="*res://autoload/faith_service.gd"`.

- [ ] **Step 2: Onboarding** — in `scenes/onboarding/onboarding.gd` delete the `FAITHS` const, the `_faith` @onready, the `FaithLabel`/`FaithOpt` text + populate lines, and change `_on_start()` to call `GameManager.new_game(nm, age)` (no faith). In `onboarding.tscn` delete `FaithLabel` and `FaithOpt` nodes.

- [ ] **Step 3: GameManager** — change signature to `func new_game(creature_name: String = "Weatherling", age: int = 0) -> void:` and `_build_state(creature_name, age)`; in `_build_state` set `s.faith = "none"` explicitly (back-compat field). Update `_load_or_new()`'s default build call.

- [ ] **Step 4: Creature** — in `scenes/creature/creature.gd` remove `EventBus.devotion_time.connect(_on_devotion)` and the `_on_devotion()` function and the `DEVOTION` enum usage (leave enum value or drop; if dropped, ensure no references).

- [ ] **Step 5: Notifications + settings** — in `notification_service.gd` remove the `"faith"` entry from `CATEGORIES`. In `settings.gd` remove `"notify/faith": false` from `DEFAULTS`.

- [ ] **Step 6: Menu + Home** — in `menu_main.gd` remove `signal open_faith`, the `Faith` button text/connect lines; in `menu_main.tscn` remove the `Faith` button node. In `home.gd` remove `faith_panel` @onready + `menu.open_faith.connect(...)`; in `home.tscn` remove the `PanelFaith` ext_resource + node.

- [ ] **Step 7: Delete files**

```bash
rm -f autoload/faith_service.gd autoload/faith_service.gd.uid
rm -f resources/faith_profile.gd resources/faith_profile.gd.uid
rm -rf scenes/ui/panel_faith data/faiths
```

- [ ] **Step 8: Verify zero faith refs + clean import**

Run:
```bash
grep -rniE "faith|devotion|FaithService|FaithProfile" --include=*.gd --include=*.tscn --include=*.godot . | grep -v "creature_state.gd" | grep -v "docs/"
```
Expected: no matches except the intentional `CreatureState.faith` field in `resources/creature_state.gd` and `save_service.gd` PROPS list (those stay). If other matches remain, remove them.

Run: `"$GODOT" --headless --import 2>&1 | grep -iE "error|missing" ; echo done` → only `done`.

- [ ] **Step 9: Run tests + smoke**

Run: `"$GODOT" --headless -s tests/run_tests.gd` → `0 failed`.
Run: `"$GODOT" --path .` → onboarding (if no save) shows name/age/city only (no faith); Home menu has no Faith button; no console errors.

- [ ] **Step 10: Commit** (checkpoint) — all faith-removal edits + deletions. Msg: `refactor: remove faith subsystem (keep CreatureState.faith for save compat)`.

---

## Self-Review

**Spec coverage (F0+F1 sections):**
- §2.1 theme/palette → Tasks 1,3. §2.3 styleboxes → Task 2. §2.3 icons → Task 4.
- §4 SceneBackground + retire VFX → Tasks 5,6. §7 faith removal → Task 7.
- §2.2 fonts: deferred — fonts arrive as user assets; theme uses default font now (Global Constraint fallback). Font wiring belongs to a later asset-slot task (F6); not blocking F0+F1. (Gap is intentional and noted.)

**Placeholder scan:** Step 1 of Task 4 shows one full SVG and specifies the remaining 12 by exact shape — acceptable (geometry trivial, names fixed). No "TBD"/"handle edge cases". `color_fallback()` is a no-op by design (flat color comes from the `.tscn` ColorRect) — documented, not a placeholder.

**Type consistency:** `Palette` consts referenced by `UiFactory` and tests match. `SceneBackground.bg_key(int,String)->String` used identically in test and node. `GameManager.new_game` arity change propagated to onboarding + `_load_or_new`.

Out-of-scope (later plans): F2 HUD/nav/FAB, F3 onboarding visual reskin, F4 panel restyle, F5 minigames/room-decor/skill-graph/XP, F6 asset+font slotting + juice. Each gets its own plan.
