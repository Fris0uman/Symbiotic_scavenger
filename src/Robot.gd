extends Actor

var _current_path: PoolVector2Array

var _body_size:= 20

var ORIGIN:= Vector2(512,576)

onready var Nav:= get_node("../Navigation2D")
onready var line:= $Line2D
onready var awarness_area:= $Area2D


func _process(delta: float) -> void:
	line.global_position = Vector2.ZERO
	if _current_path.empty():
		_current_path = make_path(pick_destination())
	var direction:= (_current_path[0] - position).normalized()
	move_force = _speed * direction
	move_force = move(move_force)
	if close_enough(_current_path[0]):
		_current_path.remove(0)
		line.remove_point(0)


func make_path(destination: Vector2)->PoolVector2Array:
	var path= Nav.get_simple_path(position,destination,false)
	line.points = path
	return path

func close_enough(vect: Vector2)->bool:
	return position.distance_squared_to(vect)<=_body_size/2

func pick_destination()->Vector2:
	var dest: Vector2
	
	if _grabbed_object == null:
		var closest_body = get_closest_ressource_in_awarness()
		if closest_body != null:
			return closest_body.position
		
		var home_direction:= (ORIGIN - position).normalized()
		dest = position - home_direction*40
	
	return dest

func get_closest_ressource_in_awarness()->Body:
	var closest_body: Body
	for body in awarness_area.get_overlapping_bodies():
			if body.is_in_group("Ressource"):
				closest_body= body
	return closest_body
