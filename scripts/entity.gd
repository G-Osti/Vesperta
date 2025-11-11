extends Node3D

@onready var arrow = $Sprite/SubViewport/Arrow
@onready var head = $Sprite/SubViewport/Avatar/Head
@onready var arms = $Sprite/SubViewport/Avatar/Arms
@onready var torso = $Sprite/SubViewport/Avatar/Torso
@onready var legs = $Sprite/SubViewport/Avatar/Legs
@onready var sleeves = $Sprite/SubViewport/Avatar/Sleeves
@onready var shirt = $Sprite/SubViewport/Avatar/Shirt
@onready var boots = $Sprite/SubViewport/Avatar/Boots
@onready var hair = $Sprite/SubViewport/Avatar/Hair
@onready var face = $Sprite/SubViewport/Avatar/Face
@onready var cape = $Sprite/SubViewport/Avatar/Cape
@onready var hat = $Sprite/SubViewport/Avatar/Hat
@onready var arrow_anim = $Sprite/SubViewport/Arrow/AnimationPlayer
@onready var animation_player = $Sprite/SubViewport/Avatar/AnimationPlayer

@onready var overlay = $Sprite/SubViewport/Overlay
@onready var overlay_life = $Sprite/SubViewport/Overlay/Life/Bar
@onready var overlay_life_penalty = $Sprite/SubViewport/Overlay/Life/Bar/Penalty
@onready var overlay_energy = $Sprite/SubViewport/Overlay/Energy/Bar
@onready var overlay_energy_penalty = $Sprite/SubViewport/Overlay/Energy/Bar/Penalty
@onready var overlay_nametag = $Sprite/SubViewport/Overlay/Nametag/Value
var mouse_in_area = false
var mouse_in_coord = false
var mouse_in_entity = false

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
	"Raça"=null,
	"Vantagem1"=null
}

@export var equips:Dictionary = {
	"Equipamento"=null,
	"Armadura"=null,
	"Acessório0"=null,
	"Acessório1"=null,
	"Acessório2"=null,
	"Classe"=null,
	"Suporte"=null,
	"Extra"=null
}

@export var equipment_types:PackedStringArray

@export var skills:Dictionary = {
	"Ação Padrão"=null,
	"Habilidade1"=null,
	"Habilidade2"=null,
	"Habilidade3"=null,
	"Habilidade4"=null,
	"HabilidadeE"=null
}

@export var unlocked_classes:Dictionary

@export var unlocked_skills:Dictionary

@export var POD = 2
@export var AGI = 2
@export var VIG = 2
@export var PSI = 2
@export var DES = 2

#Características Base
var PV:float = 24+4*VIG: #Pontos de Vida
	set(value):
		PV = value
		overlay_life.max_value = value
		overlay_life_penalty.max_value = value
var PT:float = POD #Potência
var PE:float = 16+8*PSI: #Pontos de Escudo
	set(value):
		PE = value
		overlay_energy.max_value = value
		overlay_energy_penalty.value = value
var VEL:float = 10+AGI #Velocidade
var CRT:float = 2*DES #Aumento de Crítico

#Características de Teste
var PRE:float = 5*DES #Precisão
var EVA:float = 5*AGI #Evasão
var AMP:float = 5*POD #Amplitude
var RES:float = 5*VIG #Resistência
var AST:float = 5*PSI #Astúcia

#Características Gerais
var M_CRT:float = 1.5 #Multiplicador de Crítico
var PA:int = 4 #Pontos de Ação
var MOV:int = 4 #Movimentação
var AM:int = 0 #Ameaça
var AD:Dictionary = { #Armadura
	geral = 0,
	"físico" = 0,
	"calor" = 0,
	"frio" = 0,
	"miasma" = 0,
	"raio" = 0,
	"mental" = 0
}

#Características Derivadas
var PVA = PV: #Pontos de Vida atuais
	set(value):
		PVA = value
		overlay_life.value = value
		if value <= 0:
			level.control._death(self)
var PVP = 0: #Penalidade de Pontos de Vida
	set(value):
		PVP = value
		overlay_life_penalty.value = value

var DANO = PT #Dano atual

var PEA = PE: #Pontos de Escudo atuais
	set(value):
		PEA = value
		overlay_energy.value = value
var PEP = 0: #Penalidade de Pontos de Escudo
	set(value):
		PEP = value
		overlay_energy_penalty.value = value

var PAA:int = PA #Pontos de Ação atuais
var PAL:int = 6 #Pontos de Ação limite
var PPA:int = 0 #Penalidade de Pontos de Ação
var PAV:int = 0 #Pontos de Ação anteriores

var MOVR = MOV #Movimentação restante
var MOVV = 2 #Movimentação vertical

var target_tile = []
var mov_tile = []
var turn = 0:
	set(value):
		turn = value
var placed = false
var state = "idle":
	set(value):
		if value != state:
			_animation_update()
		state = value
		if state == "waiting" or state == "positioning" or state == "positioned":
			arrow.visible = true
		else:
			arrow.visible = false
