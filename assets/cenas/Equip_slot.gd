extends TextureButton

var item = null:
	set(value):
		item = value
		_update()
@export_enum("Equipamento","Armadura","Acessório","Classe","Suporte","Extra")
var slot_type: String
@onready var CharacterMenu = %CharacterMenu
var locked = false
var default_color = Color("707982",1)

func _ready():
	%CharacterMenu.visible = false

func _get_item():
	if CharacterMenu.entity.equips.has(str(self.name)):
		item = CharacterMenu.entity.equips[str(self.name)]
	else:
		CharacterMenu.entity.equips[str(self.name)] = null
	
	if item != null:
		$Icon.set_texture(item.icon)
	
	self._update()
	#self.size = Vector2(44,44)

func _on_pressed():
	if !CharacterMenu.is_dragging and !CharacterMenu.equip_locked:
		if CharacterMenu.Inventory != null:
			CharacterMenu._destroy_inventory()
			if CharacterMenu.Inventory_target != self:
				CharacterMenu._create_inventory(self)
		else:
			CharacterMenu._create_inventory(self)

func _on_mouse_entered():
	if item != null:
		$Icon.size = Vector2(40, 40)
		$Icon.position = Vector2(2, 2)

func _on_mouse_exited():
	if item != null:
		$Icon.size = Vector2(32, 32)
		$Icon.position = Vector2(6, 6)

func _update():
	set_self_modulate(default_color)
	$Icon.size = Vector2(32, 32)
	$Icon.position = Vector2(6, 6)
	if item != null:
		$Back.visible = false
		$Icon.set_texture(item.icon)
	else:
		$Back.visible = true
		if slot_type == "Equipamento":
			$Back.set_texture(load("res://assets/sprites/ícones/BW/Hand.png"))
		if slot_type == "Armadura":
			$Back.set_texture(load("res://assets/sprites/ícones/BW/Armor.png"))
		if slot_type == "Acessório":
			$Back.set_texture(load("res://assets/sprites/ícones/BW/Ring.png"))
		if slot_type == "Classe":
			$Back.set_texture(load("res://assets/sprites/ícones/BW/1.png"))
		if slot_type == "Suporte":
			$Back.set_texture(load("res://assets/sprites/ícones/BW/2.png"))
		if slot_type == "Extra":
			$Back.set_texture(load("res://assets/sprites/ícones/BW/E.png"))
		$Icon.set_texture(null)
