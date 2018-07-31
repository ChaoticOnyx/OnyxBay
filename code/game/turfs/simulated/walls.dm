/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/wall_masks.dmi'
	icon_state = "generic"
	opacity = 1
	density = 1
	blocks_air = 1
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/damage = 0
	var/damage_overlay = 0
	var/global/damage_overlays[16]
	var/active
	var/can_open = 0
	var/material/material
	var/material/reinf_material
	var/last_state
	var/construction_stage
	var/ricochet_id = 0
	var/hitsound = 'sound/weapons/Genhit.ogg'
	var/list/wall_connections = list("0", "0", "0", "0")
	var/floor_type = /turf/simulated/floor/plating //turf it leaves after destruction

/turf/simulated/wall/New(var/newloc, var/materialtype, var/rmaterialtype)
	..(newloc)
	icon_state = "blank"
	if(!materialtype)
		materialtype = DEFAULT_WALL_MATERIAL
	material = get_material_by_name(materialtype)
	if(!isnull(rmaterialtype))
		reinf_material = get_material_by_name(rmaterialtype)
	update_material()
	hitsound = material.hitsound
	processing_turfs |= src

/turf/simulated/wall/Destroy()
	processing_turfs -= src
	dismantle_wall(null,null,1)
	. = ..()

// Walls always hide the stuff below them.
/turf/simulated/wall/levelupdate()
	for(var/obj/O in src)
		O.hide(1)

/turf/simulated/wall/protects_atom(var/atom/A)
	var/obj/O = A
	return (istype(O) && O.hides_under_flooring()) || ..()

/turf/simulated/wall/process()
	// Calling parent will kill processing
	if(!radiate())
		return PROCESS_KILL

/turf/simulated/wall/proc/get_material()
	return material

// Extracts angle's tan if ischance = 1.
// In other case it just makes bullets and lazorz go where they're supposed to.

