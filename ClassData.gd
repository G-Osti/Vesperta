class_name ClassData
extends Resource

@export var icon: Texture2D
@export var name: String

@export_multiline var description: String

#Características Base
@export var PV:float = 0 #Pontos de Vida Extra
@export var PT:float = 0 #Potência Extra
@export var PE:float = 0 #Pontos de Escudo Extra
@export var VEL:float = 0 #Velocidade Extra
@export var CRT:float = 0 #Aumento de Crítico Extra

#Características de Teste
@export var PRE:float = 0 #Precisão Extra
@export var EVA:float = 0 #Evasão Extra
@export var AMP:float = 0 #Amplitude Extra
@export var RES:float = 0 #Resistência Extra
@export var AST:float = 0 #Astúcia Extra

#Características Gerais
@export var M_CRT:float = 0 #Multiplicador de Crítico Extra
@export var PA:int = 0 #Pontos de Ação Extra
@export var MOV:int = 0 #Movimentação Extra
@export var AM:int = 0 #Ameaça Extra
@export var AD:Dictionary = { #Armadura Extra
	"geral" = 0,
	"físico" = 0,
	"calor" = 0,
	"frio" = 0,
	"miasma" = 0,
	"raio" = 0,
	"mental" = 0
}

@export var perks:Dictionary = { #Lista dde Vantagens
	"1":Resource
}

@export var skills:Dictionary = {
	"Habilidade 1":Resource,
	"Habilidade 2":Resource,
	"Habilidade 3":Resource,
	"Habilidade 4":Resource,
}

signal class_used

func use_res():
	class_used.emit()
