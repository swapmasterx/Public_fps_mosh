extends RigidBody3D
class_name PhysProp

func impulse_transfer(direction,damage,position):
	print ("prop moved")
	var hitPos = position - get_global_transform().origin
	apply_impulse((direction+damage),hitPos)
