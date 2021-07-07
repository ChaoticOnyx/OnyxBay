GLOBAL_LIST_INIT(standing_objects, list(/obj/item/weapon/stool, /obj/structure/toilet, /obj/structure/table, /obj/structure/bed))

/proc/is_standing_on_object(x)
	if(!x) return FALSE

	for(var/obj/O in get_turf(x))
		if(is_type_in_list(O, GLOB.standing_objects))
			return TRUE
	return FALSE

/obj/item/stack/cable_coil/verb/make_noose()
	set name = "Make Noose"
	set category = "Object"

	var/mob/living/carbon/human/H = usr
	var/turf/current_turf = get_turf(H)

	if(!ishuman(H) || !istype(current_turf, /turf))
		return

	var/turf/above = GetAbove(H)

	// Forbid to create a noose in the air
	// Also sanity check for turf in loc
	if(istype(above, /turf/simulated/open))
		to_chat(usr, SPAN("warning", "There is no ceiling above you."))
		return

	if(H.restrained() || H.stat || H.paralysis || H.stunned)
		to_chat(usr, SPAN("warning", "You can't do it right now."))
		return

	if(!is_standing_on_object(H))
		to_chat(usr, SPAN("warning", "You have to be standing on top of a chair, table or bed to make a noose!"))
		return

	if(amount <= 24)
		to_chat(H, SPAN("warning", "You need at least 25 lengths to make a noose!"))
		return

	if(!do_mob(H, current_turf, 3 SECONDS))
		return

	if(!H.unEquip(src))
		return

	var/obj/structure/noose/N = new /obj/structure/noose(current_turf)
	to_chat(usr, SPAN("notice", "You wind some cable together to make a noose, tying it to the ceiling."))
	forceMove(N)
	N.coil = src
	N.color = color

/obj/structure/noose
	name = "noose"
	desc = "A morbid apparatus."
	icon_state = "noose"
	icon = 'icons/obj/noose.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = FALSE
	layer = 5
	var/ticks = 0

	var/manual_triggered
	var/image/over = null
	var/obj/item/stack/cable_coil/coil
	var/area/current_area

/obj/structure/noose/attackby(obj/item/W, mob/user, params)
	if(W.edge)
		user.visible_message(\
			SPAN("notice", "[user] cuts the noose."),\
			SPAN("notice", "You cut the noose."))
		untie()
		return
	return ..()

/obj/structure/noose/bullet_act(obj/item/projectile/P)
	if(prob(40))
		visible_message(SPAN("notice", "\The [src] gets split by \the [P]!"))
		untie()

/obj/structure/noose/proc/untie()
	if(buckled_mob)
		buckled_mob.visible_message(\
			SPAN("danger", "[buckled_mob] falls over and hits the ground!"),\
			SPAN("danger", "You fall over and hit the ground!"))
		buckled_mob.adjustBruteLoss(10)
	playsound(src, 'sound/items/Wirecutter.ogg', 60, 1)
	if(coil)
		coil.dropInto(loc)
		coil = null
	qdel(src)

/obj/structure/noose/Initialize()
	. = ..()
	pixel_y += 16 //Noose looks like it's "hanging" in the air
	over = image(icon, "noose_overlay")
	over.layer = BASE_HUMAN_LAYER + 0.1
	current_area = get_area(src)

/obj/structure/noose/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	QDEL_NULL(over)
	QDEL_NULL(coil)
	current_area = null
	return ..()

/obj/structure/noose/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		layer = 3
		overlays.Add(over)
		M.pixel_y = initial(M.pixel_y) + 8
		M.dir = SOUTH
		START_PROCESSING(SSprocessing, src)
	else
		STOP_PROCESSING(SSprocessing, src)
		layer = initial(layer)
		overlays.Cut()
		pixel_x = initial(pixel_x)
		M.pixel_x = initial(M.pixel_x)
		M.pixel_y = initial(M.pixel_y)
		manual_triggered = FALSE

/obj/structure/noose/user_unbuckle_mob(mob/living/user)
	if(!user.IsAdvancedToolUser())
		return

	if(buckled_mob?.buckled == src)
		var/mob/living/M = buckled_mob
		if(M != user)
			user.visible_message(\
				SPAN("notice", "[user] begins to untie the noose over [M]'s neck..."),\
				SPAN("notice", "You begin to untie the noose over [M]'s neck..."))
			if(do_mob(user, M, 10 SECONDS))
				user.visible_message(\
				SPAN("notice", "[user] unties the noose over [M]'s neck!"),\
				SPAN("notice", "You untie the noose over [M]'s neck!"))
			else
				return
		else
			M.visible_message(\
				SPAN("warning", "[M] struggles to untie the noose over their neck!"),\
				SPAN("notice", "You struggle to untie the noose over your neck."))
			if(!do_after(M, 15 SECONDS))
				if(M?.buckled)
					to_chat(M, SPAN("warning", "You fail to untie yourself!"))
				return
			if(!M.buckled)
				return
			M.visible_message(\
				SPAN("warning", "[M] unties the noose over their neck!"),\
				SPAN("notice", "You untie the noose over your neck!"))
			M.Weaken(3)
			M.Stun(2)
		unbuckle_mob()
		add_fingerprint(user)

