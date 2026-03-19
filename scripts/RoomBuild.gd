class_name RoomBuild
extends RefCounted

static var _npc_script: Script = preload("res://scripts/NPC.gd")
static var _exit_script: Script = preload("res://scripts/ExitZone.gd")
static var _task_script: Script = preload("res://scripts/TaskZone.gd")
static var _wind_script: Script = preload("res://scripts/WindSway.gd")

static func add_floor(parent: Node3D, size: Vector2, center: Vector3) -> void:
	var floor := StaticBody3D.new()
	floor.name = "Floor"
	floor.collision_layer = 2
	floor.position = center

	var mesh := MeshInstance3D.new()
	mesh.name = "FloorMesh"
	var plane := PlaneMesh.new()
	plane.size = size
	mesh.mesh = plane
	floor.add_child(mesh)

	var shape := CollisionShape3D.new()
	shape.name = "FloorShape"
	var box := BoxShape3D.new()
	box.size = Vector3(size.x, 0.2, size.y)
	shape.shape = box
	floor.add_child(shape)
	parent.add_child(floor)

static func add_wall(parent: Node3D, name: String, pos: Vector3, size: Vector3 = Vector3(1.0, 2.2, 1.0)) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.collision_layer = 4
	body.position = pos

	var mesh := MeshInstance3D.new()
	mesh.name = "Mesh"
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	body.add_child(mesh)

	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	body.add_child(shape)
	parent.add_child(body)

static func add_perimeter_walls(parent: Node3D, width: int, depth: int, gaps: Array[Vector3] = []) -> void:
	var gap_set := {}
	for gap: Vector3 in gaps:
		gap_set[_key(gap)] = true

	var idx: int = 0
	for x: int in range(width):
		for z: int in [0, depth - 1]:
			var pos := Vector3(x + 0.5, 1.1, z + 0.5)
			if not gap_set.has(_key(pos)):
				add_wall(parent, "W%d" % idx, pos)
				idx += 1
	for z: int in range(1, depth - 1):
		for x: int in [0, width - 1]:
			var pos := Vector3(x + 0.5, 1.1, z + 0.5)
			if not gap_set.has(_key(pos)):
				add_wall(parent, "W%d" % idx, pos)
				idx += 1

static func add_box_object(parent: Node3D, name: String, pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.collision_layer = 4
	body.position = pos

	var mesh := MeshInstance3D.new()
	mesh.name = "Mesh"
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	body.add_child(mesh)

	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	body.add_child(shape)
	parent.add_child(body)

static func add_press_machine(parent: Node3D, name: String, pos: Vector3, scale: float = 1.0) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.collision_layer = 4
	body.position = pos

	var collision := CollisionShape3D.new()
	collision.name = "Shape"
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.4, 1.8, 1.8) * scale
	collision.shape = shape
	body.add_child(collision)

	var chassis := MeshInstance3D.new()
	chassis.name = "Mesh"
	var chassis_mesh := BoxMesh.new()
	chassis_mesh.size = Vector3(2.4, 1.4, 1.8) * scale
	chassis.mesh = chassis_mesh
	chassis.position = Vector3(0.0, 0.45 * scale, 0.0)
	body.add_child(chassis)

	for i: int in range(2):
		var roller := MeshInstance3D.new()
		roller.name = "Roller%d" % i
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.22 * scale
		cyl.bottom_radius = 0.22 * scale
		cyl.height = 1.4 * scale
		roller.mesh = cyl
		roller.rotation_degrees = Vector3(90.0, 0.0, 0.0)
		roller.position = Vector3(-0.45 * scale + float(i) * 0.9 * scale, 0.65 * scale, 0.0)
		body.add_child(roller)

	var canopy := MeshInstance3D.new()
	canopy.name = "Canopy"
	var canopy_mesh := PrismMesh.new()
	canopy_mesh.size = Vector3(2.0, 0.45, 1.6) * scale
	canopy.mesh = canopy_mesh
	canopy.position = Vector3(0.0, 1.35 * scale, 0.0)
	body.add_child(canopy)

	parent.add_child(body)

static func add_exit(parent: Node3D, name: String, pos: Vector3, dest_room: String, spawn: Vector3, axis: String = "x") -> void:
	var area := Area3D.new()
	area.name = name
	area.script = _exit_script
	area.position = pos
	area.set("dest_room", dest_room)
	area.set("spawn_pos", spawn)
	area.set("door_axis", axis)

	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var box := BoxShape3D.new()
	box.size = Vector3(2.4, 1.8, 2.4)
	shape.shape = box
	area.add_child(shape)
	parent.add_child(area)

