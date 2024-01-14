class_name InventoryData extends Resource

signal inventory_updated(inventory_data: InventoryData)
signal inventory_interact(inventory_data: InventoryData, index: int, button: int)

@export var slot_datas: Array[SlotData]


# When player grabs an item from inventory
func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	# If there is a slot at this grid index
	if slot_data:
		# Remove the grabbed slot from the inventory and alert inventory panel
		slot_datas[index] = null
		inventory_updated.emit(self)
		
		# Give the grabbed slot's data to requestor
		return slot_data
	else:
		return null


# When player drops an item into inventory
func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	# Get the slot at grid index
	var slot_data = slot_datas[index]

	# If dropped onto existing stack, and stacks can be merged
	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	
	# Else, swap inventory slot with grabbed slot
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data
	
	# Alert inventory panel of update
	inventory_updated.emit(self)
	# Return null if stacks merged or slot was already empty, otherwise return swapped slot
	return return_slot_data


# When player drops a single item into inventory
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	# Get the slot at grid index
	var slot_data = slot_datas[index]
	
	# If nothing is there, drop 1 item from the stack
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
	# If it can be merged, do that
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
	# Alert inventory panel to update
	inventory_updated.emit(self)
	
	# If there's still items in the stack, return grabbed slot data
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null


func use_slot_data(index: int) -> void:
	var slot_data = slot_datas[index]
	
	if not slot_data:
		return
	
	# If consumable is used
	if slot_data.item_data is ItemDataConsumable:
		# Subtract one from stack
		slot_data.quantity -= 1
		# If nothing left in stack, remove item from inventory
		if slot_data.quantity < 1:
			slot_datas[index] = null

	print(slot_data.item_data.name)
	
	# Tell player manager item was used
	PlayerManager.use_slot_data(slot_data)
	
	# Alert inventory panel of update
	inventory_updated.emit(self)


# When player picks up item in world
func pick_up_slot_data(slot_data: SlotData) -> bool:
	# Look for mergeable slots in inventory
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data):
			slot_datas[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true
			
	# Find first empty slot in inventory and add picked up item to it
	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			inventory_updated.emit(self)
			return true
	
	# If no valid slots, pick up fails
	return false


func on_slot_clicked(index: int, button: int) -> void:
	# Received from slot -> relay to inventory_interface
	inventory_interact.emit(self, index,  button)
