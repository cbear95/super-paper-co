extends Area3D

@export var pickup_id: String = "pickup"
@export var item_name: String = "Item"
@export var item_kind: String = "solvent"
@export var value: int = 1

var _base_y: float = 0.0
var _visual: Node3D = null

func _ready() -> void:
	if GameManager.has_collected_pickup(pickup_id):
		queue_free()
		return
	monitoring = true
	body_entered.connect(_on_body_entered)
	_base_y = position.y
	_visual = _build_visual()
	set_process(true)

func _process(_delta: float) -> void:
	if _visual == null:
		return
	var t: float = Time.get_ticks_msec() * 0.001
	_visual.position.y = 0.08 + sin(t * 2.2) * 0.05
	_visual.rotation.y += 0.015

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if not GameManager.register_pickup(pickup_id, item_name):
		queue_free()
		return

	match item_kind:
		"solvent":
			GameManager.modify_stress(-float(value))
		"supplies":
			GameManager.heal(value)
		"document":
			GameManager.add_xp(value)

	queue_free()

func _build_visual() -> Node3D:
	var root := Node3D.new()
	root.name = "Visual"
	add_child(root)

	var color := Color(0.8, 0.9, 1.0, 1.0)
	if item_kind == "solvent":
		color = Color(0.42, 0.90, 0.82, 1.0)
		_add_bottle(root, color)
	elif item_kind == "supplies":
		color = Color(0.96, 0.86, 0.38, 1.0)
		_add_notepad(root, color)
	else:
		color = Color(1.0, 0.46, 0.54, 1.0)
		_add_document(root, color)

	var hint := Label3D.new()
	hint.text = item_name
	hint.position = Vector3(0.0, 0.7, 0.0)
	hint.font_size = 24
	hint.modulate = Color(0.95, 0.96, 1.0, 0.95)
	hint.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(hint)
	return root

func _add_bottle(root: Node3D, color: Color) -> void:
	var body := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.08
	cyl.bottom_radius = 0.10
	cyl.height = 0.28
	body.mesh = cyl
	body.position = Vector3(0.0, 0.14, 0.0)
	body.set_surface_override_material(0, _mat(color, true))
	root.add_child(body)

	var cap := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.08, 0.06, 0.08)
	cap.mesh = box
	cap.position = Vector3(0.0, 0.32, 0.0)
	cap.set_surface_override_material(0, _mat(Color(0.94, 0.96, 0.98, 1.0)))
	root.add_child(cap)

func _add_notepad(root: Node3D, color: Color) -> void:
	var pad := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.24, 0.05, 0.18)
	pad.mesh = box
	pad.position = Vector3(0.0, 0.06, 0.0)
	pad.set_surface_override_material(0, _mat(color))
	root.add_child(pad)

	var pen := MeshInstance3D.new()
	var pen_mesh := BoxMesh.new()
	pen_mesh.size = Vector3(0.26, 0.03, 0.03)
	pen.mesh = pen_mesh
	pen.position = Vector3(0.02, 0.11, 0.0)
	pen.rotation_degrees = Vector3(0.0, 24.0, 18.0)
	pen.set_surface_override_material(0, _mat(Color(0.16, 0.22, 0.52, 1.0)))
	root.add_child(pen)

func _add_document(root: Node3D, color: Color) -> void:
	var sheet := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.26, 0.04, 0.20)
	sheet.mesh = box
	sheet.position = Vector3(0.0, 0.08, 0.0)
	sheet.rotation_degrees = Vector3(0.0, -18.0, 0.0)
	sheet.set_surface_override_material(0, _mat(color))
	root.add_child(sheet)

	var seal := MeshInstance3D.new()
	var seal_box := BoxMesh.new()
	seal_box.size = Vector3(0.05, 0.05, 0.05)
	seal.mesh = seal_box
	seal.position = Vector3(0.06, 0.12, 0.04)
	seal.set_surface_override_material(0, _mat(Color(0.95, 0.83, 0.32, 1.0)))
	root.add_child(seal)

func _mat(color: Color, transparent: bool = false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.74
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.rim_enabled = true
	mat.rim = 0.36
	mat.rim_tint = 0.18
	if transparent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(color.r * 0.10, color.g * 0.11, color.b * 0.12)
	mat.emission_energy_multiplier = 0.40
	return mat
