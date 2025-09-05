extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Debug arrow variables
var debug_arrow: MeshInstance3D
var arrow_material: StandardMaterial3D

func _ready():
	# Create debug arrow to show front direction
	create_debug_arrow()

func create_debug_arrow():
	# Create a simple arrow mesh pointing forward (positive Z)
	debug_arrow = MeshInstance3D.new()
	add_child(debug_arrow)
	
	# Create a simple box mesh to represent the arrow
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.1, 0.1, 0.5)  # Thin and long to look like an arrow
	debug_arrow.mesh = box_mesh
	
	# Position the arrow in front of the player
	debug_arrow.position = Vector3(0, 0.5, -0.5)  # Slightly above and in front
	
	# Create a bright material so it's easy to see
	arrow_material = StandardMaterial3D.new()
	arrow_material.albedo_color = Color.RED
	arrow_material.flags_unshaded = true  # Make it always bright
	debug_arrow.material_override = arrow_material

func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = Vector2.ZERO
	# WASD input
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	
	var direction: Vector3 = Vector3.ZERO
	if input_dir.length() > 0.0:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Move
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()

func _input(event):
	# Handle right mouse button turning
	if event is InputEventMouseMotion and Input.is_action_pressed("turn_player"):
		# Rotate the player based on mouse movement
		rotate_y(-event.relative.x * mouse_sensitivity)
