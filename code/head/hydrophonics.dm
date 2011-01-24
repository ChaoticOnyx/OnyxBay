datum/plants/
	var/name = "plants"
	var/icon_name = "tomato"
	var/health = 100
	var/growthtime = 100
	var/fullgrowthtime = 100
	var/itempath // what toooo spawn when its harvested
	var/itemnum = 1
	var/waterneeded = 1 //per tick
	var/co2needed = 1 // per tick
	var/uvneeded = 1
	var/growthstages
	var/needheat

datum/plants/tomato
	name = "plants"
	icon_name = "tomatoes"
	health = 100
	growth
	growthtime = 100
	waterneeded = 0.01 //per tick
	co2needed = 1 // per tick
	uvneeded = 1
	growthstages = 5
	needheat = 1

/obj/machinery/hydro/soilbed
	name = "Soilbed"
	desc = "A table with a container that should contain soil."
	icon = 'hydro.dmi'
	icon_state = "soilbed"
	var/soil = 0
	var/datum/plants/hasplant = null
	var/fullygrown = 0
	var/dead = 0
	var/stage
	var/debug = 1

/obj/machinery/hydro/soilbed/verb/derp()
	set src in view()
	hasplant = new /datum/plants/tomato ()

/obj/machinery/hydro/soilbed/New()
	..()
	var/datum/reagents/R = new/datum/reagents(30)
	reagents = R

/obj/machinery/hydro/soilbed/process()
	updateicon()

	if(hasplant && istype(hasplant,/datum/plants))
		if(hasplant.health <= 0)
			plantdie()
			return
			if(debug) world << "DIEING"

		var/turf/L = src.loc
		var/datum/gas_mixture/env = L.return_air()

		if(env.temperature < 283.15)
			hasplant.health -= 5

		var/uvhave = src.loc.ul_IsLuminous()

		world << "Light:[uvhave]"

		if(!uvhave && hasplant.uvneeded == 1)
			hasplant.health -= 5
			if(debug) world << "EATING LIGHT"

		if(uvhave == 1 && hasplant.uvneeded == 1)
			env.oxygen += hasplant.co2needed * 2
			if(debug) world << "BE MAKEING O2"

		if(env.toxins)
			hasplant.health -= 5

		if(reagents.has_reagent("water"))
			reagents.remove_reagent("water",hasplant.waterneeded)
		else
			hasplant.health -= 5

		if(!fullygrown)
			if(hasplant.growthtime <= 0)
				fullygrown = 1
			else
				var/calc = hasplant.growthtime / hasplant.fullgrowthtime
				calc = calc * 100
				stage = calc
				var/amt = reagents.get_reagent_amount("fertilizer")
				if(!amt)
					amt = 1

				hasplant.growthtime -= 1 * amt
				if(env.carbon_dioxide)
					var/plants
					var/area/A = get_area(src.loc)
					for(var/obj/machinery/hydro/soilbed/B in A)
						if(B.hasplant)
							plants++
					hasplant.growthtime = env.carbon_dioxide / plants
	updateicon()

/obj/machinery/hydro/soilbed/proc/updateicon()
	overlays = null
	if(dead)
		icon_state = "soilbed"
		overlays += image(src.icon,"dead")
	if(hasplant)
		var/icon_s
		if(stage >= 100)
			icon_s = 1
		if(stage >= 80 && stage < 100)
			icon_s = 2
		if(stage >= 60 && stage < 80)
			icon_s = 3
		if(stage >= 40 && stage < 60)
			icon_s = 4
		if(stage >= 20 && stage < 40)
			icon_s = 5
		if(stage >= 0 && stage <= 20)
			icon_s = 6
		icon_state = "soilbed"
		overlays += image(src.icon,"[hasplant.icon_name][icon_s]")
	else
		icon_state = "soilbed"

/obj/machinery/hydro/soilbed/proc/plantdie()
	del(hasplant)
	dead = 1

/obj/machinery/hydro/soilbed/attack_hand()
	if(dead)
		return

/obj/machinery/hydro/soilbed/attackby(obj/item/weapon/W,mob/user)
	if(istype(W,/obj/item/weapon/pruner) && dead)
		dead = 0
		updateicon()
	else if(istype(W,/obj/item/weapon/pruner) && fullygrown)
		if(hasplant.itemnum)
			new hasplant.itempath (src.loc)
			hasplant.itemnum--
		else
			del(hasplant)
			updateicon()
			return
	else if(istype(W,/obj/item/weapon/seeds) && !hasplant)
		if(W:ammount)
			W:ammount--
			hasplant = new W:typevar()
			if(W:ammount <= 0)
				user << "You ran out of seeds"
		else
			user << "The [src] is empty.."

obj/item/weapon/pruner
	name = "pruner"
	desc = "A common gardening tool"
	icon = 'items.dmi'
	icon_state = "cutters"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 6.0
	slash = 1
	throw_speed = 2
	throw_range = 9
	w_class = 2.0
	m_amt = 80

obj/item/weapon/food/harvest/tomato
	name = "tomato"
	desc = "It's a goddamm tomato"
	icon = 'items.dmi'
	icon_state = "cutters"

obj/item/weapon/seeds
	name = "seeds"
	icon = 'hydro.dmi'
	icon_state = "seedpack"
	var/ammount = 3
	var/typevar = /datum/plants/tomato