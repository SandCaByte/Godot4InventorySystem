extends Control

#Theme Color Buttons
@onready var default_color_button = $SettingsTitleLabel/TabContainer/Theme/SlotHeader/DefaultColorLabel/DefaultColor
@onready var taken_color_button = $SettingsTitleLabel/TabContainer/Theme/SlotHeader/TakenColorLabel/TakenColor
@onready var stackable_color_button = $SettingsTitleLabel/TabContainer/Theme/SlotHeader/StackableColorLabel/StackableColor
@onready var free_color_button = $SettingsTitleLabel/TabContainer/Theme/SlotHeader/FreeColorLabel/FreeColor

# Called when the node enters the scene tree for the first time.
func _ready():
	default_color_button.color = Global.default_color
	taken_color_button.color = Global.taken_color
	stackable_color_button.color = Global.stackable_color
	free_color_button.color = Global.free_color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_exit_button_pressed():
	#deletes itself
	self.queue_free()

func _on_free_color_color_changed(color: Color):
	Global.free_color = free_color_button.color

func _on_stackable_color_color_changed(color: Color):
	Global.stackable_color = stackable_color_button.color

func _on_taken_color_color_changed(color: Color):
	Global.taken_color = taken_color_button.color

func _on_default_color_color_changed(color: Color):
	Global.default_color = default_color_button.color
