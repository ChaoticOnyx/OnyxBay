/datum/reagent/caffeine
	name = "Caffeine"
	description = "Central nervous system stimulant."
	taste_mult = 0
	reagent_state = SOLID
	color = "#ffffff"

	glass_icon = DRINK_ICON_NOISY

	var/nutrition = 0 // Per unit
	var/adj_dizzy = 0 // Per tick
	var/adj_drowsy = 0
	var/adj_sleepy = 0
	var/adj_temp = 0
	var/adj_speed = 0

/datum/reagent/caffeine/affect_ingest(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return

	. = ..()

	M.add_nutrition(nutrition * removed)
	M.dizziness = max(0, M.dizziness + adj_dizzy)
	M.drowsyness = max(0, M.drowsyness + adj_drowsy)
	M.sleeping = max(0, M.sleeping + adj_sleepy)
	if(adj_temp > 0 && M.bodytemperature < 310) // 310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(adj_temp < 0 && M.bodytemperature > 310)
		M.bodytemperature = min(310, M.bodytemperature - (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(adj_speed)
		M.add_up_to_chemical_effect(adj_speed < 0 ? CE_SLOWDOWN : CE_SPEEDBOOST, adj_speed)

	if(alien == IS_TAJARA)
		M.adjustToxLoss(0.5 * removed)
		M.make_jittery(4)

	if(adj_temp > 0)
		holder.remove_reagent(/datum/reagent/frostoil, 10 * removed)

	if(volume > 15)
		M.add_chemical_effect(CE_PULSE, 1)

/datum/reagent/caffeine/affect_blood(mob/living/carbon/M, alien, removed)
	. = ..()
	if(alien == IS_TAJARA)
		M.adjustToxLoss(2 * removed)
		M.make_jittery(4)
		return

	M.add_chemical_effect(CE_PULSE, 2)
	M.adjustToxLoss(removed) // Probably not a good idea; not very deadly though

/datum/reagent/caffeine/overdose(mob/living/carbon/M, alien)
	if(alien == IS_DIONA)
		return

	if(alien == IS_TAJARA)
		M.adjustToxLoss(4 * REM)
		M.apply_effect(3, STUTTER)

	M.make_jittery(5)
	M.add_chemical_effect(CE_PULSE, 2)
	M.add_up_to_chemical_effect(CE_SPEEDBOOST, 1)

/datum/reagent/caffeine/coffee
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

/datum/reagent/caffeine/coffee/cafe_latte
	name = "Cafe Latte"
	description = "A nice, strong and tasty beverage while you are reading."
	taste_description = "bitter cream"
	color = "#c65905"
	adj_temp = 5

	glass_required = "coffeecup"
	glass_icon_state = "coffeelatte"
	glass_name = "cafe latte"
	glass_desc = "A nice, strong and refreshing beverage while you are reading."

/datum/reagent/caffeine/coffee/cafe_latte/affect_ingest(mob/living/carbon/M, alien, removed)
	. = ..()
	M.heal_organ_damage(0.5 * removed, 0)

/datum/reagent/caffeine/coffee/icecoffee
	name = "Iced Coffee"
	description = "Coffee and ice, refreshing and cool."
	taste_description = "bitter coldness"
	color = "#888179"
	adj_temp = -5

	glass_required = "square"
	glass_icon_state = "coffeelatte"
	glass_name = "iced coffee"
	glass_desc = "A drink to perk you up and refresh you!"
	glass_special = list(DRINK_ICE)

/datum/reagent/caffeine/coffee/soy_latte
	name = "Soy Latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	taste_description = "creamy coffee"
	color = "#c65905"
	adj_temp = 5

	glass_required = "coffeecup"
	glass_icon_state = "soylatte"
	glass_name = "soy latte"
	glass_desc = "A nice and refrshing beverage while you are reading."

/datum/reagent/caffeine/coffee/soy_latte/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.heal_organ_damage(0.5 * removed, 0)

/datum/reagent/caffeine/coffee/cappuccino
	name = "Cappuccino"
	description = "A nice, light coffee beverage made of espresso and steamed milk."
	taste_description = "creamy coffee"
	color = "#c65905"
	adj_temp = 5

	glass_required = "coffeecup"
	glass_icon_state = "cappuccino"
	glass_name = "cappuccino"
	glass_desc = "A nice, light coffee beverage made of espresso and steamed milk."

/datum/reagent/caffeine/coffee/cappuccino/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.heal_organ_damage(0.5 * removed, 0)
