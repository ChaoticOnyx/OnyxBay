//Structure as this doesn't need any power to work
/obj/structure/drain
	name = "drain"
	icon = 'icons/obj/liquids/structures/drains.dmi'
	icon_state = "drain"
	desc = "Drainage inlet embedded in the floor to prevent flooding."
	density = FALSE
	plane = TURF_PLANE
	layer = EXPOSED_PIPE_LAYER
	anchored = TRUE
	var/processing = FALSE
	var/drain_flat = 5
	var/drain_percent = 0.1
	var/welded = FALSE
	var/turf/my_turf //need to keep track of it for the signal, if in any bizarre cases something would be moving the drain

/obj/structure/drain/update_icon()
	. = ..()
	if(welded)
		icon_state = "[initial(icon_state)]_welded"
	else
		icon_state = "[initial(icon_state)]"

/obj/structure/drain/attackby(obj/item/O, mob/user)
	. = ..()
	if(isWelder(O))
		welder_act(user, O)

/obj/structure/drain/proc/welder_act(mob/living/user, obj/item/weldingtool/WT)
	if(!WT.use_tool(src, user, delay= 4 SECONDS, amount = 5))
		return

	playsound(src, 'sound/items/welder2.ogg', 50, TRUE)
	to_chat(user, SPAN_NOTICE("You start [welded ? "unwelding" : "welding"] [src]..."))
	if(do_after(user, 40, src))
		if(!src || !user || !WT.remove_fuel(5, user)) return
		to_chat(user, SPAN_NOTICE("You [welded ? "unweld" : "weld"] [src]."))
		welded = !welded
		update_icon()
		if(welded)
			if(processing)
				processing = FALSE
				set_next_think(0)
		else if (my_turf.liquids)
			set_next_think(world.time+1)
			processing = TRUE
	return TRUE

/obj/structure/drain/think()
	if(!my_turf.liquids || my_turf.liquids.immutable)
		set_next_think(0)
		processing = FALSE
		return
	my_turf.liquids.liquid_simple_delete_flat(drain_flat + (drain_percent * my_turf.liquids.total_reagents))
	set_next_think(world.time+1)

/obj/structure/drain/Initialize(mapload)
	. = ..()
	if(!isturf(loc))
		CRASH("Drain structure initialized not on a turf")
	my_turf = loc
	register_signal(my_turf, SIGNAL_TURF_LIQUIDS_CREATION, .proc/liquids_signal)
	if(my_turf.liquids)
		set_next_think(world.time+1)
		processing = TRUE

/obj/structure/drain/proc/liquids_signal()
	SIGNAL_HANDLER
	if(processing || welded)
		return
	set_next_think(world.time+1)
	processing = TRUE

/obj/structure/drain/Destroy()
	if(processing)
		set_next_think(0)
	unregister_signal(my_turf, SIGNAL_TURF_LIQUIDS_CREATION)
	my_turf = null
	return ..()

/obj/structure/drain/big
	desc = "Drainage inlet embedded in the floor to prevent flooding. This one seems large."
	icon_state = "bigdrain"
	drain_percent = 0.3
	drain_flat = 15
