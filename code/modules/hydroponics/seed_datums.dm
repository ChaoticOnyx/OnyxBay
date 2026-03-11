// Chili plants/variants.
/datum/seed/chili
	name = "chili"
	seed_name = "chili"
	display_name = "chili plants"
	chems = list(
		/datum/reagent/capsaicin = list(0, 0.5),
		/datum/reagent/nutriment = list(20, 1.0)
		)
	mutants = list("icechili","flamechili")
	kitchen_tag = "chili"
	canonical_icon = "chili"

/datum/seed/chili/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 5)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 20)
	set_trait(TRAIT_PRODUCT_ICON, "chili")
	set_trait(TRAIT_PRODUCT_COLOUR, "#ed3300")
	set_trait(TRAIT_PLANT_ICON, "bush2")
	set_trait(TRAIT_IDEAL_HEAT, 298)
	set_trait(TRAIT_IDEAL_LIGHT, 7)

/datum/seed/chili/ice
	name = "icechili"
	seed_name = "ice pepper"
	display_name = "ice-pepper plants"
	mutants = null
	chems = list(
		/datum/reagent/frostoil = list(0, 0.5),
		/datum/reagent/nutriment = list(20, 1.0)
		)
	kitchen_tag = "icechili"
	canonical_icon = "chiliice"

/datum/seed/chili/ice/New()
	..()
	set_trait(TRAIT_MATURATION, 4)
	set_trait(TRAIT_PRODUCTION, 4)
	set_trait(TRAIT_PRODUCT_COLOUR,"#00edc6")

/datum/seed/chili/flame
	name = "flamechili"
	seed_name = "flame chili"
	display_name = "flame chili plants"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(5, 0.5),
		/datum/reagent/fuel = list(0, 2.5)
		)
	kitchen_tag = "flamechili"
	fun_level = 1
	canonical_icon = null

/datum/seed/chili/flame/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#743300")
	set_trait(TRAIT_JUICY, 1)

// Berry plants/variants.
/datum/seed/berry
	name = "berries"
	seed_name = "berry"
	display_name = "berry bush"
	mutants = list("glowberries","poisonberries","blueberries")
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/drink/juice/berry = list(5, 5.0)
		)
	kitchen_tag = "berries"
	canonical_icon = "berry"

/datum/seed/berry/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_JUICY, 1)
	set_trait(TRAIT_MATURATION, 5)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 2)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "berry")
	set_trait(TRAIT_PRODUCT_COLOUR, "#fa1616")
	set_trait(TRAIT_PLANT_ICON, "bush")
	set_trait(TRAIT_WATER_CONSUMPTION, 6)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/berry/blue
	name = "blueberries"
	seed_name = "blueberry"
	display_name = "blueberry bush"
	mutants = list("berries","poisonberries","glowberries")
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/drink/juice/berry = list(5, 5.0)
		)
	kitchen_tag = "blueberries"
	canonical_icon = null

/datum/seed/berry/blue/New()
	..()
	set_trait(TRAIT_MATURATION, 5)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 2)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_COLOUR, "#1c225c")
	set_trait(TRAIT_WATER_CONSUMPTION, 5)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.2)

/datum/seed/berry/glow
	name = "glowberries"
	seed_name = "glowberry"
	display_name = "glowberry bush"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/uranium = list(10, 2.5)
		)
	canonical_icon = "glowberry"

/datum/seed/berry/glow/New()
	..()
	set_trait(TRAIT_SPREAD, 1)
	set_trait(TRAIT_BIOLUM, 1)
	set_trait(TRAIT_BIOLUM_COLOUR, "#006622")
	set_trait(TRAIT_MATURATION, 5)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 2)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_COLOUR, "#c9fa16")
	set_trait(TRAIT_WATER_CONSUMPTION, 3)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.25)

/datum/seed/berry/poison
	name = "poisonberries"
	seed_name = "poison berry"
	display_name = "poison berry bush"
	mutants = list("deathberries")
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/toxin/poisonberryjuice = list(5, 5.0)
		)
	canonical_icon = "poisonberry"

/datum/seed/berry/poison/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#6dc961")
	set_trait(TRAIT_WATER_CONSUMPTION, 3)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.25)

/datum/seed/berry/poison/death
	name = "deathberries"
	seed_name = "death berry"
	display_name = "death berry bush"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/toxin/poisonberryjuice = list(5, 5.0),
		/datum/reagent/lexorin = list(0, 0.25)
		)
	canonical_icon = "deathberry"

/datum/seed/berry/poison/death/New()
	..()
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_POTENCY, 50)
	set_trait(TRAIT_PRODUCT_COLOUR, "#7a5454")
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.35)

// Nettles/variants.
/datum/seed/nettle
	name = "nettle"
	seed_name = "nettle"
	display_name = "nettles"
	mutants = list("deathnettle")
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/acid = list(0, 1.0)
		)
	kitchen_tag = "nettle"
	canonical_icon = "nettle"

/datum/seed/nettle/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_STINGS, 1)
	set_trait(TRAIT_PLANT_ICON, "bush5")
	set_trait(TRAIT_PRODUCT_ICON, "nettles")
	set_trait(TRAIT_PRODUCT_COLOUR, "#728a54")

/datum/seed/nettle/death
	name = "deathnettle"
	seed_name = "death nettle"
	display_name = "death nettles"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/acid/polyacid = list(0, 1.0)
		)
	kitchen_tag = "deathnettle"
	canonical_icon = "deathnettle"

/datum/seed/nettle/death/New()
	..()
	set_trait(TRAIT_MATURATION,8)
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_PRODUCT_COLOUR,"#8c5030")
	set_trait(TRAIT_PLANT_COLOUR,"#634941")

//Tomatoes/variants.
/datum/seed/tomato
	name = "tomato"
	seed_name = "tomato"
	display_name = "tomato plant"
	mutants = list("bluetomato", "bloodtomato", "tomacco")
	chems = list(
		/datum/reagent/nutriment = list(15, 1.5),
		/datum/reagent/drink/juice/tomato = list(35, 3.5)
		)
	kitchen_tag = "tomato"
	canonical_icon = "tomato"

/datum/seed/tomato/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_JUICY, 1)
	set_trait(TRAIT_MATURATION, 8)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 2)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "tomato")
	set_trait(TRAIT_PRODUCT_COLOUR, "#FF0000")
	set_trait(TRAIT_PLANT_ICON, "bush3")
	set_trait(TRAIT_IDEAL_LIGHT, 6)
	set_trait(TRAIT_WATER_CONSUMPTION, 6)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.25)

/datum/seed/tomato/blood
	name = "bloodtomato"
	seed_name = "blood tomato"
	display_name = "blood tomato plant"
	mutants = list("killertomato","nanotomato")
	chems = list(
		/datum/reagent/nutriment = list(15, 1.5),
		/datum/reagent/blood = list(35, 5.0)
		)
	splat_type = /obj/effect/decal/cleanable/blood/splatter
	canonical_icon = "bloodtomato"

/datum/seed/tomato/blood/New()
	..()
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_PRODUCT_COLOUR, "#CB0000")

/datum/seed/tomato/blood/nano
	name = "nanotomato"
	seed_name = "nanoblood tomato"
	display_name = "nanoblood tomato plant"
	mutants = list("automato")
	chems = list(
		/datum/reagent/nutriment = list(15, 1.5),
		/datum/reagent/nanoblood = list(35, 3.5)
		)
	canonical_icon = null

