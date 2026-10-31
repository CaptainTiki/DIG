class_name DigEconomy
extends Node
## Credit balance and configurable prices for ore sales and fuel purchases.
## No debt, interest, refinery economy, or upgrades in v0.1.

signal credits_changed(credits: int)

@export_range(0, 9999, 1) var starting_credits: int = 0
@export_range(1, 999, 1) var ore_sale_price: int = 10
@export_range(1, 9999, 1) var fuel_unit_price: int = 25

var credits: int = 0


func _ready() -> void:
    credits = maxi(0, starting_credits)


func add_credits(amount: int) -> void:
    if amount <= 0:
        return
    credits += amount
    credits_changed.emit(credits)


func sell_ore(amount: int) -> int:
    if amount <= 0:
        return 0
    var earnings := amount * ore_sale_price
    add_credits(earnings)
    return earnings


func fuel_purchase_cost(units: int = 1) -> int:
    if units <= 0:
        return 0
    return units * fuel_unit_price


func try_spend(amount: int) -> bool:
    if amount < 0 or credits < amount:
        return false
    if amount == 0:
        return true
    credits -= amount
    credits_changed.emit(credits)
    return true