var post_state = "idle"
var n = 0

var rot = 0:
	set(value):
		if rot != value:
			_animation_update()
		rot = value

func _ready():
	overlay_nametag.text = self.name
	self.position = Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
	if team == 1:
		arrow.set_modulate(Color(1,0,0,1))
	elif team == 2:
		ai = true
		arrow.set_modulate(Color(0,0,1,1))
	elif team == 0:
		arrow.visible = false
	arrow_anim.play("Arrow",2.5)
	n = get_index()

func _process(_delta):
	rot = int(level.camera.rotation_degrees.y)%360
	if level.control.sel_coord == cell_coord:
		mouse_in_coord = true
	else:
		mouse_in_coord = false
	_mouse_in_entity()

func _animation_update():
	var norm_rot = rot
	#if rot < 0:
		#norm_rot = 360+rot%360
	#else:
		#norm_rot = rot%360
	#if (norm_rot >= 0 and norm_rot < 45) or (norm_rot >= 315 and norm_rot <= 360):
		#new_orientation = Vector2i(orientation.x,orientation.y)
	#elif norm_rot >= 45 and norm_rot < 135:
		#new_orientation = Vector2i(-orientation.y,orientation.x)
	#elif norm_rot >= 135 and norm_rot < 225:
		#new_orientation = Vector2i(-orientation.x,-orientation.y)
	#elif norm_rot >= 225 and norm_rot < 315:
		#new_orientation = Vector2i(orientation.y,-orientation.x)
		#
	#if (new_orientation.x!=0 or new_orientation.y!=0) and not(new_orientation.x!=0 and new_orientation.y!=0):
		#if new_orientation.x<0 or new_orientation.y<0 and animation_player.current_animation != "Andar2":
			#animation_player.current_animation = "Andar2"
		#elif new_orientation.x>0 or new_orientation.y>0 and animation_player.current_animation != "Andar1":
			#animation_player.current_animation = "Andar1"
		#if (new_orientation.x<0 or new_orientation.y>0):
			#_flip(false)
		#elif (new_orientation.x>0 or new_orientation.y<0):
			#_flip(true)
	#else:
		#_flip(false)
		#animation_player.current_animation = "Andar1"
	#if state == "waiting" or state == "positioning" or state == "positioned":
		#animation_player.speed_scale = 1
	#if state == "moving":
		#animation_player.speed_scale = 1.5
	#
	#if state != "waiting" and state != "moving" and state != "positioning" and state != "positioned":
		#animation_player.stop()
	#else:
		#animation_player.play()
	#if state == "positioning":
		#overlay.visible = true
	#else:
		#overlay.visible = false

func _flip(x:bool):
	for Sprite in $Sprite/SubViewport/Avatar.get_children():
		if Sprite is Sprite2D:
			Sprite.flip_h = x

func _begin_movement():
	var tween = create_tween()
	if path.size() > 1 and k < path.size()-1:
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
				selected_action._use_res(self)
		else:
			_begin_movement()
	elif state == "attack" or state == "support":
		state = post_state
		_end_action()

func _end_action():
	state = "waiting"
	k = 0
	if path.size() > 0:
		position = Vector3(path[path.size()-1])*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
	level.action_in_progress = false
	MOVR -= path.size()-1
	#level.control._prepare_action()
	level.environment._clear_movement()
	level.environment._get_movements(self)
	if ai == true:
		%Entities._get_ai_action(self)
	#_update()
	#level.control._update()
	#level.char_ui._update()
	#level.turns._update()
	#level._update()

func _end_turn():
	k = 0
	if path.size() > 0:
		position = Vector3(path[path.size()-1])*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
	level.action_in_progress = false
	level.environment._clear_movement()
	turn = turn - 100
	for i in range(4):
		turn = turn + randi_range(-16,16)
	state = "idle"
	level.control.state = "order"
	_update()
	level.control._update()
	level.char_ui._update()
	level.turns._update()

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
	var target = []
	for entity in level.entities.get_children():
		if entity.cell_coord == tile:
			target.append(entity)
	for entity in target:
		var REFE = 0
		#if Vector2(position.x,position.z) == Vector2(entity.position.x,entity.position.z)+Vector2(entity.orientation.x,entity.orientation.y):
		REFE = entity.REF
		#else:
			#REFE = entity.REF/2
		var rng = randi_range(1,100)
		print(rng,"/",100*REFE/(REFE+PRE))
		if rng > 100*REFE/(REFE+PRE):
			print("HIT!")
			#entity._damaged(DANV,DAN,PRE)
		else:
			print("MISS!")
			pass
		entity._update()

func _reorient(target_pos):
	var direction = Vector2i((target_pos-self.cell_coord).x,(target_pos-self.cell_coord).z)
	orientation = Vector2i(direction.abs().max_axis_index()==0,direction.abs().max_axis_index()==1)*direction[direction.abs().max_axis_index()]/abs(direction[direction.abs().max_axis_index()])
	_animation_update()

