var/list/holder_mob_icon_cache = list()

//Helper object for picking dionaea (and other creatures) up.
/obj/item/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	slot_flags = SLOT_HEAD | SLOT_HOLSTER

	origin_tech = null
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_holder.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_holder.dmi',
		)
	pixel_y = 8

	var/mob/mob = null

	var/last_holder

/obj/item/holder/New(loc, mob_to_hold)
	..()
	ASSERT(mob_to_hold)
	mob = mob_to_hold
	START_PROCESSING(SSobj, src)

/obj/item/holder/proc/destroy_all()
	QDEL_NULL(mob)
	qdel(src)

/obj/item/holder/Destroy()
	if(mob)
		mob.forceMove(get_turf(src))
		mob = null
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	last_holder = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/holder/Process()
	update_state()

/obj/item/holder/dropped()
	..()
	spawn(1)
		update_state()

/obj/item/holder/proc/update_state()
	if(last_holder != loc)
		unregister_all_movement(last_holder, mob)

	if(istype(loc,/turf) || !mob)
		if(mob)
			var/atom/movable/mob_container = mob
			mob_container.dropInto(loc)
			mob.reset_view()
			mob = null
		qdel(src)
	else if(last_holder != loc)
		register_all_movement(loc, mob)

	last_holder = loc

/obj/item/holder/onDropInto(atom/movable/AM)
	if(ismob(loc))   // Bypass our holding mob and drop directly to its loc
		return loc.loc
	return ..()

/obj/item/holder/GetIdCard()
	return mob.GetIdCard()

/obj/item/holder/GetAccess()
	var/obj/item/I = GetIdCard()
	return I ? I.GetAccess() : ..()

/obj/item/holder/attack_self()
	mob.show_inv(usr)

/obj/item/holder/attack(mob/target, mob/user)
	// Devour on click on self with holder
	if(target == user && istype(user,/mob/living/carbon))
		var/mob/living/carbon/M = user
		var/obj/item/blocked = M.check_mouth_coverage()
		if(blocked)
			to_chat(user, SPAN_WARNING("\The [blocked] is in the way!"))
			return 1
		M.devour(mob)
		mob = null

		update_state()

	..()

/obj/item/holder/proc/sync()
	dir = 2
	overlays.Cut()
	icon = mob.icon
	icon_state = mob.icon_state
	item_state = mob.item_state
	color = mob.color
	name = mob.name
	desc = mob.desc
	overlays |= mob.overlays
	var/mob/living/carbon/human/H = loc
	if(hasorgans(H))
		last_holder = H
		register_all_movement(H, mob)

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
	mob.attackby(W,user)

//Mob procs and vars for scooping up
/mob/living/var/holder_type

/mob/living/proc/get_scooped(mob/living/carbon/human/grabber, self_grab)

	if(!holder_type || buckled || pinned.len)
		return

	var/obj/item/holder/H = new holder_type(get_turf(src), src)

	if(self_grab)
		if(src.incapacitated())
			return
		if(!grabber.equip_to_slot_if_possible(H, slot_back, del_on_fail=0, disable_warning=1))
			to_chat(src, "<span class='warning'>You can't climb onto [grabber]!</span>")
			return

		to_chat(grabber, "<span class='notice'>\The [src] clambers onto you!</span>")
		to_chat(src, "<span class='notice'>You climb up onto \the [grabber]!</span>")
	else
		if(grabber.incapacitated())
			return
		if(!grabber.put_in_hands(H))
			to_chat(grabber, "<span class='warning'>Your hands are full!</span>")
			return

		to_chat(grabber, "<span class='notice'>You scoop up \the [src]!</span>")
		to_chat(src, "<span class='notice'>\The [grabber] scoops you up!</span>")

	src.forceMove(H)

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
	var/mob/living/carbon/human/owner = mob
	if(istype(owner) && owner.species)

		var/skin_colour = rgb(owner.r_skin, owner.g_skin, owner.b_skin)
		var/hair_colour = rgb(owner.r_hair, owner.g_hair, owner.b_hair)
		var/eye_colour =  rgb(owner.r_eyes, owner.g_eyes, owner.b_eyes)
		var/species_name = lowertext(owner.species.name)

		for(var/cache_entry in generate_for_slots)
			var/cache_key = "[owner.species]-[cache_entry]-[skin_colour]-[hair_colour]"
			if(!holder_mob_icon_cache[cache_key])

				// Generate individual icons.
				var/icon/mob_icon = icon(icon, "[species_name]_holder_[cache_entry]_base")
				mob_icon.Blend(skin_colour, ICON_ADD)
				var/icon/hair_icon = icon(icon, "[species_name]_holder_[cache_entry]_hair")
				hair_icon.Blend(hair_colour, ICON_ADD)
				var/icon/eyes_icon = icon(icon, "[species_name]_holder_[cache_entry]_eyes")
				eyes_icon.Blend(eye_colour, ICON_ADD)

				// Blend them together.
				mob_icon.Blend(eyes_icon, ICON_OVERLAY)
				mob_icon.Blend(hair_icon, ICON_OVERLAY)

				// Add to the cache.
				holder_mob_icon_cache[cache_key] = mob_icon
			item_icons[cache_entry] = holder_mob_icon_cache[cache_key]

	// Handle the rest of sync().
	..()
