/obj/item/fighter_component/engine
	name = "fighter engine"
	desc = "A mighty engine capable of propelling small spacecraft to high speeds."
	icon_state = "engine_tier1"
	slot = HARDPOINT_SLOT_ENGINE
	active = FALSE
	var/rpm = 0
	var/flooded = FALSE

/obj/item/fighter_component/engine/flooded //made just so I can put it in pilot-specific mail
	desc = "A mighty engine capable of propelling small spacecraft to high speeds. Something doesn't seem right, though..."
	flooded = TRUE

/obj/item/fighter_component/engine/proc/active()
	return (active && integrity > 0 && rpm >= ENGINE_RPM_SPUN && !flooded)

/obj/item/fighter_component/engine/think()
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE

	var/obj/item/fighter_component/apu/APU = F.loadout.get_slot(HARDPOINT_SLOT_APU)
	if(!APU?.fuel_line && rpm > 0)
		rpm -= 1000 //Spool down the engine.
		if(rpm <= 0)
			playsound(loc, 'sound/effects/ship/rcs.ogg', 100, TRUE)
			loc.visible_message("<span class='userdanger'>[src] fizzles out!</span>")
			rpm = 0
			F.stop_relay(SOUND_CHANNEL_IMP_SHIP_ALERT)
			active = FALSE
			return FALSE

	if(rpm > 3000)
		var/obj/item/fighter_component/battery/B = F.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
		B.give(500  *tier)
	if(!active())
		return FALSE

/obj/item/fighter_component/engine/proc/apu_spin(amount)
	if(flooded)
		loc.visible_message("<span class='warning'>[src] sputters uselessly.</span>")
		return

	rpm += amount
	rpm = Clamp(rpm, 0, ENGINE_RPM_SPUN)

/obj/item/fighter_component/engine/proc/try_start()
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE

	if(rpm >= ENGINE_RPM_SPUN - 200) //You get a small bit of leeway.
		active = TRUE
		rpm = ENGINE_RPM_SPUN
		playsound(loc, 'sound/effects/fighters/startup.ogg', 100, FALSE)
		F.relay('sound/effects/fighters/cockpit.wav', "<span class='warning'>You hear a loud noise as [F]'s engine kicks in.</span>", loop=TRUE, channel = SOUND_CHANNEL_SHIP_ALERT)
		return
	else
		playsound(loc, 'sound/effects/fighters/steam_whoosh.ogg', 100, TRUE)
		loc.visible_message("<span class='warning'>[src] sputters slightly.</span>")
		if(prob(20)) //Don't try and start a not spun engine, flyboys.
			playsound(loc, 'sound/effects/ship/rcs.ogg', 100, TRUE)
			loc.visible_message("<span class='userdanger'>[src] violently fizzles out!.</span>")
			F.set_master_caution(TRUE)
			rpm = 0
			flooded = TRUE
			active = FALSE
