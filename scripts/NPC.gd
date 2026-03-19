extends StaticBody3D

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
	root.mesh = BoxMesh.new()
	root.mesh.size = Vector3(0.34, 0.44, 0.22)
	root.position = Vector3(0.0, 0.78, 0.0)
	root.set_surface_override_material(0, _part_material(Color(0.92, 0.95, 0.97, 1.0), Color(0.08, 0.10, 0.12)))

	for child: Node in root.get_children():
		child.queue_free()

	var skin := _skin_color()
	var accent := dial_color.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.20)
	var pants := Color(0.24, 0.27, 0.31, 1.0)
	_make_box_part(root, "Head", Vector3(0.34, 0.32, 0.30), Vector3(0.0, 0.48, 0.0), skin)
	_make_box_part(root, "Hair", Vector3(0.30, 0.10, 0.24), Vector3(0.0, 0.58, -0.02), _hair_color())
	_make_box_part(root, "ArmL", Vector3(0.10, 0.28, 0.10), Vector3(-0.24, 0.08, 0.0), accent)
	_make_box_part(root, "ArmR", Vector3(0.10, 0.28, 0.10), Vector3(0.24, 0.08, 0.0), accent)
	_make_box_part(root, "LegL", Vector3(0.10, 0.26, 0.10), Vector3(-0.09, -0.34, 0.04), pants)
	_make_box_part(root, "LegR", Vector3(0.10, 0.26, 0.10), Vector3(0.09, -0.34, -0.04), pants)
	_make_box_part(root, "Scarf", Vector3(0.26, 0.08, 0.22), Vector3(0.0, 0.12, 0.10), dial_color)
	_make_prism_part(root, "CoatTail", Vector3(0.40, 0.26, 0.22), Vector3(0.0, -0.06, 0.0), accent)
	_make_prism_part(root, "ShoulderCape", Vector3(0.34, 0.14, 0.18), Vector3(0.0, 0.18, -0.02), accent)

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

func _make_box_part(root: MeshInstance3D, name: String, size: Vector3, pos: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	part.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.position = pos
	part.set_surface_override_material(0, _part_material(color, Color(color.r * 0.08, color.g * 0.08, color.b * 0.08)))
	root.add_child(part)

func _make_prism_part(root: MeshInstance3D, name: String, size: Vector3, pos: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	part.name = name
	var mesh := PrismMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.position = pos
	part.rotation_degrees = Vector3(180.0, 0.0, 0.0)
	part.set_surface_override_material(0, _part_material(color, Color(color.r * 0.08, color.g * 0.08, color.b * 0.08)))
	root.add_child(part)

func _part_material(color: Color, emission: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = 0.20
	return mat
