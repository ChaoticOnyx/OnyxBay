/obj/effect/decal/cleanable/reagents
	icon = 'icons/effects/effects.dmi'
	icon_state = ""
	layer = BLOOD_LAYER
	name = "puddle"
	var/obj/chemholder
	var/maxamount = 500

/*
/obj/effect/decal/cleanable/reagent/proc/Spread(exclude=list())
	//Allows liquids to sometimes flow into other tiles.
	if(amount < 15)
		return //lets suppose welder fuel is fairly thick and sticky. For something like water, 5 or less would be more appropriate.
	var/turf/simulated/S = loc
	if(!istype(S))
		return
	for(var/d in GLOB.cardinal)
		var/turf/simulated/target = get_step(src,d)
		var/turf/simulated/origin = get_turf(src)
		if(origin.CanPass(null, target, 0, 0) && target.CanPass(null, origin, 0, 0))
			var/obj/effect/decal/cleanable/liquid_fuel/other_fuel = locate() in target
			if(other_fuel)
				other_fuel.amount += amount*0.25
				if(!(other_fuel in exclude))
					exclude += src
					other_fuel.Spread(exclude)
			else
				new /obj/effect/decal/cleanable/liquid_fuel(target, amount*0.25,1)
			amount *= 0.75
*/

/obj/effect/decal/cleanable/reagents/update_icon()
	overlays.Cut()

	if(chemholder.reagents.total_volume)
		var/image/filling = image('icons/effects/effects.dmi', src, "liquid)

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 33)        filling.icon_state = "[icon_state]_small"
			if(34 to 66)       filling.icon_state = "[icon_state]_medium"
			if(67 to INFINITY) filling.icon_state = "[icon_state]_big"

		filling.color = chemholder.reagents.get_color()
		overlays += filling

/obj/effect/decal/cleanable/reagents/New(newloc, datum/reagents/carry = null)
	..()
	chemholder = new /obj()
	chemholder.create_reagents(maxamount)

/obj/effect/decal/cleanable/reagents/Initialize(mapload, amt=1, nologs=FALSE)
	if(!nologs && !mapload)
		log_and_message_admins(" - Reagents has been spilled")
	src.amount = amt
	var/has_spread = 0
	//Be absorbed by any other liquid fuel in the tile.
	for(var/obj/effect/decal/cleanable/liquid_fuel/other in loc)
		if(other != src)
			other.amount += src.amount
			other.Spread()
			has_spread = 1
			break

	. = ..()
