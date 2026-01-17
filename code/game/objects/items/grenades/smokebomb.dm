/obj/item/grenade/smokebomb
	desc = "It is set to detonate in 2 seconds."
	name = "smoke bomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	det_time = 20
	item_state = "flashbang"
	var/datum/effect/effect/system/smoke_spread/bad/smoke
	var/smoke_times = 4

/obj/item/grenade/smokebomb/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/grenade/smokebomb/detonate()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	smoke = new /datum/effect/effect/system/smoke_spread/bad
	smoke.attach(src)
	smoke.set_up(10, 0, get_turf(src))
	set_next_think(world.time + 1 SECOND)
	QDEL_IN(src, 8 SECONDS)

/obj/item/grenade/smokebomb/think()
	if(!QDELETED(smoke) && (smoke_times > 0))
		smoke_times--
		smoke.start()
		set_next_think(world.time + 1 SECOND)
		return
	
	return
