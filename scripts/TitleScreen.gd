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
	var run_a := Color.from_hsv(fmod(0.05 + _t * 0.04, 1.0), 0.72, 1.0, 0.98)
	var run_b := Color.from_hsv(fmod(0.54 + _t * 0.05, 1.0), 0.70, 1.0, 0.98)
	if _super:
		_super.modulate = run_a
	if _title:
		_title.modulate = run_b
	if _super_shadow:
		_super_shadow.modulate = Color(0.18, 0.03, 0.16, 0.95)
	if _title_shadow:
		_title_shadow.modulate = Color(0.08, 0.02, 0.12, 0.95)
	if _sub:
		_sub.modulate = Color(1.0, 0.86, 0.64, 0.94)
	if _version:
		_version.modulate = Color(0.72, 0.88, 1.0, 0.82)
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
	draw_rect(Rect2(0.0, 0.0, sw, sh), Color(0.04, 0.03, 0.07, 1.0))
	for i: int in range(26):
		var p0: float = float(i) / 26.0
		var p1: float = float(i + 1) / 26.0
		var c := Color(0.10, 0.06, 0.12, 1.0).lerp(Color(0.96, 0.54, 0.26, 1.0), pow(p0, 1.6) * 0.92)
		draw_rect(Rect2(0.0, sh * p0, sw, sh * (p1 - p0) + 2.0), c)

	var horizon: float = sh * 0.70
	var haze_center := Vector2(sw * 0.56, sh * 0.34)
	draw_circle(haze_center, 156.0, Color(1.0, 0.58, 0.30, 0.10))
	draw_circle(haze_center + Vector2(-48.0, -14.0), 108.0, Color(0.24, 0.92, 1.0, 0.08))
	for xi: int in range(0, int(sw), 48):
		draw_line(Vector2(float(xi), horizon), Vector2(float(xi), sh), Color(0.24, 0.84, 1.0, 0.12), 1.0)
	for yi: int in range(0, 16):
		var y: float = lerpf(horizon, sh, float(yi) / 17.0)
		draw_line(Vector2(0.0, y), Vector2(sw, y), Color(0.24, 0.84, 1.0, 0.14), 1.0)

	var hill_1 := PackedVector2Array([
		Vector2(0.0, sh * 0.74),
		Vector2(sw * 0.14, sh * 0.66),
		Vector2(sw * 0.28, sh * 0.70),
		Vector2(sw * 0.42, sh * 0.60),
		Vector2(sw * 0.58, sh * 0.66),
		Vector2(sw * 0.74, sh * 0.58),
		Vector2(sw, sh * 0.64),
		Vector2(sw, sh),
		Vector2(0.0, sh),
	])
	draw_colored_polygon(hill_1, Color(0.13, 0.10, 0.17, 0.96))

	var hill_2 := PackedVector2Array([
		Vector2(0.0, sh * 0.82),
		Vector2(sw * 0.18, sh * 0.74),
		Vector2(sw * 0.32, sh * 0.78),
		Vector2(sw * 0.48, sh * 0.70),
		Vector2(sw * 0.62, sh * 0.76),
		Vector2(sw * 0.80, sh * 0.70),
		Vector2(sw, sh * 0.76),
		Vector2(sw, sh),
		Vector2(0.0, sh),
	])
	draw_colored_polygon(hill_2, Color(0.08, 0.08, 0.12, 0.98))

	for i: int in range(8):
		var x: float = sw * (0.05 + float(i) * 0.115)
		var w: float = 60.0 + float(i % 3) * 20.0
		var h: float = 120.0 + float((i * 31) % 120)
		var y_base: float = horizon - 8.0 + sin(_t * 0.4 + float(i)) * 4.0
		draw_rect(Rect2(x + 9.0, y_base - h + 8.0, w, h), Color(0.02, 0.00, 0.04, 0.42))
		draw_rect(Rect2(x, y_base - h, w, h), Color(0.05, 0.06, 0.08, 0.96))
		draw_rect(Rect2(x + 6.0, y_base - h + 18.0, w - 12.0, 4.0), Color(0.26, 0.92, 1.0, 0.20))
		draw_rect(Rect2(x + 6.0, y_base - h + 40.0, w - 12.0, 4.0), Color(1.0, 0.48, 0.56, 0.18))
		draw_rect(Rect2(x + 10.0, y_base - h + 66.0, w - 20.0, 3.0), Color(1.0, 0.72, 0.32, 0.14))

	var sun_center := Vector2(sw * 0.56, sh * 0.28)
	draw_circle(sun_center, 96.0, Color(0.96, 0.58, 0.28, 0.22))
	draw_circle(sun_center, 72.0, Color(1.0, 0.78, 0.44, 0.18))

	var ring_center := Vector2(sw * 0.56, sh * 0.28)
	draw_arc(ring_center, 102.0, 0.0, TAU, 96, Color(0.20, 0.92, 1.0, 0.34), 3.0)
	draw_arc(ring_center, 78.0, 0.0, TAU, 96, Color(1.0, 0.68, 0.34, 0.22), 2.0)
	draw_arc(ring_center + Vector2(-10.0, 14.0), 128.0, PI * 1.05, TAU * 1.02, 96, Color(0.92, 0.16, 0.76, 0.16), 4.0)
	draw_arc(ring_center + Vector2(20.0, -6.0), 148.0, PI * 1.12, TAU * 1.04, 96, Color(0.14, 0.88, 1.0, 0.10), 2.0)

	var shimmer_x: float = fmod(_t * 160.0, sw + 200.0) - 120.0
	draw_polygon(PackedVector2Array([
		Vector2(shimmer_x, 0.0),
		Vector2(shimmer_x + 120.0, 0.0),
		Vector2(shimmer_x + 240.0, sh),
		Vector2(shimmer_x + 120.0, sh),
	]), [Color(0.34, 0.92, 1.0, 0.0), Color(0.34, 0.92, 1.0, 0.16), Color(0.34, 0.92, 1.0, 0.02), Color(0.34, 0.92, 1.0, 0.0)])

	var amber_x: float = fmod(_t * 110.0 + 220.0, sw + 220.0) - 150.0
	draw_polygon(PackedVector2Array([
		Vector2(amber_x, 0.0),
		Vector2(amber_x + 90.0, 0.0),
		Vector2(amber_x + 180.0, sh),
		Vector2(amber_x + 60.0, sh),
	]), [Color(1.0, 0.64, 0.30, 0.0), Color(1.0, 0.64, 0.30, 0.10), Color(1.0, 0.64, 0.30, 0.0), Color(1.0, 0.64, 0.30, 0.0)])

	var scan_y: float = fmod(_t * 80.0, sh + 80.0) - 40.0
	draw_rect(Rect2(0.0, scan_y, sw, 6.0), Color(0.12, 0.84, 1.0, 0.08))
	for yi: int in range(0, int(sh), 4):
		draw_rect(Rect2(0.0, float(yi), sw, 1.0), Color(0.0, 0.0, 0.0, 0.08))
	for i: int in range(7):
		var band_y: float = sh * (0.16 + float(i) * 0.08) + sin(_t * 1.4 + float(i)) * 7.0
		draw_rect(Rect2(0.0, band_y, sw, 2.0), Color.from_hsv(fmod(0.07 * float(i) + _t * 0.04, 1.0), 0.56, 1.0, 0.18))
	for i: int in range(3):
		var stripe_y: float = sh * (0.24 + float(i) * 0.14)
		draw_rect(Rect2(sw * 0.18, stripe_y, sw * 0.64, 3.0), Color(0.08, 0.96, 1.0, 0.07))

	var line_w: float = 420.0
	draw_line(
		Vector2(sw * 0.5 - line_w * 0.5, sh * 0.58),
		Vector2(sw * 0.5 + line_w * 0.5, sh * 0.58),
		Color(0.16, 0.92, 1.0, 0.42 + 0.16 * sin(_t * 1.8)), 1.2)

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
