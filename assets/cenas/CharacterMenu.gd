extends Control

@onready var level = $"../.."

var InvSize = 20
var is_dragging = false
var first = true
var click_lock = false

var origin_slot:TextureButton

@onready var entity = %Control.entity_sel
@onready var character #= entity.equips

var equip_locked = false

var inventory_up = false:
	set(value):
		inventory_up = value
		if value == true:
			$CharScrn/Inventory.visible = true
			$CharScrn/Skills.visible = false
		if value == false:
			$CharScrn/Inventory.visible = false
			$CharScrn/Skills.visible = true

@export var drop_slot = 0

var Inventory
var Inventory_target
var Inventory_filter

var item_node = load("res://assets/cenas/item.tscn")
var slot_node = load("res://assets/cenas/slot.tscn")
var large_node = load("res://assets/cenas/large_button.tscn")

var equip_slot_node = load("res://assets/cenas/Equip_slot.tscn")
var temp_invt_node = load("res://assets/cenas/temp_inventory.tscn")

var item:Control

#func process():
	#if first == true: #Solução ruim... alterar quando possível
		#for item in $Panel/Items.get_children():
			#item._update()
		#first = false

func _on_visibility_changed():
	is_dragging = false
	if visible == false:
		_despawn()
	
	if visible == true:
		_despawn()
		_update()
		#_spawn_inv($CharScrn/Inventory/Scroll/Grid)
		_slot_update()

func _create_inventory(slot):
	Inventory = temp_invt_node.instantiate()
	Inventory_target = slot
	%CharScrn.add_child(Inventory)
	Inventory.name = "Inventory"
	
	var Empty_slot = large_node.instantiate()
	Inventory.get_child(0).get_child(0).add_child(Empty_slot)
	Empty_slot._write("Empty")
	Empty_slot.CharacterMenu = self
	if slot.name == "Classe" or slot.name == "Suporte":
		print(entity.unlocked_classes)
		Empty_slot.target = entity.unlocked_classes
		var m:int = 0
		for n in entity.unlocked_classes.keys():
			if m == int(n):
				m+=1
			if entity.unlocked_classes.has(str(n)):
				if entity.unlocked_classes[str(n)] != null:
					var instance = large_node.instantiate()
					Inventory.get_child(0).get_child(0).add_child(instance)
					instance.name = str(n)
					instance._get_item(entity.unlocked_classes)
					instance.CharacterMenu = self
		Empty_slot.name = str(m)
	elif slot.name == "Extra":
		Empty_slot.target = entity.unlocked_eskills
		print(entity.unlocked_eskills)
		var m:int = 0
		for n in entity.unlocked_eskills.keys():
			if m == int(n):
				m+=1
			if entity.unlocked_eskills.has(str(n)):
				if entity.unlocked_eskills[str(n)] != null:
					var instance = large_node.instantiate()
					Inventory.get_child(0).get_child(0).add_child(instance)
					instance.name = str(n)
					instance._get_item(entity.unlocked_eskills)
					instance.CharacterMenu = self
		Empty_slot.name = str(m)
	else:
		Empty_slot.target = utils.Inventory
		var m:int = 0
		for n in utils.Inventory.keys():
			if m == int(n):
				m+=1
			if utils.Inventory.has(str(n)):
				if utils.Inventory[str(n)] != null:
					if utils.Inventory[str(n)].type == Inventory_target.slot_type:
						var instance = large_node.instantiate()
						Inventory.get_child(0).get_child(0).add_child(instance)
						instance.name = str(n)
						instance._get_item(utils.Inventory)
						instance.CharacterMenu = self
		Empty_slot.name = str(m)

func _destroy_inventory():
	if Inventory != null:
		Inventory.queue_free()
		Inventory = null

func _select(slot):
	print("Selected!")
	slot.target[str(slot.name)] = Inventory_target.item
	entity.equips[str(Inventory_target.name)] = slot.item
	if slot.target[str(slot.name)] == null:
		slot.target.erase(str(slot.name))
	_slot_update()
	_update()

