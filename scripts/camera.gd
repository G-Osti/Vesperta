extends Node3D

var vellin:float = 15
var velrot:float = 10
@onready var camera = $Camera3D
@onready var level = $".."
var camera_pos = 0
var target_rotation: Vector3
var target_position: Vector3
var zoom:int = 2
var destiny = Vector3(0,0,0)

var state = "idle"

var mult:float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	target_rotation = self.rotation_degrees


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (level.state == "arena" or level.state == "occupied") and !level.mouse_in_menu:
		var dir = Input.get_vector("left","right","up","down")
		if sqrt((dir.x*dir.x)+(dir.y*dir.y))>0.1:
			state = "idle"
			if dir.y<-0.5:
				position += Vector3(-1,0,-1).rotated(Vector3(0,1,0),self.rotation.y)    * vellin * delta * dir.length()
			if dir.y>0.5:
				position += Vector3(1,0,1).rotated(Vector3(0,1,0),self.rotation.y)      * vellin * delta * dir.length()
			if dir.x<-0.5:
				position += Vector3(-0.5,0,0.5).rotated(Vector3(0,1,0),self.rotation.y) * vellin * delta * dir.length()
			if dir.x>0.5:
				position += Vector3(0.5,0,-0.5).rotated(Vector3(0,1,0),self.rotation.y) * vellin * delta * dir.length()
		
		if Input.is_action_just_pressed("rot.left"):
			target_rotation += Vector3(0,90,0)
		if Input.is_action_just_pressed("rot.right"):
			target_rotation += Vector3(0,-90,0)
		
		if Input.is_action_just_pressed("zoom_in") and zoom > 1:
			zoom -= 1
		if Input.is_action_just_pressed("zoom_out") and zoom < 3:
			zoom += 1
	
	if state == "focus":
		position = position.lerp(destiny,delta*vellin/2)
		if position.distance_to(destiny)<0.1:
			position = destiny
			state = "idle"
	
	rotation_degrees = rotation_degrees.lerp(target_rotation,delta*velrot)
	if rotation_degrees.distance_to(target_rotation)<=1:
		rotation_degrees = target_rotation
	#print(get_viewport().size)
	mult = float(get_viewport().size.x)/640.0
	camera.size = mult*sqrt(2)*5*pow(2,zoom-1)

#func _unhandled_input(event):
	#if event is InputEventMouseMotion or event is InputEventMouseButton:
		#_mouse_world_pos()

func _mouse_world_pos():
	var mousePos = get_viewport().get_mouse_position()
	var ray_length = 50
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * ray_length
	
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(from,to)
	#ray_query.collide_with_areas = true
	#ray_query.collide_with_bodies = false
	ray_query.set_collision_mask(2)
	var raycast_result = space.intersect_ray(ray_query)
	
	if raycast_result:
		return level.environment._get_cell(raycast_result.position,raycast_result.normal)#,raycast_result.normal)

func _focus(entity:Node3D):
	destiny.x = entity.position.x
	destiny.z = entity.position.z
	state = "focus"

func _focus_coord(coord:Vector3i):
	destiny.x = coord.x
	destiny.z = coord.z
	state = "focus"

#func _unhandled_input(event):
	#if Input.is_action_just_pressed("tab"):
		#print(get_viewport().size," (",ProjectSettings.get_setting("display/window/size/viewport_width"),", ",ProjectSettings.get_setting("display/window/size/viewport_height"),")")
		##print(float(get_viewport().size.x)/float(get_viewport().size.y)," ",float(ProjectSettings.get_setting("display/window/size/viewport_width"))/float(ProjectSettings.get_setting("display/window/size/viewport_height")))
		##print(ProjectSettings.get_setting("display/window/size/viewport_width")+int((float(get_viewport().size.x)/float(ProjectSettings.get_setting("display/window/size/viewport_width"))-get_viewport().size.x/ProjectSettings.get_setting("display/window/size/viewport_width"))*ProjectSettings.get_setting("display/window/size/viewport_width"))," ",ProjectSettings.get_setting("display/window/size/viewport_height")+int((float(get_viewport().size.y)/float(ProjectSettings.get_setting("display/window/size/viewport_height"))-get_viewport().size.y/ProjectSettings.get_setting("display/window/size/viewport_height"))*ProjectSettings.get_setting("display/window/size/viewport_height")))
		##ProjectSettings.set_setting("display/window/size/viewport_width",ProjectSettings.get_setting("display/window/size/viewport_width")+int((float(get_viewport().size.x)/float(ProjectSettings.get_setting("display/window/size/viewport_width"))-get_viewport().size.x/ProjectSettings.get_setting("display/window/size/viewport_width"))*ProjectSettings.get_setting("display/window/size/viewport_width")))
		##ProjectSettings.get_setting("display/window/size/viewport_height",ProjectSettings.get_setting("display/window/size/viewport_height")+int((float(get_viewport().size.y)/float(ProjectSettings.get_setting("display/window/size/viewport_height"))-get_viewport().size.y/ProjectSettings.get_setting("display/window/size/viewport_height"))*ProjectSettings.get_setting("display/window/size/viewport_height")))
		##$Camera3D.size = $Camera3D.size+sqrt(2)
		#print(float(get_viewport().size.x)/float(ProjectSettings.get_setting("display/window/size/viewport_width"))," ",float(get_viewport().size.y)/float(ProjectSettings.get_setting("display/window/size/viewport_height")))
		#mult = min((float(get_viewport().size.x)/float(ProjectSettings.get_setting("display/window/size/viewport_width"))-get_viewport().size.x/ProjectSettings.get_setting("display/window/size/viewport_width")),(float(get_viewport().size.y)/float(ProjectSettings.get_setting("display/window/size/viewport_height"))-get_viewport().size.y/ProjectSettings.get_setting("display/window/size/viewport_height")))
		#print(mult)
