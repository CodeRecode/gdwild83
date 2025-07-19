extends Node2D

@onready var death_player: AudioStreamPlayer2D = $DeathPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	death_player.play()