/datum/seed/tomato/blood/nano/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR, "#CB0089")

/datum/seed/tomato/automato
	name = "automato"
	seed_name = "automato"
	display_name = "automato plant"
	mutants = null
	chems = list(
		/datum/reagent/nanites = list(1, 0.25)
		)
	splat_type = /obj/effect/decal/cleanable/blood/oil
	fun_level = 1
	canonical_icon = null

/datum/seed/tomato/automato/New()
	..()
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_PRODUCT_COLOUR, "#A0A1BA")
	set_trait(TRAIT_PRODUCT_ICON, "automato")
	set_trait(TRAIT_PLANT_COLOUR, "#606060")

/datum/seed/tomato/killer
	name = "killertomato"
	seed_name = "killer tomato"
	display_name = "killer tomato plant"
	mutants = null
	can_self_harvest = 1
	has_mob_product = /mob/living/simple_animal/hostile/tomato
	fun_level = 1
	canonical_icon = "killertomato"

/datum/seed/tomato/killer/New()
	..()
	set_trait(TRAIT_YIELD, 2)
	set_trait(TRAIT_PRODUCT_COLOUR, "#a86747")

/datum/seed/tomato/tomacco
	name = "tomacco"
	seed_name = "tomacco"
	display_name = "tomacco plant"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(15, 1.5),
		/datum/reagent/nicotine = list(1, 0.25)
		)

/datum/seed/tomato/blue
	name = "bluetomato"
	seed_name = "blue tomato"
	display_name = "blue tomato plant"
	mutants = list("bluespacetomato")
	chems = list(
		/datum/reagent/nutriment = list(15, 1.5),
		/datum/reagent/ethanol/singulo = list(5, 2.5)
		)
	canonical_icon = "bluetomato"

/datum/seed/tomato/blue/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#4d86e8")
	set_trait(TRAIT_PLANT_COLOUR,"#070aad")

/datum/seed/tomato/blue/teleport
	name = "bluespacetomato"
	seed_name = "bluespace tomato"
	display_name = "bluespace tomato plant"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(15, 1.5),
		/datum/reagent/ethanol/singulo = list(35, 3.5)
		)
	fun_level = 1
	canonical_icon = "bluespacetomato"

/datum/seed/tomato/blue/teleport/New()
	..()
	set_trait(TRAIT_TELEPORTING,1)
	set_trait(TRAIT_PRODUCT_COLOUR,"#00e5ff")
	set_trait(TRAIT_BIOLUM,1)
	set_trait(TRAIT_BIOLUM_COLOUR,"#4da4a8")

//Eggplants/varieties.
/datum/seed/eggplant
	name = "eggplant"
	seed_name = "eggplant"
	display_name = "eggplants"
	mutants = list("realeggplant")
	chems = list(
		/datum/reagent/nutriment = list(75, 5.0)
		)
	kitchen_tag = "eggplant"
	canonical_icon = "eggplant"

/datum/seed/eggplant/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 2)
	set_trait(TRAIT_POTENCY, 20)
	set_trait(TRAIT_PRODUCT_ICON, "eggplant")
	set_trait(TRAIT_PRODUCT_COLOUR, "#892694")
	set_trait(TRAIT_PLANT_ICON, "bush4")
	set_trait(TRAIT_IDEAL_HEAT, 298)
	set_trait(TRAIT_IDEAL_LIGHT, 7)

/datum/seed/eggplant/realeggplant
	name = "realeggplant"
	seed_name = "egg plant"
	display_name = "egg plants"
	mutants = null
	has_custom_product = /obj/item/reagent_containers/food/egg/randomcolor
	fun_level = 1
	canonical_icon = "eggy"

/datum/seed/eggplant/realeggplant/New()
	..()
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_PRODUCT_COLOUR, "#F7C8AD")

//Apples/varieties.
/datum/seed/apple
	name = "apple"
	seed_name = "red apple"
	display_name = "apple tree"
	mutants = list("poisonapple","greenapple","yellowapple")
	chems = list(
		/datum/reagent/nutriment = list(35, 3.5),
		/datum/reagent/drink/juice/apple = list(35, 3.5)
		)
	kitchen_tag = "apple"
	canonical_icon = "apple"

/datum/seed/apple/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 5)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "apple")
	set_trait(TRAIT_PRODUCT_COLOUR, "#FF3C0A")
	set_trait(TRAIT_PLANT_ICON, "tree2")
	set_trait(TRAIT_FLESH_COLOUR, "#e8e39b")
	set_trait(TRAIT_IDEAL_LIGHT, 4)

/datum/seed/apple/green
	name = "greenapple"
	seed_name = "green apple"
	mutants = list("rapple","apple","yellowapple")
	canonical_icon = null

/datum/seed/apple/green/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#67B248")

/datum/seed/apple/yellow
	name = "yellowapple"
	seed_name = "yellow apple"
	mutants = list("goldapple","apple","greenapple")
	canonical_icon = null

/datum/seed/apple/yellow/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#EAD759")

/datum/seed/apple/poison
	name = "poisonapple"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(35, 3.5),
		/datum/reagent/drink/juice/apple = list(30, 3.0),
		/datum/reagent/toxin/cyanide = list(5, 0.5)
		)

/datum/seed/apple/rapple
	name = "rapple"
	seed_name = "radioactive apple"
	display_name = "radioactive apple tree"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(30, 3.0),
		/datum/reagent/drink/juice/apple = list(30, 3.0),
		/datum/reagent/radium = list(10, 1.0)
		)
	fun_level = 1
	canonical_icon = null

/datum/seed/apple/rapple/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#72FF4F")

/datum/seed/apple/gold
	name = "goldapple"
	seed_name = "golden apple"
	display_name = "gold apple tree"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(25, 2.5),
		/datum/reagent/drink/juice/apple = list(30, 3.0),
		/datum/reagent/gold = list(15, 1.5)
		)
	kitchen_tag = "goldapple"
	fun_level = 1
	canonical_icon = null

/datum/seed/apple/gold/New()
	..()
	set_trait(TRAIT_MATURATION, 10)
	set_trait(TRAIT_PRODUCTION, 10)
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_PRODUCT_COLOUR, "#ffdd00")
	set_trait(TRAIT_PLANT_COLOUR, "#d6b44d")

//Ambrosia/varieties.
/datum/seed/ambrosia
	name = "ambrosia"
	seed_name = "ambrosia vulgaris"
	display_name = "ambrosia vulgaris"
	mutants = list("ambrosiadeus")
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/space_drugs = list(1.0, 1.0),
		/datum/reagent/kelotane = list(2.0, 2.0),
		/datum/reagent/bicaridine = list(2.0, 2.0),
		/datum/reagent/toxin = list(1.0, 0.25)
		)
	kitchen_tag = "ambrosia"
	canonical_icon = "ambrosiavulgaris"

/datum/seed/ambrosia/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 6)
	set_trait(TRAIT_POTENCY, 5)
	set_trait(TRAIT_PRODUCT_ICON, "ambrosia")
	set_trait(TRAIT_PRODUCT_COLOUR, "#9fad55")
	set_trait(TRAIT_PLANT_ICON, "ambrosia")
	set_trait(TRAIT_IDEAL_LIGHT, 6)

