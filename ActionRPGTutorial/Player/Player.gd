extends KinematicBody2D

############# Variables ########################################################

## Variables for state machine
var state = MOVE
enum {
	MOVE,
	ROLL,
	ATTACK
}

## Vaiables for Physics
export (float) var speed = 160
export (float) var accel = 24
export (float) var frict = 24
export (float) var adjust= 1
export (bool) var PhysicsWithAcceleration = true
const DELTA_MULTIPLY = 60
var velocity = Vector2.ZERO

## Variables for animation
onready var animationPlayer = $AnimationPlayer
onready var animationTree   = $AnimationTree
onready var animationState  = animationTree.get("parameters/playback")

############# Functions ########################################################

func _ready():
	speed = speed * adjust
	accel = accel * adjust
	frict = frict * adjust
	animationTree.active = true
	
# Function to get input using if/else statements and actions
# To be called at the beginning of the physics_process
func get_input():
	velocity = Vector2();
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1

# Function to get input using  an input-vector and action strengths
# To be called at the beginning of the physics_process
func get_inputvec():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_east") - Input.get_action_strength("ui_west")
	input_vector.y = Input.get_action_strength("ui_south") - Input.get_action_strength("ui_north")
	return input_vector.normalized()

func physics_wo_acceleration():
	#delta *= DELTA_MULTIPLY
	var input_vector = get_inputvec()
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * speed
	else:
		velocity = Vector2.ZERO
		
	velocity = move_and_slide(velocity)
	
func _process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			pass
		ATTACK:
			attack_state(delta)
	
func move_state(delta):
	if PhysicsWithAcceleration:
		delta *= DELTA_MULTIPLY
		var input_vector = get_inputvec()
		
		if input_vector != Vector2.ZERO:
			animationTree.set("parameters/Idle/blend_position", input_vector)
			animationTree.set("parameters/Run/blend_position", input_vector)
			animationTree.set("parameters/Attack/blend_position", input_vector)
			animationState.travel("Run")
			velocity = velocity.move_toward(input_vector * speed, accel * delta)
		else:
			animationState.travel("Idle")
			velocity = velocity.move_toward(Vector2.ZERO, frict * delta)
			
		print("vel: " + str(velocity))
		velocity = move_and_slide(velocity)
	else:
		physics_wo_acceleration()
		
	## Check input for state change
	if Input.is_action_just_pressed("ui_attack"):
		state = ATTACK
		
func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	pass

func on_attack_finish():
	state = MOVE
