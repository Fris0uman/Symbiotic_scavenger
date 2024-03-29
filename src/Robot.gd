extends Actor

var _current_path: PoolVector2Array
var _curr_dest: Vector2

var grab_target: Vector2

var _home_depot_pos: Vector2
var _home_depot_area: Area2D

var _heading: float

export var _step_size:= 40

onready var line:= $Line2D
onready var awarness_area:= $Area2D
onready var collision_shape:= $CollisionShape2D
onready var nav_agent:= $NavigationAgent2D

onready var map := get_node("../TileMap")

func _ready() -> void:
	set_process(true)
	
	nav_agent.connect("velocity_computed", self, "move")
	
	var AI_core = get_tree().get_nodes_in_group("Core")[0]
	_home_depot_area = AI_core.get_child(2)
	_home_depot_pos = _home_depot_area.global_position
	
	pick_heading()
	new_path()

func _draw() -> void:
	if trying_grab || _grabbed_object!= null:
		var target = get_grab_target_pos(grab_target, true)
		draw_line(to_local(position),target,Color.antiquewhite)

func _process(_delta: float) -> void:
	line.global_position = Vector2.ZERO
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
			pick_heading()
			new_path()
	
	
	if _current_path.empty():
		new_path()
	
	
	var next_location= _current_path[0]
	var direction:= position.direction_to(next_location)
	var target_vel:= direction * _speed

	nav_agent.set_velocity(target_vel)

	if close_enough(next_location):
		_current_path.remove(0)
		line.remove_point(0)

func pick_heading():
	_heading = rand_range(0,2*PI)

func new_path()->void:
	_curr_dest = pick_destination()
	_current_path = make_path(_curr_dest)

func make_path(destination: Vector2)->PoolVector2Array:
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
				var rand_angle:= rand_range(_heading-PI/3, _heading+ PI/3)
				var rand_vector:= Vector2(cos(rand_angle),sin(rand_angle))
				dest = global_position + rand_vector * _step_size
				cell_index = map.get_cellv(map.world_to_map(dest))
	else:
		dest = _home_depot_pos
	
	return dest

func get_closest_ressource_in_awarness()->Body:
	var closest_body: Body
	for body in awarness_area.get_overlapping_bodies():
		if !_home_depot_area.overlaps_body(body) && ( !body.is_grabbed() || body.is_in_group("Prey")):
			if body.is_in_group("Ressource"):
				closest_body= body
	return closest_body

func is_robot()->bool:
	return true
