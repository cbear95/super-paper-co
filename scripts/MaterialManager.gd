extends Node
## MaterialManager — Autoload that applies procedural StandardMaterial3D
## to all MeshInstance3D nodes that lack a surface material override.
## Runs after each room is loaded via RoomManager signal.

# ── Colour palette — Tunic-like screenshot warmth ────────────────────────────
# Target: sunlit parchment stone, mossy green accents, cool blue shadow,
# and restrained teal glow concentrated on magical objects.
const COL_FLOOR      := Color(0.84, 0.78, 0.64)  # warm pale stone / paper floor
const COL_WALL       := Color(0.66, 0.58, 0.47)  # sunlit ruin stone
const COL_WALL_TRIM  := Color(0.48, 0.52, 0.58)  # cool shadow stone
const COL_OBJ_BENCH  := Color(0.72, 0.55, 0.32)  # warm timber
const COL_OBJ_TALL   := Color(0.43, 0.63, 0.58)  # moss-green equipment
const COL_OBJ_SHORT  := Color(0.58, 0.71, 0.47)  # brighter herb green
const COL_NPC_MORGAN := Color(0.36, 0.64, 0.92)
const COL_NPC_RILEY  := Color(0.40, 0.82, 0.52)
const COL_NPC_BOSS   := Color(0.84, 0.34, 0.23)
const COL_NPC_DALE   := Color(0.96, 0.74, 0.28)
const COL_NPC_MIKE   := Color(0.61, 0.66, 0.71)
const COL_NPC_DEF    := Color(0.70, 0.58, 0.84)
const COL_PLAYER     := Color(0.90, 0.93, 0.96)  # lab coat white
const COL_HAZARD     := Color(0.90, 0.34, 0.18)
const COL_EXIT       := Color(0.37, 0.89, 0.82, 0.56)
const COL_TASK       := Color(0.98, 0.88, 0.34, 0.42)

const ROOM_TINTS: Dictionary = {
	"Lab": {
		"floor": Color(0.98, 1.00, 1.02, 1.0),
		"wall": Color(0.98, 1.00, 1.04, 1.0),
		"object": Color(0.90, 1.02, 1.04, 1.0),
		"exit": Color(0.92, 1.06, 1.04, 1.0),
	},
	"Hallway": {
		"floor": Color(1.02, 0.98, 0.92, 1.0),
		"wall": Color(1.04, 0.96, 0.88, 1.0),
		"object": Color(1.02, 0.97, 0.90, 1.0),
		"exit": Color(0.95, 1.02, 1.00, 1.0),
	},
	"BossOffice": {
		"floor": Color(1.06, 0.94, 0.82, 1.0),
		"wall": Color(1.08, 0.92, 0.80, 1.0),
		"object": Color(1.08, 0.90, 0.78, 1.0),
		"exit": Color(0.92, 1.00, 0.98, 1.0),
	},
	"Warehouse": {
		"floor": Color(0.90, 0.94, 0.96, 1.0),
		"wall": Color(0.88, 0.94, 0.98, 1.0),
		"object": Color(0.90, 0.98, 0.96, 1.0),
		"exit": Color(0.94, 1.06, 1.06, 1.0),
	},
	"PrintRoom": {
		"floor": Color(1.03, 0.97, 0.86, 1.0),
		"wall": Color(1.04, 0.95, 0.86, 1.0),
		"object": Color(1.06, 0.95, 0.84, 1.0),
		"exit": Color(0.96, 1.04, 1.02, 1.0),
	},
	"PressHall": {
		"floor": Color(1.05, 0.96, 0.82, 1.0),
		"wall": Color(1.08, 0.93, 0.80, 1.0),
		"object": Color(1.10, 0.92, 0.74, 1.0),
		"exit": Color(0.98, 1.08, 1.04, 1.0),
	},
	"FinishingWing": {
		"floor": Color(0.94, 0.98, 0.98, 1.0),
		"wall": Color(0.92, 0.98, 1.02, 1.0),
		"object": Color(0.96, 1.02, 0.96, 1.0),
		"exit": Color(0.96, 1.08, 1.08, 1.0),
	},
}

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
	if mi.mesh == null or mi.mesh.get_surface_count() <= 0:
		return
	# Skip if already has a material override
	if mi.get_surface_override_material(0) != null:
		return

	var mat := StandardMaterial3D.new()
	mat.roughness = 0.78
	mat.metallic  = 0.0
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.rim_enabled = true
	mat.rim = 0.28
	mat.rim_tint = 0.14

	var col: Color = _resolve_color(mi)
	var room_key: String = _classify_material_family(mi)
	mat.albedo_color = _tint_for_room(col, room_key)

	# Translucent materials for exits/tasks
	if col.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = _tint_for_room(col, room_key)

	# Keep a faint emissive lift so colours survive cool shadow without turning flat.
	mat.emission_enabled          = true
	mat.emission                  = _resolve_emission(mi, col)
	mat.emission_energy_multiplier = _resolve_emission_energy(mi) + 0.05

	mi.set_surface_override_material(0, mat)

