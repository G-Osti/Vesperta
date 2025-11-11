extends Node3D

@onready var arrow: Sprite2D = $Sprite/SubViewport/Arrow
@onready var arrow_anim: AnimationPlayer = $Sprite/SubViewport/Arrow/AnimationPlayer

@onready var head: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Head
@onready var arms: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Arms
@onready var torso: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Torso
@onready var legs: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Legs
@onready var sleeves: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Sleeves
@onready var shirt: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Shirt
@onready var boots: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Boots
@onready var hair: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Hair
@onready var face: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Face
@onready var cape: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Cape
@onready var hat: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Hat
@onready var animation_player: AnimationPlayer = $Sprite/SubViewport/Avatar/Offset/AnimationPlayer
@onready var hand0: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Hand0
@onready var hand1: Sprite2D = $Sprite/SubViewport/Avatar/Offset/Hand1

#@onready var overlay = $Sprite/SubViewport/Overlay
#@onready var overlay_life = $Sprite/SubViewport/Overlay/Life/Bar
#@onready var overlay_life_penalty = $Sprite/SubViewport/Overlay/Life/Bar/Penalty
#@onready var overlay_energy = $Sprite/SubViewport/Overlay/Energy/Bar
#@onready var overlay_energy_penalty = $Sprite/SubViewport/Overlay/Energy/Bar/Penalty
#@onready var overlay_nametag = $Sprite/SubViewport/Overlay/Nametag/Value
var mouse_in_area = false
var mouse_in_coord = false
var mouse_in_entity = false

@export var char:Resource = null

@onready var portrait = load("res://assets/sprites/Entidades/Humanoide/Retratos/Default.png")
@onready var nome = "Default"
@onready var pvisual: Dictionary = {
}

@export var cell_coord:Vector3i = Vector3i(0,2,0):
	set(value):
		cell_coord = value

var k:int = 0
var path:PackedVector3Array = []
@onready var level = $"../.."
@onready var sprite = $Sprite
@export var team = 0
#@export var id = 0
@export var ai = false

#@onready var tween = create_tween()
var seen_cells:PackedVector3Array = []
var targets:PackedVector3Array = []
var movements:PackedVector3Array = []
var entities:PackedVector3Array = []

var orientation = Vector2i(0,1):
	get:
		return orientation
	set(value):
		if value != orientation:
			_animation_update()
		orientation = value
var new_orientation: Vector2i
var selected_action

@export var perks:Dictionary = {
	"Vantagem0"=null
}

@export var equips:Dictionary = {
	"Equipamento0"=null,
	"Equipamento1"=null,
	"Mecanismo"=null,
	"Acessório0"=null,
	"Acessório1"=null,
	"Acessório2"=null
}

@export var actions:Dictionary = {
	"Ação0"=null,
	"Ação1"=null,
	"Ação2"=null,
	"Ação3"=null,
	"Ação4"=null,
	"Ação5"=null,
	"Ação6"=null,
	"Ação7"=null,
	"Ação8"=null,
	"Ação9"=null
}

#@export var POD = 0
#@export var TEC = 0
#@export var AST = 0
#@export var VIG = 0

#Características Adicionais
#var PVa:int = 0
#var VELa:int = 0
#var CRTa:int = 0
#var DANa:Vector2i = Vector2i(0,0)
#var M_CRTa:float = 0
#var MOVa:int = 0
#var MOVVa:int = 0
#var PREa:float = 0
#var REFa:float = 0
#var AMa:int = 0 #Ameaça
#var ADa:Dictionary = { #Armadura
	#"geral" = 0,
	#"físico" = 0,
	#"calor" = 0,
	#"frio" = 0,
	#"miasma" = 0,
	#"raio" = 0,
	#"mental" = 0
#}
#var ALCa:int = 0
#var CBa:int = 0

