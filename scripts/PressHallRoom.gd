extends Node3D

const RoomBuildRef = preload("res://scripts/RoomBuild.gd")

func _ready() -> void:
	_build_room()

func _build_room() -> void:
	RoomBuildRef.add_floor(self, Vector2(24.0, 16.0), Vector3(12.0, 0.0, 8.0))

	var walls := Node3D.new()
	walls.name = "Walls"
	add_child(walls)
	RoomBuildRef.add_perimeter_walls(walls, 24, 16, [
		Vector3(0.5, 1.1, 8.5),
		Vector3(23.5, 1.1, 8.5),
	])

	var objects := Node3D.new()
	objects.name = "Objects"
	add_child(objects)
	RoomBuildRef.add_press_machine(objects, "PressA", Vector3(6.5, 0.0, 5.5), 1.0)
	RoomBuildRef.add_press_machine(objects, "PressB", Vector3(12.0, 0.0, 5.5), 1.15)
	RoomBuildRef.add_press_machine(objects, "PressC", Vector3(17.5, 0.0, 5.5), 1.0)
	RoomBuildRef.add_box_object(objects, "InkCartA", Vector3(5.0, 0.45, 10.5), Vector3(1.0, 0.9, 1.0))
	RoomBuildRef.add_box_object(objects, "InkCartB", Vector3(7.0, 0.45, 10.5), Vector3(1.0, 0.9, 1.0))
	RoomBuildRef.add_box_object(objects, "PalletA", Vector3(14.5, 0.35, 10.5), Vector3(1.6, 0.7, 1.2))
	RoomBuildRef.add_box_object(objects, "PalletB", Vector3(17.0, 0.35, 10.5), Vector3(1.6, 0.7, 1.2))
	RoomBuildRef.add_box_object(objects, "ControlDesk", Vector3(11.5, 0.45, 13.0), Vector3(2.2, 0.9, 1.2))
	RoomBuildRef.add_pennant_line(self, Vector3(4.0, 4.6, 9.2), 7, 2.2, Color(0.93, 0.78, 0.38, 1.0))
	RoomBuildRef.add_pennant_line(self, Vector3(5.0, 4.0, 11.8), 6, 2.3, Color(0.40, 0.86, 0.80, 1.0))

	var npcs := Node3D.new()
	npcs.name = "NPCs"
	add_child(npcs)
	RoomBuildRef.add_npc(
		npcs,
		"NinaLead",
		Vector3(9.5, 0.0, 12.0),
		"nina",
		"Nina Alvarez",
		"Press Lead",
		"colleague_f",
		Color(0.95, 0.58, 0.24, 1.0),
		[
			"Throughput lives or dies on setup discipline.|A clean makeready saves the whole shift.",
			"These presses hum when they are happy.|You can hear bad registration before you can see it.",
		]
	)
	RoomBuildRef.add_npc(
		npcs,
		"EliTech",
		Vector3(15.5, 0.0, 12.0),
		"eli",
		"Eli Mercer",
		"Maintenance Tech",
		"colleague_m",
		Color(0.46, 0.80, 0.88, 1.0),
		[
			"The feeder drift is back.|I shimmed the guide rail, but it still chatters at speed.",
			"If a prototype feels magical, maintenance made it look easy.|That is the whole trick.",
		]
	)

	var exits := Node3D.new()
	exits.name = "Exits"
	add_child(exits)
	RoomBuildRef.add_exit(exits, "ExitPrintRoom", Vector3(0.5, 0.75, 8.5), "PrintRoom", Vector3(11.5, 0.5, 7.5), "x")
	RoomBuildRef.add_exit(exits, "ExitFinishingWing", Vector3(23.5, 0.75, 8.5), "FinishingWing", Vector3(4.5, 0.5, 7.5), "x")

	var tasks := Node3D.new()
	tasks.name = "Tasks"
	add_child(tasks)
	RoomBuildRef.add_task(tasks, "TaskMakeready", Vector3(12.0, 0.75, 12.5), "press_makeready", "Makeready Check", "Verify plate fit, blanket pressure, and feeder alignment before the next production run.")