func _spawn_inv(InvNode):
	#var n = 0
	#first = true
	_update()
	
	for n in InvSize:
		var instance = slot_node.instantiate()
		
		InvNode.add_child(instance)
		instance.name = str(n)#str(instance.get_index())
		instance.slot_type = "Inventário"
		instance._get_item()
		instance.CharacterMenu = self
		instance._update()

func _slot_update():
	print("Slots Updated!")
	if self.is_node_ready():
		#for slot in $CharScrn/Inventory/Scroll/Grid.get_children():
			#slot._get_item()
			#slot._update()
		for slot in $CharScrn/Equip/Slots.get_children():
			slot._update()
		$CharScrn/Skills/SkillsList/Equipamento._get_item()
		$CharScrn/Skills/SkillsList/Extra._get_item()
		$CharScrn/Skills/SkillsList/Suporte._get_item()
		$CharScrn/Skills/SkillsList/Classe._get_item()
		$CharScrn/Status/List/characteristics/TURN.self_modulate = (Color("707982",1))
		$CharScrn/Status/List/characteristics/ACT.self_modulate = (Color("707982",1))
		$CharScrn/Status/List/characteristics/DEF.self_modulate = (Color("707982",1))
		$CharScrn/Status/List/characteristics2/MOV.self_modulate = (Color("707982",1))
		$CharScrn/Status/List/characteristics2/ATQ.self_modulate = (Color("707982",1))
	else:
		self.visible = false

func _despawn():
	is_dragging = false
	#utils.Inventory.clear()
	#for item in $Panel/Items.get_children():
		##utils.Inventory[item.slot] = item.item
		#item.queue_free()
	
	#for slot in $CharScrn/Inventory/Scroll/Grid.get_children():
		#slot.queue_free()
	
	if item != null:
		item.queue_free()

func _move_item(slot):
	#click_lock = true
	#slot.has_item = false
	var instance = item_node.instantiate()
	item = instance
	if slot.slot_type == "Inventário":
		item.item = utils.Inventory[str(slot.name)]
	if slot.slot_type == "Equipamento":
		item.item = entity.equips[str(slot.name)]
	slot.item = null
	origin_slot = slot
	$CharScrn.add_child(item)
	is_dragging = true
	_update()

