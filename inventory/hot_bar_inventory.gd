extends PanelContainer

signal hot_bar_use(index: int)

const SLOT = preload("res://inventory/slot.tscn")

@onready var h_box_container = $MarginContainer/HBoxContainer


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return
	
	# Detect if the 1-6 keys are pressed (range non-inclusive)
	if range(KEY_1, KEY_7).has(event.keycode):
		# If so, emit which key was pressed (subtract KEY_1 to get 0, which is the first index in hot bar)
		hot_bar_use.emit(event.keycode - KEY_1)


func set_inventory_data(inventory_data: InventoryData) -> void:
	# Set up listener so if hotbar inventory changes, repopulate it
	inventory_data.inventory_updated.connect(populate_hot_bar)
	
	# Do initial population on receiving inventory data
	populate_hot_bar(inventory_data)
	
	# When hot bar is used, ask the indexed slot to use item
	hot_bar_use.connect(inventory_data.use_slot_data)


func populate_hot_bar(inventory_data: InventoryData) -> void:
	# Remove any existing items
	for child in h_box_container.get_children():
		child.queue_free()
	
	# Populate with slots found in inventory_data resource
	# Hardcoded to 6 slots
	for slot_data in inventory_data.slot_datas.slice(0, 6):
		var slot = SLOT.instantiate()
		h_box_container.add_child(slot)
		
		# If slot_data exists
		if slot_data:
			slot.set_slot_data(slot_data)
