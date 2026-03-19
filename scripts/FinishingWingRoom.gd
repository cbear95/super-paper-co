extends Node3D

const RoomBuildRef = preload("res://scripts/RoomBuild.gd")

func _ready() -> void:
	_build_room()

func _build_room() -> void:
	RoomBuildRef.add_floor(self, Vector2(22.0, 14.0), Vector3(11.0, 0.0, 7.0))

	var walls := Node3D.new()
	walls.name = "Walls"
	add_child(walls)
	RoomBuildRef.add_perimeter_walls(walls, 22, 14, [
		Vector3(0.5, 1.1, 7.5),
		Vector3(21.5, 1.1, 7.5),
	])

	var objects := Node3D.new()
	objects.name = "Objects"
	add_child(objects)
	_add_machine(objects, "MixerA", Vector3(5.5, 0.0, 4.5), Color(0.58, 0.72, 0.76, 1.0))
	_add_machine(objects, "FolderA", Vector3(10.0, 0.0, 4.5), Color(0.66, 0.74, 0.66, 1.0))
	_add_machine(objects, "BinderA", Vector3(14.5, 0.0, 4.5), Color(0.74, 0.68, 0.54, 1.0))
	_add_pallet_stack(objects, "PalletStackA", Vector3(5.5, 0.0, 9.5))
	_add_pallet_stack(objects, "PalletStackB", Vector3(8.2, 0.0, 9.6))
	_add_desk(objects, "QCDesk", Vector3(15.5, 0.0, 10.5))
	_add_machine(objects, "WrapStation", Vector3(18.2, 0.0, 9.4), Color(0.62, 0.64, 0.74, 1.0))
	_add_loose_roll(objects, "RollA", Vector3(11.6, 0.0, 9.6), 0.36)
	_add_loose_roll(objects, "RollB", Vector3(12.6, 0.0, 9.2), 0.28)
	RoomBuildRef.add_pennant_line(self, Vector3(4.5, 4.4, 8.5), 5, 2.6, Color(0.92, 0.64, 0.32, 1.0))
	RoomBuildRef.add_pennant_line(self, Vector3(6.0, 3.9, 11.2), 4, 2.8, Color(0.72, 0.88, 0.62, 1.0))
	_add_ceiling_lamp(Vector3(6.0, 4.6, 4.5), Color(0.98, 0.88, 0.70, 1.0), 1.1)
	_add_ceiling_lamp(Vector3(14.5, 4.6, 4.5), Color(0.88, 0.96, 1.00, 1.0), 1.0)
	_add_ceiling_lamp(Vector3(16.5, 4.3, 10.0), Color(0.96, 0.92, 0.78, 1.0), 0.9)

	var npcs := Node3D.new()
	npcs.name = "NPCs"
	add_child(npcs)
	RoomBuildRef.add_npc(
		npcs,
		"LenaQC",
		Vector3(14.5, 0.0, 11.5),
		"lena",
		"Lena Park",
		"Quality Control",
		"colleague_f",
		Color(0.40, 0.88, 0.62, 1.0),
		[
			"Samples can pass spec and still feel wrong in the hand.|That is why the human check stays.",
			"Good finishing makes the chemistry feel premium.|Bad finishing exposes every earlier compromise.",
		]
	)
	RoomBuildRef.add_npc(
		npcs,
		"MarcoShip",
		Vector3(18.0, 0.0, 11.0),
		"marco",
		"Marco Diaz",
		"Shipping Coordinator",
		"colleague_m",
		Color(0.92, 0.74, 0.30, 1.0),
		[
			"If you want a prototype to feel real, let it survive shipping.|Logistics is where fantasy goes to get audited.",
			"Every label is a promise.|Every damaged carton is a broken one.",
		]
	)

	var exits := Node3D.new()
	exits.name = "Exits"
	add_child(exits)
	RoomBuildRef.add_exit(exits, "ExitWarehouse", Vector3(0.5, 0.75, 7.5), "Warehouse", Vector3(13.5, 0.5, 7.5), "x")
	RoomBuildRef.add_exit(exits, "ExitPressHall", Vector3(21.5, 0.75, 7.5), "PressHall", Vector3(19.5, 0.5, 8.5), "x")

	var tasks := Node3D.new()
	tasks.name = "Tasks"
	add_child(tasks)
	RoomBuildRef.add_task(tasks, "TaskQC", Vector3(15.5, 0.75, 10.5), "finish_qc", "Finishing QC", "Review trim, fold memory, and coating consistency before approving the batch.")

