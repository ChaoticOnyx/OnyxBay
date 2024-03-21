/*
Regenerative extracts:
	Work like a legion regenerative core.
	Has a unique additional effect.
*/
/obj/item/metroidcross/regenerative
	name = "regenerative extract"
	desc = "It's filled with a milky substance, and pulses like a heartbeat."
	effect = "regenerative"
	icon_state = "regenerative"

/obj/item/metroidcross/regenerative/proc/core_effect(mob/living/carbon/human/target, mob/user)
	return
/obj/item/metroidcross/regenerative/proc/core_effect_before(mob/living/carbon/human/target, mob/user)
	return

/obj/item/metroidcross/regenerative/afterattack(atom/target,mob/user,prox)
	. = ..()
	if(!prox || !isliving(target))
		return
	var/mob/living/H = target
	if(H.stat == DEAD)
		to_chat(user, SPAN_WARNING("[src] will not work on the dead!"))
		return
	if(H != user)
		user.visible_message(SPAN_NOTICE("[user] crushes [src] over [H], the milky goo quickly regenerating all of [H] injuries!"),
			SPAN_NOTICE("You squeeze [src], and it bursts over [H], the milky goo regenerating [H] injuries."))
	else
		user.visible_message(SPAN_NOTICE("[user] crushes [src] over [user]self, the milky goo quickly regenerating all of [user] injuries!"),
			SPAN_NOTICE("You squeeze [src], and it bursts in your hand, splashing you with milky goo which quickly regenerates your injuries!"))
	core_effect_before(H, user)
	H.rejuvenate()
	core_effect(H, user)
	playsound(target, 'sound/effects/splat.ogg', 40, TRUE)
	qdel(src)

/obj/item/metroidcross/regenerative/green
	colour = "green" //Has no bonus effect.
	effect_desc = "Fully heals the target and does nothing else."

/obj/item/metroidcross/regenerative/orange
	colour = "orange"
	effect_desc = "Fully heals the target and create ring of fire!"

/obj/item/metroidcross/regenerative/orange/core_effect_before(mob/living/target, mob/user)
	target.visible_message(SPAN_WARNING("The [src] boils over!"))
	for(var/turf/targetturf in orange(2,target))
		targetturf.create_fire()

/obj/item/metroidcross/regenerative/purple
	colour = "purple"
	effect_desc = "Fully heals the target and injects them with some regen jelly."

/obj/item/metroidcross/regenerative/purple/core_effect(mob/living/target, mob/user)
	target.reagents.add_reagent(/datum/reagent/regen_jelly,10)

/obj/item/metroidcross/regenerative/blue
	colour = "blue"
	effect_desc = "Fully heals the target and makes the floor wet."

/obj/item/metroidcross/regenerative/blue/core_effect(mob/living/target, mob/user)
	if(istype(target.loc, /turf/simulated))
		var/turf/simulated/T = target.loc
		T.wet_floor(4)
		target.visible_message(SPAN_WARNING("The milky goo in the extract gets all over the floor!"))

/obj/item/metroidcross/regenerative/metal
	colour = "metal"
	effect_desc = "Fully heals the target and encases the target in a locker."

/obj/item/metroidcross/regenerative/metal/core_effect(mob/living/target, mob/user)
	target.visible_message(SPAN_WARNING("The milky goo hardens and reshapes itself, encasing [target]!"))
	var/obj/structure/closet/C = new /obj/structure/closet(target.loc)
	C.name = "slimy closet"
	C.desc = "Looking closer, it seems to be made of a sort of solid, opaque, metal-like goo."
	target.forceMove(C)

/obj/item/metroidcross/regenerative/yellow
	colour = "yellow"
	effect_desc = "Fully heals the target and fully recharges a single item on the target."

/obj/item/metroidcross/regenerative/yellow/core_effect(mob/living/target, mob/user)
	var/list/batteries = list()
	for(var/obj/item/cell/C in target.get_contents())
		if(C.charge < C.maxcharge)
			batteries += C
	if(batteries.len)
		var/obj/item/cell/ToCharge = pick(batteries)
		ToCharge.charge = ToCharge.maxcharge
		to_chat(target, SPAN_NOTICE("You feel a strange electrical pulse, and one of your electrical items was recharged."))

/obj/item/metroidcross/regenerative/darkpurple
	colour = "dark purple"
	effect_desc = "Fully heals the target and gives them purple clothing if they are naked."

/obj/item/metroidcross/regenerative/darkpurple/core_effect(mob/living/target, mob/user)
	target.equip_to_slot_or_store_or_drop(new /obj/item/clothing/shoes/purple(null), slot_shoes)
	target.equip_to_slot_or_store_or_drop(new /obj/item/clothing/under/color/lightpurple(null), slot_w_uniform)
	target.equip_to_slot_or_store_or_drop(new /obj/item/clothing/gloves/color/purple(null), slot_gloves)
	target.equip_to_slot_or_store_or_drop(new /obj/item/clothing/head/soft/purple(null), slot_head)
	target.visible_message(SPAN_NOTICE("The milky goo congeals into clothing!"))