static func add_npc(
	parent: Node3D,
	name: String,
	pos: Vector3,
	npc_id: String,
	npc_name: String,
	npc_role: String,
	portrait: String,
	color: Color,
	lines: Array[String]
) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.script = _npc_script
	body.collision_layer = 4
	body.position = pos
	body.set("npc_id", npc_id)
	body.set("npc_name", npc_name)
	body.set("npc_role", npc_role)
	body.set("portrait_type", portrait)
	body.set("dial_color", color)
	body.set("stress_add", 1.0)
	body.set("xp_add", 4)
	body.set("boss_chance", 0.0)
	body.set("dial_sets", lines)

	var mesh := MeshInstance3D.new()
	mesh.name = "Mesh"
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.28
	capsule.height = 1.3
	mesh.mesh = capsule
	mesh.position = Vector3(0.0, 0.75, 0.0)
	body.add_child(mesh)

	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.28
	capsule_shape.height = 1.3
	shape.shape = capsule_shape
	shape.position = Vector3(0.0, 0.35, 0.0)
	body.add_child(shape)

	var hint := Label3D.new()
	hint.name = "Hint"
	hint.position = Vector3(0.0, 2.0, 0.0)
	hint.text = "[E] Talk"
	hint.font_size = 40
	hint.modulate = Color(1.0, 0.94, 0.3, 1.0)
	body.add_child(hint)

	parent.add_child(body)

static func add_task(parent: Node3D, name: String, pos: Vector3, task_id: String, title: String, desc: String) -> void:
	var area := Area3D.new()
	area.name = name
	area.script = _task_script
	area.position = pos
	area.set("task_id", task_id)
	area.set("task_title", title)
	area.set("task_desc", desc)
	area.set("xp_reward", 15)
	area.set("stress_cost", 4.0)

	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var box := BoxShape3D.new()
	box.size = Vector3(1.8, 1.5, 1.8)
	shape.shape = box
	area.add_child(shape)

	var hint := Label3D.new()
	hint.name = "Hint"
	hint.position = Vector3(0.0, 1.8, 0.0)
	hint.text = "[E] " + title
	hint.font_size = 34
	hint.modulate = Color(1.0, 0.90, 0.28, 1.0)
	area.add_child(hint)

	parent.add_child(area)

static func add_spotlight(parent: Node3D, pos: Vector3, color: Color, energy: float = 2.0) -> void:
	var light := SpotLight3D.new()
	light.position = pos
	light.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	light.light_color = color
	light.light_energy = energy
	light.spot_range = 18.0
	light.spot_angle = 42.0
	parent.add_child(light)

static func add_pennant_line(parent: Node3D, start: Vector3, count: int, spacing: float, color: Color) -> void:
	var root := Node3D.new()
	root.name = "Pennants"
	root.position = start
	parent.add_child(root)

	for i: int in range(count):
		var pivot := Node3D.new()
		pivot.name = "PennantPivot%d" % i
		pivot.position = Vector3(float(i) * spacing, 0.0, 0.0)
		pivot.script = _wind_script
		pivot.set("axis", Vector3(0.0, 0.0, 1.0))
		pivot.set("speed", 0.9 + float(i) * 0.08)
		pivot.set("amplitude_degrees", 6.0 + float(i % 2) * 3.0)
		pivot.set("bob_amount", 0.01)
		root.add_child(pivot)

		var mesh := MeshInstance3D.new()
		mesh.name = "Flag"
		var prism := PrismMesh.new()
		prism.size = Vector3(0.36, 0.48, 0.08)
		mesh.mesh = prism
		mesh.position = Vector3(0.0, -0.18, 0.0)
		mesh.rotation_degrees = Vector3(0.0, 90.0, 180.0)
		mesh.set_surface_override_material(0, _pennant_material(color))
		pivot.add_child(mesh)

static func _pennant_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = Color(color.r * 0.12, color.g * 0.12, color.b * 0.10)
	mat.emission_energy_multiplier = 0.18
	return mat

static func _key(v: Vector3) -> String:
	return "%0.2f|%0.2f|%0.2f" % [v.x, v.y, v.z]
