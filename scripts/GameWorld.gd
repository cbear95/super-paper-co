extends Node3D

const RoomDressScript = preload("res://scripts/RoomDress.gd")

@onready var _container: Node3D          = $RoomContainer
@onready var _player   : CharacterBody3D = $Player
@onready var _cam      : Camera3D        = $IsoCamera
@onready var _env      : WorldEnvironment = $WorldEnvironment
@onready var _sun      : DirectionalLight3D = $DirectionalLight
@onready var _bgm      : AudioStreamPlayer = $BGMPlayer
@onready var _inventory: Control = $HUD/InventoryPanel
@onready var _inventory_room: Label = $HUD/InventoryPanel/Margin/VBox/RoomValue
@onready var _inventory_stats: Label = $HUD/InventoryPanel/Margin/VBox/StatsValue
@onready var _inventory_save: Label = $HUD/InventoryPanel/Margin/VBox/SaveValue

const ROOM_LOOKS: Dictionary = {
	"Lab": {
		"bg": Color(0.56, 0.68, 0.70, 1.0),
		"ambient": Color(0.94, 0.96, 0.92, 1.0),
		"ambient_energy": 0.72,
		"bloom": 0.16,
		"sun": Color(1.00, 0.95, 0.79, 1.0),
		"sun_energy": 1.10,
		"brightness": 1.04,
		"contrast": 1.08,
		"saturation": 0.94,
	},
	"Hallway": {
		"bg": Color(0.52, 0.47, 0.39, 1.0),
		"ambient": Color(0.96, 0.88, 0.75, 1.0),
		"ambient_energy": 0.62,
		"bloom": 0.13,
		"sun": Color(1.00, 0.90, 0.66, 1.0),
		"sun_energy": 1.18,
		"brightness": 1.00,
		"contrast": 1.12,
		"saturation": 0.92,
	},
	"BossOffice": {
		"bg": Color(0.50, 0.38, 0.31, 1.0),
		"ambient": Color(0.94, 0.82, 0.70, 1.0),
		"ambient_energy": 0.58,
		"bloom": 0.11,
		"sun": Color(1.00, 0.86, 0.62, 1.0),
		"sun_energy": 1.22,
		"brightness": 0.98,
		"contrast": 1.14,
		"saturation": 0.90,
	},
	"Warehouse": {
		"bg": Color(0.44, 0.54, 0.57, 1.0),
		"ambient": Color(0.84, 0.92, 0.92, 1.0),
		"ambient_energy": 0.64,
		"bloom": 0.12,
		"sun": Color(0.90, 0.95, 1.00, 1.0),
		"sun_energy": 1.02,
		"brightness": 1.00,
		"contrast": 1.10,
		"saturation": 0.86,
	},
	"PrintRoom": {
		"bg": Color(0.58, 0.50, 0.40, 1.0),
		"ambient": Color(0.98, 0.90, 0.78, 1.0),
		"ambient_energy": 0.66,
		"bloom": 0.14,
		"sun": Color(1.00, 0.92, 0.70, 1.0),
		"sun_energy": 1.16,
		"brightness": 1.02,
		"contrast": 1.12,
		"saturation": 0.94,
	},
	"PressHall": {
		"bg": Color(0.62, 0.54, 0.42, 1.0),
		"ambient": Color(0.99, 0.90, 0.73, 1.0),
		"ambient_energy": 0.70,
		"bloom": 0.15,
		"sun": Color(1.00, 0.89, 0.63, 1.0),
		"sun_energy": 1.18,
		"brightness": 1.00,
		"contrast": 1.15,
		"saturation": 0.96,
	},
	"FinishingWing": {
		"bg": Color(0.46, 0.56, 0.58, 1.0),
		"ambient": Color(0.89, 0.95, 0.94, 1.0),
		"ambient_energy": 0.66,
		"bloom": 0.13,
		"sun": Color(0.94, 0.97, 1.00, 1.0),
		"sun_energy": 1.06,
		"brightness": 1.00,
		"contrast": 1.08,
		"saturation": 0.88,
	},
}

