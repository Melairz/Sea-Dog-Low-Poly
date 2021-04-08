extends Camera

const DISTANCE =8.0
const HEIGHT = 4.0


func _ready():
	set_as_toplevel(true)

func _process(delta):
	var target = get_parent().get_global_transform().origin
	var current_position = get_global_transform().origin
	
	var offset = current_position -target
	offset =offset.normalized() * DISTANCE
	offset.y = HEIGHT
	
	current_position =target+offset
	
	look_at_from_position(current_position,target,Vector3.UP)
