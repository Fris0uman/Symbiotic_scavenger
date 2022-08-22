extends Node

var total_ressources: =0

var MAX_RESSOURCES:= 10000

var MIN_Y: = -2816.0
var MAX_Y: = 3584.0
var MIN_X: = -2752.0
var MAX_X: = 6400.0

export var ressource_template: PackedScene

onready var timer:= $Timer

func _ready() -> void:
	connect_to_actors()
	for _k in range(0,1000):
		_add_ressource()

func connect_to_actors() ->void:
	var tree = get_tree()
	for body in tree.get_nodes_in_group("Actor"):
		if body.connect("grab_ray_hit",self, "_on_grab_ray_hit") !=0: print("can't connect grab_ray_hit")
		if body.connect("grab_release", self, "_on_grab_release") !=0: print("can't connect grab_release")

func connect_to_actor(body: Actor)->void:
	if body.connect("grab_ray_hit",self, "_on_grab_ray_hit") !=0: print("can't connect grab_ray_hit")
	if body.connect("grab_release", self, "_on_grab_release") !=0: print("can't connect grab_release")


func _on_grab_ray_hit(collider: Object, emitter: Object)->void:
	if !collider.is_class("RigidBody2D"):
		print("%s tried to grab a non body %s" % [emitter.name, collider.name])
		print("Check that collision layers are correct, layer 3 is for grabbing only")
		return
	collider.add_grabber(emitter)
	emitter.set_grabbed_object(collider)


func _on_grab_release(grabbed: RigidBody2D, emitter: RigidBody2D):
	grabbed.be_released(emitter)

func _add_ressource()-> void:
	var new_ressource = ressource_template.instance()
	var rand_x = rand_range(MIN_X,MAX_X)
	var rand_Y = rand_range(MIN_Y,MAX_Y)
	new_ressource.position =  Vector2(rand_x,rand_Y)
	add_child(new_ressource)
	total_ressources+=1

func _on_Timer_timeout() -> void:
	if total_ressources < MAX_RESSOURCES:
		_add_ressource()
		print(total_ressources)
	timer.start(20)

