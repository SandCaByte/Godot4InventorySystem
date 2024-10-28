extends Control

#Preloaded Variables
var slot_scene = preload("res://slot.tscn")
var item_scene = preload("res://item.tscn")

#Variables Loaded When the Script is First Loaded
@onready var grid_container = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var scroll_container = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer
@onready var col_count = grid_container.columns

#Exported Variable so it accesable
@export var maxSlots: int = 64;

#Common Variables
var grid_array := []
var current_slot = null
var can_place := false
var can_stack := false
var icon_anchor: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	#populate slots
	for i in range(maxSlots):
		create_slot()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Check to see if an item is following the mouse position
	if Global.item_held:
		#Place the item on left click
		if Input.is_action_just_pressed("mouse_leftclick"):
			place_item()
	else:
		#Pick up the item the mouse is hovering above on left click
		if Input.is_action_just_pressed("mouse_leftclick"):
			if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
				select_item()
	
func create_slot():
	#instantiate a new slot
	var new_slot = slot_scene.instantiate()
	#Give the new slot an ID that increments with the number of slots created
	new_slot.slot_ID = grid_array.size()
	#Add the new slot to the grid array
	grid_array.push_back(new_slot)
	#Add slot to the scene
	grid_container.add_child(new_slot)
	#Connect the signals
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)

#function called when slot_entered signal is emitted
func _on_slot_mouse_entered(slot):
	#anchor is so that the program knows where to put the texture in the grid
	icon_anchor = Vector2(10000, 10000)
	#set the current slot to the slot that the mouse entered
	current_slot = slot
	#check if already holding an item
	if Global.item_held:
		#check the slot availability of the slot the mouse entered
		check_slot_availability(current_slot)
		#call the set_slot_filters function when there is nothing in the main thread
		set_slot_filters.call_deferred(current_slot)

#function called when slot_entered signal is emitted
func _on_slot_mouse_exited(slot):
	#change the the slot colors back to the default color
	reset_slot_filters()

	#if the mouse is not hovering above a slot then there is no current slot
	if not grid_container.get_global_rect().has_point(get_global_mouse_position()):
		current_slot = null

#Called when the spawn item button is pressed
func _on_button_spawn_pressed() -> void:
	#Do nothing if there is already an item following the mouse
	if Global.item_held:
		return
	#Instantiate a new item
	var new_item = item_scene.instantiate()
	#Add the item to the scene
	get_parent().add_child(new_item)
	#Set the item to a random item based on data
	new_item.load_item(randi_range(1, 4))
	#Connect the item signal
	new_item.item_rotated.connect(_on_item_rotated)
	#Set the item's selected property to true so the item follows the mouse position
	new_item.selected = true
	#Set the item being held to the new item
	Global.item_held = new_item

func check_slot_availability(slot) -> void:
	#for each point in item points array
	for point in Global.item_held.item_points:
		#calculates the slot to check within the grid
		var slot_to_check = slot.slot_ID + point[0] + point[1] * col_count
		#Checks if the grid is switching rows
		var row_switch_check = slot.slot_ID % col_count + point[0]
		if row_switch_check < 0 or row_switch_check >= col_count:
			#If it is switching rows and the item is wider than 1 slot then you cannot place the item
			can_place = false
			can_stack = false
			return
		if slot_to_check < 0 or slot_to_check >= grid_array.size():
			#If row is outside bounds then the slot does not exist so you cannot place the item
			can_place = false
			can_stack = false
			return
		if grid_array[slot_to_check].state == grid_array[slot_to_check].States.TAKEN:
			#If the slot is taken then check if the item is of the same item type
			var slot_stored_item = grid_array[slot_to_check].item_stored
			if slot_stored_item.item_name == Global.item_held.item_name:
				#Check if stacking items would be possible
				if slot_stored_item.quantity + Global.item_held.quantity <= slot_stored_item.max_stack_size:
					can_place = true
					can_stack = true
					return
			#If the slot already taken by a different type of item then item cannot be placed or stacked
			can_place = false
			can_stack = false
			return
		#If the conditions allow it then you can place item
		can_stack = false
		can_place = true
		
