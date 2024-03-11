extends Node

var preloaded_label = preload("res://Scenes/new_label.tscn")

func new_label(parent, position: Vector2, size: Vector2, text: String) -> Label:
    var newLabel: Label = preloaded_label.instantiate()
    if parent and parent.has_method("add_child"):
        parent.add_child(newLabel)
    if position:
        newLabel.position = position
    if size:
        newLabel.size = size
    if text:
        newLabel.text = text
    return newLabel
