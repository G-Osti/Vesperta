extends Node

@onready var control = $Control
@onready var environment = $Environment
#@onready var player = $Player
#@onready var ai = $AI
@onready var entities = $Entities
@onready var objects = $Objects
@onready var camera = $Camera
@onready var turns: Control = $UI/Turns
@onready var select: Control = %Select
@onready var action_ui = $UI/InferiorMenu/ActionUI

var mouse_in_entity = null

var action_in_progress = false
var mouse_in_interface = false
var mouse_in_menu = false

#var spawn_coords = [Vector3i(2,0,2),Vector3i(3,0,2),Vector3i(4,0,2),Vector3i(2,0,3),Vector3i(2,0,4),Vector3i(3,0,3),Vector3i(4,0,4),Vector3i(3,0,4),Vector3i(4,0,3)]
var seen_cells = []

var anim_vel = 5
var phase = "preparing":
	set(value):
		#if phase == "preparing" and value == "battle":
			#control._randomize_turns()
			#turns._create_turns()
			#select._create_sels()
		phase = value
		if value == "preparing":
			environment._get_surface_cells()
			%UI._create_turns()
			%UI._create_sels()
			#environment._prepare_overlay(spawn_coords)
var state = "arena"
var menu_state = "none"
var mouse_in_overlay = false
var mouse_coord
var selected_action = null

#func _ready():
	#phase = "preparing"

func _process(_delta):
	if phase == "preparing":
		%UI._create_turns()
		%UI._create_sels()
		phase = "battle"
	if mouse_in_interface == false and mouse_in_menu == false:
		mouse_in_overlay = false
	if mouse_in_interface == true or mouse_in_menu == true:
		mouse_in_overlay = true
	
	if action_in_progress == false and control.state == "wait":
		state = "arena"
	if action_in_progress == true or control.state != "wait":
		state = "occupied"
	
	
	environment._clear_mouse()
	if !mouse_in_overlay:
		mouse_coord = camera._mouse_world_pos()
		_mouse_in_entity()
		if mouse_in_entity != null:
			if mouse_in_entity.mouse_in_area and mouse_in_entity.state != "positioning":
				mouse_coord = mouse_in_entity.cell_coord
		if mouse_coord != null:
			control.sel_coord = mouse_coord
			environment._mark_cell(control.sel_coord)
			#$UI/TerrainStatus/Coordinates.text = str("X: ",control.sel_coord.x," Y: ",control.sel_coord.y," Z: ",control.sel_coord.z)
			#if Input.is_action_just_pressed("mouse1"):
				#print("Click!")
				#if state == "arena":
					#print("flag 1")
					#if control.state == "wait":
						#print("flag 2")
						#control._action_movement(mouse_coord)
	
	$"UI/DebugPanelLeft/Label".text = "Size: "+str(roundf(%Camera.camera.size*10)/10)+"\nCoord: "+str(%Control.sel_coord.x)+", "+str(%Control.sel_coord.y)+", "+str(%Control.sel_coord.z)+"\n"+"Type: "+str(%Environment.map.get_cell_item(%Control.sel_coord))

func _unhandled_input(event):
	if Input.is_action_just_pressed("esc"):
		_menu_input($UI/PauseMenu)
	if Input.is_action_just_pressed("debug"):
		$UI/DebugPanelLeft.visible = !$UI/DebugPanelLeft.visible
		$UI/DebugPanelRight.visible = !$UI/DebugPanelRight.visible
	if Input.is_action_just_pressed("mouse1"):
		print("Click!")
		if state == "arena" and !mouse_in_overlay:
			#print("flag 1")
			if control.state == "wait" and mouse_coord != null:
				#print("flag 2")
				control._action_movement(mouse_coord)
	#if phase == "preparing":
		#if mouse_coord != null:
			#if Input.is_action_just_pressed("mouse1"):
				#if control.entity_sel.state == "positioning":
					#if spawn_coords.has(mouse_coord):
						#var occuppied_tile = false
						#for EntityNode in get_tree().get_nodes_in_group("entity"):
							#if EntityNode.cell_coord == mouse_coord:
								#occuppied_tile = true
						#if occuppied_tile == false:
							#control._place_char()
							#_prepare_button()
							#return
						#return
					#return
				#else:
					#control._pickup_char()
					#_prepare_button()
					#return
		#if Input.is_action_just_pressed("tab"):
			#if Input.is_action_pressed("shift"):
				#control._change_char(false)
			#else:
				#control._change_char()
			#_prepare_button()
	#if event is InputEventMouseMotion:
	#pass

func _menu_input(menu):
	match menu_state:
		"none":
			mouse_in_menu = true
			menu.visible = true
			menu_state = "menus"
		"menus":
			mouse_in_menu = false
			%CharacterMenu.visible = false
			%PauseMenu.visible = false
			menu_state = "none"

func _update():
	turns._create_turns()
	select._create_sels()
	for EntityNode in get_tree().get_nodes_in_group("entity"):
		EntityNode._update()
	control._update()
	#char_ui._update()
	turns._update()
	%CharUI._update()

func _on_prepared_button_mouse_entered():
	mouse_in_interface = true

func _on_prepared_button_mouse_exited():
	mouse_in_interface = false

#func _on_prepared_button_button_up():
	#%Environment._clear_movement()
	#$UI/InferiorMenu/PreparedButton.visible = false
	#mouse_in_interface = false
	#control.entity_sel.state = "idle"
	#control.entity_sel._update()
	#phase = "battle"
	#control.state = "order"
	#control._update()

func _prepare_button():
	if phase == "preparing":
		if control.state == "positioning":
			$UI/InferiorMenu/PreparedButton.visible = false
		elif control.state == "idle":
			$UI/InferiorMenu/PreparedButton.visible = true
	else:
		$UI/InferiorMenu/PreparedButton.visible = false

func _mouse_in_entity():
	mouse_in_entity = null
	if !mouse_in_overlay:
		for EntityNode in get_tree().get_nodes_in_group("entity"):
			#EntityNode.overlay.visible = false
			if EntityNode.mouse_in_area == true or EntityNode.mouse_in_coord == true:
				if mouse_in_entity == null:
					mouse_in_entity = EntityNode
				else:
					if mouse_in_entity.position.distance_to(camera.camera.position) > EntityNode.position.distance_to(camera.camera.position):
						mouse_in_entity = EntityNode
		#if mouse_in_entity != null:
			#mouse_in_entity.overlay.visible = true
