class_name SkillData
extends Resource

@export var icon: Texture2D
@export var name: String

@export_multiline var description: String

@export_enum("Alvo","Área")
var type: String

@export var safe_targeting = false

@export_enum("Neutro","Caos","Ordem","Anima","Fluxo","Visão")
var element: String

@export var perks:Dictionary = { #Lista dde Vantagens
	"1":Resource
}

@export var cost:int = 0
@export var recharge:int = 0
var cooldown:int = 0
@export var delay:int = 0
@export var damage:Vector2 = Vector2(0,0)
@export var PVC:int = 0 #Custo de PV
@export var PEC:int = 0 #Custo de PE

signal skill_used

func sel_res(user):
	if type == "Alvo":
		return
	elif type == "Área":
		return

func use_res(user):
	skill_used.emit()
	
	user.PAA -= cost
	user.PAV = user.PAA
	#if damage != Vector2(0,0):
		#_damage(target_tile)
		#_reorient(target_tile)
	#var tween = create_tween()
	#tween.tween_property(self, "position", (Vector3(target_tile)+(Vector3(cell_coord)-Vector3(target_tile))/2)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),1/float(level.anim_vel*0.8333))
	#tween.tween_property(self, "position", Vector3(cell_coord)*Vector3(1,0.5,1)+Vector3(0.5,0.5,0.5),1/float(level.anim_vel*1.25))
	#tween.tween_interval(0.25/float(level.anim_vel))
	#tween.connect("finished", on_tween_finished)
	
