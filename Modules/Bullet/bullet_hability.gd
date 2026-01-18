@abstract
class_name BulletHability
extends Resource

enum HabilityType {
	ON_SPAWN,
	ON_CONTACT
}

## Each class that inherits this will need to implement apply hability,
## which is unique for each class.
@abstract func apply_hability(bullet: Node)