func _damaged(DANVE:Vector2i,DANE,PENE):
	var DN = randi_range(DANVE.x+DANE,DANVE.y+DANE)
	if PEA > 0:
		if PENE > 0:
			PEA -= DN*(1-PENE)
			PVA -= DN*PENE
		else:
			PEA -= DN
	else:
		PVA -= DN

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
	PAV = PAA
	MOVR = MOV
	_update()
	level.environment._get_movements(self)
	if ai == true:
		%Entities._get_ai_action(self)

func _update():
	overlay_nametag.text = self.name
	self.position = Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
	#resistence = 0
	
	#if equips["Equipamento"] != null:
		#DANV = equips["Equipamento"].DANV
	#else:
		#DANV = Vector2i(1,4)
	
	var PVE:float = 0
	var PEE:float = 0
	var VELE:float = 0
	var RPAE:float = 0
	var LPAE:float = 0
	var PREE:float = 0
	var MRGE:float = 0
	var CRTE:float = 0
	var REFE:float = 0
	var TENE:float = 0
	var MOVE:float = 0
	var FURE:float = 0
	var PERE:float = 0
	var DANE:int = 0
	var AMPE:float = 0
	var ALCE:int = 0
	for key in skills.keys():
		skills[key]=null
	equipment_types.clear()
	for item in equips.keys():
		if equips[item] != null:
			PVE += equips[item].PVE
			PEE += equips[item].PEE
			VELE += equips[item].VELE
			RPAE += equips[item].RPAE
			LPAE += equips[item].LPAE
			PREE += equips[item].PREE
			MRGE += equips[item].MRGE
			CRTE += equips[item].CRTE
			REFE += equips[item].REFE
			TENE += equips[item].TENE
			MOVE += equips[item].MOVE
			FURE += equips[item].FURE
			PERE += equips[item].PERE
			DANE += equips[item].DANE
			AMPE += equips[item].AMPE
			ALCE += equips[item].ALCE
			for key in equips[item].perks.keys():
				if equips[item].perks.has(key) and perks[key]!=null and equips[item].perks[key]!=null:
					perks[key] = equips[item].perks[key]
			if item == "Classe":
				for key in skills.keys():
					if equips[item].skills.has(key) and equips[item].skills[key]!=null:
						skills[key] = equips[item].skills[key]
			if item == "Classe" or item == "Suporte":
				if equipment_types.size() > 0:
					for type in equipment_types.size():
						equipment_types.append(equips[item].equipment_types[type])
			if item == "Extra":
				skills["HabilidadeE"] = equips[item]
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
	
	_load_visuals()
	
	if state == "waiting":
		level.environment._clear_movement()
		level.environment._get_movements(self)
	seen_cells.clear()
	seen_cells = level.control._get_fov_raycast(self.position+Vector3(0,1.2,0))
	_animation_update()

func _setup():
	_update()
	PVA = PV
	PEA = PE

func _load_visuals():
	#arrow.texture.set_atlas(pvisual["arrow.texture"])
	arrow.modulate = pvisual["arrow.modulate"]
	head.set_texture(load(pvisual["head.texture"]))
	head.modulate = pvisual["head.modulate"]
	arms.set_texture(load(pvisual["arms.texture"]))
	arms.modulate = pvisual["arms.modulate"]
	torso.set_texture(load(pvisual["torso.texture"]))
	torso.modulate = pvisual["torso.modulate"]
	legs.set_texture(load(pvisual["legs.texture"]))
	legs.modulate = pvisual["legs.modulate"]
	sleeves.set_texture(load(pvisual["sleeves.texture"]))
	sleeves.modulate = pvisual["sleeves.modulate"]
	shirt.set_texture(load(pvisual["shirt.texture"]))
	shirt.modulate = pvisual["shirt.modulate"]
	boots.set_texture(load(pvisual["boots.texture"]))
	boots.modulate = pvisual["boots.modulate"]
	hair.set_texture(load(pvisual["hair.texture"]))
	hair.modulate = pvisual["hair.modulate"]
	face.set_texture(load(pvisual["face.texture"]))
	face.modulate = pvisual["face.modulate"]
	cape.set_texture(load(pvisual["cape.texture"]))
	cape.modulate = pvisual["cape.modulate"]
	hat.set_texture(load(pvisual["hat.texture"]))
	hat.modulate = pvisual["hat.modulate"]

func _save_visuals():
	#pvisual["arrow.texture"] = arrow.texture.get_atlas()
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

func _on_area_3d_mouse_entered():
	mouse_in_area = true

func _on_area_3d_mouse_exited():
	mouse_in_area = false

func _mouse_in_entity():
	if mouse_in_area == true or mouse_in_coord == true:
		mouse_in_entity = true
	else:
		mouse_in_entity = false
