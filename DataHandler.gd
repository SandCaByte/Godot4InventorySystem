extends Node

#Path to data
@onready var item_data_path = "res://Data/Item_data.json"

#Dictionarys
var item_data := {}
var item_shape_data := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	#load the json file and set the item data
	load_data(item_data_path)
	#call the function to get and set the shape data
	set_shape_data()

func load_data(path) -> void:
	#Check to see if file exists
	if not FileAccess.file_exists(path):
		print("Item data file not found")
	#Open the json file
	var item_data_file = FileAccess.open(path, FileAccess.READ)
	#Convert json string to dictionary
	item_data = JSON.parse_string(item_data_file.get_as_text())
	#Close the json file
	item_data_file.close()
	#print(item_data) # check values
	
func set_shape_data():
	#Get each item from the item data
	for item in item_data.keys():
		#create a temporary array for storing shape data
		var temp_shape_array := []
		#for each point in the item's shape data
		for point in item_data[item]["Shape"].split("/"):
			#split the point into axises then store them in the array
			temp_shape_array.push_back(point.split(","))
		#Store the points with the item id as the key
		item_shape_data[item] = temp_shape_array
	#print(item_shape_data) # check values
