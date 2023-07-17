extends CharacterBody2D

# Called when the node enters the scene tree for the first time.

@export var default_acc = 350
var acc = default_acc
@export var maxspeed = 75
@export var selection = 0
@export var selected = false
var friction = (acc/maxspeed)

var direction = Vector2.ZERO
@export var target_position = position
@export var target_position_reached = true

func MoveTo(Position: Vector2):
	if position.distance_to(Position) < 1 or direction.length() > .1:
		return true
	else:
		direction = position.direction_to(Position)
		return false

func _input(event):
	if event.is_action_pressed("click"):
		target_position_reached = false
	if event.is_action_released("click"):
		target_position_reached = true

func _physics_process(delta):
	direction = Input.get_vector("left", "right", "up", "down")
	if not target_position_reached:
		target_position = get_global_mouse_position()
		target_position_reached = MoveTo(target_position)
	
	# animation handling
	if (direction != Vector2.ZERO and (velocity > Vector2.ZERO or velocity < Vector2.ZERO)) and selected == true:
		if Input.is_action_pressed("run"):
			$AnimationPlayer.play("Run")
		else:
			$AnimationPlayer.play("WalkRight")
		if direction.x < 0:
			$Sprite2D.flip_h = true
		if direction.x > 0:
			$Sprite2D.flip_h = false
	else:
		$AnimationPlayer.play("Idle")
	
	velocity += direction * acc * delta
	velocity -= velocity * friction * delta
		
	# run test
	if Input.is_action_pressed("run"):
		acc = default_acc * 1.5
	else:
		acc = default_acc
	
	# actual moving
	
	if selected == true:
		move_and_slide()
	
