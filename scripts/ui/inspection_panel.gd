class_name InspectionPanel extends PanelContainer

var slot_data: SlotData:
	set(val):
		slot_data = val
		update_panel_data()

@onready var item_image = %ItemImage
@onready var panel_title_label = %PanelTitleLabel

@onready var attach_slots_container = %AttachSlotsContainer
@onready var attach_scope_slot = %AttachScopeSlot
@onready var attach_underbarrel_slot = %AttachUnderbarrelSlot


func _ready():
	attach_slots_container.hide()
	print("InspectionPanel: Ready")


func set_slot_data(slot_data_: SlotData):
	slot_data = slot_data_
	if slot_data.item_data is ItemDataWeaponRanged:
		attach_slots_container.show()


func update_panel_data():
	set_panel_title()
	set_item_image()
	set_attach_slots()


func set_item_image():
	item_image.texture = slot_data.item_data.texture


func set_panel_title():
	panel_title_label.text += str(": %s" % slot_data.item_data.name)


func set_attach_slots():
	if slot_data.item_data is ItemDataWeaponRanged:
		print("InspectionPanel: Scope = %s" % slot_data.item_data.scope)
		if slot_data.item_data.scope:
			attach_scope_slot.texture = slot_data.item_data.scope.texture
		
		print("InspectionPanel: Underbarrel = %s" % slot_data.item_data.underbarrel)
		if slot_data.item_data.underbarrel:
			attach_underbarrel_slot.texture = slot_data.item_data.underbarrel.texture


func _on_close_button_pressed():
	print("InspectionPanel: Closing Window")
	queue_free()
