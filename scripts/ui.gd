extends CanvasLayer

@onready var level = $".."
var turn_indicator: PackedScene = preload("res://assets/cenas/entity_turn.tscn")
var entities_turns:Array# = [$Ordering/EntityTurn]
var sel_indicator: PackedScene = preload("res://assets/cenas/entity_sel.tscn")
var entities_sels:Array# = [$Ordering/EntityTurn]

var fentity:Node3D = null

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fentity = null
	for entity in get_tree().get_nodes_in_group("entity"):
		if %Control.sel_coord == entity.cell_coord:
			fentity = entity
	if fentity != null:
		$Selector.visible = true
		$Selector/Placa/Label.text = fentity.nome
		$Selector/Placa/Vida.value = int(128*float(fentity.PV)/float(fentity.PVmax))
		if fentity.team == 1:
			$Selector/Placa/Label.add_theme_color_override("font_color", Color("ffffff"))
		if fentity.team != 1:
			$Selector/Placa/Label.add_theme_color_override("font_color", Color("ff3838"))
	else:
		$Selector.visible = false

func _update():
	%Turns.visible = false
	%Select.visible = false
	if level.phase == "battle":
		%Turns.visible = true
		var turns_list:Array
		for turn in %Turns.get_children():
			turn._update()
			turns_list.append(turn.entity.turn)
		var k = 1
		for number in turns_list:
			%Turns.get_child(turns_list.find(turns_list.max())).order = k
			k += 1
			turns_list[(turns_list.find(turns_list.max()))]=-INF
	else:
		%Select.visible = true
		for sel in %Select.get_children():
			sel._update()
	$InferiorMenu/Placa/Label.text = %Control.entity_turn.nome
	$InferiorMenu/Placa/Acao.value = %Control.entity_turn.PA
	$InferiorMenu/Placa/Vida.value = int(128*float(%Control.entity_turn.PV)/float(%Control.entity_turn.PVmax))

func _create_turns():
	#print("creating turns")
	for turn in %Turns.get_children():
		turn.queue_free()
	var k = 1
	for entity in get_tree().get_nodes_in_group("entity"):
		#print(entity)
		var instance = turn_indicator.instantiate()
		entities_turns.append(instance)
		%Turns.add_child(instance)
		instance.entity = entity
		instance.order = k
		instance.name = "Turn"+str(k)
		k += 1
		instance._update()
	#print("done!")

func _create_sels():
	#print("creating selections")
	for sels in %Select.get_children():
		sels.queue_free()
	var k = 1
	for entity in get_tree().get_nodes_in_group("entity"):
		#print(entity)
		var instance = sel_indicator.instantiate()
		entities_sels.append(instance)
		%Select.add_child(instance)
		instance.entity = entity
		instance.order = k
		instance.name = "Sel"+str(k)
		k += 1
		instance._update()
	#print("done!")

func _on_sair_pressed():
	get_tree().quit()

func _on_salvar_button_up():
	#if level.state != "occupied":
	utils.save_game()

func _on_carregar_button_up():
	utils.load_game()

func _on_resumir_button_up():
	level._menu_input(self)



func _on_pause_menu_visibility_changed() -> void:
	if %PauseMenu.visible == true:
		if level.state == "occupied":
			$PauseMenu/PauseBack/Salvar.set_modulate(Color(0.6,0.6,0.6))
		else:
			$PauseMenu/PauseBack/Salvar.set_modulate(Color(1,1,1))


func _on_menu_button_up() -> void:
	pass # Replace with function body.


func _on_configurações_button_up() -> void:
	pass # Replace with function body.


#Inferior UI
func _on_correr_button_up() -> void:
	pass # Replace with function body.


func _on_esgueirar_button_up() -> void:
	pass # Replace with function body.


func _on_inv_button_up() -> void:
	pass # Replace with function body.


func _on_end_turn_button_up() -> void:
	if %Control.entity_turn.team == 1:
		%Control.entity_turn._end_turn()


func _on_key_1_button_up() -> void:
	pass # Replace with function body.


func _on_key_2_button_up() -> void:
	pass # Replace with function body.


func _on_key_3_button_up() -> void:
	pass # Replace with function body.


func _on_key_4_button_up() -> void:
	pass # Replace with function body.


func _on_key_5_button_up() -> void:
	pass # Replace with function body.


func _on_key_6_button_up() -> void:
	pass # Replace with function body.


func _on_key_7_button_up() -> void:
	pass # Replace with function body.


func _on_key_8_button_up() -> void:
	pass # Replace with function body.


func _on_key_9_button_up() -> void:
	pass # Replace with function body.


func _on_key_0_button_up() -> void:
	pass # Replace with function body.

#Detecção de mouse
#Interface Inferior
func _on_inferior_menu_mouse_entered() -> void:
	level.mouse_in_interface = true

func _on_inferior_menu_mouse_exited() -> void:
	level.mouse_in_interface = false


#Funções Extras
func _on_items_mouse_entered() -> void:
	level.mouse_in_interface = true

func _on_items_mouse_exited() -> void:
	level.mouse_in_interface = false

func _on_movimentos_mouse_entered() -> void:
	level.mouse_in_interface = true

func _on_movimentos_mouse_exited() -> void:
	level.mouse_in_interface = false

#Seletor
func _on_selector_mouse_entered() -> void:
	level.mouse_in_interface = true

func _on_selector_mouse_exited() -> void:
	level.mouse_in_interface = false
