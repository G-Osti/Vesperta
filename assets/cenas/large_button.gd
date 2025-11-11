extends TextureButton

var item = null:
	set(value):
		item = value
		_update()
@onready var CharacterMenu = %CharacterMenu
var locked = false
var default_color = Color("707982",1)
var target

func _get_item(repo):
	target = repo
	if repo.has(str(self.name)):
		item = repo[str(self.name)]
	else:
		repo[str(self.name)] = null
	
	if item != null:
		$Icon.set_texture(item.icon)
	self._update()

func _on_pressed():
	print("Pressed!")
	if !CharacterMenu.is_dragging and !CharacterMenu.equip_locked:
		CharacterMenu._select(self)

func _on_mouse_entered():
	if item != null:
		$Icon.size = Vector2(18, 18)
		$Icon.position = Vector2(4, 0)

func _on_mouse_exited():
	if item != null:
		$Icon.size = Vector2(16, 16)
		$Icon.position = Vector2(5, 1)

func _update():
	set_self_modulate(default_color)
	$Icon.size = Vector2(16, 16)
	$Icon.position = Vector2(5, 1)
	if item != null:
		$Icon.set_texture(item.icon)
		$Text.text = item.name
	else:
		queue_free()

func _write(text):
	$Text.text = text
