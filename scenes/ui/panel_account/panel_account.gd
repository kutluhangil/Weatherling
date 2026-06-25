## Profil & Hesap — giriş, senkron, çıkış, dışa aktar, hesap sil. (Plan §13, §16)
## Bulut yapılandırılmadıysa (SUPABASE_URL boş) yalnızca misafir/yerel gösterilir.
extends Control

@onready var _status: Label = $Panel/VBox/Status
@onready var _email: LineEdit = $Panel/VBox/EmailEdit
@onready var _pass: LineEdit = $Panel/VBox/PassEdit


func _ready() -> void:
	visible = false
	$Panel/VBox/Title.text = tr("MENU_ACCOUNT")
	_email.placeholder_text = tr("EMAIL")
	_pass.placeholder_text = tr("PASSWORD")
	_pass.secret = true
	$Panel/VBox/SignIn.text = tr("SIGN_IN")
	$Panel/VBox/SignUp.text = tr("SIGN_UP")
	$Panel/VBox/Magic.text = tr("MAGIC_LINK")
	$Panel/VBox/Guest.text = tr("GUEST_CONTINUE")
	$Panel/VBox/SignOut.text = tr("SIGN_OUT")
	$Panel/VBox/Export.text = tr("EXPORT_DATA")
	$Panel/VBox/Delete.text = tr("DELETE_ACCOUNT")
	$Panel/VBox/Close.text = tr("CLOSE")

	$Panel/VBox/SignIn.pressed.connect(func(): AuthService.sign_in_email(_email.text.strip_edges(), _pass.text))
	$Panel/VBox/SignUp.pressed.connect(func(): AuthService.sign_up_email(_email.text.strip_edges(), _pass.text))
	$Panel/VBox/Magic.pressed.connect(func(): AuthService.send_magic_link(_email.text.strip_edges()))
	$Panel/VBox/Guest.pressed.connect(func(): AuthService.sign_in_guest())
	$Panel/VBox/SignOut.pressed.connect(func(): AuthService.sign_out())
	$Panel/VBox/Export.pressed.connect(_on_export)
	$Panel/VBox/Delete.pressed.connect(func(): AuthService.delete_account())
	$Panel/VBox/Close.pressed.connect(close)
	$Dim.gui_input.connect(_on_dim_input)
	EventBus.auth_state_changed.connect(_on_auth_changed)


func open() -> void:
	_refresh_status()
	visible = true


func close() -> void:
	visible = false


func _on_export() -> void:
	var path := SaveService.export_json()
	_status.text = (tr("EXPORTED") + " " + path) if path != "" else "—"


func _on_auth_changed(s: String) -> void:
	match s:
		"check_email":
			_status.text = tr("CHECK_EMAIL")
		"error_unconfigured":
			_status.text = tr("ACCOUNT_UNCONFIGURED")
		"error_auth", "error_network":
			_status.text = tr("ACCOUNT_ERROR")
		_:
			_refresh_status()


func _refresh_status() -> void:
	if not AuthService.is_configured():
		_status.text = tr("ACCOUNT_UNCONFIGURED")
	elif AuthService.is_signed_in():
		_status.text = "✓ " + AuthService.email
	else:
		_status.text = tr("ACCOUNT_GUEST")


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
