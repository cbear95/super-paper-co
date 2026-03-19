extends Camera3D

@export var follow_speed : float = 6.0
@export var cam_offset   : Vector3 = Vector3(10.0, 13.0, 10.0)
@export var lead_amount  : float = 0.22

var target: Node3D = null

func _ready() -> void:
	projection       = Camera3D.PROJECTION_ORTHOGONAL
	size             = 12.0
	rotation_degrees = Vector3(-30.0, 45.0, 0.0)

func _physics_process(delta: float) -> void:
	if target == null:
		return
	var lead: Vector3 = Vector3.ZERO
	if target is CharacterBody3D:
		var body: CharacterBody3D = target
		lead = Vector3(body.velocity.x, 0.0, body.velocity.z) * lead_amount
	var want: Vector3 = target.global_position + cam_offset + lead
	global_position   = global_position.lerp(want, follow_speed * delta)
