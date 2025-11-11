extends Control

@onready var level = $"../.."
var turn_indicator: PackedScene = preload("res://assets/cenas/entity_turn.tscn")
var entities_turns:Array# = [$Ordering/EntityTurn]

#func _ready():
	#_initialize()

func _process(delta):
	pass

#func _initialize():
	#print("initializing turns...")
	#for entity in $"../../Entities".get_children():
		#print(entity)
		#var instance = turn_indicator.instantiate()
		#entities_turns.append(instance)
		#%Turns.get_child(0).add_child(instance)
		#instance.entity = entity

func _create_turns():
	print("creating turns")
	for entity in $"../../Entities".get_children():
		print(entity)
		var instance = turn_indicator.instantiate()
		entities_turns.append(instance)
		self.add_child(instance)
		instance.entity = entity
	
	#var temp_positions: PackedVector2Array
	#for entity_turn in entities_turns:
		#if entities_turns != null:
			#temp_positions.append(entity_turn.position)
		#entity_turn.queue_free()
	#entities_turns.clear()
	#
	#for entity in get_tree().get_nodes_in_group("entity"):
		#var instance = turn_indicator.instantiate()
		#entities_turns.append(instance)
		#$Ordering.add_child(instance)
		#instance.entity = entity
		#if !temp_positions.is_empty():
			#instance.position = temp_positions[entity.get_index()]

func _update():
	for turn in entities_turns:
		if turn.entity != null:
			turn.pvisual = turn.entity.pvisual
			turn._load_visuals()
	
	var turn_values = []
	var turn_order = []
	for turn in $Ordering.get_children():
		turn._update()
		turn_values.append(float(turn.turn.text))
	for n in turn_values.size():
		turn_order.append($Ordering.get_children()[turn_values.find(turn_values.max())])
		turn_values[turn_values.find(turn_values.max())] = -1
		turn_order[n].destiny = -turn_order[n].size.x*turn_values.size()/2+turn_order[n].size.x*n
