class_name DigPlayer
extends CharacterBody2D
## Scaffold movement only. Mining, cargo, O2, shared battery, and jetpack
## are future milestones; don't treat this as a tuned movement controller.

@export var move_speed: float = 170.0
@export var jump_velocity: float = -305.0
@export var gravity: float = 900.0


func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta

    velocity.x = Input.get_axis("ui_left", "ui_right") * move_speed

    if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
        velocity.y = jump_velocity

    move_and_slide()
