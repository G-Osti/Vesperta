extends Node3D

@onready var level = $".."

var target = null
var def_path:PackedVector3Array

var state = "idle":
	set(value):
		state = value
			#utils.save_game()
var sel_coord:Vector3i

var scenario_agility = 20
var scenario_turn = 0

@onready var entity_turn:Node3D
@onready var entity_sel:Node3D

var selected_char = 0
var count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if level.phase=="battle":
		if state == "idle":
			_randomize_turns()
			state = "order"
		if state=="order":
			_get_turns()
		if state=="action":
			if entity_turn.ai == false:
				entity_sel = entity_turn
			entity_turn.state = "waiting"
			#_update()
			entity_turn._animation_update()
			level.camera._focus(entity_turn)
			_update()
			entity_turn._begin_turn()
			state = "wait"
			#level.char_ui._update()
			#level.turns._update()
			#utils.save_game()
		#if self.state=="wait_turn":
			#for entity in level.entities.get_children():
				#entity.state = "idle"
				#entity._animation_update()
				#if entity.turn >= entity_turn.turn:
					#entity_turn = entity
					#if entity_turn.ai == false:
						#entity_sel = entity_turn
			#entity_turn.state = "waiting"
			#self.state = "action"
			#_update()
			#entity_turn._animation_update()
			#level.camera._focus(entity_turn)
			#print("Flag 1")
			#entity_turn._begin_turn()
			#level.char_ui._update()
			#level.turns._update()
			#utils.save_game()
	
	#if level.phase=="preparing":
		
		
		#if entity_sel == null:
			#_get_char()
		#if entity_sel.state == "positioning":
			#entity_sel.position = Vector3(sel_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)

func _update():
	%Environment._grid_update(entity_turn)
	%Environment._mark_shadows()
	for entity in get_tree().get_nodes_in_group("entity"):
		entity._update()
		if entity.team == 1:
			for cell in entity.seen_cells:
				%Environment._clear_shadows(cell)
	if state == "action":
		entity_turn._animation_update()
		level.camera._focus(entity_turn)
		entity_turn._begin_turn()
		%UI._update()

#func _change_char(pos:bool=true):
	#if entity_sel.state == "positioning":
		#_liberate_char()
	#elif entity_sel.state == "positioned":
		#entity_sel.state = "idle"
		#entity_sel._update()
	#_count_next_char(pos)
	#_get_char()
#
#func _get_char():
	#var temp_count = 0
	#for char in utils.entity_database:
		#if utils.entity_database[char].team == 1:
			#if temp_count == count:
				##if utils.entity_database[char].available:
				#var positioned = false
				#for entity in get_tree().get_nodes_in_group("entity"):
					#if entity.team == 1:
						#if entity.name == char.trim_suffix(".tres"):
							#positioned = true
				#if positioned == false:
					#_get_new_char()
					#entity_sel.name = char.trim_suffix(".tres")
					#for propertyInfo in utils.entity_database[char].get_script().get_script_property_list():
						#var propertyName: String = propertyInfo.name
						#entity_sel.set(propertyName,utils.entity_database[char].get(propertyName))
					#entity_sel.state = "positioning"
					#entity_sel._setup()
					#level.char_ui._update()
					#return
				#else:
					##_liberate_char()
					#for EntityNode in get_tree().get_nodes_in_group("entity"):
						#if EntityNode.name == utils.entity_database[char].char_name:
							#entity_sel = EntityNode
							##for propertyInfo in utils.entity_database[char].get_script().get_script_property_list():
								##var propertyName: String = propertyInfo.name
								##entity_sel.set(propertyName,utils.entity_database[char].get(propertyName))
							#entity_sel.state = "positioned"
							#entity_sel._setup()
							#level.char_ui._update()
							#return
			#else:
				#temp_count += 1
#
#func _count_next_char(pos:bool=true):
	#var limit_count = 0
	#for char in utils.entity_database:
		#if utils.entity_database[char].team == 1:
			#limit_count += 1
	#if count <= limit_count-1 and count >= 0:
		#count += 1*int(pos)-1*int(!pos)
	#if count > limit_count-1:
		#count = 0
	#if count < 0:
		#count = limit_count-1
	##_liberate_char()
#
#func _place_char():
	##utils.entity_database[entity_sel.name+".tres"].available = false
	#entity_sel.state = "idle"
	#state = "idle"
	#entity_sel.cell_coord = sel_coord
	##entity_sel = null
	##_get_fov_raycast(sel_coord+Vector3i(0,2,0))
	#entity_sel._update()
	#_count_next_char()
	#_get_char()
#
#func _pickup_char():
	#entity_sel.state = "positioning"
	#state = "positioning"
	#entity_sel._update()
#
#func _get_new_char():
	#var new_entity = utils.default_entity.instantiate()
	#level.entities.add_child(new_entity)
	#entity_sel = new_entity
	#state = "positioning"
	##entity_sel.state = "positioning"
