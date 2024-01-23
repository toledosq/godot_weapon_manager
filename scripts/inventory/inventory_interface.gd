class_name InventoryInterface extends Control

# Signal if item dropped on ground
signal drop_slot_data(slot_data: SlotData)
signal force_close()
signal weapon_inventory_updated()
signal grenade_inventory_updated()

var grabbed_slot_data: SlotData
var container

const CONTEXT_MENU = preload("res://scenes/ui/ui_elements/context_menu.tscn")
var current_context_menu: ContextMenu
var context_menu_slot_index: int
var context_menu_inventory_data: InventoryData

#var POPUP_PANEL = preload("res://scenes/ui/ui_elements/inspection_window.tscn")
var INSPECTION_PANEL = preload("res://scenes/ui/inspection_panel.tscn")


var open_windows: Array

@onready var player_inventory = %PlayerInventory
@onready var grabbed_slot = %GrabbedSlot
@onready var container_inventory = %ContainerInventory
@onready var container_inventory_scroller = %ContainerInventoryScroller
@onready var armor_inventory = %ArmorInventory
@onready var weapon_inventory = %WeaponInventory
@onready var grenade_inventory = %GrenadeInventory
@onready var container_inventory_label = %ContainerInventoryLabel


func _ready():
	print("Inventory Interface ready")


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


func set_armor_inventory_data(inventory_data: InventoryDataArmor) -> void:
	# Connect to the inventory data's interaction signal
	inventory_data.inventory_interact.connect(on_inventory_interact)
	# Call armor's set_inventory_data function
	armor_inventory.set_inventory_data(inventory_data)


func set_weapon_inventory_data(inventory_data: InventoryDataWeapon) -> void:
	# Connect to the inventory data's interaction signal
	inventory_data.inventory_interact.connect(on_inventory_interact)
	# Call armor's set_inventory_data function
	weapon_inventory.set_inventory_data(inventory_data)
	weapon_inventory_updated.emit()


func set_grenade_inventory_data(inventory_data: InventoryDataGrenade):
	# Connect to the inventory data's interaction signal
	inventory_data.inventory_interact.connect(on_inventory_interact)
	# Call armor's set_inventory_data function
	grenade_inventory.set_inventory_data(inventory_data)
	grenade_inventory_updated.emit()


func set_container_inventory(_container) -> void:
	# Store the external inv owner so we can disconnect the signals later
	container = _container
	# Get the external inventory's data
	var inventory_data = container.inventory_data

	if inventory_data != null:
		# Connect to the external inventory data's interaction signal
		inventory_data.inventory_interact.connect(on_inventory_interact)
		# Set inventory data in panel (populate grid)
		container_inventory.set_inventory_data(inventory_data)
	
		# Show the external inventory panel
		container_inventory.show()
		container_inventory_scroller.show()
		container_inventory_label.show()


func clear_container_inventory() -> void:
	if container:
		# Get the external inventory's data
		var inventory_data = container.inventory_data
		if inventory_data != null:
			# Disconnect interact signal
			inventory_data.inventory_interact.disconnect(on_inventory_interact)
			# Clear inventory data in panel (depopulate grid)
			container_inventory.clear_inventory_data(inventory_data)
		
	# Hide the external inventory panel
	container_inventory.hide()
	container_inventory_scroller.hide()
	container_inventory_label.hide()
	
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
			
		# If nothing is currently grabbed, show context menu
		[null, MOUSE_BUTTON_RIGHT]:
			context_menu_inventory_data = inventory_data
			context_menu_slot_index = index
			open_context_menu()
			
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


func open_context_menu():
	if current_context_menu != null:
		close_context_menu()
	
	var context_menu = CONTEXT_MENU.instantiate()
	context_menu.item_clicked.connect(_on_context_menu_item_clicked)
	add_child(context_menu)
	context_menu.position = get_local_mouse_position()
	current_context_menu = context_menu


func close_context_menu():
	current_context_menu.queue_free()
	current_context_menu = null


func open_inspect_window(slot_data):
	print("InventoryInterface: Opening inspect window")
	var inspection_panel = INSPECTION_PANEL.instantiate()
	add_child(inspection_panel)
	open_windows.append(inspection_panel)
	
	inspection_panel.set_slot_data(slot_data)
	# TODO: Research window options
	#var inspection_window = POPUP_PANEL.instantiate()
	#var inspection_panel = INSPECTION_PANEL.instantiate()
	#inspection_window.add_child(inspection_panel)
	#add_child(inspection_window)
	#open_windows.append(inspection_window)


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
	if not visible:
		if grabbed_slot_data:
			drop_slot_data.emit(grabbed_slot_data)
			grabbed_slot_data = null
			update_grabbed_slot()
		
		# If a context menu is open, close it
		if current_context_menu != null:
			close_context_menu()
		
		# If there are open windows (eg item inspect), close them
		if len(open_windows) > 0:
			for open_window in open_windows:
				if open_window != null:
					open_window.queue_free()
			open_windows.clear()


func _on_context_menu_item_clicked(item_text):
	print("InventoryInterface: Received context menu click on item %s" % item_text)
	match item_text:
		"Inspect":
			print("InventoryInterface: Open Inspection Window")
			# Get the slot_data from the inventory
			var slot_data = context_menu_inventory_data.slot_datas[context_menu_slot_index]
			# Open an inspection window
			open_inspect_window(slot_data)
		"Use":
			print("InventoryInterface: Use Item")
			context_menu_inventory_data.use_slot_data(context_menu_slot_index)
		"Drop":
			print("InventoryInterface: Drop Item")


