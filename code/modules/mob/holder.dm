var/list/holder_mob_icon_cache = list()

//Helper object for picking dionaea (and other creatures) up.
/obj/item/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	icon_state = "blank"
	slot_flags = SLOT_HEAD | SLOT_HOLSTER

	origin_tech = null
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_holder.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_holder.dmi',
		)
	pixel_y = 8

	var/mob/held_mob = null

	var/last_holder

/obj/item/holder/New(loc, mob_to_hold)
	..(loc)
	ASSERT(mob_to_hold)
	held_mob = mob_to_hold
	register_signal(mob_to_hold, SIGNAL_QDELETING, nameof(.proc/onMobQdeleting))
	set_next_think(world.time)

/obj/item/holder/proc/destroy_all()
	QDEL_NULL(held_mob)
	qdel(src)

/obj/item/holder/proc/onMobQdeleting()
	ASSERT(held_mob)
	unregister_signal(held_mob, SIGNAL_QDELETING)
	held_mob = null
	qdel(src)

/obj/item/holder/Destroy()
	if(held_mob)
		unregister_signal(held_mob, SIGNAL_QDELETING)
		if(held_mob in src)
			held_mob.forceMove(get_turf(src))
		held_mob = null
	last_holder = null
	return ..()

/obj/item/holder/think()
	check_condition()

	set_next_think(world.time + 1 SECOND)

/obj/item/holder/dropped()
	..()
	spawn(1)
		check_condition()

/obj/item/holder/proc/check_condition()
	if(isturf(loc) || !held_mob || !(held_mob in src))
		qdel(src)

/obj/item/holder/onDropInto(atom/movable/AM)
	if(ismob(loc))   // Bypass our holding mob and drop directly to its loc
		return loc.loc
	return ..()

/obj/item/holder/get_id_card()
	return held_mob.get_id_card()

/obj/item/holder/GetAccess()
	var/obj/item/I = get_id_card()
	return I ? I.GetAccess() : ..()

/obj/item/holder/attack_self()
	if(!held_mob.show_inv(usr))
		return

	usr.show_inventory?.open()

/obj/item/holder/attack(mob/target, mob/user)
	// Devour on click on self with holder
	if(target == user && istype(user,/mob/living/carbon))
		var/mob/living/carbon/M = user
		if(M.isSynthetic())
			return
		var/obj/item/blocked = M.check_mouth_coverage()
		if(blocked)
			to_chat(user, SPAN_WARNING("\The [blocked] is in the way!"))
			return 1
		M.devour(held_mob)
		check_condition()

	..()

/obj/item/holder/proc/sync()
	dir = 2
	ClearOverlays()
	icon = held_mob.icon
	icon_state = held_mob.icon_state
	item_state = held_mob.item_state
	color = held_mob.color
	name = held_mob.name
	desc = held_mob.desc
	AddOverlays(held_mob.overlays)

	update_held_icon()

//Mob specific holders.
/obj/item/holder/diona
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 5)
	slot_flags = SLOT_HEAD | SLOT_OCLOTHING | SLOT_HOLSTER

/obj/item/holder/drone
	origin_tech = list(TECH_MAGNET = 3, TECH_ENGINEERING = 5)

/obj/item/holder/mouse
	w_class = ITEM_SIZE_TINY

/obj/item/holder/borer
	origin_tech = list(TECH_BIO = 6)

//need own subtype to work with recipies
/obj/item/holder/corgi
	origin_tech = list(TECH_BIO = 4)

/obj/item/holder/lizard
	w_class = ITEM_SIZE_TINY
	origin_tech = list(TECH_BIO = 2)

/obj/item/holder/parrot
	origin_tech = list(TECH_BIO = 4)

/obj/item/holder/crab
	origin_tech = list(TECH_BIO = 3)

/obj/item/holder/chicken
	origin_tech = list(TECH_BIO = 2)
	slot_flags = SLOT_HOLSTER

/obj/item/holder/attackby(obj/item/W, mob/user)
	held_mob.attackby(W, user)
	sync()

//Mob procs and vars for scooping up
/mob/living/var/holder_type

