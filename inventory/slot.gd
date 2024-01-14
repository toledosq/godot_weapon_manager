class_name SlotPanel extends PanelContainer

signal slot_clicked(index: int, button: int)

@onready var texture_rect = $MarginContainer/TextureRect
@onready var quantity_label = $QuantityLabel

func set_slot_data(slot_data: SlotData) -> void:
	var item_data = slot_data.item_data
	# Set the slot's texture to the item's texture
	texture_rect.texture = item_data.texture
	
	# Tooltip appears when mouse hovered over slot
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	# Show/hide the quantity of item depending on how many
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()

func _on_gui_input(event):
	# If user left or right clicks on slot
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		# Emit slot_clicked signal with the slot's index and which mouse button was clicked
		# Will be caught by inventory_data
		slot_clicked.emit(get_index(), event.button_index)
