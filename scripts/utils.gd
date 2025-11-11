extends Node

var item_database: Dictionary = {}
var item_cache: Dictionary = {}
var entity_database: Dictionary = {}
var entity_cache: Dictionary = {}
var skill_cache: Dictionary = {}
var tile_cache: Dictionary = {}
var scenario_cache: Dictionary = {}
var selected_scene: Dictionary = {}
@export_dir var item_path = "res://recursos/itens/"
@export_dir var char_path = "res://recursos/personagens/"

@export var SAVE_FILE:String = "user://savegame.data"

var default_entity: PackedScene = preload("res://assets/cenas/entity.tscn")

var configs: Dictionary = {
	"slot_anim_vel": 6,
	"char_anim_vel": 1,
	"ui_scale":1
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var item_folder = DirAccess.open(item_path)
	item_folder.list_dir_begin()
	var item_file_name = item_folder.get_next()
	while item_file_name != "":
		item_database[item_file_name.left(-5)] = load(item_path + "/" + item_file_name)
		add_item(item_database[item_file_name.left(-5)])
		item_file_name = item_folder.get_next()
	item_folder.list_dir_end()
	
	var char_folder = DirAccess.open(char_path)
	char_folder.list_dir_begin()
	var char_file_name = char_folder.get_next()
	while char_file_name != "":
		var char = load(char_path + "/" + char_file_name)
		entity_database[char_file_name] = char
		char_file_name = char_folder.get_next()
	char_folder.list_dir_end()

func add_item(item):
	var temp_name:String
	var n = 0
	var valid = false
	while valid == false:
		temp_name = str(item.name)+str(n)
		if !item_cache.has(str(temp_name)):
			item_cache[str(temp_name)] = item_database[str(item.name)]
			valid = true
		else:
			n+=1
	var m = 0
	valid = false
	while valid == false:
		if !Inventory.has(str(m)):
			Inventory[str(m)] = item_database[str(item.name)]
			valid = true
		else:
			m+=1

func get_default_item(ID):
	if ID != "":
		return item_database[ID + ".tres"]

func get_item(ID):
	if ID != "":
		return item_cache[ID + ".tres"]

func get_default_entity(ID):
	if ID != "":
		return entity_database[ID + ".tres"]

func get_entity(ID):
	if ID != "":
		return entity_cache[ID + ".tres"]

func get_skill(ID):
	if ID != "":
		return skill_cache[ID + ".tres"]

func new_item(ID):
	var new_item:ItemData = get_default_item(ID).duplicate()
	new_item.C1 = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	new_item.C2 = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	new_item.C3 = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	item_cache[str(new_item)] = new_item

#func save_game():
	#var saved_game:SavedGame = SavedGame.new()
	#saved_game.item_cache = item_cache
	#
	#for EntityNode in get_tree().get_nodes_in_group("entity"):
		#var SavedData:CharacterData = CharacterData.new()
		#for propertyInfo in SavedData.get_script().get_script_property_list():
			#var propertyName: String = propertyInfo.name
			#var propertyValue = EntityNode.get(propertyName)
			#SavedData.set(propertyName,propertyValue)
		#entity_cache[EntityNode.name] = SavedData
	#saved_game.entity_cache = entity_cache
	#
	#saved_game.level_state = get_tree().root.get_node("Level").state
	#saved_game.spawn_coords = get_tree().root.get_node("Level").spawn_coords
	#saved_game.seen_cells = get_tree().root.get_node("Level").seen_cells
	#saved_game.phase = get_tree().root.get_node("Level").phase
	#saved_game.sel_coord = get_tree().root.get_node("Level").control.sel_coord
	#saved_game.scenario_agility = get_tree().root.get_node("Level").control.scenario_agility
	#saved_game.scenario_turn = get_tree().root.get_node("Level").control.scenario_turn
	#saved_game.entity_turn_name = get_tree().root.get_node("Level").control.entity_turn.name
	#saved_game.entity_sel_name = get_tree().root.get_node("Level").control.entity_sel.name
	#
	#saved_game.camera_position = get_tree().root.get_node("Level").camera.position
	#saved_game.camera_rotation = get_tree().root.get_node("Level").camera.rotation
	#saved_game.camera_zoom = get_tree().root.get_node("Level").camera.zoom
	#
	##saved_game.astar = get_tree().root.get_node("Level").environment.astar
	##print(saved_game.astar," ",get_tree().root.get_node("Level").environment.astar)
	#saved_game.cells = get_tree().root.get_node("Level").environment.cells
	#saved_game.surface_cells = get_tree().root.get_node("Level").environment.surface_cells
	#saved_game.path = get_tree().root.get_node("Level").environment.path
	#
	#ResourceSaver.save(saved_game, "user://savegame.tres")
#
#func load_game():
	#var saved_game:SavedGame = load("user://savegame.tres") as SavedGame
	#entity_cache = saved_game.entity_cache
	#
	#for EntityNode in get_tree().get_nodes_in_group("entity"):
		#EntityNode.free()
	#for EntityNode in saved_game.entity_cache:
		#var EntityInstance = default_entity.instantiate()
		#get_tree().root.get_node("Level").entities.add_child(EntityInstance)
		#EntityInstance.name = EntityNode
	#
	#for EntityNode in get_tree().get_nodes_in_group("entity"):
		#for propertyInfo in saved_game.entity_cache[EntityNode.name].get_script().get_script_property_list():
			#var propertyName: String = propertyInfo.name
			#EntityNode.set(propertyName,entity_cache[EntityNode.name].get(propertyName))
	#
	#get_tree().root.get_node("Level").state = saved_game.level_state
	#get_tree().root.get_node("Level").spawn_coords = saved_game.spawn_coords
	#get_tree().root.get_node("Level").seen_cells = saved_game.seen_cells
	#get_tree().root.get_node("Level").phase = saved_game.phase
	#get_tree().root.get_node("Level").control.sel_coord = saved_game.sel_coord
	#get_tree().root.get_node("Level").control.scenario_agility = saved_game.scenario_agility
	#get_tree().root.get_node("Level").control.scenario_turn = saved_game.scenario_turn
	#
	#for EntityNode in get_tree().get_nodes_in_group("entity"):
		#if EntityNode.name == saved_game.entity_turn_name:
			#get_tree().root.get_node("Level").control.entity_turn = EntityNode
			#get_tree().root.get_node("Level").char_ui.entity = EntityNode
		#if EntityNode.name == saved_game.entity_sel_name:
			#get_tree().root.get_node("Level").control.entity_sel = EntityNode
	#
	#get_tree().root.get_node("Level").camera.position = saved_game.camera_position
	#get_tree().root.get_node("Level").camera.rotation = saved_game.camera_rotation
	#get_tree().root.get_node("Level").camera.zoom = saved_game.camera_zoom
	#
	##get_tree().root.get_node("Level").environment.astar = saved_game.astar
	##print(get_tree().root.get_node("Level").environment.astar," ",saved_game.astar)
	#get_tree().root.get_node("Level").environment.cells = saved_game.cells
	#get_tree().root.get_node("Level").environment.surface_cells = saved_game.surface_cells
	#get_tree().root.get_node("Level").environment.path = saved_game.path
	#
	#get_tree().root.get_node("Level")._update()
	#return saved_game.item_cache

func save_config(file_path: String, section: String, key: String, value: Variant) -> void:
	var config = ConfigFile.new()
	config.load(file_path)
	config.set_value(section, key, value)
	config.save(file_path)

func load_config(file_path: String, section: String, key: String, default_value: Variant) -> Variant:
	var config = ConfigFile.new()
	config.load(file_path)
	return config.get_value(section, key, default_value)

var Inventory:Dictionary = {}
