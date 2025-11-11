extends TextureButton

var item = null:
	set(value):
		item = value
		_update()
@export_enum("Utilitátio","Armadura","Acessório")
var slot_type: String
@onready var CharacterMenu = %CharacterMenu
var locked = false
var default_color = Color("707982",1)

func _get_item():
	if CharacterMenu.entity.equipped.has(str(self.name)):
		item = CharacterMenu.entity.equipped[str(self.name)]
	else:
		CharacterMenu.entity.equipped[str(self.name)] = null
	
	if item != null:
		$Icon.set_texture(item.icon)
	#self.size = Vector2(44,44)

func _on_pressed():
	if !CharacterMenu.is_dragging and !CharacterMenu.equip_locked:
		if item != null:
			CharacterMenu._create_inventoty(slot_type,self)
		

func _on_mouse_entered():
	if item != null:
		$Icon.size = Vector2(44, 44)
		$Icon.position = Vector2(1, 1)

func _on_mouse_exited():
	if item != null:
		$Icon.size = Vector2(32, 32)
		$Icon.position = Vector2(4, 4)

func _update():
	set_self_modulate(default_color)
	$Icon.size = Vector2(32, 32)
	$Icon.position = Vector2(4, 4)
	if item != null:
		$Back.visible = false
		$Icon.set_texture(item.icon)
	else:
		$Back.visible = true
		if slot_type == "Utilitátio":
			$Back.set_texture(load("res://assets/sprites/ícones/BW/Hand.png"))
		if slot_type == "Armadura":
			$Back.set_texture(load("res://assets/sprites/ícones/BW/Armor.png"))
		if slot_type == "Acessório":
			$Back.set_texture(load("res://assets/sprites/ícones/BW/Ring.png"))
		$Icon.set_texture(null)
