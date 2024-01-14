extends StaticBody3D

# Signal thrown when container interacted with
signal toggle_inventory(external_inventory_owner)

# Assigned inventory
@export var inventory_data: InventoryData


func interact() -> void:
	toggle_inventory.emit(self)
