//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.
#define NEST_RESIST_TIME 1200

/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	buckle_pixel_shift = "x=0;y=6"
	var/health = 100
	var/image/over = null

/obj/structure/bed/nest/on_update_icon()
	return

/obj/structure/bed/nest/Initialize()
	. = ..()
	over = image(icon, "nest_over")
	over.layer = LYING_HUMAN_LAYER + 0.1

/obj/structure/bed/nest/Destroy()
	QDEL_NULL(over)
	return ..()

/obj/structure/bed/nest/post_buckle_mob(mob/living/M)
	..()
	if(M == buckled_mob)
		AddOverlays(over)
	else
		ClearOverlays()

/obj/structure/bed/nest/user_unbuckle_mob(mob/living/user)
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			var/mob/living/M = buckled_mob
			if(buckled_mob != user)
				buckled_mob.visible_message(\
					"<span class='notice'>[user.name] pulls [M.name] free from the sticky nest!</span>",\
					"<span class='notice'>[user.name] pulls you free from the gelatinous resin.</span>",\
					"<span class='notice'>You hear squelching...</span>")
				unbuckle_mob()
			else
				THROTTLE_SHARED(cooldown, NEST_RESIST_TIME, M.last_special)
				if(!cooldown)
					return
				M.visible_message(\
					"<span class='warning'>[buckled_mob.name] struggles to break free of the gelatinous resin...</span>",\
					"<span class='warning'>You struggle to break free from the gelatinous resin...</span>",\
					"<span class='notice'>You hear squelching...</span>")
				if(!do_after(M, NEST_RESIST_TIME, luck_check_type = LUCK_CHECK_COMBAT))
					to_chat(M, SPAN("warning", "You fail to untie yourself!"))
					M.last_special = world.time - NEST_RESIST_TIME/2 // Don't make them wait forever till next try, but also don't allow them to try again immediately
					return
				if(!M.buckled || buckled_mob != M)
					return
				M.visible_message(\
				SPAN("warning", "[M] breaks free of the gelatinous resin!"),\
				SPAN("notice", "You break free of the gelatinous resin!"))
				unbuckle_mob()
			add_fingerprint(user)
	return

/obj/structure/bed/nest/user_buckle_mob(mob/living/M, mob/user)
	if(!ismob(M) || !Adjacent(user) || (M.loc != loc) || user.restrained() || usr.stat || M.buckled || istype(user, /mob/living/silicon/pai))
		return

	unbuckle_mob()

	var/mob/living/carbon/xenos = user
	var/mob/living/carbon/victim = M

	if(istype(victim) && (locate(/obj/item/organ/internal/xenos/hivenode) in victim.internal_organs))
		return

	if(istype(xenos) && !(locate(/obj/item/organ/internal/xenos/hivenode) in xenos.internal_organs))
		return

	if(M == usr)
		return
	else
		M.visible_message(
			"<span class='notice'>[user.name] secretes a thick vile goo, securing [M] into [src]!</span>",
			"<span class='warning'>[user.name] drenches you in a foul-smelling resin, trapping you in the [src]!</span>",
			"<span class='notice'>You hear squelching...</span>")
	buckle_mob(M)
	src.add_fingerprint(user)
	return

/obj/structure/bed/nest/attackby(obj/item/W, mob/user)
	health = max(0, health - W.force)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	user.visible_message(SPAN("warning", "[user] hits \the [src] with \the [W]!"))
	healthcheck()

/obj/structure/bed/nest/proc/healthcheck()
	if(health <= 0)
		set_density(0)
		if(buckled_mob)
			unbuckle_mob()
		qdel(src)
	return
