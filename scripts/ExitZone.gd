extends Area3D

@export var dest_room  : String  = "Hallway"
@export var spawn_pos  : Vector3 = Vector3(2.0, 0.5, 2.0)
## Which wall the door is on: "x" (left/right wall) or "z" (front/back wall)
@export var door_axis  : String  = "x"

var _portal_core: MeshInstance3D = null
var _portal_rune: MeshInstance3D = null
var _door_leaf_left: MeshInstance3D = null
var _door_leaf_right: MeshInstance3D = null
var _streamers: Array[Node3D] = []

func _ready() -> void:
	monitoring = true
	monitorable = true
	collision_layer = 1
	collision_mask = 1
	_configure_trigger_shape()
	body_entered.connect(_on_body)
	_build_door_visual()
	set_process(true)

func _process(delta: float) -> void:
	if _portal_core == null or _portal_rune == null:
		return
	var t: float = Time.get_ticks_msec() * 0.001
	var pulse: float = (sin(t * 2.1) + 1.0) * 0.5
	_portal_core.scale.y = lerpf(0.98, 1.02, pulse)
	_portal_core.scale.x = lerpf(0.98, 1.02, pulse)
	_portal_core.scale.z = lerpf(0.98, 1.02, pulse)
	_portal_rune.rotation.y += delta * 0.24
	if _door_leaf_left:
		_door_leaf_left.position.y = 0.40 + sin(t * 1.4) * 0.01
	if _door_leaf_right:
		_door_leaf_right.position.y = 0.40 + cos(t * 1.4) * 0.01
	for i: int in range(_streamers.size()):
		var streamer := _streamers[i]
		var sway: float = sin(t * (1.6 + float(i) * 0.22) + float(i)) * 0.22
		streamer.rotation.z = sway
		streamer.rotation.x = sway * 0.16

func _on_body(body: Node) -> void:
	if body.is_in_group("player"):
		RoomManager.travel_to(dest_room, spawn_pos)

func _configure_trigger_shape() -> void:
	var shape_node: CollisionShape3D = get_node_or_null("Shape")
	if shape_node == null or shape_node.shape == null:
		return
	if shape_node.shape is BoxShape3D:
		var box: BoxShape3D = shape_node.shape
		if door_axis == "x":
			box.size = Vector3(1.8, 1.8, 2.2)
		else:
			box.size = Vector3(2.2, 1.8, 1.8)

func _build_door_visual() -> void:
	# Replace the abstract portal slab with a readable arch + double-door silhouette.
	var depth: float = 0.24
	var span: float = 1.02
	var frame_mat := _make_stone_material()
	var door_mat := _make_door_material()
	var glow_mat := _make_portal_material()
	var accent_mat := _make_accent_material()
	var lantern_mat := _make_lantern_material()
	var cloth_mat := _make_streamer_material(1)
	_streamers.clear()

	if door_axis == "x":
		_add_box("LeftPost", Vector3(depth, 2.0, 0.20), Vector3(0.0, 0.46, -0.48), frame_mat)
		_add_box("RightPost", Vector3(depth, 2.0, 0.20), Vector3(0.0, 0.46, 0.48), frame_mat)
		_add_box("Lintel", Vector3(depth, 0.22, span * 1.06), Vector3(0.0, 1.42, 0.0), frame_mat)
		_add_box("Crown", Vector3(depth * 0.9, 0.14, span * 0.72), Vector3(0.0, 1.56, 0.0), accent_mat)
		_add_box("Threshold", Vector3(depth * 0.8, 0.10, span * 0.86), Vector3(0.0, -0.02, 0.0), accent_mat)
		_door_leaf_left = _add_box("DoorLeafLeft", Vector3(depth * 0.42, 1.48, 0.34), Vector3(0.0, 0.40, -0.19), door_mat)
		_door_leaf_right = _add_box("DoorLeafRight", Vector3(depth * 0.42, 1.48, 0.34), Vector3(0.0, 0.40, 0.19), door_mat)
		_add_box("LanternNorth", Vector3(depth * 0.5, 0.22, 0.16), Vector3(0.0, 0.92, -0.64), lantern_mat)
		_add_box("LanternSouth", Vector3(depth * 0.5, 0.22, 0.16), Vector3(0.0, 0.92, 0.64), lantern_mat)
		_add_box("ClothTop", Vector3(depth * 0.64, 0.12, 0.90), Vector3(0.0, 1.18, 0.0), cloth_mat)
		_portal_core = _add_box("PortalCore", Vector3(depth * 0.2, 1.18, 0.04), Vector3(0.0, 0.42, 0.0), glow_mat)
		_portal_rune = _add_diamond("PortalRune", Vector3(depth * 0.26, 0.22, 0.18), Vector3(0.0, 0.54, 0.0), glow_mat)
	else:
		_add_box("LeftPost", Vector3(0.20, 2.0, depth), Vector3(-0.48, 0.46, 0.0), frame_mat)
		_add_box("RightPost", Vector3(0.20, 2.0, depth), Vector3(0.48, 0.46, 0.0), frame_mat)
		_add_box("Lintel", Vector3(span * 1.06, 0.22, depth), Vector3(0.0, 1.42, 0.0), frame_mat)
		_add_box("Crown", Vector3(span * 0.72, 0.14, depth * 0.9), Vector3(0.0, 1.56, 0.0), accent_mat)
		_add_box("Threshold", Vector3(span * 0.86, 0.10, depth * 0.8), Vector3(0.0, -0.02, 0.0), accent_mat)
		_door_leaf_left = _add_box("DoorLeafLeft", Vector3(0.34, 1.48, depth * 0.42), Vector3(-0.19, 0.40, 0.0), door_mat)
		_door_leaf_right = _add_box("DoorLeafRight", Vector3(0.34, 1.48, depth * 0.42), Vector3(0.19, 0.40, 0.0), door_mat)
		_add_box("LanternWest", Vector3(0.16, 0.22, depth * 0.5), Vector3(-0.64, 0.92, 0.0), lantern_mat)
		_add_box("LanternEast", Vector3(0.16, 0.22, depth * 0.5), Vector3(0.64, 0.92, 0.0), lantern_mat)
		_add_box("ClothTop", Vector3(0.90, 0.12, depth * 0.64), Vector3(0.0, 1.18, 0.0), cloth_mat)
		_portal_core = _add_box("PortalCore", Vector3(0.04, 1.18, depth * 0.2), Vector3(0.0, 0.42, 0.0), glow_mat)
		_portal_rune = _add_diamond("PortalRune", Vector3(0.18, 0.22, depth * 0.26), Vector3(0.0, 0.54, 0.0), glow_mat)

	# Small room-label above the portal.
	var lbl := Label3D.new()
	lbl.text      = dest_room
	lbl.font_size = 32
	lbl.modulate  = Color(0.96, 0.92, 0.72, 0.92)
	lbl.position  = Vector3(0.0, 1.72, 0.0)
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(lbl)
	_add_streamers()

