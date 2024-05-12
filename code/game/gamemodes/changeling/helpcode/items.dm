
///// Changeling weapons /////
/obj/item/melee/changeling
	name = "arm weapon"
	desc = "A grotesque weapon made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "arm_blade"
	w_class = ITEM_SIZE_HUGE
	force = 5
	mod_weight = 1.5
	mod_reach = 1.5
	mod_handy = 1.75
	anchored = 1
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	canremove = FALSE
	force_drop = TRUE
	var/mob/living/creator //This is just like ninja swords, needed to make sure dumb shit that removes the sword doesn't make it stay around.
	var/weapType = "weapon"
	var/weapLocation = "arm"

/obj/item/melee/changeling/New(location)
	..()
	if(ismob(loc))
		creator = loc
		creator.visible_message(SPAN("danger", "A grotesque weapon forms around [loc.name]\'s arm!"), \
								null, \
								SPAN("italics", "You hear organic matter ripping and tearing!"))

/obj/item/melee/changeling/Initialize()
	. = ..()
	set_next_think(world.time + 1 SECOND)

/obj/item/melee/changeling/dropped(mob/user)
	user.visible_message(SPAN("danger", "With a sickening crunch, [creator] reforms their arm!"), \
						 SPAN("changeling", "We assimilate the weapon back into our body."), \
						 SPAN("italics", "You hear organic matter ripping and tearing!"))
	playsound(user, 'sound/effects/blob/blobattack.ogg', 30, 1)
	spawn(1)
		qdel(src)

/obj/item/melee/changeling/think()  //Stolen from ninja swords.
	if(!creator || loc != creator ||(creator.l_hand != src && creator.r_hand != src))
		// Tidy up a bit.
		if(istype(loc, /mob/living))
			var/mob/living/carbon/human/host = loc
			if(istype(host))
				for(var/obj/item/organ/external/organ in host.organs)
					for(var/obj/item/O in organ.implants)
						if(O == src)
							organ.implants -= src
			host.pinned -= src
			host.embedded -= src
			host.drop(src, force = TRUE)
		spawn(1)
			qdel(src)

	set_next_think(world.time + 1 SECOND)

/obj/item/melee/changeling/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon_state = "arm_blade"
	force = 25
	armor_penetration = 50 // I guess that's more like a regular knife goes through butter, not a hot one, but hey it's not an esword
	sharp = 1
	edge = 1
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/melee/changeling/arm_blade/greater
	name = "arm greatblade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people and armor as a hot knife through butter."
	force = 35
	armor_penetration = 80

/obj/item/melee/changeling/claw
	name = "hand claw"
	desc = "A grotesque claw made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon_state = "ling_claw"
	armor_penetration = 70
	force = 15
	sharp = 1
	edge = 1
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/melee/changeling/claw/greater
	name = "hand greatclaw"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people and armor as a hot knife through butter."
	force = 20
	armor_penetration = 100

///// Changeling emag /////
/obj/item/finger_lockpick
	name = "finger lockpick"
	desc = "This finger appears to be an organic datajack."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "electric_hand"
	canremove = FALSE
	force_drop = TRUE

/obj/item/finger_lockpick/Initialize()
	. = ..()
	if(ismob(loc))
		to_chat(loc, SPAN("changeling", "We shape our finger to fit inside electronics, and are ready to force them open."))

/obj/item/finger_lockpick/dropped(mob/user)
	to_chat(user, SPAN("changeling", "We discreetly shape our finger back to a less suspicious form."))
	spawn(1)
		qdel(src)

/obj/item/finger_lockpick/afterattack(atom/target, mob/living/user, proximity)
	if(!target)
		return
	if(!proximity)
		return
	if(!user.mind.changeling)
		return

	var/datum/changeling/changeling = user.mind.changeling
	var/datum/changeling_power/item/lockpick/source_power = changeling.get_changeling_power_by_name("Bioelectric Lockpick")
	if(!source_power)
		log_debug("Changeling Shenanigans: [user] ([user.key]) had no Bioelectric Lockpick power while trying to use a finger_lockpick.")
		return

	if(changeling.chem_charges < source_power.fingerpick_cost)
		to_chat(user, SPAN("changeling", "We require more chemicals to do that."))
		return

	if(world.time < source_power.last_time_used + source_power.fingerpick_cooldown)
		to_chat(user, SPAN("changeling", "\The [src] is still recharging, we have to wait!"))
		return
	else
		source_power.last_time_used = world.time

	//Airlocks require an ugly block of code, but we don't want to just call emag_act(), since we don't want to break airlocks forever.
	if(istype(target,/obj/machinery/door))
		var/obj/machinery/door/door = target
		to_chat(user, SPAN("changeling", "We send an electrical pulse up our finger, and into \the [target], attempting to open it."))

		if(door.density && door.operable())
			door.do_animate("spark")
			sleep(6)
			//More typechecks, because windoors can't be locked.  Fun.
			if(istype(target,/obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/airlock = target

				if(airlock.locked) //Check if we're bolted.
					airlock.unlock()
					to_chat(user, SPAN("changeling", "We've unlocked \the [airlock]. Another pulse is requried to open it."))
				else	//We're not bolted, so open the door already.
					airlock.open()
					to_chat(user, SPAN("changeling", "We've opened \the [airlock]."))
			else
				door.open() //If we're a windoor, open the windoor.
				to_chat(user, SPAN("changeling", "We've opened \the [door]."))
		else //Probably broken or no power.
			to_chat(user, SPAN("changeling", "The door does not respond to the pulse."))

		door.add_fingerprint(user)
		log_and_message_admins("finger-lockpicked \an [door].")
		source_power.use_chems(source_power.fingerpick_cost)
	else if(istype(target, /obj/)) //This should catch everything else we might miss, without a million typechecks.
		var/obj/O = target
		to_chat(user, SPAN("changeling", "We send an electrical pulse up our finger, and into \the [O]."))
		O.add_fingerprint(user)
		O.emag_act(1, user, src)
		log_and_message_admins("finger-lockpicked \an [O].")
		source_power.use_chems(source_power.fingerpick_cost)

	return
