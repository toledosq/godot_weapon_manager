class_name InventoryDataGrenade extends InventoryData

signal weapon_equipped(index)
signal weapon_unequipped(index)


# When player grabs an item from inventory
func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	# If there is a slot at this grid index
	if slot_data:
		# Remove the grabbed slot from the inventory and alert inventory panel
		slot_datas[index] = null
		inventory_updated.emit(self)
		
		# Alert weapon unequipped
		EventBus.remove_grenade.emit()
		
		# Give the grabbed slot's data to requestor
		return slot_data
	else:
		return null


# When player drops an item into equip inventory, check that it's equipable
func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	# If it's not an equipable item, don't drop it, give it back
	if not grabbed_slot_data.item_data is ItemDataGrenade:
		return grabbed_slot_data

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
	
	# Alert WeaponManager that grenade was added
	EventBus.add_grenade.emit(slot_datas[index])
	
	# Return null if stacks merged or slot was already empty, otherwise return swapped slot
	return return_slot_data


# When player drops a single item into equip inventory, check that it's equipable
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	# If it's not an equipable item, don't drop it, give it back
	if not grabbed_slot_data.item_data is ItemDataGrenade:
		return grabbed_slot_data
	
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
	
	# Alert WeaponManager that grenade was added
	EventBus.add_grenade.emit(slot_datas[index])
	
	# If there's still items in the stack, return grabbed slot data
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null


func use_slot_data(index: int) -> void:
	var slot_data = slot_datas[index]
	
	if not slot_data:
		return

	# Subtract one from stack
	slot_data.quantity -= 1
	# If nothing left in stack, remove item from inventory
	if slot_data.quantity < 1:
		slot_datas[index] = null

	print(slot_data.item_data.name)
	
	# Alert inventory panel of update
	inventory_updated.emit(self)
