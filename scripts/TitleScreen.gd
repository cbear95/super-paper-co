extends Node2D

var _t    : float = 0.0
var _blink: bool  = false

@onready var _start: Label = $UI/StartLabel
@onready var _bgm: AudioStreamPlayer = $BGMPlayer
@onready var _super: Label = $UI/SuperLabel
@onready var _super_shadow: Label = $UI/SuperShadow
@onready var _title: Label = $UI/TitleLabel
@onready var _title_shadow: Label = $UI/TitleShadow
@onready var _sub: Label = $UI/SubLabel
@onready var _version: Label = $UI/VersionLabel

func _ready() -> void:
	_start_bgm()

func _process(delta: float) -> void:
	_t    += delta
	_blink = sin(_t * 3.2) > 0.0
	if _start:
		_start.visible = _blink
	var run_a := Color.from_hsv(fmod(_t * 0.08, 1.0), 0.82, 1.0, 0.96)
	var run_b := Color.from_hsv(fmod(0.62 + _t * 0.08, 1.0), 0.78, 1.0, 0.98)
	if _super:
		_super.modulate = run_a
	if _title:
		_title.modulate = run_b
	if _super_shadow:
		_super_shadow.modulate = Color(0.24, 0.04, 0.22, 0.95)
	if _title_shadow:
		_title_shadow.modulate = Color(0.10, 0.02, 0.16, 0.95)
	if _sub:
		_sub.modulate = Color(0.42, 0.84, 1.0, 0.92)
	if _version:
		_version.modulate = Color(0.34, 0.62, 0.86, 0.80)
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
	draw_rect(Rect2(0.0, 0.0, sw, sh), Color(0.018, 0.020, 0.046, 1.0))
	for i: int in range(18):
		var p0: float = float(i) / 18.0
		var p1: float = float(i + 1) / 18.0
		var c := Color(0.04, 0.08, 0.20, 1.0).lerp(Color(0.13, 0.02, 0.18, 1.0), p0)
		draw_rect(Rect2(0.0, sh * p0, sw, sh * (p1 - p0) + 2.0), c)

	var horizon: float = sh * 0.62
	for xi: int in range(0, int(sw), 44):
		draw_line(Vector2(float(xi), horizon), Vector2(float(xi), sh), Color(0.16, 0.82, 1.0, 0.18), 1.0)
	for yi: int in range(0, 18):
		var y: float = lerpf(horizon, sh, float(yi) / 17.0)
		draw_line(Vector2(0.0, y), Vector2(sw, y), Color(0.16, 0.82, 1.0, 0.20), 1.0)

	var tower_color := Color(0.04, 0.08, 0.12, 0.95)
	for i: int in range(8):
		var x: float = sw * (0.05 + float(i) * 0.11)
		var w: float = 44.0 + float(i % 3) * 18.0
		var h: float = 110.0 + float((i * 37) % 120)
		draw_rect(Rect2(x, horizon - h, w, h), tower_color)
		draw_rect(Rect2(x + 6.0, horizon - h + 12.0, w - 12.0, 3.0), Color(0.18, 0.96, 1.0, 0.22))
		draw_rect(Rect2(x + 6.0, horizon - h + 32.0, w - 12.0, 3.0), Color(1.0, 0.20, 0.78, 0.18))

	var ring_center := Vector2(sw * 0.5, sh * 0.28)
	draw_arc(ring_center, 92.0, 0.0, TAU, 80, Color(0.24, 0.94, 1.0, 0.36), 3.0)
	draw_arc(ring_center, 70.0, 0.0, TAU, 80, Color(1.0, 0.18, 0.74, 0.22), 2.0)
	draw_arc(ring_center + Vector2(0.0, 12.0), 116.0, PI, TAU, 80, Color(0.92, 0.20, 0.80, 0.18), 4.0)

	var scan_y: float = fmod(_t * 80.0, sh + 80.0) - 40.0
	draw_rect(Rect2(0.0, scan_y, sw, 6.0), Color(0.12, 0.84, 1.0, 0.07))
	for yi: int in range(0, int(sh), 4):
		draw_rect(Rect2(0.0, float(yi), sw, 1.0), Color(0.0, 0.0, 0.0, 0.08))
	for i: int in range(5):
		var band_y: float = sh * (0.18 + float(i) * 0.10) + sin(_t * 1.6 + float(i)) * 8.0
		draw_rect(Rect2(0.0, band_y, sw, 2.0), Color.from_hsv(fmod(0.12 * float(i) + _t * 0.06, 1.0), 0.86, 1.0, 0.18))

	var line_w: float = 360.0
	draw_line(
		Vector2(sw * 0.5 - line_w * 0.5, sh * 0.55),
		Vector2(sw * 0.5 + line_w * 0.5, sh * 0.55),
		Color(0.10, 0.92, 1.0, 0.72 + 0.18 * sin(_t * 1.8)), 1.4)

func _start_bgm() -> void:
	if _bgm == null:
		return
	var stream: AudioStream = _load_bgm_stream()
	if stream == null:
		push_warning("TitleScreen missing soundtrack file: res://SuperPaperCo.mp3")
		return
	_bgm.stream = stream
	_bgm.volume_db = -9.0
	_bgm.play()

func _load_bgm_stream() -> AudioStream:
	if ResourceLoader.exists("res://SuperPaperCo.mp3"):
		var imported: AudioStream = load("res://SuperPaperCo.mp3")
		if imported != null:
			if imported.has_method("set_loop"):
				imported.set_loop(true)
			return imported

	if not FileAccess.file_exists("res://SuperPaperCo.mp3"):
		return null

	var mp3 := AudioStreamMP3.new()
	mp3.data = FileAccess.get_file_as_bytes("res://SuperPaperCo.mp3")
	mp3.loop = true
	return mp3
