extends Area3D

@export var dest_room  : String  = "Hallway"
@export var spawn_pos  : Vector3 = Vector3(2.0, 0.5, 2.0)
## Which wall the door is on: "x" (left/right wall) or "z" (front/back wall)
@export var door_axis  : String  = "x"

var _portal_core: MeshInstance3D = null
var _portal_rune: MeshInstance3D = null
var _hall_shadow: MeshInstance3D = null
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
	var t: float = Time.get_ticks_msec() * 0.001
	var pulse: float = (sin(t * 2.1) + 1.0) * 0.5
	if _hall_shadow:
		_hall_shadow.scale.z = lerpf(0.94, 1.04, pulse)
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
			box.size = Vector3(2.8, 2.0, 3.0)
		else:
			box.size = Vector3(3.0, 2.0, 2.8)

func _build_door_visual() -> void:
	var depth: float = 0.34
	var span: float = 1.14
	var frame_mat := _make_stone_material()
	var accent_mat := _make_accent_material()
	var lantern_mat := _make_guide_material()
	var cloth_mat := _make_streamer_material(1)
	_streamers.clear()

	if door_axis == "x":
		_add_box("LeftPost", Vector3(depth, 2.1, 0.24), Vector3(0.0, 0.48, -0.62), frame_mat)
		_add_box("RightPost", Vector3(depth, 2.1, 0.24), Vector3(0.0, 0.48, 0.62), frame_mat)
		_add_box("Lintel", Vector3(depth, 0.24, span * 1.24), Vector3(0.0, 1.48, 0.0), frame_mat)
		_add_box("Crown", Vector3(depth * 0.9, 0.16, span * 0.88), Vector3(0.0, 1.66, 0.0), accent_mat)
		_add_box("Runner", Vector3(depth * 0.7, 0.06, 1.16), Vector3(0.0, 0.01, 0.0), accent_mat)
		_add_box("HallSideNorth", Vector3(depth * 0.8, 1.20, 0.18), Vector3(0.0, 0.30, -0.86), frame_mat)
		_add_box("HallSideSouth", Vector3(depth * 0.8, 1.20, 0.18), Vector3(0.0, 0.30, 0.86), frame_mat)
		_add_box("GuideNorth", Vector3(depth * 0.44, 0.16, 0.12), Vector3(0.0, 0.86, -0.92), lantern_mat)
		_add_box("GuideSouth", Vector3(depth * 0.44, 0.16, 0.12), Vector3(0.0, 0.86, 0.92), lantern_mat)
		_add_box("ClothTop", Vector3(depth * 0.64, 0.12, 1.02), Vector3(0.0, 1.20, 0.0), cloth_mat)
		_hall_shadow = _add_box("HallShadow", Vector3(depth * 0.16, 1.30, 0.96), Vector3(0.0, 0.44, 0.0), _make_hall_shadow_material())
		_add_box("RunnerLine", Vector3(depth * 0.18, 0.03, 0.76), Vector3(0.0, 0.03, 0.0), _make_runner_material())
	else:
		_add_box("LeftPost", Vector3(0.24, 2.1, depth), Vector3(-0.62, 0.48, 0.0), frame_mat)
		_add_box("RightPost", Vector3(0.24, 2.1, depth), Vector3(0.62, 0.48, 0.0), frame_mat)
		_add_box("Lintel", Vector3(span * 1.24, 0.24, depth), Vector3(0.0, 1.48, 0.0), frame_mat)
		_add_box("Crown", Vector3(span * 0.88, 0.16, depth * 0.9), Vector3(0.0, 1.66, 0.0), accent_mat)
		_add_box("Runner", Vector3(1.16, 0.06, depth * 0.7), Vector3(0.0, 0.01, 0.0), accent_mat)
		_add_box("HallSideWest", Vector3(0.18, 1.20, depth * 0.8), Vector3(-0.86, 0.30, 0.0), frame_mat)
		_add_box("HallSideEast", Vector3(0.18, 1.20, depth * 0.8), Vector3(0.86, 0.30, 0.0), frame_mat)
		_add_box("GuideWest", Vector3(0.12, 0.16, depth * 0.44), Vector3(-0.92, 0.86, 0.0), lantern_mat)
		_add_box("GuideEast", Vector3(0.12, 0.16, depth * 0.44), Vector3(0.92, 0.86, 0.0), lantern_mat)
		_add_box("ClothTop", Vector3(1.02, 0.12, depth * 0.64), Vector3(0.0, 1.20, 0.0), cloth_mat)
		_hall_shadow = _add_box("HallShadow", Vector3(0.96, 1.30, depth * 0.16), Vector3(0.0, 0.44, 0.0), _make_hall_shadow_material())
		_add_box("RunnerLine", Vector3(0.76, 0.03, depth * 0.18), Vector3(0.0, 0.03, 0.0), _make_runner_material())

	var lbl := Label3D.new()
	lbl.text      = dest_room
	lbl.font_size = 22
	lbl.modulate  = Color(0.90, 0.88, 0.80, 0.58)
	lbl.position  = Vector3(0.0, 1.82, 0.0)
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

func _make_hall_shadow_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.14, 0.16, 0.42)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.96
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
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

func _make_runner_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.74, 0.76, 0.66, 1.0)
	mat.roughness = 0.72
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = Color(0.10, 0.10, 0.08)
	mat.emission_energy_multiplier = 0.16
	return mat

func _make_guide_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.86, 0.82, 0.62, 1.0)
	mat.roughness = 0.70
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = Color(0.12, 0.14, 0.10)
	mat.emission_energy_multiplier = 0.26
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
