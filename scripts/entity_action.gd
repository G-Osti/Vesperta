extends Control
@onready var level = $"../../../.."
@onready var entity:Node3D = $"../../../Player/Entity"

@onready var head = $SubViewport/Avatar/Head
@onready var arms = $SubViewport/Avatar/Arms
@onready var torso = $SubViewport/Avatar/Torso
@onready var legs = $SubViewport/Avatar/Legs
@onready var sleeves = $SubViewport/Avatar/Sleeves
@onready var shirt = $SubViewport/Avatar/Shirt
@onready var boots = $SubViewport/Avatar/Boots
@onready var hair = $SubViewport/Avatar/Hair
@onready var face = $SubViewport/Avatar/Face
@onready var cape = $SubViewport/Avatar/Cape
@onready var hat = $SubViewport/Avatar/Hat

@export var pvisual: Dictionary = {
}

@onready var nametag = $Nametag/Value
@onready var image = $Image

@onready var life = $Life/Bar
#@onready var life_shield = $Life/Bar/Shield
@onready var life_penalty = $Life/Bar/Penalty
@onready var life_value = $Life/Bg/Value

@onready var energy = $Energy/Bar
@onready var energy_penalty = $Energy/Bar/Penalty
@onready var energy_value = $Energy/Bg/Value

@onready var action = $Action/Bar
@onready var action_penalty = $Action/Bar/Decrease
@onready var action_value = $Action/Bg/Value

#@onready var destiny:int = get_viewport_rect().size.x/2

# Called when the node enters the scene tree for the first time.
func _ready():
	_update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update()
	#position = position.lerp(Vector2(destiny,0),order.vel_anim*delta)
	#if position.distance_to(Vector2(destiny,0))<0.1:
		#position = Vector2(destiny,0)
	pass

func _update():
	entity = $"..".entity
	if entity != null:
		#name = entity.name
		nametag.text = entity.name
		#image.texture = utils.get_portrait(portrait)
		pvisual = entity.pvisual
		_load_visuals()
		
		life.max_value = entity.PV
		life.value = entity.PVA
		#life_shield.max_value = entity.max_life
		#life_shield.value = entity.life_shield
		life_penalty.max_value = entity.PV
		life_penalty.value = entity.PVP
		life_value.text = str(life.value)+" PV" #+str(life.max_value-life_penalty.value)
		#if life_shield.value > 0:
			#life_value.text = life_value.text+"("+str(life_shield.value)+")"
		
		energy.max_value = entity.PE
		energy.value = entity.PEA
		#energy_shield.max_value = entity.max_energy
		#energy_shield.value = entity.energy_shield
		energy_penalty.max_value = entity.PE
		energy_penalty.value = entity.PEP
		energy_value.text = str(energy.value)+" PE" #+str(energy.max_value-energy_penalty.value)
		#if entity_shield.value > 0:
			#entity_value.text = entity_value.text+"("+str(entity_shield.value)+")"
		
		action.max_value = entity.LPA
		action.value = entity.PAA
		#action_shield.max_value = entity.max_action
		#action_shield.value = entity.action_shield
		action_penalty.max_value = entity.LPA
		action_penalty.value = entity.PAP
		action_value.text = str(action.value)+" PA" #+str(action.max_value-action_penalty.value)
		#if action_shield.value > 0:
			#action_value.text = action_value.text+"("+str(action_shield.value)+")"

func _on_character_pressed():
	level._menu_input(%CharacterMenu)
	

func _load_visuals():
	#arrow.texture.set_atlas(pvisual["arrow.texture"])
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
