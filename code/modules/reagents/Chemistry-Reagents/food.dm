
/* Food */

/datum/reagent/nutriment
	name = "Nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."

	taste_mult = 1.0

	reagent_state = SOLID
	color = "#664330"

	metabolism = 2.5
	ingest_met = 0.5
	digest_met = 2.5
	ingest_absorbability = 0.25
	digest_absorbability = 1.0

	var/nutriment_factor = 1.0 // Per ml
	var/injectable = 0

/datum/reagent/nutriment/mix_data(list/newdata, newamount)

	if(!islist(newdata) || !newdata.len)
		return

	//add the new taste data
	for(var/taste in newdata)
		if(taste in data)
			data[taste] += newdata[taste]
		else
			data[taste] = newdata[taste]

	//cull all tastes below 10% of total
	var/totalFlavor = 0
	for(var/taste in data)
		totalFlavor += data[taste]
	if(!totalFlavor)
		return
	for(var/taste in data)
		if(data[taste]/totalFlavor < 0.1)
			data -= taste

/datum/reagent/nutriment/affect_blood(mob/living/carbon/M, alien, removed)
	if(!injectable)
		M.adjustToxLoss(0.25 * removed)
		return
	affect_digest(M, alien, removed)

/datum/reagent/nutriment/affect_ingest(mob/living/carbon/M, alien, removed)
	adjust_nutrition(M, alien, removed * ingest_absorbability)

/datum/reagent/nutriment/affect_digest(mob/living/carbon/M, alien, removed)
	M.heal_organ_damage(0.1 * removed, 0) //what
	adjust_nutrition(M, alien, removed * digest_absorbability)

/datum/reagent/nutriment/proc/adjust_nutrition(mob/living/carbon/M, alien, removed)
	switch(alien)
		if(IS_UNATHI) removed *= 0.1 // Unathi get most of their nutrition from meat.
	M.add_nutrition(nutriment_factor * removed) // For hunger and fatness

/datum/reagent/nutriment/glucose
	name = "Glucose"

	taste_description = "sweetness"
	taste_mult = 3.0

	color = "#ffffff"

	metabolism = 5.0
	ingest_met = 0.5
	digest_met = 5.0
	ingest_absorbability = 0.1
	digest_absorbability = 0.5

	nutriment_factor = 5.0
	injectable = 1

/datum/reagent/nutriment/protein // Bad for Skrell!
	name = "animal protein"

	taste_description = "some sort of protein"

	color = "#440000"

	ingest_absorbability = 0.1
	digest_absorbability = 0.5

	nutriment_factor = 2.5

	var/skrell_safe = FALSE
	var/cooked_path = /datum/reagent/nutriment/protein/cooked

/datum/reagent/nutriment/protein/affect_digest(mob/living/carbon/M, alien, removed)
	if(alien == IS_SKRELL && !skrell_safe)
		M.adjustToxLoss(0.5 * removed)
		return
	M.add_chemical_effect(CE_BLOODRESTORE, removed * 2.5)
	..()

/datum/reagent/nutriment/protein/affect_ingest(mob/living/carbon/M, alien, removed)
	if(alien == IS_SKRELL && !skrell_safe)
		M.adjustToxLoss(0.5 * removed)
		return
	..()

/datum/reagent/nutriment/protein/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_SKRELL && !skrell_safe)
		M.adjustToxLoss(2 * removed)
		return
	..()

/datum/reagent/nutriment/protein/adjust_nutrition(mob/living/carbon/M, alien, removed)
	switch(alien)
		if(IS_UNATHI) removed *= 2.25
	M.add_nutrition(nutriment_factor * removed) // For hunger and fatness

// Cooking proteins make them more available.
/datum/reagent/nutriment/protein/cooked
	name = "denatured protein"

	taste_description = "some sort of protein"

	ingest_absorbability = 0.2
	digest_absorbability = 1.0

	cooked_path = null

/datum/reagent/nutriment/protein/gluten
	name = "gluten"

	taste_description = "dough"

	skrell_safe = TRUE
	cooked_path = /datum/reagent/nutriment/protein/gluten/cooked

/datum/reagent/nutriment/protein/gluten/cooked
	name = "denatured gluten"

	taste_description = "bread"

	ingest_absorbability = 0.2
	digest_absorbability = 1.0

	cooked_path = null

/datum/reagent/nutriment/protein/compressed
	name = "compressed protein"

	nutriment_factor = 25.0

	ingest_absorbability = 0.05
	digest_absorbability = 0.25

	cooked_path = null

/datum/reagent/nutriment/protein/fungal
	name = "fungal protein"

	taste_description = "mushrooms"

	skrell_safe = TRUE
	cooked_path = null

