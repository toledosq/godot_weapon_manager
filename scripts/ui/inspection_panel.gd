class_name InspectionPanel extends PanelContainer


func _on_button_pressed():
	print("InspectionPanel: Closing Window")
	queue_free()
