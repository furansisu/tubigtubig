extends ProgressBar
@onready var player = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
var tick = 0
var spdmultiplier
func _process(delta):
	if tick > 0:
		tick -= delta
		return
	if self.value == 0 and tick <= 0:
		tick = 1.5
	spdmultiplier = player.spd * 0.33
	if self.value >= 100:
		self.hide()
	else:
		self.show()
	if player.running and player.get_velocity().length() > 10:
		updateValue(-delta * 10 * spdmultiplier)
	else:
		updateValue(delta * 5  * spdmultiplier)
	if player.dashing:
		updateValue(-100)
		

func updateValue(valueAdded):
	var tween = create_tween()
	tween.tween_property(self, "value", self.value + valueAdded, 0.1)