/obj/structure/noose/proc/check_head(mob/living/carbon/human/H, mob/user)
	if(!H || !ishuman(H))
		return FALSE

	var/obj/item/organ/external/affecting = H.get_organ(BP_HEAD)
	if(!affecting || affecting.is_stump())
		if(user)
			to_chat(user, SPAN("danger", "They don't have a head."))
		return FALSE
	else
		return TRUE

/obj/structure/noose/user_buckle_mob(mob/living/carbon/human/M, mob/user)
	if(!in_range(user, src) || user.stat || user.restrained() || !istype(M))
		return FALSE

	if(!user.IsAdvancedToolUser())
		return

	if(M.loc != loc)
		return FALSE //Can only noose someone if they're on the same tile as noose

	if(!check_head(M, user))
		return

	add_fingerprint(user)

	if(M == user)
		var/datum/gender/G = gender_datums[M.get_visible_gender()]
		M.visible_message(\
			SPAN("danger", "[user] attempts to tie \the [src] over [G.his] neck!"),\
			SPAN("danger", "You attempt to tie \the [src] over your neck!"))

		if(do_after(user, 5 SECONDS))
			if(buckle_mob(M))
				M.visible_message(\
					SPAN("warning", "[user] ties \the [src] over [G.his] neck!"),\
					SPAN("warning", "You tie \the [src] over your neck!"))
				playsound(user, 'sound/effects/noose/noosed.ogg', 50, 1, -1)
				return TRUE

		user.visible_message(\
			SPAN("warning", "[user] fails to tie \the [src] over [G.his] neck!"),\
			SPAN("warning", "You fail to tie \the [src] over your neck!"))
		return FALSE
	else
		M.visible_message(\
			SPAN("danger", "[user] attempts to tie \the [src] over [M]'s neck!"),\
			SPAN("danger", "You ties \the [src] over your neck!"))
		to_chat(user, SPAN("notice", "It will take 20 seconds and you have to stand still."))

		if(do_after(user, 20 SECONDS))
			if(buckle_mob(M))
				M.visible_message(\
					SPAN("danger", "[user] ties \the [src] over [M]'s neck!"),\
					SPAN("danger", "You tie \the [src] over your neck!"))
				playsound(user, 'sound/effects/noose/noosed.ogg', 50, 1, -1)
				return TRUE

		user.visible_message(\
			SPAN("warning", "[user] fails to tie \the [src] over [M]'s neck!"),\
			SPAN("warning", "You fail to tie \the [src] over [M]'s neck!"))
		return FALSE

/obj/structure/noose/Process()
	if(!buckled_mob || !ishuman(buckled_mob) || !check_head(buckled_mob))
		if(buckled_mob)
			unbuckle_mob()
		return PROCESS_KILL

	if((is_standing_on_object(buckled_mob) && !buckled_mob.resting) || !current_area.has_gravity)
		if(pixel_x != initial(pixel_x) || buckled_mob.pixel_x != initial(buckled_mob.pixel_x))
			pixel_x = initial(pixel_x)
			buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
			manual_triggered = FALSE
		return

	if(!manual_triggered && buckled_mob.resting)
		noosed_effect(buckled_mob)

	ticks++

	switch(ticks)
		if(1)
			pixel_x -= 1
			buckled_mob.pixel_x -= 1
		if(2)
			pixel_x = initial(pixel_x)
			buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
		if(3)
			pixel_x += 1
			buckled_mob.pixel_x += 1

			if(buckled_mob)
				playsound(buckled_mob, 'sound/effects/noose/noose_idle.ogg', 50, 1, -3)
				if(ishuman(buckled_mob))
					var/mob/living/carbon/human/H = buckled_mob
					if(!H.need_breathe())
						return

				if(prob(15))
					var/flavor_text = list(\
						SPAN("warning", "[buckled_mob]'s legs flail for anything to stand on."),\
						SPAN("warning", "[buckled_mob]'s hands are desperately clutching the noose."),\
						SPAN("warning", "[buckled_mob]'s limbs sway back and forth with diminishing strength."))

					if(buckled_mob.stat == DEAD)
						flavor_text = list(\
							SPAN("warning", "[buckled_mob]'s limbs lifelessly sway back and forth."),\
							SPAN("warning", "[buckled_mob]'s eyes stare straight ahead."))
					buckled_mob.visible_message(pick(flavor_text))
		if(4)
			pixel_x = initial(pixel_x)
			buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
			ticks = 0

	if(ishuman(buckled_mob))
		var/mob/living/carbon/human/H = buckled_mob
		if(!H.need_breathe())
			return

		buckled_mob.adjustOxyLoss(3)
		buckled_mob.silent = max(buckled_mob.silent, 10)
		if(!(H.silent && H.stat) && prob(10))
			buckled_mob.emote("gasp")

/obj/structure/noose/proc/noosed_effect(mob/user)
	if(manual_triggered)
		return

	if(buckled_mob?.buckled == user)
		manual_triggered = TRUE

	// Here's come some special actions
	for(var/obj/O in user.loc)
		// For example chairs will fold
		if(istype(O, /obj/structure/bed/chair))
			var/obj/structure/bed/chair/C = O
			C.fold()
			return
