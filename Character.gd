extends CharacterBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Hello bro")

var velocity = Vector2.ZERO
var default_acc = 500
var acc = default_acc
var maxspeed = 100
var friction = acc/(maxspeed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		$AnimationTree.get("parameters/playback").travel("Walk")
		if input_vector.x <= -0.1:
			$Sprite2D.flip_h = true
		if input_vector.x >= 0.1:
			$Sprite2D.flip_h = false
			
	else:
		$AnimationTree.get("parameters/playback").travel("Idle")
	
	velocity += input_vector * acc * delta
	velocity -= velocity * friction * delta
	
	if Input.is_action_pressed("run"):
		acc = default_acc * 1.75
	else:
		acc = default_acc
	
	set_velocity(velocity)
	move_and_slide()
