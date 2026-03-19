extends CharacterBody3D

@export var move_speed: float = 5.0
@export var grid_size : float = 1.0
@export var inv_time  : float = 1.2

const DIRS: Dictionary = {
	"up":    Vector3(-1.0, 0.0, -1.0),
	"down":  Vector3( 1.0, 0.0,  1.0),
	"left":  Vector3(-1.0, 0.0,  1.0),
	"right": Vector3( 1.0, 0.0, -1.0),
}

var _target : Vector3 = Vector3.ZERO
var _moving : bool    = false
var _inv    : float   = 0.0
var _icool  : float   = 0.0
var _facing : String  = "down"
var _step   : int     = 0

@onready var _mesh  : MeshInstance3D = $Mesh
@onready var _iarea : Area3D         = $InteractArea

func _ready() -> void:
	_target = global_position
	GameManager.player_died.connect(_on_died)
	add_to_group("player")

func _physics_process(delta: float) -> void:
	_inv   = maxf(0.0, _inv   - delta)
	_icool = maxf(0.0, _icool - delta)

	if _mesh:
		var flash_visible: bool = not (_inv > 0.0 and int(_inv * 10.0) % 2 == 0)
		_mesh.visible = flash_visible

	if DialogueManager.is_active:
		return

	if _moving:
		var diff: Vector3 = _target - global_position
		if diff.length() < move_speed * delta * 1.2:
			global_position = _target
			_moving = false
		else:
			velocity = diff.normalized() * move_speed
			move_and_slide()
	else:
		_read_input()

func _read_input() -> void:
	var dir: String = ""
	if   Input.is_action_pressed("move_up"):    dir = "up"
	elif Input.is_action_pressed("move_down"):  dir = "down"
	elif Input.is_action_pressed("move_left"):  dir = "left"
	elif Input.is_action_pressed("move_right"): dir = "right"

	if dir != "":
		_facing = dir
		var dir_vec: Vector3 = DIRS[dir]
		var nxt: Vector3 = _target + dir_vec.normalized() * grid_size
		nxt.y = _target.y
		if _walkable(nxt):
			_target = nxt
			_moving = true
			_step   = (_step + 1) % 4

	if Input.is_action_just_pressed("interact") and _icool <= 0.0:
		_do_interact()

func _walkable(pos: Vector3) -> bool:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var qf: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		pos + Vector3(0.0, 1.0, 0.0), pos + Vector3(0.0, -1.0, 0.0))
	qf.collision_mask = 2
	if space.intersect_ray(qf).is_empty():
		return false
	var qw: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		_target + Vector3(0.0, 0.5, 0.0), pos + Vector3(0.0, 0.5, 0.0))
	qw.collision_mask = 4
	return space.intersect_ray(qw).is_empty()

func _do_interact() -> void:
	if not _iarea:
		return
	for body: Node3D in _iarea.get_overlapping_bodies():
		if body.has_method("interact"):
			body.interact(self)
			_icool = 0.5
			return
	for area: Area3D in _iarea.get_overlapping_areas():
		if area.has_method("interact"):
			area.interact(self)
			_icool = 0.5
			return

func take_damage(amount: int, _src: String = "") -> void:
	if _inv > 0.0:
		return
	_inv = inv_time
	GameManager.hurt(amount, _src)

func _on_died() -> void:
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
