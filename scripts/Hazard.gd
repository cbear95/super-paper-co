extends CharacterBody3D

const OUTLINE_SHADER := preload("res://shaders/outline_next_pass.gdshader")

@export var patrol_dist: float = 6.0
@export var speed      : float = 2.5
@export var damage     : int   = 1
@export var stress_hit : float = 15.0
@export var patrol_axis: String = "x"

var _dir : float = 1.0
var _dist: float = 0.0
var _travel_dir: Vector3 = Vector3.RIGHT

func _ready() -> void:
	add_to_group("hazard")
	collision_mask = 4
	randomize()
	_seed_motion_pattern()
	_build_visual()
	var area: Area3D = $HitArea
	if area:
		area.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if DialogueManager.is_active or GameManager.menu_open:
		velocity = Vector3.ZERO
		return
	var move: float = speed * _dir * delta
	_dist += absf(move)
	if _dist >= patrol_dist:
		_dir  *= -1.0
		_dist  = 0.0
	velocity = _travel_dir * speed * _dir
	move_and_slide()

func _on_body_entered(body: Node) -> void:
	if DialogueManager.is_active or GameManager.menu_open:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage, "hazard")
		GameManager.modify_stress(stress_hit)

func _build_visual() -> void:
	var root: MeshInstance3D = get_node_or_null("Mesh")
	if root == null:
		return
	root.mesh = null
	for child: Node in root.get_children():
		child.queue_free()

	var lower_name: String = name.to_lower()
	if lower_name.contains("forklift"):
		_build_forklift(root)
	else:
		_build_paper_roll(root)

func _seed_motion_pattern() -> void:
	var seed := abs((name + str(Time.get_unix_time_from_system()) + str(randi())).hash())
	var options: Array[Vector3] = [
		Vector3(1.0, 0.0, 0.0),
		Vector3(-1.0, 0.0, 0.0),
		Vector3(0.0, 0.0, 1.0),
		Vector3(0.0, 0.0, -1.0),
		Vector3(1.0, 0.0, 1.0).normalized(),
		Vector3(-1.0, 0.0, 1.0).normalized(),
		Vector3(1.0, 0.0, -1.0).normalized(),
		Vector3(-1.0, 0.0, -1.0).normalized(),
	]
	if patrol_axis == "x":
		options = [
			Vector3(1.0, 0.0, 0.0),
			Vector3(-1.0, 0.0, 0.0),
			Vector3(1.0, 0.0, 1.0).normalized(),
			Vector3(1.0, 0.0, -1.0).normalized(),
		]
	elif patrol_axis == "z":
		options = [
			Vector3(0.0, 0.0, 1.0),
			Vector3(0.0, 0.0, -1.0),
			Vector3(1.0, 0.0, 1.0).normalized(),
			Vector3(-1.0, 0.0, 1.0).normalized(),
		]
	_travel_dir = options[seed % options.size()]
	_dir = -1.0 if seed % 2 == 0 else 1.0

func _build_forklift(root: Node3D) -> void:
	var body_mat := _mat(Color(0.82, 0.65, 0.24, 1.0), Color(0.10, 0.08, 0.03))
	var dark_mat := _mat(Color(0.28, 0.31, 0.30, 1.0), Color(0.04, 0.05, 0.05))
	var glass_mat := _mat(Color(0.56, 0.80, 0.82, 0.92), Color(0.06, 0.10, 0.10), true)

	_add_box(root, "Body", Vector3(1.05, 0.54, 0.82), Vector3(0.0, 0.28, 0.0), body_mat)
	_add_box(root, "Rear", Vector3(0.42, 0.42, 0.72), Vector3(-0.34, 0.62, 0.0), body_mat)
	_add_box(root, "SeatCab", Vector3(0.46, 0.38, 0.50), Vector3(0.10, 0.72, 0.0), glass_mat)
	_add_box(root, "Roof", Vector3(0.70, 0.08, 0.70), Vector3(0.02, 1.02, 0.0), dark_mat)
	_add_box(root, "MastL", Vector3(0.08, 1.20, 0.08), Vector3(0.46, 0.70, -0.22), dark_mat)
	_add_box(root, "MastR", Vector3(0.08, 1.20, 0.08), Vector3(0.46, 0.70, 0.22), dark_mat)
	_add_box(root, "Crossbar", Vector3(0.10, 0.08, 0.60), Vector3(0.46, 1.16, 0.0), dark_mat)
	_add_box(root, "ForkBack", Vector3(0.12, 0.28, 0.48), Vector3(0.52, 0.26, 0.0), dark_mat)
	_add_box(root, "ForkL", Vector3(0.68, 0.04, 0.08), Vector3(0.82, 0.06, -0.16), dark_mat)
	_add_box(root, "ForkR", Vector3(0.68, 0.04, 0.08), Vector3(0.82, 0.06, 0.16), dark_mat)

	for wheel_pos: Vector3 in [
		Vector3(-0.28, 0.08, -0.30),
		Vector3(-0.28, 0.08, 0.30),
		Vector3(0.24, 0.08, -0.30),
		Vector3(0.24, 0.08, 0.30),
	]:
		_add_wheel(root, wheel_pos, 0.15, 0.10, dark_mat)

func _build_paper_roll(root: Node3D) -> void:
	var paper_mat := _mat(Color(0.92, 0.90, 0.78, 1.0), Color(0.08, 0.07, 0.05))
	var core_mat := _mat(Color(0.62, 0.48, 0.30, 1.0), Color(0.06, 0.04, 0.02))

	var roll := MeshInstance3D.new()
	roll.name = "Roll"
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.86
	cyl.bottom_radius = 0.86
	cyl.height = 1.72
	roll.mesh = cyl
	roll.position = Vector3(0.0, 0.86, 0.0)
	roll.rotation_degrees = Vector3(0.0, 0.0, 90.0)
	roll.set_surface_override_material(0, paper_mat)
	root.add_child(roll)

	var core := MeshInstance3D.new()
	core.name = "Core"
	var core_cyl := CylinderMesh.new()
	core_cyl.top_radius = 0.20
	core_cyl.bottom_radius = 0.20
	core_cyl.height = 1.80
	core.mesh = core_cyl
	core.position = Vector3(0.0, 0.86, 0.0)
	core.rotation_degrees = Vector3(0.0, 0.0, 90.0)
	core.set_surface_override_material(0, core_mat)
	root.add_child(core)

func _add_box(root: Node3D, part_name: String, size: Vector3, pos: Vector3, material: Material) -> void:
	var mi := MeshInstance3D.new()
	mi.name = part_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.set_surface_override_material(0, material)
	root.add_child(mi)

func _add_wheel(root: Node3D, pos: Vector3, radius: float, width: float, material: Material) -> void:
	var mi := MeshInstance3D.new()
	mi.name = "Wheel"
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = width
	mi.mesh = cyl
	mi.position = pos
	mi.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	mi.set_surface_override_material(0, material)
	root.add_child(mi)

func _mat(color: Color, emission: Color, transparent: bool = false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	if transparent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = 0.18
	mat.next_pass = _outline_pass(color)
	return mat

func _outline_pass(color: Color) -> ShaderMaterial:
	var outline := ShaderMaterial.new()
	outline.shader = OUTLINE_SHADER
	outline.set_shader_parameter("outline_color", Color(color.r * 0.12, color.g * 0.12, color.b * 0.14, 1.0))
	outline.set_shader_parameter("outline_width", 0.030)
	return outline
