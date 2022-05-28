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
