class_name CharacterData
extends Resource

@export var nome = "Character"
@export var unique = false
@export var team = 0
@export var ai = false

@export var pvisual: Dictionary = {
	"arms.modulate": PackedColorArray([Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0)]),
	"arms.texture": "res://assets/sprites/Entidades/Humanoide/Braços.png",
	"boots.modulate": PackedColorArray([Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0)]),
	"boots.texture": "res://assets/sprites/Entidades/Humanoide/Acessorios/Botas0.png",
	"face.modulate": PackedColorArray([Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0)]),
	"face.texture": "res://assets/sprites/Entidades/Humanoide/Acessorios/Face0.png",
	"hair.modulate": PackedColorArray([Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0)]),
	"hair.texture": "res://assets/sprites/Entidades/Humanoide/Acessorios/Cabelo0.png",
	"hat.modulate": PackedColorArray([Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0)]),
	"hat.texture": "res://assets/sprites/Entidades/Humanoide/Acessorios/Face0.png",
	"head.modulate": PackedColorArray([Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0)]),
	"head.texture": "res://assets/sprites/Entidades/Humanoide/Cabeça.png",
	"legs.modulate": PackedColorArray([Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0)]),
	"legs.texture": "res://assets/sprites/Entidades/Humanoide/Pernas.png",
	"shirt.modulate": PackedColorArray([Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0)]),
	"shirt.texture": "res://assets/sprites/Entidades/Humanoide/Acessorios/Camisa0.png",
	"sleeves.modulate": PackedColorArray([Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0)]),
	"sleeves.texture": "res://assets/sprites/Entidades/Humanoide/Acessorios/Mangas0.png",
	"torso.modulate": PackedColorArray([Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0)]),
	"torso.texture": "res://assets/sprites/Entidades/Humanoide/Tronco.png"
}

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
