extends CharacterBody2D

# Called when the node enters the scene tree for the first time.

@export var default_acc = 1500
var acc = default_acc
@export var maxspeed = 100
@export var selection = 0
@export var selected = false
var friction = (acc/maxspeed)

@export var target = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	
	# animation handling
	if (direction != Vector2.ZERO or velocity > Vector2.ZERO) and selected == true:
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
		acc = default_acc * 1.75
	else:
		acc = default_acc
	
	# actual moving
	
	if selected == true:
		move_and_slide()
	
	# POSITION MOVEMENT TEST	
	if target != Vector2.ZERO and selected == true:
		velocity = position.direction_to(target) * maxspeed
		
		if position.distance_to(target) > 10:
			move_and_slide()
		else:
			target = Vector2.ZERO
			
func _input(event):
	if event.is_action_pressed("click"):
		target = get_global_mouse_position()
