## Gün-gece ışığı: tüm sahneyi (layer 0) faza göre tonlar. (Plan §11.2, Faz 2)
## CanvasModulate çarpan: dawn ılık · day beyaz · dusk altın · night dim mavi.
## HUD ayrı CanvasLayer'da → tonlanmaz, okunur kalır.
extends CanvasModulate

const COLORS := {
	"dawn": Color(1.00, 0.82, 0.70),
	"day": Color(1.00, 1.00, 1.00),
	"dusk": Color(1.00, 0.72, 0.55),
	"night": Color(0.36, 0.42, 0.66),
}
const FADE := 1.5


func _ready() -> void:
	EventBus.time_phase_changed.connect(_on_phase_changed)
	color = COLORS.get(TimeService.get_phase(), Color.WHITE)  # açılışta anında


func _on_phase_changed(phase: String) -> void:
	var t := create_tween()
	t.tween_property(self, "color", COLORS.get(phase, Color.WHITE), FADE)
