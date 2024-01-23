class_name InspectionPanel extends PanelContainer


var slot_data: SlotData:
	set(val):
		slot_data = val
		update_panel_data()

@onready var weapon_image = %WeaponImage
@onready var panel_title_label = %PanelTitleLabel


func _ready():
	print("InspectionPanel: Ready")


func set_slot_data(slot_data_: SlotData):
	slot_data = slot_data_


func update_panel_data():
	set_weapon_image()


func set_weapon_image():
	weapon_image.texture = slot_data.item_data.texture

func set_panel_title():
	panel_title_label.text += str(": %s" % slot_data.item_data.name)


func _on_close_button_pressed():
	print("InspectionPanel: Closing Window")
	queue_free()
