extends StaticBody3D

@export var npc_id       : String       = "npc"
@export var npc_name     : String       = "NPC"
@export var npc_role     : String       = ""
@export var portrait_type: String       = "default"
@export var dial_color   : Color        = Color(0.4, 0.7, 1.0, 1.0)
@export var stress_add   : float        = 0.0
@export var xp_add       : int         = 5
@export var boss_chance  : float        = 0.75
@export var dial_sets    : Array[String]= []

func _ready() -> void:
	add_to_group("npc")

func interact(_player: Node) -> void:
	if DialogueManager.is_active:
		return
	var lines: Array = _pick_lines()
	var cb: Callable = func():
		GameManager.add_xp(xp_add)
		GameManager.modify_stress(stress_add)
	DialogueManager.start(npc_name, npc_role, portrait_type, dial_color, lines, cb)

func _pick_lines() -> Array:
	if dial_sets.is_empty():
		return ["..."]
	if npc_id == "boss_holt":
		return _boss_lines()
	var idx: int = GameManager.next_dial_idx(npc_id, dial_sets.size())
	return Array(dial_sets[idx].split("|"))

func _boss_lines() -> Array:
	var bad: Array = []
	var good: Array = []
	for i: int in range(dial_sets.size()):
		var s: Array = Array(dial_sets[i].split("|"))
		if i < 3:
			bad.append(s)
		else:
			good.append(s)
	if randf() < boss_chance and not bad.is_empty():
		return bad[randi() % bad.size()]
	if not good.is_empty():
		return good[randi() % good.size()]
	return ["..."]
