extends CharacterBody2D
class_name Animal

var health: int = 5
#@export var restore_health_value: int = 1
#
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var hit_fx_player: AudioStreamPlayer2D = $HitFxPlayer
var remains = preload("res://animals/remains.tscn")

var player: Player = null
var player_attacked_me: bool = false
var player_sighted: bool = false
#
#
#@export var dna_awarded: int = 15
#
#
#@export var speed: float = 4000.0
#var collided: bool = false
#var collision_normal: Vector2 = Vector2.ZERO
#var previously_collided: bool = false
#
#@onready var sight_detector: Area2D = $SightDetection
#var player_sighted: bool = false
#
#
var current_status: STATUS = STATUS.HEALTHY
#
#
enum STATUS {
	HEALTHY = 1,
	SLOWED = 2,
	POISONED = 3,
	DEAD = 4
}
#
#
#var current_state: STATE = STATE.IDLE
#var min_time: float = 1.0
#var max_time: float = 3.0
#var state_time: float
#var can_transition: bool = true
#
#

enum STATE {
	IDLE,
	WANDER,
	FLEE,
	LOOK,
	CHASE,
	ATTACK
}
#
func _ready() -> void:
	animated_sprite_2d.play()
	player = get_tree().get_first_node_in_group("Player")

func take_damage(damage_amount: int, attack_modifier) -> void:
	player_attacked_me = true
	health -= damage_amount
	hit_fx_player.play()

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
		_die()

	player_sighted = true

func _die():
	var instance = remains.instantiate()
	instance.global_position = global_position
	get_tree().root.add_child(instance)
	queue_free.call_deferred()
	

#abstract func
func _respond_to_damage():
	pass

#func _physics_process(delta: float) -> void:
	#run_state_machine(delta)
	#collided = move_and_slide()
#
	#_idle_upon_obstacle_collision()
	#_flee_upon_player_sighted()
#
#
#func run_state_machine(delta: float) -> void:
	#if not can_transition: return
#
	#match current_state:
		#STATE.IDLE:
			#_idle_state()
		#STATE.WANDER:
			#_wander_state(delta)
		#STATE.FLEE:
			#_flee_state(delta)
		#STATE.LOOK:
			#_look_state()
#
#
#func _idle_upon_obstacle_collision() -> void:
	#if collided and velocity != Vector2.ZERO:
		#velocity = Vector2.ZERO
		#current_state = STATE.IDLE
		#_idle_state()
#
		#previously_collided = true
		#collision_normal = get_last_slide_collision().get_normal()
		#collided = false
#
#
#func _flee_upon_player_sighted() -> void:
	#if current_state != STATE.FLEE and player_sighted:
		#current_state = STATE.FLEE
		#_flee_state(get_physics_process_delta_time())
#
#
#func _idle_state() -> void:
	#can_transition = false
	#velocity = Vector2.ZERO
#
	#state_time = randf_range(min_time,max_time)
	#await get_tree().create_timer(state_time).timeout
#
	#if player_sighted:
		#current_state = STATE.FLEE
	#else:
		#current_state = STATE.WANDER
#
	#can_transition = true
#
#
#func _wander_state(delta: float) -> void:
	#can_transition = false
#
	#if previously_collided:
		#var angle_offset: float = randf_range(deg_to_rad(-30),deg_to_rad(30))
		#var move_vector: Vector2 =  collision_normal.rotated(angle_offset)
		#velocity = move_vector * speed * delta
#
		#sight_detector.rotation = move_vector.angle()
#
		#previously_collided = false
		#collision_normal = Vector2.ZERO
	#else:
		#var look_vector: Vector2 = Vector2.RIGHT.rotated(randf_range(0,TAU))
		#velocity = look_vector * speed * delta
#
		#sight_detector.rotation = look_vector.angle()
#
	#state_time = randf_range(min_time,max_time)
	#await get_tree().create_timer(state_time).timeout
#
	#if player_sighted:
		#current_state = STATE.FLEE
		#can_transition = true
	#elif current_state != STATE.IDLE:
		#velocity = Vector2.ZERO
		#current_state = STATE.IDLE
		#can_transition = true
	#else:
		#velocity = Vector2.ZERO
#
#
#func _flee_state(delta: float) -> void:
	#can_transition = false
#
	#var flee_vector: Vector2 = (position - player.position).normalized()
	#velocity = flee_vector * speed * delta
#
	#sight_detector.rotation = flee_vector.angle()
#
	#state_time = randf_range(min_time,max_time)
	#await get_tree().create_timer(state_time).timeout
#
	#player_sighted = false
	#current_state = STATE.LOOK
#
	#can_transition = true
#
#
#func _look_state() -> void:
	#if not can_transition: return
	#can_transition = false
#
	#var facing_direction = velocity.normalized()
	#sight_detector.rotation = get_angle_to(player.position)
	#velocity = Vector2.ZERO
#
	#var random_look_time: float = randf_range(0.3,1.0)
	#await get_tree().create_timer(random_look_time).timeout
#
	#if current_state == STATE.FLEE: return
#
	#sight_detector.rotation = facing_direction.angle()
#
	#random_look_time = randf_range(0.3,1.0)
	#await get_tree().create_timer(random_look_time).timeout
#
	#if current_state == STATE.FLEE: return
#
	#sight_detector.rotation = Vector2(-facing_direction.x,facing_direction.y).angle()
#
	#if player_sighted and not current_state == STATE.FLEE:
		#current_state = STATE.FLEE
		#can_transition = true
	#elif current_state != STATE.IDLE and not current_state == STATE.FLEE:
		#velocity = Vector2.ZERO
		#current_state = STATE.IDLE
		#can_transition = true
#
#
#func take_damage(damage_amount: int, attack_modifier) -> void:
	#health -= damage_amount
#
	#match  attack_modifier:
		#STATUS.HEALTHY:
			#current_status = STATUS.HEALTHY
		#STATUS.SLOWED:
			#current_status = STATUS.SLOWED
		#STATUS.POISONED:
			#current_status = STATUS.POISONED
		#STATUS.DEAD:
			#current_status = STATUS.DEAD
#
	#if health <= 0:
		#current_status = STATUS.DEAD
#
	#if current_status == STATUS.DEAD:
		#queue_free.call_deferred()
#
	#player_sighted = true
	#_flee_upon_player_sighted()
#
#
#func _on_sight_detection_body_entered(node: Node) -> void:
	#if node is not Player:
		#return
	#player_sighted = true
	#if player == null:
		#player = node
#
#
##func _on_sight_detection_body_exited(player: Player) -> void:
	##player_sighted = false