func _add_machine(parent: Node3D, name: String, pos: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.collision_layer = 4
	body.position = pos
	parent.add_child(body)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.4, 1.5, 1.5)
	shape.shape = box
	shape.position = Vector3(0.0, 0.75, 0.0)
	body.add_child(shape)

	_add_box(body, Vector3(2.2, 0.84, 1.36), Vector3(0.0, 0.44, 0.0), color)
	_add_box(body, Vector3(2.0, 0.12, 1.2), Vector3(0.0, 1.00, 0.0), Color(0.88, 0.82, 0.68, 1.0))
	_add_box(body, Vector3(0.28, 0.58, 0.28), Vector3(-0.70, 1.24, 0.0), Color(0.46, 0.50, 0.54, 1.0))
	_add_box(body, Vector3(0.34, 0.18, 0.24), Vector3(0.56, 0.88, 0.0), Color(0.20, 0.34, 0.48, 1.0))

func _add_pallet_stack(parent: Node3D, name: String, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.collision_layer = 4
	body.position = pos
	parent.add_child(body)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.8, 1.1, 1.8)
	shape.shape = box
	shape.position = Vector3(0.0, 0.55, 0.0)
	body.add_child(shape)

	for i: int in range(3):
		_add_box(body, Vector3(1.8, 0.12, 1.8), Vector3(0.0, 0.10 + float(i) * 0.22, 0.0), Color(0.66, 0.48, 0.28, 1.0))
	_add_box(body, Vector3(1.46, 0.34, 1.46), Vector3(0.0, 0.78, 0.0), Color(0.82, 0.78, 0.66, 1.0))

func _add_desk(parent: Node3D, name: String, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.collision_layer = 4
	body.position = pos
	parent.add_child(body)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.0, 1.0, 1.2)
	shape.shape = box
	shape.position = Vector3(0.0, 0.5, 0.0)
	body.add_child(shape)

	_add_box(body, Vector3(2.0, 0.12, 1.2), Vector3(0.0, 0.78, 0.0), Color(0.82, 0.74, 0.60, 1.0))
	_add_box(body, Vector3(0.52, 0.34, 0.18), Vector3(-0.40, 0.98, 0.18), Color(0.22, 0.36, 0.48, 1.0))
	_add_box(body, Vector3(0.40, 0.24, 0.40), Vector3(0.56, 0.92, -0.10), Color(0.60, 0.68, 0.70, 1.0))
	for x: float in [-0.82, 0.82]:
		for z: float in [-0.42, 0.42]:
			_add_box(body, Vector3(0.10, 0.74, 0.10), Vector3(x, 0.36, z), Color(0.64, 0.60, 0.54, 1.0))

func _add_loose_roll(parent: Node3D, name: String, pos: Vector3, radius: float) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.collision_layer = 4
	body.position = pos
	parent.add_child(body)

	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = radius
	shape.shape = sphere
	shape.position = Vector3(0.0, radius, 0.0)
	body.add_child(shape)

	var roll := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = radius * 2.2
	roll.mesh = cyl
	roll.position = Vector3(0.0, radius, 0.0)
	roll.rotation_degrees = Vector3(0.0, 0.0, 90.0)
	roll.set_surface_override_material(0, _mat(Color(0.92, 0.90, 0.80, 1.0)))
	body.add_child(roll)

func _add_ceiling_lamp(pos: Vector3, color: Color, energy: float) -> void:
	var light := OmniLight3D.new()
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = 8.0
	add_child(light)

func _add_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.position = pos
	mi.set_surface_override_material(0, _mat(color))
	parent.add_child(mi)

func _mat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.84
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.rim_enabled = true
	mat.rim = 0.34
	mat.rim_tint = 0.16
	mat.emission_enabled = true
	mat.emission = Color(color.r * 0.08, color.g * 0.08, color.b * 0.08)
	mat.emission_energy_multiplier = 0.18
	return mat
