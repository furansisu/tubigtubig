extends KinematicBody2D

# Called when the node enters the scene tree for the first time.

var velocity = Vector2.ZERO
var default_acc = 500
var acc = default_acc
var maxspeed = 100
var friction = acc/(maxspeed)
var motion = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	
	# animation handling
	if motion != Vector2.ZERO:
		$AnimationPlayer.play("WalkRight")
		if motion.x <= -0.1:
			$Sprite.flip_h = true
		if motion.x >= 0.1:
			$Sprite.flip_h = false
	else:
		$AnimationPlayer.play("Idle")
	
	# calculation
	velocity += motion * acc * delta
	velocity -= velocity * friction * delta

	
	# moving other bodies
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		collision.collider.move_and_slide(-collision.normal * friction)
		velocity = velocity/2
		
	# run test
	if Input.is_action_pressed("run"):
		acc = default_acc * 1.75
	else:
		acc = default_acc
	
	# actual moving
	move_and_slide(velocity)
	

func move(input):
	motion = input