/datum/reagent/nutriment/protein/fungal/adjust_nutrition(mob/living/carbon/M, alien, removed)
	if(alien == IS_SKRELL) // More nutrition for skrells, no bonus for unathi. Simple as that.
		removed *= 2.0
	M.add_nutrition(nutriment_factor * removed)

/datum/reagent/nutriment/protein/egg // Also bad for skrell.
	name = "egg protein"

	taste_description = "slime"

	reagent_state = LIQUID
	color = "#ffffaa"

	ingest_absorbability = 0.2
	digest_absorbability = 0.75

	cooked_path = /datum/reagent/nutriment/protein/egg/cooked

/datum/reagent/nutriment/protein/egg/cooked
	name = "cooked egg protein"

	taste_description = "eggs"

	reagent_state = SOLID
	color = "#ffe17f"

	ingest_absorbability = 0.2
	digest_absorbability = 1.0

	cooked_path = null

/datum/reagent/nutriment/honey
	name = "Honey"
	description = "A golden yellow syrup, loaded with sugary sweetness."

	taste_description = "sweetness"
	taste_mult = 5.0

	color = "#ffff00"

	nutriment_factor = 5.0

/datum/reagent/honey/affect_digest(mob/living/carbon/M, alien, removed)
	..()
	M.heal_organ_damage(0.5 * removed, 0)
	M.add_chemical_effect(CE_PAINKILLER, 1)
	if(alien == IS_UNATHI)
		if(M.chem_doses[type] < 2)
			if(M.chem_doses[type] == metabolism * 2 || prob(5))
				M.emote("yawn")
		else if(M.chem_doses[type] < 5)
			M.eye_blurry = max(M.eye_blurry, 10)
		else if(M.chem_doses[type] < 20)
			if(prob(50))
				M.Weaken(2)
			M.drowsyness = max(M.drowsyness, 20)
		else
			M.sleeping = max(M.sleeping, 20)
			M.drowsyness = max(M.drowsyness, 60)

/datum/reagent/nutriment/flour
	name = "flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."

	taste_description = "chalky wheat"

	reagent_state = SOLID
	color = "#ffffff"

	nutriment_factor = 1.0

/datum/reagent/nutriment/flour/touch_turf(turf/simulated/T)
	if(!istype(T, /turf/space))
		if(!locate(/obj/effect/decal/cleanable/flour, T))
			new /obj/effect/decal/cleanable/flour(T)

		if(T.wet > 1)
			T.wet = min(T.wet, 1)
		else
			T.wet = 0

/datum/reagent/nutriment/coco
	name = "Coco Powder"
	description = "A fatty, bitter paste made from coco beans."

	taste_description = "bitterness"
	taste_mult = 5.0

	reagent_state = SOLID
	color = "#302000"

	nutriment_factor = 2.5

/datum/reagent/nutriment/soysauce
	name = "Soysauce"
	description = "A salty sauce made from the soy plant."

	taste_description = "umami"
	taste_mult = 5.0

	reagent_state = LIQUID
	color = "#792300"

	nutriment_factor = 1.0
	hydration_value = 0.7

/datum/reagent/nutriment/ketchup
	name = "Ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."

	taste_description = "ketchup"
	taste_mult = 5.0

	reagent_state = LIQUID
	color = "#731008"

	nutriment_factor = 2.0
	hydration_value = 0.5

/datum/reagent/nutriment/barbecue
	name = "Barbecue Sauce"
	description = "Barbecue sauce for barbecues and long shifts."

	taste_description = "barbecue"
	taste_mult = 5.0

	reagent_state = LIQUID
	color = "#4f330f"

	nutriment_factor = 2.0
	hydration_value = 0.4

/datum/reagent/nutriment/garlicsauce
	name = "Garlic Sauce"
	description = "Garlic sauce, perfect for spicing up a plate of garlic."

	taste_description = "garlic"
	taste_mult = 5.0

	reagent_state = LIQUID
	color = "#d8c045"

	nutriment_factor = 3.0
	hydration_value = 0.4

/datum/reagent/nutriment/rice
	name = "Rice"
	description = "Enjoy the great taste of nothing."

	taste_description = "rice"
	taste_mult = 0.4

	reagent_state = SOLID
	color = "#ffffff"

	nutriment_factor = 1.0

	decompile_results = list(
		/datum/reagent/nutriment/flour = 1.0
		)

