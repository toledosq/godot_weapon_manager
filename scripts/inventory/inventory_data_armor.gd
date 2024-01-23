class_name InventoryDataArmor extends InventoryData


# When player drops an item into equip inventory, check that it's equipable
func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	# If it's not an equipable item, don't drop it, give it back
	if not grabbed_slot_data.item_data is ItemDataArmor:
		return grabbed_slot_data
	
	# Otherwise, drop it into the slot (using parents' function)
	return super.drop_slot_data(grabbed_slot_data, index)


# When player drops a single item into equip inventory, check that it's equipable
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	# If it's not an equipable item, don't drop it, give it back
	if not grabbed_slot_data.item_data is ItemDataArmor:
		return grabbed_slot_data
	
	# Otherwise, drop it into the slot (using parents' function)
	return super.drop_single_slot_data(grabbed_slot_data, index)
