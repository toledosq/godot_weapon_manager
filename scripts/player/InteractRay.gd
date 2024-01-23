extends RayCast3D


var colliding := false


# Physics process since checking collision
func _physics_process(_delta):
	if not colliding:
		if is_colliding():
			colliding = true
			EventBus.interact_ray_colliding.emit()
	else:
		if not is_colliding():
			colliding = false
			EventBus.interact_ray_stopped_colliding.emit()
	
	if Input.is_action_just_pressed("interact"):
		interact()


func interact() -> void:
	print("InteractRay: Interact called")
	if colliding:
		var interact_object = get_collider()
		if interact_object.has_method("interact"):
			print("Player: Calling interact on %s" % interact_object.name)
			interact_object.interact()
