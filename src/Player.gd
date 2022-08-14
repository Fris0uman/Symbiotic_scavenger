extends Actor


func _ready() -> void:
	set_process(true)


func _process(_delta: float) -> void:
	trying_grab = Input.is_action_pressed("grab")
	if _grabbed_object != null && Input.is_action_just_pressed("interact"):
		release_grab()
		
	update()

func _draw() -> void:
	if trying_grab || _grabbed_object!= null:
		var target = get_grab_target_pos(get_local_mouse_position(), true)
		draw_line(to_local(position),target,Color.antiquewhite)

func _physics_process(_delta) ->void:
	var direction:= Vector2(Input.get_axis("move_left","move_right"), Input.get_axis("move_up","move_down"))
	move_force = _speed * direction
	move_force = move(move_force)
	
	if trying_grab:
		var target = get_grab_target_pos(get_local_mouse_position())
		grab_ray.cast_to = target
		var collision_dist:= int( position.distance_to(grab_ray.get_collision_point()))
		grab_ray_length = collision_dist if grab_ray.is_colliding() else GRAB_DIST
		if grab_ray.is_colliding() && Input.is_action_pressed("interact"):
			confirm_grab()
	if _grabbed_object != null:
		apply_grab(_grabbed_object)
