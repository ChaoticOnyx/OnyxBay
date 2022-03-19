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

/obj/machinery/computer/camera_advanced/Initialize()
	..()
	vision = new eye_type(src)
	if(off_action)
		actions += new off_action(src)

/obj/machinery/computer/camera_advanced/Destroy()
	qdel(vision)
	vision = null
	. = ..()

/obj/machinery/computer/camera_advanced/attack_hand(obj/item/I, user)
	..()
	var/mob/living/L = I
	GrantActions(L)
	vision.possess(L)
	GLOB.destroyed_event.register(L, src, /obj/machinery/computer/camera_advanced/proc/release)
	GLOB.logged_out_event.register(L, src, /obj/machinery/computer/camera_advanced/proc/release)

/obj/machinery/computer/camera_advanced/proc/release(mob/living/L)
	vision.release(L)
	for(var/datum/action/A in actions)
		A.Remove(L)
	GLOB.destroyed_event.unregister(L, src)
	GLOB.logged_out_event.unregister(L, src)


/obj/machinery/computer/camera_advanced/proc/GrantActions(mob/living/L)
	for(var/datum/action/action in actions)
		action.Grant(L)

/datum/action/innate/camera_off
	name = "End Camera View"
	button_icon_state = "camera_off"

/datum/action/innate/camera_off/Activate()
	if(!owner || !isliving(owner))
		return
	var/obj/machinery/computer/camera_advanced/origin = target
	origin.release(owner)
