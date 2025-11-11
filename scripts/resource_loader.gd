extends Node

var default_item_cache: Dictionary = {}
var item_cache: Dictionary = {}
var default_entity_cache: Dictionary = {}
var entity_cache: Dictionary = {}
var arena_entity_cache: Dictionary = {}
var skill_cache: Dictionary = {}
var tile_cache: Dictionary = {}
var scenario_cache: Dictionary = {}
var selected_scene: Dictionary = {}
@export_dir var item_folder

@export var SAVE_FILE:String = "user://savegame.data"

# Called when the node enters the scene tree for the first time.
func _ready():
	var folder = DirAccess.open(item_folder)
	folder.list_dir_begin()
	
	var file_name = folder.get_next()
	
	while file_name != "":
		default_item_cache[file_name] = load(item_folder + "/" + file_name)
		print(file_name)
		file_name = folder.get_next()
	#print("####")
	#save_game()
	#var test = load_game()
	#print(test["Espada.tres"].damage)
	#new_item("Espada")
	#new_item("Espada")
	#print("####")

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	pass

func get_default_item(ID):
	if ID != "":
		return default_item_cache[ID + ".tres"]

func get_item(ID):
	if ID != "":
		return item_cache[ID + ".tres"]

func get_default_entity(ID):
	if ID != "":
		return default_entity_cache[ID + ".tres"]

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

func save_game():
	var saved_game:SavedGame = SavedGame.new()
	saved_game.item_list = default_item_cache
	ResourceSaver.save(saved_game, "user://savegame.tres")

func load_game():
	var saved_game:SavedGame = load("user://savegame.tres") as SavedGame
	print(saved_game.item_list)
	return saved_game.item_list
