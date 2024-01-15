class_name InventoryDataWeapon extends InventoryData

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
		EventBus.remove_weapon.emit(index)
		
		# Give the grabbed slot's data to requestor
		return slot_data
	else:
		return null


# When player drops an item into equip inventory, check that it's equipable
func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	# If it's not an equipable item, don't drop it, give it back
	if not grabbed_slot_data.item_data is ItemDataWeapon:
		return grabbed_slot_data
	
	# Otherwise, drop it into the slot (using parents' function)
	EventBus.add_weapon.emit(index, grabbed_slot_data.item_data)
	return super.drop_slot_data(grabbed_slot_data, index)


# When player drops a single item into equip inventory, check that it's equipable
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	# If it's not an equipable item, don't drop it, give it back
	if not grabbed_slot_data.item_data is ItemDataWeapon:
		return grabbed_slot_data
	
	# Otherwise, drop it into the slot (using parents' function)
	EventBus.add_weapon.emit(index, grabbed_slot_data.item_data)
	return super.drop_single_slot_data(grabbed_slot_data, index)
