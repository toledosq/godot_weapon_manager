extends Node

const PickUp = preload("res://item/pickup/pickup.tscn")

@onready var inventory_interface = $UI/InventoryInterface


func _ready() -> void:
	initialize_inventories()


func initialize_inventories() -> void:
	print("Main: Connecting to Inventory Interface")
	# Connect player to inventory interface
	PlayerManager.player.toggle_inventory.connect(toggle_inventory_interface)

	# Connect to the interface's force_close signal
	inventory_interface.force_close.connect(toggle_inventory_interface)
	
	# Connect to interface's drop item in world signal
	inventory_interface.drop_slot_data.connect(_on_inventory_interface_drop_slot_data)
	
	print("Main: Populating Player Inventory")
	# Populate player inventory
	inventory_interface.set_player_inventory_data(PlayerManager.player.inventory_data)
	
	print("Main: Populating Player Armor Inventory")
	# Populate armor inventory
	inventory_interface.set_armor_inventory_data(PlayerManager.player.armor_inventory_data)
	
	print("Main: Populating Player Weapon Inventory")
	# Populate weapon inventory
	inventory_interface.set_weapon_inventory_data(PlayerManager.player.weapon_inventory_data)
	
	#print("Main: Populating Player Hot Bar")
	## Populate hotbar with player inventory data
	#hot_bar_inventory.set_inventory_data(PlayerManager.player.inventory_data)
	
	print("Main: Connecting to External Inventories")
	# Find all containers in world and connect to their toggle function (for interacting)
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)


func toggle_inventory_interface(container = null) -> void:
# Inventory interface is hidden by default
	inventory_interface.visible = not inventory_interface.visible
	
	## Show mouse if interface is visible
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#hot_bar_inventory.hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#hot_bar_inventory.show()

	# If an external inventory is being interacted with, populate the container panel
	if container and inventory_interface.visible:
		inventory_interface.set_container_inventory(container)
	else:
		inventory_interface.clear_container_inventory()


func _on_inventory_interface_drop_slot_data(slot_data):
	var pick_up = PickUp.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = PlayerManager.player.get_drop_position()
	add_child(pick_up)
