extends Body

var _speed:= 80
var move_force: = Vector2.ZERO

var trying_grab:= false
var grab_ray_length:= 40

var _grabbed_object: RigidBody2D

var GRAB_DIST:= 40

onready var grab_ray:= $RayCast2D

signal grab_ray_hit(collider, emitter)
signal grab_release(grabbed,grabber)

func _ready() -> void:
	set_process(true)


func _process(_delta: float) -> void:
	trying_grab = Input.is_action_pressed("grab")
	if _grabbed_object != null && Input.is_action_just_pressed("interact"):
		emit_signal("grab_release", _grabbed_object,self)
		_grabbed_object = null
		
	update()

func _draw() -> void:
	if trying_grab || _grabbed_object!= null:
		var target = get_grab_target_pos(true)
		draw_line(to_local(position),target,Color.antiquewhite)


func _physics_process(_delta) ->void:
	var direction:= Vector2(Input.get_axis("move_left","move_right"), Input.get_axis("move_up","move_down"))
	move_force = _speed * direction
	move_force = move(move_force)
	
	if trying_grab:
		var target = get_grab_target_pos()
		grab_ray.cast_to = target
		var collision_dist:= int( position.distance_to(grab_ray.get_collision_point()))
		grab_ray_length = collision_dist if grab_ray.is_colliding() else GRAB_DIST
		if grab_ray.is_colliding() && Input.is_action_pressed("interact"):
			emit_signal("grab_ray_hit", grab_ray.get_collider(), self) 
	if _grabbed_object != null:
		apply_grab(_grabbed_object)

func move(force: Vector2)-> Vector2:
	apply_central_impulse(force)
	return force

func get_grab_target_pos(for_line_draw:=false)->Vector2:
	var pos:= to_local( position)
	var mouse_pos:= get_local_mouse_position()
	var to_reach_pos:= mouse_pos
	
	if _grabbed_object != null:
		to_reach_pos = to_local(_grabbed_object.position)
	
	var normalized = (to_reach_pos - pos).normalized()
	if for_line_draw:
		return pos + normalized *min(grab_ray_length, min(GRAB_DIST, pos.distance_to(to_reach_pos)) )
	return pos + normalized * min(GRAB_DIST, pos.distance_to(to_reach_pos))


func set_grabbed_object(body: RigidBody2D)->void:
	_grabbed_object = body
