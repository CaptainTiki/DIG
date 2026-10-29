class_name DigEconomy
extends Node
## Basic balance API for future ore sales and fuel purchases.
## No debt, interest, refinery economy, or transaction UI yet.

signal credits_changed(credits: int)

var credits: int = 0


func add_credits(amount: int) -> void:
    if amount <= 0:
        return

    credits += amount
    credits_changed.emit(credits)


func try_spend(amount: int) -> bool:
    if amount < 0 or credits < amount:
        return false

    credits -= amount
    credits_changed.emit(credits)
    return true
