## Display cutout (çentik/punch-hole) + gesture-nav güvenli alan padding'i.
## HUD CanvasLayer'a takılır. Bir kenara sabitlenmiş Control'leri güvenli alana iter,
## böylece üst rozetler çentik altına, alt aksiyon barı nav çubuğu altına gizlenmez.
## Tam ekran (dört kenara sabit) modallar ATLANIR — tam kaplama/dim için kasıtlı.
## Masaüstü/çentiksiz cihazda insetler 0 → görünür etki yok. (Plan §10, Android uyum)
extends CanvasLayer

var _base: Dictionary = {}   # Control -> {l,t,r,b} orijinal offset'ler


func _ready() -> void:
	for c in get_children():
		if c is Control:
			_base[c] = {"l": c.offset_left, "t": c.offset_top, "r": c.offset_right, "b": c.offset_bottom}
	get_viewport().size_changed.connect(_apply)
	_apply()


func _apply() -> void:
	var safe := DisplayServer.get_display_safe_area()
	var win := DisplayServer.window_get_size()
	if win.x <= 0 or win.y <= 0:
		return
	# Güvenli alan fiziksel pikselde; canvas_items+expand içerik birimine ölçekle.
	var vp := get_viewport().get_visible_rect().size
	var sx := vp.x / float(win.x)
	var sy := vp.y / float(win.y)
	var inset_top: float = safe.position.y * sy
	var inset_left: float = safe.position.x * sx
	var inset_right: float = (win.x - safe.end.x) * sx
	var inset_bottom: float = (win.y - safe.end.y) * sy
	for c in _base:
		if not is_instance_valid(c):
			continue
		var full: bool = c.anchor_left == 0.0 and c.anchor_top == 0.0 \
			and c.anchor_right == 1.0 and c.anchor_bottom == 1.0
		if full:
			continue  # modal: tam kaplama kalsın
		var b: Dictionary = _base[c]
		if c.anchor_top == 0.0:
			c.offset_top = b.t + inset_top
		if c.anchor_left == 0.0:
			c.offset_left = b.l + inset_left
		if c.anchor_right == 1.0:
			c.offset_right = b.r - inset_right
		if c.anchor_bottom == 1.0:
			c.offset_bottom = b.b - inset_bottom
