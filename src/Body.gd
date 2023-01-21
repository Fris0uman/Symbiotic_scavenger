extends RigidBody2D
class_name Body

var _grabbers: Array

var grab_force_vector:= Vector2.ZERO

var contact_point: Vector2

export var _body_size:= 20
export var _flags: Array

func _physics_process(_delta: float) -> void:
	apply_all_grabs()

func apply_all_grabs() ->void:
	for body in _grabbers:
		apply_grab(body)

func apply_grab(body_to_link: RigidBody2D) -> void:
	if body_to_link != null:
		var pos:= position
		var grab_pos:= body_to_link.position
		grab_force_vector = grab_pos - pos
		apply_central_impulse(grab_force_vector)

func add_grabber(body: RigidBody2D) ->void:
	_grabbers.append(body)

func be_released(released_by: RigidBody2D) ->void:
	var index:= _grabbers.find(released_by)
	if index == -1:
		print("%s trying to release from wrong grabber %s" % [name, released_by.name])
	else:
		_grabbers.remove(index)

func clear_all_grab()->void:
	for grabber in _grabbers:
		grabber.release_grab()

func get_body_size()->int:
	return _body_size

func is_grabbed()->bool:
	return !_grabbers.empty()

func get_grabbers()->Array:
	return _grabbers

func has_flag(flag: String)->bool:
	return _flags.has(flag)
