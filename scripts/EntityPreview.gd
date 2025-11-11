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

@export var appearance: utils.SPRITES
@onready var pvisual: Dictionary = {
}
@export var portrait: utils.SPRITES
@export var cell_coord:Vector3i = Vector3i(0,2,0):
	set(value):
		cell_coord = value

@onready var overlay = $Sprite/SubViewport/Overlay
@onready var overlay_health = $Sprite/SubViewport/Overlay/Health
@onready var overlay_health_penalty = $Sprite/SubViewport/Overlay/Health/Penalty
@onready var overlay_vigor = $Sprite/SubViewport/Overlay/Vigor
@onready var overlay_vigor_penalty = $Sprite/SubViewport/Overlay/Vigor/Penalty
@onready var overlay_locked = $Sprite/SubViewport/Overlay/Vigor/Locked
@onready var overlay_nametag = $Sprite/SubViewport/Overlay/Name
@onready var overlay_turn = $Sprite/SubViewport/Overlay/Turn

var k:int = 0
var path:PackedVector3Array = []
@onready var level = $"../.."
@onready var sprite = $Sprite
@export var team = 0
#@export var id = 0
@export var ai = false

#@onready var tween = create_tween()
var seen_cells:PackedVector3Array = []
var movements:PackedVector3Array = []
var allies:PackedVector3Array = []
var enemies:PackedVector3Array = []
var objects:PackedVector3Array = []

var orientation = Vector2i(0,1):
	get:
		return orientation
	set(value):
		if value != orientation:
			_animation_update()
		orientation = value
var new_orientation: Vector2i

var max_health = 20:
	set(value):
		max_health = value
		overlay_health.max_value = value
		overlay_health_penalty.max_value = value
var health = max_health:
	get:
		return health
	set(value):
		health = value
		overlay_health.value = value
		if value <= 0:
			level.control._death(self)
var health_penalty = 0:
	set(value):
		health_penalty = value
		overlay_health_penalty.value = value
var max_vigor = 50:
	set(value):
		max_vigor = value
		overlay_vigor.max_value = value
		overlay_vigor_penalty.value = value
var vigor = max_vigor:
	set(value):
		vigor = value
		overlay_vigor.value = value
var vigor_penalty = 0:
	set(value):
		vigor_penalty = value
		overlay_vigor_penalty.value = value
var max_energy = 6
var energy_base_cost = 2
var energy = 0:
	get:
		return energy
	set(value):
		energy = value
var old_energy = 0
var inc_energy = 4
var energy_locked = 0
var energy_penalty = 0

var resistence = 0
var damage:Vector2i = Vector2i(5,10)
var attack_cost = 2
var penetration = 0
var target_tile = []
var mov_tile = []

var precision = 20
var evasion = 10

var agility = 20
var turn = 0:
	set(value):
		turn = value
var placed = false
var state = "idle":
	get:
		return state
	set(value):
		if value != state:
			_animation_update()
		state = value
var post_state = "idle"
var n = 0

var speed = 4
var movement_range = speed:
	set(value):
		movement_range = value
var climb_range = 2
var attack_range = 1

var act_type = "Perto"

var equipped

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
		
	if (new_orientation.x!=0 or new_orientation.y!=0) and not(new_orientation.x!=0 and new_orientation.y!=0):
		if new_orientation.x<0 or new_orientation.y<0 and animation_player.current_animation != "Andar2":
			animation_player.current_animation = "Andar2"
		elif new_orientation.x>0 or new_orientation.y>0 and animation_player.current_animation != "Andar1":
			animation_player.current_animation = "Andar1"
		if (new_orientation.x<0 or new_orientation.y>0):
			_flip(false)
		elif (new_orientation.x>0 or new_orientation.y<0):
			_flip(true)
	else:
		_flip(false)
		animation_player.current_animation = "Andar1"
	if state == "waiting" or state == "positioning":
		animation_player.speed_scale = 1
	if state == "moving":
		animation_player.speed_scale = 1.5
	
	if state != "waiting" and state != "moving" and state != "positioning":
		animation_player.stop()
	else:
		animation_player.play()

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
			#if energy <= 0:
				#_end_turn()
			#if energy > 0:
			if post_state == "waiting":
				state = post_state
				_end_action()
			if post_state == "attack" or post_state == "support":
				state = post_state
				if act_type == "Perto":
					_melee_action()
				if act_type == "Longe":
					_ranged_action()
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
	movement_range -= path.size()-1
	#level.control._prepare_action()
	level.environment._clear_movement()
	level.environment._get_movements(self)
	if ai == true:
		%Entities._get_ai_action(self)
	_update()
	level.control._update()

