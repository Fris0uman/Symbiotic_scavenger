extends KinematicBody2D
var _speed:= 40
var move_vel: = Vector2.ZERO

var trying_grab:= false
var grab_ray_length:= 40

var grabbed_object: RigidBody2D

var GRAB_DIST:= 40

onready var grab_ray:= $RayCast2D
onready var object:= get_node("../Object")

signal grab_ray_hit(collider, emitter)
signal grab_release(grabbed,grabber)

func _ready() -> void:
	set_process(true)
	if object != null:
		object.connect("is_grabbed",self, "_on_grabbing")

func _process(_delta: float) -> void:
	trying_grab = Input.is_action_pressed("grab")
	if grabbed_object != null && !trying_grab:
		emit_signal("grab_release", grabbed_object,self)
		grabbed_object = null
		
	update()

func _draw() -> void:
	if trying_grab:
		var target = get_grab_target_pos(true)
		draw_line(to_local(position),target,Color.antiquewhite)


func _physics_process(_delta) ->void:
	var direction:= Vector2(Input.get_axis("move_left","move_right"), Input.get_axis("move_up","move_down"))
	move_vel = _speed * direction
	move_vel = move_and_slide(move_vel)
	
	if trying_grab:
		var target = get_grab_target_pos()
		grab_ray.cast_to = target
		var collision_dist:= int( position.distance_to(grab_ray.get_collision_point()))
		grab_ray_length = collision_dist if grab_ray.is_colliding() else GRAB_DIST
		if grab_ray.is_colliding():
			emit_signal("grab_ray_hit", grab_ray.get_collider(), self) 
	if grabbed_object != null:
		pass

func get_grab_target_pos(for_line_draw:=false)->Vector2:
	var pos:= to_local( position)
	var mouse_pos:= get_local_mouse_position()
	
	var normalized = (mouse_pos - pos).normalized()
	if for_line_draw:
		return pos + normalized *min(grab_ray_length, min(GRAB_DIST, pos.distance_to(mouse_pos)) )
	return pos + normalized * min(GRAB_DIST, pos.distance_to(mouse_pos))

func _on_grabbing(grabbed: RigidBody2D, grabber: KinematicBody2D)->void:
	if grabber == self:
		grabbed_object = grabbed
