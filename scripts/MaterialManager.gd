extends Node
## MaterialManager — Autoload that applies procedural StandardMaterial3D
## to all MeshInstance3D nodes that lack a surface material override.
## Runs after each room is loaded via RoomManager signal.

# ── Colour palette (Tunic / Pokemon Yellow inspired — muted, warm) ──────────
const COL_FLOOR     := Color(0.22, 0.24, 0.30)   # dark slate
const COL_FLOOR_LINE:= Color(0.30, 0.33, 0.40)   # subtle grid tint
const COL_WALL      := Color(0.38, 0.36, 0.44)   # concrete purple-grey
const COL_WALL_TOP  := Color(0.45, 0.42, 0.50)   # lighter cap
const COL_OBJ_BENCH := Color(0.52, 0.42, 0.32)   # wood-brown  (lab benches)
const COL_OBJ_TALL  := Color(0.35, 0.45, 0.50)   # steel-blue  (cabinets / shelves)
const COL_OBJ_SHORT := Color(0.48, 0.50, 0.42)   # olive-grey  (small equipment)
const COL_NPC_MORGAN:= Color(0.28, 0.58, 0.90)   # lab-coat blue
const COL_NPC_RILEY := Color(0.25, 0.78, 0.50)   # green scrubs
const COL_NPC_BOSS  := Color(0.70, 0.20, 0.20)   # intimidating red
const COL_NPC_DALE  := Color(0.85, 0.65, 0.20)   # sales gold
const COL_NPC_MIKE  := Color(0.55, 0.55, 0.55)   # press-room grey
const COL_NPC_DEF   := Color(0.60, 0.55, 0.70)   # default NPC lavender
const COL_PLAYER    := Color(0.95, 0.85, 0.55)   # warm cream (protagonist)
const COL_HAZARD    := Color(0.90, 0.25, 0.15)   # danger red
const COL_EXIT      := Color(0.0, 0.70, 0.85, 0.45)  # translucent teal
const COL_TASK      := Color(0.95, 0.82, 0.20, 0.35)  # translucent gold

# NPC colour lookup by npc_id
var _npc_colors: Dictionary = {
	"morgan": COL_NPC_MORGAN,
	"riley":  COL_NPC_RILEY,
	"holt":   COL_NPC_BOSS,
	"dale":   COL_NPC_DALE,
	"mike":   COL_NPC_MIKE,
}

func _ready() -> void:
	# Apply materials every time the scene tree changes a room
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	# Defer so the full subtree is ready
	if node is MeshInstance3D:
		_apply_material.call_deferred(node)

func _apply_material(mi: MeshInstance3D) -> void:
	if not is_instance_valid(mi):
		return
	# Skip if already has a material override
	if mi.get_surface_override_material(0) != null:
		return

	var mat := StandardMaterial3D.new()
	mat.roughness = 0.85
	mat.metallic  = 0.0

	var col: Color = _resolve_color(mi)
	mat.albedo_color = col

	# Translucent materials for exits/tasks
	if col.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = col

	mi.set_surface_override_material(0, mat)

func _resolve_color(mi: MeshInstance3D) -> Color:
	var parent: Node = mi.get_parent()
	if parent == null:
		return COL_WALL

	var pname: String = parent.name
	var gp: Node = parent.get_parent()
	var gp_name: String = gp.name if gp else ""

	# ── Player ──
	if pname == "Player" or parent.is_in_group("player"):
		return COL_PLAYER

	# ── Floor ──
	if pname == "Floor" or pname.begins_with("Floor"):
		return COL_FLOOR

	# ── Walls ──
	if gp_name == "Walls" or pname.begins_with("W"):
		if parent is StaticBody3D:
			return COL_WALL
		return COL_WALL

	# ── NPCs ──
	if gp_name == "NPCs" or parent.has_method("interact"):
		if parent.get("npc_id"):
			var npc_id: String = parent.get("npc_id")
			if npc_id in _npc_colors:
				return _npc_colors[npc_id]
		return COL_NPC_DEF

	# ── Hazards ──
	if gp_name == "Hazards" or parent.is_in_group("hazard"):
		return COL_HAZARD

	# ── Objects — colour by height ──
	if gp_name == "Objects" or pname.begins_with("O"):
		if mi.mesh and mi.mesh is BoxMesh:
			var h: float = mi.mesh.size.y
			if h >= 1.5:
				return COL_OBJ_TALL
			elif h >= 1.0:
				return COL_OBJ_TALL
			else:
				return COL_OBJ_BENCH
		return COL_OBJ_SHORT

	# ── Exits / Tasks (Area3D parents) ──
	if parent is Area3D:
		if parent.get("dest_room"):
			return COL_EXIT
		if parent.get("task_id"):
			return COL_TASK

	# Default
	return COL_WALL