func _resolve_color(mi: MeshInstance3D) -> Color:
	var parent: Node = mi.get_parent()
	if parent == null:
		return COL_WALL

	var pname: String = parent.name
	var gp: Node = parent.get_parent()
	var gp_name: String = ""
	if gp != null:
		gp_name = gp.name

	# ── Player ──
	if pname == "Player" or parent.is_in_group("player"):
		return COL_PLAYER

	# ── Floor ──
	if pname == "Floor" or pname.begins_with("Floor"):
		return COL_FLOOR

	# ── Walls ──
	if gp_name == "Walls" or pname.begins_with("W"):
		if pname.to_lower().contains("trim") or pname.ends_with("Top"):
			return COL_WALL_TRIM
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

func _resolve_emission(mi: MeshInstance3D, col: Color) -> Color:
	var parent: Node = mi.get_parent()
	if parent == null:
		return Color(col.r * 0.08, col.g * 0.08, col.b * 0.08)

	var pname: String = parent.name
	var gp: Node = parent.get_parent()
	var gp_name: String = ""
	if gp != null:
		gp_name = gp.name

	if pname == "Player" or parent.is_in_group("player"):
		return Color(0.12, 0.16, 0.20)
	if gp_name == "Walls" or pname.begins_with("W"):
		return Color(0.06, 0.08, 0.10)
	if gp_name == "Objects" or pname.begins_with("O"):
		return Color(col.r * 0.10, col.g * 0.09, col.b * 0.08)
	if parent is Area3D and parent.get("dest_room"):
		return Color(0.09, 0.38, 0.34)
	if parent is Area3D and parent.get("task_id"):
		return Color(0.22, 0.18, 0.05)
	return Color(col.r * 0.10, col.g * 0.10, col.b * 0.10)

func _resolve_emission_energy(mi: MeshInstance3D) -> float:
	var parent: Node = mi.get_parent()
	if parent == null:
		return 0.28
	if parent is Area3D and parent.get("dest_room"):
		return 0.85
	if parent is Area3D and parent.get("task_id"):
		return 0.45
	if parent.name == "Player" or parent.is_in_group("player"):
		return 0.22
	return 0.30

func _classify_material_family(mi: MeshInstance3D) -> String:
	var parent: Node = mi.get_parent()
	if parent == null:
		return "wall"

	var pname: String = parent.name
	var gp: Node = parent.get_parent()
	var gp_name: String = ""
	if gp != null:
		gp_name = gp.name

	if pname == "Floor" or pname.begins_with("Floor"):
		return "floor"
	if gp_name == "Objects" or pname.begins_with("O"):
		return "object"
	if parent is Area3D and parent.get("dest_room"):
		return "exit"
	return "wall"

func _tint_for_room(col: Color, family: String) -> Color:
	var profile: Dictionary = ROOM_TINTS.get(GameManager.current_room, {})
	var tint: Color = profile.get(family, Color(1.0, 1.0, 1.0, 1.0))
	return Color(col.r * tint.r, col.g * tint.g, col.b * tint.b, col.a)