#Características
var PVmax:int = 20:#50+4*VIG: #Pontos de Vida
	set(value):
		PV = int(floor(float(PV)/float(PVmax)*value))
		PVmax = value
		#overlay_life.max_value = value
		#overlay_life_penalty.max_value = value
var VEL:int = 20#20+AST #Velocidade
var CRT:int = 2#2*TEC #Aumento de Crítico
var DAN = Vector2i(1,4)#Vector2i(8+POD,14+POD) #Dano atual

#Características Gerais
var M_CRT:float = 1.5 #Multiplicador de Crítico
var PAmax:int = 4 #Pontos de Ação
var MOV:int = 4 #Movimentação por PA

#Características Derivadas
var PV:int = PVmax: #Pontos de Vida atuais
	set(value):
		PV = value
		#overlay_life.value = value
		if value <= 0:
			level.control._death(self)
var PVP:int = 0: #Penalidade de Pontos de Vida
	set(value):
		PVP = value
		#overlay_life_penalty.value = value
var PVA:int = 0: #Pontos de Vida Adicionais
	set(value):
		PVA = value
		#overlay_energy_penalty.value = value

var PA:int = PAmax #Pontos de Ação atuais
var PAP:int = 0 #Penalidade de Pontos de Ação

var MOVR:int = 0 #Movimentação livre (já paga)
var MOVV:int = 1 #Movimentação vertical

var PRE:float = 1.0 #Precisão atual
var REF:float = 1.0 #Reflexos atual

var ALC:int = 1 #Alcance de ação base
var CB:int = 2 #Custo de ação base

var AM:int = 0 #Ameaça
var AD:Dictionary = { #Armadura
	"geral" = 0,
	"físico" = 0,
	"calor" = 0,
	"frio" = 0,
	"miasma" = 0,
	"raio" = 0,
	"mental" = 0
}

var target_tile = []
var mov_tile = []
var turn:int = 0:
	set(value):
		turn = value
var state = "idle":
	set(value):
		if value != state:
			_animation_update()
		state = value
		#if state == "waiting":
			#arrow.visible = true
		#else:
			#arrow.visible = false
var post_state = "idle"
var n = 0

var rot = 0:
	set(value):
		if rot != value:
			_animation_update()
		rot = value
var forward = true

func _ready():
	#overlay_nametag.text = self.name
	self.position = Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
	_load_char()
	if team == 1:
		pass#arrow.set_modulate(Color(0,0,1,1))
	elif team == 2:
		ai = true
		pass#arrow.set_modulate(Color(1,0,0,1))
	elif team == 0:
		pass#arrow.visible = false
	#arrow_anim.play("Arrow",2.5)
	n = get_index()

func _process(_delta):
	rot = int(level.camera.rotation_degrees.y)%360
	#if level.control.sel_coord == cell_coord:
		#mouse_in_coord = true
	#else:
		#mouse_in_coord = false
	_mouse_in_entity()

func _animation_update():
	var norm_rot = rot
	if rot < 0:
		norm_rot = 360+rot%360
	else:
		norm_rot = rot%360
	if (norm_rot >= 0 and norm_rot < 45) or (norm_rot >= 315 and norm_rot <= 360):
		new_orientation = Vector2i(orientation.x,orientation.y)
	elif norm_rot >= 45 and norm_rot < 135:
		new_orientation = Vector2i(-orientation.y,orientation.x)
	elif norm_rot >= 135 and norm_rot < 225:
		new_orientation = Vector2i(-orientation.x,-orientation.y)
	elif norm_rot >= 225 and norm_rot < 315:
		new_orientation = Vector2i(orientation.y,-orientation.x)
	
	if state == "waiting":
		animation_player.speed_scale = 1
	if state == "moving":
		animation_player.speed_scale = 1.5
	
	if (new_orientation.x!=0 or new_orientation.y!=0) and not(new_orientation.x!=0 and new_orientation.y!=0):
		if new_orientation.x<0 or new_orientation.y<0:
			if state == "waiting" or "moving" and animation_player.current_animation != "Andar2":
				animation_player.current_animation = "Andar2"
				forward = false
		elif new_orientation.x>0 or new_orientation.y>0:
			if state == "waiting" or "moving" and animation_player.current_animation != "Andar1":
				animation_player.current_animation = "Andar1"
				forward = true
		if (new_orientation.x<0 or new_orientation.y>0):
			_flip(false)
		elif (new_orientation.x>0 or new_orientation.y<0):
			_flip(true)
	else:
		_flip(false)
		animation_player.current_animation = "Andar1"
	
	if state == "idle" and animation_player.is_playing():
		animation_player.stop()
	
	#if state == "positioning":
		#overlay.visible = true
	#else:
		#overlay.visible = false

