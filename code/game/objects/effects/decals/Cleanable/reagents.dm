/obj/effect/decal/cleanable/reagent_puddle
	icon = 'icons/effects/effects.dmi'
	icon_state = "liquid"
	layer = BLOOD_LAYER
	name = "puddle"
	var/chemholder

/obj/effect/decal/cleanable/reagent/proc/Spread(exclude=list())
	//Allows liquids to sometimes flow into other tiles.
	if(amount < 15) return //lets suppose welder fuel is fairly thick and sticky. For something like water, 5 or less would be more appropriate.
	var/turf/simulated/S = loc
	if(!istype(S)) return
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

/obj/effect/decal/cleanable/reagent/New(newloc, datum/reagents/carry = null)
	..()
	chemholder = new /obj()
	chemholder.create_reagents(300)

/obj/effect/decal/cleanable/liquid_fuel/Initialize(mapload, amt=1, nologs=FALSE)
	if(!nologs && !mapload)
		log_and_message_admins(" - Liquid fuel has been spilled")
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
	if(!has_spread)
		Spread()
	else
		return INITIALIZE_HINT_QDEL
