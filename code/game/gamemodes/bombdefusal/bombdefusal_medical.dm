// ========== BOMB DEFUSAL - SIMPLIFIED MEDICAL SYSTEM ==========

// Arena mode flag on human mob
/mob/living/carbon/human/var/bombdefusal_arena_mode = FALSE

// Full heal proc - resets all damage for round transitions and revives
/mob/living/carbon/human/proc/arena_full_heal()
	if(!bombdefusal_arena_mode)
		return

	// Use the built-in revive which properly handles:
	// organ restoration, stat reset, dead->living mob list, timeofdeath,
	// health update, icon regen, failed_last_breath, etc.
	revive()

	// Arena-specific extras on top of revive()
	// Reset blood to full
	if(vessel && species)
		vessel.clear_reagents()
		vessel.add_reagent(/datum/reagent/blood, species.blood_volume)

	// Clear embedded objects from external organs
	for(var/obj/item/organ/external/E in organs)
		if(QDELETED(E))
			continue
		E.status = 0
		var/list/to_remove = E.implants?.Copy()
		if(to_remove)
			for(var/obj/item/I in to_remove)
				if(!istype(I, /obj/item/organ))
					E.implants -= I
					qdel(I)

	update_canmove()

// ===== ARENA MEDKIT =====
// Used by medics on teammates. Instant heal, multi-charge, cooldown.

/obj/item/bombdefusal_medkit
	name = "arena medkit"
	desc = "A compact field medkit for rapid combat healing. Use on a teammate."
	icon = 'icons/obj/storage/firstaid.dmi'
	icon_state = "firstaid"
	w_class = ITEM_SIZE_NORMAL
	var/charges = 3
	var/next_use_time = 0
	var/heal_amount = 60
	var/cooldown_time = 100 // 10 seconds

/obj/item/bombdefusal_medkit/attack(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(!istype(target) || !istype(user))
		return ..()

	if(target == user)
		to_chat(user, "<span class='warning'>You can't use this on yourself! Use an arena injector instead.</span>")
		return

	if(!target.bombdefusal_arena_mode)
		to_chat(user, "<span class='warning'>This can only be used on arena participants!</span>")
		return

	if(charges <= 0)
		to_chat(user, "<span class='warning'>The medkit is empty!</span>")
		return

	if(world.time < next_use_time)
		var/time_left = round((next_use_time - world.time) / 10, 0.1)
		to_chat(user, "<span class='warning'>Medkit on cooldown! [time_left]s remaining.</span>")
		return

	// Heal the target
	target.heal_overall_damage(heal_amount, heal_amount)

	// Clear bleeding and pain on external organs
	for(var/obj/item/organ/external/E in target.organs)
		E.status &= ~(ORGAN_BLEEDING)
		// Remove embedded objects
		for(var/obj/item/I in E.implants)
			E.implants -= I
			qdel(I)

	charges--
	next_use_time = world.time + cooldown_time

	to_chat(user, "<span class='notice'>You heal [target.name] with the medkit. [charges] charge(s) remaining.</span>")
	to_chat(target, "<span class='notice'>[user.name] heals you with a medkit!</span>")

	// Check if this is a downed player revive via medkit
	// (Defibs handle the actual revive from downed state)

/obj/item/bombdefusal_medkit/examine(mob/user, infix)
	. = ..()
	. += "It has [charges] charge(s) remaining."
	if(world.time < next_use_time)
		. += "It is on cooldown."

// ===== ARENA INJECTOR =====
// Self-use heal. Single use. Any role can buy.

/obj/item/bombdefusal_injector
	name = "arena stimulant"
	desc = "A single-use combat stimulant. Inject yourself for a quick heal."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "yourinjector"
	w_class = ITEM_SIZE_TINY
	var/heal_amount = 25

/obj/item/bombdefusal_injector/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	if(!user.bombdefusal_arena_mode)
		to_chat(user, "<span class='warning'>This can only be used by arena participants!</span>")
		return

	user.heal_overall_damage(heal_amount, heal_amount)

	// Clear some pain/bleeding
	for(var/obj/item/organ/external/E in user.organs)
		E.status &= ~(ORGAN_BLEEDING)

	to_chat(user, "<span class='notice'>You inject yourself with a combat stimulant. You feel better!</span>")
	qdel(src)

// ===== DEPLOYABLE BARRICADE =====
// Support-exclusive. Uses the syndicate energy barrier but weaker and no explosion on death.

/obj/item/device/energybarrier/arena
	name = "tactical energy barrier"
	desc = "A compact deployable energy barrier. Provides temporary battlefield cover."

/obj/item/device/energybarrier/arena/attack_self(mob/living/user)
	var/obj/structure/energybarrier/arena/E = new(user.loc)
	E.add_fingerprint(user)
	qdel(src)

// Arena version - weaker HP, no explosion on death
/obj/structure/energybarrier/arena
	name = "tactical energy barrier"
	desc = "A deployable energy barrier providing temporary cover. Won't last long under sustained fire."
	health = 120
	maxhealth = 120

/obj/structure/energybarrier/arena/explode()
	visible_message(SPAN("warning", "\The [src] fizzles out!"))
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	// No explosion - just sparks and deletion
