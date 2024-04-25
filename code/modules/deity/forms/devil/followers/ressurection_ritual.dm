#define RUNE_DRAW_COOLDOWN 8 SECONDS

/datum/action/cooldown/spell/ressurection_ritual
	name = "Ressurection Ritual"
	button_icon_state = "statue"
	click_to_activate = TRUE
	cast_range = 1

/datum/action/cooldown/spell/ressurection_ritual/is_valid_target(atom/cast_on)
	if(!isfloor(cast_on))
		cast_on.show_splash_text(usr, "Must be cast on a floor!", SPAN_WARNING("This spell must be cast on a floor!"))
		return FALSE

	if(locate(/obj/effect/ressurection_rune) in cast_on)
		cast_on.show_splash_text(usr, "Must be cast on a floor!", SPAN_WARNING("This spell must be cast on a floor!"))
		return FALSE

	return ..()

/datum/action/cooldown/spell/ressurection_ritual/cast(turf/cast_on)
	cast_on.show_splash_text(usr, "Drawing...", SPAN_WARNING("You start drawing with your blood..."))
	var/mob/living/carbon/human/H = usr
	if(H.should_have_organ(BP_HEART))
		H.vessel.remove_reagent(/datum/reagent/blood, 3)

	if(!do_after(usr, RUNE_DRAW_COOLDOWN, cast_on))
		cast_on.show_splash_text(usr, "Interrupted!", SPAN_WARNING("You were interrupted!"))

	if(H.should_have_organ(BP_HEART))
		H.vessel.remove_reagent(/datum/reagent/blood, 3)

	var/obj/effect/ressurection_rune/rune = new /obj/effect/ressurection_rune(cast_on)
	rune.add_fingerprint(H)
	rune.add_blood(H)

/obj/effect/ressurection_rune
	icon = 'icons/effects/runes.dmi'
	icon_state = "ressurection_rune"
	var/mob/living/deity/linked_deity

/obj/effect/ressurection_rune/Initialize(mapload, deity)
	. = ..()
	linked_deity = deity

/obj/effect/ressurection_rune/Destroy()
	linked_deity = null
	return ..()

/obj/effect/ressurection_rune/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	var/list/cultists = list()
	for(var/mob/living/carbon/human in range(1, src))
		var/datum/godcultist/G = human?.mind?.godcultist
		if(!istype(G) || G.linked_deity != linked_deity)
			continue

		cultists |= human

	if(LAZYLEN(cultists) <= 1)
		for(var/mob/M in cultists)
			to_chat(M, SPAN_WARNING("You need more cultists!"))

		return

	for(var/mob/living/carbon/C in GLOB.player_list - cultists)
		C.hallucination(400, 80)

	new /obj/effect/infernal_portal(loc, src, linked_deity)

/obj/effect/infernal_portal
	name = "portal"
	icon = 'icons/obj/portals.dmi'
	icon_state = "portal"
	density = TRUE
	unacidable = TRUE
	anchored = TRUE
	var/integrity = 400
	var/obj/effect/ressurection_rune/rune
	var/mob/living/deity/deity

/obj/effect/infernal_portal/Initialize(mapload, rune, deity)
	. = ..()
	set_next_think(world.time + 1 MINUTE)
	src.rune = rune
	src.deity = deity

/obj/effect/infernal_portal/Destroy()
	QDEL_NULL(rune)
	deity = null
	return ..()

/obj/effect/infernal_portal/think()
	var/datum/deity_form/devil/devil = deity?.form
	if(!istype(devil))
		return

	devil.create_devils_shell(deity, get_turf(src))
	playsound(get_turf(src), 'sound/effects/wind/wind_5_1.ogg', 100, FALSE, 1)

/obj/effect/infernal_portal/bullet_act(obj/item/projectile/proj, def_zone)
	take_damage(proj.damage)

/obj/effect/infernal_portal/hitby(atom/movable/AM, speed, nomsg)
	..()

	var/tforce = 0
	if(ismob(AM))
		tforce = 15 * (speed / 5)
	else
		tforce = AM:throwforce * (speed / 5)
	take_damage(tforce)

/obj/effect/infernal_portal/attackby(obj/item/I, mob/user)
	. = ..()
	if(I.damtype == BRUTE || I.damtype == BURN)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		user.do_attack_animation(src)
		visible_message(SPAN_WARNING("\The [src] has been [pick(I.attack_verb)] with [I] by [user]!"))
		shake_animation(stime = 3)
		obj_attack_sound(I)
		take_damage(I.force)

/obj/effect/infernal_portal/proc/take_damage(force)
	integrity -= force
	if(integrity <= 0)
		explosion(get_turf(src), 0, 1, 4, world.view)
		qdel_self()