func _swap_items(slot):
	if item != null:
		#if item.item_type == slot.slot_type or slot.slot_type == "Todos":
			#click_lock = true
			
		if slot.slot_type == "Inventário":
			item.item = utils.Inventory[str(slot.name)]
			if origin_slot.slot_type == "Inventário":
				utils.Inventory[str(slot.name)] = utils.Inventory[str(origin_slot.name)]
				utils.Inventory[str(origin_slot.name)] = item.item
			if origin_slot.slot_type == "Equipamento":
				utils.Inventory[str(slot.name)] = entity.equips[str(origin_slot.name)]
				entity.equips[str(origin_slot.name)] = item.item
			slot.item = utils.Inventory[str(slot.name)]
		
		if slot.slot_type == "Equipamento":
			item.item = entity.equips[str(slot.name)]
			if origin_slot.slot_type == "Inventário":
				entity.equips[str(slot.name)] = utils.Inventory[str(origin_slot.name)]
				utils.Inventory[str(origin_slot.name)] = item.item
			if origin_slot.slot_type == "Equipamento":
				entity.equips[str(slot.name)] = entity.equips[str(origin_slot.name)]
				entity.equips[str(origin_slot.name)] = item.item
			slot.item = entity.equips[str(slot.name)]
			
			#if slot.get_parent().name == "Main" or slot.get_parent().name == "Accs":
				#item.item = utils.sel_character["Equipped"][slot.n]
				#if origin_slot.get_parent().name == "Grid":
					#if utils.get_item(utils.Inventory[origin_slot.n]).two_handed == true and utils.get_item(utils.Inventory[slot.n]).two_handed == false:
						#var n
						#if slot.n == 0:
							#n = 2
						#if slot.n == 2:
							#n = 0
						#$Panel/Equiped/Main.get_child(n).locked = true
						#for sel_slot in $Panel/Inv/Grid.get_children():
							#if sel_slot.has_item == false and sel_slot != origin_slot and $Panel/Equiped/Main.get_child(n).item != "Empty":
								#utils.Inventory[sel_slot.n] = $Panel/Equiped/Main.get_child(n).item
								#sel_slot.item = utils.Inventory[sel_slot.n]
								#sel_slot.has_item = true
								#sel_slot._update()
								#utils.sel_character["Equipped"][$Panel/Equiped/Main.get_child(n).n] = "Empty"
								#$Panel/Equiped/Main.get_child(n).item = "Empty"
								#$Panel/Equiped/Main.get_child(n).has_item = false
								#$Panel/Equiped/Main.get_child(n)._update()
					#if utils.get_item(utils.Inventory[origin_slot.n]).two_handed == false:# and rl.get_item(utils.Inventory[slot.n]).two_handed == true:
						#var n
						#if slot.n == 0:
							#n = 2
						#if slot.n == 2:
							#n = 0
						#$Panel/Equiped/Main.get_child(n).locked = false
						#$Panel/Equiped/Main.get_child(n).item = "Empty"
					#utils.sel_character["Equipped"][slot.n] = utils.Inventory[origin_slot.n]
					#utils.Inventory[origin_slot.n] = item.item
				#if origin_slot.get_parent().name == "Main" or origin_slot.get_parent().name == "Accs":
					#if utils.get_item(utils.sel_character["Equipped"][origin_slot.n]).two_handed == true:
						#var n
						#if origin_slot.n == 0:
							#n = 2
						#if origin_slot.n == 2:
							#n = 0
						#$Panel/Equiped/Main.get_child(n).locked = false
						#$Panel/Equiped/Main.get_child(n).item = "Empty"
					#utils.sel_character["Equipped"][slot.n] = utils.sel_character["Equipped"][origin_slot.n]
					#utils.sel_character["Equipped"][origin_slot.n] = item.item
				#slot.item = utils.sel_character["Equipped"][slot.n]
		item._update()
		slot._update()
	else:
		is_dragging = false
	#_slot_update()
	_update()

