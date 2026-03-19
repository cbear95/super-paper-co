extends StaticBody3D

const OUTLINE_SHADER := preload("res://shaders/outline_next_pass.gdshader")

@export var npc_id       : String       = "npc"
@export var npc_name     : String       = "NPC"
@export var npc_role     : String       = ""
@export var portrait_type: String       = "default"
@export var dial_color   : Color        = Color(0.4, 0.7, 1.0, 1.0)
@export var stress_add   : float        = 0.0
@export var xp_add       : int         = 5
@export var boss_chance  : float        = 0.75
@export var dial_sets    : Array[String]= []

var _target_yaw: float = 0.0
var _hair: MeshInstance3D = null
var _scarf: MeshInstance3D = null
var _foot_l: MeshInstance3D = null
var _foot_r: MeshInstance3D = null

func _ready() -> void:
	add_to_group("npc")
	_build_visual_rig()
	set_process(true)

func _process(delta: float) -> void:
	var mesh: MeshInstance3D = get_node_or_null("Mesh")
	if mesh == null:
		return
	var t: float = Time.get_ticks_msec() * 0.001 + float(name.hash() % 17)
	mesh.position.y = 0.78 + sin(t * 1.6) * 0.02
	mesh.rotation.z = sin(t * 1.1) * 0.025
	mesh.rotation.y = lerp_angle(mesh.rotation.y, _target_yaw, 7.0 * delta)
	if _hair:
		_hair.rotation.x = lerpf(_hair.rotation.x, -0.06 + sin(t * 1.3) * 0.02, 6.0 * delta)
	if _scarf:
		_scarf.rotation.x = lerpf(_scarf.rotation.x, -0.08 + sin(t * 1.8) * 0.04, 6.0 * delta)

func interact(player: Node) -> void:
	if DialogueManager.is_active:
		return
	if player is Node3D:
		var to_player: Vector3 = (player.global_position - global_position)
		to_player.y = 0.0
		if to_player.length() > 0.001:
			_target_yaw = atan2(-to_player.x, -to_player.z)
	var lines: Array = _pick_lines()
	var cb: Callable = func():
		GameManager.add_xp(xp_add)
		GameManager.modify_stress(stress_add)
	DialogueManager.start(npc_name, npc_role, portrait_type, dial_color, lines, cb)

func _pick_lines() -> Array:
	if dial_sets.is_empty():
		return ["..."]
	if npc_id == "boss_holt":
		return _boss_lines()
	var idx: int = GameManager.next_dial_idx(npc_id, dial_sets.size())
	return Array(dial_sets[idx].split("|"))

func _boss_lines() -> Array:
	var bad: Array = []
	var good: Array = []
	for i: int in range(dial_sets.size()):
		var s: Array = Array(dial_sets[i].split("|"))
		if i < 3:
			bad.append(s)
		else:
			good.append(s)
	if randf() < boss_chance and not bad.is_empty():
		return bad[randi() % bad.size()]
	if not good.is_empty():
		return good[randi() % good.size()]
	return ["..."]

