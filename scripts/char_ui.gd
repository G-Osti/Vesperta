extends Control

@onready var level = $"../../.."
@onready var entity = $"../../../Player/Entity"
@onready var entity_action = $EntityAction
var mouse_in = false

# Called when the node enters the scene tree for the first time.
#func _ready():
	#for child in [$Actions/Habilidade1, $Actions/Habilidade2, $Actions/Habilidade3, $Actions/Habilidade4, $Actions/HabilidadeE]:
		#child.command = self
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
#
#func _update():
	#entity = level.control.entity_sel
	#entity_action._update()
	#if %Control.entity_sel != %Control.entity_turn:
		#self.modulate = Color(0.5,0.5,0.5,1)
		#for item in $Actions.get_children(true):
			#item.set_mouse_filter(2)
		#for item in %Conditions.get_children(true):
			#item.set_mouse_filter(2)
		#$EntityAction/Character.set_mouse_filter(2)
#
	#else:
		#self.modulate = Color(1,1,1,1)
		#for item in $Actions.get_children(true):
			#item.set_mouse_filter(1)
		#for item in %Conditions.get_children(true):
			#item.set_mouse_filter(1)
		#$EntityAction/Character.set_mouse_filter(1)
	#
	##$Actions/EActions/TextureRect.rotation_degrees = 0
	##if level.control.state == "action":
		##level.selected_action = $Actions/Action.name
		##$Actions/Action.set_self_modulate(Color(1.5,1.5,1.5))
	#
	#for child in [$Actions/Habilidade1, $Actions/Habilidade2, $Actions/Habilidade3, $Actions/Habilidade4, $Actions/HabilidadeE]:
		#child.skill = entity.skills[child.name]
		#child._update()
#
#func _on_mouse_entered():
	#level.mouse_in_interface = true
#
#func _on_mouse_exited():
	#level.mouse_in_interface = false
#
#func _on_end_turn_button_up():
	#entity._end_turn()
#
##func _on_e_actions_button_up():
	##print($"../EActions".visible)
	##if $"../EActions".visible == true:
		##$"../EActions".visible = false
	##elif $"../EActions".visible == false:
		##$"../EActions".visible = true
##
##func _on_action_button_up():
	##if level.selected_action != $Actions/Action.name:
		##level.selected_action = "Action"
		##$Actions/Action.set_self_modulate(Color(1.5,1.5,1.5))
	##else:
		##level.selected_action = null
		##$Actions/Action.set_self_modulate(Color(1,1,1))
#
#func _on_item_toggled(toggled_on):
	#pass # Replace with function body.
#
#func _on_basic_action_toggled(toggled_on):
	#pass # Replace with function body.
#
#func _execute(skill):
	#print(skill.name)
