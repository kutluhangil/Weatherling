## İnanç paneli — geleneği değiştir veya kapat (none). (Plan §8, §10.2)
## Saygı: her an değiştirilebilir/kapatılabilir; ceza yok.
extends Control

const FAITHS := [
	["none", "FAITH_NONE"], ["islam", "FAITH_ISLAM"], ["christianity", "FAITH_CHRISTIANITY"],
	["judaism", "FAITH_JUDAISM"], ["hinduism", "FAITH_HINDUISM"], ["buddhism", "FAITH_BUDDHISM"],
	["spiritual", "FAITH_SPIRITUAL"],
]

@onready var _opt: OptionButton = $Panel/VBox/FaithOpt
@onready var _apply: Button = $Panel/VBox/Apply
@onready var _close: Button = $Panel/VBox/Close
@onready var _title: Label = $Panel/VBox/Title


func _ready() -> void:
	visible = false
	_title.text = tr("ONBOARD_FAITH")
	_apply.text = tr("APPLY")
	_close.text = tr("CLOSE")
	for f in FAITHS:
		_opt.add_item(tr(f[1]))
	_apply.pressed.connect(_on_apply)
	_close.pressed.connect(close)
	$Dim.gui_input.connect(_on_dim_input)


func open() -> void:
	for i in FAITHS.size():
		if FAITHS[i][0] == FaithService.current_faith:
			_opt.selected = i
	visible = true


func close() -> void:
	visible = false


func _on_apply() -> void:
	var id: String = FAITHS[_opt.selected][0] if _opt.selected >= 0 else "none"
	var s: CreatureState = GameManager.current_state()
	if s != null:
		s.faith = id
	FaithService.set_faith(id)
	GameManager.save_now()
	close()


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
