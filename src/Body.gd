extends RigidBody2D
class_name Body

var _grabber: RigidBody2D

var grab_force_vector:= Vector2.ZERO

var contact_point: Vector2

var just_released:= false


func _physics_process(_delta: float) -> void:
	if _grabber != null:
		apply_grab(_grabber)
	elif just_released:
		apply_central_impulse(Vector2.ZERO)
		just_released = false

func apply_grab(body_to_link: RigidBody2D) -> void:
	if body_to_link != null:
		var pos:= position
		var grab_pos:= body_to_link.position
		grab_force_vector = grab_pos - pos
		apply_central_impulse(grab_force_vector)

func set_grabber(body: RigidBody2D) ->void:
	_grabber = body

func be_released(released_by: RigidBody2D) ->void:
	if released_by != _grabber:
		print("Trying to release from wrong grabber")
	set_grabber(null)
	just_released = true
