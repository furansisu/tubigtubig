extends Node

@export var initial_state : State
@onready var AreaHandler = get_node("/root/World/PlayingAreas")

var character : CharacterBody2D

var current_state : State
var states : Dictionary = {}

func _ready():
	character = get_parent()
	character.Selected.connect(onSelect)
	character.targetArea = AreaHandler.setStartingArea()
	var nextArea = AreaHandler.getNextAreaOfCharacter(character)
	character.nextScoreArea = [nextArea, nextArea.side_area]
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.Transitioned.connect(on_child_transition)
				
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
				
func _process(delta):
	if current_state:
		current_state.Update(delta)
		
func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)
		
func on_child_transition(state, new_state_name):
	print(character.name, " has transitioned from ", state.name, " to ", new_state_name)
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name)
	if not new_state:
		return
	
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	current_state = new_state
	
func onSelect(selectedBool):
	if selectedBool == true:
		on_child_transition(current_state, "Disable")
	else:
		on_child_transition(current_state, "Strafe") # create function to check what state I'm supposed to be in?
