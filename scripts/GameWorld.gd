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
@onready var _inventory_title: Label = $HUD/InventoryPanel/Margin/VBox/Title
@onready var _inventory_room_label: Label = $HUD/InventoryPanel/Margin/VBox/RoomLabel
@onready var _inventory_stats_label: Label = $HUD/InventoryPanel/Margin/VBox/StatsLabel
@onready var _inventory_save_label: Label = $HUD/InventoryPanel/Margin/VBox/SaveLabel

var _input_latch: Dictionary = {
	"inventory": false,
	"save": false,
	"load": false,
}
var _inventory_grid: RichTextLabel = null
var _inventory_actions: VBoxContainer = null
var _solvent_button: Button = null
var _supplies_button: Button = null
var _documents_label: Label = null

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
	GameManager.inventory_changed.connect(_refresh_inventory_panel)
	GameManager.stats_changed.connect(_refresh_inventory_panel)
	_build_inventory_layout()
	_refresh_inventory_panel()
	_on_menu_toggled(GameManager.menu_open)

func _process(_delta: float) -> void:
	_handle_global_input()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		_toggle_inventory()
		get_viewport().set_input_as_handled()
		return
	if GameManager.menu_open:
		return
	if event.is_action_pressed("save_game"):
		_cache_spawn_position()
		if GameManager.save_game():
			print("Game saved to ", GameManager.SAVE_PATH)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("load_game"):
		if GameManager.load_game():
			get_tree().change_scene_to_file("res://scenes/GameWorld.tscn")
		get_viewport().set_input_as_handled()

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
	RoomDressScript.apply_to_room(room, RoomManager.current_room)

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

func _handle_global_input() -> void:
	if GameManager.menu_open:
		return

func _cache_spawn_position() -> void:
	RoomManager.spawn_position = _player.global_position

func _toggle_inventory() -> void:
	var next_open: bool = not GameManager.menu_open
	GameManager.set_menu_open(next_open)
	if next_open:
		_cache_spawn_position()
		var saved: bool = GameManager.save_game()
		print("Inventory opened. Save ", "ok" if saved else "failed")
	_refresh_inventory_panel()

func _on_menu_toggled(is_open: bool) -> void:
	if _inventory:
		_inventory.visible = is_open
	_refresh_inventory_panel()

func _refresh_inventory_panel() -> void:
	if _inventory_title:
		_inventory_title.text = "ATTACHE CASE"
	if _inventory_room:
		_inventory_room.text = "Zone  %s" % RoomManager.current_room
	if _inventory_stats:
		_inventory_stats.text = "Vitals\nHP      %d / %d\nStress  %d\nXP      %d\nMental  %d" % [
			GameManager.hp,
			GameManager.MAX_HP,
			int(round(GameManager.stress)),
			GameManager.xp,
			int(round(GameManager.mental)),
		]
	if _inventory_save:
		_inventory_save.text = "Q  close / autosave\nMouse  use item\nK  manual save\nL  load save"
	if _inventory_grid:
		_inventory_grid.text = _inventory_grid_text()
	if _solvent_button:
		var solvent_count: int = GameManager.item_count("solvent")
		_solvent_button.text = "Use Solvent (%d)" % solvent_count
		_solvent_button.disabled = solvent_count <= 0 or GameManager.stress <= 0.0
	if _supplies_button:
		var supplies_count: int = GameManager.item_count("supplies")
		_supplies_button.text = "Use Pen + Notepad (%d)" % supplies_count
		_supplies_button.disabled = supplies_count <= 0 or GameManager.hp >= GameManager.MAX_HP
	if _documents_label:
		_documents_label.text = "Documents filed: %d" % GameManager.item_count("document")

func _build_inventory_layout() -> void:
	if _inventory == null:
		return
	_inventory.custom_minimum_size = Vector2(560.0, 320.0)
	_inventory.position = Vector2.ZERO
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.09, 0.10, 0.96)
	panel_style.border_color = Color(0.38, 0.46, 0.42, 0.95)
	panel_style.set_border_width_all(3)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	_inventory.add_theme_stylebox_override("panel", panel_style)
	if _inventory_title:
		_inventory_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_inventory_title.text = "ATTACHE CASE"
		_inventory_title.add_theme_font_size_override("font_size", 24)
		_inventory_title.add_theme_color_override("font_color", Color(0.86, 0.92, 0.84, 1.0))
	if _inventory_room_label:
		_inventory_room_label.text = "Location"
	if _inventory_stats_label:
		_inventory_stats_label.text = "Condition"
	if _inventory_save_label:
		_inventory_save_label.text = "Commands"
	if _inventory_grid == null:
		_inventory_grid = RichTextLabel.new()
		_inventory_grid.name = "CaseGrid"
		_inventory_grid.bbcode_enabled = true
		_inventory_grid.fit_content = true
		_inventory_grid.scroll_active = false
		_inventory_grid.custom_minimum_size = Vector2(500.0, 120.0)
		_inventory_grid.add_theme_font_size_override("normal_font_size", 16)
		_inventory_grid.add_theme_color_override("default_color", Color(0.82, 0.88, 0.82, 1.0))
		$HUD/InventoryPanel/Margin/VBox.add_child(_inventory_grid)
	if _inventory_actions == null:
		_inventory_actions = VBoxContainer.new()
		_inventory_actions.name = "InventoryActions"
		_inventory_actions.add_theme_constant_override("separation", 8)
		$HUD/InventoryPanel/Margin/VBox.add_child(_inventory_actions)
		_solvent_button = Button.new()
		_solvent_button.text = "Use Solvent"
		_solvent_button.focus_mode = Control.FOCUS_ALL
		_solvent_button.pressed.connect(_use_solvent)
		_inventory_actions.add_child(_solvent_button)
		_supplies_button = Button.new()
		_supplies_button.text = "Use Pen + Notepad"
		_supplies_button.focus_mode = Control.FOCUS_ALL
		_supplies_button.pressed.connect(_use_supplies)
		_inventory_actions.add_child(_supplies_button)
		_documents_label = Label.new()
		_documents_label.text = "Documents filed: 0"
		_documents_label.add_theme_color_override("font_color", Color(0.84, 0.88, 0.80, 1.0))
		_inventory_actions.add_child(_documents_label)

func _inventory_grid_text() -> String:
	var solvent_count: int = GameManager.item_count("solvent")
	var supply_count: int = GameManager.item_count("supplies")
	var doc_count: int = GameManager.item_count("document")

	var rows := [
		"[color=#b8c6b6]CASE LAYOUT[/color]",
		"[code][ ][S][S][D][ ]  Solvent x%d[/code]" % solvent_count,
		"[code][ ][N][N][D][ ]  Supplies x%d[/code]" % supply_count,
		"[code][ ][ ][ ][ ][ ]  Documents x%d[/code]" % doc_count,
		"[code][ ][ ][ ][ ][ ]  Room key items pending[/code]",
	]
	return "\n".join(rows)

func _use_solvent() -> void:
	if GameManager.use_inventory_item("solvent"):
		_refresh_inventory_panel()

func _use_supplies() -> void:
	if GameManager.use_inventory_item("supplies"):
		_refresh_inventory_panel()

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
