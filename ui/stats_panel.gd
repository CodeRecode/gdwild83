extends PanelContainer

@onready var dna_value: Label = $MarginContainer/GridContainer/DNAValue
@onready var health_value: Label = $MarginContainer/GridContainer/HealthValue

func _on_player_dna_modified(new_value: int) -> void:
	dna_value.text = str(new_value)


func _on_player_health_modified(new_value: float) -> void:
	health_value.text = str(int(floor(new_value)))


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
