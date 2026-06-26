## Skill node-graph çizim katmanı — node'lar arası bağlantı çizgileri. (Plan §6.4 görsel)
## panel_skills node'ları konumlandırır + add_link ile çizgi kaydeder.
extends Control

var _links: Array = []  # [[Vector2 from, Vector2 to, bool active], ...]


func clear_links() -> void:
	_links.clear()
	queue_redraw()


func add_link(a: Vector2, b: Vector2, active: bool) -> void:
	_links.append([a, b, active])
	queue_redraw()


func _draw() -> void:
	for l in _links:
		var col: Color = Palette.DUSK_AMBER if l[2] else Palette.OUTLINE_VARIANT
		draw_line(l[0], l[1], col, 3.0, true)
