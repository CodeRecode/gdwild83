extends CharacterBody2D
class_name Animal


@export var health: int = 10
@export var restore_health_value: int = 1


var current_status: STATUS = STATUS.HEALTHY


enum STATUS {
	HEALTHY = 1,
	SLOWED = 2,
	POISONED = 3,
	DEAD = 4
}


func take_damage(damage_amount: int, attack_modifier) -> void:
	health -= damage_amount
	print(attack_modifier)
	match  attack_modifier:
		STATUS.HEALTHY:
			current_status = STATUS.HEALTHY
		STATUS.SLOWED:
			current_status = STATUS.SLOWED
		STATUS.POISONED:
			current_status = STATUS.POISONED
		STATUS.DEAD:
			current_status = STATUS.DEAD

	if health <= 0 or current_status == STATUS.DEAD:
		print(name + " died")
		queue_free()