/mob/living/proc/get_scooped(mob/living/carbon/human/grabber, self_grab)

	if(!holder_type || buckled || LAZYLEN(pinned))
		return

	if(self_grab)
		if(incapacitated())
			return
	else
		if(grabber.incapacitated())
			return

	for(var/obj/item/grab/G in grabbed_by)
		if(self_grab) // Somebody's grabbing us, no way to climb onto anyone.
			to_chat(src, SPAN("warning", "You can't climb onto [grabber] while being grabbed!"))
			return
		else if(G.assailant != grabber) // Grabber's trying to scoop us up, but somebody else's grabbing us.
			to_chat(grabber, SPAN("warning", "You can't scoop up \the [src] because of [G.assailant]'s grab!"))
			return

	var/obj/item/holder/H = new holder_type(get_turf(src), src)

	if(self_grab)
		if(!grabber.equip_to_slot_if_possible(H, slot_back, del_on_fail = FALSE, disable_warning = TRUE))
			to_chat(src, SPAN("warning", "You can't climb onto [grabber]!"))
			qdel(H)
			return

		to_chat(grabber, SPAN("notice", "\The [src] clambers onto you!"))
		to_chat(src, SPAN("notice", "You climb up onto \the [grabber]!"))
	else
		if(!grabber.put_in_hands(H))
			to_chat(grabber, SPAN("warning", "Your hands are full!"))
			qdel(H)
			return

		to_chat(grabber, SPAN("notice", "You scoop up \the [src]!"))
		to_chat(src, SPAN("notice", "\The [grabber] scoops you up!"))

	for(var/obj/item/grab/G in grabbed_by)
		qdel(G) // All the checks have been done above, it's safe to murder one (or even two, who knows) of grabber's grab objects

	forceMove(H)

	if(isanimal(src))
		var/mob/living/simple_animal/SA = src
		SA.panic_target = null
		SA.stop_automated_movement = 0
		SA.turns_since_scan = 5

	grabber.status_flags |= PASSEMOTES
	H.sync()

	return H

/mob/living/MouseDrop(mob/living/carbon/human/over_object)
	if(istype(over_object) && Adjacent(over_object) && (usr == src || usr == over_object) && over_object.a_intent == I_GRAB)
		if(scoop_check(over_object))
			get_scooped(over_object, (usr == src))
			return
	return ..()

/mob/living/proc/scoop_check(mob/living/scooper)
	return 1

/mob/living/carbon/human/scoop_check(mob/living/scooper)
	return (scooper.mob_size > src.mob_size && a_intent == I_HELP)

/obj/item/holder/human
	icon = 'icons/mob/holder_complex.dmi'
	var/list/generate_for_slots = list(slot_l_hand_str, slot_r_hand_str, slot_back_str)
	slot_flags = SLOT_BACK
	w_class = ITEM_SIZE_LARGE

/obj/item/holder/human/sync()
	// Generate appropriate on-mob icons.
	var/mob/living/carbon/human/owner = held_mob
	if(istype(owner) && owner.species)

		var/skin_colour = rgb(owner.r_skin, owner.g_skin, owner.b_skin)
		var/hair_colour = rgb(owner.r_hair, owner.g_hair, owner.b_hair)
		var/s_hair_color = rgb(owner.r_s_hair, owner.g_s_hair, owner.b_s_hair)
		var/eye_colour =  rgb(owner.r_eyes, owner.g_eyes, owner.b_eyes)
		var/species_name = lowertext(owner.species.name)

		for(var/cache_entry in generate_for_slots)
			var/cache_key = "[owner.species]-[cache_entry]-[skin_colour]-[hair_colour]-[s_hair_color]"
			if(!holder_mob_icon_cache[cache_key])

				// Generate individual icons.
				var/icon/mob_icon = icon(icon, "[species_name]_holder_[cache_entry]_base")
				mob_icon.Blend(skin_colour, ICON_ADD)
				var/icon/hair_icon = icon(icon, "[species_name]_holder_[cache_entry]_hair")
				hair_icon.Blend(hair_colour, ICON_ADD)
				var/icon/s_hair_icon = icon(icon, "[species_name]_holder_[cache_entry]_s_hair")
				s_hair_icon.Blend(s_hair_color, ICON_ADD)
				var/icon/eyes_icon = icon(icon, "[species_name]_holder_[cache_entry]_eyes")
				eyes_icon.Blend(eye_colour, ICON_ADD)

				// Blend them together.
				mob_icon.Blend(eyes_icon, ICON_OVERLAY)

				hair_icon.Blend(s_hair_icon, ICON_OVERLAY)
				mob_icon.Blend(hair_icon, ICON_OVERLAY)

				// Add to the cache.
				holder_mob_icon_cache[cache_key] = mob_icon
			item_icons[cache_entry] = holder_mob_icon_cache[cache_key]

	// Handle the rest of sync().
	..()
