extends CharacterBody3D

@export var move_speed := 5.5
@export var sprint_speed := 8.5
@export var jump_velocity := 7.0
@export var acceleration := 18.0
@export var turn_speed := 9.0

var animation_clock := 0.0
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var torso: Node3D
var weapon_root: Node3D
var muzzle_flash: MeshInstance3D
var recoil_timer := 0.0

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
	var moving := direction.length() > 0.12
	var sprinting := Input.is_action_pressed("sprint")
	var current_speed := sprint_speed if sprinting else move_speed
	velocity.x = move_toward(velocity.x, direction.x * current_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * current_speed, acceleration * delta)
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
	else:
		velocity.y -= 24.0 * delta
	if moving:
		var desired_yaw := atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, desired_yaw, 1.0 - exp(-turn_speed * delta))
	move_and_slide()
	if recoil_timer > 0.0:
		recoil_timer = maxf(0.0, recoil_timer - delta)
		if recoil_timer == 0.0 and is_instance_valid(muzzle_flash):
			muzzle_flash.visible = false
	_update_animation(delta, moving, sprinting)

func _update_animation(delta: float, moving: bool, sprinting: bool) -> void:
	if not is_instance_valid(left_leg):
		return
	if moving and is_on_floor():
		animation_clock += delta * (12.0 if sprinting else 8.0)
		var swing := sin(animation_clock) * (0.72 if sprinting else 0.48)
		left_leg.rotation.x = swing
		right_leg.rotation.x = -swing
		left_arm.rotation.x = -swing * 0.72
		right_arm.rotation.x = swing * 0.72
	else:
		animation_clock = 0.0
		left_leg.rotation.x = move_toward(left_leg.rotation.x, 0.0, delta * 5.0)
		right_leg.rotation.x = move_toward(right_leg.rotation.x, 0.0, delta * 5.0)
		left_arm.rotation.x = move_toward(left_arm.rotation.x, 0.0, delta * 5.0)
		right_arm.rotation.x = move_toward(right_arm.rotation.x, 0.0, delta * 5.0)
	if recoil_timer > 0.0:
		right_arm.rotation.x -= 0.28
	if is_on_floor():
		torso.position.y = lerpf(torso.position.y, 1.18 + (0.025 if moving else 0.0), delta * 8.0)
	else:
		torso.position.y = 1.18

func _build_character() -> void:
	var skin := _mat(Color(0.55, 0.34, 0.22))
	var shirt := _mat(Color(0.08, 0.28, 0.72))
	var pants := _mat(Color(0.12, 0.14, 0.18))
	var shoes := _mat(Color(0.025, 0.025, 0.03))
	torso = Node3D.new()
	torso.name = "TorsoPivot"
	torso.position = Vector3(0, 1.18, 0)
	add_child(torso)
	_add_capsule(torso, "Torso", 0.34, 0.82, Vector3.ZERO, shirt)
	_add_capsule(torso, "Neck", 0.12, 0.22, Vector3(0, 0.48, 0), skin)
	_add_capsule(self, "Head", 0.23, 0.42, Vector3(0, 1.86, 0), skin)

	left_leg = _make_limb("LeftLeg", Vector3(-0.13, 0.58, 0))
	right_leg = _make_limb("RightLeg", Vector3(0.13, 0.58, 0))
	add_child(left_leg)
	add_child(right_leg)
	_add_box(left_leg, "Left thigh", Vector3(0.2, 0.48, 0.24), Vector3(0, -0.12, 0), pants)
	_add_box(left_leg, "Left shoe", Vector3(0.22, 0.12, 0.34), Vector3(0, -0.43, -0.06), shoes)
	_add_box(right_leg, "Right thigh", Vector3(0.2, 0.48, 0.24), Vector3(0, -0.12, 0), pants)
	_add_box(right_leg, "Right shoe", Vector3(0.22, 0.12, 0.34), Vector3(0, -0.43, -0.06), shoes)

	left_arm = _make_limb("LeftArm", Vector3(-0.42, 1.48, 0))
	right_arm = _make_limb("RightArm", Vector3(0.42, 1.48, 0))
	add_child(left_arm)
	add_child(right_arm)
	_add_capsule(left_arm, "Left upper arm", 0.12, 0.64, Vector3(0, -0.25, 0), skin)
	_add_capsule(right_arm, "Right upper arm", 0.12, 0.64, Vector3(0, -0.25, 0), skin)
	_add_capsule(left_arm, "Left sleeve", 0.135, 0.36, Vector3(0, -0.08, 0), shirt)
	_add_capsule(right_arm, "Right sleeve", 0.135, 0.36, Vector3(0, -0.08, 0), shirt)
	_add_box(self, "Hair", Vector3(0.39, 0.16, 0.4), Vector3(0, 2.02, 0.015), _mat(Color(0.035, 0.025, 0.02)))
	_add_box(self, "Jacket stripe", Vector3(0.07, 0.54, 0.025), Vector3(0, 1.2, -0.345), _mat(Color(0.82, 0.72, 0.28)))
	_add_box(self, "Belt", Vector3(0.68, 0.09, 0.38), Vector3(0, 0.78, 0), _mat(Color(0.035, 0.03, 0.025), 0.15, 0.6))
	_add_box(self, "Left eye", Vector3(0.045, 0.055, 0.025), Vector3(-0.075, 1.89, -0.205), _mat(Color(0.025, 0.02, 0.018)))
	_add_box(self, "Right eye", Vector3(0.045, 0.055, 0.025), Vector3(0.075, 1.89, -0.205), _mat(Color(0.025, 0.02, 0.018)))
	_build_deagle()

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.9
	collision.shape = shape
	collision.position.y = 0.95
	add_child(collision)

