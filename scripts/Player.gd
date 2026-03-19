extends CharacterBody3D

const OUTLINE_SHADER := preload("res://shaders/outline_next_pass.gdshader")

@export var move_speed: float = 7.1
@export var accel: float = 24.0
@export var decel: float = 18.0
@export var turn_speed: float = 14.0
@export var inv_time: float = 1.2

const ISO_UNIT := 0.70710678
const SCREEN_UP := Vector3(-ISO_UNIT, 0.0, -ISO_UNIT)
const SCREEN_RIGHT := Vector3(ISO_UNIT, 0.0, -ISO_UNIT)

var _inv   : float   = 0.0
var _icool : float   = 0.0
var _facing_dir: Vector3 = Vector3(0.0, 0.0, 1.0)
var _step_t: float = 0.0

@onready var _mesh  : MeshInstance3D = $Mesh
@onready var _iarea : Area3D         = $InteractArea

var _head: MeshInstance3D = null
var _coat: MeshInstance3D = null
var _arm_l: MeshInstance3D = null
var _arm_r: MeshInstance3D = null
var _leg_l: MeshInstance3D = null
var _leg_r: MeshInstance3D = null
var _hair: MeshInstance3D = null
var _scarf: MeshInstance3D = null
var _foot_l: MeshInstance3D = null
var _foot_r: MeshInstance3D = null

func _ready() -> void:
	GameManager.player_died.connect(_on_died)
	add_to_group("player")
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	up_direction = Vector3.UP
	_mesh.position = Vector3(0.0, -0.18, 0.0)
	_iarea.collision_mask = 5
	var interact_shape: CollisionShape3D = _iarea.get_node_or_null("InteractShape")
	if interact_shape and interact_shape.shape is SphereShape3D:
		(interact_shape.shape as SphereShape3D).radius = 1.55
	_build_visual_rig()

func _physics_process(delta: float) -> void:
	_inv   = maxf(0.0, _inv   - delta)
	_icool = maxf(0.0, _icool - delta)

	if _mesh:
		var flash_visible: bool = not (_inv > 0.0 and int(_inv * 10.0) % 2 == 0)
		_mesh.visible = flash_visible

	if DialogueManager.is_active:
		velocity = velocity.move_toward(Vector3.ZERO, decel * delta)
		return
	if GameManager.menu_open:
		velocity = velocity.move_toward(Vector3.ZERO, decel * delta)
		_update_visuals(delta, 0.0)
		return

	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired: Vector3 = _input_to_world(input) * move_speed

	if desired.length() > 0.01:
		velocity.x = move_toward(velocity.x, desired.x, accel * delta)
		velocity.z = move_toward(velocity.z, desired.z, accel * delta)
		_facing_dir = desired.normalized()
	else:
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)
		velocity.z = move_toward(velocity.z, 0.0, decel * delta)

	velocity.y = 0.0
	_move_with_collision(delta)
	_update_visuals(delta, input.length())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _icool <= 0.0 and not DialogueManager.is_active and not GameManager.menu_open:
		_do_interact()
		get_viewport().set_input_as_handled()

func _input_to_world(input: Vector2) -> Vector3:
	var world: Vector3 = (SCREEN_RIGHT * input.x) + (SCREEN_UP * -input.y)
	world.y = 0.0
	return world.normalized() if world.length() > 0.001 else Vector3.ZERO

func _move_with_collision(delta: float) -> void:
	var motion: Vector3 = Vector3(velocity.x, 0.0, velocity.z) * delta
	if motion.length() <= 0.0001:
		return

	var start: Transform3D = global_transform
	start.origin.y = global_position.y
	if not test_move(start, motion):
		global_position += motion
		return

	var slide_x := Vector3(motion.x, 0.0, 0.0)
	var slide_z := Vector3(0.0, 0.0, motion.z)

	if absf(slide_x.x) > 0.0001 and not test_move(start, slide_x):
		global_position += slide_x
		start = global_transform
		start.origin.y = global_position.y
	if absf(slide_z.z) > 0.0001 and not test_move(start, slide_z):
		global_position += slide_z