/turf/simulated/wall/proc/projectile_reflection(var/obj/item/projectile/Proj, var/ischance = 0)
	if(Proj.starting)
		var/ricochet_temp_id = rand(1,1000)
		if(!ischance) Proj.ricochet_id = ricochet_temp_id
		var/turf/curloc = get_turf(src)
		if(!ischance && ((curloc.x == Proj.starting.x) || (curloc.y == Proj.starting.y)))
			visible_message("\red <B>\The [Proj] critically misses!</B>")
			var/critical_x = Proj.starting.x
			var/critical_y = Proj.starting.y
			if(istype(Proj,/obj/item/projectile/bullet))
				critical_x = critical_x + pick(-1, 0, 0, 1)
				critical_y = critical_y + pick(-1, 0, 0, 1)
			Proj.redirect(critical_x, critical_y, curloc, src)
			return
		var/check_x0 = 32 * curloc.x
		var/check_y0 = 32 * curloc.y
		var/check_x1 = 32 * Proj.starting.x
		var/check_y1 = 32 * Proj.starting.y
		var/check_x2 = 32 * Proj.original.x
		var/check_y2 = 32 * Proj.original.y
		var/corner_x0 = check_x0
		var/corner_y0 = check_y0
		if(check_y0 - check_y1 > 0)
			corner_y0 = corner_y0 - 16
		else
			corner_y0 = corner_y0 + 16
		if(check_x0 - check_x1 > 0)
			corner_x0 = corner_x0 - 16
		else
			corner_x0 = corner_x0 + 16

		// Checks if original is lower or upper than line connecting proj's starting and wall
		// In specific coordinate system that has wall as (0,0) and 'starting' as (r, 0), where r > 0.
		// So, this checks whether 'original's' y-coordinate is positive or negative in new c.s.
		// In order to understand, in which direction bullet will ricochet.
		// Actually new_y isn't y-coordinate, but it has the same sign.
		var/new_y = (check_y2 - corner_y0) * (check_x1 - corner_x0) - (check_x2 - corner_x0) * (check_y1 - corner_y0)
		// Here comes the thing which differs two situations:
		// First - bullet comes from north-west or south-east, with negative func value. Second - NE or SW.
		var/new_func = (corner_x0 - check_x1) * (corner_y0 - check_y1)

		// Added these wall things because my original code works well with one-tiled walls, but ignores adjacent turfs which in my current opinion was pretty wrong.
		var/wallnorth = 0
		var/wallsouth = 0
		var/walleast = 0
		var/wallwest = 0
		for (var/turf/simulated/wall/W in range(2, curloc))
			var/turf/tempwall = get_turf(W)
			if (tempwall.x == curloc.x)
				if (tempwall.y == (curloc.y - 1))
					wallnorth = 1
					if (!ischance) W.ricochet_id = ricochet_temp_id
				else if (tempwall.y == (curloc.y + 1))
					wallsouth = 1
					if (!ischance) W.ricochet_id = ricochet_temp_id
			if (tempwall.y == curloc.y)
				if (tempwall.x == (curloc.x + 1))
					walleast = 1
					if (!ischance) W.ricochet_id = ricochet_temp_id
				else if (tempwall.x == (curloc.x - 1))
					wallwest = 1
					if (!ischance) W.ricochet_id = ricochet_temp_id

		if((wallnorth || wallsouth) && ((Proj.starting.y - curloc.y)*(wallsouth - wallnorth) >= 0))
			if(!ischance)
				Proj.redirect(round(check_x1 / 32), round((2 * check_y0 - check_y1)/32), curloc, src)
				return
			else
				return abs((check_y0 - check_y1) / (check_x0 - check_x1))

		if((walleast || wallwest) && ((Proj.starting.x - curloc.x)*(walleast-wallwest) >= 0))
			if(!ischance)
				Proj.redirect(round((2 * check_x0 - check_x1) / 32), round(check_y1 / 32), curloc, src)
				return
			else
				return abs((check_x0 - check_x1) / (check_y0 - check_y1))

		if((new_y * new_func) > 0)
			if(!ischance)
				Proj.redirect(round((2 * check_x0 - check_x1) / 32), round(check_y1 / 32), curloc, src)
			else
				return abs((check_x0 - check_x1) / (check_y0 - check_y1))
		else
			if(!ischance)
				Proj.redirect(round(check_x1 / 32), round((2 * check_y0 - check_y1)/32), curloc, src)
			else
				return abs((check_y0 - check_y1) / (check_x0 - check_x1))
		return


