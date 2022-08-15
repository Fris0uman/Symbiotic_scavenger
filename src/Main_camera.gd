extends Camera2D

onready var Player:= get_node("../Player")

func _process(_delta):
	position = Player.position
