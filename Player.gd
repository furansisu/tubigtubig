extends CharacterBody2D

# Called when the node enters the scene tree for the first time.

var velocity1 = Vector2.ZERO
@export var default_acc = 1500
var acc = default_acc
@export var maxspeed = 200
@export var selection = 0
var friction = (acc/maxspeed) * 2.5
var motion = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	# animation handling
	if motion != Vector2.ZERO:
		if Input.is_action_pressed("run"):
			$AnimationPlayer.play("Run")
		else:
			$AnimationPlayer.play("WalkRight")
		if motion.x <= -0.1:
			$Sprite2D.flip_h = true
		if motion.x >= 0.1:
			$Sprite2D.flip_h = false
	else:
		$AnimationPlayer.play("Idle")
	
	# calculation
	velocity1 += motion * acc * delta
	velocity1 -= velocity1 * friction * delta
	
	# moving other bodies
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		if collider is CharacterBody2D:
			collider.set_velocity(-normal * friction)
			collider.move_and_slide()
			velocity1 = velocity1/2
		
	# run test
	if Input.is_action_pressed("run"):
		acc = default_acc * 1.75
	else:
		acc = default_acc
	
	# actual moving
	set_velocity(velocity1)
	move_and_slide()
	
	if !selection == get_owner().currnumchar:
		motion = Vector2.ZERO

func move(input):
	motion = input