/datum/seed/ambrosia/deus
	name = "ambrosiadeus"
	seed_name = "ambrosia deus"
	display_name = "ambrosia deus"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/bicaridine = list(2.0, 2.0),
		/datum/reagent/synaptizine = list(1.0, 0.25),
		/datum/reagent/hyperzine = list(1.0, 1.0),
		/datum/reagent/space_drugs = list(1.0, 1.5)
		)
	kitchen_tag = "ambrosiadeus"
	canonical_icon = "ambrosiadeus"

/datum/seed/ambrosia/deus/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#a3f0ad")
	set_trait(TRAIT_PLANT_COLOUR,"#2a9c61")

//Mushrooms/varieties.
/datum/seed/mushroom
	name = "mushrooms"
	seed_name = "chanterelle"
	seed_noun = SEED_NOUN_SPORES
	display_name = "chanterelle mushrooms"
	mutants = list("reishi","amanita","plumphelmet")
	chems = list(
		/datum/reagent/nutriment/protein/fungal = list(25, 10.0)
		)
	splat_type = /obj/effect/vine
	kitchen_tag = "mushroom"
	canonical_icon = "chanter"

/datum/seed/mushroom/New()
	..()
	set_trait(TRAIT_MATURATION, 7)
	set_trait(TRAIT_PRODUCTION, 1)
	set_trait(TRAIT_YIELD, 5)
	set_trait(TRAIT_POTENCY, 1)
	set_trait(TRAIT_PRODUCT_ICON, "mushroom4")
	set_trait(TRAIT_PRODUCT_COLOUR, "#dbda72")
	set_trait(TRAIT_PLANT_COLOUR, "#d9c94e")
	set_trait(TRAIT_PLANT_ICON, "mushroom")
	set_trait(TRAIT_WATER_CONSUMPTION, 6)
	set_trait(TRAIT_IDEAL_HEAT, 288)
	set_trait(TRAIT_LIGHT_TOLERANCE, 6)

/datum/seed/mushroom/mold
	name = "mold"
	seed_name = "brown mold"
	display_name = "brown mold"
	mutants = null
	canonical_icon = null

/datum/seed/mushroom/mold/New()
	..()
	set_trait(TRAIT_SPREAD, 1)
	set_trait(TRAIT_MATURATION, 10)
	set_trait(TRAIT_YIELD, -1)
	set_trait(TRAIT_PRODUCT_ICON, "mushroom5")
	set_trait(TRAIT_PRODUCT_COLOUR, "#7a5f20")
	set_trait(TRAIT_PLANT_COLOUR, "#7a5f20")
	set_trait(TRAIT_PLANT_ICON, "mushroom9")

/datum/seed/mushroom/plump
	name = "plumphelmet"
	seed_name = "plump helmet"
	display_name = "plump helmet mushrooms"
	mutants = list("walkingmushroom","towercap")
	chems = list(
		/datum/reagent/nutriment/protein/fungal = list(35, 12.5)
		)
	kitchen_tag = "plumphelmet"
	canonical_icon = "plump"

/datum/seed/mushroom/plump/New()
	..()
	set_trait(TRAIT_MATURATION, 8)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 0)
	set_trait(TRAIT_PRODUCT_ICON, "mushroom10")
	set_trait(TRAIT_PRODUCT_COLOUR, "#b57bb0")
	set_trait(TRAIT_PLANT_COLOUR, "#9e4f9d")
	set_trait(TRAIT_PLANT_ICON, "mushroom2")

/datum/seed/mushroom/plump/walking
	name = "walkingmushroom"
	seed_name = "walking mushroom"
	display_name = "walking mushrooms"
	mutants = null
	can_self_harvest = 1
	has_mob_product = /mob/living/simple_animal/mushroom
	fun_level = 1
	canonical_icon = "walkingmushroom"

/datum/seed/mushroom/plump/walking/New()
	..()
	set_trait(TRAIT_MATURATION, 5)
	set_trait(TRAIT_YIELD, 1)
	set_trait(TRAIT_PRODUCT_COLOUR, "#fac0f2")
	set_trait(TRAIT_PLANT_COLOUR, "#c4b1c2")

/datum/seed/mushroom/hallucinogenic
	name = "reishi"
	seed_name = "reishi"
	display_name = "reishi"
	mutants = list("libertycap","glowshroom")
	chems = list(
		/datum/reagent/nutriment/protein/fungal = list(25, 10.0),
		/datum/reagent/psilocybin = list(0, 0.5)
		)
	canonical_icon = null

/datum/seed/mushroom/hallucinogenic/New()
	..()
	set_trait(TRAIT_MATURATION, 10)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 15)
	set_trait(TRAIT_PRODUCT_ICON, "mushroom11")
	set_trait(TRAIT_PRODUCT_COLOUR, "#ffb70f")
	set_trait(TRAIT_PLANT_COLOUR, "#f58a18")
	set_trait(TRAIT_PLANT_ICON, "mushroom6")

/datum/seed/mushroom/hallucinogenic/strong
	name = "libertycap"
	seed_name = "liberty cap"
	display_name = "liberty cap mushrooms"
	mutants = null
	chems = list(
		/datum/reagent/nutriment/protein/fungal = list(25, 10.0),
		/datum/reagent/psilocybin = list(0, 0.75),
		/datum/reagent/space_drugs = list(0, 0.5)
		)
	canonical_icon = "liberty"

/datum/seed/mushroom/hallucinogenic/strong/New()
	..()
	set_trait(TRAIT_PRODUCTION, 1)
	set_trait(TRAIT_POTENCY, 15)
	set_trait(TRAIT_PRODUCT_ICON, "mushroom8")
	set_trait(TRAIT_PRODUCT_COLOUR, "#f2e550")
	set_trait(TRAIT_PLANT_COLOUR, "#d1ca82")
	set_trait(TRAIT_PLANT_ICON, "mushroom3")

/datum/seed/mushroom/poison
	name = "amanita"
	seed_name = "fly amanita"
	display_name = "fly amanita mushrooms"
	mutants = list("destroyingangel","plastic")
	chems = list(
		/datum/reagent/nutriment/protein/fungal = list(25, 10.0),
		/datum/reagent/psilocybin = list(0, 0.75),
		/datum/reagent/toxin/amatoxin = list(0, 0.5)
		)
	kitchen_tag = "amanita"
	canonical_icon = "amanita"

/datum/seed/mushroom/poison/New()
	..()
	set_trait(TRAIT_MATURATION, 10)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "mushroom")
	set_trait(TRAIT_PRODUCT_COLOUR, "#ff4545")
	set_trait(TRAIT_PLANT_COLOUR, "#e0ddba")
	set_trait(TRAIT_PLANT_ICON, "mushroom4")

/datum/seed/mushroom/poison/death
	name = "destroyingangel"
	seed_name = "destroying angel"
	display_name = "destroying angel mushrooms"
	mutants = null
	chems = list(
		/datum/reagent/nutriment/protein/fungal = list(25, 7.5),
		/datum/reagent/psilocybin = list(0, 0.5),
		/datum/reagent/toxin/amatoxin = list(2.5, 0.75)
		)
	kitchen_tag = ""
	canonical_icon = "angel"

/datum/seed/mushroom/poison/death/New()
	..()
	set_trait(TRAIT_MATURATION, 12)
	set_trait(TRAIT_YIELD, 2)
	set_trait(TRAIT_POTENCY, 35)
	set_trait(TRAIT_PRODUCT_ICON, "mushroom3")
	set_trait(TRAIT_PRODUCT_COLOUR, "#ede8ea")
	set_trait(TRAIT_PLANT_COLOUR, "#e6d8dd")
	set_trait(TRAIT_PLANT_ICON, "mushroom5")

