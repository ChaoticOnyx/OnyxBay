/obj/item/device/assembly/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustable substances."
	icon_state = "igniter"
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 50, MATERIAL_WASTE = 10)

	secured = 1
	wires = WIRE_RECEIVE

	drop_sound = SFX_DROP_COMPONENT
	pickup_sound = SFX_PICKUP_COMPONENT

/obj/item/device/assembly/igniter/activate()
	. = ..()
	if(!.)
		return

	if(istype(holder?.loc,/obj/item/grenade))
		var/obj/item/grenade/grenade = holder.loc
		if(grenade.active)
			grenade.detonate()
	else if(istype(holder?.loc, /obj/structure/bed/chair/wheelchair/wheelcannon))
		var/obj/structure/bed/chair/wheelchair/wheelcannon/wheelcannon = holder.loc
		wheelcannon.shoot()
	else if(istype(holder?.loc, /obj/item/tank))
		var/obj/item/tank/tank = holder.loc
		tank.ignite()
	else
		var/turf/location = get_turf(loc)
		if(location)
			location.hotspot_expose(1000,1000)
		if (istype(src.loc,/obj/item/device/assembly_holder))
			if (istype(src.loc.loc, /obj/structure/reagent_dispensers/fueltank/))
				var/obj/structure/reagent_dispensers/fueltank/tank = src.loc.loc
				if (tank && tank.modded)
					tank.explode()

		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

	return TRUE

/obj/item/device/assembly/igniter/attack_self(mob/user)
	activate()
	add_fingerprint(user)
