/datum/spell/camera_connection/god_vision
	name = "All Seeing Eye"
	desc = "See what your master sees."

	charge_max = 10
	spell_flags = Z2NOCAST
	invocation = "none"
	invocation_type = SPI_NONE

	eye_type = /mob/observer/eye

	icon_state = "gen_mind"

/datum/spell/camera_connection/god_vision/set_connected_god(mob/living/deity/god)
	..()
	vision.visualnet = god.eyeobj.visualnet

/datum/spell/camera_connection/god_vision/Destroy()
	vision.visualnet = null
	return ..()
