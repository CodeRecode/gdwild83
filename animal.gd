extends CharacterBody2D
class_name Animal


@export var health: int = 10
@export var restore_health_value: int = 1


@export var dna_awarded: int = 15


@export var speed: float = 4000.0
var collided: bool = false
var collision_normal: Vector2 = Vector2.ZERO
var previously_collided: bool = false


var current_status: STATUS = STATUS.HEALTHY


enum STATUS {
	HEALTHY = 1,
	SLOWED = 2,
	POISONED = 3,
	DEAD = 4
}


var current_state: STATE = STATE.IDLE
var min_time: float = 1.0
var max_time: float = 3.0
var state_time: float
var can_transition: bool = true


enum STATE {
	IDLE,
	WANDER
}


func _physics_process(delta: float) -> void:
	run_state_machine(delta)
	collided = move_and_slide()

	if collided and velocity != Vector2.ZERO:
		velocity = Vector2.ZERO
		current_state = STATE.IDLE
		_idle_state()

		previously_collided = true
		collision_normal = get_last_slide_collision().get_normal()
		collided = false

func run_state_machine(delta: float) -> void:
	if not can_transition: return

	match current_state:
		STATE.IDLE:
			_idle_state()
		STATE.WANDER:
			_wander_state(delta)


func _idle_state() -> void:
	can_transition = false
	velocity = Vector2.ZERO

	state_time = randf_range(min_time,max_time)
	await get_tree().create_timer(state_time).timeout

	current_state = STATE.WANDER
	can_transition = true


func _wander_state(delta: float) -> void:
	can_transition = false

	if previously_collided:
		var angle_offset: float = randf_range(deg_to_rad(-30),deg_to_rad(30))
		var move_away_vector: Vector2 =  collision_normal.rotated(angle_offset)
		velocity = move_away_vector * speed * delta

		previously_collided = false
		collision_normal = Vector2.ZERO
	else:
		velocity = Vector2.UP.rotated(randf_range(0,TAU)) * speed * delta

	state_time = randf_range(min_time,max_time)
	await get_tree().create_timer(state_time).timeout

	if current_state != STATE.IDLE:
		velocity = Vector2.ZERO
		current_state = STATE.IDLE
		can_transition = true
	else:
		velocity = Vector2.ZERO


func take_damage(damage_amount: int, attack_modifier) -> void:
	health -= damage_amount

	match  attack_modifier:
		STATUS.HEALTHY:
			current_status = STATUS.HEALTHY
		STATUS.SLOWED:
			current_status = STATUS.SLOWED
		STATUS.POISONED:
			current_status = STATUS.POISONED
		STATUS.DEAD:
			current_status = STATUS.DEAD

	if health <= 0:
		current_status = STATUS.DEAD

	if current_status == STATUS.DEAD:
		queue_free.call_deferred()
