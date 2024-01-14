extends Control

# Signal if item dropped on ground
signal drop_slot_data(slot_data: SlotData)
signal force_close()
signal weapon_inventory_updated()

var grabbed_slot_data: SlotData
var container

@onready var player_inventory = $PlayerInventory
@onready var grabbed_slot = $GrabbedSlot
@onready var container_inventory = $ContainerInventory
@onready var armor_inventory = $ArmorInventory
@onready var weapon_inventory = $WeaponInventory


func _physics_process(_delta):
	# If an item is grabbed (grabbed), have it follow the cursor
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5,5)
	
	# If player gets too far from a container, force close inventory interface
	if container and container.global_position.distance_to(PlayerManager.get_global_position()) > 4:
		force_close.emit()


func set_player_inventory_data(inventory_data: InventoryData) -> void:
	# Connect to the inventory data's interaction signal
	inventory_data.inventory_interact.connect(on_inventory_interact)
	# Call player's set_inventory_data function
	player_inventory.set_inventory_data(inventory_data)


func set_armor_inventory_data(inventory_data: InventoryData) -> void:
	# Connect to the inventory data's interaction signal
	inventory_data.inventory_interact.connect(on_inventory_interact)
	# Call armor's set_inventory_data function
	armor_inventory.set_inventory_data(inventory_data)


func set_weapon_inventory_data(inventory_data: InventoryData) -> void:
	# Connect to the inventory data's interaction signal
	inventory_data.inventory_interact.connect(on_inventory_interact)
	# Call armor's set_inventory_data function
	weapon_inventory.set_inventory_data(inventory_data)
	weapon_inventory_updated.emit()


func set_container_inventory(_container) -> void:
	# Store the external inv owner so we can disconnect the signals later
	container = _container
	# Get the external inventory's data
	var inventory_data = container.inventory_data

	# Connect to the external inventory data's interaction signal
	inventory_data.inventory_interact.connect(on_inventory_interact)
	# Set inventory data in panel (populate grid)
	container_inventory.set_inventory_data(inventory_data)
	
	# Show the external inventory panel
	container_inventory.show()


func clear_container_inventory() -> void:
	if container:
		# Get the external inventory's data
		var inventory_data = container.inventory_data

		# Disconnect interact signal
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		# Clear inventory data in panel (depopulate grid)
		container_inventory.clear_inventory_data(inventory_data)
		
		# Hide the external inventory panel
		container_inventory.hide()
		# unlink the external inventory from the interface
		container = null


# Set up to allow multiple different inventories, useful for containers
func on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:
	# Match which slot was interacted with, and which mouse button it was
	match [grabbed_slot_data, button]:
		
		# If nothing is currently grabbed, grab the slot
		[null, MOUSE_BUTTON_LEFT]:
			# Grab slot data from the slot's index in inventory_data
			grabbed_slot_data = inventory_data.grab_slot_data(index)
			
		# If something is grabbed, drop it into the slot
		[_, MOUSE_BUTTON_LEFT]:
			# Drop slot data from the slot's index in inventory_data
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
			
		# If nothing is currently grabbed, use item
		# TODO: Refactor to show subpanel with options
		[null, MOUSE_BUTTON_RIGHT]:
			inventory_data.use_slot_data(index)
			
		# If something is grabbed
		[_, MOUSE_BUTTON_RIGHT]:
			# Drop slot data from the slot's index in inventory_data
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
			
	# Update the interface's grabbed slot variable
	update_grabbed_slot()


func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.set_slot_data(grabbed_slot_data)
		grabbed_slot.show()
	else:
		grabbed_slot.hide()


# Handles GUI input where it is not handled in child panels
# IE, if you click outside the panel while the inventory_interface is shown
func _on_gui_input(event):
	if event is InputEventMouseButton \
			and event.is_pressed() \
			and grabbed_slot_data:
		
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				# Tell game that an item was dropped
				drop_slot_data.emit(grabbed_slot_data)
				# Ungrab the item slot
				grabbed_slot_data = null
			MOUSE_BUTTON_RIGHT:
				# Tell game that a SINGLE item was dropped
				drop_slot_data.emit(grabbed_slot_data.create_single_slot_data())
				# If that was last item, ungrab slot
				if grabbed_slot_data.quantity < 1:
					grabbed_slot_data = null
					
		update_grabbed_slot()


func _on_visibility_changed():
	# If an item slot is grabbed when the interface closes, drop it
	if not visible and grabbed_slot_data:
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()
