extends Node
## MaterialManager — Autoload that applies procedural StandardMaterial3D
## to all MeshInstance3D nodes that lack a surface material override.
## Runs after each room is loaded via RoomManager signal.

# ── Colour palette — Tunic / Pokémon Yellow warmth ───────────────────────────
# Tunic hallmarks: warm parchment floors, terracotta/stone walls,
# rich wood browns, vibrant saturated character colours, soft emissive glow.
const COL_FLOOR     := Color(0.82, 0.76, 0.62)   # parchment / aged paper
const COL_WALL      := Color(0.58, 0.52, 0.48)   # warm sandstone
const COL_WALL_TOP  := Color(0.68, 0.62, 0.55)   # lighter stone cap
const COL_OBJ_BENCH := Color(0.70, 0.50, 0.30)   # warm oak / lab bench
const COL_OBJ_TALL  := Color(0.42, 0.58, 0.68)   # steel-blue cabinet
const COL_OBJ_SHORT := Color(0.55, 0.68, 0.52)   # sage green equipment
const COL_NPC_MORGAN:= Color(0.30, 0.62, 0.95)   # bright lab blue
const COL_NPC_RILEY := Color(0.28, 0.88, 0.55)   # vivid green
const COL_NPC_BOSS  := Color(0.90, 0.22, 0.18)   # punchy boss red
const COL_NPC_DALE  := Color(0.98, 0.75, 0.12)   # sales-floor gold
const COL_NPC_MIKE  := Color(0.62, 0.65, 0.70)   # press-operator grey
const COL_NPC_DEF   := Color(0.72, 0.55, 0.88)   # soft lavender
const COL_PLAYER    := Color(1.00, 0.88, 0.38)   # bright warm yellow — Tunic fox energy
const COL_HAZARD    := Color(0.95, 0.28, 0.12)   # hot danger red
const COL_EXIT      := Color(0.05, 0.85, 0.78, 0.50)  # teal portal
const COL_TASK      := Color(1.00, 0.88, 0.20, 0.40)  # warm gold task

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
	mat.roughness = 0.72
	mat.metallic  = 0.0

	var col: Color = _resolve_color(mi)
	mat.albedo_color = col

	# Translucent materials for exits/tasks
	if col.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = col

	# Tunic-style: subtle emissive tint so objects hold colour in shadow
	mat.emission_enabled          = true
	mat.emission                  = Color(col.r * 0.12, col.g * 0.12, col.b * 0.12)
	mat.emission_energy_multiplier = 0.35

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
