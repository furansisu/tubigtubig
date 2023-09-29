extends State
class_name Disable

var character : CharacterBody2D

func Enter():
	if not character:
		character = get_parent().get_parent()
	character.Move(Vector2.ZERO, character.defaultspd)
	print(character.name, "'s AI was disabled")

func Exit():
	print(character.name, "'s AI was reenabled")
