/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	light_color = COLOR_RED_LIGHT

	var/mob/observer/eye/vision
	var/eye_type = /mob/observer/eye/cameranet
	var/list/actions=list()
	/// Typepath of the action button we use as "off"
	/// It's a typepath so subtypes can give it fun new names
	var/datum/action/innate/camera_off/off_action = /datum/action/innate/camera_off
	var/datum/action/innate/camera_reset/reset_action = /datum/action/innate/camera_reset
	var/list/initial_coordinates

/obj/machinery/computer/camera_advanced/Initialize()
	. = ..()
	vision = new eye_type(src)
	initial_coordinates = list(x, y, z)
	if(off_action)
		actions += new off_action(src)
	if(reset_action)
		actions += new reset_action(src)

/obj/machinery/computer/camera_advanced/Destroy()
	qdel(vision)
	vision = null
	. = ..()

/obj/machinery/computer/camera_advanced/attack_ghost(mob/ghost)
	return

/obj/machinery/computer/camera_advanced/attack_ai(mob/user)
	var/mob/living/silicon/ai/AI = user
	AI.destroy_eyeobj()
	attack_hand(user)

/obj/machinery/computer/camera_advanced/attack_hand(obj/item/I, user)
	..()
	if(!vision.owner)
		var/mob/living/L = I
		GrantActions(L)
		vision.possess(L, FALSE)
		register_signal(L, SIGNAL_QDELETING, nameof(.proc/release))
		register_signal(L, SIGNAL_LOGGED_OUT, nameof(.proc/release))
		register_signal(L, SIGNAL_MOB_DEATH, nameof(.proc/release))
		register_signal(L, SIGNAL_MOVED, nameof(.proc/release))

/obj/machinery/computer/camera_advanced/proc/release(mob/living/L)
	vision.release(L)
	for(var/datum/action/A in actions)
		A.Remove(L)

	unregister_signal(L, SIGNAL_QDELETING)
	unregister_signal(L, SIGNAL_LOGGED_OUT)
	unregister_signal(L, SIGNAL_MOB_DEATH)
	unregister_signal(L, SIGNAL_MOVED)


/obj/machinery/computer/camera_advanced/proc/GrantActions(mob/living/L)
	for(var/datum/action/action in actions)
		action.Grant(L)

/datum/action/innate/camera_off
	name = "End Camera View"
	button_icon_state = "camera_off"

/datum/action/innate/camera_off/Activate()
	if(!owner || !isliving(owner))
		return

	var/mob/living/L = owner
	var/obj/machinery/computer/camera_advanced/origin = target

	origin.release(L)

	if(!isAI(L))
		return

	var/mob/living/silicon/ai/AI = L
	AI.create_eyeobj(get_turf(origin.vision))


/datum/action/innate/camera_reset
	name = "Reset Camera View"
	button_icon_state = "camera_reset"

/datum/action/innate/camera_reset/Activate()
	if(!owner || !isliving(owner))
		return
	var/obj/machinery/computer/camera_advanced/origin = target
	origin.vision.forceMove(locate(origin.initial_coordinates[1],origin.initial_coordinates[2],origin.initial_coordinates[3]))
