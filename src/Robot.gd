extends Actor

var _current_path: PoolVector2Array

var grab_target: Vector2

var _home_depot_pos: Vector2
var _home_depot_area: Area2D

onready var Nav:= get_node("../Navigation2D")
onready var line:= $Line2D
onready var line2:= $Line2D2
onready var awarness_area:= $Area2D
onready var collision_shape:= $CollisionShape2D
onready var nav_agent:= $NavigationAgent2D

onready var map := get_node("../TileMap")

func _ready() -> void:
	nav_agent.connect("velocity_computed", self, "agent_velocity_computed")
	set_process(true)
	
	var AI_core = get_tree().get_nodes_in_group("Core")[0]
	_home_depot_area = AI_core.get_child(2)
	_home_depot_pos = _home_depot_area.global_position
	
	new_path()

func _draw() -> void:
	if trying_grab || _grabbed_object!= null:
		var target = get_grab_target_pos(grab_target, true)
		draw_line(to_local(position),target,Color.antiquewhite)

func _process(delta: float) -> void:
	line.global_position = Vector2.ZERO
	line2.global_position = Vector2.ZERO
	update()

func _physics_process(_delta: float) -> void:
	var closest_ressource = get_closest_ressource_in_awarness()
	if closest_ressource!= null && !is_carrying():
		grab_target = closest_ressource.position
		if close_enough(grab_target, closest_ressource):
			trying_grab = true
			if try_grab(grab_target):
				confirm_grab()
				new_path()
	else:
		trying_grab = false
		grab_target= position
	
	if is_carrying():
		if close_enough(_home_depot_pos):
			release_grab()
			new_path()
	
	
	if nav_agent.is_target_reached():
		new_path()
	
	var next_location= nav_agent.get_next_location()
	line2.add_point(next_location)
	var direction:= position.direction_to(next_location)
	#move_force = _speed * direction
	#move_force = move(move_force)
	
	var target_vel:= direction * _speed
	nav_agent.set_velocity(target_vel)
	
	if close_enough(next_location):
		line2.remove_point(0)


func agent_velocity_computed(calculated_velocity : Vector2):
	move(calculated_velocity)

func new_path()->void:
	make_path(pick_destination())

func make_path(destination: Vector2)->PoolVector2Array:
	#var path= Nav.get_simple_path(position,destination,false)
	nav_agent.set_target_location(destination)
	var path = Navigation2DServer.map_get_path(nav_agent.get_navigation_map() ,position,destination, false)
	line.points = path
	return path

func close_enough(vect: Vector2, bod = null)->bool:
	if bod == null:
		return position.distance_to(vect)<=_body_size/2.0
	else:
		var bod_size= bod.get_body_size()
		var dist:= position.distance_to(vect)
		return dist <= (bod_size + _body_size)/2 + GRAB_DIST


func pick_destination()->Vector2:
	var dest:= position
	
	if !is_carrying():
		var closest_body = get_closest_ressource_in_awarness()
		if closest_body != null:
			return closest_body.position
		else:
			var cell_index:= -1
			while cell_index != 1:
				var rand_angle:= rand_range(PI, 2*PI/3)
				var rand_vector:= Vector2(cos(rand_angle),sin(rand_angle))
				dest = position.direction_to(rand_vector)
				cell_index = map.get_cellv(map.world_to_map(dest))
	else:
		dest = _home_depot_pos
	
	
	return dest

func get_closest_ressource_in_awarness()->Body:
	var closest_body: Body
	for body in awarness_area.get_overlapping_bodies():
		if !_home_depot_area.overlaps_body(body) && !body.is_grabbed():
			if body.is_in_group("Ressource"):
				closest_body= body
	return closest_body
