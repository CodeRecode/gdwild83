extends Animal
class_name Beetle


@export var instance_health: int = 10
@export var restore_health_value: int = 1


@export var dna_awarded: int = 15


@export var attack_power: int = 2
@export var attack_delay: float = 1.0
var attacking: bool = false

@export var speed: float = 4000.0
var collided: bool = false
var collision_normal: Vector2 = Vector2.ZERO
var previously_collided: bool = false


@onready var sight_detector: Area2D = $SightDetection
var looking_for_player: bool = false
var player_in_range: bool = false


var current_state: STATE = STATE.IDLE
var min_time: float = 1.0
var max_time: float = 3.0
var state_time: float
var can_transition: bool = true

func _ready() -> void:
	super._ready()
	health = instance_health

func _physics_process(delta: float) -> void:
	run_state_machine(delta)
	collided = move_and_slide()

	_idle_upon_obstacle_collision()
	_flee_upon_player_sighted()
	_caught_up_to_player()
	_attack_if_attacked()


func run_state_machine(delta: float) -> void:
	if not can_transition: return

	match current_state:
		STATE.IDLE:
			_idle_state()
		STATE.WANDER:
			_wander_state(delta)
		STATE.FLEE:
			_flee_state(delta)
		STATE.LOOK:
			_look_state()
		STATE.ATTACK:
			_attack_state()
		STATE.CHASE:
			_chase_state(delta)


func _idle_upon_obstacle_collision() -> void:
	if collided and velocity != Vector2.ZERO:
		velocity = Vector2.ZERO
		current_state = STATE.IDLE
		_idle_state()

		previously_collided = true
		collision_normal = get_last_slide_collision().get_normal()
		collided = false


func _flee_upon_player_sighted() -> void:
	if current_state != STATE.FLEE and player_sighted and health <= 3:
		current_state = STATE.FLEE
		_flee_state(get_physics_process_delta_time())


func _attack_if_attacked() -> void:
	if current_state != STATE.ATTACK and player_attacked_me and player_in_range:
		current_state = STATE.ATTACK
		_attack_state()


func _caught_up_to_player() -> void:
	if current_state == STATE.CHASE and player_in_range:
		current_state = STATE.ATTACK
		_attack_state()


func _idle_state() -> void:
	can_transition = false
	velocity = Vector2.ZERO

	state_time = randf_range(min_time,max_time)
	await get_tree().create_timer(state_time).timeout

	if player_sighted and health <= 3:
		current_state = STATE.FLEE
	elif player_attacked_me and health > 3:
		current_state = STATE.CHASE
	elif player_attacked_me and player_in_range:
		current_state = STATE.ATTACK
	else:
		current_state = STATE.WANDER

	can_transition = true


func _wander_state(delta: float) -> void:
	can_transition = false

	if previously_collided:
		var angle_offset: float = randf_range(deg_to_rad(-30),deg_to_rad(30))
		var move_vector: Vector2 =  collision_normal.rotated(angle_offset)
		velocity = move_vector * speed * delta

		sight_detector.rotation = move_vector.angle()

		previously_collided = false
		collision_normal = Vector2.ZERO
	else:
		var look_vector: Vector2 = Vector2.RIGHT.rotated(randf_range(0,TAU))
		velocity = look_vector * speed * delta

		sight_detector.rotation = look_vector.angle()

	state_time = randf_range(min_time,max_time)
	await get_tree().create_timer(state_time).timeout

	if player_sighted and health <= 3:
		current_state = STATE.FLEE

	elif current_state != STATE.IDLE and not player_attacked_me:
		velocity = Vector2.ZERO
		current_state = STATE.IDLE
	elif player_attacked_me and health > 3 and not player_in_range:
		current_state = STATE.CHASE
	elif player_in_range:
		current_state = STATE.ATTACK
	else:
		velocity = Vector2.ZERO

	can_transition = true


func _flee_state(delta: float) -> void:
	can_transition = false

	var flee_vector: Vector2 = (position - player.position).normalized()
	velocity = flee_vector * speed * delta

	sight_detector.rotation = flee_vector.angle()

	state_time = randf_range(min_time,max_time)
	await get_tree().create_timer(state_time).timeout

	player_sighted = false
	current_state = STATE.LOOK

	can_transition = true


func _look_state() -> void:
	if not can_transition: return
	if looking_for_player == true: return

	can_transition = false
	looking_for_player = true

	var facing_direction = velocity.normalized()
	sight_detector.rotation = get_angle_to(player.position)
	velocity = Vector2.ZERO

	var random_look_time: float = randf_range(0.3,1.0)
	await get_tree().create_timer(random_look_time).timeout

	if current_state != STATE.LOOK:
		looking_for_player = false
		return

	if looking_for_player:
		sight_detector.rotation = facing_direction.angle()

	random_look_time = randf_range(0.3,1.0)
	await get_tree().create_timer(random_look_time).timeout

	if current_state != STATE.LOOK:
		looking_for_player = false
		return

	if looking_for_player:
		sight_detector.rotation = Vector2(-facing_direction.x,facing_direction.y).angle()

	if player_sighted and not current_state == STATE.FLEE and health <= 3:
		current_state = STATE.FLEE
		can_transition = true
	elif current_state != STATE.IDLE and not current_state == STATE.FLEE:
		velocity = Vector2.ZERO
		current_state = STATE.IDLE

	looking_for_player = false
	can_transition = true


func _attack_state() -> void:
	if attacking: return
	can_transition = false

	if not attacking:
		player.take_damage(attack_power, 0)
		attacking = true

		var player_direction = (animated_sprite_2d.position - player.position).normalized() * 15
		var original_position = animated_sprite_2d.position
		var tween = create_tween().tween_property(animated_sprite_2d, "position", original_position + player_direction, 0.075)
		await tween.finished
		create_tween().tween_property(animated_sprite_2d, "position", original_position, 0.05)

	await get_tree().create_timer(attack_delay - 0.075).timeout

	attacking = false

	if player_in_range and health > 3: #run away if low health
		current_state = STATE.ATTACK
	elif health <= 3:
		current_state = STATE.FLEE
	elif not player_in_range and health > 3:
		current_state = STATE.CHASE
	else:
		current_state = STATE.LOOK

	can_transition = true


func _chase_state(delta: float) -> void:
	can_transition = false

	var chase_vector: Vector2 = (player.position - position).normalized()
	velocity = chase_vector * speed * delta

	await get_tree().create_timer(2).timeout

	if player_in_range:
		current_state = STATE.ATTACK
	elif not player_in_range and player_attacked_me and health > 3:
		current_state = STATE.CHASE
	else:
		current_state = STATE.LOOK


	can_transition = true


func respond_to_damage():
	if health <= 3: _flee_upon_player_sighted()
	else: _attack_if_attacked()


func _on_sight_detection_body_entered(node: Node) -> void:
	if node is not Player:
		return
	player_sighted = true
	if player == null:
		player = node


#func _on_sight_detection_body_exited(player: Player) -> void:
	#player_sighted = false


func _on_attack_range_area_2d_body_entered(node2D: Node2D) -> void:
	if node2D is Player:
		player_in_range = true


func _on_attack_range_area_2d_body_exited(node2D: Node2D) -> void:
	if node2D is Player:
		player_in_range = false
