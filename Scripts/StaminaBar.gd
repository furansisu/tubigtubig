extends ProgressBar
@onready var player = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
    self.value = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
var tick = 0
var spdmultiplier
func _process(delta):
    if tick > 0:
        tick -= delta
        return
    if self.value == 0 and tick <= 0:
        tick = 1
    spdmultiplier = player.spd * 0.33
    if self.value >= 100:
        self.hide()
    else:
        self.show()
    if player.running and player.get_velocity().length() > 10:
        if player.LastPerson:
            updateValue(-delta * 3 * spdmultiplier)
        else:
            updateValue(-delta * 5 * spdmultiplier)
    else:
        updateValue(delta * 10  * spdmultiplier)
    if player.dashing:
        updateValue(10)
        

func updateValue(valueAdded):
    var tween = create_tween()
    tween.tween_property(self, "value", self.value + valueAdded, 0.1)