func _flip(x:bool):
	$Sprite/Char.flip_h = x
	_load_visuals()
	#for Sprite in $Sprite/SubViewport/Avatar/Offset.get_children():
		#if Sprite is Sprite2D:
			#Sprite.flip_h = x

func _begin_movement():
	var tween = create_tween()
	if path.size() > 1 and k < path.size()-1:
		if MOVR == 0:
			_change_state()
		if MOVR > 0:
			MOVR -= 1
		var direction = Vector2i(round((path[k+1]-path[k]).x),round((path[k+1]-path[k]).z))
		orientation = Vector2i(direction.abs().max_axis_index()==0,direction.abs().max_axis_index()==1)*direction[direction.abs().max_axis_index()]/abs(direction[direction.abs().max_axis_index()])
		_animation_update()
		cell_coord = path[k+1]
		if path[k].y == path[k+1].y:
			tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),2/float(level.anim_vel))
			tween.tween_interval(0.25/float(level.anim_vel))
		else:
			tween.tween_property(self, "position", Vector3(path[k]+(Vector3(cell_coord)-path[k])/2)*Vector3(1,0.5,1)+Vector3(0.5,1.5,0.5),1/float(level.anim_vel*0.8333))
			tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),1/float(level.anim_vel*1.25))
			tween.tween_interval(0.25/float(level.anim_vel))
		tween.connect("finished", on_tween_finished)
	else:
		_change_state()

func on_tween_finished():
	_change_state()

func _change_state():
	#%Control._update()
	if state == "moving":
		k += 1
		if k+1 >= path.size():
			#if action <= 0:
				#_end_turn()
			#if action > 0:
			if post_state == "waiting":
				state = post_state
				_end_action()
			if post_state == "attack" or post_state == "support":
				state = post_state
				post_state = "waiting"
				if selected_action == null:
					_damage(target_tile)
				#selected_action._use_res(self)
		else:
			_begin_movement()
	elif state == "attack" or state == "support":
		state = post_state
		_end_action()
	else:
		_end_action()

func _end_action():
	state = "waiting"
	k = 0
	if path.size() > 0:
		position = Vector3(path[path.size()-1])*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
	level.action_in_progress = false
	#MOVL -= path.size()-1
	#level.control._prepare_action()
	level.environment._clear_movement()
	level.environment._get_movements(self)
	if ai == true:
		%Entities._get_ai_action(self)
	#_update()
	%Control._update()
	%UI._update()
	if PA > 0:
		level.environment._clear_movement()
		level.environment._get_movements(self)
		if ai == true:
			%Entities._get_ai_action(self)
	else:
		_end_turn()

func _end_turn():
	k = 0
	if path.size() > 0:
		position = Vector3(path[path.size()-1])*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
	level.action_in_progress = false
	level.environment._clear_movement()
	turn = turn - 100
	#for i in range(4):
		#turn = turn + randi_range(-16,16)
	state = "idle"
	level.control.state = "order"
	#_update()
	%Control._update()
	%UI._update()

