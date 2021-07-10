
// For changeling names generation
var/global/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

// Using in: /mob/living/carbon/human/proc/changeling_rapidregen()
/datum/rapidregen
	var/heals = 10
	var/mob/living/carbon/human/H = null
	var/datum/changeling/C = null

/datum/rapidregen/New(mob/_M)
	H = _M
	C = _M.mind.changeling
	START_PROCESSING(SSprocessing, src)

/datum/rapidregen/Destroy()
	H = null
	C = null
	return ..()

/datum/rapidregen/Process()
	if(QDELETED(H))
		qdel(src)
		return
	if(heals)
		H.adjustBruteLoss(-5)
		H.adjustToxLoss(-5)
		H.adjustOxyLoss(-5)
		H.adjustFireLoss(-5)
		--heals
	else
		C?.rapidregen_active = FALSE
		qdel(src)

///// Changeling reagents /////
/datum/reagent/toxin/cyanide/change_toxin //Fast and Lethal
	name = "Changeling reagent"
	description = "A highly toxic chemical extracted from strange alien-looking biostructure."
	taste_mult = 0.6
	reagent_state = LIQUID
	color = "#cf3600"
	strength = 30
	metabolism = REM * 0.5
	target_organ = BP_HEART

/datum/reagent/toxin/cyanide/change_toxin/biotoxin //Fast and Lethal
	name = "Strange biotoxin"
	description = "Destroys any biological tissue in seconds."
	taste_mult = 0.6
	reagent_state = LIQUID
	color = "#cf3600"
	strength = 80
	metabolism = REM * 0.5
	target_organ = BP_BRAIN

/datum/reagent/toxin/cyanide/change_toxin/biotoxin/affect_blood(mob/living/carbon/M, alien, removed)
	..()
	var/datum/changeling/changeling = M.mind.changeling
	if(changeling)
		M.mind.changeling.true_dead = 1
		M.mind.changeling.geneticpoints = 0
		M.mind.changeling.chem_storage = 0
		M.mind.changeling.chem_recharge_rate = 0

/datum/reagent/rezadone/change_reviver
	name = "Strange bioliquid"
	description = "Smells like acetone."
	taste_description = "sourness"
	reagent_state = LIQUID
	color = "#cb68fc"
	overdose = 4
	scannable = 1
	metabolism = 0.05
	ingest_met = 0.02
	flags = IGNORE_MOB_SIZE

/datum/reagent/rezadone/change_reviver/affect_blood(mob/living/carbon/M, alien, removed)
	..()
	if(prob(1))
		var/datum/antagonist/changeling/a = new
		a.add_antagonist(M.mind, ignore_role = TRUE, do_not_equip = TRUE)

/datum/reagent/rezadone/change_reviver/overdose(mob/living/carbon/M, alien)
	..()
	M.revive()

///// Changeling reagets recipes /////
/datum/chemical_reaction/change_reviver
	name = "Strange bioliquid"
	result = /datum/reagent/rezadone/change_reviver
	required_reagents = list(/datum/reagent/toxin/cyanide/change_toxin = 5, /datum/reagent/dylovene = 5, /datum/reagent/cryoxadone = 5)
	result_amount = 5

/datum/chemical_reaction/Biotoxin
	name = "Strange biotoxin"
	result = /datum/reagent/toxin/cyanide/change_toxin/biotoxin
	required_reagents = list(/datum/reagent/toxin/cyanide/change_toxin = 5, /datum/reagent/toxin/plasma = 5, /datum/reagent/mutagen = 5)
	result_amount = 3

///// Changeling weapons /////
/obj/item/weapon/melee/changeling
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
	throw_speed = 0
	var/mob/living/creator //This is just like ninja swords, needed to make sure dumb shit that removes the sword doesn't make it stay around.
	var/weapType = "weapon"
	var/weapLocation = "arm"

/obj/item/weapon/melee/changeling/New(location)
	..()
	if(ismob(loc))
		creator = loc
		creator.visible_message(SPAN("danger", "A grotesque weapon forms around [loc.name]\'s arm!"), \
								null, \
								SPAN("italics", "You hear organic matter ripping and tearing!"))

/obj/item/weapon/melee/changeling/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/melee/changeling/dropped(mob/user)
	user.visible_message(SPAN("danger", "With a sickening crunch, [creator] reforms their arm!"), \
						 SPAN("changeling", "We assimilate the weapon back into our body."), \
						 SPAN("italics", "You hear organic matter ripping and tearing!"))
	playsound(src, 'sound/effects/blob/blobattack.ogg', 30, 1)
	spawn(1)
		if(src)
			qdel(src)

/obj/item/weapon/melee/changeling/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/weapon/melee/changeling/Process()  //Stolen from ninja swords.
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
			host.drop_from_inventory(src)
		spawn(1)
			if(src)
				qdel(src)

/obj/item/weapon/melee/changeling/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon_state = "arm_blade"
	force = 25
	armor_penetration = 15
	sharp = 1
	edge = 1
	anchored = 1
	canremove = 0
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/melee/changeling/arm_blade/greater
	name = "arm greatblade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people and armor as a hot knife through butter."
	force = 35
	armor_penetration = 20

/obj/item/weapon/melee/changeling/claw
	name = "hand claw"
	desc = "A grotesque claw made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon_state = "ling_claw"
	armor_penetration = 20
	force = 15
	sharp = 1
	edge = 1
	canremove = 0
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/melee/changeling/claw/greater
	name = "hand greatclaw"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people and armor as a hot knife through butter."
	force = 20
	armor_penetration = 50
	anchored = 1

///// Changeling emag /////
/obj/item/weapon/finger_lockpick
	name = "finger lockpick"
	desc = "This finger appears to be an organic datajack."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "electric_hand"

/obj/item/weapon/finger_lockpick/New()
	if(ismob(loc))
		to_chat(loc, SPAN("changeling", "We shape our finger to fit inside electronics, and are ready to force them open."))

/obj/item/weapon/finger_lockpick/dropped(mob/user)
	to_chat(user, SPAN("changeling", "We discreetly shape our finger back to a less suspicious form."))
	spawn(1)
		if(src)
			qdel(src)

/obj/item/weapon/finger_lockpick/afterattack(atom/target, mob/living/user, proximity)
	if(!target)
		return
	if(!proximity)
		return
	if(!user.mind.changeling)
		return

	var/datum/changeling/ling_datum = user.mind.changeling

	if(ling_datum.chem_charges < 10)
		to_chat(user, SPAN("changeling", "We require more chemicals to do that."))
		return

	if(world.time < ling_datum.FLP_last_time_used + 10 SECONDS)
		to_chat(user, SPAN("changeling", "The finger lockpick is still recharging, we have to wait!"))
		return
	else
		ling_datum.FLP_last_time_used = world.time

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
		ling_datum.chem_charges -= 10
	else if(istype(target, /obj/)) //This should catch everything else we might miss, without a million typechecks.
		var/obj/O = target
		to_chat(user, SPAN("changeling", "We send an electrical pulse up our finger, and into \the [O]."))
		O.add_fingerprint(user)
		O.emag_act(1, user, src)
		log_and_message_admins("finger-lockpicked \an [O].")
		ling_datum.chem_charges -= 10

	return
