extends CharacterBody2D

# Called when the node enters the scene tree for the first time.

@export var default_acc = 1500
var acc = default_acc
@export var maxspeed = 100
@export var selection = 0
@export var selected = false
var friction = (acc/maxspeed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	print(direction.x)
	
	# animation handling
	if direction != Vector2.ZERO and selected == true:
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
	
	# moving other bodies
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		if collider is CharacterBody2D:
			collider.set_velocity(-normal * friction)
			collider.move_and_slide()
			velocity = velocity/2
		
	# run test
	if Input.is_action_pressed("run"):
		acc = default_acc * 1.75
	else:
		acc = default_acc
	
	# actual moving
	
	if selected == true:
		move_and_slide()