#func _ranged_action():
	#post_state = "waiting"
	#PAA -= 2
	#PAV = PAA
	#_damage(target_tile)
	#_reorient(target_tile)
	#var tween = create_tween()
	#tween.tween_property(self, "position", Vector3(target_tile+(Vector3(cell_coord)-path[k])/2)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),1/float(level.anim_vel*0.8333))
	#tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),1/float(level.anim_vel*1.25))
	#tween.tween_interval(0.25/float(level.anim_vel))
	#tween.connect("finished", on_tween_finished)

func _damage(tile):
	var tween = create_tween()
	var sprite_3d = Sprite3D.new()
	sprite_3d.pixel_size = 0.0221*2
	sprite_3d.render_priority = 5
	sprite_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_3d.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite_3d.hframes = 8
	sprite_3d.visible = false
	level.add_child(sprite_3d)
	_reorient(tile)
	tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)+Vector3(cell_coord-tile).normalized()/2,1.6/float(level.anim_vel))
	tween.tween_interval(0.25/float(level.anim_vel))
	if animation_player.current_animation == "Andar2":
		animation_player.current_animation = "Ataque2"
	elif animation_player.current_animation == "Andar1":
		animation_player.current_animation = "Ataque1"
	animation_player.speed_scale = 1
	animation_player.play()
	sprite_3d.flip_h = !$Sprite/Char.flip_h
	if equips["Equipamento0"]:
		if equips["Equipamento0"].anim == "Perto":
			sprite_3d.position = Vector3(tile)*Vector3(1,0.5,1)+Vector3(0.5,0.8,0.5)
			tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)-Vector3(cell_coord-tile).normalized()/2,1.2/float(level.anim_vel))
			tween.tween_interval(0.2/float(level.anim_vel))
			sprite_3d.texture = load("res://assets/sprites/Efeitos/Slash.png")
			#sprite_3d.visible = true
			tween.tween_property(sprite_3d, 'visible', true,0.01)
			tween.tween_property(sprite_3d, 'frame', 8, 0.6/float(level.anim_vel))
		elif equips["Equipamento0"].anim == "Arco":
			sprite_3d.position = Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
			#sprite_3d.texture = load("res://assets/sprites/Efeitos/Slash.png")
			tween.tween_property(sprite_3d, 'position', Vector3(tile)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)-Vector3(cell_coord-tile), 0.5/float(level.anim_vel))
			tween.tween_property(sprite_3d, 'position', Vector3(tile)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5), 0.5/float(level.anim_vel))
			sprite_3d.position = Vector3(tile)*Vector3(1,0.5,1)+Vector3(0.5,0.8,0.5)
			sprite_3d.texture = load("res://assets/sprites/Efeitos/Slash.png")
			tween.tween_property(sprite_3d, 'visible', true,0.01)
			tween.tween_property(sprite_3d, 'frame', 8, 0.6/float(level.anim_vel))
		elif equips["Equipamento0"].anim == "Raio":
			sprite_3d.position = Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
			#sprite_3d.texture = load("res://assets/sprites/Efeitos/Slash.png")
			tween.tween_property(sprite_3d, 'position', Vector3(tile)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5), 1/float(level.anim_vel))
			sprite_3d.position = Vector3(tile)*Vector3(1,0.5,1)+Vector3(0.5,0.8,0.5)
			sprite_3d.texture = load("res://assets/sprites/Efeitos/Slash.png")
			tween.tween_property(sprite_3d, 'visible', true,0.01)
			tween.tween_property(sprite_3d, 'frame', 8, 0.6/float(level.anim_vel))
		#else:
			#sprite_3d.position = Vector3(tile)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
			#sprite_3d.hframes = 8
			#sprite_3d.texture = load("res://assets/sprites/Efeitos/Slash.png")
			#tween.tween_property(sprite_3d,"frame", 7, 1/float(level.anim_vel))
	else:
		tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)-Vector3(cell_coord-tile).normalized()/2,1.2/float(level.anim_vel))
	if equips["Equipamento1"]:
		if animation_player.current_animation == "Andar2":
			animation_player.current_animation = "Ataque2"
			animation_player.speed_scale = 1
			animation_player.play()
		elif animation_player.current_animation == "Andar1":
			animation_player.current_animation = "Ataque1"
			animation_player.speed_scale = 1
			animation_player.play()
		if equips["Equipamento0"].anim == "Arco":
			sprite_3d.position = Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
			tween.tween_property(sprite_3d, 'position', Vector3(tile)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5), 1/float(level.anim_vel))
		else:
			tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),1/float(level.anim_vel))
			tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)-Vector3(cell_coord-tile).normalized()/2,1/float(level.anim_vel))
	
		#print("AAAAAAAAAAAA")
	#await animation_player.animation_finished
	print("1")
	#tween.tween_interval(0.8/float(level.anim_vel))
	#await tween.finished
	print("2")
	tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),1.2/float(level.anim_vel))
	print("3")
	#tween.tween_interval(0.25/float(level.anim_vel))
	await tween.finished
	sprite_3d.queue_free()
	print("4")
	var target = []
	for entity in get_tree().get_nodes_in_group("entity"):
		if entity.cell_coord == tile:
			target.append(entity)
	for entity in target:
		var REFE = 0
		#if Vector2(position.x,position.z) == Vector2(entity.position.x,entity.position.z)+Vector2(entity.orientation.x,entity.orientation.y):
		REFE = entity.REF
		#else:
			#REFE = entity.REF/2
		var rng = randi_range(1,100)
		print(rng,">",min(100*((1-REFE)+(1-PRE)),0.95))
		if rng > min(100*((1-REFE)+(1-PRE)),0.95):
			print("HIT!")
			entity._damaged(DAN)
		else:
			print("MISS!")
			pass
		#entity._update()
	_end_action()

