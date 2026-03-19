extends CharacterBody3D

@export var patrol_dist: float = 6.0
@export var speed      : float = 2.5
@export var damage     : int   = 1
@export var stress_hit : float = 15.0

var _dir : float = 1.0
var _dist: float = 0.0

func _ready() -> void:
	add_to_group("hazard")
	var area: Area3D = $HitArea
	if area:
		area.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var move: float = speed * _dir * delta
	_dist += absf(move)
	if _dist >= patrol_dist:
		_dir  *= -1.0
		_dist  = 0.0
	velocity = Vector3(speed * _dir * 0.7, 0.0, speed * _dir * 0.7)
	move_and_slide()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, "hazard")
		GameManager.modify_stress(stress_hit)
