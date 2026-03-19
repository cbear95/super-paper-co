extends Node2D

var _t    : float = 0.0
var _blink: bool  = false

@onready var _start: Label = $UI/StartLabel

func _process(delta: float) -> void:
	_t    += delta
	_blink = sin(_t * 3.2) > 0.0
	if _start:
		_start.visible = _blink
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		GameManager.reset_stats()
		RoomManager.travel_to("Lab", Vector3(5.0, 0.5, 5.0))

func _draw() -> void:
	var vp: Rect2  = get_viewport_rect()
	var sw: float  = vp.size.x
	var sh: float  = vp.size.y
	draw_rect(Rect2(0.0, 0.0, sw, sh), Color(0.024, 0.031, 0.063, 1.0))
	for xi: int in range(0, int(sw), 40):
		draw_line(Vector2(float(xi), 0.0), Vector2(float(xi), sh),
			Color(0.0, 0.24, 0.47, 0.13), 1.0)
	for yi: int in range(0, int(sh), 40):
		draw_line(Vector2(0.0, float(yi)), Vector2(sw, float(yi)),
			Color(0.0, 0.24, 0.47, 0.13), 1.0)
	var sy: float = fmod(_t * 38.0, 3.0)
	while sy < sh:
		draw_rect(Rect2(0.0, sy, sw, 1.5),
			Color(0.0, 0.7, 1.0, 0.035 + 0.018 * sin(sy * 0.05 + _t * 2.0)))
		sy += 3.0
	var lw: float = 320.0
	draw_line(
		Vector2(sw * 0.5 - lw * 0.5, sh * 0.54),
		Vector2(sw * 0.5 + lw * 0.5, sh * 0.54),
		Color(0.0, 0.78, 1.0, 0.65 + 0.2 * sin(_t * 1.4)), 1.0)