func _reorient(target_pos):
	var direction = Vector2i((target_pos-self.cell_coord).x,(target_pos-self.cell_coord).z)
	orientation = Vector2i(direction.abs().max_axis_index()==0,direction.abs().max_axis_index()==1)*direction[direction.abs().max_axis_index()]/abs(direction[direction.abs().max_axis_index()])
	_animation_update()

func _damaged(DANE:Vector2i):
	var DN = randi_range(DANE.x,DANE.y)
	print(PV," - ",DN," = ")
	PV -= DN
	print(PV)

func _movement_action(tile:Vector3i):
	level.action_in_progress = true
	state = "moving"
	_animation_update()
	var target = "none"
	for entity in self.get_parent().get_children():
		if entity.cell_coord == tile:
			if entity.team == self.team:
				target = "ally"
			if entity.team == 0:
				target = "object"
			else:
				target = "enemy"
	if target == "none":
		post_state = "waiting"
		mov_tile = tile
	if target == "ally":
		post_state = "support"
		mov_tile = level.environment._get_closest_tile(self,tile)
		target_tile = tile
	if target == "enemy":
		post_state = "attack"
		mov_tile = level.environment._get_closest_tile(self,tile)
		target_tile = tile
	if target == "object":
		post_state = "attack"
		mov_tile = level.environment._get_closest_tile(self,tile)
		target_tile = tile
	
	path = level.environment._get_path(self,mov_tile)
	level.environment._clear_movement()
	_begin_movement()

func _begin_turn():
	#if PAV + RPA <= LPA:
		#PAA = PAV + RPA
	#else:
		#PAA = LPA
	#print("Turn Begun! ",PAV,"/",LPA," -> ",PAA,"/",LPA)
	PA = PAmax
	MOVR = MOV
	#_update()
	level.environment._clear_movement()
	level.environment._get_movements(self)
	if ai == true:
		%Entities._get_ai_action(self)

