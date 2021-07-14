/* Food */

/datum/reagent/nutriment
	name = "Nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	taste_mult = 4
	reagent_state = SOLID
	metabolism = REM * 4
	var/nutriment_factor = 10 // Per unit
	var/injectable = 0
	color = "#664330"

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
		M.adjustToxLoss(0.2 * removed)
		return
	affect_ingest(M, alien, removed)

/datum/reagent/nutriment/affect_ingest(mob/living/carbon/M, alien, removed)
	M.heal_organ_damage(0.5 * removed, 0) //what

	adjust_nutrition(M, alien, removed)
	M.add_chemical_effect(CE_BLOODRESTORE, 4 * removed)

/datum/reagent/nutriment/proc/adjust_nutrition(mob/living/carbon/M, alien, removed)
	switch(alien)
		if(IS_UNATHI) removed *= 0.1 // Unathi get most of their nutrition from meat.
	M.nutrition += nutriment_factor * removed // For hunger and fatness

/datum/reagent/nutriment/glucose
	name = "Glucose"
	color = "#ffffff"

	injectable = 1

/datum/reagent/nutriment/protein // Bad for Skrell!
	name = "animal protein"
	taste_description = "some sort of protein"
	color = "#440000"

/datum/reagent/nutriment/protein/affect_ingest(mob/living/carbon/M, alien, removed)
	switch(alien)
		if(IS_SKRELL)
			M.adjustToxLoss(0.5 * removed)
			return
	..()

/datum/reagent/nutriment/protein/adjust_nutrition(mob/living/carbon/M, alien, removed)
	switch(alien)
		if(IS_UNATHI) removed *= 2.25
	M.nutrition += nutriment_factor * removed // For hunger and fatness

/datum/reagent/nutriment/protein/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien && alien == IS_SKRELL)
		M.adjustToxLoss(2 * removed)
		return
	..()

/datum/reagent/nutriment/protein/egg // Also bad for skrell.
	name = "egg yolk"
	taste_description = "egg"
	color = "#ffffaa"

/datum/reagent/nutriment/honey
	name = "Honey"
	description = "A golden yellow syrup, loaded with sugary sweetness."
	taste_description = "sweetness"
	nutriment_factor = 10
	color = "#ffff00"

/datum/reagent/honey/affect_ingest(mob/living/carbon/M, alien, removed)
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
	nutriment_factor = 1
	color = "#ffffff"

/datum/reagent/nutriment/flour/touch_turf(turf/simulated/T)
	if(!istype(T, /turf/space))
		new /obj/effect/decal/cleanable/flour(T)
		if(T.wet > 1)
			T.wet = min(T.wet, 1)
		else
			T.wet = 0

/datum/reagent/nutriment/coco
	name = "Coco Powder"
	description = "A fatty, bitter paste made from coco beans."
	taste_description = "bitterness"
	taste_mult = 1.3
	reagent_state = SOLID
	nutriment_factor = 5
	color = "#302000"

/datum/reagent/nutriment/soysauce
	name = "Soysauce"
	description = "A salty sauce made from the soy plant."
	taste_description = "umami"
	taste_mult = 1.1
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#792300"

/datum/reagent/nutriment/ketchup
	name = "Ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	taste_description = "ketchup"
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#731008"

/datum/reagent/nutriment/barbecue
	name = "Barbecue Sauce"
	description = "Barbecue sauce for barbecues and long shifts."
	taste_description = "barbecue"
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#4f330f"

/datum/reagent/nutriment/garlicsauce
	name = "Garlic Sauce"
	description = "Garlic sauce, perfect for spicing up a plate of garlic."
	taste_description = "garlic"
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#d8c045"

/datum/reagent/nutriment/rice
	name = "Rice"
	description = "Enjoy the great taste of nothing."
	taste_description = "rice"
	taste_mult = 0.4
	reagent_state = SOLID
	nutriment_factor = 1
	color = "#ffffff"

/datum/reagent/nutriment/cherryjelly
	name = "Cherry Jelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	taste_description = "cherry"
	taste_mult = 1.3
	reagent_state = LIQUID
	nutriment_factor = 1
	color = "#801e28"