func _update_visuals(delta: float, input_strength: float) -> void:
	if _mesh == null:
		return
	var horizontal: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	if horizontal.length() > 0.05:
		var target_yaw: float = atan2(-_facing_dir.x, -_facing_dir.z)
		_mesh.rotation.y = lerp_angle(_mesh.rotation.y, target_yaw, turn_speed * delta)
		_step_t += delta * (4.8 + horizontal.length() * 0.8)
	else:
		_step_t = lerpf(_step_t, 0.0, 4.0 * delta)

	var speed_ratio: float = clampf(horizontal.length() / move_speed, 0.0, 1.0)
	var sway: float = sin(_step_t) * 0.05 * speed_ratio
	var local_velocity: Vector3 = _mesh.global_basis.inverse() * horizontal.normalized() if horizontal.length() > 0.001 else Vector3.ZERO
	_mesh.rotation.z = lerpf(_mesh.rotation.z, sway + local_velocity.x * 0.12 * speed_ratio, 8.0 * delta)
	_mesh.rotation.x = lerpf(_mesh.rotation.x, -0.04 * speed_ratio + absf(local_velocity.z) * 0.04 * speed_ratio, 8.0 * delta)
	_mesh.scale.y = lerpf(_mesh.scale.y, 1.0 + 0.04 * speed_ratio, 8.0 * delta)
	_mesh.scale.x = lerpf(_mesh.scale.x, 1.0 - 0.03 * speed_ratio, 8.0 * delta)
	_mesh.scale.z = lerpf(_mesh.scale.z, 1.0 - 0.03 * speed_ratio, 8.0 * delta)
	_mesh.position.y = lerpf(_mesh.position.y, -0.18 + 0.03 * absf(sway) + 0.01 * input_strength, 8.0 * delta)

	var stride: float = sin(_step_t * 2.0) * 0.80 * speed_ratio
	if _leg_l:
		_leg_l.rotation.x = lerpf(_leg_l.rotation.x, stride * 0.85, 10.0 * delta)
		_leg_l.position.z = lerpf(_leg_l.position.z, 0.05 + 0.08 * stride, 10.0 * delta)
		_leg_l.position.y = lerpf(_leg_l.position.y, -0.34 - 0.02 * absf(stride), 10.0 * delta)
	if _leg_r:
		_leg_r.rotation.x = lerpf(_leg_r.rotation.x, -stride * 0.85, 10.0 * delta)
		_leg_r.position.z = lerpf(_leg_r.position.z, -0.05 - 0.08 * stride, 10.0 * delta)
		_leg_r.position.y = lerpf(_leg_r.position.y, -0.34 - 0.02 * absf(stride), 10.0 * delta)
	if _foot_l:
		_foot_l.position.y = lerpf(_foot_l.position.y, -0.37 - 0.02 * maxf(0.0, -stride), 10.0 * delta)
	if _foot_r:
		_foot_r.position.y = lerpf(_foot_r.position.y, -0.37 - 0.02 * maxf(0.0, stride), 10.0 * delta)
	if _arm_l:
		_arm_l.rotation.x = lerpf(_arm_l.rotation.x, -stride * 0.6 - 0.12 * local_velocity.x, 10.0 * delta)
	if _arm_r:
		_arm_r.rotation.x = lerpf(_arm_r.rotation.x, stride * 0.6 - 0.12 * local_velocity.x, 10.0 * delta)
	if _head:
		_head.position.y = lerpf(_head.position.y, 0.40 + 0.02 * absf(sway), 8.0 * delta)
	if _hair:
		_hair.rotation.x = lerpf(_hair.rotation.x, -0.08 * speed_ratio, 8.0 * delta)
	if _scarf:
		_scarf.rotation.x = lerpf(_scarf.rotation.x, -0.10 * speed_ratio - stride * 0.10, 8.0 * delta)
		_scarf.rotation.z = lerpf(_scarf.rotation.z, local_velocity.x * -0.08 * speed_ratio, 8.0 * delta)
	if _coat:
		_coat.rotation.x = lerpf(_coat.rotation.x, -0.12 * speed_ratio - stride * 0.12, 8.0 * delta)
		_coat.rotation.z = lerpf(_coat.rotation.z, local_velocity.x * -0.10 * speed_ratio, 8.0 * delta)