/datum/seed/mushroom/towercap
	name = "towercap"
	seed_name = "tower cap"
	display_name = "tower caps"
	chems = list(
		/datum/reagent/woodpulp = list(200, 10.0)
		)
	mutants = null
	canonical_icon = "towercap"

/datum/seed/mushroom/towercap/New()
	..()
	set_trait(TRAIT_MATURATION, 15)
	set_trait(TRAIT_PRODUCT_ICON, "mushroom7")
	set_trait(TRAIT_PRODUCT_COLOUR, "#79a36d")
	set_trait(TRAIT_PLANT_COLOUR, "#857f41")
	set_trait(TRAIT_PLANT_ICON, "mushroom8")

/datum/seed/mushroom/glowshroom
	name = "glowshroom"
	seed_name = "glowshroom"
	display_name = "glowshrooms"
	mutants = null
	chems = list(
		/datum/reagent/nutriment/protein/fungal = list(15, 0.5),
		/datum/reagent/radium = list(0.5, 0.25)
		)
	canonical_icon = "glowshroom"

/datum/seed/mushroom/glowshroom/New()
	..()
	set_trait(TRAIT_SPREAD, 1)
	set_trait(TRAIT_MATURATION, 15)
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_POTENCY, 30)
	set_trait(TRAIT_BIOLUM, 1)
	set_trait(TRAIT_BIOLUM_COLOUR, "#006622")
	set_trait(TRAIT_PRODUCT_ICON, "mushroom2")
	set_trait(TRAIT_PRODUCT_COLOUR, "#ddfab6")
	set_trait(TRAIT_PLANT_COLOUR, "#efff8a")
	set_trait(TRAIT_PLANT_ICON, "mushroom7")

/datum/seed/mushroom/plastic
	name = "plastic"
	seed_name = "plastellium"
	display_name = "plastellium"
	mutants = null
	chems = list(
		/datum/reagent/nutriment/protein/fungal = list(5, 0.25),
		/datum/reagent/toxin/plasticide = list(50, 10)
		)
	canonical_icon = null

/datum/seed/mushroom/plastic/New()
	..()
	set_trait(TRAIT_MATURATION, 5)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 6)
	set_trait(TRAIT_POTENCY, 20)
	set_trait(TRAIT_PRODUCT_ICON, "mushroom6")
	set_trait(TRAIT_PRODUCT_COLOUR, "#e6e6e6")
	set_trait(TRAIT_PLANT_COLOUR, "#e6e6e6")
	set_trait(TRAIT_PLANT_ICON, "mushroom10")

//Flowers/varieties
/datum/seed/flower
	name = "harebells"
	seed_name = "harebell"
	display_name = "harebells"
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0)
		)
	canonical_icon = "harebell"

/datum/seed/flower/New()
	..()
	set_trait(TRAIT_MATURATION, 7)
	set_trait(TRAIT_PRODUCTION, 1)
	set_trait(TRAIT_YIELD, 2)
	set_trait(TRAIT_PRODUCT_ICON, "flower5")
	set_trait(TRAIT_PRODUCT_COLOUR, "#c492d6")
	set_trait(TRAIT_PLANT_COLOUR, "#6b8c5e")
	set_trait(TRAIT_PLANT_ICON, "flower")
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/flower/poppy
	name = "poppies"
	seed_name = "poppy"
	display_name = "poppies"
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0)
		)
	kitchen_tag = "poppy"
	mutants = list("opiumpoppies")
	canonical_icon = "poppy"

/datum/seed/flower/poppy/New()
	..()
	set_trait(TRAIT_POTENCY, 20)
	set_trait(TRAIT_MATURATION, 8)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 6)
	set_trait(TRAIT_PRODUCT_ICON, "flower3")
	set_trait(TRAIT_PRODUCT_COLOUR, "#b33715")
	set_trait(TRAIT_PLANT_ICON, "flower3")
	set_trait(TRAIT_IDEAL_LIGHT, 6)
	set_trait(TRAIT_WATER_CONSUMPTION, 0.5)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/flower/poppy/opium
	name = "opiumpoppies"
	seed_name = "somniferum poppy"
	display_name = "somniferum poppies"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/painkiller/opium = list(0, 0.5)
		)
	canonical_icon = null

/datum/seed/flower/poppy/opium/New()
	..()
	set_trait(TRAIT_POTENCY, 20)
	set_trait(TRAIT_MATURATION, 8)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 6)
	set_trait(TRAIT_PRODUCT_ICON, "bulbflower")
	set_trait(TRAIT_PRODUCT_COLOUR, "#7d9b55")
	set_trait(TRAIT_PLANT_ICON, "bulbflower")
	set_trait(TRAIT_IDEAL_LIGHT, 6)
	set_trait(TRAIT_WATER_CONSUMPTION, 0.5)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/flower/sunflower
	name = "sunflowers"
	seed_name = "sunflower"
	display_name = "sunflowers"
	mutants = list("moonflowers")
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/nutriment/oil = list(50, 2.5)
		)
	canonical_icon = "sunflower"

/datum/seed/flower/sunflower/New()
	..()
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCT_ICON, "flower2")
	set_trait(TRAIT_PRODUCT_COLOUR, "#fff700")
	set_trait(TRAIT_PLANT_ICON, "flower2")
	set_trait(TRAIT_IDEAL_LIGHT, 7)
	set_trait(TRAIT_WATER_CONSUMPTION, 6)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/flower/sunflower/moon
	name = "moonflowers"
	seed_name = "moonflower"
	display_name = "moonflowers"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/ethanol/moonshine = list(50, 2.5)
		)
	canonical_icon = null

/datum/seed/flower/sunflower/moon/New()
	..()
	set_trait(TRAIT_PRODUCT_ICON,"flowermoon")
	set_trait(TRAIT_PRODUCT_COLOUR,"#FFFB9B")

/datum/seed/flower/lavender
	name = "lavender"
	seed_name = "lavender"
	display_name = "lavender"
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/bicaridine = list(0, 0.5)
		)
	canonical_icon = null

/datum/seed/flower/lavender/New()
	..()
	set_trait(TRAIT_MATURATION, 7)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 5)
	set_trait(TRAIT_PRODUCT_ICON, "flower6")
	set_trait(TRAIT_PRODUCT_COLOUR, "#b57edc")
	set_trait(TRAIT_PLANT_COLOUR, "#6b8c5e")
	set_trait(TRAIT_PLANT_ICON, "flower4")
	set_trait(TRAIT_IDEAL_LIGHT, 7)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.05)
	set_trait(TRAIT_WATER_CONSUMPTION, 0.5)

//Grapes/varieties
/datum/seed/grapes
	name = "grapes"
	seed_name = "grape"
	display_name = "grapevines"
	mutants = list("greengrapes")
	chems = list(
		/datum/reagent/nutriment = list(35, 3.5),
		/datum/reagent/drink/juice/grape = list(35, 3.5)
		)
	canonical_icon = "grape"

