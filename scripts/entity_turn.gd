extends Control

@onready var level: Node = $"../../.."
@onready var entity:Node3D
@onready var retrato: TextureRect = $Retrato
@onready var vida: TextureProgressBar = $Vida
@onready var nome: Label = $Nome

@export var order:int = 1
#@export var portrait = load("res://assets/sprites/Texturas/Acao.png")

@onready var head: Sprite2D = $Avatar/Offset/Head
@onready var arms: Sprite2D = $Avatar/Offset/Arms
@onready var torso: Sprite2D = $Avatar/Offset/Torso
@onready var legs: Sprite2D = $Avatar/Offset/Legs
@onready var sleeves: Sprite2D = $Avatar/Offset/Sleeves
@onready var shirt: Sprite2D = $Avatar/Offset/Shirt
@onready var boots: Sprite2D = $Avatar/Offset/Boots
@onready var hair: Sprite2D = $Avatar/Offset/Hair
@onready var face: Sprite2D = $Avatar/Offset/Face
@onready var cape: Sprite2D = $Avatar/Offset/Cape
@onready var hat: Sprite2D = $Avatar/Offset/Hat

@onready var turn = $Turno

@onready var destiny:Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
#func _ready():
	#_update()

func _process(delta):
	if position.distance_to(destiny)>0.1:
		position = position.lerp(destiny,utils.configs["slot_anim_vel"]*delta)
	else:
		position = destiny

func _update():
	if entity != null:
		#portrait = entity.portrait
		nome.text = entity.nome
		turn.text = str(int(entity.turn))
		vida.value = (float(entity.PV)*vida.max_value)/float(entity.PVmax)
		for subsprite in [head,arms,torso,legs,sleeves,shirt,boots,hair,face,hat]:
			subsprite.set_texture(load(entity.pvisual[str(subsprite.name).to_lower()+".texture"]))
			var SpriteColor = ShaderMaterial.new()
			SpriteColor.shader = preload("res://assets/cenas/SpriteColor.gdshader")
			subsprite.material = SpriteColor
			subsprite.material.set_shader_parameter("C",entity.pvisual[str(subsprite.name).to_lower()+".modulate"])
		#head.set_texture(load(entity.pvisual["head.texture"]))
		#head.modulate = entity.pvisual["head.modulate"]
		#arms.set_texture(load(entity.pvisual["arms.texture"]))
		#arms.modulate = entity.pvisual["arms.modulate"]
		#torso.set_texture(load(entity.pvisual["torso.texture"]))
		#torso.modulate = entity.pvisual["torso.modulate"]
		#legs.set_texture(load(entity.pvisual["legs.texture"]))
		#legs.modulate = entity.pvisual["legs.modulate"]
		#sleeves.set_texture(load(entity.pvisual["sleeves.texture"]))
		#sleeves.modulate = entity.pvisual["sleeves.modulate"]
		#shirt.set_texture(load(entity.pvisual["shirt.texture"]))
		#shirt.modulate = entity.pvisual["shirt.modulate"]
		#boots.set_texture(load(entity.pvisual["boots.texture"]))
		#boots.modulate = entity.pvisual["boots.modulate"]
		#hair.set_texture(load(entity.pvisual["hair.texture"]))
		#hair.modulate = entity.pvisual["hair.modulate"]
		#face.set_texture(load(entity.pvisual["face.texture"]))
		#face.modulate = entity.pvisual["face.modulate"]
		#cape.set_texture(load(entity.pvisual["cape.texture"]))
		#cape.modulate = entity.pvisual["cape.modulate"]
		#hat.set_texture(load(entity.pvisual["hat.texture"]))
		#hat.modulate = entity.pvisual["hat.modulate"]
	#retrato.texture = portrait
	if order == 1:
		scale = Vector2(1.0,1.0)
	else:
		scale = Vector2(1.0,1.0)
	self.destiny.y = (self.size.y)*self.scale.y*(order-1)#((self.size.y-3)+(self.size.y)*self.scale.y*(order-2))*int(order>1)
	#self.destiny.y = (-(self.size.y)*self.scale.y*($"..".get_children().size())/2+(self.size.y)*self.scale.y*utils.configs["ui_scale"]*order)

func _on_mouse_entered():
	level.mouse_in_interface = true

func _on_mouse_exited():
	level.mouse_in_interface = false
