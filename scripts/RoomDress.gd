class_name RoomDress
extends RefCounted

static var _pickup_script: Script = preload("res://scripts/PickupItem.gd")
static var _outline_shader: Shader = preload("res://shaders/outline_next_pass.gdshader")

static func apply_to_room(room: Node3D, room_name: String = "") -> void:
	if room == null:
		return
	var target_room := room_name if not room_name.is_empty() else RoomManager.current_room
	match target_room:
		"Lab":
			_dress_lab(room)
		"Warehouse":
			_dress_warehouse(room)
		"PrintRoom":
			_dress_print_room(room)
		"Hallway":
			_dress_hallway(room)

static func _dress_lab(room: Node3D) -> void:
	var objects: Node3D = room.get_node_or_null("Objects")
	if objects == null:
		return
	_mute_placeholders(objects)

	var decor := _ensure_child(room, "Decor")
	_add_lab_bench(decor, "BenchA", Vector3(3.5, 0.0, 2.5), 2.8)
	_add_lab_bench(decor, "BenchB", Vector3(8.2, 0.0, 2.5), 2.6)
	_add_cabinet(decor, "CabinetA", Vector3(11.4, 0.0, 4.5), Vector3(1.6, 1.3, 0.7))
	_add_cabinet(decor, "CabinetB", Vector3(2.6, 0.0, 7.0), Vector3(1.2, 1.6, 0.7))

	var pickups := _ensure_child(room, "Pickups")
	_add_pickup(pickups, "lab_solvent", "Loose Solvent Bottle", "solvent", 12, Vector3(3.9, 0.72, 2.3))
	_add_pickup(pickups, "lab_notepad", "Pen & Notepad", "supplies", 1, Vector3(8.6, 0.74, 2.3))
	_add_pickup(pickups, "lab_docs", "Confidential Document", "document", 18, Vector3(11.4, 0.86, 4.4))

static func _dress_warehouse(room: Node3D) -> void:
	var objects: Node3D = room.get_node_or_null("Objects")
	if objects == null:
		return
	_mute_placeholders(objects)

	var decor := _ensure_child(room, "Decor")
	_add_warehouse_rack(decor, "RackWest", Vector3(3.2, 0.0, 3.0), 3.2)
	_add_warehouse_rack(decor, "RackEast", Vector3(13.6, 0.0, 3.0), 3.2)
	_add_loose_roll(decor, "RollLooseA", Vector3(2.8, 0.0, 6.8), 0.42)
	_add_loose_roll(decor, "RollLooseB", Vector3(3.8, 0.0, 6.6), 0.34)
	_add_loose_roll(decor, "RollLooseC", Vector3(14.3, 0.0, 6.6), 0.38)

	var pickups := _ensure_child(room, "Pickups")
	_add_pickup(pickups, "warehouse_solvent", "Relief Solvent", "solvent", 10, Vector3(3.4, 0.70, 6.2))
	_add_pickup(pickups, "warehouse_supplies", "Emergency Notepad", "supplies", 1, Vector3(2.3, 0.66, 2.3))
	_add_pickup(pickups, "warehouse_docs", "Shipping Manifest", "document", 15, Vector3(13.5, 0.96, 3.0))

static func _dress_print_room(room: Node3D) -> void:
	var objects: Node3D = room.get_node_or_null("Objects")
	if objects == null:
		return
	_mute_placeholders(objects)

	var decor := _ensure_child(room, "Decor")
	_add_press_table(decor, "PressTableA", Vector3(5.5, 0.0, 3.5), 2.4)
	_add_press_table(decor, "PressTableB", Vector3(10.5, 0.0, 3.5), 2.4)
	_add_loose_roll(decor, "PrintRollA", Vector3(6.9, 0.0, 6.9), 0.26)
	_add_loose_roll(decor, "PrintRollB", Vector3(9.1, 0.0, 6.9), 0.26)

	var pickups := _ensure_child(room, "Pickups")
	_add_pickup(pickups, "print_solvent", "Cleaning Solvent", "solvent", 8, Vector3(5.4, 0.74, 3.1))
	_add_pickup(pickups, "print_docs", "Marked Proof Sheets", "document", 16, Vector3(10.5, 0.82, 3.1))

static func _dress_hallway(room: Node3D) -> void:
	var decor := _ensure_child(room, "Decor")
	_add_arch(decor, "HallArchA", Vector3(4.5, 0.0, 5.5), 2.4)
	_add_arch(decor, "HallArchB", Vector3(12.5, 0.0, 5.5), 2.4)

