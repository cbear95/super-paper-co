extends CanvasLayer

const SPEED_NORM: float = 0.030
const SPEED_FAST: float = 0.008

var _lines  : Array    = []
var _lidx   : int      = 0
var _cidx   : int      = 0
var _ctimer : float    = 0.0
var _on_fin : Callable = Callable()
var _color  : Color    = Color.WHITE
var _ptype  : String   = "default"

@onready var _panel   : PanelContainer = $Panel
@onready var _nname   : Label          = $Panel/M/VBox/Header/Name
@onready var _nrole   : Label          = $Panel/M/VBox/Header/Role
@onready var _portrait: Control        = $Panel/M/VBox/Body/Portrait
@onready var _txt     : RichTextLabel  = $Panel/M/VBox/Body/Text
@onready var _cont    : Label          = $Panel/M/VBox/Footer/Hint
@onready var _dots    : HBoxContainer  = $Panel/M/VBox/Footer/Dots

func _ready() -> void:
	DialogueManager.register_box(self)
	_panel.visible = false

func begin(nn: String, nr: String, pt: String, col: Color,
		lines: Array, on_fin: Callable) -> void:
	_lines  = lines
	_lidx   = 0
	_cidx   = 0
	_ctimer = 0.0
	_on_fin = on_fin
	_color  = col
	_ptype  = pt
	_nname.text = nn
	_nname.add_theme_color_override("font_color", col)
	_nrole.text = nr
	_portrait.set("portrait_type", pt)
	_portrait.set("tint", col)
	_portrait.queue_redraw()
	_panel.visible = true
	_txt.text      = ""
	_cont.visible  = false
	_rebuild_dots()

func _process(delta: float) -> void:
	if not _panel.visible:
		return
	var line: String = _lines[_lidx]
	if _cidx < line.length():
		_ctimer += delta
		var spd: float = SPEED_FAST if Input.is_action_pressed("ui_accept") else SPEED_NORM
		while _ctimer >= spd and _cidx < line.length():
			_cidx   += 1
			_ctimer -= spd
		_txt.text     = line.substr(0, _cidx)
		_cont.visible = false
	else:
		_cont.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if event is InputEventMouseMotion:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		_advance()
		get_viewport().set_input_as_handled()

func _advance() -> void:
	var line: String = _lines[_lidx]
	if _cidx < line.length():
		_cidx     = line.length()
		_txt.text = line
		return
	_lidx += 1
	if _lidx >= _lines.size():
		_close()
	else:
		_cidx         = 0
		_ctimer       = 0.0
		_txt.text     = ""
		_cont.visible = false
		_rebuild_dots()

func _close() -> void:
	_panel.visible = false
	DialogueManager.finish()
	if _on_fin.is_valid():
		_on_fin.call()

func _rebuild_dots() -> void:
	for c: Node in _dots.get_children():
		c.queue_free()
	for i: int in range(_lines.size()):
		var d: ColorRect = ColorRect.new()
		d.custom_minimum_size = Vector2(8.0, 8.0)
		d.color = _color if i == _lidx else Color(0.2, 0.28, 0.38, 0.6)
		_dots.add_child(d)
