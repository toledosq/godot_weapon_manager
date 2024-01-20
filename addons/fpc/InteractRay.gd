extends RayCast3D


var colliding := false


func _physics_process(_delta):
	if not colliding:
		if is_colliding():
			colliding = true
			EventBus.interact_ray_colliding.emit()
	else:
		if not is_colliding():
			colliding = false
			EventBus.interact_ray_stopped_colliding.emit()
