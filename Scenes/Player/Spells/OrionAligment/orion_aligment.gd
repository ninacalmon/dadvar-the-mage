class_name OrionAligment extends BulletHability
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var hability_type: BulletHability.HabilityType = BulletHability.HabilityType.ON_SPAWN

func apply_hability(bullet: Node):
	bullet.modulate = Color.RED
	bullet.bullet_module.spawn_amount = 3
	print("APPLYING ORION HABILITY", bullet)
