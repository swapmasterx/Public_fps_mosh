extends Node3D

class_name ALH


var primary_input = true
var altfire_input = true
var ability1_input = true
var ability2_input = true

func enable_lockout(Primary_LC, AltFire_LC, Ability1_LC, Ability2_LC):
	if Primary_LC == true:
		primary_input = false
	if AltFire_LC == true:
		altfire_input = false
	if Ability1_LC == true:
		ability1_input = false
	if Ability2_LC == true:
		ability2_input = false
	return
#Called after fire rate timer
func disable_lockout(Primary_LC, AltFire_LC, Ability1_LC, Ability2_LC):
	if Primary_LC == true:
		primary_input = true
	if AltFire_LC == true:
		altfire_input = true
	if Ability1_LC == true:
		ability1_input = true
	if Ability2_LC:
		ability2_input = true
	return
	
