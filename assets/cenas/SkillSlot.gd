extends TextureButton
class_name skill_slot

var skill:Object = null
var command = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _update():
	if skill != null:
		$TextureRect.set_texture(skill.icon)
	else:
		$TextureRect.set_texture(null)

func _on_toggled(toggled_on):
	if command != null:
		command._execute(self.skill)
