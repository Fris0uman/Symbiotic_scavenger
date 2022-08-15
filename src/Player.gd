extends Actor


func _ready() -> void:
	set_process(true)


func _process(_delta: float) -> void:
	trying_grab = Input.is_action_pressed("grab")
	if _grabbed_object != null && Input.is_action_just_pressed("cancel"):
		release_grab()
		
	update()

func _draw() -> void:
	if trying_grab || _grabbed_object!= null:
		var target = get_grab_target_pos(get_global_mouse_position(), true)
		draw_line(to_local(position),target,Color.antiquewhite)

func _physics_process(_delta) ->void:
	var direction:= Vector2(Input.get_axis("move_left","move_right"), Input.get_axis("move_up","move_down"))
	move_force = _speed * direction
	move_force = move(move_force)
	
	if trying_grab:
		if try_grab(get_global_mouse_position()) && Input.is_action_just_pressed("interact"):
			confirm_grab()

