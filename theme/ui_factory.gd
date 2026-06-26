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
