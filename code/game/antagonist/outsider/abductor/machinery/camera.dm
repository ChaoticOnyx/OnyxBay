
/////////
/obj/machinery/computer/camera_advanced/abductor
	name = "Human Observation Console"
	var/team_number = 0
	var/obj/machinery/abductor/console/console
	eye_type = /mob/observer/eye/cameranet/abductor
	/// We can't create our actions until after LateInitialize
	/// So we instead do it on the first call to GrantActions
	var/abduct_created = FALSE
	anchored = 1
	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera"
	icon_keyboard = null

/obj/machinery/computer/camera_advanced/abductor/GrantActions(mob/living/carbon/user)
	if(!abduct_created)
		abduct_created = TRUE
		actions += new /datum/action/innate/teleport_in(console.pad)
		actions += new /datum/action/innate/teleport_out(console)
		actions += new /datum/action/innate/teleport_self(console.pad)
		actions += new /datum/action/innate/vest_mode_swap(console)
		actions += new /datum/action/innate/vest_disguise_swap(console)
		actions += new /datum/action/innate/set_droppoint(console)
	..()

/obj/machinery/computer/camera_advanced/abductor/Initialize()
	..()
	var/datum/spawnpoint/arrivals/spawnpoint = new()
	vision = new eye_type(pick(spawnpoint.turfs))

/obj/machinery/computer/camera_advanced/abductor/attack_hand(obj/item/I, user)
	if(isabductor(I))
		..()
	else
		to_chat(user,SPAN_NOTICE("You can't figure out how it's working."))

/mob/observer/eye/cameranet/abductor/possess(mob/user)
	if(owner && owner != user)
		return

	if(owner && owner.eyeobj != src)
		return

	owner = user
	owner.eyeobj = src

	SetName("[owner.name] ([name_sufix])") // Update its name

	if(owner.client)
		owner.client.eye = src

	visualnet.update_eye_chunks(src, TRUE)

/datum/action/innate/teleport_in
///Is the amount of time required between uses

///Is used to compare to world.time in order to determine if the action should early return
	var/use_delay
	name = "Send To"
	button_icon_state = "beam_down"

/datum/action/innate/teleport_in/Activate()
	if(!target || !iscarbon(owner))
		return
	if(world.time < use_delay)
		to_chat(owner, SPAN_WARNING("You must wait [(use_delay - world.time)/10] seconds to use the [target] again!"))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/observer/eye/remote_eye = C.eyeobj
	var/obj/machinery/abductor/pad/P = target

	use_delay = world.time + 60 SECONDS

	P.PadToLoc(remote_eye.loc)

/datum/action/innate/teleport_out
	name = "Retrieve"
	button_icon_state = "beam_up"

/datum/action/innate/teleport_out/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target

	console.TeleporterRetrieve()

/datum/action/innate/teleport_self
///Is the amount of time required between uses
	var/teleport_self_cooldown = 9 SECONDS
	var/use_delay
	name = "Send Self"
	button_icon_state = "beam_down"

/datum/action/innate/teleport_self/Activate()
	if(!target || !iscarbon(owner))
		return
	if(world.time < use_delay)
		to_chat(owner, SPAN_WARNING("You can only teleport to one place at a time!"))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/observer/eye/remote_eye = C.eyeobj
	var/obj/machinery/abductor/pad/P = target

	use_delay = (world.time + teleport_self_cooldown)

	P.MobToLoc(remote_eye.loc, C)

/datum/action/innate/vest_mode_swap
	name = "Switch Vest Mode"
	button_icon_state = "vest_mode"

/datum/action/innate/vest_mode_swap/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target
	console.FlipVest()


/datum/action/innate/vest_disguise_swap
	name = "Switch Vest Disguise"
	button_icon_state = "vest_disguise"

/datum/action/innate/vest_disguise_swap/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = target
	console.SelectDisguise(remote=1)

/datum/action/innate/set_droppoint
	name = "Set Experiment Release Point"
	button_icon_state = "set_drop"

/datum/action/innate/set_droppoint/Activate()
	if(!target || !iscarbon(owner))
		return

	var/mob/living/carbon/human/C = owner
	var/mob/observer/eye/remote_eye = C.eyeobj

	var/obj/machinery/abductor/console/console = target
	console.SetDroppoint(remote_eye.loc,owner)