/datum/reagent/nutriment/cornoil
	name = "Corn Oil"
	description = "An oil derived from various types of corn."
	taste_description = "metroid"
	taste_mult = 0.1
	reagent_state = LIQUID
	nutriment_factor = 20
	color = "#302000"

/datum/reagent/nutriment/cornoil/touch_turf(turf/simulated/T)
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

/datum/reagent/nutriment/virus_food
	name = "Virus Food"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	taste_description = "vomit"
	taste_mult = 2
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#899613"

/datum/reagent/nutriment/sprinkles
	name = "Sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	taste_description = "childhood whimsy"
	nutriment_factor = 1
	color = "#ff00ff"

/datum/reagent/nutriment/mint
	name = "Mint"
	description = "Also known as Mentha."
	taste_description = "mint"
	reagent_state = LIQUID
	color = "#cf3600"

/datum/reagent/lipozine // The anti-nutriment.
	name = "Lipozine"
	description = "A chemical compound that causes a powerful fat-burning reaction."
	taste_description = "mothballs"
	reagent_state = LIQUID
	color = "#bbeda4"
	overdose = REAGENTS_OVERDOSE

/datum/reagent/lipozine/affect_blood(mob/living/carbon/M, alien, removed)
	M.nutrition = max(M.nutrition - 10 * removed, 0)

/* Non-food stuff like condiments */

/datum/reagent/sodiumchloride
	name = "Table Salt"
	description = "A salt made of sodium chloride. Commonly used to season food."
	taste_description = "salt"
	reagent_state = SOLID
	color = "#ffffff"
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
	taste_mult = 1.5
	reagent_state = LIQUID
	color = "#b31008"

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
	taste_mult = 1.5
	reagent_state = LIQUID
	color = "#b31008"
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
			M.custom_emote(2, "[pick("dry heaves!","coughs!","splutters!")]")
			to_chat(M, "<span class='danger'>You feel like your insides are burning!</span>")
	if(istype(M, /mob/living/carbon/metroid))
		M.bodytemperature += rand(0, 15) + metroid_temp_adj
	holder.remove_reagent(/datum/reagent/frostoil, 5)

/datum/reagent/capsaicin/condensed
	name = "Condensed Capsaicin"
	description = "A chemical agent used for self-defense and in police work."
	taste_description = "scorching agony"
	taste_mult = 10
	reagent_state = LIQUID
	touch_met = 50 // Get rid of it quickly
	color = "#b31008"
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
			M.custom_emote(2, "[pick("coughs!","coughs hysterically!","splutters!")]")
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

/* Drinks */

/datum/reagent/drink
	name = "Drink"
	description = "Uh, some kind of drink."
	reagent_state = LIQUID
	color = "#e78108"
	var/nutrition = 0 // Per unit
	var/adj_dizzy = 0 // Per tick
	var/adj_drowsy = 0
	var/adj_sleepy = 0
	var/adj_temp = 0
	var/adj_speed = 0

/datum/reagent/drink/affect_blood(mob/living/carbon/M, alien, removed)
	M.adjustToxLoss(removed) // Probably not a good idea; not very deadly though
	return

