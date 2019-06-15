/spell/hand/slippery_surface
	name = "Slippery Surface"
	desc = "More of a practical joke than an actual spell."
	school = "transmutation"
	feedback = "su"
	range = 5
	spell_flags = 0
	invocation_type = SpI_NONE
	show_message = " snaps their fingers."
	spell_delay = 50
	hud_state = "gen_ice"
	level_max = list(Sp_TOTAL = 0, Sp_SPEED = 0, Sp_POWER = 0)

/spell/hand/slippery_surface/cast_hand(var/atom/a, var/mob/user)
	for(var/turf/simulated/T in view(1,a))
		T.wet_floor(50)
	return ..()