extends Control

var grabbable = false
var grabbed = false
var origin_slot = null
var item = null:
	set(value):
		item = value
		_update()
var change = false
@onready var CharacterMenu = $"../../.."
var item_type = "Recurso"

#func _ready():
	#_update()

func _process(delta):
	#if grabbed == true:
	position = get_global_mouse_position()/$"..".scale-size/2 - $"..".position/$"..".scale #

func _update():
	if item != null:
		$Icon.set_texture(item.icon)
		$Icon.size = Vector2(16, 16)
		$Icon.position = Vector2(4, 4)
		item_type = item.type
	else:
		queue_free()