func _end_turn():
	k = 0
	if path.size() > 0:
		position = Vector3(path[path.size()-1])*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
	level.action_in_progress = false
	level.environment._clear_movement()
	turn = turn - 100
	for i in range(12):
		turn = turn + randi_range(-4,4)
	state = "idle"
	level.control.state = "order"
	_update()

func _melee_action():
	post_state = "waiting"
	energy -= 2
	old_energy = energy
	_damage(target_tile)
	_reorient(target_tile)
	var tween = create_tween()
	tween.tween_property(self, "position", (Vector3(target_tile)+(Vector3(cell_coord)-Vector3(target_tile))/2)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),1/float(level.anim_vel*0.8333))
	tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),1/float(level.anim_vel*1.25))
	tween.tween_interval(0.25/float(level.anim_vel))
	tween.connect("finished", on_tween_finished)

func _ranged_action():
	post_state = "waiting"
	energy -= 2
	old_energy = energy
	_damage(target_tile)
	_reorient(target_tile)
	var tween = create_tween()
	tween.tween_property(self, "position", Vector3(target_tile+(Vector3(cell_coord)-path[k])/2)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),1/float(level.anim_vel*0.8333))
	tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),1/float(level.anim_vel*1.25))
	tween.tween_interval(0.25/float(level.anim_vel))
	tween.connect("finished", on_tween_finished)

func _damage(tile):
	var target = []
	for entity in level.entities.get_children():
		if entity.cell_coord == tile:
			target.append(entity)
	for entity in target:
		var eva = 0
		if Vector2(position.x,position.z) == Vector2(entity.position.x,entity.position.z)+Vector2(entity.orientation.x,entity.orientation.y):
			eva = entity.evasion
		else:
			eva = entity.evasion/2
		var rng = randi_range(1,100)
		if rng > 100*eva/(eva+precision):
			entity._damaged(damage,penetration)
		else:
			entity._damaged(damage/2,0)

func _reorient(target_pos):
	var direction = Vector2i((target_pos-self.cell_coord).x,(target_pos-self.cell_coord).z)
	orientation = Vector2i(direction.abs().max_axis_index()==0,direction.abs().max_axis_index()==1)*direction[direction.abs().max_axis_index()]/abs(direction[direction.abs().max_axis_index()])
	_animation_update()

func _damaged(dmg_rng:Vector2i,pen):
	var dmg = randi_range(dmg_rng.x,dmg_rng.y)
	if vigor > 0:
		if pen > 0:
			vigor -= dmg*(1-pen)
			health -= dmg*pen
		else:
			vigor -= dmg
	else:
		health -= dmg

func _movement_action(tile:Vector3i,target:String):
	level.action_in_progress = true
	state = "moving"
	_animation_update()
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
	if old_energy + inc_energy <= max_energy:
		energy = old_energy + inc_energy
	else:
		energy = max_energy
	old_energy = energy
	movement_range = speed
	_update()
	level.environment._get_movements(self)
	if ai == true:
		%Entities._get_ai_action(self)

func _update():
	overlay_nametag.text = self.name
	self.position = Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5)
	resistence = 0
	health = health
	max_health = max_health
	health_penalty = health_penalty
	vigor = vigor
	max_vigor = max_vigor
	vigor_penalty = vigor_penalty
	max_energy = 6
	
	energy_locked = 0
	energy_penalty = 0
	
	var precision_extra = 0
	var evasion_extra = 0
	#for item in equipped:
		#if item != "Empty":
			#precision_extra += utils.get_item(item).precision
			#evasion_extra += utils.get_item(item).evasion
	precision = 20 + precision_extra
	evasion = 10 + evasion_extra
	
	var damage_extra:Vector2i
	#for item in equipped:
		#if item != "Empty":
			#damage_extra += utils.get_item(item).damage
	damage = Vector2i(5,10) + damage_extra
	
	agility = 20
	speed = 4
	climb_range = 2
	attack_range = 1
	
	_load_visuals()
	
	if state == "waiting":
		level.environment._clear_movement()
		level.environment._get_movements(self)
	seen_cells.clear()
	seen_cells = level.control._get_fov_raycast(self.position+Vector3(0,1,0))
	_animation_update()

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
	if level.overlay_state == "arena" and state == "idle":
		overlay.visible = true

func _on_area_3d_mouse_exited():
	overlay.visible = false
