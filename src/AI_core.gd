extends RigidBody2D


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