func set_slot_filters(slot):
	#for each point in item points array
	for point in Global.item_held.item_points:
		#calculates the slot to check within the grid
		var slot_to_check = slot.slot_ID + point[0] + point[1] * col_count
		#Checks if the grid is switching rows
		var row_switch_check = slot.slot_ID % col_count + point[0]
		#Check if slot to check is within grid bounds
		if slot_to_check < 0 or slot_to_check >= grid_array.size():
			continue
		#Check if Switching Rows
		if row_switch_check < 0 or row_switch_check >= col_count:
			continue
		
		#Check if you can place the item
		if can_place:
			if can_stack:
				#If you can stack the item then highlight the slot teal
				grid_array[slot_to_check].set_color(grid_array[slot_to_check].States.STACKABLE)
			else:
				#If you can place the item then highlight the slots green
				grid_array[slot_to_check].set_color(grid_array[slot_to_check].States.FREE)
			
			#Make sure the icon will place correctly
			if point[1] < icon_anchor.x: icon_anchor.x = point[1]
			if point[0] < icon_anchor.y: icon_anchor.y = point[0]
		else:
			#If you cannot place the item then highlight the slot red
			grid_array[slot_to_check].set_color(grid_array[slot_to_check].States.TAKEN)

#Function to set the slot color filters to the default color
func reset_slot_filters():
	for slot in grid_array:
		slot.set_color(slot.States.DEFAULT)

#Function to rotate the item
func _on_item_rotated(item):
	#Reset the color filters
	reset_slot_filters()
	#Re-determine if item can be placed with new rotation
	if current_slot:
		_on_slot_mouse_entered(current_slot)

#Function for placing the item
func place_item():
	#If can place is false or the mouse isnt hovering over a slot then item cannot be placed
	if not can_place or not current_slot:
		return
	
	#Find slot position within grid array
	var calculated_slot_id = current_slot.slot_ID + icon_anchor.x * col_count + icon_anchor.y
	#Snap the item icon to the slot's global position
	Global.item_held._snap_to(grid_array[calculated_slot_id].global_position)

	#If item is stackable then stack items then return
	if can_stack:
		stack_items()
		return

	#for changing scene tree to allow the item to scroll with the grid container
	Global.item_held.get_parent().remove_child(Global.item_held)
	grid_container.add_child(Global.item_held)
	Global.item_held.global_position = get_global_mouse_position()
	
	#anchor the item held to the current slot
	Global.item_held.grid_anchor = current_slot
	#for each point in item points array
	for point in Global.item_held.item_points:
		#calculates the slot to check within the grid
		var slot_to_check = current_slot.slot_ID + point[0] + point[1] * col_count
		#Set slot state to taken
		grid_array[slot_to_check].state = grid_array[slot_to_check].States.TAKEN
		#Store the item in the slot
		grid_array[slot_to_check].item_stored = Global.item_held
	
	#Stop holding item
	Global.item_held = null
	#reset slot filters
	reset_slot_filters()

func stack_items():
	var temp_current_slot = current_slot
	if temp_current_slot.item_stored == null:
		for point in Global.item_held.item_points:
			#calculates the slot to check within the grid
			var slot_to_check = current_slot.slot_ID + point[0] + point[1] * col_count
			if not grid_array[slot_to_check].item_stored == null:
				temp_current_slot = grid_array[slot_to_check]
	#Find slot position within grid array
	var calculated_slot_id = temp_current_slot.slot_ID + icon_anchor.x * col_count + icon_anchor.y
	#Snap the item icon to the slot's global position
	Global.item_held._snap_to(grid_array[calculated_slot_id].global_position)
	#Add the item held quantity to the slotted item quantity
	temp_current_slot.item_stored.quantity += Global.item_held.quantity
	#Update the stored item's quantity
	temp_current_slot.item_stored.update_quantity()
	#Wait until snapping animation is over
	await get_tree().create_timer(0.15).timeout
	#Delete the object instance of the item held
	Global.item_held.queue_free()
	#stop holding item
	Global.item_held = null
	#reset the slot filters
	reset_slot_filters()

#Function to pick up an item
func select_item():
	#If you have an item selected already or there is no item to pick up then you cant pick up an item
	if not current_slot or not current_slot.item_stored:
		return
	
	#Assign the slotted item as the item being held
	Global.item_held = current_slot.item_stored
	#Change the selected property of the object to true
	Global.item_held.selected = true

	#move node in the scene tree to prevent item from only rendering in grid container
	Global.item_held.get_parent().remove_child(Global.item_held)
	get_parent().add_child(Global.item_held)
	Global.item_held.global_position = get_global_mouse_position()
	
	#for each point in item points array
	for point in Global.item_held.item_points:
		#calculates the slot to check within the grid
		var slot_to_check = Global.item_held.grid_anchor.slot_ID + point[0] + point[1] * col_count
		#Set the slot state to free
		grid_array[slot_to_check].state = grid_array[slot_to_check].States.FREE
		#Set the item stored state back to null
		grid_array[slot_to_check].item_stored = null
		
		#Refresh slot availability
		check_slot_availability(current_slot)
		#Update slot filter color when Main thread is free
		set_slot_filters.call_deferred(current_slot)
