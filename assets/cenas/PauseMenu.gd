extends Control
@onready var level = $"../.."

func _process(_delta):
	if level.state == "occupied":
		$TextureRect/Salvar.set_modulate(Color(0.6,0.6,0.6))
	else:
		$TextureRect/Salvar.set_modulate(Color(1,1,1))

func _on_sair_pressed():
	get_tree().quit()

func _on_salvar_button_up():
	#if level.state != "occupied":
	utils.save_game()

func _on_carregar_button_up():
	utils.load_game()

func _on_resumir_button_up():
	level._menu_input(self)
