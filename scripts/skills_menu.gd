extends Control

@onready var level = $"../.."
@onready var entity:Node3D = $"../../Player/Entity"
@onready var entity_action = $"../CharUI/EntityAction"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _update():
	entity = level.control.entity_turn
	entity_action._update()
