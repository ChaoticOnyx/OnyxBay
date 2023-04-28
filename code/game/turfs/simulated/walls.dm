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
	hitby_sound = 'sound/effects/metalhit2.ogg'
	explosion_block = 1

	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 100 MEGA ELECTRONVOLT,
		RADIATION_BETA_PARTICLE = 20.2 MEGA ELECTRONVOLT,
		RADIATION_HAWKING = 1 ELECTRONVOLT
	)

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
	var/hitsound = 'sound/effects/fighting/Genhit.ogg'
	var/list/wall_connections = list("0", "0", "0", "0")
	var/floor_type = /turf/simulated/floor/plating //turf it leaves after destruction
	var/masks_icon = 'icons/turf/wall_masks.dmi'

/turf/simulated/wall/New(newloc, materialtype, rmaterialtype)
	..(newloc)
	if(GLOB.using_map.legacy_mode)
		masks_icon = 'icons/turf/wall_masks_legacy.dmi'
	icon_state = "blank"
	if(!materialtype)
		materialtype = DEFAULT_WALL_MATERIAL
	material = get_material_by_name(materialtype)
	if(!isnull(rmaterialtype))
		reinf_material = get_material_by_name(rmaterialtype)
	update_material()
	hitsound = material.hitsound

// Walls always hide the stuff below them.
/turf/simulated/wall/levelupdate()
	for(var/obj/O in src)
		O.hide(O.hides_inside_walls())

/turf/simulated/wall/protects_atom(atom/A)
	var/obj/O = A
	return (istype(O) && O.hides_under_flooring()) || ..()

/turf/simulated/wall/proc/get_material()
	return material

// Not friend with mathematic, but more likely that varint, than other
/turf/simulated/wall/proc/projectile_reflection(obj/item/projectile/proj, calculate = FALSE)
	var/turf/proj_turf = get_turf(proj)
	var/face_direction = get_dir(src, proj_turf)
	var/face_angle = dir2angle(face_direction)
	var/proj_angle =  MODULUS(face_angle - (Get_Angle(proj_turf, proj.starting) + 180), 360)

	var/real_angle = SIMPLIFY_DEGREES(abs(proj_angle))
	if(calculate)
		return real_angle / 3.6

	var/radian = real_angle * 3.14 / 180
	var/dx = proj.x + (real_angle < 180 ? -8 * cos(radian) : 8 * cos(radian))// raw, but working!
	var/dy = proj.y + (real_angle < 270 && real_angle > 90 ? -8 * sin(radian) : 8 * sin(radian))// raw, but working!
	proj.redirect(dx, dy, src)

/turf/simulated/wall/blob_act(damage)
	take_damage(damage)

/turf/simulated/wall/bullet_act(obj/item/projectile/Proj)
	var/proj_damage = Proj.get_structure_damage()
	if(ricochet_id != 0)
		if(ricochet_id == Proj.ricochet_id)
			ricochet_id = 0
			return PROJECTILE_CONTINUE
		ricochet_id = 0
	// Walls made from reflective-able materials reflect beam-type projectiles depending on their reflectance value.
	if(istype(Proj, /obj/item/projectile/beam))
		if(reinf_material)
			if(material.opacity * reinf_material.opacity < 0.16) return PROJECTILE_CONTINUE

			if(material.reflectance + reinf_material.reflectance > 0)
				// Reflection chance depends on materials' var 'reflectance'.
				var/reflectchance = material.reflectance + reinf_material.reflectance - min(round(Proj.damage/3), 50)
				var/turf/curloc = get_turf(src)
				if((curloc.x == Proj.starting.x) || (curloc.y == Proj.starting.y))
					reflectchance = 0
				else
					reflectchance = round(projectile_reflection(Proj, 1) * reflectchance)
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
				var/turf/curloc = get_turf(src)
				if((curloc.x == Proj.starting.x) || (curloc.y == Proj.starting.y))
					reflectchance = 0
				else
					reflectchance = round(projectile_reflection(Proj, 1) * reflectchance)
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
	if(istype(Proj, /obj/item/projectile/bullet) && Proj.can_ricochet)
		if(reinf_material)
			if(material.resilience * reinf_material.resilience > 0)
				var/ricochetchance = round(sqrt(material.resilience * reinf_material.resilience))
				var/turf/curloc = get_turf(src)
				if((curloc.x == Proj.starting.x) || (curloc.y == Proj.starting.y))
					ricochetchance = 0
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
					ricochetchance = 0
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

/turf/simulated/wall/hitby(atom/movable/AM, speed = THROWFORCE_SPEED_DIVISOR, nomsg = FALSE)
	..()
	play_hitby_sound(AM)
	if(ismob(AM))
		return

	var/tforce = AM:throwforce / (speed * THROWFORCE_SPEED_DIVISOR)
	if(tforce < 17.5)
		if(!nomsg)
			visible_message("[AM] bounces off \the [src].")
		return

	if(!nomsg)
		visible_message(SPAN("warning", "[src] was hit by [AM]."))
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

/turf/simulated/wall/ChangeTurf(turf/N, tell_universe = TRUE, force_lighting_update = FALSE)
	clear_plants()
	return ..()

//Appearance
/turf/simulated/wall/_examine_text(mob/user)
	. = ..()

	if(!damage)
		. += "\n<span class='notice'>It looks fully intact.</span>"
	else
		var/dam = damage / material.integrity
		if(dam <= 0.3)
			. += "\n<span class='warning'>It looks slightly damaged.</span>"
		else if(dam <= 0.6)
			. += "\n<span class='warning'>It looks moderately damaged.</span>"
		else
			. += "\n<span class='danger'>It looks heavily damaged.</span>"

	if(locate(/obj/effect/overlay/wallrot) in src)
		. += "\n<span class='warning'>There is fungus growing on [src].</span>"

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

/turf/simulated/wall/proc/dismantle_wall(devastated, explode, no_product)

	playsound(src, 'sound/items/Deconstruct.ogg', 100, 1)
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
			src.ChangeTurf(get_base_turf_by_area(src))
			return
		if(2.0)
			if(prob(75))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1,1)
		if(3.0)
			take_damage(rand(0, 250))
	return

// Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(locate(/obj/effect/overlay/wallrot) in src)
		return
	var/number_rots = rand(2,3)
	for(var/i=0, i<number_rots, i++)
		new /obj/effect/overlay/wallrot(src)

/turf/simulated/wall/proc/can_melt()
	if(material.flags & MATERIAL_UNMELTABLE)
		return 0
	return 1

/turf/simulated/wall/proc/thermitemelt(mob/user as mob)
	if(!can_melt())
		return
	var/obj/effect/overlay/O = new /obj/effect/overlay( src )
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

/turf/simulated/wall/proc/CheckPenetration(base_chance, damage)
	return round(damage/material.integrity*180)

/turf/simulated/wall/proc/burn(temperature)
	if(material.combustion_effect(src, temperature, 0.7))
		spawn(2)
			new /obj/structure/girder(src)
			src.ChangeTurf(/turf/simulated/floor)
			for(var/turf/simulated/wall/W in range(3,src))
				W.burn((temperature/4))
			for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
				D.ignite(temperature/4)
