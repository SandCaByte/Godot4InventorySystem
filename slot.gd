extends TextureRect

#Slot signals for signaling mouse entering and exiting
signal slot_entered(slot)
signal slot_exited(slot)

#Get color filter node when ready
@onready var filter = $StatusFilter

#Common Variables
var slot_ID
enum States {DEFAULT, TAKEN, STACKABLE, FREE}
var state = States.DEFAULT
var item_stored = null

#Function to set the color of the status filter
func set_color(a_state = States.DEFAULT) -> void:
	#Switch statement to determine value of state
	match a_state:
		States.DEFAULT:
			#if state is default then set color to default color
			filter.color = Global.default_color
		States.TAKEN:
			#if state is taken then set color to taken color
			filter.color = Global.taken_color
		States.STACKABLE:
			#if state is free then set color to free color
			filter.color = Global.stackable_color
		States.FREE:
			#if state is free then set color to free color
			filter.color = Global.free_color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Called when the mouse enters the node dimensions
func _on_mouse_entered():
	#Emit the slot entered signal
	slot_entered.emit(self)

#Called when the mouse exits the node dimensions
func _on_mouse_exited():
	#Emit the slot exited signal
	slot_exited.emit(self)
