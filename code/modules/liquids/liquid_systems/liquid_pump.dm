//Right now it's a structure that works off of magic, as it'd require an internal power source for what its supposed to do
/obj/structure/liquid_pump
	name = "portable liquid pump"
	desc = "An industrial grade pump, capable of either siphoning or spewing liquids. Needs to be anchored first to work. Has a limited capacity internal storage."
	icon = 'icons/obj/liquids/structures/liquid_pump.dmi'
	icon_state = "liquid_pump"
	density = TRUE
	anchored = FALSE
	/// How many reagents at maximum can it hold
	var/max_volume = 10000
	/// Whether spewing reagents out, instead of siphoning them
	var/spewing_mode = FALSE
	/// Whether its turned on and processing
	var/turned_on = FALSE
	/// How fast does the pump work, in percentages relative to the volume we're working with
	var/pump_speed_percentage = 0.4
	/// How fast does the pump work, in flat values. Flat values on top of percentages to help processing
	var/pump_speed_flat = 20

/obj/structure/liquid_pump/attackby(obj/item/O, mob/user)
	if(!isWrench(O))
		return ..()
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if (do_after(user, 40, src))
		user.visible_message( \
			"<span class='notice'>\The [user] unfastens \the [src].</span>", \
			"<span class='notice'>You have unfastened \the [src].</span>", \
			"You hear ratchet.")
	if(!anchored && turned_on)
		toggle_working()
	return TRUE

/obj/structure/liquid_pump/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, SPAN_WARNING("[src] needs to be anchored first!"))
		return
	to_chat(user, SPAN_NOTICE("You turn [src] [turned_on ? "off" : "on"]."))
	toggle_working()

/obj/structure/liquid_pump/AltClick(mob/living/user)
	if(!Adjacent(user, src))
		return ..()

	to_chat(user, SPAN_NOTICE("You flick [src]'s spewing mode [spewing_mode ? "off" : "on"]."))
	spewing_mode = !spewing_mode
	update_icon()

/obj/structure/liquid_pump/_examine_text(mob/user, infix, suffix)
	. = ..()
	. += SPAN_NOTICE("It's anchor bolts are [anchored ? "down and secured" : "up"].")
	. += SPAN_NOTICE("It's currently [turned_on ? "ON" : "OFF"].")
	. += SPAN_NOTICE("It's mode currently is set to [spewing_mode ? "SPEWING" : "SIPHONING"].")
	. += SPAN_NOTICE("The pressure gauge shows [reagents.total_volume]/[reagents.maximum_volume].")

/obj/structure/liquid_pump/think()
	if(!isturf(loc))
		set_next_think(world.time+1)
		return
	var/turf/T = loc
	if(spewing_mode)
		if(!reagents.total_volume)
			set_next_think(world.time+1)
			return
		var/datum/reagents/tempr = new(10000)
		reagents.trans_to(tempr, (reagents.total_volume * pump_speed_percentage) + pump_speed_flat)
		T.add_liquid_from_reagents(tempr)
		qdel(tempr)
	else
		if(!T.liquids)
			set_next_think(world.time+1)
			return
		var/free_space = reagents.maximum_volume - reagents.total_volume
		if(!free_space)
			set_next_think(world.time+1)
			return
		var/target_siphon_amt = (T.liquids.total_reagents * pump_speed_percentage) + pump_speed_flat
		if(target_siphon_amt > free_space)
			target_siphon_amt = free_space
		var/datum/reagents/tempr = T.liquids.take_reagents_flat(target_siphon_amt)
		tempr.trans_to(reagents, tempr.total_volume)
		qdel(tempr)
	set_next_think(world.time+1)
	return

/obj/structure/liquid_pump/update_icon()
	. = ..()
	if(turned_on)
		if(spewing_mode)
			icon_state = "[initial(icon_state)]_spewing"
		else
			icon_state = "[initial(icon_state)]_siphoning"
	else
		icon_state = "[initial(icon_state)]"

/obj/structure/liquid_pump/proc/toggle_working()
	if(turned_on)
		set_next_think(0)
	else
		set_next_think(world.time+1)
	turned_on = !turned_on
	update_icon()

/obj/structure/liquid_pump/Initialize(mapload)
	. = ..()
	create_reagents(max_volume)

/obj/structure/liquid_pump/Destroy()
	if(turned_on)
		set_next_think(0)
	qdel(reagents)
	return ..()
