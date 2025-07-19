extends CharacterBody2D
class_name Projectile


var player: Player


var damage: int = 0
var projectile_range: float = 0.0
var projectile_velocity: Vector2 = Vector2.ZERO

var previous_position: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0


var target: int = -1


enum TARGET {
	PLAYER = 0,
	ANIMAL = 1
}


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")


func spawn(new_damage: int, new_range: float, new_velocity: Vector2, new_target_type: int) -> void:
	damage = new_damage
	projectile_range = new_range
	projectile_velocity = new_velocity

	previous_position = global_position
	target = clampi(new_target_type, 0, 1)


func _physics_process(delta: float) -> void:
	if distance_traveled > projectile_range:
		queue_free()
		return

	velocity = projectile_velocity * delta
	move_and_slide()

	var distance_moved = global_position.distance_to(previous_position)
	distance_traveled += distance_moved
	previous_position = global_position


func _on_target_detector_body_entered(body: Node2D) -> void:
	match target:
		TARGET.PLAYER:
			if body is Player:
				body.take_damage(damage, 0)
				queue_free()
		TARGET.ANIMAL:
			if body is Animal:
				body.take_damage(damage, 0)

				if body.health <= 0 and player != null:
					player._consume_resources(body)

				queue_free()
