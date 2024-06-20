//Acid rain is part of the natural weather cycle in the humid forests of Planetstation, and cause acid damage to anyone unprotected.
/datum/weather/acid_rain
	name = "acid rain"
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	foreshadowing_duration = 40 SECONDS
	foreshadowing_message = "<span class='boldwarning'>Thunder rumbles far above. You hear droplets drumming against the canopy. Seek shelter.</span>"
	foreshadowing_overlay = "acid_rain_low"

	weather_message = "Acidic rain pours down around you! Get inside!"
	weather_overlay = "acid_rain"
	weather_duration_lower = 1 MINUTE
	weather_duration_upper = 3 MINUTES

	end_duration = 10 SECONDS
	end_message = "The downpour gradually slows to a light shower. It should be safe outside now."

	protect_indoors = TRUE

	sound_active_outside = /datum/looping_sound/weather/rain/indoors
	sound_active_inside = /datum/looping_sound/weather/rain
	sound_weak_outside = /datum/looping_sound/weather/rain/indoors
	sound_weak_inside = /datum/looping_sound/weather/rain

/datum/weather/acid_rain/weather_act(mob/living/carbon/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.head)
			if(H.head.unacidable)
				to_chat(H, SPAN_DANGER("Your [H.head] protects you from the acid."))

			else
				to_chat(H, SPAN_DANGER("Your [H.head] melts away!"))
				qdel(H.head)
				H.update_inv_head(1)
				H.update_hair(1)
				H.update_facial_hair(1)
			return

		if(H.wear_mask)
			if(H.wear_mask.unacidable)
				to_chat(H, SPAN_DANGER("Your [H.wear_mask] protects you from the acid."))

			else
				to_chat(H, SPAN_DANGER("Your [H.wear_mask] melts away!"))
				qdel(H.wear_mask)
				H.update_inv_wear_mask(1)
				H.update_hair(1)
				H.update_facial_hair(1)
			return

		if(H.glasses)
			if(H.glasses.unacidable)
				to_chat(H, SPAN_DANGER("Your [H.glasses] partially protect you from the acid!"))
			else
				to_chat(H, SPAN_DANGER("Your [H.glasses] melt away!"))
				qdel(H.glasses)
				H.update_inv_glasses(1)
			return


	if(L.unacidable)
		return

	L.take_organ_damage(0, 2)
	if(ishuman(L) && prob(10))
		var/mob/living/carbon/human/H = L
		var/screamed
		for(var/obj/item/organ/external/affecting in H.organs)
			if(!screamed && affecting.can_feel_pain())
				screamed = 1
				H.emote("scream")