func _drop_item(slot):
	if item != null:
		#if item.item_type == slot.slot_type or slot.slot_type == "Todos":
		if slot.slot_type == "Inventário":
			utils.Inventory[str(slot.name)] = item.item
			slot.item = utils.Inventory[str(slot.name)]
		if slot.slot_type == "Equipamento":
			entity.equips[str(slot.name)] = item.item
			slot.item = entity.equips[str(slot.name)]
			#if utils.get_item(item.item).two_handed == true:
				#if slot.item == "Empty" or slot.item == null:
					#var n
					#if slot.n == 0:
						#n = 2
					#if slot.n == 2:
						#n = 0
					#$Panel/Equiped/Main.get_child(n).locked = true
					#$Panel/Equiped/Main.get_child(n).item = "Empty"
				#var two_handed_item
				#if origin_slot.get_parent().name == "Grid":
					#two_handed_item = utils.get_item(utils.Inventory[origin_slot.n]).two_handed
				#if (origin_slot.get_parent().name == "Main" or origin_slot.get_parent().name == "Accs"):
					#two_handed_item = utils.get_item(utils.Inventory[origin_slot.n]).two_handed
				#if two_handed_item and utils.get_item(utils.Inventory[slot.n]).two_handed == false:
					#var n
					#if slot.n == 0:
						#n = 2
					#if slot.n == 2:
						#n = 0
					#$Panel/Equiped/Main.get_child(n).locked = true
					#for sel_slot in $Panel/Inv/Grid.get_children():
						#if sel_slot.has_item == false and sel_slot != origin_slot and $Panel/Equiped/Main.get_child(n).item != "Empty":
							#utils.Inventory[sel_slot.n] = $Panel/Equiped/Main.get_child(n).item
							#sel_slot.item = utils.Inventory[sel_slot.n]
							#sel_slot.has_item = true
							#sel_slot._update()
							#utils.sel_character["Equipped"][$Panel/Equiped/Main.get_child(n).n] = "Empty"
							#$Panel/Equiped/Main.get_child(n).item = "Empty"
							#$Panel/Equiped/Main.get_child(n).has_item = false
							#$Panel/Equiped/Main.get_child(n)._update()
				#if slot.locked:
					#slot.locked = false
					#var n
					#if slot.n == 0:
						#n = 2
					#if slot.n == 2:
						#n = 0
					#$Panel/Equiped/Main.get_child(n).locked = true
					#for sel_slot in $Panel/Inv/Grid.get_children():
						#if sel_slot.has_item == false and sel_slot != origin_slot and $Panel/Equiped/Main.get_child(n).item != "Empty":
							#utils.Inventory[sel_slot.n] = $Panel/Equiped/Main.get_child(n).item
							#sel_slot.item = utils.Inventory[sel_slot.n]
							#sel_slot.has_item = true
							#sel_slot._update()
							#utils.sel_character["Equipped"][$Panel/Equiped/Main.get_child(n).n] = "Empty"
							#$Panel/Equiped/Main.get_child(n).item = "Empty"
							#$Panel/Equiped/Main.get_child(n).has_item = false
							#$Panel/Equiped/Main.get_child(n)._update()
			#else:
				#if slot.locked:
					#slot.locked = false
					#var n
					#if slot.n == 0:
						#n = 2
					#if slot.n == 2:
						#n = 0
					#$Panel/Equiped/Main.get_child(n).locked = false
					#for sel_slot in $Panel/Inv/Grid.get_children():
						#if sel_slot.has_item == false and sel_slot != origin_slot and $Panel/Equiped/Main.get_child(n).item != "Empty":
							#utils.Inventory[sel_slot.n] = $Panel/Equiped/Main.get_child(n).item
							#sel_slot.item = utils.Inventory[sel_slot.n]
							#sel_slot.has_item = true
							#sel_slot._update()
							#utils.sel_character["Equipped"][$Panel/Equiped/Main.get_child(n).n] = "Empty"
							#$Panel/Equiped/Main.get_child(n).item = "Empty"
							#$Panel/Equiped/Main.get_child(n).has_item = false
							#$Panel/Equiped/Main.get_child(n)._update()
		if origin_slot.slot_type == "Inventário" and origin_slot != slot:
			utils.Inventory[str(origin_slot.name)] = null
		if origin_slot.slot_type == "Equipamento" and origin_slot != slot:
			entity.equips[str(origin_slot.name)] = null
		item.queue_free()
		is_dragging = false
	else:
		is_dragging = false
	_update()

func _on_inv_sort_children():
	#_slot_update()
	if visible == true:
		for slot in $CharScrn/Inventory/Scroll/Grid.get_children():
			if slot.item != null:
				slot._update()
		#for slot in $Panel/Equiped/Main.get_children():
			#if slot.has_item == true:
				#slot._update()
		#for slot in $Panel/Equiped/Accs.get_children():
			#if slot.has_item == true:
				#slot._update()

func _on_inv_scroll_ended():
	pass

