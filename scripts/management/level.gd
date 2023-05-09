extends Node2D
class_name Level

@onready var player:CharacterBody2D = get_node("Player")

func _ready() -> void:
	player.get_node("Texture").connect("game_over",on_game_over)
	

func on_game_over() -> void:
	get_tree().reload_current_scene()
