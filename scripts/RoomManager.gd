extends Node

signal room_changed(room_name: String)

const ROOM_SCENES: Dictionary = {
	"Lab":        "res://scenes/rooms/Lab.tscn",
	"Hallway":    "res://scenes/rooms/Hallway.tscn",
	"BossOffice": "res://scenes/rooms/BossOffice.tscn",
	"Warehouse":  "res://scenes/rooms/Warehouse.tscn",
	"PrintRoom":  "res://scenes/rooms/PrintRoom.tscn",
}

var current_room  : String  = "Lab"
var spawn_position: Vector3 = Vector3(5.0, 0.5, 5.0)

func travel_to(room_id: String, spawn: Vector3) -> void:
	current_room   = room_id
	spawn_position = spawn
	GameManager.current_room = room_id
	room_changed.emit(room_id)
	get_tree().call_deferred("change_scene_to_file", "res://scenes/GameWorld.tscn")