func _update():
	#overlay_nametag.text = self.name
	print("updating: ", self.name)
	_load_char()
	self.position = Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
	#resistence = 0
	
	#if equips["Equipamento"] != null:
		#DANV = equips["Equipamento"].DANV
	#else:
		#DANV = Vector2i(1,4)
	
	#Atributos Extra
	var PVE:int = 0 #Pontos de Vida Extra
	var VELE:int = 0 #Velocidade Extra
	var CRTE:int = 0 #Aumento de Crítico Extra
	var DANE = Vector2i(0,0)
	var M_CRTE:float = 0 #Multiplicador de Crítico Extra
	var MOVE:int = 0 #Movimentação Extra
	var AME:int = 0 #Ameaça Extra
	var ADE:Dictionary = { #Armadura Extra
		"geral" = 0,
		"físico" = 0,
		"calor" = 0,
		"frio" = 0,
		"miasma" = 0,
		"raio" = 0,
		"mental" = 0
	}
	var PREE:int = 0
	var REFE:int = 0
	var ALCE:int = 0
	var CBE:int = 0
	#for key in actions.keys():
		#actions[key]=null
	#for key in perks.keys():
		#perks[key]=null
	for item in equips.keys():
		if equips[item] != null:
			PVE += equips[item].PV
			VELE += equips[item].VEL
			CRTE += equips[item].CRT
			DANE += equips[item].DAN
			M_CRTE += equips[item].M_CRT
			MOVE += equips[item].MOV
			AME += equips[item].AM
			ADE["geral"] += equips[item].AD["geral"]
			ADE["físico"] += equips[item].AD["físico"]
			ADE["calor"] += equips[item].AD["calor"]
			ADE["frio"] += equips[item].AD["frio"]
			ADE["miasma"] += equips[item].AD["miasma"]
			ADE["raio"] += equips[item].AD["raio"]
			ADE["mental"] += equips[item].AD["mental"]
			PREE += equips[item].PRE
			REFE += equips[item].REF
			ALCE += equips[item].ALC
			CBE += equips[item].CB
			#for key in equips[item].perks.keys():
				#if equips[item].perks.has(key) and perks[key]!=null and equips[item].perks[key]!=null:
					#perks[key] = equips[item].perks[key]
	for item in perks.keys():
		if perks[item] != null:
			PVE += perks[item].PV
			VELE += perks[item].VEL
			CRTE += perks[item].CRT
			DANE += perks[item].DAN
			M_CRTE += perks[item].M_CRT
			MOVE += perks[item].MOV
			AME += perks[item].AM
			ADE["geral"] += perks[item].AD["geral"]
			ADE["físico"] += perks[item].AD["físico"]
			ADE["calor"] += perks[item].AD["calor"]
			ADE["frio"] += perks[item].AD["frio"]
			ADE["miasma"] += perks[item].AD["miasma"]
			ADE["raio"] += perks[item].AD["raio"]
			ADE["mental"] += perks[item].AD["mental"]
			PREE += perks[item].PRE
			REFE += perks[item].REF
			ALCE += perks[item].ALC
			CBE += perks[item].CB
	PVmax = 20+PVE#50+4*VIG+PVE #Pontos de Vida
	VEL = 20+VELE#20+AST+VELE #Velocidade
	CRT = 2+CRTE#2*TEC+CRTE #Aumento de Crítico
	DAN = Vector2i(1,4)+DANE#Vector2i(8+POD,14+POD)+DANE #Dano atual
	M_CRT = 1.5+M_CRTE #Multiplicador de Crítico
	MOV = 4+MOVE #Movimentação
	PRE = 1.0+PREE #Precisão atual
	REF = 1.0+REFE #Reflexos atual
	ALC = 1+ALCE #Alcance de ação base
	CB = 2+CBE #Custo de ação base
	AM = AME #Ameaça
	AD["geral"] = ADE["geral"]
	AD["físico"] = ADE["físico"]
	AD["calor"] = ADE["calor"]
	AD["frio"] = ADE["frio"]
	AD["miasma"] = ADE["miasma"]
	AD["raio"] = ADE["raio"]
	AD["mental"] = ADE["mental"]
	
	#PV = 16+8*FIS + PVE
	#PE = 16+8*POD + PEE
	#VEL = 10+0.5*ESP + VELE
	#RPA = 4 + RPAE
	#LPA = 6 + LPAE
	#PRE = 0+3*DES+2*AST + PREE
	#MRG = 0+2.5*AST + MRGE
	#CRT = 1.5 + CRTE
	#REF = 0+3*DES+2*ESP + REFE
	#TEN = 0+5*FIS + TENE
	#MOV = 4 + MOVE
	#FUR = 0+5*DES + FURE
	#PER = 0+5*ESP + PERE
	#DAN = 0 + POD + DANE
	#AMP = 0+5*AST + AMPE
	#ALC = 1 + ALCE
	
	#if state == "waiting":
		#level.environment._clear_movement()
		#level.environment._get_movements(self)
	seen_cells.clear()
	seen_cells = %Control._get_fov_raycast(self.position+Vector3(0,1,0))
	_animation_update()

