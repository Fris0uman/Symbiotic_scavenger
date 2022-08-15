extends RigidBody2D

var _ressources: Array

onready var depot:= $Ressource_depot
onready var map:= get_node("../Navigation2D/TileMap")

func _ready() -> void:
	place_depot()

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
	if body.is_in_group("Ressource"):
		#Disable collision with Actors
		body.set_collision_layer_bit(0,false)
		body.set_collision_mask_bit(0,false)
		body.set_modulate(Color.dimgray)
