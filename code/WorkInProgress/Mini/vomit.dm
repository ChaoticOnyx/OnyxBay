/obj/decal/cleanable/vomit
	name = "vomit"
	density = 0
	anchored = 1
	layer = 2
	icon = 'decals.dmi'
	icon_state = "vomit"
	random_icon_states = list("vomit") //add more if you want

/mob/living/carbon/human/proc/vomit(var/returns = 0)
	var/message = "<B>[src]</B> "
	lastnutritioncomplaint = world.timeofday //you don't feel hungry right after you vomit silly
	if(nutrition > 0) //vomit
		new /obj/decal/cleanable/vomit(src.loc)
		message += "vomits."
		nutrition = 0
		for(var/datum/reagent/R in reagents)
			if(istype(R, /datum/reagent/beer) || istype(R, /datum/reagent/vodka) || istype(R, /datum/reagent/dwine))
				R.volume = 0
	else              //retch
		message += "retches."
	if(returns == 1)
		return message
	for (var/mob/O in viewers(src, null))
		O.show_message(message, 1)