func _build_visual_rig() -> void:
	var root: MeshInstance3D = get_node_or_null("Mesh")
	if root == null:
		return
	var torso := CapsuleMesh.new()
	torso.radius = 0.15
	torso.height = 0.42
	root.mesh = torso
	root.position = Vector3(0.0, 0.60, 0.0)
	root.set_surface_override_material(0, _part_material(Color(0.92, 0.95, 0.97, 1.0), Color(0.08, 0.10, 0.12)))

	for child: Node in root.get_children():
		child.queue_free()

	var skin := _skin_color()
	var accent := dial_color.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.20)
	var pants := Color(0.24, 0.27, 0.31, 1.0)
	_make_sphere_part(root, "Head", 0.17, Vector3(0.0, 0.40, 0.0), skin, Vector3(1.0, 1.08, 1.0))
	_hair = _make_sphere_part(root, "Hair", 0.15, Vector3(0.0, 0.48, -0.03), _hair_color(), Vector3(1.0, 0.56, 0.84))
	_make_capsule_part(root, "ArmL", 0.05, 0.24, Vector3(-0.21, 0.05, 0.0), accent, Vector3(0.0, 0.0, 10.0))
	_make_capsule_part(root, "ArmR", 0.05, 0.24, Vector3(0.21, 0.05, 0.0), accent, Vector3(0.0, 0.0, -10.0))
	_make_capsule_part(root, "LegL", 0.05, 0.26, Vector3(-0.09, -0.31, 0.03), pants)
	_make_capsule_part(root, "LegR", 0.05, 0.26, Vector3(0.09, -0.31, -0.03), pants)
	_foot_l = _make_box_part(root, "FootL", Vector3(0.12, 0.06, 0.20), Vector3(-0.09, -0.27, 0.06), Color(0.10, 0.12, 0.16, 1.0))
	_foot_r = _make_box_part(root, "FootR", Vector3(0.12, 0.06, 0.20), Vector3(0.09, -0.27, -0.06), Color(0.10, 0.12, 0.16, 1.0))
	_scarf = _make_prism_part(root, "Scarf", Vector3(0.24, 0.12, 0.18), Vector3(0.0, 0.10, 0.12), dial_color)
	_make_prism_part(root, "CoatTail", Vector3(0.40, 0.34, 0.28), Vector3(0.0, -0.02, 0.0), accent)
	_make_prism_part(root, "ShoulderCape", Vector3(0.34, 0.14, 0.20), Vector3(0.0, 0.15, -0.02), accent)

func _skin_color() -> Color:
	var tones := [
		Color(0.94, 0.84, 0.72, 1.0),
		Color(0.82, 0.66, 0.50, 1.0),
		Color(0.62, 0.46, 0.34, 1.0),
	]
	return tones[abs(name.hash()) % tones.size()]

func _hair_color() -> Color:
	var tones := [
		Color(0.28, 0.22, 0.18, 1.0),
		Color(0.54, 0.36, 0.18, 1.0),
		Color(0.18, 0.20, 0.26, 1.0),
	]
	return tones[abs((name + npc_id).hash()) % tones.size()]

func _make_box_part(root: MeshInstance3D, name: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.position = pos
	part.set_surface_override_material(0, _part_material(color, Color(color.r * 0.08, color.g * 0.08, color.b * 0.08)))
	root.add_child(part)
	return part

func _make_sphere_part(root: MeshInstance3D, name: String, radius: float, pos: Vector3, color: Color, scale_override: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	part.mesh = mesh
	part.position = pos
	part.scale = scale_override
	part.set_surface_override_material(0, _part_material(color, Color(color.r * 0.08, color.g * 0.08, color.b * 0.08)))
	root.add_child(part)
	return part

func _make_capsule_part(root: MeshInstance3D, name: String, radius: float, height: float, pos: Vector3, color: Color, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	part.mesh = mesh
	part.position = pos
	part.rotation_degrees = rot_deg
	part.set_surface_override_material(0, _part_material(color, Color(color.r * 0.08, color.g * 0.08, color.b * 0.08)))
	root.add_child(part)
	return part

func _make_prism_part(root: MeshInstance3D, name: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = name
	var mesh := PrismMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.position = pos
	part.rotation_degrees = Vector3(180.0, 0.0, 0.0)
	part.set_surface_override_material(0, _part_material(color, Color(color.r * 0.08, color.g * 0.08, color.b * 0.08)))
	root.add_child(part)
	return part

func _part_material(color: Color, emission: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = 0.20
	mat.next_pass = _outline_pass(color)
	return mat

func _outline_pass(color: Color) -> ShaderMaterial:
	var outline := ShaderMaterial.new()
	outline.shader = OUTLINE_SHADER
	outline.set_shader_parameter("outline_color", Color(color.r * 0.14, color.g * 0.14, color.b * 0.16, 1.0))
	outline.set_shader_parameter("outline_width", 0.024)
	return outline
