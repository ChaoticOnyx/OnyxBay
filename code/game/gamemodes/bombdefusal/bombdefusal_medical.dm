// ========== BOMB DEFUSAL - SIMPLIFIED MEDICAL SYSTEM ==========

// Full heal proc - resets all damage for round transitions and revives
/mob/living/carbon/human/bombdefusal
	snowflake_organs = 0
	var/datum/mind/last_attacker_mind = null

/mob/living/carbon/human/bombdefusal/bullet_act(obj/item/projectile/P, def_zone)
	if(P.firer && isliving(P.firer))
		var/mob/living/L = P.firer
		if(L.mind)
			last_attacker_mind = L.mind
	return ..()

/mob/living/carbon/human/bombdefusal/hit_with_weapon(obj/item/I, mob/living/user, effective_force, hit_zone)
	if(user && isliving(user) && user.mind)
		last_attacker_mind = user.mind
	return ..()

/mob/living/carbon/human/bombdefusal/simple
	snowflake_organs = ORGAN_SNOWFLAKE_SIMPLE

/mob/living/carbon/human/bombdefusal/simplest
	snowflake_organs = ORGAN_SNOWFLAKE_SIMPLEST

/mob/living/carbon/human/bombdefusal/death(gibbed, deathmessage = "seizes up and falls limp...", show_dead_message = "You have died.")
	if(is_ic_dead())
		return

	// Bomb defusal arena mode - notify match of death
	if(mind)
		var/datum/game_mode/bombdefusal/mode = SSticker.mode
		if(istype(mode))
			var/datum/bombdefusal_player_data/pd = mode.get_player_data(mind)
			if(pd && pd.match)
				pd.match.on_player_death(src, last_attacker_mind, gibbed)

	return ..()

/mob/living/carbon/human/bombdefusal/proc/arena_full_heal()
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
	for(var/obj/item/organ/external/E in external_organs)
		if(QDELETED(E))
			continue
		E.status = 0
		var/list/to_remove = E.implants?.Copy()
		if(to_remove)
			for(var/obj/item/I in to_remove)
				if(!istype(I, /obj/item/organ))
					E.implants -= I
					qdel(I)

	// Clear status modifiers (drugs, pain, debuffs that may add their own slowdowns).
	// qdel'ing them runs their cleanup which removes any movespeed_modification they added,
	// so the baseline species/walk/run modifiers stay intact.
	for(var/datum/modifier/M in modifiers)
		modifiers -= M
		qdel(M)
	update_movespeed()

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
	var/cooldown_time = 100 // 10 seconds

/obj/item/bombdefusal_medkit/attack(mob/living/carbon/human/bombdefusal/target, mob/living/carbon/human/bombdefusal/user)
	if(!ismob(target))
		return ..()

	if(!istype(user))
		to_chat(user, SPAN("warning", "This can only be used by arena participants!"))
		return

	if(!istype(target))
		to_chat(user, SPAN("warning", "This can only be used on arena participants!"))
		return

	if(target == user)
		to_chat(user, "<span class='warning'>You can't use this on yourself! Use an arena injector instead.</span>")
		return

	if(charges <= 0)
		to_chat(user, "<span class='warning'>The medkit is empty!</span>")
		return

	if(world.time < next_use_time)
		var/time_left = round((next_use_time - world.time) / 10, 0.1)
		to_chat(user, "<span class='warning'>Medkit on cooldown! [time_left]s remaining.</span>")
		return

	to_chat(user, "<span class='notice'>Applying medkit to [target.name]...</span>")
	if(!do_after(user, cooldown_time, target))
		return

	// Re-check after timer
	if(charges <= 0 || world.time < next_use_time || QDELETED(src))
		return
	if(!istype(target) || !istype(user))
		return

	// Full heal - same as between rounds
	target.arena_full_heal()

	charges--
	next_use_time = world.time + cooldown_time

	to_chat(user, "<span class='notice'>You fully heal [target.name]. [charges] charge(s) remaining.</span>")
	to_chat(target, "<span class='notice'>[user.name] fully heals you with a medkit!</span>")

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
	icon_state = "injector_green"
	w_class = ITEM_SIZE_TINY
	var/heal_amount = 50

/obj/item/bombdefusal_injector/attack(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(!istype(target, /mob/living/carbon/human))
		return ..()

	target.heal_overall_damage(heal_amount, heal_amount)

	// Clear bleeding on external organs
	for(var/obj/item/organ/external/E in target.external_organs)
		E.status &= ~(ORGAN_BLEEDING)

	if(target == user)
		to_chat(user, "<span class='notice'>You inject yourself with a combat stimulant. You feel better!</span>")
	else
		to_chat(user, "<span class='notice'>You inject [target.name] with a combat stimulant.</span>")
		to_chat(target, "<span class='notice'>[user.name] injects you with a combat stimulant!</span>")
	qdel(src)

/obj/item/bombdefusal_injector/attack_self(mob/user)
	attack(user, user)

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
	health = 240
	maxhealth = 240

/obj/structure/energybarrier/arena/explode()
	visible_message(SPAN("warning", "\The [src] fizzles out!"))
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	// No explosion - just sparks and deletion
