extends Node2D

export var Main_scene: PackedScene

func _on_Button_pressed() -> void:
	get_tree().change_scene(Main_scene.resource_path)
