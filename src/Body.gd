extends RigidBody2D
class_name Body

onready var Player:= get_node("../Player")

var grab_force_vector:= Vector2.ZERO

var contact_point: Vector2

var grabber: RigidBody2D
var just_released:= false

signal is_grabbed(grabbed, grabber)

func _ready() -> void:
	if Player != null:
		Player.connect("grab_ray_hit",self, "_on_grab_ray_hit")
		Player.connect("grab_release", self, "_on_grab_release")


func _on_grab_ray_hit(collider: Object, emitter: Object)->void:
	if collider == self:
		grabber = emitter
		emit_signal("is_grabbed",self,grabber)

func _on_grab_release(grabbed: RigidBody2D, emitter: RigidBody2D):
	if grabbed == self:
		if grabber != emitter:
			print("Trying to release from wring grabber")
		grabber = null
		just_released = true

func _physics_process(_delta: float) -> void:
	if grabber != null:
		apply_grab(grabber)
	elif just_released:
		apply_central_impulse(Vector2.ZERO)
		just_released = false


func apply_grab(body_to_link: RigidBody2D) -> void:
	if body_to_link != null:
		var pos:= position
		var grab_pos:= body_to_link.position
		grab_force_vector = grab_pos - pos
		apply_central_impulse(grab_force_vector)

