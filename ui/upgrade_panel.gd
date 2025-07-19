extends PanelContainer

@onready var upgrade_1_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/Upgrade1Button
@onready var upgrade_2_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/Upgrade2Button
@onready var evolution_player: AudioStreamPlayer = $EvolutionPlayer

signal evolution_chosen(choice: int)

func _ready() -> void:
	hide()

func _on_player_evolution_triggered(name1: String, name2: String) -> void:
	upgrade_1_button.text = name1
	upgrade_2_button.text = name2
	show()
	evolution_player.play()
	get_tree().paused = true


func _on_upgrade_1_button_pressed() -> void:
	_choose(1)

func _on_upgrade_2_button_pressed() -> void:
	_choose(2)

func _choose(choice: int) -> void:
	get_tree().paused = false
	evolution_chosen.emit(choice)
	hide()
	evolution_player.stop()
