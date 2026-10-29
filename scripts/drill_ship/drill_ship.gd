class_name DrillShip
extends AnimatableBody2D
## The ship's body will move through the world in milestone D.
## The safe zone is the only implemented ship behavior for now.

signal player_entered
signal player_exited


func _on_safe_zone_body_entered(body: Node2D) -> void:
    if body is DigPlayer:
        player_entered.emit()


func _on_safe_zone_body_exited(body: Node2D) -> void:
    if body is DigPlayer:
        player_exited.emit()
