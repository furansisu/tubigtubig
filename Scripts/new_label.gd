extends Label
class_name NodeLabel

var tween_info = {
	property = "global_position",
	easing = Tween.TRANS_QUAD,
	shouldYield = false,
}

func tween_to_position(position: Vector2, length: float) -> Tween:
	var tween = Tween.new()
	tween.tween_property(self, tween_info.property, position, length).set_trans(tween_info.easing)
	tween.play()
	if tween_info.shouldYield:
		await tween.finished
	return tween
