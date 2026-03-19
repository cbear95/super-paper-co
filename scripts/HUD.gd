extends CanvasLayer

@onready var _hearts  : HBoxContainer  = $Panel/M/Stats/HPRow/Hearts
@onready var _str_bar : ProgressBar    = $Panel/M/Stats/StrRow/Bar
@onready var _xp_bar  : ProgressBar    = $Panel/M/Stats/XPRow/Bar
@onready var _mnt_bar : ProgressBar    = $Panel/M/Stats/MntRow/Bar
@onready var _xp_lbl  : Label          = $Panel/M/Stats/XPRow/Lbl
@onready var _mnt_lbl : Label          = $Panel/M/Stats/MntRow/Lbl
@onready var _room_lbl: Label          = $RoomLabel
@onready var _task_pop: PanelContainer = $TaskPop
@onready var _task_lbl: Label          = $TaskPop/M/Title
@onready var _hurt_ov : ColorRect      = $HurtOverlay

var _hurt_t: float = 0.0
var _task_t: float = 0.0

func _ready() -> void:
	GameManager.stats_changed.connect(_refresh)
	GameManager.task_completed.connect(_task_done)
	RoomManager.room_changed.connect(_on_room)
	_task_pop.visible  = false
	_hurt_ov.color     = Color(1.0, 0.0, 0.1, 0.0)
	_hurt_ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_refresh()

func _process(delta: float) -> void:
	if _hurt_t > 0.0:
		_hurt_t -= delta
		_hurt_ov.color = Color(1.0, 0.0, 0.1, clampf(_hurt_t * 0.55, 0.0, 0.35))
	else:
		_hurt_ov.color = Color(1.0, 0.0, 0.1, 0.0)
	if _task_t > 0.0:
		_task_t -= delta
		if _task_t <= 0.0:
			_task_pop.visible = false

func _refresh() -> void:
	for c: Node in _hearts.get_children():
		c.queue_free()
	for i: int in range(GameManager.MAX_HP):
		var lbl: Label = Label.new()
		lbl.text = "\u2665" if i < GameManager.hp else "\u2661"
		lbl.add_theme_font_size_override("font_size", 22)
		if i < GameManager.hp:
			lbl.add_theme_color_override("font_color", Color(1.0, 0.2, 0.3, 1.0))
		else:
			lbl.add_theme_color_override("font_color", Color(0.28, 0.12, 0.16, 1.0))
		_hearts.add_child(lbl)
	_str_bar.value = GameManager.stress
	_xp_bar.value  = minf(float(GameManager.xp), 100.0)
	_mnt_bar.value = GameManager.mental
	_xp_lbl.text   = "XP %d" % GameManager.xp
	var m: float = GameManager.mental
	if m > 60.0:
		_mnt_lbl.text = "Grounded"
		_mnt_lbl.add_theme_color_override("font_color", Color(0.3, 0.88, 0.5, 1.0))
	elif m > 30.0:
		_mnt_lbl.text = "Strained"
		_mnt_lbl.add_theme_color_override("font_color", Color(0.9, 0.78, 0.2, 1.0))
	else:
		_mnt_lbl.text = "Fraying"
		_mnt_lbl.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2, 1.0))

func _task_done(_task_id: String) -> void:
	_task_lbl.text    = "\u2713  " + _task_id.replace("_", " ").capitalize()
	_task_pop.visible = true
	_task_t           = 4.0

func _on_room(room_name: String) -> void:
	_room_lbl.text = room_name
