extends Body

var ressources_fuel: Array
var ressources_scrap: Array

var robot_template:= preload("res://assets/Scenes/Robot.tscn")

onready var depot:= $Ressource_depot
onready var spawner:= $Spawner

onready var world:= get_parent()
onready var map:= get_node("../TileMap")

func _ready() -> void:
	place_depot()

func _process(_delta: float) -> void:
	if ressources_scrap.size() >=2:
		make_new_bot()

func place_depot()->void:
	# Clear all cells under the depot
	var extents = depot.get_child(1).shape.extents
	var first_cell = map.world_to_map(depot.global_position - extents)
	var last_cell = map.world_to_map(depot.global_position + extents)
	var cells = []
	for x in range(first_cell.x, last_cell.x + 1):
		for y in range(first_cell.y, last_cell.y + 1):
			cells.append(Vector2(x, y))
	for vect in cells:
		map.set_cellv(vect,1)


func sort_ressource(body:Body)->void:
	if body.has_flag("Fuel"):
		ressources_fuel.append(body)
	elif body.has_flag("Scrap"):
		ressources_scrap.append(body)

func update_ressources_in_depot()->void:
	for body in depot.get_overlapping_bodies():
		sort_ressource(body)

func _on_Ressource_depot_body_entered(body: RigidBody2D) -> void:
	#Make robot release the ressource and go back fetching more
	for actor in body.get_grabbers():
		if actor.is_robot():
			actor.release_grab()
			actor.new_path()
	
	# Turn off Preys
	if body.is_in_group("Prey"):
		body.set_process(false)
		body.set_physics_process(false)
	
	#Disable collision with Actors
	body.set_collision_layer_bit(0,false)
	body.set_collision_mask_bit(0,false)
	
	body.set_modulate(Color.dimgray)
	
	sort_ressource(body)

func make_new_bot()->void:
	var new_robot = robot_template.instance()
	new_robot.position = spawner.global_position
	world.add_child(new_robot)
	world.connect_to_actor(new_robot)
	
	for k in [1,2]:
		ressources_scrap.front().clear_all_grab()
		ressources_scrap.front().queue_free()
		ressources_scrap.pop_front()
		world.total_ressources -=1
