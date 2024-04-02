/obj/item/grenade/anti_photon
	desc = "An experimental device for temporarily removing light in a limited area."
	name = "photon disruption grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "emp"
	item_state = "emp"
	det_time = 20
	origin_tech = list(TECH_BLUESPACE = 4, TECH_MATERIAL = 4)

/obj/item/grenade/anti_photon/Initialize()
	. = ..()
	add_think_ctx("think_qdel", CALLBACK(src, nameof(.proc/think_qdel)), 0)

/obj/item/grenade/anti_photon/detonate()
	playsound(src.loc, 'sound/effects/phasein.ogg', 50, 1, 5)
	set_light(-1, 6, 10, 2, "#ffffff")
	set_next_think(world.time + rand(20 SECONDS, 29 SECONDS))

/obj/item/grenade/anti_photon/think()
	set_light(1, 1, 10, 2, "#[num2hex(rand(64,255))][num2hex(rand(64,255))][num2hex(rand(64,255))]")
	playsound(loc, 'sound/effects/bang.ogg', 50, 1, 5)
	set_next_think_ctx("think_qdel", world.time + 1 SECOND)

/obj/item/grenade/anti_photon/proc/think_qdel()
	qdel_self()