static func _add_domain_backdrop(room: Node3D, room_name: String) -> void:
	var backdrop := _ensure_child(room, "Backdrop")
	match room_name:
		"Lab":
			_add_hill_layer(backdrop, Vector3(8.0, 2.0, -4.5), Vector2(30.0, 8.0), Color(0.54, 0.72, 0.50, 1.0), -8.0)
			_add_hill_layer(backdrop, Vector3(8.0, 2.4, -6.6), Vector2(34.0, 10.0), Color(0.70, 0.80, 0.60, 1.0), -10.0)
		"Hallway":
			_add_hill_layer(backdrop, Vector3(8.0, 2.2, -4.2), Vector2(28.0, 8.0), Color(0.62, 0.66, 0.52, 1.0), -10.0)
		"Warehouse":
			_add_hill_layer(backdrop, Vector3(8.0, 2.0, -4.2), Vector2(30.0, 7.5), Color(0.58, 0.70, 0.68, 1.0), -10.0)
			_add_arch(backdrop, "WarehouseArch", Vector3(8.0, 0.0, -2.0), 3.4)
		"PrintRoom":
			_add_hill_layer(backdrop, Vector3(8.0, 2.2, -4.5), Vector2(28.0, 7.0), Color(0.74, 0.74, 0.58, 1.0), -12.0)
			_add_hill_layer(backdrop, Vector3(8.0, 2.8, -7.0), Vector2(36.0, 10.0), Color(0.84, 0.82, 0.62, 1.0), -14.0)

static func _add_hill_layer(parent: Node3D, pos: Vector3, size: Vector2, color: Color, z_offset: float) -> void:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)

	var mesh := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = size
	mesh.mesh = quad
	mesh.position = Vector3(0.0, 0.0, z_offset)
	mesh.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	mesh.set_surface_override_material(0, _mat_translucent(color))
	root.add_child(mesh)

static func _add_arch(parent: Node3D, name: String, pos: Vector3, width: float) -> void:
	var body := _body(name, pos + Vector3(0.0, 1.2, 0.0), Vector3(width, 2.4, 0.4))
	parent.add_child(body)
	_add_box_mesh(body, "Left", Vector3(0.34, 2.2, 0.36), Vector3(-width * 0.42, 0.0, 0.0), _mat(Color(0.70, 0.64, 0.52, 1.0)))
	_add_box_mesh(body, "Right", Vector3(0.34, 2.2, 0.36), Vector3(width * 0.42, 0.0, 0.0), _mat(Color(0.70, 0.64, 0.52, 1.0)))
	_add_box_mesh(body, "Top", Vector3(width * 0.76, 0.24, 0.34), Vector3(0.0, 0.90, 0.0), _mat(Color(0.82, 0.76, 0.62, 1.0)))

static func _mute_placeholders(objects: Node3D) -> void:
	for child: Node in objects.get_children():
		if child is CollisionObject3D:
			child.collision_layer = 0
			child.collision_mask = 0
		var mesh: MeshInstance3D = child.get_node_or_null("Mesh")
		if mesh:
			mesh.visible = false

static func _ensure_child(parent: Node3D, name: String) -> Node3D:
	var node: Node3D = parent.get_node_or_null(name)
	if node != null:
		for child: Node in node.get_children():
			child.queue_free()
		return node
	node = Node3D.new()
	node.name = name
	parent.add_child(node)
	return node

static func _add_pickup(parent: Node3D, pickup_id: String, item_name: String, kind: String, value: int, pos: Vector3) -> void:
	var area := Area3D.new()
	area.name = pickup_id
	area.script = _pickup_script
	area.position = pos
	area.set("pickup_id", pickup_id)
	area.set("item_name", item_name)
	area.set("item_kind", kind)
	area.set("value", value)
	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var sphere := SphereShape3D.new()
	sphere.radius = 0.34
	shape.shape = sphere
	area.add_child(shape)
	parent.add_child(area)

static func _add_lab_bench(parent: Node3D, name: String, pos: Vector3, width: float) -> void:
	var body := _body(name, pos + Vector3(0.0, 0.44, 0.0), Vector3(width, 1.0, 0.9))
	parent.add_child(body)

	_add_box_mesh(body, "Top", Vector3(width, 0.10, 0.90), Vector3(0.0, 0.42, 0.0), _mat(Color(0.80, 0.72, 0.58, 1.0)))
	for x: float in [-width * 0.42, width * 0.42]:
		for z: float in [-0.32, 0.32]:
			_add_box_mesh(body, "Leg", Vector3(0.10, 0.78, 0.10), Vector3(x, -0.02, z), _mat(Color(0.62, 0.64, 0.68, 1.0)))
	_add_box_mesh(body, "Shelf", Vector3(width * 0.82, 0.08, 0.58), Vector3(0.0, 0.04, 0.0), _mat(Color(0.70, 0.73, 0.76, 1.0)))
	_add_box_mesh(body, "Instrument", Vector3(0.44, 0.18, 0.28), Vector3(-width * 0.20, 0.58, 0.0), _mat(Color(0.34, 0.52, 0.64, 1.0)))
	_add_box_mesh(body, "Sink", Vector3(0.36, 0.08, 0.28), Vector3(width * 0.24, 0.52, 0.10), _mat(Color(0.54, 0.68, 0.72, 1.0)))

