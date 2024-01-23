extends PopupPanel


func _ready():
	print("PopupPanel: Ready")


func _on_close_requested():
	print("PopupPanel: Close requested")
	queue_free()


func _on_tree_exited():
	print("PopupPanel: Exited tree")
