class_name SavedGame
extends Resource

@export var item_cache:Dictionary
@export var entity_cache:Dictionary

@export var level_state:String
@export var action_in_progress = false
@export var mouse_in_interface = false
@export var mouse_in_menu = false

@export var spawn_coords = [Vector3i(2,0,2),Vector3i(3,0,2),Vector3i(4,0,2),Vector3i(2,0,3),Vector3i(2,0,4),Vector3i(3,0,3),Vector3i(4,0,4),Vector3i(3,0,4),Vector3i(4,0,3)]
@export var seen_cells = []

@export var anim_vel = 5
@export var phase = "preparing"
@export var state = "arena"
@export var menu_state = "none"
@export var overlay_state = "none"
var mouse_coord
var selected_action = null

@export var sel_coord:Vector3i

@export var scenario_agility = 10
@export var scenario_turn = 0

@export var entity_turn_name:String
@export var entity_sel_name:String

@export var camera_position:Vector3
@export var camera_rotation:Vector3
@export var camera_zoom:float

var astar:AStar3D
var cells:Array
var surface_cells:Array
var path:PackedVector3Array
