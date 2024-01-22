extends Button
var defaultText = text
var defaultTheme = preload("res://Resources/FONTS/button_theme.tres")


# Called when the node enters the scene tree for the first time.
func _ready():
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if is_hovered():
        if button_pressed:
            text = defaultText + "!"
        else: text = defaultText + "?"
    else:
        text = defaultText
