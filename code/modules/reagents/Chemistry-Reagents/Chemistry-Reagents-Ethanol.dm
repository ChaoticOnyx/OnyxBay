/* Alcohol */


/datum/reagent/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	description = "A well-known alcohol with a variety of applications."
	taste_description = "pure alcohol"
	reagent_state = LIQUID
	color = "#404030"
	touch_met = 5
	var/nutriment_factor = 0
	var/strength = 10 // This is, essentially, units between stages - the lower, the stronger. Less fine tuning, more clarity.
	var/toxicity = 1

	var/druggy = 0
	var/adj_temp = 0
	var/targ_temp = 310
	var/halluci = 0

	glass_name = "ethanol"
	glass_desc = "A well-known alcohol with a variety of applications."

/datum/reagent/ethanol/touch_mob(mob/living/L, amount)
	if(istype(L))
		L.adjust_fire_stacks(amount / 15)

/datum/reagent/ethanol/affect_blood(mob/living/carbon/M, alien, removed)
	M.adjustToxLoss(removed * 2 * toxicity)
	return

/datum/reagent/ethanol/affect_ingest(mob/living/carbon/M, alien, removed)
	M.nutrition += nutriment_factor * removed
	var/strength_mod = 1
	if(alien == IS_SKRELL)
		strength_mod *= 5
	if(alien == IS_DIONA)
		strength_mod = 0

	M.add_chemical_effect(CE_ALCOHOL, 1)
	var/effective_dose = M.chem_doses[type] * strength_mod * (1 + volume/60) //drinking a LOT will make you go down faster

	if(effective_dose >= strength) // Early warning
		M.make_dizzy(6) // It is decreased at the speed of 3 per tick
	if(effective_dose >= strength * 2) // Slurring
		M.add_chemical_effect(CE_PAINKILLER, 150/strength)
		M.slurring = max(M.slurring, 30)
	if(effective_dose >= strength * 3) // Confusion - walking in random directions
		M.add_chemical_effect(CE_PAINKILLER, 150/strength)
		M.confused = max(M.confused, 20)
	if(effective_dose >= strength * 4) // Blurry vision
		M.add_chemical_effect(CE_PAINKILLER, 150/strength)
		M.eye_blurry = max(M.eye_blurry, 10)
	if(effective_dose >= strength * 5) // Drowsyness - periodically falling asleep
		M.add_chemical_effect(CE_PAINKILLER, 150/strength)
		M.drowsyness = max(M.drowsyness, 20)
	if(effective_dose >= strength * 6) // Toxic dose
		M.add_chemical_effect(CE_ALCOHOL_TOXIC, toxicity)
	if(effective_dose >= strength * 7) // Pass out
		M.Paralyse(20)
		M.Sleeping(30)

	if(druggy != 0)
		M.make_drugged(druggy)

	if(adj_temp > 0 && M.bodytemperature < targ_temp) // 310 is the normal bodytemp. 310.055
		M.bodytemperature = min(targ_temp, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(adj_temp < 0 && M.bodytemperature > targ_temp)
		M.bodytemperature = min(targ_temp, M.bodytemperature - (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))

	if(halluci)
		M.adjust_hallucination(halluci, halluci)

/datum/reagent/ethanol/touch_obj(obj/O)
	if(istype(O, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/paperaffected = O
		paperaffected.clearpaper()
		to_chat(usr, "The solution dissolves the ink on the paper.")
		return
	if(istype(O, /obj/item/weapon/book))
		if(volume < 5)
			return
		if(istype(O, /obj/item/weapon/book/tome))
			to_chat(usr, SPAN("notice", "The solution does nothing. Whatever this is, it isn't normal ink."))
			return
		var/obj/item/weapon/book/affectedbook = O
		affectedbook.dat = null
		to_chat(usr, SPAN("notice", "The solution dissolves the ink on the book."))
	return


/datum/reagent/ethanol/absinthe
	name = "Absinthe"
	description = "Watch out that the Green Fairy doesn't come for you!"
	taste_description = "death and licorice"
	taste_mult = 1.5
	color = "#33ee00"
	strength = 12

	glass_name = "absinthe"
	glass_desc = "Wormwood, anise, oh my."

/datum/reagent/ethanol/ale
	name = "Ale"
	description = "A dark alchoholic beverage made by malted barley and yeast."
	taste_description = "hearty barley ale"
	color = "#4c3100"
	strength = 50

	glass_name = "ale"
	glass_desc = "A freezing pint of delicious ale"

/datum/reagent/ethanol/beer
	name = "Beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	taste_description = "piss water"
	color = "#ffd300"
	strength = 50
	nutriment_factor = 1

	glass_name = "beer"
	glass_desc = "A freezing pint of beer"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/beer/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.jitteriness = max(M.jitteriness - 3, 0)

/datum/reagent/ethanol/beer/dark
	name = "Dark Beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	taste_description = "bittersweet roasted flavor"
	color = "#5b3500"
	strength = 50
	nutriment_factor = 1

	glass_name = "dark beer"
	glass_desc = "A freezing pint of dark beer"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/beer/dark/machpella
	name = "Machpella Dark Beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	taste_description = "fairly sweet malty flavor"
	color = "#5b3500"
	strength = 50
	nutriment_factor = 1

	glass_name = "dark beer"
	glass_desc = "A freezing pint of Machpella Dark Beer"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/bluecuracao
	name = "Blue Curacao"
	description = "Exotically blue, fruity drink, distilled from oranges."
	taste_description = "oranges"
	taste_mult = 1.1
	color = "#0000cd"
	strength = 15

	glass_name = "blue curacao"
	glass_desc = "Exotically blue, fruity drink, distilled from oranges."

/datum/reagent/ethanol/cider/apple
	name = "Apple Cider"
	description = "An alcoholic beverage made from apples."
	taste_description = "apple cider"
	color = "#e0e254"
	strength = 50

	glass_name = "apple cider"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/cognac
	name = "Cognac"
	description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	taste_description = "rich and smooth alcohol"
	taste_mult = 1.1
	color = "#ab3c05"
	strength = 15

	glass_name = "cognac"
	glass_desc = "Damn, you feel like some kind of French aristocrat just by holding this."

/datum/reagent/ethanol/deadrum
	name = "Deadrum"
	description = "Popular with the sailors. Not very popular with everyone else."
	taste_description = "salty sea water"
	color = "#ecb633"
	strength = 50

	glass_name = "rum"
	glass_desc = "Now you want to Pray for a pirate suit, don't you?"

/datum/reagent/ethanol/deadrum/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.dizziness +=5

/datum/reagent/ethanol/gin
	name = "Gin"
	description = "It's gin. In space. I say, good sir."
	taste_description = "an alcoholic christmas tree"
	color = "#0064c6"
	strength = 15

	glass_name = "gin"
	glass_desc = "A crystal clear glass of Griffeater gin."

//Base type for alchoholic drinks containing coffee
/datum/reagent/ethanol/coffee
	overdose = 45

/datum/reagent/ethanol/coffee/affect_ingest(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	..()
	M.dizziness = max(0, M.dizziness - 5)
	M.drowsyness = max(0, M.drowsyness - 3)
	M.sleeping = max(0, M.sleeping - 2)
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(alien == IS_TAJARA)
		M.adjustToxLoss(0.5 * removed)
		M.make_jittery(4) //extra sensitive to caffine

/datum/reagent/ethanol/coffee/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_TAJARA)
		M.adjustToxLoss(2 * removed)
		M.make_jittery(4)
		return
	..()

/datum/reagent/ethanol/coffee/overdose(mob/living/carbon/M, alien)
	if(alien == IS_DIONA)
		return
	if(alien == IS_TAJARA)
		M.adjustToxLoss(4 * REM)
		M.apply_effect(3, STUTTER)
	M.make_jittery(5)

/datum/reagent/ethanol/coffee/kahlua
	name = "Kahlua"
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	taste_description = "spiked latte"
	taste_mult = 1.1
	color = "#4c3100"
	strength = 15

	glass_name = "RR coffee liquor"
	glass_desc = "DAMN, THIS THING LOOKS ROBUST"

/datum/reagent/ethanol/melonliquor
	name = "Melon Liquor"
	description = "A relatively sweet and fruity 46 proof liquor."
	taste_description = "fruity alcohol"
	color = "#138808" // rgb: 19, 136, 8
	strength = 20

	glass_name = "melon liquor"
	glass_desc = "A relatively sweet and fruity 46 proof liquor."

/datum/reagent/ethanol/rum
	name = "Rum"
	description = "Yohoho and all that."
	taste_description = "spiked butterscotch"
	taste_mult = 1.1
	color = "#ecb633"
	strength = 15

	glass_name = "rum"
	glass_desc = "Now you want to Pray for a pirate suit, don't you?"

/datum/reagent/ethanol/sake
	name = "Sake"
	description = "Anime's favorite drink."
	taste_description = "dry alcohol"
	color = "#dddddd"
	strength = 25

	glass_name = "sake"
	glass_desc = "A glass of sake."

/datum/reagent/ethanol/tequilla
	name = "Tequila"
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
	taste_description = "paint stripper"
	color = "#ffff91"
	strength = 25

	glass_name = "Tequilla"
	glass_desc = "Now all that's missing is the weird colored shades!"

/datum/reagent/ethanol/thirteenloko
	name = "Thirteen Loko"
	description = "A potent mixture of caffeine and alcohol."
	taste_description = "jitters and death"
	color = "#102000"
	strength = 25
	nutriment_factor = 1

	glass_name = "Thirteen Loko"
	glass_desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass."

/datum/reagent/ethanol/thirteenloko/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.drowsyness = max(0, M.drowsyness - 7)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.make_jittery(5)
	M.add_chemical_effect(CE_PULSE, 2)
	M.add_up_to_chemical_effect(CE_SPEEDBOOST, 0.6)

/datum/reagent/ethanol/vermouth
	name = "Vermouth"
	description = "You suddenly feel a craving for a martini..."
	taste_description = "dry alcohol"
	taste_mult = 1.3
	color = "#91ff91" // rgb: 145, 255, 145
	strength = 15

	glass_name = "vermouth"
	glass_desc = "You wonder why you're even drinking this straight."

/datum/reagent/ethanol/vodka
	name = "Vodka"
	description = "Number one drink AND fueling choice for Terrans around the galaxy."
	taste_description = "grain alcohol"
	color = "#9bcdff" // rgb: 211, 233, 255
	strength = 15

	glass_name = "vodka"
	glass_desc = "The glass contain wodka. Xynta."

/datum/reagent/ethanol/vodka/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.apply_effect(- 0.5 * removed, IRRADIATE, blocked = 0)

/datum/reagent/ethanol/vodka/premium
	name = "Premium Vodka"
	description = "Premium distilled vodka imported directly from the Terran Colonial Confederation."
	taste_description = "clear kvass"
	color = "#9bcdff" // rgb: 224, 242, 255 - very light blue.
	strength = 10

/datum/reagent/ethanol/whiskey
	name = "Whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	taste_description = "molasses"
	color = "#6d3a00"
	strength = 25

	glass_name = "whiskey"
	glass_desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."

/datum/reagent/ethanol/whiskey/specialwhiskey // I have no idea what this is and where it comes from
	name = "Special Blend Whiskey"
	description = "Just when you thought regular whiskey was good... This silky, amber goodness has to come along and ruin everything."
	taste_description = "liquid fire"
	color = "#523600"
	strength = 25

	glass_name = "special blend whiskey"
	glass_desc = "Just when you thought regular whiskey was good... This silky, amber goodness has to come along and ruin everything."

/datum/reagent/ethanol/wine
	name = "Red Wine"
	description = "An premium alchoholic beverage made from distilled grape juice."
	taste_description = "bitter sweetness"
	color = "#7e4043" // rgb: 126, 64, 67
	strength = 15

	glass_name = "red wine"
	glass_desc = "A very classy looking drink."

/datum/reagent/ethanol/wine/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.radiation = max(M.radiation - 5 * removed, 0)

/datum/reagent/ethanol/wine/premium
	name = "White Wine"
	description = "An exceptionally expensive alchoholic beverage made from distilled white grapes."
	taste_description = "white velvet"
	color = "#ffddaa" // rgb: 255, 221, 170 - a light cream
	strength = 20

	glass_name = "white wine"
	glass_desc = "A very expensive looking drink."

/datum/reagent/ethanol/wine/white
	name = "White Wine"
	description = "Martian sauvignon blanc. For those who actually like wine."
	taste_description = "refreshing sourness"
	color = "#ffebb2"
	strength = 15

	glass_name = "white wine"
	glass_desc = "A very elite looking drink."

/datum/reagent/ethanol/wine/rose
	name = "Rose Wine"
	description = "Glamorous and fancy beyond all limits."
	taste_description = "sweet and sour pleasure"
	color = "#ffcbc9"
	strength = 12

	glass_name = "red wine"
	glass_desc = "A very glamorous looking drink."

/datum/reagent/ethanol/wine/sparkling
	name = "Sparkling Wine"
	description = "Much like regular wine, but with bubbles. This one is white."
	color = "#fff696"
	strength = 17

	glass_name = "sparkling wine"
	glass_desc = "A very festive looking drink."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/herbal
	name = "Herbal Liquor"
	description = "A complex blend of herbs, spices and roots mingle in this old Earth classic."
	taste_description = "a sweet summer garden"
	color = "#dfff00"
	strength = 13

	glass_name = "herbal liquor"
	glass_desc = "It's definitely green. Or is it yellow?"

// Cocktails
/datum/reagent/ethanol/acid_spit
	name = "Acid Spit"
	description = "A drink for the daring, can be deadly if incorrectly prepared!"
	taste_description = "stomach acid"
	reagent_state = LIQUID
	color = "#9FE77B"
	strength = 30

	glass_required = "pint"
	glass_name = "Acid Spit"
	glass_desc = "A drink from the company archives. Made from live aliens."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/alliescocktail
	name = "Allies Cocktail"
	description = "A drink made from your allies, not as sweet as when made from your enemies."
	taste_description = "bitter yet free"
	color = "#d8ac45"
	strength = 25

	glass_required = "cocktail"
	glass_icon_state = "allies"
	glass_name = "Allies cocktail"
	glass_desc = "A drink made from your allies."

/datum/reagent/ethanol/aloe
	name = "Aloe"
	description = "So very, very, very good."
	taste_description = "sweet 'n creamy"
	color = "#b7ea75"
	strength = 15

	glass_required = "wine"
	glass_icon_state = "alloe"
	glass_name = "Aloe"
	glass_desc = "Very, very, very good."

/datum/reagent/ethanol/amasec
	name = "Amasec"
	description = "Official drink of the Gun Club!"
	taste_description = "dark and metallic"
	reagent_state = LIQUID
	color = "#ff975d"
	strength = 25

	glass_required = "mug"
	glass_icon_state = "amasec"
	glass_name = "Amasec"
	glass_desc = "Always handy before COMBAT!!!"

/datum/reagent/ethanol/andalusia
	name = "Andalusia"
	description = "A nice, strangely named drink."
	taste_description = "lemons"
	color = "#f4ea4a"
	strength = 15

	glass_required = "cognac"
	glass_icon_state = "andalusia"
	glass_name = "Andalusia"
	glass_desc = "A nice, strange named drink."

/datum/reagent/ethanol/armstrong
	name = "Armstrong"
	description = "One of the Official Cocktails of the Expeditionary Corps, celebrating Neil Armstrong."
	taste_description = "limes and alcoholic beer"
	color = "#D3D879FD"
	strength = 15

	glass_required = "pint"
	glass_name = "Armstrong cocktail"
	glass_desc = "Beer, vodka and lime come together in this instant classic. Named for Neil Armstrong, who was the first man to set foot on Luna, in the 20th century."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/antifreeze
	name = "Anti-freeze"
	description = "Ultimate refreshment."
	taste_description = "Jack Frost's piss"
	color = "#56deea"
	strength = 12
	adj_temp = 20
	targ_temp = 330

	glass_required = "pint"
	glass_name = "Anti-freeze"
	glass_desc = "The ultimate refreshment."

/datum/reagent/ethanol/atomicbomb
	name = "Atomic Bomb"
	description = "Nuclear proliferation never tasted so good."
	taste_description = "da bomb"
	reagent_state = LIQUID
	color = "#666300"
	strength = 10
	druggy = 50

	glass_required = "carafe"
	glass_icon_state = "atomicbomb"
	glass_name = "Atomic Bomb"
	glass_desc = "We cannot take legal responsibility for your actions after imbibing."

/datum/reagent/ethanol/coffee/b52
	name = "B-52"
	description = "Coffee, Irish Cream, and cognac. You will get bombed."
	taste_description = "angry and irish"
	taste_mult = 1.3
	color = "#997650"
	strength = 12

	glass_required = "vodkaglass"
	glass_icon_state = "b52"
	glass_name = "B-52"
	glass_desc = "Kahlua, Irish cream, and congac. You will get bombed."

/datum/reagent/ethanol/bacardi
	name = "Bacardi"
	description = "A perfect mix of white rum, lime juice and grenadine."
	color = "#ff5e5e"
	strength = 15
	taste_description = "lime and grenadine"

	glass_required = "cocktail"
	glass_icon_state = "bacardi"
	glass_name = "Bacardi"
	glass_desc = "A perfect mix of white rum, lime juice and grenadine."

/datum/reagent/ethanol/bahama_mama
	name = "Bahama mama"
	description = "Tropical cocktail."
	taste_description = "lime and orange"
	color = "#ff7f3b"
	strength = 25

	glass_required = "hurricane"
	glass_icon_state = "bahamamama"
	glass_name = "Bahama Mama"
	glass_desc = "Tropical cocktail"

/datum/reagent/ethanol/bananahonk
	name = "Banana Mama"
	description = "A drink from Clown Heaven."
	taste_description = "a bad joke"
	nutriment_factor = 1
	color = "#ffff91"
	strength = 12

	glass_required = "pint"
	glass_icon_state = "bananahonk"
	glass_name = "Banana Honk"
	glass_desc = "A drink from Banana Heaven."

/datum/reagent/ethanol/bdaiquiri
	name = "Banana daiquiri"
	description = "The magic of frozen banana sweets."
	color = "#ffd791"
	strength = 15

	glass_required = "cocktail"
	glass_icon_state = "bananadaiquiri"
	glass_name = "Banana daiquiri"
	glass_desc = "The magic of frozen banana sweets."

/datum/reagent/ethanol/barefoot
	name = "Barefoot"
	description = "Barefoot and pregnant"
	taste_description = "creamy berries"
	color = "#ffcdea"
	strength = 30

	glass_required = "cocktail"
	glass_icon_state = "barefoot"
	glass_name = "Barefoot"
	glass_desc = "Barefoot and pregnant"

/datum/reagent/ethanol/beepsky_smash
	name = "Beepsky Smash"
	description = "Deny drinking this and prepare for THE LAW."
	taste_description = "JUSTICE"
	taste_mult = 2
	reagent_state = LIQUID
	color = "#404040"
	strength = 12

	glass_required = "rocks"
	glass_icon_state = "beepskysmash"
	glass_name = "Beepsky Smash"
	glass_desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."

/datum/reagent/ethanol/beepsky_smash/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.Stun(2)

/datum/reagent/ethanol/bilk
	name = "Bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	taste_description = "desperation and lactate"
	color = "#E3F2AED7"
	strength = 50
	nutriment_factor = 2

	glass_required = "square"
	glass_name = "bilk"
	glass_desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."

/datum/reagent/ethanol/black_russian
	name = "Black Russian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	taste_description = "bitterness"
	color = "#360000"
	strength = 15

	glass_required = "rocks"
	glass_icon_state = "blackrussian"
	glass_name = "Black Russian"
	glass_desc = "For the lactose-intolerant. Still as classy as a White Russian."

/datum/reagent/ethanol/bloody_mary
	name = "Bloody Mary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	taste_description = "tomatoes with a hint of lime"
	color = "#b40000"
	strength = 15

	glass_required = "pint"
	glass_icon_state = "bloodymary"
	glass_name = "Bloody Mary"
	glass_desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."

/datum/reagent/ethanol/booger
	name = "Booger"
	description = "Ewww..."
	taste_description = "sweet 'n creamy"
	color = "#8cff8c"
	strength = 30

	glass_required = "square"
	glass_icon_state = "booger"
	glass_name = "Booger"
	glass_desc = "Ewww..."

/datum/reagent/ethanol/coffee/brave_bull
	name = "Brave Bull"
	description = "It's just as effective as Dutch-Courage!"
	taste_description = "alcoholic bravery"
	taste_mult = 1.1
	color = "#4c3100"
	strength = 15

	glass_required = "cognac"
	glass_icon_state = "bravebull"
	glass_name = "Brave Bull"
	glass_desc = "Tequilla and coffee liquor, brought together in a mouthwatering mixture. Drink up."

/datum/reagent/ethanol/changelingsting
	name = "Changeling Sting"
	description = "You take a tiny sip and feel a burning sensation..."
	taste_description = "your brain coming out your nose"
	color = "#2e6671"
	strength = 10

	glass_required = "square"
	glass_icon_state = "changelingsting"
	glass_name = "Changeling Sting"
	glass_desc = "A stingy drink."

/datum/reagent/ethanol/martini
	name = "Classic Martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	taste_description = "dry class"
	color = "#0064c8"
	strength = 25

	glass_required = "cocktail"
	glass_icon_state = "classicmartini"
	glass_name = "classic martini"
	glass_desc = "Damn, the bartender even stirred it, not shook it."

/datum/reagent/ethanol/commodore64
	name = "Commodore 64"
	description = "So-called ''ladies' drink,'' this sweet, fruity, unliquorly concoction that comes loaded with things like cream and egg white and a considerable charge of well-disguised inhibition- (and therefore, the theory goes, undergarment-) remover. "
	color = "#924C3E"
	strength = 25
	taste_description = "fruity sweetness"

	glass_required = "rocks"
	glass_name = "Commodore 64"
	glass_desc = "Also known as Pink Lady, Maiden's Prayer, Poet's Dream, and Angel's Wing."

/datum/reagent/ethanol/chacha
	name = "Chacha"
	description = "favorite drink of mountain people."
	color = "#FCD18D"
	strength = 10
	taste_description = "one feels the taste of a distant mountainous country"

	glass_required = "shot"
	glass_name = "Chacha"
	glass_desc = "favorite drink of mountain people."

/datum/reagent/ethanol/corpserevive
	name = "Corpse Reviver"
	description = "The best hangover cure!"
	color = "#74E074"
	strength = 15

	glass_required = "rock"
	glass_name = "Corpse Reviver"
	glass_desc = "The best hangover cure!"
	glass_special = list(DRINK_FIZZ, DRINK_ICE)

/datum/reagent/ethanol/cuba_libre
	name = "Cuba Libre"
	description = "Rum, mixed with cola. Viva la revolucion."
	taste_description = "cola"
	color = "#3e1b00"
	strength = 30

	glass_required = "pint"
	glass_icon_state = "cubalibre"
	glass_name = "Cuba Libre"
	glass_desc = "A classic mix of rum and cola."

/datum/reagent/ethanol/daddysindahouse
	name = "Daddy's in da House"
	description = "Bang, bang, bang, bang!"
	color = "#049956"
	strength = 14
	taste_description = "a stab wound in your liver"

	glass_required = "wine"
	glass_icon_state = "daddysinthehouse"
	glass_name = "Daddy's in da House"
	glass_desc = "Bang, bang, bang, bang!"

/datum/reagent/ethanol/afternoon
	name = "Death in the afternoon"
	description = "Favorite drink for functionary!"
	color = "#d4ff66"
	strength = 100
	taste_description = "sweet and bitter, like Death itself."

	glass_required = "wine"
	glass_icon_state = "deathintheafternoon"
	glass_name = "Death in the afternoon"
	glass_desc = "Favorite drink for chapters!"

/datum/reagent/ethanol/demonsblood
	name = "Demons Blood"
	description = "AHHHH!!!!"
	taste_description = "sweet tasting iron"
	taste_mult = 1.5
	color = "#820000"
	strength = 15

	glass_required = "cognac"
	glass_icon_state = "demonsblood"
	glass_name = "Demons' Blood"
	glass_desc = "Just looking at this thing makes the hair at the back of your neck stand up."

/datum/reagent/ethanol/devilskiss
	name = "Devils Kiss"
	description = "Creepy time!"
	taste_description = "bitter iron"
	color = "#a68310"
	strength = 15

	glass_required = "cocktail"
	glass_icon_state = "devilskiss"
	glass_name = "Devil's Kiss"
	glass_desc = "Creepy time!"

/datum/reagent/drink/doctor_delight
	name = "The Doctor's Delight"
	description = "A gulp a day keeps the MediBot away. That's probably for the best."
	taste_description = "homely fruit"
	reagent_state = LIQUID
	color = "#ff8cff"
	nutrition = 1

	glass_required = "pint"
	glass_icon_state = "doctorsdelight"
	glass_name = "The Doctor's Delight"
	glass_desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."

/datum/reagent/drink/doctor_delight/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.adjustOxyLoss(-4 * removed)
	M.heal_organ_damage(2 * removed, 2 * removed)
	M.adjustToxLoss(-2 * removed)
	if(M.dizziness)
		M.dizziness = max(0, M.dizziness - 15)
	if(M.confused)
		M.confused = max(0, M.confused - 5)

/datum/reagent/ethanol/driestmartini
	name = "Driest Martini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	taste_description = "a beach"
	nutriment_factor = 1
	color = "#2e6671"
	strength = 12

	glass_required = "cocktail"
	glass_icon_state = "driestmartini"
	glass_name = "Driest Martini"
	glass_desc = "Only for the experienced. You think you see sand floating in the glass."

/datum/reagent/ethanol/erikasurprise
	name = "Erika Surprise"
	description = "The surprise is, it's green!"
	taste_description = "tartness and bananas"
	color = "#5CB242"
	strength = 15

	glass_required = "mug"
	glass_name = "Erika Surprise"
	glass_desc = "The surprise is, it's green!"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/coffee/espressomartini
	name = "Espresso Martini"
	description = "Perfect for breakfast, perfect for dinner."
	color = "#72481d"
	strength = 15
	taste_description = "sweet espresso"

	glass_required = "wine"
	glass_icon_state = "espressomartini"
	glass_name = "Espresso Martini"
	glass_desc = "Perfect for breakfast, perfect for dinner."

/datum/reagent/ethanol/fullbiotickick
	name = "Full Biotic Kick"
	description = "Fortunately, biotics aren't real. Are they?.."
	color = "#d6774f"
	strength = 15
	taste_description = "mass effect"

	glass_required = "mug"
	glass_icon_state = "fullbiotickick"
	glass_name = "Full Biotic Kick"
	glass_desc = "Fortunately, biotics aren't real. Are they?.."

/datum/reagent/ethanol/georgerrmartini
	name = "George R.R. Martini"
	description = "Makes you think about boobs and dragons."
	color = "#9f0000"
	strength = 15
	taste_description = "blood, tears and pure agony"

	glass_required = "hurricane"
	glass_icon_state = "georgerrmartini"
	glass_name = "George R.R. Martini"
	glass_desc = "Makes you think about boobs and dragons."

/datum/reagent/ethanol/georgerrmartini/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(prob(10))
		M.emote(pick("cry"))

/datum/reagent/ethanol/ginfizz
	name = "Gin Fizz"
	description = "Refreshingly lemony, deliciously dry."
	taste_description = "dry, tart lemons"
	color = "#ffffae"
	strength = 30

	glass_required = "square"
	glass_name = "gin fizz"
	glass_desc = "Refreshingly lemony, deliciously dry."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/gintonic
	name = "Gin and Tonic"
	description = "An all time classic, mild cocktail."
	taste_description = "mild and tart"
	color = "#0064c8"
	strength = 50

	glass_required = "square"
	glass_icon_state = "gintonic"
	glass_name = "gin and tonic"
	glass_desc = "A mild but still great cocktail. Drink up, like a true Englishman."

/datum/reagent/ethanol/glintwine
	name = "Glintwine"
	description = "Mulled wine is very popular and traditional in the United Kingdom at Christmas, and less commonly throughout winter."
	color = "#600202"
	strength = 10
	taste_mult = 1.5
	druggy = 5
	adj_temp = 10
	targ_temp = 360
	taste_description = "liquid new year"

	glass_required = "mug"
	glass_icon_state = "glintwine"
	glass_name = "Glintwine"
	glass_desc = "Mulled wine is very popular and traditional in the United Kingdom at Christmas, and less commonly throughout winter."

/datum/reagent/ethanol/goldschlager
	name = "Goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	taste_description = "burning cinnamon"
	taste_mult = 1.3
	color = "#EBEBEBD5"
	strength = 15

	glass_required = "cocktail"
	glass_name = "Goldschlager"
	glass_desc = "100 proof that teen girls will drink anything with gold in it."

/datum/reagent/ethanol/grog
	name = "Grog"
	description = "Watered-down rum, pirate approved!"
	taste_description = "a poor excuse for alcohol"
	reagent_state = LIQUID
	color = "#E3E45E"
	strength = 100

	glass_required = "mug"
	glass_name = "grog"
	glass_desc = "A fine and cepa drink for Space."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/hippies_delight
	name = "Hippies' Delight"
	description = "You just don't get it maaaan."
	taste_description = "giving peace a chance"
	reagent_state = LIQUID
	color = "#ff88ff"
	strength = 15
	druggy = 50

	glass_required = "pint"
	glass_icon_state = "hippiesdelight"
	glass_name = "Hippie's Delight"
	glass_desc = "A drink enjoyed by people during the 1960's."

/datum/reagent/ethanol/hooch
	name = "Hooch"
	description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
	taste_description = "pure resignation"
	color = "#706A58"
	strength = 25
	toxicity = 2

	glass_required = "square"
	glass_name = "Hooch"
	glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

/datum/reagent/ethanol/battuta
	name = "Ibn Batutta"
	description = "One of the Official Cocktails of the Expeditionary Corps, celebrating Muhammad Ibn Battuta."
	taste_description = "a Moroccan garden"
	color = "#DFA866FE"
	strength = 18

	glass_required = "cognac"
	glass_name = "Ibn Batutta cocktail"
	glass_desc = "A refreshing blend of herbal liquor, the juice of an orange and a hint of mint. Named for Muhammad Ibn Battuta, whose travels spanned from Mali eastward to China in the 14th century."

/datum/reagent/ethanol/iced_beer
	name = "Iced Beer"
	description = "A beer which is so cold the air around it freezes."
	taste_description = "refreshingly cold"
	color = "#E3E45E"
	strength = 50
	adj_temp = -20
	targ_temp = 270

	glass_required = "pint"
	glass_name = "iced beer"
	glass_desc = "A beer so frosty, the air around it freezes."
	glass_special = list(DRINK_ICE, DRINK_FIZZ)

/datum/reagent/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	description = "Mmm, tastes like chocolate cake..."
	taste_description = "delicious anger"
	color = "#2e6671"
	strength = 15

	glass_required = "pint"
	glass_icon_state = "irishcarbomb"
	glass_name = "Irish Car Bomb"
	glass_desc = "An irish car bomb."

/datum/reagent/ethanol/coffee/irishcoffee
	name = "Irish Coffee"
	description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
	taste_description = "giving up on the day"
	color = "#4c3100"
	strength = 15

	glass_required = "vodkaglass"
	glass_icon_state = "irishcoffee"
	glass_name = "Irish coffee"
	glass_desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."

/datum/reagent/ethanol/irish_cream
	name = "Irish Cream"
	description = "Whiskey-imbued cream, what else would you expect from the Irish."
	taste_description = "creamy alcohol"
	color = "#E3D0B3F3"
	strength = 25

	glass_required = "rocks"
	glass_name = "Irish cream"
	glass_desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
	glass_special = list(DRINK_ICE)

/datum/reagent/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	taste_description = "a mixture of cola and alcohol"
	color = "#895b1f"
	strength = 12

	glass_required = "pint"
	glass_icon_state = "longislandicedtea"
	glass_name = "Long Island iced tea"
	glass_desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."

/datum/reagent/ethanol/manhattan
	name = "Manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	taste_description = "mild dryness"
	color = "#c13600"
	strength = 15

	glass_required = "cocktail"
	glass_icon_state = "manhattan"
	glass_name = "Manhattan"
	glass_desc = "The Detective's undercover drink of choice. He never could stomach gin..."

/datum/reagent/ethanol/manhattan_proj
	name = "Manhattan Project"
	description = "A scientist's drink of choice, for pondering ways to blow stuff up."
	taste_description = "death, the destroyer of worlds"
	color = "#c15d00"
	strength = 10
	druggy = 30

	glass_required = "cocktail"
	glass_icon_state = "manhattanproject"
	glass_name = "Manhattan Project"
	glass_desc = "A scientist's drink of choice, for pondering ways to blow stuff up."

/datum/reagent/ethanol/manly_dorf
	name = "The Manly Dorf"
	description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
	taste_description = "hair on your chest and your chin"
	color = "#4c3100"
	strength = 25

	glass_required = "bigmug"
	glass_icon_state = "manlydorf"
	glass_name = "The Manly Dorf"
	glass_desc = "A manly concotion made from Ale and Beer. Intended for true men only."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/margarita
	name = "Margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	taste_description = "dry and salty"
	color = "#8cff8c"
	strength = 15

	glass_required = "cocktail"
	glass_icon_state = "margarita"
	glass_name = "margarita"
	glass_desc = "On the rocks with salt on the rim. Arriba~!"

/datum/reagent/ethanol/magellan
	name = "Magellan"
	description = "One of the Official Cocktails of the Expeditionary Corps, celebrating Ferdinand Magellan."
	taste_description = "an aristrocatic experience"
	color = "#B5A288E0"
	strength = 13

	glass_required = "rocks"
	glass_desc = "A tasty sweetened blend of wine and fine whiskey. Named for Ferdinand Magellan, who led the first expedition to circumnavigate Earth in the 15th century."
	glass_special = list(DRINK_ICE)

/datum/reagent/ethanol/mead
	name = "Mead"
	description = "A Viking's drink, though a cheap one."
	taste_description = "sweet, sweet alcohol"
	reagent_state = LIQUID
	color = "#E4C35E"
	strength = 30
	nutriment_factor = 1

	glass_required = "mug"
	glass_name = "mead"
	glass_desc = "A Viking's beverage, though a cheap one."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/metroidscore
	name = "Metroid's Core"
	description = "Old good metroids... Where did you go?"
	color = "#17523A"
	strength = 20
	taste_description = "sharp herbal taste and sourness"

	glass_required = "square"
	glass_name = "Metroid's Core"
	glass_desc = "Old good metroids... Where did you go?"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/mojito
	name = "Mojito"
	description = "A refreshing summer drink."
	color = "#76C98C"
	strength = 20
	taste_description = "mint and lime"

	glass_required = "square"
	glass_icon_state = "mojito"
	glass_name = "Mojito"
	glass_desc = "A refreshing summer drink."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/moonshine
	name = "Moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	taste_description = "bitterness"
	taste_mult = 2.5
	color = "#AEE5E4B3"
	strength = 12

	glass_required = "square"
	glass_name = "moonshine"
	glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

/datum/reagent/ethanol/neurotoxin
	name = "Neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	taste_description = "a numbing sensation"
	reagent_state = LIQUID
	color = "#2e2e61"
	strength = 10

	glass_required = "pint"
	glass_icon_state = "neurotoxin"
	glass_name = "Neurotoxin"
	glass_desc = "A drink that is guaranteed to knock you silly."
	glass_icon = DRINK_ICON_NOISY
	glass_special = list("neuroright")

/datum/reagent/ethanol/neurotoxin/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	M.Weaken(3)
	M.Stun(2)
	M.add_chemical_effect(CE_PULSE, -1)

/datum/reagent/ethanol/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	description = "Whoah, this stuff looks volatile!"
	taste_description = "your brains smashed out by a lemon wrapped around a gold brick"
	taste_mult = 5
	reagent_state = LIQUID
	color = "#7f00ff"
	strength = 10

	glass_required = "hurricane"
	glass_icon_state = "gargleblaster"
	glass_name = "Pan-Galactic Gargle Blaster"
	glass_desc = "Does... does this mean that Arthur and Ford are here? Oh joy."

/datum/reagent/ethanol/patron
	name = "Patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	taste_description = "metallic and expensive"
	color = "#D4D6B0FC"
	strength = 30

	glass_required = "cocktail"
	glass_name = "Patron"
	glass_desc = "Drinking patron in the bar, with all the subpar ladies."

/datum/reagent/ethanol/pwine
	name = "Poison Wine"
	description = "Is this even wine? Toxic! Hallucinogenic! Probably consumed in boatloads by your superiors!"
	taste_description = "purified alcoholic death"
	color = "#000000"
	strength = 10
	druggy = 50
	halluci = 10

	glass_name = "???"
	glass_desc = "A black ichor with an oily purple sheer on top. Are you sure you should drink this?"

/datum/reagent/ethanol/pwine/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(M.chem_doses[type] > 30)
		M.adjustToxLoss(2 * removed)
	if(M.chem_doses[type] > 60 && ishuman(M) && prob(5))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/heart/L = H.internal_organs_by_name[BP_HEART]
		if (L && istype(L))
			if(M.chem_doses[type] < 120)
				L.take_internal_damage(10 * removed, 0)
			else
				L.take_internal_damage(100, 0)

/datum/reagent/ethanol/red_mead
	name = "Red Mead"
	description = "The true Viking's drink! Even though it has a strange red color."
	taste_description = "sweet and salty alcohol"
	color = "#B24542"
	strength = 30

	glass_required = "mug"
	glass_name = "red mead"
	glass_desc = "A true Viking's beverage, though its color is strange."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/sbiten
	name = "Sbiten"
	description = "A spicy Mead! Might be a little hot for the little guys!"
	taste_description = "hot and spice"
	color = "#ffa371"
	strength = 15
	adj_temp = 50
	targ_temp = 360

	glass_required = "hurricane"
	glass_icon_state = "sbiten"
	glass_name = "Sbiten"
	glass_desc = "A spicy mix of Mead and Spice. Very hot."

/datum/reagent/ethanol/screwdrivercocktail
	name = "Screwdriver"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	taste_description = "oranges"
	color = "#DAB58EFA"
	strength = 15

	glass_required = "square"
	glass_name = "Screwdriver"
	glass_desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."

/datum/reagent/ethanol/ships_surgeon
	name = "Ship's Surgeon"
	description = "Rum and Dr. Gibb. Served ice cold, like the scalpel."
	taste_description = "black comedy"
	color = "#524d0f"
	strength = 15

	glass_required = "mug"
	glass_icon_state = "shipssurgeon"
	glass_name = "ship's surgeon"
	glass_desc = "Rum qualified for surgical practice by Dr. Gibb. Smooth and steady."

/datum/reagent/ethanol/siegbrau
	name = "Siegbrau"
	description = "A drink that even an Undead can enjoy."
	color = "#9f0000"
	strength = 35
	taste_description = "malty flavor and something extremely dear and familiar"

	glass_required = "hurricane"
	glass_icon_state = "sigbrau"
	glass_name = "Siegbrau"
	glass_desc = "A drink that even an Undead can enjoy."

/datum/reagent/ethanol/siegbrau/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.adjustOxyLoss(-4 * removed)
	M.heal_organ_damage(2 * removed, 2 * removed)
	M.adjustToxLoss(-2 * removed)
	if(M.dizziness)
		M.dizziness = max(0, M.dizziness - 15)
	if(M.confused)
		M.confused = max(0, M.confused - 5)

/datum/reagent/ethanol/shroombeer
	name = "shroom berr"
	description = "A brew made of toxic mushrooms. What can go wrong?"
	color = "#72487a"
	strength = 15
	taste_description = "BOILING RAGE WAAAAAAAAAGH"

	glass_required = "mug"
	glass_icon_state = "shroombeer"
	glass_name = "shroom berr"
	glass_desc = "tiem to go berzerk!!"

/datum/reagent/ethanol/shroombeer/affect_blood(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA || alien == IS_SKRELL)
		return

	var/threshold = 10

	M.make_drugged(30)

	if(M.chem_doses[type] < 1 * threshold)
		M.apply_effect(3, STUTTER)
		M.make_dizzy(5)
		M.add_chemical_effect(CE_PAINKILLER, 50)
		M.add_up_to_chemical_effect(CE_SPEEDBOOST, 0.5)
		M.add_chemical_effect(CE_PULSE, 2)
		if(prob(5))
			M.emote(pick("twitch", "blink_r"))

	else if(M.chem_doses[type] < 2 * threshold)
		M.apply_effect(3, STUTTER)
		M.make_jittery(5)
		M.make_dizzy(5)
		M.add_chemical_effect(CE_PAINKILLER, 100)
		M.add_up_to_chemical_effect(CE_SPEEDBOOST, 1.25)
		M.add_chemical_effect(CE_PULSE, 3)

		M.make_drugged(35)
		if(prob(10))
			M.emote(pick("twitch", "blink_r", "shiver"))
	else
		M.add_chemical_effect(CE_MIND, -1)
		M.apply_effect(3, STUTTER)
		M.make_jittery(10)
		M.make_dizzy(10)
		M.add_chemical_effect(CE_PAINKILLER, 200)
		M.add_chemical_effect(CE_ALCOHOL_TOXIC, 1)
		M.add_up_to_chemical_effect(CE_SPEEDBOOST, 2)
		M.add_chemical_effect(CE_PULSE, 4)

		M.make_drugged(40)
		if(prob(15))
			M.emote(pick("twitch", "blink_r", "shiver"))

/datum/reagent/ethanol/silencer
	name = "Silencer"
	description = "A drink from Mime Heaven."
	taste_description = "a pencil eraser"
	taste_mult = 1.2
	nutriment_factor = 1
	color = "#ffffff"
	strength = 12

	glass_required = "pint"
	glass_icon_state = "silencer"
	glass_name = "Silencer"
	glass_desc = "A drink from mime Heaven."

/datum/reagent/ethanol/singulo
	name = "Singulo"
	description = "A blue-space beverage!"
	taste_description = "concentrated matter"
	color = "#2e6671"
	strength = 10

	glass_required = "carafe"
	glass_icon_state = "singulo"
	glass_name = "Singulo"
	glass_desc = "A blue-space beverage."

/datum/reagent/ethanol/snowwhite
	name = "Snow White"
	description = "A cold refreshment"
	taste_description = "refreshing cold"
	color = "#DFDFDFE6"
	strength = 30

	glass_required = "pint"
	glass_name = "Snow White"
	glass_desc = "A cold refreshment."
	glass_special = list(DRINK_FIZZ, DRINK_ICE)

/datum/reagent/ethanol/suidream
	name = "Sui Dream"
	description = "Comprised of: White soda, blue curacao, melon liquor."
	taste_description = "fruit"
	color = "#00a86b"
	strength = 100

	glass_required = "dpint"
	glass_icon_state = "suidream"
	glass_name = "Sui Dream"
	glass_desc = "A froofy, fruity, and sweet mixed drink. Understanding the name only brings shame."

/datum/reagent/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	description = "Tastes like terrorism!"
	taste_description = "purified antagonism"
	color = "#2e6671"
	strength = 10

	glass_required = "pint"
	glass_icon_state = "syndicatebomb"
	glass_name = "Syndicate Bomb"
	glass_desc = "Tastes like terrorism!"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/tequilla_sunrise
	name = "Tequila Sunrise"
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
	taste_description = "oranges"
	color = "#ffe48c"
	strength = 25

	glass_required = "pint"
	glass_icon_state = "tequillasunrise"
	glass_name = "Tequilla Sunrise"
	glass_desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."

/datum/reagent/ethanol/sexonthebeach
	name = "Sex on the Beach"
	description = "Don't take this as an instruction. You'll get robusted by ERP police."
	color = "#d34b00"
	strength = 20
	taste_description = "fruity classic"

	glass_required = "pint"
	glass_icon_state = "sexonthebeach"
	glass_name = "Sex on the Beach"
	glass_desc = "Don't take this as an instruction. You'll get robusted by ERP police."

/datum/reagent/ethanol/threemileisland
	name = "Three Mile Island Iced Tea"
	description = "Made for a woman, strong enough for a man."
	taste_description = "dry"
	color = "#666340"
	strength = 10
	druggy = 50

	glass_required = "carafe"
	glass_icon_state = "threemileisland"
	glass_name = "Three Mile Island iced tea"
	glass_desc = "A glass of this is sure to prevent a meltdown."

/datum/reagent/ethanol/toxins_special
	name = "Toxins Special"
	description = "This thing is ON FIRE! CALL THE DAMN SHUTTLE!"
	taste_description = "spicy toxins"
	reagent_state = LIQUID
	color = "#7f00ff"
	strength = 10
	adj_temp = 15
	targ_temp = 330

	glass_required = "shot"
	glass_icon_state = "toxinsspecial"
	glass_name = "Toxins Special"
	glass_desc = "Whoah, this thing is on FIRE"

/datum/reagent/ethanol/vesper
	name = "Vesper Martini"
	description = "Three measures of Gordon's, one of vodka, half a measure of Kina Lillet. Shake it very well until it's ice-cold, then add a large thin slice of lemon peel. Got it?"
	color = "#d8c36c"
	strength = 13
	taste_description = "perfect dryness"

	glass_required = "hurricane"
	glass_icon_state = "vesper"
	glass_name = "Vesper Martini"
	glass_desc = "That one appears to be large and very strong and very cold and very well-made."

/datum/reagent/ethanol/vodkamartini
	name = "Vodka Martini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	taste_description = "shaken, not stirred"
	color = "#0064c8"
	strength = 12

	glass_required = "cocktail"
	glass_icon_state = "vodkamartini"
	glass_name = "vodka martini"
	glass_desc ="A bastardisation of the classic martini. Still great."

/datum/reagent/ethanol/vodkatonic
	name = "Vodka and Tonic"
	description = "For when a gin and tonic isn't russian enough."
	taste_description = "tart bitterness"
	color = "#0064c8"
	strength = 15

	glass_required = "square"
	glass_icon_state = "vodkatonic"
	glass_name = "vodka and tonic"
	glass_desc = "For when a gin and tonic isn't Russian enough."


/datum/reagent/ethanol/white_russian
	name = "White Russian"
	description = "That's just, like, your opinion, man..."
	taste_description = "bitter cream"
	color = "#a68340"
	strength = 15

	glass_required = "rocks"
	glass_icon_state = "whiterussian"
	glass_name = "White Russian"
	glass_desc = "A very nice looking drink. But that's just, like, your opinion, man."


/datum/reagent/ethanol/whiskey_cola
	name = "Whiskey Cola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	taste_description = "cola"
	color = "#A3877AFC"
	strength = 25

	glass_required = "rocks"
	glass_name = "whiskey cola"
	glass_desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
	glass_special = list(DRINK_FIZZ, DRINK_ICE)

/datum/reagent/ethanol/whiskeysoda
	name = "Whiskey Soda"
	description = "For the more refined griffon."
	color = "#eab300"
	strength = 15

	glass_required = "rocks"
	glass_icon_state = "whiskeysoda"
	glass_name = "whiskey soda"
	glass_desc = "Ultimate refreshment."
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/witcher
	name = "Witcher"
	description = "\"People,\" Geralt turned his head, \"like to invent monsters and monstrosities. Then they seem less monstrous themselves\""
	color = "#f6f293"
	strength = 15
	taste_description = "potion"

	glass_required = "pint"
	glass_icon_state = "witcher"
	glass_name = "witchers' drink"
	glass_desc = "\"People,\" Geralt turned his head, \"like to invent monsters and monstrosities. Then they seem less monstrous themselves\""

/datum/reagent/ethanol/witcher/wolf
	name = "School of the Wolf"
	color = "#d1f2b2"
	taste_description = "lilac and gooseberries"

	glass_icon_state = "witcherwolf"
	glass_name = "School of the Wolf"

/datum/reagent/ethanol/witcher/cat
	name = "School of the Cat"
	color = "#f6af93"
	strength = 20
	taste_description = "berbercane fruit"

	glass_icon_state = "witchercat"
	glass_name = "School of the Cat"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/witcher/bear
	name = "School of the Bear"
	color = "#86583C"
	taste_description = "robust"
	strength = 12

	glass_icon_state = "witcherbear"
	glass_name = "School of the Bear"

/datum/reagent/ethanol/witcher/griffin
	name = "School of the Griffin"
	color = "#80b8e0"
	taste_description = "mana potion"

	glass_icon_state = "witchergriffin"
	glass_name = "School of the Griffin"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/zhenghe
	name = "Zheng He"
	description = "One of the Official Cocktails of the Expeditionary Corps, celebrating Zheng He."
	taste_description = "herbal bitterness"
	color = "#173b06"
	strength = 20

	glass_required = "cognac"
	glass_icon_state = "zhenghe"
	glass_name = "Zheng He cocktail"
	glass_desc = "A rather bitter blend of vermouth and well-steeped black tea. Named for Zheng He, who travelled from Nanjing in China as far as Mogadishu in the Horn of Africa in the 15th century."

/datum/reagent/ethanol/kvass
	name = "Kvass"
	description = "Kvass is a traditional drink of old north nations from the Earth, commonly made from rye bread."
	taste_description = "old north valleys"
	color = "#473000"
	strength = 60
	adj_temp = 10

	glass_required = "mug"
	glass_icon_state = "kvass"
	glass_name = "kvass"
	glass_desc = "Tasty kvass, it has BEST antioxidants, it's good for your soul!"
	glass_special = list(DRINK_FIZZ)

/datum/reagent/ethanol/quas
	name = "Quas"
	description = "Sadron's Summer Refreshment. Cold snap in a liquid form. Or, perhaps, just a bad pun."
	taste_description = "cold snap"
	color = "#0099cc"
	strength = 20
	adj_temp = -30
	targ_temp = 260

	glass_required = "vodkaglass"
	glass_icon_state = "quas"
	glass_name = "quas"
	glass_desc = "Sadron's Summer Refreshment. Cold snap in a liquid form. Or, perhaps, just a bad pun."
	glass_special = list(DRINK_FIZZ, DRINK_ICE)

/datum/reagent/ethanol/quas/affect_ingest(mob/living/carbon/M, alien, removed)
	..()
	if(alien == IS_DIONA)
		return
	M.heal_organ_damage(3 * removed, 3 * removed)