static func _add_cabinet(parent: Node3D, name: String, pos: Vector3, size: Vector3) -> void:
	var body := _body(name, pos + Vector3(0.0, size.y * 0.5, 0.0), size)
	parent.add_child(body)
	_add_box_mesh(body, "Cabinet", size, Vector3.ZERO, _mat(Color(0.62, 0.70, 0.72, 1.0)))
	_add_box_mesh(body, "Trim", Vector3(size.x * 0.86, 0.06, size.z * 0.92), Vector3(0.0, size.y * 0.36, 0.0), _mat(Color(0.86, 0.82, 0.66, 1.0)))

static func _add_warehouse_rack(parent: Node3D, name: String, pos: Vector3, length: float) -> void:
	var body := _body(name, pos + Vector3(0.0, 1.05, 0.0), Vector3(1.2, 2.2, length))
	parent.add_child(body)

	for x: float in [-0.46, 0.46]:
		for z: float in [-length * 0.40, length * 0.40]:
			_add_box_mesh(body, "Upright", Vector3(0.10, 2.10, 0.10), Vector3(x, 0.0, z), _mat(Color(0.46, 0.56, 0.54, 1.0)))
	for y: float in [0.65, 1.30]:
		_add_box_mesh(body, "Shelf", Vector3(1.02, 0.08, length * 0.88), Vector3(0.0, y - 1.05, 0.0), _mat(Color(0.68, 0.54, 0.34, 1.0)))
	for y: float in [0.40, 1.04]:
		_add_box_mesh(body, "BoxA", Vector3(0.42, 0.34, 0.46), Vector3(-0.20, y - 1.05, -0.68), _mat(Color(0.70, 0.66, 0.54, 1.0)))
		_add_box_mesh(body, "BoxB", Vector3(0.34, 0.30, 0.40), Vector3(0.18, y - 1.05, 0.34), _mat(Color(0.82, 0.74, 0.58, 1.0)))

static func _add_press_table(parent: Node3D, name: String, pos: Vector3, width: float) -> void:
	var body := _body(name, pos + Vector3(0.0, 0.55, 0.0), Vector3(width * 0.86, 0.96, 0.86))
	parent.add_child(body)
	_add_box_mesh(body, "Base", Vector3(width, 0.42, 1.12), Vector3(0.0, -0.14, 0.0), _mat(Color(0.54, 0.62, 0.64, 1.0)))
	_add_box_mesh(body, "Top", Vector3(width * 0.92, 0.10, 1.04), Vector3(0.0, 0.34, 0.0), _mat(Color(0.86, 0.80, 0.66, 1.0)))
	for x: float in [-width * 0.24, width * 0.24]:
		_add_cylinder_mesh(body, "Roller", 0.14, 0.96, Vector3(x, 0.16, 0.0), Vector3(90.0, 0.0, 0.0), _mat(Color(0.30, 0.42, 0.48, 1.0)))

static func _add_loose_roll(parent: Node3D, name: String, pos: Vector3, radius: float) -> void:
	var body := _body(name, pos + Vector3(0.0, radius, 0.0), Vector3(radius * 1.35, radius * 1.35, radius * 1.35))
	parent.add_child(body)
	_add_cylinder_mesh(body, "Roll", radius, radius * 2.2, Vector3.ZERO, Vector3(0.0, 0.0, 90.0), _mat(Color(0.90, 0.88, 0.80, 1.0)))
	_add_cylinder_mesh(body, "Core", radius * 0.28, radius * 2.34, Vector3.ZERO, Vector3(0.0, 0.0, 90.0), _mat(Color(0.62, 0.48, 0.30, 1.0)))

static func _body(name: String, pos: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name
	body.collision_layer = 4
	body.position = pos
	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	return body

static func _add_box_mesh(parent: Node3D, name: String, size: Vector3, pos: Vector3, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.set_surface_override_material(0, mat)
	parent.add_child(mi)

static func _add_cylinder_mesh(parent: Node3D, name: String, radius: float, height: float, pos: Vector3, rot: Vector3, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot
	mi.set_surface_override_material(0, mat)
	parent.add_child(mi)

static func _mat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.82
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.rim_enabled = true
	mat.rim = 0.30
	mat.rim_tint = 0.14
	mat.emission_enabled = true
	mat.emission = Color(color.r * 0.09, color.g * 0.09, color.b * 0.08)
	mat.emission_energy_multiplier = 0.18
	mat.next_pass = _outline_mat(color)
	return mat

static func _mat_translucent(color: Color) -> StandardMaterial3D:
	var mat := _mat(color)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.92
	return mat

static func _outline_mat(color: Color) -> ShaderMaterial:
	var outline := ShaderMaterial.new()
	outline.shader = _outline_shader
	outline.set_shader_parameter("outline_color", Color(color.r * 0.12, color.g * 0.12, color.b * 0.14, 1.0))
	outline.set_shader_parameter("outline_width", 0.028)
	return outline