/obj/item/metroidcross/regenerative/darkblue
	colour = "dark blue"
	effect_desc = "Fully heals the target and fireproofs their clothes."

/obj/item/metroidcross/regenerative/darkblue/core_effect(mob/living/target, mob/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/fireproofed = FALSE
	if(istype(H.get_equipped_item(slot_wear_suit),/obj/item/clothing))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_equipped_item(slot_wear_suit)
		fireproof(C)
	if(istype(H.get_equipped_item(slot_head),/obj/item/clothing))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_equipped_item(slot_head)
		fireproof(C)
	if(fireproofed)
		target.visible_message(SPAN_NOTICE("Some of [target]'s clothing gets coated in the goo, and turns blue!"))

/obj/item/metroidcross/regenerative/darkblue/proc/fireproof(obj/item/clothing/C)
	C.name = "fireproofed [C.name]"
	C.max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	C.heat_protection = C.body_parts_covered

/obj/item/metroidcross/regenerative/silver
	colour = "silver"
	effect_desc = "Fully heals the target and makes their belly feel round and full."

/obj/item/metroidcross/regenerative/silver/core_effect(mob/living/target, mob/user)
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/C = target
		C.nutrition = STOMACH_FULLNESS_HIGH
		to_chat(target, SPAN_NOTICE("You feel satiated."))
	return

/obj/item/metroidcross/regenerative/bluespace
	colour = "bluespace"
	effect_desc = "Fully heals the target and teleports them to where this core was created."
	var/turf/simulated/T

/obj/item/metroidcross/regenerative/bluespace/core_effect(mob/living/target, mob/user)
	var/turf/old_location = get_turf(target)
	if(do_teleport(target, T, 2)) //despite being named a bluespace teleportation method the quantum channel is used to preserve precision teleporting with a bag of holding
		old_location.visible_message(SPAN_WARNING("[target] disappears in a shower of sparks!"))
		to_chat(target, SPAN_DANGER("The milky goo teleports you somewhere it remembers!"))


/obj/item/metroidcross/regenerative/bluespace/Initialize(mapload)
	. = ..()
	T = get_turf(src)

/obj/item/metroidcross/regenerative/sepia
	colour = "sepia"
	effect_desc = "Fully heals the target, but give monochrome."

/obj/item/metroidcross/regenerative/sepia/core_effect_before(mob/living/target, mob/user)
	to_chat(target, SPAN_NOTICE("You try to forget how you feel."))
	ADD_TRAIT(target, /datum/modifier/trait/colorblind_monochrome)

/obj/item/metroidcross/regenerative/cerulean
	colour = "cerulean"
	effect_desc = "Fully heals the target and makes a second regenerative core with no special effects."

/obj/item/metroidcross/regenerative/cerulean/core_effect(mob/living/target, mob/user)
	var/obj/item/metroidcross/X = new /obj/item/metroidcross/regenerative(user.loc)
	user.put_in_active_hand(X)
	to_chat(user, SPAN_NOTICE("Some of the milky goo congeals in your hand!"))

/obj/item/metroidcross/regenerative/pyrite
	colour = "pyrite"
	effect_desc = "Fully heals and randomly colors the target."

/obj/item/metroidcross/regenerative/pyrite/core_effect(mob/living/target, mob/user)
	target.visible_message(SPAN_WARNING("The milky goo coating [target] leaves [target] a different color!"))
	target.color=rgb(rand(0,255),rand(0,255),rand(0,255))

/obj/item/metroidcross/regenerative/red
	colour = "red"
	effect_desc = "Fully heals the target and injects them with some ephedrine."

/obj/item/metroidcross/regenerative/red/core_effect(mob/living/target, mob/user)
	to_chat(target, SPAN_NOTICE("You feel... <i>faster.</i>"))
	target.reagents.add_reagent(/datum/reagent/hyperzine, 15)

/obj/item/metroidcross/regenerative/grey
	colour = "grey"
	effect_desc = "Fully heals the target and changes the spieces or color of a metroid or jellyperson."

/obj/item/metroidcross/regenerative/grey/core_effect(mob/living/target, mob/user)
	if(ismetroid(target))
		target.visible_message(SPAN_WARNING("The [target] suddenly changes color!"))
		var/mob/living/carbon/metroid/S = target
		S.random_colour()
	if(ispromethean(target))
		target.reagents.add_reagent(/datum/reagent/metroidjelly,5)


/obj/item/metroidcross/regenerative/pink
	colour = "pink"
	effect_desc = "Fully heals the target and injects them with some drugs."

/obj/item/metroidcross/regenerative/pink/core_effect(mob/living/target, mob/user)
	to_chat(target, SPAN_NOTICE("You feel more calm."))
	target.reagents.add_reagent(/datum/reagent/space_drugs, 4)

/obj/item/metroidcross/regenerative/gold
	colour = "gold"
	effect_desc = "Fully heals the target and produces a random coin."

/obj/item/metroidcross/regenerative/gold/core_effect(mob/living/target, mob/user)
	var/newcoin = pick(/obj/item/material/coin/silver, /obj/item/material/coin/iron, /obj/item/material/coin/gold, /obj/item/material/coin/diamond, /obj/item/material/coin/plasma, /obj/item/material/coin/uranium)
	var/obj/item/material/coin/C = new newcoin(target.loc)
	playsound(C, 'sound/items/coinflip.ogg', 50, TRUE)
	target.put_in_any_hand_if_possible(C)

/obj/item/metroidcross/regenerative/oil
	colour = "oil"
	effect_desc = "Fully heals the target and flashes everyone in sight."

/obj/item/metroidcross/regenerative/oil/core_effect(mob/living/target, mob/user)
	playsound(src, 'sound/weapons/flash.ogg', 100, TRUE)
	for(var/mob/living/M in view(user,7))
		if(iscarbon(M))
			if(M.stat!=DEAD)
				var/mob/living/carbon/C = M
				var/safety = C.eyecheck()
				if(safety < FLASH_PROTECTION_MODERATE)
					var/flash_strength = (rand(3,7))
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						flash_strength = round(H.species.flash_mod * flash_strength)
					if(flash_strength > 0)
						M.flash_eyes(FLASH_PROTECTION_MODERATE - safety)
						M.Stun(flash_strength / 2)
						M.eye_blurry += flash_strength
						M.confused += (flash_strength + 2)
						if(flash_strength > 3)
							M.drop_l_hand()
							M.drop_r_hand()
						if(flash_strength > 5)
							M.Weaken(2)

/obj/item/metroidcross/regenerative/black
	colour = "black"
	effect_desc = "Fully heals the target and creates an imperfect duplicate of them made of metroid, that fakes their death."

/obj/item/metroidcross/regenerative/black/core_effect_before(mob/living/target, mob/user)

	to_chat(target, SPAN_NOTICE("The milky goo flows from your skin, forming an imperfect copy of you."))

	if(ishuman(target))
		var/mob/living/carbon/human/T = target
		var/mob/living/carbon/human/D = new T.type(target.loc)
		var/list/newUI = T.dna.UI.Copy()
		D.real_name = T.real_name
		D.name = T.name
		D.ClearOverlays()
		D.overlays_standing = T.overlays_standing.Copy()
		D.UpdateAppearance(newUI.Copy())
		D.icon = getFlatIcon(T)
		D.icon_update = FALSE
		D.update_icon = FALSE
		D.adjustBruteLoss(target.getBruteLoss())
		D.adjustFireLoss(target.getFireLoss())
		D.adjustToxLoss(target.getToxLoss())
		D.death()
		addtimer(CALLBACK(D, nameof(/mob.proc/dust)), 300)
		return

	var/mob/living/dummy = new target.type(target.loc)
	dummy.adjustBruteLoss(target.getBruteLoss())
	dummy.adjustFireLoss(target.getFireLoss())
	dummy.adjustToxLoss(target.getToxLoss())
	dummy.death()
	addtimer(CALLBACK(dummy, nameof(/mob.proc/dust)), 300)

/obj/item/metroidcross/regenerative/lightpink
	colour = "light pink"
	effect_desc = "Fully heals the target and also heals the user."

/obj/item/metroidcross/regenerative/lightpink/core_effect(mob/living/target, mob/user)
	if(!isliving(user))
		return
	if(target == user)
		return
	if(target.stat == DEAD)
		to_chat(user, SPAN_WARNING("[src] will not work on the dead!"))
		return
	var/mob/living/U = user
	U.rejuvenate()
	to_chat(U, SPAN_NOTICE("Some of the milky goo sprays onto you, as well!"))

/obj/item/metroidcross/regenerative/adamantine
	colour = "adamantine"
	effect_desc = "Fully heals the target and boosts their armor."

/obj/item/metroidcross/regenerative/adamantine/core_effect(mob/living/target, mob/user) //WIP - Find out why this doesn't work.
	target.add_modifier(/datum/modifier/status_effect/metroidskin)

/obj/item/metroidcross/regenerative/rainbow
	colour = "rainbow"
	effect_desc = "Fully heals the target and temporarily makes them immortal, but pacifistic."

/obj/item/metroidcross/regenerative/rainbow/core_effect(mob/living/target, mob/user)
	target.add_modifier(/datum/modifier/status_effect/rainbow_protection)
