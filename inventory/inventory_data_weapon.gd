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
	
	## IF ATTACHMENT DROPPED
	if grabbed_slot_data.item_data is ItemDataAttachment:
		return handle_attachments(grabbed_slot_data, index)
	
	## IF ITEM NOT WEAPON DROPPED
	if not grabbed_slot_data.item_data is ItemDataWeapon or grabbed_slot_data.item_data is ItemDataGrenade:
		return grabbed_slot_data
	
	## IF WEAPON DROPPED
	# Otherwise, drop it into the slot (using parents' function)
	EventBus.add_weapon.emit(index, grabbed_slot_data.item_data)
	return super.drop_slot_data(grabbed_slot_data, index)


# When player drops a single item into equip inventory, check that it's equipable
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	## IF ATTACHMENT DROPPED
	if grabbed_slot_data.item_data is ItemDataAttachment:
		return handle_attachments(grabbed_slot_data, index)
	
	## IF ITEM NOT WEAPON DROPPED
	# If it's not an equipable item, don't drop it, give it back
	if not grabbed_slot_data.item_data is ItemDataWeapon or grabbed_slot_data.item_data is ItemDataGrenade:
		return grabbed_slot_data
	
	## IF WEAPON DROPPED
	# Otherwise, drop it into the slot (using parents' function)
	EventBus.add_weapon.emit(index, grabbed_slot_data.item_data)
	return super.drop_single_slot_data(grabbed_slot_data, index)


func handle_attachments(grabbed_slot_data: SlotData, index: int):
	var slot_data = slot_datas[index]
	if slot_data:
		
		# Attempt to attach
		var returned_attachment = slot_data.item_data.add_attachment(grabbed_slot_data.item_data)
		
		# If swapped
		if returned_attachment and returned_attachment != grabbed_slot_data.item_data:
				EventBus.attachment_added.emit(grabbed_slot_data, index)
				grabbed_slot_data.item_data = returned_attachment
				
		# If added, not swapped
		else:
			EventBus.attachment_added.emit(grabbed_slot_data.item_data, index)
			grabbed_slot_data = null
		
		return grabbed_slot_data
