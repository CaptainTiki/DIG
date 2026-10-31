extends Area2D
## A loose ore object that remains in the world until cargo has room for it.

signal collected(amount: int)

@export_range(1, 8, 1) var amount: int = 1

var _claimed: bool = false


func _on_body_entered(body: Node2D) -> void:
    if _claimed or not body is DigPlayer:
        return

    var player := body as DigPlayer
    if not player.try_collect_ore(amount):
        return

    _claimed = true
    set_deferred("monitoring", false)
    collected.emit(amount)
    queue_free()
