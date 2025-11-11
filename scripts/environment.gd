extends Node3D

@onready var level = $".."
@onready var map: GridMap = $GridMap
@onready var mouse_overlay = $MouseOverlay
@onready var shadows_overlay = $ShadowsOverlay
@onready var effects_overlay = $EffectsOverlay
@onready var action_overlay = $ActionOverlay
@onready var astar = AStar3D.new()
@onready var cells: Array:
	set(value):
		cells = value
		for cell in cells:
			$"BackMap".set_cell_item(cell,0)
@onready var surface_cells = []

#@onready var player = $"../Player"

var path:PackedVector3Array

func _ready():
	cells = map.get_used_cells()

func _get_cell(pos:Vector3,normal):
	var top = false
	if normal == Vector3(0,1,0):
		top = true
	var cell = map.local_to_map(pos)-int(top)*Vector3i(0,1,0) #- Vector3i(face)
	#print(cell,top)
	if top==false:
		while map.get_cell_item(cell+Vector3i(0,1,0))!=-1: 
			cell += Vector3i(0,1,0)
	if map.get_cell_item(cell)==-1:
		cell -= Vector3i(0,1,0)
	#var cell_full = false
	#while !cell_full:
		#if map.get_cell_item(cell)!=-1:
			#cell -= Vector3i(0,1,0)
		#else:
			#cell_full = true
			#cell += Vector3i(0,1,0)
	
	#if cells.has(cell):
	return cell

func _get_movements(entity):
	#print("get_mov: ",entity.MOV*entity.PA)
	_grid_update(entity)
	entity.targets.clear()
	entity.targets.append(entity.cell_coord)
	entity.movements.clear()
	entity.movements.append(entity.cell_coord)
	entity.entities.clear()
	entity.entities.append(entity.cell_coord)
	for item in entity.movements:
		for cell in astar.get_point_connections(cells.find(Vector3i(item))):
			var temp_path = astar.get_point_path(cells.find(entity.cell_coord),cell)
			if !entity.movements.has(cells[cell]):
				#print(temp_path, " was: ", temp_path.size()-1<=entity.MOV*entity.PA)
				if temp_path.size()-1<=entity.MOVR+entity.ALC:
					_cell_declaration(entity,cell,temp_path,true)
				#elif entity.PAS <= entity.PAA:
					#_cell_declaration(entity,cell,temp_path,false)
	for fentity in get_tree().get_nodes_in_group("entity"):
		var temp_path = astar.get_point_path(cells.find(entity.cell_coord),cells.find(fentity.cell_coord))
		if temp_path.size()-1<=entity.MOVR+entity.ALC:
			_cell_declaration(entity,cells.find(fentity.cell_coord),temp_path,true)

func _cell_declaration(entity,cell,temp_path,mov=false):
	var entity_type = 0
	var impassible = false
	for target_entity in get_tree().get_nodes_in_group("entity"):
		if cells[cell] == target_entity.cell_coord:
			astar.set_point_weight_scale(cell,2)
			if target_entity.team != 0:
				if target_entity.team == entity.team:
					entity_type = 3 #ally
					impassible = false
				elif target_entity.team != 0:
					astar.set_point_weight_scale(cell,3)
					entity_type = 4 #enemy
					impassible = true
			else:
				astar.set_point_weight_scale(cell,3)
				entity_type = 6 #neutral
				impassible = true
	
	if temp_path.size()-1<=entity.MOVR+entity.ALC and !entity.entities.has(cells[cell]):
		entity.targets.append(cells[cell])
		var target_found = false
		for entities in get_tree().get_nodes_in_group("entity"):
			if entities.cell_coord == cells[cell]:
				target_found = true
		if target_found == true:
			entity.entities.append(cells[cell])
			if entity.ai == false:
				action_overlay.set_cell_item(cells[cell],entity_type)
		else:
			if temp_path.size()-1<=entity.MOVR and !entity.movements.has(cells[cell]):
				if mov == true:
					entity.movements.append(cells[cell])
				if entity.ai == false:
					action_overlay.set_cell_item(cells[cell],1)
	if impassible == true:
		for tile in astar.get_point_connections(cell):
			astar.disconnect_points(cell,tile)

func _get_surface_cells():
	for cell1 in cells:
		if map.get_cell_item(cell1+Vector3i(0,1,0))==-1:
			if !surface_cells.has(cell1):
				surface_cells.append(cell1)

func _prepare_overlay(area: PackedVector3Array):
	var temp_sum = Vector3i(0,0,0)
	for cell in area:
		if surface_cells.has(Vector3i(cell)):
			action_overlay.set_cell_item(cell,1)
		temp_sum += Vector3i(cell)
	level.camera._focus_coord(temp_sum/area.size())

#func _mark_overlay(cell:Vector3,type:int):
	#action_overlay.set_cell_item(cell,type)
	

func _mark_shadows():
	for cell in surface_cells:
		shadows_overlay.set_cell_item(cell,5)

func _clear_shadows(cell:Vector3i):
	shadows_overlay.set_cell_item(cell,-1)

func _get_path(entity,dest):
	path.clear()
	#_clear_movement()
	_connect_cells(entity)
	for tile in entity.entities:
		if astar.get_point_weight_scale(cells.find(tile))>2:
			for id in astar.get_point_connections(cells.find(tile)):
				astar.disconnect_points(cells.find(tile),id,true)
	path = astar.get_point_path(cells.find(entity.cell_coord),cells.find(dest))
	return path

func _mark_cell(cell:Vector3i):
	mouse_overlay.set_cell_item(cell,0)

func _clear_mouse():
	for cell in mouse_overlay.get_used_cells():
		mouse_overlay.set_cell_item(cell,-1)
	pass

func _clear_movement():
	for cell in action_overlay.get_used_cells():
		action_overlay.set_cell_item(cell,-1)
	pass

func _grid_update(entity):
	_clear_movement()
	astar.clear()
	for cell in cells:
		if !cells.has(cell+Vector3i(0,1,0)):
			astar.add_point(cells.find(cell), cell, 1)
	_connect_cells(entity)

func _connect_cells(entity):
	for cell1 in cells:
		if map.get_cell_item(cell1+Vector3i(0,1,0))==-1:
			if !surface_cells.has(cell1):
				surface_cells.append(cell1)
			for cell2 in cells:
				if !astar.are_points_connected(cells.find(cell1),cells.find(cell2),true):
					#astar.disconnect_points(cells.find(cell1),cells.find(cell2),true)
					if map.get_cell_item(cell2+Vector3i(0,1,0))==-1 and cell1!=cell2:
						if abs(cell1.y-cell2.y)<=entity.MOVV:
							if ((abs(cell1.x-cell2.x)<=1 and cell1.z==cell2.z) or (abs(cell1.z-cell2.z)<=1 and cell1.x==cell2.x)):
								astar.connect_points(cells.find(cell1),cells.find(cell2),true)
								astar.set_point_weight_scale(cells.find(cell1),1)
								astar.set_point_weight_scale(cells.find(cell2),1)

func _get_closest_tile(entity, target):
	#_clear_movement()
	_connect_cells(entity)
	var closest_tile:Vector3 = target
	for tile in entity.movements:
		if tile.distance_to(Vector3(entity.cell_coord)) < closest_tile.distance_to(Vector3(entity.cell_coord)) or closest_tile == Vector3(target):
			if astar.get_point_path(cells.find(target),cells.find(Vector3i(tile))).size() <= entity.ALC+1:
				closest_tile = tile
	_get_movements(entity)
	return Vector3i(closest_tile)
