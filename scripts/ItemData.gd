class_name ItemData
extends Resource

@export var icon: Texture2D
@export var color = PackedColorArray([Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0),Color(0,0,0,0)])
@export var name: String

@export_enum("Equipamento","Acessório","Mecanismo","Dínamo")
var type: String

@export_enum("Nenhum","Uma Mão","Duas Mãos","Caos","Ordem","Íntegro","Fluxo")
var subtype1: String = "Nenhum"

@export_enum("Nenhum","Caos","Ordem","Íntegro","Fluxo")
var subtype2: String = "Nenhum"

@export_enum("Nenhum","Perto","Arco","Raio")
var anim: String = "Nenhum"

#@export_enum("Físico","Chaos","Order","Anima","Flux","Vision")
#var element: String

@export_multiline var description: String

#Características Adicionais (Todas são somadas às características base
@export var PV:int = 0 #Pontos de Vida Extra
@export var VEL:int = 0 #Velocidade Extra
@export var CRT:int = 0 #Aumento de Crítico Extra
@export var DAN = Vector2i(0,0)
@export var M_CRT:float = 0 #Multiplicador de Crítico Extra
@export var MOV:int = 0 #Movimentação Extra
@export var AM:int = 0
@export var AD:Dictionary = { #Armadura Extra
	"geral" = 0,
	"físico" = 0,
	"calor" = 0,
	"frio" = 0,
	"miasma" = 0,
	"raio" = 0,
	"mental" = 0}
@export var PRE:int = 0
@export var REF:int = 0
@export var ALC:int = 0
@export var CB:int = 0

@export var perks:Dictionary = { #Lista dde Vantagens
	"1"=null
}

signal item_used

func use_res():
	item_used.emit()
