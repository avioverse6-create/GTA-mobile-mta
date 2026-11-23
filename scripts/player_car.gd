extends CharacterBody3D

@export var acceleration := 18.0
@export var reverse_acceleration := 10.0
@export var max_speed := 34.0
@export var steering_speed := 1.8
@export var friction := 8.0

var speed := 0.0
var body_color := Color(0.035, 0.28, 0.72)

func _ready() -> void:
	_build_car()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.9, 1.0, 4.1)
	collision.shape = shape
	collision.position.y = 0.65
	add_child(collision)

func _physics_process(delta: float) -> void:
	var throttle := Input.get_action_strength("accelerate") - Input.get_action_strength("brake")
	if throttle > 0.0:
		speed = move_toward(speed, max_speed, acceleration * delta)
	elif throttle < 0.0:
		speed = move_toward(speed, -max_speed * 0.32, reverse_acceleration * delta)
	else:
		speed = move_toward(speed, 0.0, friction * delta)

	var steer := Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
	if absf(speed) > 0.5:
		rotate_y(steer * steering_speed * delta * clampf(absf(speed) / 8.0, 0.25, 1.0) * signf(speed))

	var forward := -global_transform.basis.z
	velocity.x = forward.x * speed
	velocity.z = forward.z * speed
	velocity.y -= 24.0 * delta
	move_and_slide()

func _build_car() -> void:
	var blue := _mat(Color(0.025, 0.16, 0.62), 0.22, 0.35)
	var glass := _mat(Color(0.035, 0.075, 0.11), 0.12, 0.08)
	var black := _mat(Color(0.012, 0.014, 0.02), 0.72)
	var rubber := _mat(Color(0.018, 0.02, 0.024), 0.95)
	var alloy := _mat(Color(0.68, 0.74, 0.8), 0.22, 0.75)
	var light := _mat(Color(0.82, 0.94, 1.0), 0.18, 0.1, true)
	var red := _mat(Color(0.8, 0.025, 0.018), 0.2, 0.1, true)

	_add_box("Lower chassis", Vector3(1.82, 0.42, 3.9), Vector3(0, 0.55, 0), blue)
	_add_box("Sculpted hood", Vector3(1.78, 0.28, 1.25), Vector3(0, 0.88, -1.25), blue)
	_add_box("Rear deck", Vector3(1.78, 0.3, 0.82), Vector3(0, 0.88, 1.48), blue)
	_add_box("Cabin", Vector3(1.48, 0.72, 1.72), Vector3(0, 1.22, 0.12), glass)
	_add_box("Roof", Vector3(1.42, 0.12, 1.2), Vector3(0, 1.62, 0.12), blue)
	_add_box("Front bumper", Vector3(1.9, 0.22, 0.18), Vector3(0, 0.43, -2.02), black)
	_add_box("Rear bumper", Vector3(1.9, 0.22, 0.18), Vector3(0, 0.43, 2.02), black)
	_add_box("Front grille", Vector3(0.72, 0.16, 0.035), Vector3(0, 0.67, -2.105), black)
	_add_box("Rear spoiler", Vector3(1.55, 0.07, 0.22), Vector3(0, 1.23, 1.88), black)

	for x in [-0.62, 0.62]:
		_add_box("Headlight", Vector3(0.43, 0.13, 0.06), Vector3(x, 0.88, -1.91), light)
		_add_box("Tail light", Vector3(0.43, 0.13, 0.06), Vector3(x, 0.88, 1.91), red)

	for x in [-0.98, 0.98]:
		for z in [-1.32, 1.32]:
			_add_wheel(Vector3(x, 0.48, z), rubber, alloy)

func _add_box(label: String, size: Vector3, pos: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = label
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.position = pos
	add_child(mesh_instance)

func _add_wheel(pos: Vector3, tire: Material, rim: Material) -> void:
	var wheel := MeshInstance3D.new()
	wheel.name = "Sport wheel"
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.39
	cylinder.bottom_radius = 0.39
	cylinder.height = 0.22
	cylinder.radial_segments = 24
	wheel.mesh = cylinder
	wheel.material_override = tire
	wheel.position = pos
	wheel.rotation_degrees.z = 90
	add_child(wheel)

	var hub := MeshInstance3D.new()
	var hub_mesh := CylinderMesh.new()
	hub_mesh.top_radius = 0.2
	hub_mesh.bottom_radius = 0.2
	hub_mesh.height = 0.235
	hub_mesh.radial_segments = 20
	hub.mesh = hub_mesh
	hub.material_override = rim
	hub.position = pos
	hub.rotation_degrees.z = 90
	add_child(hub)

func _mat(color: Color, metallic := 0.0, roughness := 0.5, emission := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	if emission:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.4
	return material
