extends Node

signal stats_changed
signal player_died
signal task_completed(task_id: String)

const MAX_HP     : int   = 3
const MAX_STRESS : float = 100.0
const MAX_XP     : int   = 999

var hp     : int   = 3
var stress : float = 0.0
var xp     : int   = 0
var mental : float = 100.0

var current_room   : String         = "Lab"
var completed_tasks: Array[String]  = []
var npc_dial_idx   : Dictionary     = {}

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
	completed_tasks.clear()
	npc_dial_idx.clear()
	stats_changed.emit()

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