func _add_box(
	name: String,
	size: Vector3,
	offset: Vector3,
	material: Material,
	add_collision: bool = false
) -> MeshInstance3D:
	var body: Node3D = self
	if add_collision:
		var collider := StaticBody3D.new()
		collider.name = name
		collider.collision_layer = 4
		collider.position = offset
		var shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = size
		shape.shape = box_shape
		collider.add_child(shape)
		add_child(collider)
		body = collider

	var mi := MeshInstance3D.new()
	mi.name = "Mesh"
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.position = Vector3.ZERO if add_collision else offset
	mi.set_surface_override_material(0, material)
	body.add_child(mi)
	return mi

func _add_diamond(name: String, size: Vector3, offset: Vector3, material: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var prism := PrismMesh.new()
	prism.size = size
	mi.mesh = prism
	mi.position = offset
	mi.rotation_degrees = Vector3(0.0, 45.0, 90.0 if door_axis == "x" else 0.0)
	mi.set_surface_override_material(0, material)
	add_child(mi)
	return mi

func _make_stone_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.71, 0.66, 0.53, 1.0)
	mat.roughness = 0.95
	mat.metallic = 0.0
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = Color(0.08, 0.07, 0.05)
	mat.emission_energy_multiplier = 0.14
	return mat

func _make_door_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.52, 0.40, 0.23, 1.0)
	mat.roughness = 0.88
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = Color(0.10, 0.06, 0.02)
	mat.emission_energy_multiplier = 0.20
	return mat

func _make_accent_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.86, 0.75, 0.52, 1.0)
	mat.roughness = 0.82
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = Color(0.16, 0.12, 0.05)
	mat.emission_energy_multiplier = 0.28
	return mat

func _make_portal_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.62, 0.95, 0.84, 0.46)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.14
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = Color(0.14, 0.58, 0.48)
	mat.emission_energy_multiplier = 1.6
	return mat

func _make_lantern_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.96, 0.84, 0.44, 1.0)
	mat.roughness = 0.70
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = Color(0.28, 0.22, 0.10)
	mat.emission_energy_multiplier = 0.62
	return mat

func _add_streamers() -> void:
	var offsets: Array[Vector3] = []
	if door_axis == "x":
		offsets = [Vector3(0.0, 1.10, -0.44), Vector3(0.0, 1.04, 0.0), Vector3(0.0, 1.10, 0.44)]
	else:
		offsets = [Vector3(-0.44, 1.10, 0.0), Vector3(0.0, 1.04, 0.0), Vector3(0.44, 1.10, 0.0)]

	for i: int in range(offsets.size()):
		var pivot := Node3D.new()
		pivot.name = "StreamerPivot%d" % i
		pivot.position = offsets[i]
		add_child(pivot)
		_streamers.append(pivot)

		var flag := MeshInstance3D.new()
		flag.name = "Streamer"
		var mesh := PrismMesh.new()
		mesh.size = Vector3(0.12, 0.46, 0.06)
		flag.mesh = mesh
		flag.position = Vector3(0.0, -0.26, 0.0)
		flag.rotation_degrees = Vector3(0.0, 90.0 if door_axis == "x" else 0.0, 180.0)
		flag.set_surface_override_material(0, _make_streamer_material(i))
		pivot.add_child(flag)

func _make_streamer_material(index: int) -> StandardMaterial3D:
	var palette := [
		Color(0.92, 0.84, 0.46, 1.0),
		Color(0.38, 0.86, 0.80, 1.0),
		Color(0.95, 0.63, 0.32, 1.0),
	]
	var color: Color = palette[index % palette.size()]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.84
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = Color(color.r * 0.12, color.g * 0.10, color.b * 0.08)
	mat.emission_energy_multiplier = 0.14
	return mat
