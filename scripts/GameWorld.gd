extends Node3D

@onready var _container: Node3D          = $RoomContainer
@onready var _player   : CharacterBody3D = $Player
@onready var _cam      : Camera3D        = $IsoCamera

func _ready() -> void:
	_load_room()
	_player.global_position = RoomManager.spawn_position
	var cam_node: Camera3D = _cam
	cam_node.set("target", _player)

func _load_room() -> void:
	for c: Node in _container.get_children():
		c.queue_free()
	var path: String = RoomManager.ROOM_SCENES.get(RoomManager.current_room, "")
	if path.is_empty():
		push_error("No scene path for room: " + RoomManager.current_room)
		return
	var packed: PackedScene = load(path)
	if packed == null:
		push_error("Could not load: " + path)
		return
	_container.add_child(packed.instantiate())
