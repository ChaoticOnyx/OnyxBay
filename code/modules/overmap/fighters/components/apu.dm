/obj/item/fighter_component/apu
	name = "fighter auxiliary power unit"
	desc = "An Auxiliary Power Unit for a fighter"
	icon_state = "apu_tier1"
	slot = HARDPOINT_SLOT_APU
	active = FALSE
	var/fuel_line = FALSE
	var/next_process = 0

/obj/item/fighter_component/apu/proc/toggle_fuel_line()
	fuel_line = !fuel_line
	playsound(src, 'sound/effects/fighters/warmup.ogg', 100, FALSE)

/obj/item/fighter_component/apu/think()
	if(!..())
		return

	if(world.time < next_process)
		return

	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE

	next_process = world.time + 4 SECONDS
	if(!fuel_line)
		return //APU needs fuel to drink

	F.relay('sound/effects/fighters/apu_loop.ogg')
	var/obj/item/fighter_component/engine/engine = F.loadout.get_slot(HARDPOINT_SLOT_ENGINE)
	F.use_fuel(2, TRUE) //APUs take fuel to run.
	if(engine.active())
		return

	engine.apu_spin(500*tier)