#func _setup():
	#_load_char()
	#_update()
	#PV = PVmax

func _load_visuals():
#	arrow.texture.set_path(pvisual["arrow.texture"])
	#arrow.modulate = pvisual["arrow.modulate"]
	#var SpriteColor = 
	for subsprite in [head,arms,torso,legs,sleeves,shirt,boots,hair,face,hat]:
		subsprite.set_texture(load(pvisual[str(subsprite.name).to_lower()+".texture"]))
		var SpriteColor = ShaderMaterial.new()
		SpriteColor.shader = preload("res://assets/cenas/SpriteColor.gdshader")
		subsprite.material = SpriteColor
		subsprite.material.set_shader_parameter("C",pvisual[str(subsprite.name).to_lower()+".modulate"])
	#head.set_texture(load(pvisual["head.texture"]))
	#head.material.duplicate(true)
	#head.material.set_shader_parameter("C",pvisual["head.modulate"])
	#print(head.material.get_shader_parameter("C"))
	#arms.set_texture(load(pvisual["arms.texture"]))
	#arms.material.set_shader_parameter("shader_parameter/C",pvisual["arms.modulate"])
	#torso.set_texture(load(pvisual["torso.texture"]))
	#torso.material.set_shader_parameter("shader_parameter/C",pvisual["torso.modulate"])
	#legs.set_texture(load(pvisual["legs.texture"]))
	#legs.material.set_shader_parameter("shader_parameter/C",pvisual["legs.modulate"])
	#sleeves.set_texture(load(pvisual["sleeves.texture"]))
	#sleeves.material.set_shader_parameter("shader_parameter/C",pvisual["sleeves.modulate"])
	#shirt.set_texture(load(pvisual["shirt.texture"]))
	#shirt.material.set_shader_parameter("shader_parameter/C",pvisual["shirt.modulate"])
	#boots.set_texture(load(pvisual["boots.texture"]))
	#boots.material.set_shader_parameter("shader_parameter/C",pvisual["boots.modulate"])
	#hair.set_texture(load(pvisual["hair.texture"]))
	#hair.material.set_shader_parameter("shader_parameter/C",pvisual["hair.modulate"])
	#face.set_texture(load(pvisual["face.texture"]))
	#face.material.set_shader_parameter("shader_parameter/C",pvisual["face.modulate"])
	#hat.set_texture(load(pvisual["hat.texture"]))
	#hat.material.set_shader_parameter("shader_parameter/C",pvisual["hat.modulate"])
	
	var sprite_node = [hand0,hand1]
	if ($Sprite/Char.flip_h or !forward) and !($Sprite/Char.flip_h and !forward):
		sprite_node = [hand1,hand0]
	if equips["Equipamento0"] != null:
		sprite_node[0].set_texture(load(equips["Equipamento0"].icon.resource_path))
		var SpriteColor = ShaderMaterial.new()
		SpriteColor.shader = preload("res://assets/cenas/SpriteColor.gdshader")
		sprite_node[0].material = SpriteColor
		sprite_node[0].material.set_shader_parameter("C",equips["Equipamento0"].color)
	else:
		sprite_node[0].set_texture(null)
	if equips["Equipamento1"] != null:
		sprite_node[1].set_texture(load(equips["Equipamento1"].icon.resource_path))
		var SpriteColor = ShaderMaterial.new()
		SpriteColor.shader = preload("res://assets/cenas/SpriteColor.gdshader")
		sprite_node[1].material = SpriteColor
		sprite_node[1].material.set_shader_parameter("C",equips["Equipamento1"].color)
	else:
		sprite_node[1].set_texture(null)
	var SpriteColor = ShaderMaterial.new()
	SpriteColor.shader = preload("res://assets/cenas/Aura.gdshader")
	$Sprite/SubViewport/Sprite2D.material = SpriteColor
	if get_parent().entity_turn:
		if get_parent().entity_turn == self:
			$Sprite/SubViewport/Sprite2D.material.set_shader_parameter("color",Color(0,0.7,1,1))
		else:
			if team == 0:
				$Sprite/SubViewport/Sprite2D.material.set_shader_parameter("color",Color(0.1,0.1,0,1))
			elif team == get_parent().entity_turn.team:
				$Sprite/SubViewport/Sprite2D.material.set_shader_parameter("color",Color(0.05,1,0.05,1))
			elif team != get_parent().entity_turn.team:
				$Sprite/SubViewport/Sprite2D.material.set_shader_parameter("color",Color(1,0.05,0.05,1))
	#print($Sprite/SubViewport/Sprite2D.material.get_shader_parameter("color"))

