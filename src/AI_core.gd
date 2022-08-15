extends Body

var _ressources: Array

var robot_template:= preload("res://assets/Scenes/Robot.tscn")

onready var depot:= $Ressource_depot
onready var spawner:= $Spawner

onready var world:= get_parent()
onready var map:= get_node("../Navigation2D/TileMap")

func _ready() -> void:
	place_depot()

func _process(_delta: float) -> void:
	if _ressources.size() >=2:
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


func update_ressources_in_depot()->void:
	for body in depot.get_overlapping_bodies():
		if body.is_in_group("Ressource"):
			_ressources.append(body)


#TODO: replace group check with smarter layer management
func _on_Ressource_depot_body_entered(body: RigidBody2D) -> void:
	#TODO: Wait for ressource to be released before counting it
	if body.is_in_group("Ressource"):
		#Disable collision with Actors
		body.set_collision_layer_bit(0,false)
		body.set_collision_mask_bit(0,false)
		
		body.set_modulate(Color.dimgray)
		
		_ressources.append(body)

func make_new_bot()->void:
	var new_robot = robot_template.instance()
	new_robot.position = spawner.global_position
	world.add_child(new_robot)
	world.connect_to_actor(new_robot)
	
	for k in [1,2]:
		_ressources.front().clear_all_grab()
		_ressources.front().queue_free()
		_ressources.pop_front()
		world.total_ressources -=1