func _build_visual_rig() -> void:
	if _mesh == null:
		return

	var torso := CapsuleMesh.new()
	torso.radius = 0.15
	torso.height = 0.42
	_mesh.mesh = torso
	_mesh.set_surface_override_material(0, _make_part_material(Color(0.94, 0.96, 0.98, 1.0), Color(0.10, 0.14, 0.18)))

	_head = _make_sphere_part("Head", 0.17, Vector3(0.0, 0.34, 0.0), Color(0.93, 0.82, 0.66, 1.0), Vector3(1.0, 1.08, 1.0))
	_hair = _make_sphere_part("Hair", 0.15, Vector3(0.0, 0.42, -0.03), Color(0.24, 0.19, 0.14, 1.0), Vector3(1.0, 0.56, 0.84))
	_arm_l = _make_capsule_part("ArmL", 0.05, 0.24, Vector3(-0.21, 0.05, 0.0), Color(0.95, 0.96, 0.98, 1.0), Vector3(0.0, 0.0, 10.0))
	_arm_r = _make_capsule_part("ArmR", 0.05, 0.24, Vector3(0.21, 0.05, 0.0), Color(0.95, 0.96, 0.98, 1.0), Vector3(0.0, 0.0, -10.0))
	_leg_l = _make_capsule_part("LegL", 0.05, 0.26, Vector3(-0.09, -0.34, 0.03), Color(0.22, 0.24, 0.28, 1.0))
	_leg_r = _make_capsule_part("LegR", 0.05, 0.26, Vector3(0.09, -0.34, -0.03), Color(0.22, 0.24, 0.28, 1.0))
	_foot_l = _make_box_part("FootL", Vector3(0.12, 0.06, 0.20), Vector3(-0.09, -0.37, 0.06), Color(0.10, 0.12, 0.16, 1.0))
	_foot_r = _make_box_part("FootR", Vector3(0.12, 0.06, 0.20), Vector3(0.09, -0.37, -0.06), Color(0.10, 0.12, 0.16, 1.0))
	_scarf = _make_prism_part("Scarf", Vector3(0.24, 0.12, 0.18), Vector3(0.0, 0.10, 0.12), Color(0.28, 0.56, 0.68, 1.0))
	_coat = _make_prism_part("CoatTail", Vector3(0.40, 0.34, 0.28), Vector3(0.0, -0.02, 0.0), Color(0.88, 0.90, 0.95, 1.0))
	_make_prism_part("ShoulderCape", Vector3(0.34, 0.14, 0.20), Vector3(0.0, 0.15, -0.01), Color(0.90, 0.92, 0.97, 1.0))

func _make_box_part(name: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.position = pos
	part.set_surface_override_material(0, _make_part_material(color, Color(color.r * 0.10, color.g * 0.10, color.b * 0.10)))
	_mesh.add_child(part)
	return part

func _make_sphere_part(name: String, radius: float, pos: Vector3, color: Color, scale_override: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	part.mesh = mesh
	part.position = pos
	part.scale = scale_override
	part.set_surface_override_material(0, _make_part_material(color, Color(color.r * 0.10, color.g * 0.10, color.b * 0.10)))
	_mesh.add_child(part)
	return part

func _make_capsule_part(name: String, radius: float, height: float, pos: Vector3, color: Color, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	part.mesh = mesh
	part.position = pos
	part.rotation_degrees = rot_deg
	part.set_surface_override_material(0, _make_part_material(color, Color(color.r * 0.10, color.g * 0.10, color.b * 0.10)))
	_mesh.add_child(part)
	return part

func _make_prism_part(name: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = name
	var mesh := PrismMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.position = pos
	part.rotation_degrees = Vector3(180.0, 0.0, 0.0)
	part.set_surface_override_material(0, _make_part_material(color, Color(color.r * 0.10, color.g * 0.10, color.b * 0.10)))
	_mesh.add_child(part)
	return part

func _make_part_material(color: Color, emission: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.86
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = 0.24
	mat.next_pass = _outline_pass(color)
	return mat

func _outline_pass(color: Color) -> ShaderMaterial:
	var outline := ShaderMaterial.new()
	outline.shader = OUTLINE_SHADER
	outline.set_shader_parameter("outline_color", Color(color.r * 0.14, color.g * 0.14, color.b * 0.16, 1.0))
	outline.set_shader_parameter("outline_width", 0.026)
	return outline

func _do_interact() -> void:
	if not _iarea:
		return
	var best_target: Node = null
	var best_score: float = -INF
	var facing: Vector3 = _facing_dir if _facing_dir.length() > 0.001 else Vector3(0.0, 0.0, 1.0)
	for body: Node3D in _iarea.get_overlapping_bodies():
		if not body.has_method("interact"):
			continue
		var score: float = _interaction_score(body.global_position, facing)
		if score > best_score:
			best_score = score
			best_target = body
	for area: Area3D in _iarea.get_overlapping_areas():
		if not area.has_method("interact"):
			continue
		var score: float = _interaction_score(area.global_position, facing)
		if score > best_score:
			best_score = score
			best_target = area
	if best_target != null:
		best_target.interact(self)
		_icool = 0.5

func _interaction_score(target_pos: Vector3, facing: Vector3) -> float:
	var to_target := target_pos - global_position
	to_target.y = 0.0
	var dist := to_target.length()
	if dist <= 0.001:
		return 1000.0
	var dir := to_target / dist
	var facing_score := dir.dot(facing.normalized())
	if facing_score < 0.25:
		return -INF
	return facing_score * 10.0 - dist

func take_damage(amount: int, _src: String = "") -> void:
	if DialogueManager.is_active or GameManager.menu_open:
		return
	if _inv > 0.0:
		return
	_inv = inv_time
	GameManager.hurt(amount, _src)

func _on_died() -> void:
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