/datum/reagent/nutriment/cherryjelly
	name = "Cherry Jelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."

	taste_description = "cherry"
	taste_mult = 5.0

	reagent_state = LIQUID
	color = "#801e28"

	nutriment_factor = 2.5
	hydration_value = 0.4

	decompile_results = list(
		/datum/reagent/flavoring/cherry = 0.1,
		/datum/reagent/water = 0.75,
		/datum/reagent/sugar = 0.15
		)

/datum/reagent/nutriment/oil
	name = "Cooking Oil"
	description = "Liquid fat usually used for cooking. Refined and deodorized."

	taste_description = "oil"
	taste_mult = 0.1

	reagent_state = LIQUID
	color = "#f7eaaf"

	nutriment_factor = 3.0

/datum/reagent/nutriment/oil/touch_turf(turf/simulated/T)
	if(!istype(T))
		return

	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air(T:air:total_moles)
		lowertemp.temperature = max(min(lowertemp.temperature-2000, lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

	if(volume >= 3)
		T.wet_floor()

/datum/reagent/nutriment/oil/corn
	name = "Corn Oil"
	description = "An oil derived from various types of corn."

	taste_description = "oil"
	taste_mult = 1.0

	color = "#dbc559"

	decompile_results = list(
		/datum/reagent/nutriment/oil = 0.95,
		/datum/reagent/glycerol = 0.05 // Much less effective than using acid.
		)

/datum/reagent/nutriment/oil/burned
	name = "Burnt Oil"
	description = "Cooking fat that's been overheated, contains burned particles of unidentifiable origin."

	taste_description = "burned oil"
	taste_mult = 2.5

	color = "#9f7726"

	decompile_results = list(
		/datum/reagent/nutriment/oil = 0.85,
		/datum/reagent/carbon = 0.1,
		/datum/reagent/toxin = 0.05
		)

/datum/reagent/nutriment/virus_food
	name = "Virus Food"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."

	taste_description = "vomit"
	taste_mult = 2.0

	reagent_state = LIQUID
	color = "#899613"

	nutriment_factor = 1.5
	hydration_value = 0.7

	decompile_results = list(
		/datum/reagent/water = 1.0
		)

/datum/reagent/nutriment/sprinkles
	name = "Sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."

	taste_description = "childhood whimsy"

	color = "#ff00ff"

	nutriment_factor = 5.0

	decompile_results = list(
		/datum/reagent/sugar = 1.0
		)

/datum/reagent/nutriment/mint
	name = "Mint"
	description = "Also known as Mentha."

	taste_description = "mint"
	taste_mult = 5.0

	reagent_state = LIQUID
	color = "#cf3600"

	decompile_results = list(
		/datum/reagent/menthol = 0.25
		)


/* Non-food stuff like condiments */

/datum/reagent/salt // Aka Sodium Chloride
	name = "Table Salt"
	description = "A salt made of sodium chloride. Commonly used to season food."

	taste_description = "salt"
	taste_mult = 7.5

	reagent_state = SOLID
	color = "#ffffff"

	hydration_value = -7.5
	overdose = REAGENTS_OVERDOSE

/datum/reagent/blackpepper
	name = "Black Pepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	taste_description = "pepper"
	reagent_state = SOLID
	color = "#000000"

/datum/reagent/enzyme
	name = "Universal Enzyme"
	description = "A universal enzyme used in the preperation of certain chemicals and foods."

	taste_description = "sweetness"
	taste_mult = 0.7

	reagent_state = LIQUID
	color = "#365e30"

	overdose = REAGENTS_OVERDOSE

/datum/reagent/frostoil
	name = "Frost Oil"
	description = "A special oil that noticably chills the body. Extracted from Ice Peppers."

	taste_description = "mint"
	taste_mult = 10.0

	reagent_state = LIQUID
	color = "#b31008"

	ingest_met = METABOLISM_FALLBACK

	decompile_results = list(
		/datum/reagent/nutriment/oil = 0.75,
		/datum/reagent/menthol = 0.25
		)

/datum/reagent/frostoil/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	M.bodytemperature = max(M.bodytemperature - 10 * TEMPERATURE_DAMAGE_COEFFICIENT, 0)
	if(prob(1))
		M.emote("shiver")
	if(istype(M, /mob/living/carbon/metroid))
		M.bodytemperature = max(M.bodytemperature - rand(10,20), 0)
	holder.remove_reagent(/datum/reagent/capsaicin, 5)

/datum/reagent/capsaicin
	name = "Capsaicin Oil"
	description = "This is what makes chilis hot."

	taste_description = "hot peppers"
	taste_mult = 10.0

	reagent_state = LIQUID
	color = "#b31008"

	ingest_met = METABOLISM_FALLBACK
	ingest_absorbability = 1.0

	decompile_results = list(
		/datum/reagent/nutriment/oil = 0.75,
		/datum/reagent/capsaicin/condensed = 0.25 // Two times less effective than using plasma.
		)

	var/agony_dose = 5
	var/agony_amount = 2
	var/discomfort_message = "<span class='danger'>Your insides feel uncomfortably hot!</span>"
	var/metroid_temp_adj = 10

/datum/reagent/capsaicin/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	M.adjustToxLoss(0.5 * removed)

/datum/reagent/capsaicin/affect_ingest(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.can_feel_pain())
			return
	if(M.chem_doses[type] < agony_dose)
		if(prob(5) || M.chem_doses[type] == metabolism) //dose == metabolism is a very hacky way of forcing the message the first time this procs
			to_chat(M, discomfort_message)
	else
		M.apply_effect(agony_amount, PAIN, 0)
		if(prob(5))
			M.custom_emote(AUDIBLE_MESSAGE, pick("dry heaves!","coughs!","splutters!"), "AUTO_EMOTE")
			to_chat(M, "<span class='danger'>You feel like your insides are burning!</span>")
	if(istype(M, /mob/living/carbon/metroid))
		M.bodytemperature += rand(0, 15) + metroid_temp_adj
	holder.remove_reagent(/datum/reagent/frostoil, 5)

/datum/reagent/capsaicin/affect_digest(mob/living/carbon/M, alien, removed)
	affect_ingest(M, alien, removed * 0.25)

/datum/reagent/capsaicin/condensed
	name = "Condensed Capsaicin"
	description = "A chemical agent used for self-defense and in police work."

	taste_description = "scorching agony"
	taste_mult = 50.0

	reagent_state = LIQUID
	color = "#b31008"

	touch_met = 50 // Get rid of it quickly
	ingest_met = METABOLISM_FALLBACK
	ingest_absorbability = 1.0

	decompile_results = null

	agony_dose = 0.5
	agony_amount = 4
	discomfort_message = "<span class='danger'>You feel like your insides are burning!</span>"
	metroid_temp_adj = 15

/datum/reagent/capsaicin/condensed/affect_touch(mob/living/carbon/M, alien, removed)
	var/eyes_covered = 0
	var/mouth_covered = 0
	var/no_pain = 0
	var/obj/item/eye_protection = null
	var/obj/item/face_protection = null

	var/effective_strength = 5

	if(alien == IS_SKRELL)	//Larger eyes means bigger targets.
		effective_strength = 8

	var/list/protection
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		protection = list(H.head, H.glasses, H.wear_mask)
		if(!H.can_feel_pain())
			no_pain = 1 //TODO: living-level can_feel_pain() proc
	else
		protection = list(M.wear_mask)

	for(var/obj/item/I in protection)
		if(I)
			if(I.body_parts_covered & EYES)
				eyes_covered = 1
				eye_protection = I.name
			if(I.body_parts_covered & FACE)
				mouth_covered = 1
				face_protection = I.name

	var/message = null
	if(eyes_covered)
		if(!mouth_covered)
			message = "<span class='warning'>Your [eye_protection] protects your eyes from the pepperspray!</span>"
	else
		message = "<span class='warning'>The pepperspray gets in your eyes!</span>"
		if(mouth_covered)
			M.eye_blurry = max(M.eye_blurry, effective_strength * 3)
			M.eye_blind = max(M.eye_blind, effective_strength)
		else
			M.eye_blurry = max(M.eye_blurry, effective_strength * 5)
			M.eye_blind = max(M.eye_blind, effective_strength * 2)

	if(mouth_covered)
		if(!message)
			message = "<span class='warning'>Your [face_protection] protects you from the pepperspray!</span>"
	else if(!no_pain)
		message = "<span class='danger'>Your face and throat burn!</span>"
		if(prob(25))
			M.custom_emote(AUDIBLE_MESSAGE, pick("coughs!","coughs hysterically!","splutters!"), "AUTO_EMOTE")
		M.Weaken(5)
		M.Stun(6)

/datum/reagent/capsaicin/condensed/affect_ingest(mob/living/carbon/M, alien, removed)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.can_feel_pain())
			return
	if(M.chem_doses[type] == metabolism)
		to_chat(M, "<span class='danger'>You feel like your insides are burning!</span>")
	else
		M.apply_effect(4, PAIN, 0)
		if(prob(5))
			M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>", "<span class='danger'>You feel like your insides are burning!</span>")
	if(istype(M, /mob/living/carbon/metroid))
		M.bodytemperature += rand(15, 30)
	holder.remove_reagent(/datum/reagent/frostoil, 5)

/datum/reagent/nutriment/magical_custard
	name = "Magical Custard"
	description = "It's both tasty and healthy. Must be magic."

	taste_description = "sweet pleasure"
	taste_mult = 5.0

	reagent_state = LIQUID
	color = "#FFE6A3"

	nutriment_factor = 5.0
	ingest_met = METABOLISM_FALLBACK
	ingest_absorbability = 1.0
	digest_absorbability = 1.0
	scannable = TRUE
	flags = IGNORE_MOB_SIZE

/datum/reagent/magical_custard/affect_digest(mob/living/carbon/M, alien, removed)
	M.add_chemical_effect(CE_BRUTE_REGEN, 2.5)
	M.add_chemical_effect(CE_BURN_REGEN, 2.5)
	M.adjustToxLoss(-2.5 * removed)

/datum/reagent/astrotame
	name = "Astrotame"
	description = "A space age artifical sweetener."

	taste_description = "sweetness"
	taste_mult = 15.0

	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255

/datum/reagent/sugar/caramel
	name = "Caramel"
	description = "Who would have guessed that heating sugar is so delicious?"

	taste_description = "bitter sweetness"
	taste_mult = 5.0

	reagent_state = SOLID
	color = "#ffffff"

/* Flavorings */
/datum/reagent/flavoring
	name = "Monosodium Glutamate"
	description = "Sodium salt of glutamic acid. Commonly used as a flavor enhancer and mentally retarded people detector."

	taste_mult = 25.0
	taste_description = "tastiness"

	reagent_state = SOLID
	color = "#ffffff"

/datum/reagent/flavoring/cherry
	name = "Cherry Extract"
	description = "The concentrated essence of several different kinds of berries."
	taste_description = "cherry"
	color = "#801e28"

/datum/reagent/flavoring/banana
	name = "Banana Extract"
	description = "The concentrated essence of a banana."
	taste_description = "bananas"
	color = "#c3af00"

/datum/reagent/flavoring/berry
	name = "Berry Extract"
	description = "The concentrated essence of several different kinds of berries."
	taste_description = "berries"
	color = "#990066"

/datum/reagent/flavoring/carrot
	name = "Carrot Extract"
	description = "The concentrated essence of a carrot."
	taste_description = "carrots"
	color = "#ff8c00"

/datum/reagent/flavoring/grape
	name = "Grape Extract"
	description = "The concentrated essence of grapes."
	taste_description = "grapes"
	color = "#863333"

/datum/reagent/flavoring/lemon
	name = "Lemon Extract"
	description = "The concentrated essence of a lemon."
	taste_description = "lemons"
	color = "#afaf00"

/datum/reagent/flavoring/lime
	name = "Lime Extract"
	description = "The concentrated essence of a lime."
	taste_description = "limes"
	color = "#365e30"

/datum/reagent/flavoring/orange
	name = "Orange Extract"
	description = "The concentrated essence of an orange."
	taste_description = "oranges"
	color = "#e78108"

/datum/reagent/flavoring/potato
	name = "Potato Extract"
	description = "The concentrated essence of a potato."
	taste_description = "potatoes"
	color = "#302000"

/datum/reagent/flavoring/garlic
	name = "Garlic Extract"
	description = "The concentrated essence of a garlic."
	taste_description = "garlic"
	color = "#eeddcc"

/datum/reagent/flavoring/onion
	name = "Onion Extract"
	description = "The concentrated essence of an onion."
	taste_description = "onions"
	color = "#ffeedd"

/datum/reagent/flavoring/tomato
	name = "Tomato Extract"
	description = "The concentrated essence of a tomato."
	taste_description = "tomatoes"
	color = "#731008"

/datum/reagent/flavoring/watermelon
	name = "Watermelon Extract"
	description = "The concentrated essence of a watermelon."
	taste_description = "watermelon"
	color = "#b83333"

/datum/reagent/flavoring/apple
	name = "Apple Extract"
	description = "The concentrated essence of an apple."
	taste_description = "apples"
	color = "#e59C40"

/datum/reagent/flavoring/coconut
	name = "Coconut Extract"
	description = "The concentrated essence of a coconut."
	taste_description = "coconut"
	color = "#ffffff"

/datum/reagent/flavoring/chocolate
	name = "Chocolate Flavoring"
	description = "It tastes pretty much like chocolate, yet it's safe for dogs and yields less happiness."
	taste_description = "chocolate flavoring"
	color = "#302000"

/datum/reagent/flavoring/coffee
	name = "Coffee Flavoring"
	description = "Artificial coffee flavoring. It's much like your regular coffee, but concentrated and pretty much soulless."
	taste_description = "coffee flavoring"
	color = "#482000"