/turf/simulated/wall/bullet_act(var/obj/item/projectile/Proj)
	var/proj_damage = Proj.get_structure_damage()
	if(ricochet_id != 0)
		if(ricochet_id == Proj.ricochet_id)
			ricochet_id = 0
			return PROJECTILE_CONTINUE
		ricochet_id = 0
	// Walls made from reflective-able materials reflect beam-type projectiles depending on their reflectance value.
	if(istype(Proj,/obj/item/projectile/beam))
		if(reinf_material)
			if(material.opacity * reinf_material.opacity < 0.16) return PROJECTILE_CONTINUE

			if(material.reflectance + reinf_material.reflectance > 0)
				// Reflection chance depends on materials' var 'reflectance'.
				var/reflectchance = material.reflectance + reinf_material.reflectance - min(round(Proj.damage/3), 50)
				reflectchance = min(max(reflectchance, 0), 100)
				var/damagediff = round(proj_damage * reflectchance / 100)
				proj_damage /= reinf_material.burn_armor
				if(reflectchance > 0)
					visible_message("\red <B>\The [Proj] gets reflected by shiny surface of reinforced wall!</B>")
					projectile_reflection(Proj)
					Proj.damage = damagediff
					take_damage(min(proj_damage - damagediff, 100))
					return PROJECTILE_CONTINUE // complete projectile permutation
				// Walls with positive reflection values deal with laser better than walls with negative.
				burn(1500)
			else
				burn(2000)
		else
			if(material.opacity < 0.4) return PROJECTILE_CONTINUE

			if(material.reflectance > 0)
				// Reflection chance depends on materials' var 'reflectance'.
				var/reflectchance = material.reflectance - min(round(Proj.damage/3), 50)
				reflectchance = min(max(reflectchance, 0), 100)
				var/damagediff = round(proj_damage * reflectchance / 100)
				if(reflectchance > 0)
					visible_message("\red <B>\The [Proj] gets reflected by shiny surface of wall!</B>")
					projectile_reflection(Proj)
					Proj.damage = damagediff
					take_damage(min(proj_damage - damagediff, 100))
					return PROJECTILE_CONTINUE // complete projectile permutation
				// Walls with positive reflection values deal with laser better than walls with negative.
				burn(2000)
			else
				burn(2500)

	//else if(istype(Proj,/obj/item/projectile/ion))
	//	burn(500)

	// Bullets ricochet from walls made of specific materials with some little chance.
	if(istype(Proj,/obj/item/projectile/bullet))
		if(reinf_material)
			if(material.resilience * reinf_material.resilience > 0)
				var/ricochetchance = round(sqrt(material.resilience * reinf_material.resilience))
				var/turf/curloc = get_turf(src)
				if((curloc.x == Proj.starting.x) || (curloc.y == Proj.starting.y))
					ricochetchance = round(ricochetchance / 5)
				else
					ricochetchance = round(projectile_reflection(Proj, 1) * ricochetchance)
				ricochetchance = min(max(ricochetchance, 0), 100)
				var/damagediff = round(proj_damage * ricochetchance / 100)
				if(prob(ricochetchance))
					visible_message("\red <B>\The [Proj] ricochets from the surface of reinforced wall!</B>")
					projectile_reflection(Proj)
					proj_damage /= reinf_material.brute_armor
					Proj.damage = damagediff
					take_damage(min(proj_damage - damagediff, 100))
					return PROJECTILE_CONTINUE // complete projectile permutation
		else
			if(material.resilience > 0)
				var/ricochetchance = round(material.resilience)
				var/turf/curloc = get_turf(src)
				if((curloc.x == Proj.starting.x) || (curloc.y == Proj.starting.y))
					ricochetchance = round(ricochetchance / 5)
				else
					ricochetchance = round(projectile_reflection(Proj, 1) * ricochetchance)
				ricochetchance = min(max(ricochetchance, 0), 100)
				var/damagediff = round(proj_damage * ricochetchance / 100)
				if(prob(ricochetchance))
					visible_message("\red <B>\The [Proj] ricochets from the surface of wall!</B>")
					projectile_reflection(Proj)
					Proj.damage = damagediff
					take_damage(min(proj_damage - damagediff, 100))
					return PROJECTILE_CONTINUE // complete projectile permutation

	if(reinf_material)
		if(Proj.damage_type == BURN)
			proj_damage /= reinf_material.burn_armor
		else if(Proj.damage_type == BRUTE)
			proj_damage /= reinf_material.brute_armor

	//cap the amount of damage, so that things like emitters can't destroy walls in one hit.
	var/damage = min(proj_damage, 100)

	take_damage(damage)
	return

/turf/simulated/wall/hitby(AM as mob|obj, var/speed=THROWFORCE_SPEED_DIVISOR)
	..()
	if(ismob(AM))
		return

	var/tforce = AM:throwforce * (speed/THROWFORCE_SPEED_DIVISOR)
	if (tforce < 15)
		return

	take_damage(tforce)

/turf/simulated/wall/proc/clear_plants()
	for(var/obj/effect/overlay/wallrot/WR in src)
		qdel(WR)
	for(var/obj/effect/vine/plant in range(src, 1))
		if(!plant.floor) //shrooms drop to the floor
			plant.floor = 1
			plant.update_icon()
			plant.pixel_x = 0
			plant.pixel_y = 0
		plant.update_neighbors()

/turf/simulated/wall/ChangeTurf(var/newtype)
	clear_plants()
	return ..(newtype)

