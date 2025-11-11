extends TextureButton

var item = null:
	set(value):
		item = value
		_update()
@export_enum("Inventário","Equipamento","Habilidade","Classe")
var slot_type: String
@export_enum("Equipamento","Armadura","Acessório","Consumível","Recurso")
var equipped_type: String = "Recurso"
@onready var CharacterMenu = %CharacterMenu
var locked = false
var default_color = Color("707982",1)

func _get_item():
	if slot_type == "Inventário":
		if utils.Inventory.has(str(self.name)):
			item = utils.Inventory[str(self.name)]
		else:
			utils.Inventory[str(self.name)] = null
	elif slot_type == "Equipamento":
		if CharacterMenu.entity.equipped.has(str(self.name)):
			item = CharacterMenu.entity.equipped[str(self.name)]
		else:
			CharacterMenu.entity.equipped[str(self.name)] = null
	
	else:
		print("Erro! Sem item para pegar.")
	
	if item != null:
		$Icon.set_texture(item.icon)
	#self.size = Vector2(44,44)

func _on_pressed():
	if slot_type == "Equipamento" or slot_type == "Inventário":
		#if CharacterMenu.click_lock == false:
			#CharacterMenu.click_lock = true
		print(CharacterMenu.item.item.type)
		if !CharacterMenu.is_dragging and locked == false:
			if item != null:
				CharacterMenu._move_item(self)
		elif CharacterMenu.item.item.type == equipped_type or slot_type == "Inventário":
			if item != null and locked == false:
				CharacterMenu._swap_items(self)
			if item == null:
				CharacterMenu._drop_item(self)
		else:
			print("Erro! Item incompatível.")
			pass
		#CharacterMenu.click_lock = false
	elif slot_type == "Habilidade" or slot_type == "Classe":
		print("Erro! Sem função de aquisição de Habilidade ou Classe")
		pass

func _on_mouse_entered():
	if item != null:
		pass
		#$Icon.size = Vector2(44, 44)
		#$Icon.position = Vector2(1, 1)
	#size = Vector2(44,44)

func _on_mouse_exited():
	if item != null:
		pass
		#$Icon.size = Vector2(32, 32)
		#$Icon.position = Vector2(4, 4)

func _update():
	set_self_modulate(default_color)
	#size = Vector2(44,44)
	if item != null:
		$Back.visible = false
		$Icon.set_texture(item.icon)
	else:
		
		if slot_type == "Equipamento":
			$Back.visible = true
			if self.name == "hand":
				$Back.set_texture(load("res://assets/sprites/ícones/BW/Hand.png"))
			elif self.name == "armor":
				$Back.set_texture(load("res://assets/sprites/ícones/BW/Armor.png"))
			elif self.name == "acc1" or self.name == "acc2" or self.name == "acc3":
				$Back.set_texture(load("res://assets/sprites/ícones/BW/Ring.png"))
		$Icon.set_texture(null)
	
	#if locked == true:
		#set_self_modulate(default_color*Color(0.5,0.5,0.5,1))
	#if locked == false:
		#set_self_modulate(default_color*Color(1,1,1,1))
