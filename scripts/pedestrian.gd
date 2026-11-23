extends CharacterBody3D

@export var walk_speed := 1.6
@export var wander_radius := 1.2

var home_position := Vector3.ZERO
var destination := Vector3.ZERO
var choose_timer := 0.0
var animation_clock := 0.0
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var body_color := Color(0.2, 0.42, 0.62)
var health := 100.0
var is_dead := false
var death_timer := 0.0

func _ready() -> void:
	add_to_group("pedestrians")
	health = 100.0
	home_position = global_position
	destination = home_position
	_build_person()
	_choose_destination()

func _process(delta: float) -> void:
	if is_dead:
		death_timer -= delta
		if death_timer <= 0.0:
			queue_free()

func take_damage(amount: float) -> bool:
	if is_dead:
		return true
	health = maxf(0.0, health - amount)
	if health <= 0.0:
		is_dead = true
		death_timer = 2.5
		set_physics_process(false)
		collision_layer = 0
		collision_mask = 0
		rotation.x = -PI * 0.5
		return true
	return false

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	choose_timer -= delta
	var flat_target := destination - global_position
	flat_target.y = 0.0
	if choose_timer <= 0.0 or flat_target.length() < 0.7:
		_choose_destination()
		flat_target = destination - global_position
		flat_target.y = 0.0
	var direction := flat_target.normalized() if flat_target.length() > 0.1 else Vector3.ZERO
	velocity.x = direction.x * walk_speed
	velocity.z = direction.z * walk_speed
	velocity.y -= 24.0 * delta
	if direction.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 3.0)
	move_and_slide()
	_animate(delta, direction.length() > 0.1 and is_on_floor())

func _choose_destination() -> void:
	var angle := randf() * TAU
	var distance := randf_range(0.4, wander_radius)
	destination = home_position + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
	choose_timer = randf_range(3.0, 7.0)

func _animate(delta: float, walking: bool) -> void:
	if walking:
		animation_clock += delta * 5.5
		var swing := sin(animation_clock) * 0.38
		left_leg.rotation.x = swing
		right_leg.rotation.x = -swing
		left_arm.rotation.x = -swing * 0.65
		right_arm.rotation.x = swing * 0.65
	else:
		left_leg.rotation.x = move_toward(left_leg.rotation.x, 0.0, delta * 3.0)
		right_leg.rotation.x = move_toward(right_leg.rotation.x, 0.0, delta * 3.0)
		left_arm.rotation.x = move_toward(left_arm.rotation.x, 0.0, delta * 3.0)
		right_arm.rotation.x = move_toward(right_arm.rotation.x, 0.0, delta * 3.0)

func _build_person() -> void:
	var skin := _mat(Color(0.58, 0.38, 0.27))
	var shirt := _mat(body_color)
	var pants := _mat(Color(0.12, 0.14, 0.17))
	var shoes := _mat(Color(0.025, 0.025, 0.03))
	_add_capsule("Body", 0.32, 0.78, Vector3(0, 1.18, 0), shirt)
	_add_capsule("Head", 0.22, 0.4, Vector3(0, 1.85, 0), skin)
	left_leg = _pivot("LeftLeg", Vector3(-0.13, 0.58, 0))
	right_leg = _pivot("RightLeg", Vector3(0.13, 0.58, 0))
	left_arm = _pivot("LeftArm", Vector3(-0.4, 1.48, 0))
	right_arm = _pivot("RightArm", Vector3(0.4, 1.48, 0))
	add_child(left_leg)
	add_child(right_leg)
	add_child(left_arm)
	add_child(right_arm)
	_add_box(left_leg, "Leg", Vector3(0.2, 0.55, 0.23), Vector3(0, -0.16, 0), pants)
	_add_box(right_leg, "Leg", Vector3(0.2, 0.55, 0.23), Vector3(0, -0.16, 0), pants)
	_add_box(left_leg, "Shoe", Vector3(0.22, 0.12, 0.32), Vector3(0, -0.44, -0.05), shoes)
	_add_box(right_leg, "Shoe", Vector3(0.22, 0.12, 0.32), Vector3(0, -0.44, -0.05), shoes)
	_add_capsule(left_arm, "Arm", 0.11, 0.62, Vector3(0, -0.24, 0), skin)
	_add_capsule(right_arm, "Arm", 0.11, 0.62, Vector3(0, -0.24, 0), skin)
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.34
	shape.height = 1.85
	collision.shape = shape
	collision.position.y = 0.92
	add_child(collision)

func _pivot(label: String, pos: Vector3) -> Node3D:
	var node := Node3D.new()
	node.name = label
	node.position = pos
	return node

func _add_capsule(label: String, radius: float, height: float, pos: Vector3, material: Material) -> void:
	var node := MeshInstance3D.new()
	node.name = label
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	node.mesh = mesh
	node.material_override = material
	node.position = pos
	add_child(node)

func _add_box(parent: Node3D, label: String, box_size: Vector3, pos: Vector3, material: Material) -> void:
	var node := MeshInstance3D.new()
	node.name = label
	var mesh := BoxMesh.new()
	mesh.size = box_size
	node.mesh = mesh
	node.material_override = material
	node.position = pos
	parent.add_child(node)

func _mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material