//Appearance
/turf/simulated/wall/examine(mob/user)
	. = ..(user)

	if(!damage)
		to_chat(user, "<span class='notice'>It looks fully intact.</span>")
	else
		var/dam = damage / material.integrity
		if(dam <= 0.3)
			to_chat(user, "<span class='warning'>It looks slightly damaged.</span>")
		else if(dam <= 0.6)
			to_chat(user, "<span class='warning'>It looks moderately damaged.</span>")
		else
			to_chat(user, "<span class='danger'>It looks heavily damaged.</span>")

	if(locate(/obj/effect/overlay/wallrot) in src)
		to_chat(user, "<span class='warning'>There is fungus growing on [src].</span>")

//Damage

/turf/simulated/wall/melt()

	if(!can_melt())
		return

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	if(!F)
		return
	F.burn_tile()
	F.icon_state = "wall_thermite"
	visible_message("<span class='danger'>\The [src] spontaneously combusts!.</span>") //!!OH SHIT!!
	return

/turf/simulated/wall/proc/take_damage(dam)
	if(dam)
		damage = max(0, damage + dam)
		update_damage()
	return

/turf/simulated/wall/proc/update_damage()
	var/cap = material.integrity
	if(reinf_material)
		cap += reinf_material.integrity

	if(locate(/obj/effect/overlay/wallrot) in src)
		cap = cap / 10

	if(damage >= cap)
		dismantle_wall()
	else
		update_icon()

	return

/turf/simulated/wall/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	burn(exposed_temperature)

/turf/simulated/wall/adjacent_fire_act(turf/simulated/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume)
	burn(adj_temp)
	if(adj_temp > material.melting_point)
		take_damage(log(RAND_F(0.9, 1.1) * (adj_temp - material.melting_point)))

	return ..()

/turf/simulated/wall/proc/dismantle_wall(var/devastated, var/explode, var/no_product)

	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	if(!no_product)
		if(reinf_material)
			reinf_material.place_dismantled_girder(src, reinf_material)
		else
			material.place_dismantled_girder(src)
		material.place_dismantled_product(src,devastated)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.forceMove(src)

	clear_plants()
	material = get_material_by_name("placeholder")
	reinf_material = null
	update_connections(1)

	ChangeTurf(floor_type)

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1.0)
			src.ChangeTurf(get_base_turf(src.z))
			return
		if(2.0)
			if(prob(75))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1,1)
		if(3.0)
			take_damage(rand(0, 250))
		else
	return

// Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(locate(/obj/effect/overlay/wallrot) in src)
		return
	var/number_rots = rand(2,3)
	for(var/i=0, i<number_rots, i++)
		new/obj/effect/overlay/wallrot(src)

/turf/simulated/wall/proc/can_melt()
	if(material.flags & MATERIAL_UNMELTABLE)
		return 0
	return 1

/turf/simulated/wall/proc/thermitemelt(mob/user as mob)
	if(!can_melt())
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay( src )
	O.SetName("Thermite")
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.set_density(1)
	O.plane = LIGHTING_PLANE
	O.layer = FIRE_LAYER

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	F.burn_tile()
	F.icon_state = "wall_thermite"
	to_chat(user, "<span class='warning'>The thermite starts melting through the wall.</span>")

	spawn(100)
		if(O)
			qdel(O)
//	F.sd_LumReset()		//TODO: ~Carn
	return

/turf/simulated/wall/proc/radiate()
	var/total_radiation = material.radioactivity + (reinf_material ? reinf_material.radioactivity / 2 : 0)
	if(!total_radiation)
		return

	radiation_repository.radiate(src, total_radiation)
	return total_radiation

/turf/simulated/wall/proc/burn(temperature)
	if(material.combustion_effect(src, temperature, 0.7))
		spawn(2)
			new /obj/structure/girder(src)
			src.ChangeTurf(/turf/simulated/floor)
			for(var/turf/simulated/wall/W in range(3,src))
				W.burn((temperature/4))
			for(var/obj/machinery/door/airlock/phoron/D in range(3,src))
				D.ignite(temperature/4)
