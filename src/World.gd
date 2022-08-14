extends Node


func _ready() -> void:
	connect_to_actors()

func connect_to_actors() ->void:
	var tree = get_tree()
	for body in tree.get_nodes_in_group("Actor"):
		if body.connect("grab_ray_hit",self, "_on_grab_ray_hit") !=0: print("can't connect grab_ray_hit")
		if body.connect("grab_release", self, "_on_grab_release") !=0: print("can't connect grab_release")

func _on_grab_ray_hit(collider: Object, emitter: Object)->void:
	collider.set_grabber(emitter)
	emitter.set_grabbed_object(collider)


func _on_grab_release(grabbed: RigidBody2D, emitter: RigidBody2D):
	grabbed.be_released(emitter)
