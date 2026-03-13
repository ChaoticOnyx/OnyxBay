
/* Drinks */

/datum/reagent/drink
	name = "Drink"
	description = "Uh, some kind of drink."

	taste_mult = 2.5

	reagent_state = LIQUID
	color = "#e78108"

	metabolism = 5.0
	ingest_met = 1.0
	digest_met = 5.0
	ingest_absorbability = 0.0
	digest_absorbability = 0.0
	hydration_value = 1.0

	var/nutrition = 0 // Per ml
	var/adj_dizzy = 0 // Per tick
	var/adj_drowsy = 0
	var/adj_sleepy = 0
	var/adj_temp = 0
	var/adj_speed = 0

/datum/reagent/drink/affect_blood(mob/living/carbon/M, alien, removed)
	M.adjustToxLoss(removed * 0.25) // Probably not a good idea; not very deadly though
	return

/datum/reagent/drink/affect_ingest(mob/living/carbon/M, alien, removed)
	..()

	M.add_nutrition(nutrition * removed * ingest_absorbability) // For hunger and fatness

	if(adj_temp > 0 && M.bodytemperature < 310) // 310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(adj_temp < 0 && M.bodytemperature > 310)
		M.bodytemperature = min(310, M.bodytemperature - (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	return

/datum/reagent/drink/affect_digest(mob/living/carbon/M, alien, removed)
	..()

	M.add_nutrition(nutrition * removed * digest_absorbability)

	M.dizziness = max(0, M.dizziness + adj_dizzy)
	M.drowsyness = max(0, M.drowsyness + adj_drowsy)
	M.sleeping = max(0, M.sleeping + adj_sleepy)

	if(adj_speed)
		M.add_up_to_chemical_effect(adj_speed < 0 ? CE_SLOWDOWN : CE_SPEEDBOOST, adj_speed)
	return

// Juices
/datum/reagent/drink/juice
	name = "Juice"
	description = "Some sort of juice."

	taste_mult = 2.5

	nutrition = 0.5

/datum/reagent/drink/juice/affect_digest(mob/living/carbon/M, alien, removed)
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

	taste_description = "bananas"

	color = "#c3af00"

	decompile_results = list(
		/datum/reagent/water = 0.8,
		/datum/reagent/sugar = 0.1,
		/datum/reagent/flavoring/banana = 0.1
		)

	glass_name = "banana juice"
	glass_desc = "The raw essence of a banana. HONK!"

/datum/reagent/drink/juice/berry
	name = "Berry Juice"
	description = "A delicious blend of several different kinds of berries."

	taste_description = "berries"

	color = "#990066"

	decompile_results = list(
		/datum/reagent/water = 0.8,
		/datum/reagent/sugar = 0.1,
		/datum/reagent/flavoring/berry = 0.1
		)

	glass_name = "berry juice"
	glass_desc = "Berry juice. Or maybe it's jam. Who cares?"

/datum/reagent/drink/juice/carrot
	name = "Carrot Juice"
	description = "It is just like a carrot but without crunching."

	taste_description = "carrots"

	color = "#ff8c00" // rgb: 255, 140, 0

	decompile_results = list(
		/datum/reagent/water = 0.75,
		/datum/reagent/imidazoline = 0.1,
		/datum/reagent/sugar = 0.1,
		/datum/reagent/flavoring/carrot = 0.1
		)

	glass_name = "carrot juice"
	glass_desc = "It is just like a carrot but without crunching."

/datum/reagent/drink/juice/carrot/affect_digest(mob/living/carbon/M, alien, removed)
	..()
	M.reagents.add_reagent(/datum/reagent/imidazoline, removed * 0.02)

/datum/reagent/drink/juice/grape
	name = "Grape Juice"
	description = "It's grrrrrape!"

	taste_description = "grapes"

	color = "#863333"

	decompile_results = list(
		/datum/reagent/water = 0.8,
		/datum/reagent/sugar = 0.1,
		/datum/reagent/flavoring/grape = 0.1
		)

	glass_name = "grape juice"
	glass_desc = "It's grrrrrape!"

/datum/reagent/drink/juice/lemon
	name = "Lemon Juice"
	description = "This juice is VERY sour."

	taste_description = "sourness"
	taste_mult = 5.0

	color = "#afaf00"

	decompile_results = list(
		/datum/reagent/water = 0.8,
		/datum/reagent/sugar = 0.1,
		/datum/reagent/flavoring/lemon = 0.1
		)

	glass_name = "lemon juice"
	glass_desc = "Sour..."

/datum/reagent/drink/juice/lime
	name = "Lime Juice"
	description = "The sweet-sour juice of limes."

	taste_description = "sourness"
	taste_mult = 5.0

	color = "#365e30"

	decompile_results = list(
		/datum/reagent/water = 0.8,
		/datum/reagent/sugar = 0.1,
		/datum/reagent/flavoring/lime = 0.1
		)

	glass_name = "lime juice"
	glass_desc = "A glass of sweet-sour lime juice"

/datum/reagent/drink/juice/lime/affect_digest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.adjustToxLoss(-0.1 * removed)

/datum/reagent/drink/juice/orange
	name = "Orange juice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"

	taste_description = "oranges"

	color = "#e78108"

	decompile_results = list(
		/datum/reagent/water = 0.8,
		/datum/reagent/sugar = 0.1,
		/datum/reagent/flavoring/orange = 0.1
		)

	glass_name = "orange juice"
	glass_desc = "Vitamins! Yay!"

/datum/reagent/drink/juice/orange/affect_digest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.adjustOxyLoss(-0.15 * removed)

/datum/reagent/toxin/poisonberryjuice // It has more in common with toxins than drinks... but it's a juice
	name = "Poison Berry Juice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."

	taste_description = "berries"

	color = "#863353"

	decompile_results = list(
		/datum/reagent/water = 0.4,
		/datum/reagent/sugar = 0.1,
		/datum/reagent/toxin = 0.2,
		/datum/reagent/toxin/cyanide = 0.2,
		/datum/reagent/flavoring/berry = 0.1
		)

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

	taste_description = "belarusian water"

	color = "#302000"

	decompile_results = list(
		/datum/reagent/water = 0.7,
		/datum/reagent/nutriment/flour = 0.2, // Since we don't have starch yet
		/datum/reagent/flavoring/potato = 0.1
		)

	nutrition = 1.0

	glass_name = "potato juice"
	glass_desc = "Juice from a potato. Bleh."

/datum/reagent/drink/juice/garlic
	name = "Garlic Juice"
	description = "Who would even drink this?"

	taste_description = "bad breath"
	taste_mult = 5.0

	color = "#eeddcc"

	decompile_results = list(
		/datum/reagent/water = 0.8,
		/datum/reagent/flavoring/garlic = 0.2
		)

	glass_name = "garlic juice"
	glass_desc = "Who would even drink juice from garlic?"

/datum/reagent/drink/juice/onion
	name = "Onion Juice"
	description = "Juice from an onion, for when you need to cry."

	taste_description = "stinging tears"
	taste_mult = 5.0

	color = "#ffeedd"

	decompile_results = list(
		/datum/reagent/water = 0.8,
		/datum/reagent/sugar = 0.1,
		/datum/reagent/flavoring/onion = 0.1
		)

	glass_name = "onion juice"
	glass_desc = "Juice from an onion, for when you need to cry."

/datum/reagent/drink/juice/tomato
	name = "Tomato Juice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"

	taste_description = "tomatoes"
	taste_mult = 3.5

	color = "#731008"

	decompile_results = list(
		/datum/reagent/water = 0.8,
		/datum/reagent/flavoring = 0.1,
		/datum/reagent/flavoring/tomato = 0.1
		)

	glass_name = "tomato juice"
	glass_desc = "Are you sure this is tomato juice?"

/datum/reagent/drink/juice/tomato/affect_digest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.add_chemical_effect(CE_BURN_REGEN, 0.5)

/datum/reagent/drink/juice/watermelon
	name = "Watermelon Juice"
	description = "Delicious juice made from watermelon."

	taste_description = "watermelon"

	color = "#b83333"

	decompile_results = list(
		/datum/reagent/water = 0.8,
		/datum/reagent/sugar = 0.1,
		/datum/reagent/flavoring/watermelon = 0.1
		)

	glass_name = "watermelon juice"
	glass_desc = "Delicious juice made from watermelon."

/datum/reagent/drink/juice/apple
	name = "Apple Juice"
	description = "Apples! Apples! Apples!"

	taste_description = "apples"

	color = "#e59C40"

	decompile_results = list(
		/datum/reagent/water = 0.8,
		/datum/reagent/sugar = 0.1,
		/datum/reagent/flavoring/apple = 0.1
		)

	glass_name = "apple juice"
	glass_desc = "Two cups a day keep the doctor away!"

/datum/reagent/drink/juice/apple/affect_digest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.add_chemical_effect(CE_BURN_REGEN, 0.5)

/datum/reagent/drink/juice/coconut
	name = "Coconut Milk"
	description = "It's white and smells like your granny's rice pudding."

	taste_description = "coconut"

	color = "#ffffff"

	decompile_results = list(
		/datum/reagent/water = 0.9,
		/datum/reagent/flavoring/coconut = 0.1
		)

	glass_name = "coconut milk"
	glass_desc = "How do they milk coconuts?"

// Everything else

/datum/reagent/drink/milk
	name = "Milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."

	taste_description = "milk"

	color = "#dfdfdf"

	hydration_value = 0.9
	nutrition = 0.75

	decompile_results = list(
		/datum/reagent/water = 0.5,
		/datum/reagent/drink/milk/cream = 0.5
		)

	glass_name = "milk"
	glass_desc = "White and nutritious goodness!"

/datum/reagent/drink/milk/affect_digest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.add_chemical_effect(CE_BRUTE_REGEN, 0.5)
	holder.remove_reagent(/datum/reagent/capsaicin, 10 * removed)

/datum/reagent/drink/milk/chocolate
	name =  "Chocolate Milk"
	description = "A mixture of perfectly healthy milk and delicious chocolate."

	taste_description = "chocolate milk"

	color = "#74533b"

	nutrition = 1.25

	decompile_results = list(
		/datum/reagent/drink/milk = 0.75,
		/datum/reagent/nutriment/coco = 0.25
		)

	glass_name = "chocolate milk"
	glass_desc = "Deliciously fattening!"

/datum/reagent/drink/milk/cream
	name = "Cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"

	taste_description = "creamy milk"

	color = "#dfd7af"

	hydration_value = 0.6
	nutrition = 1.5

	decompile_results = list(
		/datum/reagent/water = 0.5,
		/datum/reagent/nutriment/oil = 0.5
		)

	glass_name = "cream"
	glass_desc = "Ewwww..."

/datum/reagent/drink/milk/soymilk
	name = "Soy Milk"
	description = "An opaque white liquid made from soybeans."

	taste_description = "soy milk"

	color = "#dfdfc7"

	hydration_value = 0.9

	decompile_results = list(
		/datum/reagent/water = 0.5,
		/datum/reagent/nutriment/protein = 0.25,
		/datum/reagent/nutriment/flour = 0.25
		)

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

/datum/reagent/drink/tea/affect_digest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.adjustToxLoss(-0.1 * removed)

/datum/reagent/drink/tea/icetea
	name = "Iced Tea"
	description = "No relation to a certain rap artist/ actor."

	taste_description = "sweet tea"

	color = "#104038" // rgb: 16, 64, 56

	adj_temp = -5

	glass_required = "square"
	glass_icon_state = "icedtea"
	glass_name = "iced tea"
	glass_desc = "No relation to a certain rap artist/ actor."
	glass_special = list(DRINK_ICE)

/datum/reagent/drink/hot_coco
	name = "Hot Chocolate"
	description = "Made with love! And cocoa beans."

	taste_description = "creamy chocolate"

	reagent_state = LIQUID
	color = "#5B250C"

	nutrition = 0.5
	adj_temp = 30
	hydration_value = 0.9

	decompile_results = list(
		/datum/reagent/water = 1.0,
		/datum/reagent/nutriment/coco = 0.2
		)

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

	decompile_results = list(
		/datum/reagent/water = 1.0
		)

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

	decompile_results = list(
		/datum/reagent/water = 1.0,
		/datum/reagent/flavoring/grape = 0.1
		)

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

	decompile_results = list(
		/datum/reagent/water = 1.0
		)

	glass_name = "tonic water"
	glass_desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."

/datum/reagent/drink/lemonade
	name = "Lemonade"
	description = "Oh the nostalgia..."

	taste_description = "tartness"

	color = "#ffff00"
	adj_temp = -5

	decompile_results = list(
		/datum/reagent/water = 0.5,
		/datum/reagent/sugar = 0.5,
		/datum/reagent/flavoring/lemon = 0.1
		)

	glass_name = "lemonade"
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
	hydration_value = 0.7
	nutrition = 0.9

	decompile_results = list(
		/datum/reagent/water = 0.4,
		/datum/reagent/drink/milk = 0.4,
		/datum/reagent/drink/milk/cream = 0.2
		)

	glass_required = "shake"
	glass_icon_state = "milkshake"
	glass_name = "milkshake"
	glass_desc = "Glorious brainfreezing mixture."

/datum/reagent/milkshake/affect_digest(mob/living/carbon/M, alien, removed)
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

/datum/reagent/drink/rewriter/affect_digest(mob/living/carbon/M, alien, removed)
	..()
	M.make_jittery(5)

/datum/reagent/drink/nuka_cola
	name = "Nuka Cola"
	description = "Cola, cola never changes."

	taste_description = "the future"

	color = "#006600"

	nutrition = 0.25
	adj_temp = -5
	adj_sleepy = -2
	adj_speed = 0.8

	glass_name = "Nuka-Cola"
	glass_desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/drink/nuka_cola/affect_digest(mob/living/carbon/M, alien, removed)
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

	hydration_value = 0.4

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

	nutrition = 0.25
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

	nutrition = 0.25
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

	nutrition = 0.25
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

	nutrition = 0.25
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

	nutrition = 0.25
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

	nutrition = 0.25
	adj_drowsy = -6
	adj_sleepy = -2
	adj_temp = -8
	adj_speed = 0.4
	overdose = 0.4 LITERS

	glass_name = "energy drink"
	glass_desc = "Looks like a liquid power cell."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/drink/energy/affect_digest(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	..()
	if(alien == IS_TAJARA)
		M.adjustToxLoss(0.5 * removed)
		M.make_jittery(4) //extra sensitive to caffine, taurine, and all the kinds of shit in nrg drinks
	if(volume > 100)
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
	color = "#302000"

	nutrition = 4.0
	hydration_value = -2.5 // Dry, you see

/datum/reagent/drink/hot_ramen
	name = "Hot Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."

	taste_description = "wet and cheap noodles"

	reagent_state = LIQUID
	color = "#302000"

	nutrition = 1.0
	adj_temp = 5
	hydration_value = 0.5

/datum/reagent/drink/hell_ramen
	name = "Hell Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."

	taste_description = "wet and cheap noodles on fire"

	reagent_state = LIQUID
	color = "#302000"

	nutrition = 1.0
	hydration_value = 0.5

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
	color = "#302000"

	nutrition = 4.0
	hydration_value = -2.5

/datum/reagent/drink/chicken_soup
	name = "Chicken Soup"
	description = "No chickens were harmed in the making of this soup."

	taste_description = "somewhat tasteless chicken broth"
	reagent_state = LIQUID

	color = "#c9b042"
	nutrition = 0.75
	adj_temp = 5
	hydration_value = 0.8

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
	taste_mult = 2.5

	reagent_state = SOLID
	color = "#619494"

	adj_temp = -5
	hydration_value = 1.0

	glass_name = "ice"
	glass_desc = "Generally, you're supposed to put something else in there too..."
	glass_icon = DRINK_ICON_NOISY

	decompile_results = list(
		/datum/reagent/water = 1.0
		)

/datum/reagent/drink/nothing
	name = "Nothing"
	description = "Absolutely nothing."

	taste_description = "nothing"

	glass_name = "nothing"
	glass_desc = "Absolutely nothing."
