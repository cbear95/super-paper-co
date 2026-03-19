extends Area3D

@export var task_id    : String = "task"
@export var task_title : String = "Task"
@export var task_desc  : String = "Complete the task."
@export var xp_reward  : int   = 15
@export var stress_cost: float = 8.0

@onready var _hint: Label3D = $Hint

func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(body: Node) -> void:
	if body.is_in_group("player") and _hint:
		_hint.visible = not GameManager.is_task_done(task_id)

func _on_exit(body: Node) -> void:
	if body.is_in_group("player") and _hint:
		_hint.visible = false

func interact(_player: Node) -> void:
	if GameManager.is_task_done(task_id):
		return
	var cb: Callable = func():
		GameManager.complete_task(task_id, xp_reward, stress_cost)
	DialogueManager.start(
		"[TASK]", task_title, "task",
		Color(1.0, 0.88, 0.24, 1.0),
		[task_desc, "Press E or Space to complete."],
		cb)