func _update():
	var max_key = 0
	for key in utils.Inventory.keys():
		if int(key) > max_key:
			max_key = int(key)
	if max_key >= 16-3:
		InvSize = int(ceil(float(max_key+1)/4)*4)
	else:
		InvSize = 16
	
	for n in InvSize:
		if !utils.Inventory.has(str(n)):
			utils.Inventory[str(n)] = null
	
	_destroy_inventory()
	if level == null:
		%CharacterMenu.visible = false
		return
	entity = level.control.entity_sel
	entity._update()
	$CharScrn/Status/List/characteristics/TURN/VEL.text = str(entity.VEL)
	$CharScrn/Status/List/characteristics/TURN/PAC.text = str(entity.RPA,"/",entity.LPA,"PA")
	$CharScrn/Status/List/characteristics/ACT/PRE.text = str(entity.PRE)
	$CharScrn/Status/List/characteristics/ACT/CRT.text = str(entity.MRG,"%x",entity.CRT)
	$CharScrn/Status/List/characteristics/DEF/REF.text = str(entity.REF)
	$CharScrn/Status/List/characteristics/DEF/AMPTEN.text = str("+",entity.AMP,"%/+",entity.TEN,"%")
	$CharScrn/Status/List/characteristics2/MOV/MOV.text = str(entity.MOV)
	$CharScrn/Status/List/characteristics2/MOV/FURPER.text = str("+",entity.FUR,"%/+",entity.PER,"%")
	$CharScrn/Status/List/characteristics2/ATQ/DAN.text = str(entity.DANV.x+entity.DAN,"-",entity.DANV.y+entity.DAN)
	$CharScrn/Status/List/characteristics2/ATQ/ALC.text = str(entity.ALC)
	
	$CharScrn/Status/List/attributes/MeshInstance2D.polygon[0] = Vector2(80-64*sin(0*2*PI/5)*entity.FIS/4,80-64*cos(0*2*PI/5)*entity.FIS/4)
	$CharScrn/Status/List/attributes/Line2D.points[0] = Vector2(80-64*sin(0*2*PI/5)*entity.FIS/4,80-64*cos(0*2*PI/5)*entity.FIS/4)
	$CharScrn/Status/List/attributes/MeshInstance2D.polygon[1] = Vector2(80-64*sin(1*2*PI/5)*entity.POD/4,80-64*cos(1*2*PI/5)*entity.POD/4)
	$CharScrn/Status/List/attributes/Line2D.points[1] = Vector2(80-64*sin(1*2*PI/5)*entity.POD/4,80-64*cos(1*2*PI/5)*entity.POD/4)
	$CharScrn/Status/List/attributes/MeshInstance2D.polygon[2] = Vector2(80-64*sin(2*2*PI/5)*entity.DES/4,80-64*cos(2*2*PI/5)*entity.DES/4)
	$CharScrn/Status/List/attributes/Line2D.points[2] = Vector2(80-64*sin(2*2*PI/5)*entity.DES/4,80-64*cos(2*2*PI/5)*entity.DES/4)
	$CharScrn/Status/List/attributes/MeshInstance2D.polygon[3] = Vector2(80-64*sin(3*2*PI/5)*entity.AST/4,80-64*cos(3*2*PI/5)*entity.AST/4)
	$CharScrn/Status/List/attributes/Line2D.points[3] = Vector2(80-64*sin(3*2*PI/5)*entity.AST/4,80-64*cos(3*2*PI/5)*entity.AST/4)
	$CharScrn/Status/List/attributes/MeshInstance2D.polygon[4] = Vector2(80-64*sin(4*2*PI/5)*entity.ESP/4,80-64*cos(4*2*PI/5)*entity.ESP/4)
	$CharScrn/Status/List/attributes/Line2D.points[4] = Vector2(80-64*sin(4*2*PI/5)*entity.ESP/4,80-64*cos(4*2*PI/5)*entity.ESP/4)
	_slot_update()
	%CharUI._update()

func _on_prev_char_pressed():
	var entity_list:Array
	for char in get_tree().get_nodes_in_group("entity"):
		entity_list.append(char)
	var sel = entity_list.find(entity)
	if sel - 1 < 0:
		sel = entity_list.size()-1
	else:
		sel -= 1
	entity = entity_list[sel]
	%Control.entity_sel = entity
	_update()
	%CharacterMenu._update()
	%CharUI._update()
	_despawn()
	#_spawn_inv($CharScrn/Inventory/Scroll/Grid)

func _on_next_char_pressed():
	var entity_list:Array
	for char in get_tree().get_nodes_in_group("entity"):
		entity_list.append(char)
	var sel = entity_list.find(entity)
	if sel + 1 > entity_list.size()-1:
		sel = 0
	else:
		sel += 1
	entity = entity_list[sel]
	%Control.entity_sel = entity
	_update()
	%CharacterMenu._update()
	%CharUI._update()
	_despawn()
	#_spawn_inv($CharScrn/Inventory/Scroll/Grid)

func _on_switch_button_up():
	inventory_up = !inventory_up