#
#func _liberate_char():
	#utils.entity_database[entity_sel.name+".tres"].available = true
	#entity_sel.queue_free()

func _action_movement(coord:Vector3i):
	if state == "wait":
		if level.environment.cells.has(coord):
			#state = "idle"
			if entity_turn.targets.has(coord):
				entity_turn._movement_action(coord)

func _get_turns():
	var MTT = null
	var flag = false
	for entity in get_tree().get_nodes_in_group("entity"):
		#entity._update()
		if entity.team != 0:
			if MTT != null:
				if (100-entity.turn) < MTT:
					MTT = 100 - entity.turn
			else:
				MTT = 100 - entity.turn
	for entity in get_tree().get_nodes_in_group("entity"):
		entity.turn += MTT
		if entity.turn >= 100:
			flag = true
			entity_turn = entity
	#print("Control: ",MTT," ",)
	if flag == true:
		state = "action"
	%UI._update()

func _sort(entity):
	#entity.turn += entity.VEL
	
	if entity.turn >= 100:
		entity_turn = entity
		state = "wait_turn"
		#turn_decided = true
	
func _death(entity):
	#for turn in level.ordering.get_children():
		#if turn.name == entity.name:
			#turn.queue_free()
	entity.queue_free()
	await entity.tree_exited
	%UI._create_turns()

#func _on_timer_timeout():
	#if state == "wait_timer":
		#state = "order"
	#$Timer.stop()
	#$Timer.wait_time = 0.2
	

func _view_range():
	pass

func _get_fov_raycast(from:Vector3):
	var mousePos = get_viewport().get_mouse_position()
	var ray_length = 6
	var space = %Camera.get_world_3d().direct_space_state
	#%Environment._mark_shadows()
	var cell_list: PackedVector3Array = []
	for tile in %Environment.cells:
		for tpos in [Vector3(0.49,0,0.49),Vector3(-0.49,0,0.49),Vector3(0.49,0,-0.49),Vector3(-0.49,0,-0.49)]:
			#for fpos in [Vector3(0.49,0,0.49),Vector3(-0.49,0,0.49),Vector3(0.49,0,-0.49),Vector3(-0.49,0,-0.49),Vector3(0,0,0),Vector3(0.49,0,0),Vector3(-0.49,0,0),Vector3(0,0,-0.49),Vector3(0,0,0.49)]:
			var fpos = Vector3(0,0,0)
			var to = Vector3(tile) + Vector3(0,0.45,0)
			var ray_query = PhysicsRayQueryParameters3D.create(Vector3(from)+fpos,Vector3(to)+tpos)
			var raycast_result = space.intersect_ray(ray_query)
			if raycast_result != {}:
				if %Environment.surface_cells.has(level.environment._get_cell(raycast_result.position,raycast_result.normal)) and !cell_list.has(level.environment._get_cell(raycast_result.position,raycast_result.normal)):
					var up_dot = raycast_result.normal.dot(Vector3.UP)
					if up_dot > 0.7:
						cell_list.append(level.environment._get_cell(raycast_result.position,raycast_result.normal))
					#%Environment._clear_shadows(level.environment._get_cell(raycast_result.position))
	for entity in get_tree().get_nodes_in_group("entity"):
		var ray_query = PhysicsRayQueryParameters3D.create(Vector3(from),Vector3(entity.cell_coord)+Vector3(0,0.5,0))
		var raycast_result = space.intersect_ray(ray_query)
		if raycast_result != {}:
			if !cell_list.has(entity.cell_coord):
				cell_list.append(entity.cell_coord)
	return cell_list
	
func _randomize_turns():
	for entity in get_tree().get_nodes_in_group("entity"):
		entity.turn += randi_range(-10,10) + entity.VEL
	
	#if raycast_result != {}:
		#return level.environment._get_cell(raycast_result.position,raycast_result.normal)

func _get_ai_action(entity):
	level.environment._get_movements(entity)
	target = null
	def_path.clear()
	for ptarget in %Entities.get_children():
		if ptarget.team == 1:
			var temp_path = level.environment._get_path(entity,ptarget.cell_coord)
			if def_path.is_empty() or def_path.size()>temp_path.size():
				def_path = temp_path
				target = ptarget
	
	if target != null and entity.action >= entity.action_base_cost:
		var target_cell:Vector3i
		if def_path.size()-2 <= entity.movement_range:
			target_cell = def_path[def_path.size()-1]
			level.control._action_movement(target_cell)
			return
		else:
			if entity.movement_range > 0:
				for i in def_path:
					if entity.movements.has(i):
						target_cell = i
				level.control._action_movement(target_cell)
				return
			else:
				entity._end_turn()
				return
	else:
		entity._end_turn()
		return
