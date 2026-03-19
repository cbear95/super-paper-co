extends Node

signal dialogue_started
signal dialogue_finished

var is_active: bool = false
var _box: Node = null

func register_box(box: Node) -> void:
	_box = box

func start(npc_name: String, npc_role: String, portrait: String,
		color: Color, lines: Array, on_finish: Callable = Callable()) -> void:
	if _box == null:
		return
	is_active = true
	_box.begin(npc_name, npc_role, portrait, color, lines, on_finish)
	dialogue_started.emit()

func finish() -> void:
	is_active = false
	dialogue_finished.emit()
