//Hypercharged slime cell - Charged Yellow
/obj/item/cell/high/slime_hypercharged
	name = "hypercharged slime core"
	desc = "A charged yellow slime extract, infused with plasma. It almost hurts to touch."
	icon = 'icons/mob/simple/slimes.dmi'
	icon_state = "yellow slime extract"
	maxcharge = 3000

//Barrier cube - Chilling Grey
/obj/item/barriercube
	name = "barrier cube"
	desc = "A compressed cube of slime. When squeezed, it grows to massive size!"
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "barriercube"
	w_class = ITEM_SIZE_TINY

/obj/item/barriercube/attack_self(mob/user)
	if(locate(/obj/structure/barricade/slime) in get_turf(loc))
		to_chat(user, SPAN_WARNING("You can't fit more than one barrier in the same space!"))
		return
	to_chat(user, SPAN_NOTICE("You squeeze [src]."))
	var/obj/B = new /obj/structure/barricade/slime(get_turf(loc))
	B.visible_message(SPAN_WARNING("[src] suddenly grows into a large, gelatinous barrier!"))
	qdel(src)

//Slime barricade - Chilling Grey
/obj/structure/barricade/slime
	name = "gelatinous barrier"
	desc = "A huge chunk of grey slime. Bullets might get stuck in it."
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "slimebarrier"
	maxhealth = 60

//Slime forcefield - Chilling Metal
/obj/effect/forcefield/slimewall
	name = "solidified gel"
	desc = "A mass of solidified slime gel - completely impenetrable, but it's melting away!"
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "slimebarrier_thick"

//Slime clone - Chilling Cerulean
/datum/modifier/metroid_clone
	name = "metroid_cloned"
	var/mob/living/clone
	var/datum/mind/originalmind //For when the clone gibs.

/datum/modifier/metroid_clone/on_applied()
	var/typepath = holder.type
	clone = new typepath(holder.loc)
	var/mob/living/carbon/O = holder
	var/mob/living/carbon/C = clone
	if(istype(C) && istype(O))
		C.real_name = O.real_name
		C.setDNA(O.getDNA())

	if(holder.mind)
		originalmind = holder.mind
		holder.mind.transfer_to(clone)
	clone.add_modifier(/datum/modifier/metroid_clone_decay)
	return ..()

/datum/modifier/metroid_clone/tick()
	if(!istype(clone) || clone.stat != CONSCIOUS)
		holder.remove_specific_modifier(src)

/datum/modifier/metroid_clone/on_remove()
	if(clone?.mind && holder)
		clone.mind.transfer_to(holder)
	else
		if(holder && originalmind)
			originalmind.transfer_to(holder)
			if(originalmind.key)
				holder.ckey = originalmind.key
	if(clone)
		for(var/obj/item/I in clone.get_equipped_items())
			clone.drop(I, force = TRUE)
		qdel(clone)

/datum/modifier/metroid_clone_decay
	name = "metroid_clonedecay"

/datum/modifier/metroid_clone_decay/on_applied()
	holder.throw_alert("\ref[holder]_clone_decay", /obj/screen/movable/alert/clone_decay)

/datum/modifier/metroid_clone_decay/tick()
	holder.adjustToxLoss(1)
	holder.adjustOxyLoss(1)
	holder.adjustBruteLoss(1)
	holder.adjustFireLoss(1)
	holder.color = "#007BA7"

/obj/screen/movable/alert/clone_decay
	name = "Clone Decay"
	desc = "You are simply a construct, and cannot maintain this form forever. You will be returned to your original body if you should fall."
	icon_state = "metroid_clonedecay"

//Frozen stasis - Chilling Dark Blue
/obj/structure/ice_stasis
	name = "ice block"
	desc = "A massive block of ice. You can see something vaguely humanoid inside."
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "frozen"
	density = TRUE
	var/health = 100

/obj/structure/ice_stasis/attack_generic(mob/user, damage, attack_verb, wallbreaker)
	health -= damage
	if(health<=0)
		Destroy()

/obj/structure/ice_stasis/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/magic/ethereal_exit.ogg', 50, TRUE)

/obj/structure/ice_stasis/Destroy()
	for(var/atom/movable/M in contents)
		M.forceMove(loc)
	playsound(src, 'sound/effects/glassbr3.ogg', 50, TRUE)
	return ..()

/obj/screen/movable/alert/status_effect/freon/stasis
	name = "Frozen Solid"
	desc = "You're frozen inside of a protective ice cube! While inside, you can't do anything, but are immune! Resist to get out."
	icon_state = "frozen"

/datum/modifier/frozenstasis
	name = "slime_frozen"
	var/obj/structure/ice_stasis/cube

/datum/modifier/frozenstasis/on_apply()
	holder.throw_alert("\ref[holder]_frozenstasis", /obj/screen/movable/alert/clone_decay)
	register_signal(holder, SIGNAL_MOB_RESIST, .proc/breakCube)
	cube = new /obj/structure/ice_stasis(get_turf(holder))
	holder.forceMove(cube)
	holder.status_flags |= GODMODE

/datum/modifier/frozenstasis/tick()
	if(!cube || holder.loc != cube)
		holder.remove_specific_modifier(src)

/datum/modifier/frozenstasis/proc/breakCube()
	holder.remove_specific_modifier(src)

/datum/modifier/frozenstasis/on_remove()
	if(cube)
		qdel(cube)
	holder.status_flags &= ~GODMODE

	unregister_signal(holder, SIGNAL_MOB_RESIST)
