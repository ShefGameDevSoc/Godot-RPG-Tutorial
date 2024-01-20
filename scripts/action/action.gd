class_name Action
extends Resource

enum Target { EVERYONE, ALLIES, OPPONENTS, SELF, NOT_SELF }
enum Type { ATTACK, HEALING }

@export var name: String = "New Action"
@export var targets := Target.NOT_SELF
@export var type := Type.ATTACK

@export var cannot_miss := false
@export var accuracy: int = 100

@export_group("Attack")
@export var power: int = 50

@export_group("Heal")
@export var heal_by_points := true
@export var health_points: int
@export_range(0.0, 1.0) var heal_ratio: float
