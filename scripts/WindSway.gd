extends Node3D

@export var axis: Vector3 = Vector3(0.0, 0.0, 1.0)
@export var speed: float = 1.2
@export var amplitude_degrees: float = 8.0
@export var bob_amount: float = 0.04

var _base_rotation: Vector3 = Vector3.ZERO
var _base_position: Vector3 = Vector3.ZERO
var _phase: float = 0.0

func _ready() -> void:
	_base_rotation = rotation
	_base_position = position
	_phase = randf() * TAU

func _process(delta: float) -> void:
	var t: float = Time.get_ticks_msec() * 0.001 * speed + _phase
	var sway: float = sin(t) * deg_to_rad(amplitude_degrees)
	rotation = _base_rotation + axis * sway
	position.y = _base_position.y + sin(t * 0.7) * bob_amount
