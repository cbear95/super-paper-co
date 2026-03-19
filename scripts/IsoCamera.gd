extends Camera3D

@export var follow_speed : float = 7.0
@export var cam_offset   : Vector3 = Vector3(10.0, 13.0, 10.0)

var target: Node3D = null

func _ready() -> void:
	projection       = Camera3D.PROJECTION_ORTHOGONAL
	size             = 13.0
	rotation_degrees = Vector3(-30.0, 45.0, 0.0)

func _physics_process(delta: float) -> void:
	if target == null:
		return
	var want: Vector3 = target.global_position + cam_offset
	global_position   = global_position.lerp(want, follow_speed * delta)