func _build_deagle() -> void:
	weapon_root = Node3D.new()
	weapon_root.name = "DesertEagle"
	weapon_root.position = Vector3(0.1, -0.48, -0.16)
	weapon_root.rotation.x = -0.08
	right_arm.add_child(weapon_root)
	var steel := _mat(Color(0.24, 0.28, 0.32), 0.82, 0.22)
	var dark_steel := _mat(Color(0.055, 0.065, 0.075), 0.72, 0.28)
	var grip_material := _mat(Color(0.07, 0.045, 0.03), 0.05, 0.9)
	_add_box(weapon_root, "Slide", Vector3(0.14, 0.14, 0.42), Vector3(0, 0.02, -0.16), steel)
	_add_box(weapon_root, "Barrel", Vector3(0.075, 0.075, 0.19), Vector3(0, 0.015, -0.43), dark_steel)
	_add_box(weapon_root, "Grip", Vector3(0.13, 0.25, 0.16), Vector3(0, -0.17, -0.005), grip_material)
	_add_box(weapon_root, "Grip panel", Vector3(0.014, 0.17, 0.12), Vector3(0.073, -0.17, 0.0), steel)
	muzzle_flash = MeshInstance3D.new()
	muzzle_flash.name = "MuzzleFlash"
	var flash_mesh := SphereMesh.new()
	flash_mesh.radius = 0.075
	flash_mesh.height = 0.15
	muzzle_flash.mesh = flash_mesh
	muzzle_flash.material_override = _mat(Color(1.0, 0.62, 0.12))
	muzzle_flash.position = Vector3(0, 0.02, -0.54)
	muzzle_flash.visible = false
	weapon_root.add_child(muzzle_flash)

func play_fire_animation() -> void:
	recoil_timer = 0.11
	if is_instance_valid(muzzle_flash):
		muzzle_flash.visible = true
	right_arm.rotation.x = -0.28

func _make_limb(label: String, pos: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = label
	pivot.position = pos
	return pivot

func _add_capsule(parent: Node3D, label: String, radius: float, height: float, pos: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = label
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.position = pos
	parent.add_child(mesh_instance)

func _add_box(parent: Node3D, label: String, box_size: Vector3, pos: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = label
	var mesh := BoxMesh.new()
	mesh.size = box_size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.position = pos
	parent.add_child(mesh_instance)

func _mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material