/datum/seed/grapes/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 3)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "grapes")
	set_trait(TRAIT_PRODUCT_COLOUR, "#bb6ac4")
	set_trait(TRAIT_PLANT_COLOUR, "#378f2e")
	set_trait(TRAIT_PLANT_ICON, "vine")
	set_trait(TRAIT_IDEAL_LIGHT, 6)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/grapes/green
	name = "greengrapes"
	seed_name = "green grape"
	display_name = "green grapevines"
	mutants = null
	chems = list(
		/datum/reagent/nutriment = list(35, 3.5),
		/datum/reagent/drink/juice/grape = list(35, 3.5),
		/datum/reagent/kelotane = list(0, 0.5)
		)
	canonical_icon = "greengrape"

/datum/seed/grapes/green/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR, "#42ed2f")

//Everything else
/datum/seed/peanuts
	name = "peanut"
	seed_name = "peanut"
	display_name = "peanut vines"
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/nutriment/oil = list(10, 1.0)
		)
	canonical_icon = null

/datum/seed/peanuts/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 6)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "nuts")
	set_trait(TRAIT_PRODUCT_COLOUR, "#c4ae7a")
	set_trait(TRAIT_PLANT_ICON, "bush2")
	set_trait(TRAIT_IDEAL_LIGHT, 6)

/datum/seed/peppercorn
	name = "peppercorn"
	seed_name = "peppercorn"
	display_name = "black pepper"
	chems = list(
		/datum/reagent/blackpepper = list(5, 0.5)
		)
	canonical_icon = null

/datum/seed/peppercorn/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 4)
	set_trait(TRAIT_PRODUCTION, 4)
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_POTENCY, 5)
	set_trait(TRAIT_PRODUCT_ICON, "nuts")
	set_trait(TRAIT_PRODUCT_COLOUR, "#4d4d4d")
	set_trait(TRAIT_PLANT_ICON, "vine2")
	set_trait(TRAIT_IDEAL_LIGHT, 6)

/datum/seed/cabbage
	name = "cabbage"
	seed_name = "cabbage"
	display_name = "cabbages"
	chems = list(
		/datum/reagent/nutriment = list(75, 5.0)
		)
	kitchen_tag = "cabbage"
	canonical_icon = "cabbage"

/datum/seed/cabbage/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 3)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "cabbage")
	set_trait(TRAIT_PRODUCT_COLOUR, "#84bd82")
	set_trait(TRAIT_PLANT_COLOUR, "#6d9c6b")
	set_trait(TRAIT_PLANT_ICON, "vine2")
	set_trait(TRAIT_IDEAL_LIGHT, 6)
	set_trait(TRAIT_WATER_CONSUMPTION, 6)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/banana
	name = "banana"
	seed_name = "banana"
	display_name = "banana tree"
	chems = list(
		/datum/reagent/nutriment = list(35, 3.5),
		/datum/reagent/drink/juice/banana = list(35, 3.5)
		)
	trash_type = /obj/item/bananapeel
	kitchen_tag = "banana"
	mutants = list("lubanana","bunana")
	canonical_icon = "banana"

/datum/seed/banana/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_PRODUCT_ICON, "bananas")
	set_trait(TRAIT_PRODUCT_COLOUR, "#FFEC58")
	set_trait(TRAIT_PLANT_COLOUR, "#69ad50")
	set_trait(TRAIT_PLANT_ICON, "tree4")
	set_trait(TRAIT_IDEAL_HEAT, 298)
	set_trait(TRAIT_IDEAL_LIGHT, 7)
	set_trait(TRAIT_WATER_CONSUMPTION, 6)

/datum/seed/banana/bunana
	name = "bunana"
	seed_name = "bunana"
	display_name = "bunana tree"
	chems = list(
		/datum/reagent/nutriment = list(35, 3.5),
		/datum/reagent/drink/juice/banana = list(50, 5.0)
		)
	mutants = null
	fun_level = 1

/datum/seed/banana/bunana/New()
	..()
	set_trait(TRAIT_PRODUCT_ICON,"bunanas")
	set_trait(TRAIT_WATER_CONSUMPTION, 9)

/datum/seed/banana/lubanana
	name = "lubanana"
	seed_name = "lubanana"
	display_name = "lubanana tree"
	chems = list(
		/datum/reagent/nutriment = list(35, 3.5),
		/datum/reagent/drink/juice/banana = list(35, 3.5),
		/datum/reagent/lube = list(15, 1.5)
		)
	trash_type = /obj/item/bananapeel/lubanana
	mutants = list("banbanana")
	fun_level = 1
	canonical_icon = null

/datum/seed/banana/lubanana/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR, "#BEECD1")
	set_trait(TRAIT_JUICY, 2)
	set_trait(TRAIT_WATER_CONSUMPTION, 9)

/datum/seed/banana/banbanana
	name = "banbanana"
	seed_name = "BANana"
	display_name = "BANana tree"
	mutants = null
	has_custom_product = /obj/item/toy/banbanana
	fun_level = 2

/datum/seed/banana/banbanana/New()
	..()
	set_trait(TRAIT_YIELD, 1)

/datum/seed/corn
	name = "corn"
	seed_name = "corn"
	display_name = "ears of corn"
	chems = list(
		/datum/reagent/nutriment/oil/corn = list(15, 1.5),
		/datum/reagent/nutriment = list(35, 3.5)
		)
	kitchen_tag = "corn"
	trash_type = /obj/item/corncob
	canonical_icon = "corn"

/datum/seed/corn/New()
	..()
	set_trait(TRAIT_MATURATION, 8)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_POTENCY, 20)
	set_trait(TRAIT_PRODUCT_ICON, "corn")
	set_trait(TRAIT_PRODUCT_COLOUR, "#fff23b")
	set_trait(TRAIT_PLANT_COLOUR, "#87c969")
	set_trait(TRAIT_PLANT_ICON, "corn")
	set_trait(TRAIT_IDEAL_HEAT, 298)
	set_trait(TRAIT_IDEAL_LIGHT, 6)
	set_trait(TRAIT_WATER_CONSUMPTION, 6)

/datum/seed/potato
	name = "potato"
	seed_name = "potato"
	display_name = "potatoes"
	chems = list(
		/datum/reagent/nutriment = list(30, 3.0),
		/datum/reagent/drink/juice/potato = list(25, 2.5)
		)
	kitchen_tag = "potato"
	mutants = list("potatocell")
	canonical_icon = "potato"

/datum/seed/potato/New()
	..()
	set_trait(TRAIT_PRODUCES_POWER, 1)
	set_trait(TRAIT_MATURATION, 10)
	set_trait(TRAIT_PRODUCTION, 1)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "potato")
	set_trait(TRAIT_PRODUCT_COLOUR, "#BFA876")
	set_trait(TRAIT_PLANT_ICON, "bush2")
	set_trait(TRAIT_WATER_CONSUMPTION, 6)

/datum/seed/potato/cell
	name = "potatocell"
	seed_name = "electric potato"
	display_name = "electric potatoes"
	mutants = null
	has_custom_product = /obj/item/cell/potato
	fun_level = 1

/datum/seed/potato/cell/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR, "#BCB596")

/datum/seed/garlic
	name = "garlic"
	seed_name = "garlic"
	display_name = "garlic"
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/drink/juice/garlic = list(10, 1.0)
		)
	kitchen_tag = "garlic"
	canonical_icon = null

/datum/seed/garlic/New()
	..()
	set_trait(TRAIT_MATURATION, 10)
	set_trait(TRAIT_PRODUCTION, 1)
	set_trait(TRAIT_YIELD, 5)
	set_trait(TRAIT_POTENCY, 12)
	set_trait(TRAIT_PRODUCT_ICON, "garlic")
	set_trait(TRAIT_PRODUCT_COLOUR, "#fff8dd")
	set_trait(TRAIT_PLANT_ICON, "stalk")
	set_trait(TRAIT_WATER_CONSUMPTION, 7)

