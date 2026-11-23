extends CharacterBody3D

@export var move_speed := 5.5
@export var sprint_speed := 8.5
@export var jump_velocity := 7.0
@export var acceleration := 18.0
@export var turn_speed := 9.0

func _ready() -> void:
	_build_character()

func _physics_process(delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left"),
		Input.get_action_strength("brake") - Input.get_action_strength("accelerate")
	)
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
	if direction.length() > 1.0:
		direction = direction.normalized()
	var current_speed := sprint_speed if Input.is_action_pressed("sprint") else move_speed
	velocity.x = move_toward(velocity.x, direction.x * current_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * current_speed, acceleration * delta)
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
	else:
		velocity.y -= 24.0 * delta
	if direction.length() > 0.12:
		var desired_yaw := atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, desired_yaw, 1.0 - exp(-turn_speed * delta))
	move_and_slide()

func _build_character() -> void:
	var skin := _mat(Color(0.55, 0.34, 0.22))
	var shirt := _mat(Color(0.08, 0.28, 0.72))
	var pants := _mat(Color(0.12, 0.14, 0.18))
	var shoes := _mat(Color(0.025, 0.025, 0.03))
	_add_capsule("Torso", 0.34, 0.82, Vector3(0, 1.18, 0), shirt)
	_add_capsule("Head", 0.23, 0.42, Vector3(0, 1.86, 0), skin)
	_add_box("Left leg", Vector3(0.2, 0.62, 0.24), Vector3(-0.13, 0.48, 0), pants)
	_add_box("Right leg", Vector3(0.2, 0.62, 0.24), Vector3(0.13, 0.48, 0), pants)
	_add_box("Left shoe", Vector3(0.22, 0.12, 0.34), Vector3(-0.13, 0.13, -0.06), shoes)
	_add_box("Right shoe", Vector3(0.22, 0.12, 0.34), Vector3(0.13, 0.13, -0.06), shoes)
	_add_capsule("Left arm", 0.12, 0.64, Vector3(-0.42, 1.2, 0), skin)
	_add_capsule("Right arm", 0.12, 0.64, Vector3(0.42, 1.2, 0), skin)
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.9
	collision.shape = shape
	collision.position.y = 0.95
	add_child(collision)

func _add_capsule(label: String, radius: float, height: float, pos: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = label
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.position = pos
	add_child(mesh_instance)

func _add_box(label: String, size: Vector3, pos: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = label
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.position = pos
	add_child(mesh_instance)

func _mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material
