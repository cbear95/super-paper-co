extends Node

signal stats_changed
signal player_died
signal task_completed(task_id: String)
signal menu_toggled(is_open: bool)
signal pickup_collected(item_name: String)
signal inventory_changed

const MAX_HP     : int   = 3
const MAX_STRESS : float = 100.0
const MAX_XP     : int   = 999
const SAVE_PATH  : String = "user://savegame.json"

var hp     : int   = 3
var stress : float = 0.0
var xp     : int   = 0
var mental : float = 100.0

var current_room   : String         = "Lab"
var completed_tasks: Array[String]  = []
var npc_dial_idx   : Dictionary     = {}
var menu_open      : bool           = false
var collected_pickups: Array[String] = []
var inventory_items: Dictionary = {
	"solvent": 0,
	"supplies": 0,
	"document": 0,
}

var _stress_tick: float = 0.0
var _poison_tick: float = 0.0

func _ready() -> void:
	reset_stats()

func _process(delta: float) -> void:
	_stress_tick += delta
	if _stress_tick >= 8.0:
		_stress_tick = 0.0
		if stress > 0.0:
			modify_stress(-1.5)
	_poison_tick += delta
	if _poison_tick >= 12.0:
		_poison_tick = 0.0
		if stress >= 80.0:
			hurt(1, "stress_poison")
	_recalc_mental()

func reset_stats() -> void:
	hp = MAX_HP
	stress = 0.0
	xp = 0
	mental = 100.0
	menu_open = false
	completed_tasks.clear()
	npc_dial_idx.clear()
	collected_pickups.clear()
	inventory_items = {
		"solvent": 0,
		"supplies": 0,
		"document": 0,
	}
	stats_changed.emit()
	inventory_changed.emit()

func set_menu_open(open: bool) -> void:
	if menu_open == open:
		return
	menu_open = open
	menu_toggled.emit(menu_open)

func hurt(amount: int, _src: String = "") -> void:
	hp = maxi(0, hp - amount)
	stats_changed.emit()
	if hp <= 0:
		player_died.emit()

func heal(amount: int) -> void:
	hp = mini(MAX_HP, hp + amount)
	stats_changed.emit()

func modify_stress(amount: float) -> void:
	stress = clampf(stress + amount, 0.0, MAX_STRESS)
	if stress >= MAX_STRESS:
		stress = MAX_STRESS * 0.5
		hurt(1, "stress_max")
	_recalc_mental()
	stats_changed.emit()

func add_xp(amount: int) -> void:
	xp = mini(MAX_XP, xp + amount)
	_recalc_mental()
	stats_changed.emit()

func _recalc_mental() -> void:
	var hr: float = float(hp) / float(MAX_HP)
	var sr: float = stress / MAX_STRESS
	var xb: float = minf(30.0, float(xp) / 10.0)
	mental = clampf(hr * 40.0 + (1.0 - sr) * 40.0 + xb, 0.0, 100.0)

func complete_task(task_id: String, xp_reward: int, stress_cost: float) -> void:
	if task_id in completed_tasks:
		return
	completed_tasks.append(task_id)
	add_xp(xp_reward)
	modify_stress(stress_cost)
	task_completed.emit(task_id)

func is_task_done(task_id: String) -> bool:
	return task_id in completed_tasks

func next_dial_idx(npc_id: String, max_sets: int) -> int:
	if npc_id not in npc_dial_idx:
		npc_dial_idx[npc_id] = 0
	var i: int = npc_dial_idx[npc_id]
	npc_dial_idx[npc_id] = (i + 1) % max_sets
	return i

func has_collected_pickup(pickup_id: String) -> bool:
	return pickup_id in collected_pickups

func register_pickup(pickup_id: String, item_name: String) -> bool:
	if has_collected_pickup(pickup_id):
		return false
	collected_pickups.append(pickup_id)
	pickup_collected.emit(item_name)
	inventory_changed.emit()
	return true

func register_inventory_pickup(pickup_id: String, item_name: String, item_kind: String, value: int) -> bool:
	if not register_pickup(pickup_id, item_name):
		return false
	match item_kind:
		"solvent", "supplies", "document":
			inventory_items[item_kind] = int(inventory_items.get(item_kind, 0)) + maxi(value, 1)
		_:
			inventory_items[item_kind] = int(inventory_items.get(item_kind, 0)) + maxi(value, 1)
	if item_kind == "document":
		add_xp(value)
	elif item_kind == "supplies" and hp < MAX_HP:
		use_inventory_item("supplies")
	inventory_changed.emit()
	return true

func item_count(item_kind: String) -> int:
	return int(inventory_items.get(item_kind, 0))

func use_inventory_item(item_kind: String) -> bool:
	var count: int = item_count(item_kind)
	if count <= 0:
		return false
	match item_kind:
		"solvent":
			modify_stress(-18.0)
		"supplies":
			if hp >= MAX_HP:
				return false
			heal(1)
		_:
			return false
	inventory_items[item_kind] = count - 1
	inventory_changed.emit()
	return true

func save_game() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file: " + SAVE_PATH)
		return false
	var payload: Dictionary = {
		"hp": hp,
		"stress": stress,
		"xp": xp,
		"mental": mental,
		"current_room": RoomManager.current_room,
		"spawn_position": {
			"x": RoomManager.spawn_position.x,
			"y": RoomManager.spawn_position.y,
			"z": RoomManager.spawn_position.z,
		},
		"completed_tasks": completed_tasks,
		"npc_dial_idx": npc_dial_idx,
		"collected_pickups": collected_pickups,
		"inventory_items": inventory_items,
	}
	file.store_string(JSON.stringify(payload))
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not read save file: " + SAVE_PATH)
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		push_error("Invalid save data in: " + SAVE_PATH)
		return false

	var data: Dictionary = parsed
	hp = int(data.get("hp", MAX_HP))
	stress = float(data.get("stress", 0.0))
	xp = int(data.get("xp", 0))
	mental = float(data.get("mental", 100.0))
	current_room = String(data.get("current_room", "Lab"))
	completed_tasks = Array(data.get("completed_tasks", []))
	npc_dial_idx = Dictionary(data.get("npc_dial_idx", {}))
	collected_pickups = Array(data.get("collected_pickups", []))
	inventory_items = {
		"solvent": int(Dictionary(data.get("inventory_items", {})).get("solvent", 0)),
		"supplies": int(Dictionary(data.get("inventory_items", {})).get("supplies", 0)),
		"document": int(Dictionary(data.get("inventory_items", {})).get("document", 0)),
	}

	var spawn_data: Dictionary = Dictionary(data.get("spawn_position", {}))
	RoomManager.current_room = current_room
	RoomManager.spawn_position = Vector3(
		float(spawn_data.get("x", 5.0)),
		float(spawn_data.get("y", 0.5)),
		float(spawn_data.get("z", 5.0))
	)

	stats_changed.emit()
	inventory_changed.emit()
	return true