/datum/reagent/drink/affect_ingest(mob/living/carbon/M, alien, removed)
	M.nutrition += nutrition * removed
	M.dizziness = max(0, M.dizziness + adj_dizzy)
	M.drowsyness = max(0, M.drowsyness + adj_drowsy)
	M.sleeping = max(0, M.sleeping + adj_sleepy)
	if(adj_temp > 0 && M.bodytemperature < 310) // 310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(adj_temp < 0 && M.bodytemperature > 310)
		M.bodytemperature = min(310, M.bodytemperature - (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(adj_speed)
		M.add_up_to_chemical_effect(adj_speed < 0 ? CE_SLOWDOWN : CE_SPEEDBOOST, adj_speed)

// Juices
/datum/reagent/drink/juice/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.immunity = min(M.immunity + 0.25, M.immunity_norm*1.5)
	var/effective_dose = M.chem_doses[type]/2
	if(alien == IS_UNATHI)
		if(effective_dose < 2)
			if(effective_dose == metabolism * 2 || prob(5))
				M.emote("yawn")
		else if(effective_dose < 5)
			M.eye_blurry = max(M.eye_blurry, 10)
		else if(effective_dose < 20)
			if(prob(50))
				M.Weaken(2)
			M.drowsyness = max(M.drowsyness, 20)
		else
			M.sleeping = max(M.sleeping, 20)
			M.drowsyness = max(M.drowsyness, 60)

/datum/reagent/drink/juice/banana
	name = "Banana Juice"
	description = "The raw essence of a banana."
	taste_description = "banana"
	color = "#c3af00"

	glass_name = "banana juice"
	glass_desc = "The raw essence of a banana. HONK!"

/datum/reagent/drink/juice/berry
	name = "Berry Juice"
	description = "A delicious blend of several different kinds of berries."
	taste_description = "berries"
	color = "#990066"

	glass_name = "berry juice"
	glass_desc = "Berry juice. Or maybe it's jam. Who cares?"

/datum/reagent/drink/juice/carrot
	name = "Carrot juice"
	description = "It is just like a carrot but without crunching."
	taste_description = "carrots"
	color = "#ff8c00" // rgb: 255, 140, 0

	glass_name = "carrot juice"
	glass_desc = "It is just like a carrot but without crunching."

/datum/reagent/drink/juice/carrot/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.reagents.add_reagent(/datum/reagent/imidazoline, removed * 0.2)

/datum/reagent/drink/juice/grape
	name = "Grape Juice"
	description = "It's grrrrrape!"
	taste_description = "grapes"
	color = "#863333"

	glass_name = "grape juice"
	glass_desc = "It's grrrrrape!"

/datum/reagent/drink/juice/lemon
	name = "Lemon Juice"
	description = "This juice is VERY sour."
	taste_description = "sourness"
	taste_mult = 1.1
	color = "#afaf00"

	glass_name = "lemon juice"
	glass_desc = "Sour..."

/datum/reagent/drink/juice/lime
	name = "Lime Juice"
	description = "The sweet-sour juice of limes."
	taste_description = "unbearable sourness"
	taste_mult = 1.1
	color = "#365e30"

	glass_name = "lime juice"
	glass_desc = "A glass of sweet-sour lime juice"

/datum/reagent/drink/juice/lime/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.adjustToxLoss(-0.5 * removed)

/datum/reagent/drink/juice/orange
	name = "Orange juice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	taste_description = "oranges"
	color = "#e78108"

	glass_name = "orange juice"
	glass_desc = "Vitamins! Yay!"

/datum/reagent/drink/juice/orange/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.adjustOxyLoss(-2 * removed)

/datum/reagent/toxin/poisonberryjuice // It has more in common with toxins than drinks... but it's a juice
	name = "Poison Berry Juice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	taste_description = "berries"
	color = "#863353"
	strength = 5

	glass_name = "poison berry juice"
	glass_desc = "A glass of deadly juice."

/datum/reagent/toxin/poisonberryjuice/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_UNATHI)
		return //unathi are immune!
	return ..()

/datum/reagent/drink/juice/potato
	name = "Potato Juice"
	description = "Juice of the potato. Bleh."
	taste_description = "irish sadness"
	nutrition = 2
	color = "#302000"

	glass_name = "potato juice"
	glass_desc = "Juice from a potato. Bleh."

/datum/reagent/drink/juice/garlic
	name = "Garlic Juice"
	description = "Who would even drink this?"
	taste_description = "bad breath"
	nutrition = 1
	color = "#eeddcc"

	glass_name = "garlic juice"
	glass_desc = "Who would even drink juice from garlic?"

/datum/reagent/drink/juice/onion
	name = "Onion Juice"
	description = "Juice from an onion, for when you need to cry."
	taste_description = "stinging tears"
	nutrition = 1
	color = "#ffeedd"

	glass_name = "onion juice"
	glass_desc = "Juice from an onion, for when you need to cry."

/datum/reagent/drink/juice/tomato
	name = "Tomato Juice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	taste_description = "tomatoes"
	color = "#731008"

	glass_name = "tomato juice"
	glass_desc = "Are you sure this is tomato juice?"

/datum/reagent/drink/juice/tomato/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.heal_organ_damage(0, 0.5 * removed)

/datum/reagent/drink/juice/watermelon
	name = "Watermelon Juice"
	description = "Delicious juice made from watermelon."
	taste_description = "sweet watermelon"
	color = "#b83333"

	glass_name = "watermelon juice"
	glass_desc = "Delicious juice made from watermelon."

/datum/reagent/drink/juice/apple
	name = "Apple Juice"
	description = "Apples! Apples! Apples!"
	taste_description = "apples"
	color = "#E59C40"

	glass_name = "apple juice"
	glass_desc = "Two cups a day keep the doctor away!"

/datum/reagent/drink/juice/apple/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.heal_organ_damage(0, 0.5 * removed)

/datum/reagent/drink/juice/coconut
	name = "Coconut Milk"
	description = "It's white and smells like your granny's rice pudding."
	taste_description = "coconut"
	color = "FFFFFF"

	glass_name = "coconut milk"
	glass_desc = "How do they milk coconuts?"

// Everything else

/datum/reagent/drink/milk
	name = "Milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	taste_description = "milk"
	color = "#dfdfdf"

	glass_name = "milk"
	glass_desc = "White and nutritious goodness!"

/datum/reagent/drink/milk/chocolate
	name =  "Chocolate Milk"
	description = "A mixture of perfectly healthy milk and delicious chocolate."
	taste_description = "chocolate milk"
	color = "#74533b"

	glass_name = "chocolate milk"
	glass_desc = "Deliciously fattening!"

/datum/reagent/drink/milk/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.heal_organ_damage(0.5 * removed, 0)
	holder.remove_reagent(/datum/reagent/capsaicin, 10 * removed)

/datum/reagent/drink/milk/cream
	name = "Cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	taste_description = "creamy milk"
	color = "#dfd7af"

	glass_name = "cream"
	glass_desc = "Ewwww..."

/datum/reagent/drink/milk/soymilk
	name = "Soy Milk"
	description = "An opaque white liquid made from soybeans."
	taste_description = "soy milk"
	color = "#dfdfc7"

	glass_name = "soy milk"
	glass_desc = "White and nutritious soy goodness!"

/datum/reagent/drink/tea
	name = "Tea"
	description = "Tasty black tea, it has antioxidants, it's good for you!"
	taste_description = "tart black tea"
	color = "#101000"
	adj_dizzy = -2
	adj_drowsy = -1
	adj_sleepy = -3
	adj_temp = 20

	glass_name = "tea"
	glass_desc = "Tasty black tea, it has antioxidants, it's good for you!"
	glass_special = list(DRINK_VAPOR)

/datum/reagent/drink/tea/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.adjustToxLoss(-0.5 * removed)

/datum/reagent/drink/tea/icetea
	name = "Iced Tea"
	description = "No relation to a certain rap artist/ actor."
	taste_description = "sweet tea"
	color = "#104038" // rgb: 16, 64, 56
	adj_temp = -5

	glass_name = "iced tea"
	glass_desc = "No relation to a certain rap artist/ actor."
	glass_special = list(DRINK_ICE)

/datum/reagent/drink/coffee
	name = "Coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	taste_description = "bitterness"
	taste_mult = 1.3
	color = "#482000"
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	adj_temp = 25
	adj_speed = 0.3
	overdose = 45

	glass_name = "coffee"
	glass_desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."
	glass_special = list(DRINK_VAPOR)

/datum/reagent/drink/coffee/affect_ingest(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	..()
	if(alien == IS_TAJARA)
		M.adjustToxLoss(0.5 * removed)
		M.make_jittery(4) //extra sensitive to caffine
	if(adj_temp > 0)
		holder.remove_reagent(/datum/reagent/frostoil, 10 * removed)
	if(volume > 15)
		M.add_chemical_effect(CE_PULSE, 1)

/datum/reagent/nutriment/coffee/affect_blood(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_TAJARA)
		M.adjustToxLoss(2 * removed)
		M.make_jittery(4)
		return
	M.add_chemical_effect(CE_PULSE, 2)

/datum/reagent/drink/coffee/overdose(mob/living/carbon/M, alien)
	if(alien == IS_DIONA)
		return
	if(alien == IS_TAJARA)
		M.adjustToxLoss(4 * REM)
		M.apply_effect(3, STUTTER)
	M.make_jittery(5)
	M.add_chemical_effect(CE_PULSE, 2)
	M.add_up_to_chemical_effect(CE_SPEEDBOOST, 1)

/datum/reagent/drink/coffee/icecoffee
	name = "Iced Coffee"
	description = "Coffee and ice, refreshing and cool."
	taste_description = "bitter coldness"
	color = "#888179"
	adj_temp = -5

	glass_required = "square"
	glass_icon_state = "icedcoffee"
	glass_name = "cafe latte"
	glass_desc = "A drink to perk you up and refresh you!"
	glass_special = list(DRINK_ICE)

/datum/reagent/drink/coffee/soy_latte
	name = "Soy Latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	taste_description = "creamy coffee"
	color = "#c65905"
	adj_temp = 5

	glass_required = "coffeecup"
	glass_icon_state = "soylatte"
	glass_name = "soy latte"
	glass_desc = "A nice and refrshing beverage while you are reading."

/datum/reagent/drink/coffee/soy_latte/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.heal_organ_damage(0.5 * removed, 0)

/datum/reagent/drink/coffee/cafe_latte
	name = "Cafe Latte"
	description = "A nice, strong and tasty beverage while you are reading."
	taste_description = "bitter cream"
	color = "#c65905"
	adj_temp = 5

	glass_required = "coffeecup"
	glass_icon_state = "coffeelatte"
	glass_name = "cafe latte"
	glass_desc = "A nice, strong and refreshing beverage while you are reading."

/datum/reagent/drink/coffee/cafe_latte/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.heal_organ_damage(0.5 * removed, 0)

/datum/reagent/drink/coffee/cappuccino
	name = "Cappuccino"
	description = "A nice, light coffee beverage made of espresso and steamed milk."
	taste_description = "creamy coffee"
	color = "#c65905"
	adj_temp = 5

	glass_required = "coffeecup"
	glass_icon_state = "cappuccino"
	glass_name = "cappuccino"
	glass_desc = "A nice, light coffee beverage made of espresso and steamed milk."

/datum/reagent/drink/coffee/cappuccino/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.heal_organ_damage(0.5 * removed, 0)

/datum/reagent/drink/hot_coco
	name = "Hot Chocolate"
	description = "Made with love! And cocoa beans."
	taste_description = "creamy chocolate"
	reagent_state = LIQUID
	color = "#5B250C"
	nutrition = 2
	adj_temp = 30

	glass_required = "square"
	glass_name = "hot chocolate"
	glass_desc = "Made with love! And cocoa beans."
	glass_special = list(DRINK_VAPOR)

/datum/reagent/drink/sodawater
	name = "Soda Water"
	description = "A can of club soda. Why not make a scotch and soda?"
	taste_description = "carbonated water"
	color = "#619494"
	adj_dizzy = -5
	adj_drowsy = -3
	adj_temp = -5

	glass_name = "soda water"
	glass_desc = "Soda water. Why not make a scotch and soda?"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/drink/grapesoda
	name = "Grape Soda"
	description = "Grapes made into a fine drank."
	taste_description = "grape soda"
	color = "#421c52"
	adj_drowsy = -3
	adj_speed = 0.3

	glass_name = "grape soda"
	glass_desc = "Looks like a delicious drink!"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/drink/tonic
	name = "Tonic Water"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	taste_description = "tart and fresh"
	color = "#619494"
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	adj_temp = -5
	adj_speed = 0.3

	glass_name = "tonic water"
	glass_desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."

/datum/reagent/drink/lemonade
	name = "Lemonade"
	description = "Oh the nostalgia..."
	taste_description = "tartness"
	color = "#ffff00"
	adj_temp = -5

	glass_desc = "Oh the nostalgia..."
	glass_special = list(DRINK_FIZZ, DRINK_ICE)

/datum/reagent/drink/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	taste_description = "fruity sweetness"
	color = "#cccc99"
	adj_temp = -5

	glass_required = "rocks"
	glass_icon_state = "kiraspecial"
	glass_name = "Kira Special"
	glass_desc = "Long live the guy who everyone had mistaken for a girl. Baka!"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/drink/brownstar
	name = "Brown Star"
	description = "It's not what it sounds like..."
	taste_description = "orange and cola soda"
	color = "#9f3400"
	adj_temp = -2
	adj_speed = 0.3

	glass_required = "pint"
	glass_name = "Brown Star"
	glass_desc = "It's not what it sounds like..."

/datum/reagent/drink/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	taste_description = "creamy vanilla"
	color = "#aee5e4"
	adj_temp = -9

	glass_required = "shake"
	glass_icon_state = "milkshake"
	glass_name = "milkshake"
	glass_desc = "Glorious brainfreezing mixture."

/datum/reagent/milkshake/affect_ingest(mob/living/carbon/M, alien, removed)
	..()

	var/effective_dose = M.chem_doses[type]/2
	if(alien == IS_UNATHI)
		if(effective_dose < 2)
			if(effective_dose == metabolism * 2 || prob(5))
				M.emote("yawn")
		else if(effective_dose < 5)
			M.eye_blurry = max(M.eye_blurry, 10)
		else if(effective_dose < 20)
			if(prob(50))
				M.Weaken(2)
			M.drowsyness = max(M.drowsyness, 20)
		else
			M.sleeping = max(M.sleeping, 20)
			M.drowsyness = max(M.drowsyness, 60)

/datum/reagent/drink/rewriter
	name = "Rewriter"
	description = "The secret of the sanctuary of the Libarian..."
	taste_description = "a bad night out"
	color = "#485000"
	adj_temp = -5

	glass_required = "mug"
	glass_name = "Rewriter"
	glass_desc = "The secret of the sanctuary of the Libarian..."

/datum/reagent/drink/rewriter/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.make_jittery(5)

/datum/reagent/drink/nuka_cola
	name = "Nuka Cola"
	description = "Cola, cola never changes."
	taste_description = "the future"
	color = "#006600"
	adj_temp = -5
	adj_sleepy = -2
	adj_speed = 0.8

	glass_name = "Nuka-Cola"
	glass_desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/drink/nuka_cola/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.make_jittery(20)
	M.make_drugged(30)
	M.dizziness += 5
	M.drowsyness = 0

/datum/reagent/drink/grenadine
	name = "Grenadine Syrup"
	description = "Made in the modern day with proper pomegranate substitute. Who uses real fruit, anyways?"
	taste_description = "100% pure pomegranate"
	color = "#ff004f"

	glass_required = "shake"
	glass_icon_state = "grenadinesyrup"
	glass_name = "grenadine syrup"
	glass_desc = "Sweet and tangy, a bar syrup used to add color or flavor to drinks."

/datum/reagent/drink/space_cola
	name = "Space Cola"
	description = "A refreshing beverage."
	taste_description = "cola"
	reagent_state = LIQUID
	color = "#100800"
	adj_drowsy = -3
	adj_temp = -5
	adj_speed = 0.3

	glass_name = "Space Cola"
	glass_desc = "A glass of refreshing Space Cola"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/drink/spacemountainwind
	name = "Mountain Wind"
	description = "Blows right through you like a space wind."
	taste_description = "sweet citrus soda"
	color = "#66ff66"
	adj_drowsy = -7
	adj_sleepy = -1
	adj_temp = -5
	adj_speed = 0.3

	glass_name = "Space Mountain Wind"
	glass_desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/drink/dr_gibb
	name = "Dr. Gibb"
	description = "A delicious blend of 42 different flavours"
	taste_description = "cherry soda"
	color = "#800000"
	adj_drowsy = -6
	adj_temp = -5
	adj_speed = 0.3

	glass_name = "Dr. Gibb"
	glass_desc = "Dr. Gibb. Not as dangerous as the name might imply."

/datum/reagent/drink/space_up
	name = "Space-Up"
	description = "Tastes like a hull breach in your mouth."
	taste_description = "a hull breach"
	color = "#202800"
	adj_temp = -8
	adj_speed = 0.3

	glass_name = "Space-up"
	glass_desc = "Space-up. It helps keep your cool."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/drink/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	taste_description = "tangy lime and lemon soda"
	color = "#878f00"
	adj_temp = -8
	adj_speed = 0.3

	glass_name = "lemon lime soda"
	glass_desc = "A tangy substance made of 0.5% natural citrus!"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/drink/energy
	name = "energy drink"
	description = "Contains high levels of caffeine. Prohibited for use by children, pregnant women, people sensitive to caffeine, people not sensitive to caffeine, tajaran, animals and medical bots."
	taste_description = "energy"
	taste_mult = 1.3
	color = "#67ff00"
	adj_drowsy = -6
	adj_sleepy = -2
	adj_temp = -8
	adj_speed = 0.4
	overdose = 45

	glass_name = "energy drink"
	glass_desc = "Looks like a liquid power cell."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/drink/energy/affect_ingest(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	..()
	if(alien == IS_TAJARA)
		M.adjustToxLoss(0.5 * removed)
		M.make_jittery(4) //extra sensitive to caffine, taurine, and all the kinds of shit in nrg drinks
	if(volume > 15)
		M.add_chemical_effect(CE_PULSE, 1)

/datum/reagent/drink/energy/overdose(mob/living/carbon/M, alien)
	if(alien == IS_DIONA)
		return
	if(alien == IS_TAJARA)
		M.adjustToxLoss(4 * REM)
		M.apply_effect(3, STUTTER)
	M.make_jittery(5)
	M.add_chemical_effect(CE_PULSE, 2)
	M.add_up_to_chemical_effect(CE_SPEEDBOOST, 0.8)

/datum/reagent/drink/dry_ramen
	name = "Dry Ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	taste_description = "dry and cheap noodles"
	reagent_state = SOLID
	nutrition = 1
	color = "#302000"

/datum/reagent/drink/hot_ramen
	name = "Hot Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	taste_description = "wet and cheap noodles"
	reagent_state = LIQUID
	color = "#302000"
	nutrition = 5
	adj_temp = 5

/datum/reagent/drink/hell_ramen
	name = "Hell Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	taste_description = "wet and cheap noodles on fire"
	reagent_state = LIQUID
	color = "#302000"
	nutrition = 5

/datum/reagent/drink/hell_ramen/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT

/datum/reagent/drink/chicken_powder
	name = "Chicken Powder"
	description = "Space age food AND cold medicine. Contains Chicken Powder ^t^m and chemicals that boil in contact with water."
	taste_description = "chicked-flavored powder"
	reagent_state = SOLID
	nutrition = 1
	color = "#302000"

/datum/reagent/drink/chicken_soup
	name = "Chicken Soup"
	description = "No chickens were harmed in the making of this soup."
	taste_description = "somewhat tasteless chicken broth"
	reagent_state = LIQUID
	color = "#c9b042"
	nutrition = 5
	adj_temp = 5

	glass_name = "chicken soup"
	glass_desc = "A hot cup'o'soup."
	glass_icon = DRINK_ICON_NOISY

/datum/reagent/drink/chicken_soup/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return

	M.add_chemical_effect(CE_PAINKILLER, 5)
	M.add_chemical_effect(CE_ANTIVIRAL, 0.5)

/datum/reagent/drink/ice
	name = "Ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	taste_description = "ice"
	taste_mult = 1.5
	reagent_state = SOLID
	color = "#619494"
	adj_temp = -5

	glass_name = "ice"
	glass_desc = "Generally, you're supposed to put something else in there too..."
	glass_icon = DRINK_ICON_NOISY

/datum/reagent/drink/nothing
	name = "Nothing"
	description = "Absolutely nothing."
	taste_description = "nothing"

	glass_name = "nothing"
	glass_desc = "Absolutely nothing."