/datum/seed/onion
	name = "onion"
	seed_name = "onion"
	display_name = "onions"
	chems = list(
		/datum/reagent/nutriment = list(30, 3.0),
		/datum/reagent/drink/juice/onion = list(20, 2.0)
		)
	kitchen_tag = "onion"
	canonical_icon = null

/datum/seed/onion/New()
	..()
	set_trait(TRAIT_MATURATION, 10)
	set_trait(TRAIT_PRODUCTION, 1)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "onion")
	set_trait(TRAIT_PRODUCT_COLOUR, "#FFC080")
	set_trait(TRAIT_PLANT_ICON, "stalk")
	set_trait(TRAIT_WATER_CONSUMPTION, 5)

/datum/seed/soybean
	name = "soybean"
	seed_name = "soybean"
	display_name = "soybeans"
	chems = list(
		/datum/reagent/nutriment = list(25, 2.5),
		/datum/reagent/drink/milk/soymilk = list(30, 3.0)
		)
	kitchen_tag = "soybeans"
	canonical_icon = "soybean"

/datum/seed/soybean/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,4)
	set_trait(TRAIT_PRODUCTION,4)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_POTENCY,5)
	set_trait(TRAIT_PRODUCT_ICON,"bean")
	set_trait(TRAIT_PRODUCT_COLOUR,"#ebe7c0")
	set_trait(TRAIT_PLANT_ICON,"stalk")

/datum/seed/wheat
	name = "wheat"
	seed_name = "wheat"
	display_name = "wheat stalks"
	chems = list(
		/datum/reagent/nutriment = list(5, 0.5),
		/datum/reagent/nutriment/flour = list(35, 3.5)
		)
	kitchen_tag = "wheat"
	canonical_icon = "wheat"

/datum/seed/wheat/New()
	..()
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 1)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 5)
	set_trait(TRAIT_PRODUCT_ICON, "wheat")
	set_trait(TRAIT_PRODUCT_COLOUR, "#dbd37d")
	set_trait(TRAIT_PLANT_COLOUR, "#bfaf82")
	set_trait(TRAIT_PLANT_ICON, "stalk2")
	set_trait(TRAIT_IDEAL_LIGHT, 6)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/rice
	name = "rice"
	seed_name = "rice"
	display_name = "rice stalks"
	chems = list(
		/datum/reagent/nutriment = list(5, 0.5),
		/datum/reagent/nutriment/rice = list(35, 3.5)
		)
	kitchen_tag = "rice"
	canonical_icon = null

/datum/seed/rice/New()
	..()
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 1)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 5)
	set_trait(TRAIT_PRODUCT_ICON, "rice")
	set_trait(TRAIT_PRODUCT_COLOUR, "#d5e6d1")
	set_trait(TRAIT_PLANT_COLOUR, "#8ed17d")
	set_trait(TRAIT_PLANT_ICON, "stalk2")
	set_trait(TRAIT_WATER_CONSUMPTION, 6)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/carrots
	name = "carrot"
	seed_name = "carrot"
	display_name = "carrots"
	chems = list(
		/datum/reagent/nutriment = list(35, 3.5),
		/datum/reagent/drink/juice/carrot = list(35, 3.5),
		/datum/reagent/imidazoline = list(0, 0.5)
		)
	kitchen_tag = "carrot"
	canonical_icon = "carrot"

/datum/seed/carrots/New()
	..()
	set_trait(TRAIT_MATURATION, 10)
	set_trait(TRAIT_PRODUCTION, 1)
	set_trait(TRAIT_YIELD, 5)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "carrot")
	set_trait(TRAIT_PRODUCT_COLOUR, "#FF8C4A")
	set_trait(TRAIT_FLESH_COLOUR, "#20C11F")
	set_trait(TRAIT_PLANT_ICON, "carrot")
	set_trait(TRAIT_WATER_CONSUMPTION, 6)

/datum/seed/weeds
	name = "weeds"
	seed_name = "weed"
	display_name = "weeds"
	canonical_icon = "weeds"

/datum/seed/weeds/New()
	..()
	set_trait(TRAIT_MATURATION, 5)
	set_trait(TRAIT_PRODUCTION, 1)
	set_trait(TRAIT_YIELD, -1)
	set_trait(TRAIT_POTENCY, -1)
	set_trait(TRAIT_IMMUTABLE, -1)
	set_trait(TRAIT_PRODUCT_ICON, "flower4")
	set_trait(TRAIT_PRODUCT_COLOUR, "#fceb2b")
	set_trait(TRAIT_PLANT_COLOUR, "#59945a")
	set_trait(TRAIT_PLANT_ICON, "bush6")

/datum/seed/whitebeets
	name = "whitebeet"
	seed_name = "white-beet"
	display_name = "white-beets"
	chems = list(
		/datum/reagent/nutriment = list(45, 4.5),
		/datum/reagent/sugar = list(5, 0.5)
		)
	kitchen_tag = "whitebeet"
	canonical_icon = "whitebeet"

/datum/seed/whitebeets/New()
	..()
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 6)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "carrot2")
	set_trait(TRAIT_PRODUCT_COLOUR, "#eef5b0")
	set_trait(TRAIT_PLANT_COLOUR, "#4d8f53")
	set_trait(TRAIT_PLANT_ICON, "carrot2")
	set_trait(TRAIT_WATER_CONSUMPTION, 6)

/datum/seed/sugarcane
	name = "sugarcane"
	seed_name = "sugarcane"
	display_name = "sugarcanes"
	chems = list(
		/datum/reagent/nutriment = list(25, 2.5),
		/datum/reagent/sugar = list(10, 1.0)
		)
	canonical_icon = "sugarcane"

/datum/seed/sugarcane/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 3)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "stalk")
	set_trait(TRAIT_PRODUCT_COLOUR, "#b4d6bd")
	set_trait(TRAIT_PLANT_COLOUR, "#6bbd68")
	set_trait(TRAIT_PLANT_ICON, "stalk3")
	set_trait(TRAIT_IDEAL_HEAT, 298)

/datum/seed/watermelon
	name = "watermelon"
	seed_name = "watermelon"
	display_name = "watermelon vine"
	chems = list(
		/datum/reagent/nutriment = list(15, 1.5),
		/datum/reagent/drink/juice/watermelon = list(75, 7.5)
		)
	kitchen_tag = "watermelon"
	canonical_icon = "watermelon"

/datum/seed/watermelon/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_JUICY, 1)
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "vine")
	set_trait(TRAIT_PRODUCT_COLOUR, "#326b30")
	set_trait(TRAIT_PLANT_COLOUR, "#257522")
	set_trait(TRAIT_PLANT_ICON, "vine2")
	set_trait(TRAIT_FLESH_COLOUR, "#f22c2c")
	set_trait(TRAIT_IDEAL_HEAT, 298)
	set_trait(TRAIT_IDEAL_LIGHT, 6)
	set_trait(TRAIT_WATER_CONSUMPTION, 6)

/datum/seed/pumpkin
	name = "pumpkin"
	seed_name = "pumpkin"
	display_name = "pumpkin vine"
	chems = list(
		/datum/reagent/nutriment = list(75, 7.5)
		)
	kitchen_tag = "pumpkin"
	canonical_icon = "pumpkin"

