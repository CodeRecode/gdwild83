extends Animal
class_name Narrator

@export var instance_health: int = 5
@export var speed: float = 7000.0

var restore_health_value: int = 100
var dna_awarded: int = 10000

var can_be_attacked: bool = false
var flee_vector: Vector2 = Vector2.ZERO

signal narrator_died()


func _ready() -> void:
	super._ready()
	health = instance_health


func _physics_process(delta: float) -> void:
	if can_be_attacked and player_sighted:
		_flee(delta)
		move_and_slide()


#temporary override
func take_damage(damage_amount: int, attack_modifier) -> void:
	if not can_be_attacked:
		return

	hit_fx_player.play()
	health -= damage_amount

	if health <= 0:
		narrator_died.emit()
	else:
		# Additive color, set factor 0-1 to increase/decrease the redness
		var red_factor = .2
		var original_scale = animated_sprite_2d.scale
		var tween_in_time = .05
		var tween_out_time = .15

		var tween = create_tween().tween_property(animated_sprite_2d, "material:shader_parameter/hit_color", Color.RED * red_factor, tween_in_time)
		create_tween().tween_property(animated_sprite_2d, "scale", original_scale * Vector2(0.8,1.2),tween_in_time)

		await tween.finished

		create_tween().tween_property(animated_sprite_2d, "material:shader_parameter/hit_color", Color.BLACK, tween_out_time)
		create_tween().tween_property( animated_sprite_2d, "scale", original_scale,tween_out_time)

func _on_story_controller_narrator_vulnerable() -> void:
	can_be_attacked = true


func _flee(delta: float) -> void:
	flee_vector = (position - player.position).normalized()
	velocity = flee_vector * speed * delta


func _on_sight_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		player_sighted = true


func _on_sight_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		player_sighted = false
