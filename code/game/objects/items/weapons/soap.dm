/obj/item/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	w_class = ITEM_SIZE_SMALL
	throwforce = 0
	throw_range = 20
	var/key_data

/obj/item/soap/New()
	..()
	create_reagents(30)
	wet()

/obj/item/soap/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) > 1)
		return
	if(reagents.total_volume <= 0)
		. += "\nIt's dry!"
	return

/obj/item/soap/proc/wet()
	reagents.add_reagent(/datum/reagent/space_cleaner, 15)

/obj/item/soap/Crossed(AM as mob|obj)
	if(istype(AM, /mob/living))
		var/mob/living/M = AM
		if(reagents.total_volume <= 0)
			return
		if(M.slip_on_obj(src, 2, 2))
			reagents.remove_any(3)

/obj/item/soap/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity)
		return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(istype(target,/obj/structure/sink))
		to_chat(user, SPAN("notice", "You wet \the [src] in the sink."))
		wet()
	if(reagents.total_volume <= 0)
		to_chat(user, SPAN("notice", "\The [src] is dry!"))
		return
	if(user.client && (target in user.client.screen))
		to_chat(user, SPAN("notice", "You need to take that [target.name] off before cleaning it."))
	else if(istype(target,/obj/effect/decal/cleanable/blood))
		to_chat(user, SPAN("notice", "You scrub \the [target.name] out."))
		target.clean_blood() //Blood is a cleanable decal, therefore needs to be accounted for before all cleanable decals.
	else if(istype(target,/obj/effect/decal/cleanable))
		to_chat(user, SPAN("notice", "You scrub \the [target.name] out."))
		qdel(target)
	else if(istype(target,/turf))
		to_chat(user, SPAN("notice", "You scrub \the [target.name] clean."))
		var/turf/T = target
		T.clean(src, user)
	else
		to_chat(user, SPAN("notice", "You clean \the [target.name]."))
		target.clean_blood() //Clean bloodied atoms. Blood decals themselves need to be handled above.
	return

//attack_as_weapon
/obj/item/soap/attack(mob/living/target, mob/living/user, target_zone)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == BP_MOUTH)
		user.visible_message(SPAN("danger", "\The [user] washes \the [target]'s mouth out with soap!"))
		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN) //prevent spam
		return
	..()

/obj/item/soap/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/key))
		if(!key_data)
			to_chat(user, SPAN("notice", "You imprint \the [I] into \the [src]."))
			var/obj/item/key/K = I
			key_data = K.key_data
			update_icon()
		return
	..()

/obj/item/soap/update_icon()
	overlays.Cut()
	if(key_data)
		overlays += image('icons/obj/items.dmi', icon_state = "soap_key_overlay")

/obj/item/soap/nanotrasen
	desc = "A NanoTrasen-brand bar of soap. Smells of plasma."
	icon_state = "soapnt"

/obj/item/soap/deluxe
	icon_state = "soapdeluxe"

/obj/item/soap/deluxe/New()
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of [pick("lavender", "vanilla", "strawberry", "chocolate" ,"space")]."
	..()

/obj/item/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"

/obj/item/soap/gold
	desc = "One true soap to rule them all."
	icon_state = "soapgold"

/obj/item/soap/brig
	desc = "Train your security guards!"
	icon_state = "soapbrig"
