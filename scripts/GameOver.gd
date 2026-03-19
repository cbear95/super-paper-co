extends Node2D

var _t: float = 0.0

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return
	if event.is_action_pressed("ui_accept"):
		GameManager.reset_stats()
		get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")

func _draw() -> void:
	var vp: Rect2 = get_viewport_rect()
	draw_rect(Rect2(0.0, 0.0, vp.size.x, vp.size.y), Color(0.04, 0.005, 0.005, 1.0))
	for yi: int in range(0, int(vp.size.y), 4):
		draw_rect(Rect2(0.0, float(yi), vp.size.x, 1.5), Color(0.55, 0.0, 0.0, 0.07))
