extends Control

var portrait_type: String = "default"
var tint         : Color  = Color(0.4, 0.7, 1.0, 1.0)

func _draw() -> void:
	var pw: float = size.x
	var ph: float = size.y
	var cx: float = pw * 0.5
	draw_rect(Rect2(0.0, 0.0, pw, ph), Color(0.04, 0.07, 0.14, 1.0))
	draw_rect(Rect2(0.0, 0.0, pw, ph), Color(tint.r, tint.g, tint.b, 0.25), false, 1.5)

	if portrait_type == "task":
		var fnt: Font = ThemeDB.fallback_font
		draw_string(fnt, Vector2(cx - 16.0, ph * 0.62), "TASK",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1.0, 0.88, 0.24, 1.0))
		return

	var skin  : Color = Color(0.80, 0.60, 0.38, 1.0)
	var coat  : Color = tint
	var angry : bool  = false

	match portrait_type:
		"boss":
			skin  = Color(0.72, 0.40, 0.24, 1.0)
			coat  = Color(0.22, 0.05, 0.05, 1.0)
			angry = true
		"sales":
			coat  = Color(0.12, 0.24, 0.52, 1.0)

	# coat
	draw_rect(Rect2(cx - pw * 0.28, ph * 0.52, pw * 0.56, ph * 0.42), coat)
	# lapels for non-suit
	if portrait_type not in ["boss", "sales"]:
		draw_rect(Rect2(cx - pw * 0.28, ph * 0.52, pw * 0.13, ph * 0.42),
			Color(0.88, 0.88, 0.88, 1.0))
		draw_rect(Rect2(cx + pw * 0.15, ph * 0.52, pw * 0.13, ph * 0.42),
			Color(0.88, 0.88, 0.88, 1.0))
	# head
	draw_rect(Rect2(cx - pw * 0.18, ph * 0.14, pw * 0.36, ph * 0.36), skin)
	# hair
	draw_rect(Rect2(cx - pw * 0.18, ph * 0.10, pw * 0.36, ph * 0.10),
		Color(0.18, 0.11, 0.05, 1.0))
	# eyes
	draw_rect(Rect2(cx - pw * 0.13, ph * 0.21, pw * 0.09, ph * 0.08), Color.WHITE)
	draw_rect(Rect2(cx + pw * 0.04, ph * 0.21, pw * 0.09, ph * 0.08), Color.WHITE)
	draw_rect(Rect2(cx - pw * 0.10, ph * 0.23, pw * 0.05, ph * 0.05),
		Color(0.1, 0.1, 0.15, 1.0))
	draw_rect(Rect2(cx + pw * 0.06, ph * 0.23, pw * 0.05, ph * 0.05),
		Color(0.1, 0.1, 0.15, 1.0))
	if angry:
		draw_line(Vector2(cx - pw * 0.14, ph * 0.19),
			Vector2(cx - pw * 0.03, ph * 0.22), Color(0.10, 0.02, 0.02, 1.0), 2.5)
		draw_line(Vector2(cx + pw * 0.03, ph * 0.22),
			Vector2(cx + pw * 0.14, ph * 0.19), Color(0.10, 0.02, 0.02, 1.0), 2.5)
		draw_rect(Rect2(cx - pw * 0.09, ph * 0.35, pw * 0.18, ph * 0.04),
			Color(0.55, 0.08, 0.08, 1.0))
	else:
		draw_rect(Rect2(cx - pw * 0.07, ph * 0.36, pw * 0.14, ph * 0.03),
			Color(skin.r * 0.7, skin.g * 0.6, skin.b * 0.6, 1.0))
