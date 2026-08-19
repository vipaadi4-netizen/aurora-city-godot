extends CharacterBody3D

## Third-person explorer controller.
## Keyboard input and the touch joystick both feed the same movement vector.

const SPEED := 8.0
const ACCELERATION := 26.0
const TURN_SPEED := 10.0
var joystick: Control
var camera: Camera3D

func _ready() -> void:
	_build_body()
	_build_camera()

func _build_body() -> void:
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.height = 2.1
	capsule.radius = 0.42
	collider.shape = capsule
	collider.position.y = 1.05
	add_child(collider)
	var mesh := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.height = 2.1
	capsule_mesh.radius = 0.42
	mesh.mesh = capsule_mesh
	mesh.position.y = 1.05
	var suit := StandardMaterial3D.new()
	suit.albedo_color = Color("#63d3e2")
	suit.emission_enabled = true
	suit.emission = Color("#164c59")
	suit.emission_energy_multiplier = 1.5
	mesh.material_override = suit
	add_child(mesh)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 5.4, 8.5)
	camera.rotation_degrees = Vector3(-18, 0, 0)
	camera.current = true
	add_child(camera)

func _physics_process(delta: float) -> void:
	var keyboard_input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var touch_input := Vector2.ZERO
	if joystick and joystick.has_method("get_value"):
		touch_input = joystick.get_value()
	var input_vector := touch_input if touch_input.length() > 0.08 else keyboard_input
	var direction := Vector3(input_vector.x, 0, input_vector.y)
	velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCELERATION * delta)
	if not is_on_floor():
		velocity.y -= 24.0 * delta
	else:
		velocity.y = 0
	if direction.length() > 0.08:
		rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), TURN_SPEED * delta)
	move_and_slide()
	global_position.x = clamp(global_position.x, -145.0, 145.0)
	global_position.z = clamp(global_position.z, -145.0, 145.0)
