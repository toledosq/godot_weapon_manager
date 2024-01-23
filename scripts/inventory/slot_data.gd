class_name SlotData extends Resource


const MAX_STACK_SIZE: int = 99

@export var item_data: ItemData
# Stack quantity can be set within range of 1-MAX_STACK_SIZE
@export_range(1, MAX_STACK_SIZE) var quantity: int = 1: set = set_quantity


# Check if 2 stacks can be partially merged into one stack
# Used for dropping single items
func can_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data \
			and item_data.stackable \
			and quantity < MAX_STACK_SIZE


# Check if 2 stacks can be fully merged into one stack
func can_fully_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data \
			and item_data.stackable \
			and quantity + other_slot_data.quantity <= MAX_STACK_SIZE


# Merge 2 stacks into 1 stack
func fully_merge_with(other_slot_data: SlotData) -> void:
	quantity += other_slot_data.quantity


# To remove one item from stack, duplicate this slot and subtract 1 from it's quantity, and set the duplicate's quantity to 1
func create_single_slot_data() -> SlotData:
	var new_slot_data = duplicate()
	new_slot_data.quantity = 1
	quantity -= 1
	return new_slot_data


# Set stack size
func set_quantity(value: int) -> void:
	quantity = value
	
	# Do not allow more than 1 of non-stacking items
	if quantity > 1 and not item_data.stackable:
		quantity = 1
		push_error("%s is not stackable, setting quantity to 1" % item_data.name)
