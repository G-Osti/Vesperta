class_name SavedGame
extends Resource

@export var pvisual:Dictionary
@export var cell_coord:Vector3i
var k:int
var path:PackedVector3Array
@export var team = 0
@export var ai = false

var seen_cells:PackedVector3Array = []
var movements:PackedVector3Array = []
var allies:PackedVector3Array = []
var enemies:PackedVector3Array = []
var objects:PackedVector3Array = []

var orientation = Vector2i(0,1)

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

@export var FIS = 2
@export var POD = 2
@export var DES = 2
@export var AST = 2
@export var ESP = 2

var PV:float = 16+8*FIS
var PE:float = 16+8*POD
var VEL:float = 10+0.5*ESP
var RPA:float = 4
var LPA:float = 6
var PRE:float = 0+3*DES+2*AST
var MRG:float = 0+2.5*AST
var CRT:float = 1.5
var REF:float = 0+3*DES+2*ESP
var TEN:float = 0+5*FIS
var MOV:float = 4
var FUR:float = 0+5*DES
var PER:float = 0+5*ESP
var DANV = Vector2i(1,4)
var DAN:float = 0 + POD
var AMP:float = 0+5*AST

var PVA = PV
var PVP = 0
var PEA = PE
var PEP = 0
var PPA = 2 #Custo de PA a ação padrão
var PAA = 0 #Pontos de ação atuais
var PAV = 0 #Pontos de ação do turno anterior
var PAL = 0 #Pontos de ação travados
var PAP = 0 #Penalidade de pontos de ação

var RES:Dictionary = {
	"físico" = 0,
	"calor" = 0,
	"frio" = 0,
	"miasma" = 0,
	"raio" = 0,
	"mental" = 0
}
var PEN = 0 #Penetração de escudo
var MOVR = MOV #Movimentação restante
var MOVV = 1 #Movimentação vertical
var ALC = 1 #Alcance da ação padrão

var target_tile = []
var mov_tile = []
var turn = 0
var placed = false
var state = "idle"
var post_state = "idle"
var n = 0

var rot = 0:
