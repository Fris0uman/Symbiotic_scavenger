extends Actor

var _current_path: PoolVector2Array
var _curr_dest: Vector2
var _heading: float

var _bodies_fleeing_from: Array

export var _step_size:= 40

onready var awarness_area:= $Area2D
onready var nav_agent:= $NavigationAgent2D

onready var map := get_node("../TileMap")


func _ready() -> void:
	set_process(true)
	
	awarness_area.connect("body_entered",self, "_on_body_entered")
	awarness_area.connect("body_exited",self,"_on_body_exited")
	nav_agent.connect("velocity_computed", self, "move")

	pick_heading()

func _physics_process(_delta: float) -> void:
	if _bodies_fleeing_from.empty():
		return

	if _current_path.empty():
		new_path()

	var next_location= _current_path[0]
	var direction:= position.direction_to(next_location)
	var target_vel:= direction * _speed

	nav_agent.set_velocity(target_vel)
	
	if close_enough(next_location):
		_current_path.remove(0)

func _on_body_entered(body: Body)->void:
	if body == null || !body.is_in_group("Actor"):
		return
	
	_bodies_fleeing_from.append(body)
	new_path()


func _on_body_exited(body: Body)->void:
	if body == null || !body.is_in_group("Actor"):
		return
	_bodies_fleeing_from.erase(body)

func pick_fleeing_heading()->void:
	var chaser_vector:= Vector2.ZERO
	for body in _bodies_fleeing_from:
		chaser_vector += position.direction_to(body.position)
	_heading = acos( - chaser_vector.normalized().x )

func new_path()->void:
	pick_fleeing_heading()
	_curr_dest = pick_destination()
	_current_path = make_path(_curr_dest)

func make_path(destination: Vector2)->PoolVector2Array:
	var path = Navigation2DServer.map_get_path(nav_agent.get_navigation_map() ,position,destination, false)
	return path


func pick_destination()->Vector2:
	var dest:= position
	var cell_index:= -1
	while cell_index != 1:
		var rand_angle:= rand_range(_heading-PI/3, _heading+ PI/3)
		var rand_vector:= Vector2(cos(rand_angle),sin(rand_angle))
		dest = global_position + rand_vector * _step_size
		cell_index = map.get_cellv(map.world_to_map(dest))

	return dest

func pick_heading():
	_heading = rand_range(0,2*PI)

func close_enough(vect: Vector2, bod = null)->bool:
	if bod == null:
		return position.distance_to(vect)<=_body_size/2.0
	else:
		var bod_size= bod.get_body_size()
		var dist:= position.distance_to(vect)
		return dist <= (bod_size + _body_size)/2 + GRAB_DIST