/datum/seed/pumpkin/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "vine2")
	set_trait(TRAIT_PRODUCT_COLOUR, "#F98C28")
	set_trait(TRAIT_PLANT_COLOUR, "#bae8c1")
	set_trait(TRAIT_PLANT_ICON, "vine2")
	set_trait(TRAIT_FLESH_COLOUR, "#74741F")
	set_trait(TRAIT_WATER_CONSUMPTION, 6)

/datum/seed/citrus
	name = "lime"
	seed_name = "lime"
	display_name = "lime trees"
	chems = list(
		/datum/reagent/nutriment = list(15, 1.5),
		/datum/reagent/drink/juice/lime = list(30, 3.0)
		)
	kitchen_tag = "lime"
	canonical_icon = "lime"

/datum/seed/citrus/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_JUICY, 1)
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 15)
	set_trait(TRAIT_PRODUCT_ICON, "lemon")
	set_trait(TRAIT_PRODUCT_COLOUR, "#3af026")
	set_trait(TRAIT_PLANT_ICON, "tree")
	set_trait(TRAIT_FLESH_COLOUR, "#3af026")

/datum/seed/citrus/lemon
	name = "lemon"
	seed_name = "lemon"
	display_name = "lemon trees"
	chems = list(
		/datum/reagent/nutriment = list(15, 1.5),
		/datum/reagent/drink/juice/lemon = list(35, 3.5)
		)
	kitchen_tag = "lemon"
	canonical_icon = "lemon"

/datum/seed/citrus/lemon/New()
	..()
	set_trait(TRAIT_PRODUCES_POWER, 1)
	set_trait(TRAIT_PRODUCT_COLOUR, "#f0e226")
	set_trait(TRAIT_FLESH_COLOUR, "#f0e226")
	set_trait(TRAIT_IDEAL_LIGHT, 6)

/datum/seed/citrus/orange
	name = "orange"
	seed_name = "orange"
	display_name = "orange trees"
	kitchen_tag = "orange"
	chems = list(
		/datum/reagent/nutriment = list(25, 2.5),
		/datum/reagent/drink/juice/orange = list(35, 3.5)
		)
	canonical_icon = "orange"

/datum/seed/citrus/orange/New()
	..()
	set_trait(TRAIT_PRODUCT_ICON,"orange")
	set_trait(TRAIT_PRODUCT_COLOUR,"#FF8000")
	set_trait(TRAIT_FLESH_COLOUR,"#ffc20a")

/datum/seed/grass
	name = "grass"
	seed_name = "grass"
	display_name = "grass"
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0)
		)
	kitchen_tag = "grass"
	canonical_icon = "grass"

/datum/seed/grass/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 2)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 5)
	set_trait(TRAIT_PRODUCT_ICON, "grass")
	set_trait(TRAIT_PRODUCT_COLOUR, "#09ff00")
	set_trait(TRAIT_PLANT_COLOUR, "#07d900")
	set_trait(TRAIT_PLANT_ICON, "grass")
	set_trait(TRAIT_WATER_CONSUMPTION, 0.5)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/cocoa
	name = "cocoa"
	seed_name = "cacao"
	display_name = "cacao tree"
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/nutriment/coco = list(25, 2.5)
		)
	canonical_icon = "cocoapod"

/datum/seed/cocoa/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 5)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 2)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "treefruit")
	set_trait(TRAIT_PRODUCT_COLOUR, "#BC6912")
	set_trait(TRAIT_PLANT_ICON, "tree2")
	set_trait(TRAIT_IDEAL_HEAT, 298)
	set_trait(TRAIT_WATER_CONSUMPTION, 6)

/datum/seed/coconut
	name = "coconut"
	seed_name = "coconut"
	display_name = "coconut palm"
	chems = list(
		/datum/reagent/nutriment = list(15, 1.5),
		/datum/reagent/drink/juice/coconut = list(75, 7.5)
		)
	mutants = list("cowcownut")
	canonical_icon = null

/datum/seed/coconut/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "coconut")
	set_trait(TRAIT_PRODUCT_COLOUR, "#724C1D")
	set_trait(TRAIT_PLANT_COLOUR, "#69ad50")
	set_trait(TRAIT_PLANT_ICON, "tree4")
	set_trait(TRAIT_IDEAL_HEAT, 298)
	set_trait(TRAIT_IDEAL_LIGHT, 7)
	set_trait(TRAIT_WATER_CONSUMPTION, 7)

/datum/seed/coconut/cowcownut
	name = "cowcownut"
	seed_name = "cowcownut"
	display_name = "cowcownut palm"
	has_mob_product = /mob/living/simple_animal/cow/cowcownut
	chems = null
	mutants = null
	fun_level = 1
	canonical_icon = null

/datum/seed/coconut/cowcownut/New()
	..()
	set_trait(TRAIT_YIELD, 1)
	set_trait(TRAIT_PRODUCT_ICON, "cowcownut")
	set_trait(TRAIT_MATURATION, 9)

/datum/seed/cherries
	name = "cherry"
	seed_name = "cherry"
	seed_noun = SEED_NOUN_PITS
	display_name = "cherry tree"
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/nutriment/cherryjelly = list(5, 5.0)
		)
	kitchen_tag = "cherries"
	canonical_icon = null

/datum/seed/cherries/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_JUICY, 1)
	set_trait(TRAIT_MATURATION, 5)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "cherry")
	set_trait(TRAIT_PRODUCT_COLOUR, "#a80000")
	set_trait(TRAIT_PLANT_ICON, "tree2")
	set_trait(TRAIT_PLANT_COLOUR, "#2f7d2d")

/datum/seed/kudzu
	name = "kudzu"
	seed_name = "kudzu"
	display_name = "kudzu vines"
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/dylovene = list(2.5, 1.5)
		)

/datum/seed/kudzu/New()
	..()
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_SPREAD, 2)
	set_trait(TRAIT_PRODUCT_ICON, "treefruit")
	set_trait(TRAIT_PRODUCT_COLOUR, "#96d278")
	set_trait(TRAIT_PLANT_COLOUR, "#6f7a63")
	set_trait(TRAIT_PLANT_ICON, "vine2")
	set_trait(TRAIT_WATER_CONSUMPTION, 0.5)

/datum/seed/diona
	name = "diona"
	seed_name = "diona"
	seed_noun = SEED_NOUN_NODES
	display_name = "replicant pods"
	can_self_harvest = 1
	has_mob_product = /mob/living/carbon/larva/diona
	mutants = list("maneater")
	canonical_icon = "replicapod"

/datum/seed/diona/New()
	..()
	set_trait(TRAIT_ENDURANCE, 15)
	set_trait(TRAIT_MATURATION, 5)
	set_trait(TRAIT_PRODUCTION, 10)
	set_trait(TRAIT_YIELD, 1)
	set_trait(TRAIT_POTENCY, 30)
	set_trait(TRAIT_PRODUCT_ICON, "diona")
	set_trait(TRAIT_PRODUCT_COLOUR, "#799957")
	set_trait(TRAIT_PLANT_COLOUR, "#66804b")
	set_trait(TRAIT_PLANT_ICON, "alien4")

/datum/seed/diona/maneater
	name = "maneater"
	seed_name = "man-eating plant"
	display_name = "man-eating plant"
	has_mob_product = /mob/living/simple_animal/hostile/maneater
	mutants = null
	customsprite = 1
	fun_level = 1
	canonical_icon = "maneater"

