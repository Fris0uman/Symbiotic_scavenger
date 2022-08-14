extends Actor

var _current_path: PoolVector2Array

var grab_target: Vector2

var ORIGIN:= Vector2(512,576)

onready var Nav:= get_node("../Navigation2D")
onready var line:= $Line2D
onready var awarness_area:= $Area2D
onready var collision_shape:= $CollisionShape2D

func _ready() -> void:
	set_process(true)

func _draw() -> void:
	if trying_grab || _grabbed_object!= null:
		var target = get_grab_target_pos(grab_target, true)
		draw_line(to_local(position),target,Color.antiquewhite)

func _process(delta: float) -> void:
	line.global_position = Vector2.ZERO
	
	var closest_ressource = get_closest_ressource_in_awarness()
	if closest_ressource!= null && !is_carrying():
		grab_target = closest_ressource.position
		if close_enough(grab_target, closest_ressource):
			trying_grab = true
			if try_grab(grab_target):
				confirm_grab()
				clear_path()
	else:
		trying_grab = false
		grab_target= position
	
	if _current_path.empty():
		_current_path = make_path(pick_destination())
	var direction:= (_current_path[0] - position).normalized()
	move_force = _speed * direction
	move_force = move(move_force)
	
	
	if close_enough(_current_path[0]):
		_current_path.remove(0)
		line.remove_point(0)
	
	update()

func clear_path()->void:
	_current_path = PoolVector2Array()

func make_path(destination: Vector2)->PoolVector2Array:
	var path= Nav.get_simple_path(position,destination,false)
	line.points = path
	return path

func close_enough(vect: Vector2, bod = null)->bool:
	if bod == null:
		return position.distance_to(vect)<=_body_size/2
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
			var home_direction:= (ORIGIN - position).normalized()
			dest = position - home_direction*40
	else:
		dest = ORIGIN
	
	
	return dest

func get_closest_ressource_in_awarness()->Body:
	var closest_body: Body
	for body in awarness_area.get_overlapping_bodies():
			if body.is_in_group("Ressource"):
				closest_body= body
	return closest_body
