extends Node2D

#Signal for inventory to be updated when rotated
signal item_rotated(item)

#Store the child nodes as variables
@onready var IconRect = $Icon
@onready var QuantityLabel = $Icon/Label

#Common Variables
var item_name: String
var max_stack_size: int
var quantity := 1
var item_points := []
var selected = false
var grid_anchor = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Check if object selected
	if selected:
		#follow mouse position
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
	#Check if item is being held
	if Global.item_held:
		#Check if the instance of the item is the item that is held
		if self == Global.item_held:
			#Rotate the item on right click
			if Input.is_action_just_pressed("mouse_rightclick"):
				rotate_item()
	
func load_item(itemID: int) -> void:
	#set the items name to the item id's name
	item_name = DataHandler.item_data[str(itemID)]["Name"]
	#set item's texture to the stored png file named item after the item name
	var Icon_path = "res://Assets/" + item_name + ".png"
	IconRect.texture = load(Icon_path)
	#set item's max stack size
	max_stack_size = int(DataHandler.item_data[str(itemID)]["MaxStackSize"])
	#Update the quantity label
	update_quantity()
	#For each point in the item's group of points dictionary
	for point in DataHandler.item_shape_data[str(itemID)]:
		#Converter array to convert dictionary to array
		var converter_array := []
		#for each axis of the point
		for axis in point:
			#store the axis value in the array
			converter_array.push_back(int(axis))
		#store each array of axis values into an array of points
		item_points.push_back(converter_array)
		
func rotate_item():
	#For each point in the item's array of points
	for point in item_points:
		#store the original y value
		var temp_y = point[0]
		#set the y value to the x value multiplied by -1
		point[0] = -point[1]
		#set the x axis to the original y value
		point[1] = temp_y
	#add to the item's rotation value
	rotation_degrees += 90
	#Set 360 degrees back to 0 degrees so we dont end up with degree values over 360
	if rotation_degrees >= 360:
		rotation_degrees = 0
	#Keep the label rotation at zero
	QuantityLabel.rotation_degrees -= 90
	if QuantityLabel.rotation_degrees <= -360:
		QuantityLabel.rotation_degrees = 0
	QuantityLabel.anchor_bottom = 1.0
	QuantityLabel.anchor_right = 1.0
	#Signal that item was rotated
	item_rotated.emit(self)
		
func _snap_to(destination: Vector2): # destination is set to the global position that the item icon texture snaps to
	#Create a tween of the node
	var tween = get_tree().create_tween()
	#Check if the item is not rotated at 90 degrees or 270 degrees
	if int(rotation_degrees) % 180 == 0:
		#the destination to snap the icon to is offset by half the texture's size
		destination += IconRect.size / 2
	else:
		#Switch the x and y values
		var temp_xy_switch = Vector2(IconRect.size.y, IconRect.size.x)
		#the destination to snap the icon to is offset by half of the texture's size when rotated
		destination += temp_xy_switch / 2
	
	#Translate the tween's global position to the destination position in 0.15 seconds with the translation type being a sine wave
	tween.tween_property(self, "global_position", destination, 0.15).set_trans(Tween.TRANS_SINE)
	#deselect the item because function is only called when placing the item in the inventory
	selected = false

func update_quantity():
	#if the quantity is only one then dont show number
	if quantity == 1:
		QuantityLabel.text = " "
		return
	#Update the Quantity Label
	QuantityLabel.text = str(quantity)