/datum/seed/diona/maneater/New()
	..()
	set_trait(TRAIT_ENDURANCE, 50)
	set_trait(TRAIT_YIELD, 1)
	set_trait(TRAIT_PRODUCT_ICON, "maneater")
	set_trait(TRAIT_PLANT_COLOUR, "#8AA97B")
	set_trait(TRAIT_PLANT_ICON, "maneater")

/datum/seed/shand
	name = "shand"
	seed_name = "S'randar's hand"
	display_name = "S'randar's hand leaves"
	chems = list(
		/datum/reagent/nutriment = list(10, 1.0),
		/datum/reagent/bicaridine = list(2.5, 1.5)
		)
	kitchen_tag = "shand"
	canonical_icon = null

/datum/seed/shand/New()
	..()
	set_trait(TRAIT_MATURATION, 3)
	set_trait(TRAIT_PRODUCTION, 5)
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 10)
	set_trait(TRAIT_PRODUCT_ICON, "alien3")
	set_trait(TRAIT_PRODUCT_COLOUR, "#378c61")
	set_trait(TRAIT_PLANT_COLOUR, "#378c61")
	set_trait(TRAIT_PLANT_ICON, "tree5")
	set_trait(TRAIT_IDEAL_HEAT, 283)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/mtear
	name = "mtear"
	seed_name = "Messa's tear"
	display_name = "Messa's tear leaves"
	chems = list(
		/datum/reagent/nutriment = list(5, 0.5),
		/datum/reagent/nutriment/honey = list(5, 0.5),
		/datum/reagent/kelotane = list(2.5, 1.5)
		)
	kitchen_tag = "mtear"
	canonical_icon = null

/datum/seed/mtear/New()
	..()
	set_trait(TRAIT_MATURATION,3)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"alien4")
	set_trait(TRAIT_PRODUCT_COLOUR,"#4cc5c7")
	set_trait(TRAIT_PLANT_COLOUR,"#4cc789")
	set_trait(TRAIT_PLANT_ICON,"bush7")
	set_trait(TRAIT_IDEAL_HEAT, 283)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/tobacco
	name = "tobacco"
	seed_name = "tobacco"
	display_name = "tobacco leaves"
	mutants = list("finetobacco", "puretobacco")
	chems = list(
		/datum/reagent/tobacco = list(2.5, 0.1)
		)
	canonical_icon = null

/datum/seed/tobacco/New()
	..()
	set_trait(TRAIT_MATURATION, 6)
	set_trait(TRAIT_PRODUCTION, 6)
	set_trait(TRAIT_YIELD, 5)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON, "tobacco")
	set_trait(TRAIT_PRODUCT_COLOUR, "#749733")
	set_trait(TRAIT_PLANT_COLOUR, "#749733")
	set_trait(TRAIT_PLANT_ICON, "vine2")
	set_trait(TRAIT_IDEAL_HEAT, 299)
	set_trait(TRAIT_IDEAL_LIGHT, 7)
	set_trait(TRAIT_WATER_CONSUMPTION, 6)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.15)

/datum/seed/tobacco/finetobacco
	name = "finetobacco"
	seed_name = "fine tobacco"
	display_name = "fine tobacco leaves"
	chems = list(
		/datum/reagent/tobacco/fine = list(2.5, 0.1)
		)
	canonical_icon = null

/datum/seed/tobacco/finetobacco/New()
	..()
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_PRODUCT_COLOUR, "#33571b")
	set_trait(TRAIT_PLANT_COLOUR, "#33571b")
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.20)

/datum/seed/tobacco/puretobacco //provides the pure nicotine reagent
	name = "puretobacco"
	seed_name = "succulent tobacco"
	display_name = "succulent tobacco leaves"
	chems = list(
		/datum/reagent/nicotine = list(2.5, 0.1)
		)
	canonical_icon = null

/datum/seed/tobacco/puretobacco/New()
	..()
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_JUICY, 1)
	set_trait(TRAIT_PRODUCT_COLOUR, "#b7c61a")
	set_trait(TRAIT_PLANT_COLOUR, "#b7c61a")
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.30)

// Alien weeds.
/datum/seed/xenomorph
	name = "xenomorph"
	seed_name = "alien weed"
	display_name = "alien weeds"
	force_layer = OBJ_LAYER
	chems = list(
		/datum/reagent/toxin/plasma = list(2.5, 0.5)
		)
	canonical_icon = null

/datum/seed/xenomorph/New()
	..()
	set_trait(TRAIT_PLANT_ICON, "vine2")
	set_trait(TRAIT_IMMUTABLE, 1)
	set_trait(TRAIT_PRODUCT_COLOUR, "#3d1934")
	set_trait(TRAIT_FLESH_COLOUR, "#3d1934")
	set_trait(TRAIT_PLANT_COLOUR, "#3d1934")
	set_trait(TRAIT_PRODUCTION, 1)
	set_trait(TRAIT_YIELD, -1)
	set_trait(TRAIT_SPREAD, 2)
	set_trait(TRAIT_POTENCY, 50)

// Weed weeds
/datum/seed/cannabis
	name = "cannabis"
	seed_name = "cannabis"
	display_name = "cannabis buds"
	chems = list(
		/datum/reagent/thc = list(5.0, 0.5)
		)
	kitchen_tag = "cannabis"
	canonical_icon = null

/datum/seed/cannabis/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 4)
	set_trait(TRAIT_YIELD, 3)
	set_trait(TRAIT_POTENCY, 4)
	set_trait(TRAIT_PRODUCTION, 3)
	set_trait(TRAIT_IDEAL_LIGHT, 7)
	set_trait(TRAIT_PRODUCT_ICON, "cannabis")
	set_trait(TRAIT_PLANT_ICON, "cannabis")
	set_trait(TRAIT_PRODUCT_COLOUR, "#4c7f28")
	set_trait(TRAIT_PLANT_COLOUR, "#4c7f28")
	set_trait(TRAIT_WATER_CONSUMPTION, 10)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.25)

/datum/seed/coffeea
	name = "coffeea"
	seed_name = "coffeea"
	display_name = "coffee arabica bush"
	mutants = list("coffeea_robusta")
	chems = list(
		/datum/reagent/caffeine = list(2.5, 0.25)
		)
	kitchen_tag = "coffeebean"
	canonical_icon = "coffeea"
	has_custom_product = /obj/item/reagent_containers/food/grown/coffee

/datum/seed/coffeea/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT, 1)
	set_trait(TRAIT_MATURATION, 5)
	set_trait(TRAIT_YIELD, 5)
	set_trait(TRAIT_POTENCY, 3)
	set_trait(TRAIT_PRODUCTION, 3)
	set_trait(TRAIT_IDEAL_LIGHT, 6)
	set_trait(TRAIT_PRODUCT_ICON, "arabica_beans")
	set_trait(TRAIT_PLANT_ICON, "coffeea")
	set_trait(TRAIT_WATER_CONSUMPTION, 10)
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.3)

/datum/seed/coffeea/robusta
	name = "coffeea_robusta"
	display_name = "coffee robusta bush"
	seed_name = "coffeea-robusta"
	has_custom_product = /obj/item/reagent_containers/food/grown/coffee/robusta

/datum/seed/coffeea/robusta/New()
	..()
	set_trait(TRAIT_PRODUCT_ICON, "robusta_beans")
