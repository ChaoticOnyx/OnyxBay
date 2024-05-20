/obj/item/fighter_component/countermeasure_dispenser
	name = "fighter countermeasure dispenser"
	desc = "A device which allows a fighter to deploy countermeasures."
	icon_state = "countermeasure_tier1"
	slot = HARDPOINT_SLOT_COUNTERMEASURE
	var/max_charges = 3
	var/charges = 3

/obj/effect/temp_visual/countermeasure_cloud
	icon = 'icons/effects/countermeasures.dmi'
	icon_state = "thundercloud"
	duration = 10 SECONDS
	pixel_x = -80
	pixel_y = -80

/obj/effect/temp_visual/countermeasure_cloud/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		SIGNAL_ENTERED = nameof(.proc/on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/temp_visual/countermeasure_cloud/proc/on_entered(datum/source, obj/item/projectile/B)
	SIGNAL_HANDLER

	//if(istype(B, /obj/item/projectile/guided_munition/torpedo) || istype(B, /obj/item/projectile/guided_munition/missile))
	//	if(prob(50))
	//		B.explode() //Kaboom on the chaff
	//	else
	//		B.homing = FALSE //Confused by the chaff

/obj/structure/overmap/small_craft/proc/fire_countermeasure()
	var/obj/item/fighter_component/countermeasure_dispenser/CD = loadout.get_slot(HARDPOINT_SLOT_COUNTERMEASURE)
	if(!CD) //Check for a dispenser
		to_chat(usr, "<span class='warning'>Failed to detect countermeasure dispenser!</span>")
		return

	if(!CD.charges) //check to see if we have any countermeasures
		to_chat(usr, "<span class='warning'>Countermeasures depleted!</span>")
		return

	if(CD.integrity <= 0) //check to see if the dispenser is broken
		if(prob(85))
			to_chat(usr, "<span class='warning'>Error detected in Countermeasure System! Process Aborted!</span>")
			DIRECT_OUTPUT(usr, sound('sound/effects/alert.ogg', repeat = FALSE, wait = 0, volume = 100))
			return

	CD.charges -= 1
	for(var/I = 0, I < 3, I++) //launch three chaff
		new /obj/effect/temp_visual/countermeasure_cloud(get_turf(src))
		sleep(5)
