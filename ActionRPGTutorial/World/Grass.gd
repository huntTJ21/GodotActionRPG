extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_attack"):
		var GrassEffect = load("res://Effects/GrassEffect.tscn") # Load the scene
		var grassEffect = GrassEffect.instance()				 # Instance the scene
		var world = get_tree().current_scene					 # Get world scene
		world.add_child(grassEffect)							 # Add instance to the world scene
		grassEffect.global_position = global_position			 # Set the instance position to th position of the grass
		queue_free()											 # Remove the grass instance from the scene
