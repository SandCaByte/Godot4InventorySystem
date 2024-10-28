extends Node2D

#Preload settings menu
var settings_menu = preload("res://settings.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_settings_button_pressed():
	var new_settings_menu = settings_menu.instantiate()
	add_child(new_settings_menu)
