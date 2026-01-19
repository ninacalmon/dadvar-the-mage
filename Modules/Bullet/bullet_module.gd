extends Area2D
class_name BulletModule
signal enemy_hit(enemy: Node2D)

@export var lifetime: float
@export var damage: float
@export var bullet_speed: float
@export var spawn_amount: int = 1

@onready var on_hit_events_connected = enemy_hit.get_connections().size()

## Look at target and return the Vector2D pointing torwards it.
func get_bullet_move_direction(start_position: Vector2, target_position: Vector2) -> Vector2:
	look_at(target_position)
	return (target_position - start_position).normalized()
	
## Changes bullet position on game world.
func update_bullet_position(bullet, direction, delta):
	bullet.global_position += direction * bullet_speed * delta

## Updates time since bullet spawn and kills it when lifetime is over.
func update_lifetime(delta: float) -> void:
	self.lifetime -= delta
	if (self.lifetime <= 0):
		get_parent().queue_free()

## If hit something that is Damageable, do the damage.
func _on_body_entered(body: Node2D) -> void:
	if Interface.node_implements_interface(body, Interface.Damageable):
		body.take_damage(self.damage)
		enemy_hit.emit(body)

	if on_hit_events_connected <= 0:
		destroy()

func destroy():
	on_hit_events_connected -= 1
	if on_hit_events_connected > 0:
		return

	get_parent().queue_free()