func _save_visuals():
	pvisual["arrow.texture"] = arrow.texture.get_path()
	pvisual["arrow.modulate"] = arrow.modulate
	pvisual["head.texture"] = head.texture.get_path()
	pvisual["head.modulate"] = head.modulate
	pvisual["arms.texture"] = arms.texture.get_path()
	pvisual["arms.modulate"] = arms.modulate
	pvisual["torso.texture"] = torso.texture.get_path()
	pvisual["torso.modulate"] = torso.modulate
	pvisual["legs.texture"] = legs.texture.get_path()
	pvisual["legs.modulate"] = legs.modulate
	pvisual["sleeves.texture"] = sleeves.texture.get_path()
	pvisual["sleeves.modulate"] = sleeves.modulate
	pvisual["shirt.texture"] = shirt.texture.get_path()
	pvisual["shirt.modulate"] = shirt.modulate
	pvisual["boots.texture"] = boots.texture.get_path()
	pvisual["boots.modulate"] = boots.modulate
	pvisual["hair.texture"] = hair.texture.get_path()
	pvisual["hair.modulate"] = hair.modulate
	pvisual["face.texture"] = face.texture.get_path()
	pvisual["face.modulate"] = face.modulate
	pvisual["cape.texture"] = cape.texture.get_path()
	pvisual["cape.modulate"] = cape.modulate
	pvisual["hat.texture"] = hat.texture.get_path()
	pvisual["hat.modulate"] = hat.modulate
	#equips["Equipamento0"].texture = hand_0.texture.get_path()
	#equips["Equipamento1"].texture = hand_1.texture.get_path()

func _load_char():
	var i = 0
	for Prop in char.get_property_list():
		if Prop.name in self and i>=9:
			#print(Prop.name)
			self.set(Prop.name,char.get(Prop.name))
		i += 1
	_load_visuals()

func _on_area_3d_mouse_entered():
	mouse_in_area = true

func _on_area_3d_mouse_exited():
	mouse_in_area = false

func _mouse_in_entity():
	if mouse_in_area == true or mouse_in_coord == true:
		mouse_in_entity = true
		$Sprite/SubViewport/Sprite2D.material.set_shader_parameter("width",1)
	else:
		mouse_in_entity = false
		$Sprite/SubViewport/Sprite2D.material.set_shader_parameter("width",0)
