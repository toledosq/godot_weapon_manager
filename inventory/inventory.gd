class_name InventoryPanel extends PanelContainer

const SLOT = preload("res://inventory/slot.tscn")

@onready var item_grid = $MarginContainer/ItemGrid


func set_inventory_data(inventory_data: InventoryData) -> void:
	# Set up listener so if inventory changes, repopulate the item grid
	inventory_data.inventory_updated.connect(populate_item_grid)
	
	# Do initial population on receiving inventory data
	populate_item_grid(inventory_data)


func clear_inventory_data(inventory_data: InventoryData) -> void:
	# Disconnect the update signal
	inventory_data.inventory_updated.disconnect(populate_item_grid)


func populate_item_grid(inventory_data: InventoryData) -> void:
	# Remove any existing items
	for child in item_grid.get_children():
		child.queue_free()
	
	# Populate with slots found in inventory_data resource
	for slot_data in inventory_data.slot_datas:
		var slot = SLOT.instantiate()
		item_grid.add_child(slot)
		
		# Connect slot_clicked interaction signal to inventory data resource
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		# If slot_data exists
		if slot_data:
			slot.set_slot_data(slot_data)
