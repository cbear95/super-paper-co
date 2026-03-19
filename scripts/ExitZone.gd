extends Area3D

@export var dest_room: String  = "Hallway"
@export var spawn_pos: Vector3 = Vector3(2.0, 0.5, 2.0)

func _ready() -> void:
	body_entered.connect(_on_body)

func _on_body(body: Node) -> void:
	if body.is_in_group("player"):
		RoomManager.travel_to(dest_room, spawn_pos)
