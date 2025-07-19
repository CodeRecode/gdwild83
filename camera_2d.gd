extends Camera2D


var strength: float = 15.0
var duration: float = 0.05


func _on_player_player_took_damage() -> void:
	var original_position: Vector2 = position
	var shake_offset: Vector2 = Vector2(randf_range(-strength,strength),randf_range(-strength,strength))

	var shake_tween = create_tween().tween_property(self, "position", position + shake_offset, duration)
	await shake_tween.finished
	var return_tween = create_tween().tween_property(self, "position", original_position, duration / 2)


func _on_player_zoom_camera(new_value: float) -> void:
	create_tween().tween_property(self, "zoom", Vector2(new_value, new_value), 1)