func _ready() -> void:
	_apply_room_look()
	_start_bgm()
	_load_room()
	_player.global_position = RoomManager.spawn_position
	var cam_node: Camera3D = _cam
	cam_node.set("target", _player)
	GameManager.menu_toggled.connect(_on_menu_toggled)
	_refresh_inventory_panel()
	_on_menu_toggled(GameManager.menu_open)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		_toggle_inventory()
		get_viewport().set_input_as_handled()
		return

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.menu_open:
		return
	if event.is_action_pressed("save_game"):
		if GameManager.save_game():
			print("Game saved to ", GameManager.SAVE_PATH)
	elif event.is_action_pressed("load_game"):
		if GameManager.load_game():
			get_tree().change_scene_to_file("res://scenes/GameWorld.tscn")

func _load_room() -> void:
	for c: Node in _container.get_children():
		c.queue_free()
	var path: String = RoomManager.ROOM_SCENES.get(RoomManager.current_room, "")
	if path.is_empty():
		push_error("No scene path for room: " + RoomManager.current_room)
		return
	var packed: PackedScene = load(path)
	if packed == null:
		push_error("Could not load: " + path)
		return
	var room: Node3D = packed.instantiate()
	_container.add_child(room)
	RoomDressScript.apply_to_room(room)

func _apply_room_look() -> void:
	if _env == null or _env.environment == null or _sun == null:
		return
	var look: Dictionary = ROOM_LOOKS.get(RoomManager.current_room, ROOM_LOOKS["Lab"])
	var env: Environment = _env.environment
	env.background_color = look["bg"]
	env.ambient_light_color = look["ambient"]
	env.ambient_light_energy = look["ambient_energy"]
	env.glow_bloom = look["bloom"]
	env.adjustment_enabled = true
	env.adjustment_brightness = look["brightness"]
	env.adjustment_contrast = look["contrast"]
	env.adjustment_saturation = look["saturation"]
	_sun.light_color = look["sun"]
	_sun.light_energy = look["sun_energy"]

func _toggle_inventory() -> void:
	var next_open: bool = not GameManager.menu_open
	GameManager.set_menu_open(next_open)
	if next_open:
		var saved: bool = GameManager.save_game()
		print("Inventory opened. Save ", "ok" if saved else "failed")
	_refresh_inventory_panel()

func _on_menu_toggled(is_open: bool) -> void:
	if _inventory:
		_inventory.visible = is_open
	_refresh_inventory_panel()

func _refresh_inventory_panel() -> void:
	if _inventory_room:
		_inventory_room.text = RoomManager.current_room
	if _inventory_stats:
		_inventory_stats.text = "HP %d/3\nStress %d\nXP %d\nMental %d" % [
			GameManager.hp,
			int(round(GameManager.stress)),
			GameManager.xp,
			int(round(GameManager.mental)),
		]
	if _inventory_save:
		_inventory_save.text = "Q opens this menu and autosaves.\nK manual save, L load."

func _start_bgm() -> void:
	if _bgm == null:
		return
	var stream: AudioStream = _load_bgm_stream()
	if stream != null:
		_bgm.stream = stream
		_bgm.volume_db = -9.0
		_bgm.play()
		print("BGM started: SuperPaperCo.mp3")
		return
	push_warning("Missing soundtrack file: res://SuperPaperCo.mp3")

func _load_bgm_stream() -> AudioStream:
	if ResourceLoader.exists("res://SuperPaperCo.mp3"):
		var imported: AudioStream = load("res://SuperPaperCo.mp3")
		if imported != null:
			if imported.has_method("set_loop"):
				imported.set_loop(true)
			return imported

	if not FileAccess.file_exists("res://SuperPaperCo.mp3"):
		return null

	var mp3 := AudioStreamMP3.new()
	mp3.data = FileAccess.get_file_as_bytes("res://SuperPaperCo.mp3")
	mp3.loop = true
	return mp3
