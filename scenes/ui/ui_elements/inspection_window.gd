extends Window


func _ready():
	print("InspectWindow: Ready")


func _on_close_requested():
	print("InspectWindow: Close requested")
	queue_free()


func _on_tree_exited():
	print("InspectWindow: Exited tree")
