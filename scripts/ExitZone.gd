extends Area3D

@export var dest_room  : String  = "Hallway"
@export var spawn_pos  : Vector3 = Vector3(2.0, 0.5, 2.0)
## Which wall the door is on: "x" (left/right wall) or "z" (front/back wall)
@export var door_axis  : String  = "x"

func _ready() -> void:
	body_entered.connect(_on_body)
	_build_door_visual()

func _on_body(body: Node) -> void:
	if body.is_in_group("player"):
		RoomManager.travel_to(dest_room, spawn_pos)

func _build_door_visual() -> void:
	# Glowing portal frame that fills the gap where the wall was removed.
	# door_axis "x" = door faces X (left/right room wall)
	# door_axis "z" = door faces Z (front/back room wall)
	var frame := MeshInstance3D.new()
	var bm    := BoxMesh.new()
	if door_axis == "x":
		bm.size = Vector3(0.18, 2.1, 1.05)
	else:
		bm.size = Vector3(1.05, 2.1, 0.18)
	frame.mesh = bm
	frame.position = Vector3(0.0, 0.35, 0.0)

	var mat := StandardMaterial3D.new()
	mat.albedo_color              = Color(0.05, 0.85, 0.78, 0.55)
	mat.transparency              = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled          = true
	mat.emission                  = Color(0.02, 0.55, 0.50)
	mat.emission_energy_multiplier = 1.2
	mat.roughness                 = 0.4
	frame.set_surface_override_material(0, mat)
	add_child(frame)

	# Small room-label above the portal
	var lbl := Label3D.new()
	lbl.text      = "→ " + dest_room
	lbl.font_size = 32
	lbl.modulate  = Color(0.0, 0.95, 0.85, 0.9)
	lbl.position  = Vector3(0.0, 1.55, 0.0)
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(lbl)
