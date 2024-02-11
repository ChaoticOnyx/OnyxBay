/obj/item/stack/telecrystal
	name = "telecrystal"
	desc = "It seems to be pulsing with suspiciously enticing energies."
	description_antag = "Telecrystals can be activated by utilizing them on devices with an actively running uplink. They will not activate on unactivated uplinks."
	singular_name = "telecrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "telecrystal"
	w_class = ITEM_SIZE_TINY
	max_amount = 50
	item_flags = ITEM_FLAG_NO_BLUDGEON
	origin_tech = list(TECH_MATERIAL = 6, TECH_BLUESPACE = 4)

/obj/item/stack/telecrystal/afterattack(obj/item/I, mob/user, proximity)
	if(!proximity)
		return
	if(istype(I, /obj/item))
		if(I.hidden_uplink && I.hidden_uplink.active) //No metagaming by using this on every PDA around just to see if it gets used up.
			I.hidden_uplink.uses += amount
			I.hidden_uplink.update_nano_data()
			SSnano.update_uis(I.hidden_uplink)
			use(amount)
			to_chat(user, SPAN("notice", "You slot \the [src] into \the [I] and charge its internal uplink."))

/obj/item/stack/telecrystal/attack_self(mob/user)
	var/turf/Turf = get_turf(src)
	if(!(Turf.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
		to_chat(user, SPAN("warning", "[src] doesn't work on this location!"))
		return
	if(use(1))
		user.visible_message(SPAN("warning", "\The [user] crushes a crystal!"), \
							 SPAN("notice", "You crush \a [src]!"), \
							 SPAN("italics", "You hear the sound of a crystal breaking just before a sudden crack of electricity."))
		var/turf/T = get_random_turf_in_range(user, 7, 3)
		if(T)
			user.phase_out(T, get_turf(user))
			user.forceMove(T)
			user.phase_in(T, get_turf(user))

//Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.

/obj/item/stack/telecrystal/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "bluespace_crystal"
	singular_name = "bluespace crystal"
	/// The teleport range when crushed/thrown at someone.
	var/blink_range = 3

/obj/item/stack/telecrystal/bluespace_crystal/afterattack(obj/item/I, mob/user, proximity)
	return


/obj/item/stack/telecrystal/bluespace_crystal/attack_self(mob/user)
	user.visible_message(SPAN_WARNING("[user] crushes [src]!"), SPAN_DANGER("You crush [src]!"))
	playsound(get_turf(user), GET_SFX(SFX_SPARK_MEDIUM), 100, TRUE)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(5, 1, user)
	s.start()
	blink_mob(user)
	use(1)

/obj/item/stack/telecrystal/bluespace_crystal/proc/blink_mob(mob/living/L)
	playsound(L,'sound/effects/phasein.ogg',50)
	do_teleport(L, get_turf(L), blink_range)

/obj/item/stack/telecrystal/bluespace_crystal/throw_impact(atom/hit_atom)
	if(!..()) // not caught in mid-air
		visible_message(SPAN_NOTICE("[src] fizzles and disappears upon impact!"))
		var/turf/T = get_turf(hit_atom)
		playsound(T, GET_SFX(SFX_SPARK_MEDIUM), 100, TRUE)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
		s.set_up(5, 1, hit_atom)
		s.start()
		if(isliving(hit_atom))
			blink_mob(hit_atom)
		use(1)
