extends Body
class_name Actor

var _speed:= 80
var _grabbed_object: RigidBody2D

var move_force: = Vector2.ZERO

var trying_grab:= false
var grab_ray_length:= 40

var GRAB_DIST:= 40

onready var grab_ray:= $RayCast2D

signal grab_ray_hit(collider, emitter)
signal grab_release(grabbed,grabber)

func confirm_grab()->void:
	emit_signal("grab_ray_hit", grab_ray.get_collider(), self) 

func release_grab()->void:
		emit_signal("grab_release", _grabbed_object,self)
		_grabbed_object = null

func move(force: Vector2)-> Vector2:
	apply_central_impulse(force)
	return force

func get_grab_target_pos(pos_to_try: Vector2,for_line_draw:=false)->Vector2:
	var pos:= to_local( position)
	var to_reach_pos:= pos_to_try
	
	if _grabbed_object != null:
		to_reach_pos = to_local(_grabbed_object.position)
	
	var normalized = (to_reach_pos - pos).normalized()
	if for_line_draw:
		return pos + normalized *min(grab_ray_length, min(GRAB_DIST, pos.distance_to(to_reach_pos)) )
	return pos + normalized * min(GRAB_DIST, pos.distance_to(to_reach_pos))


func set_grabbed_object(body: RigidBody2D)->void:
	_grabbed_object = body

