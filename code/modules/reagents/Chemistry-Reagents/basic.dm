#define WATER_LATENT_HEAT 1900 // How much heat is removed when applied to a hot turf, in J/ml (1900 makes 1200 u of water roughly equivalent to 4L)

/// Water
/datum/reagent/water
	name = "Water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."

	taste_description = "water"

	reagent_state = LIQUID
	color = "#3073b6"

	metabolism = 7.5
	ingest_met = 1.5
	digest_met = 7.5
	hydration_value = 1.0

	glass_name = "water"
	glass_desc = "The father of all refreshments."

	var/slippery = 1

/datum/reagent/water/affect_blood(mob/living/carbon/M, alien, removed)
	if(istype(M, /mob/living/carbon/metroid) || alien == IS_METROID)
		M.adjustToxLoss(removed)
		return
	if(holder.has_reagent(/datum/reagent/salt, removed * 0.009)) // IV Saline Solution
		holder.remove_reagent(/datum/reagent/salt, removed * 0.009)
		M.add_hydration(removed * hydration_value * 3.0)
	else
		M.add_hydration(removed * hydration_value * 0.5)

/datum/reagent/water/affect_ingest(mob/living/carbon/M, alien, removed)
	if(istype(M, /mob/living/carbon/metroid) || alien == IS_METROID)
		M.adjustToxLoss(removed)
		return
	..()
	return

/datum/reagent/water/affect_digest(mob/living/carbon/M, alien, removed)
	if(istype(M, /mob/living/carbon/metroid) || alien == IS_METROID)
		M.adjustToxLoss(removed)
		return
	..()
	return

/datum/reagent/water/touch_turf(turf/simulated/T, amount)
	if(!istype(T))
		return

	var/datum/gas_mixture/environment = T.return_air()
	var/min_temperature = 100 CELSIUS // The boiling point of water

	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air(T:air:total_moles)
		lowertemp.temperature = max(min(lowertemp.temperature-2000, lowertemp.temperature / 2), 273.15) // It's 273.15 since we don't want extinguishers to drop the room temp down to the absolute zero.
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

	var/flamer = (locate(/obj/flamer_fire) in T)
	if(flamer && !istype(T, /turf/space))
		qdel(flamer)

	if(environment && environment.temperature > min_temperature) // Abstracted as steam or something
		var/removed_heat = between(0, amount * WATER_LATENT_HEAT, -environment.get_thermal_energy_change(min_temperature))
		environment.add_thermal_energy(-removed_heat)
		if(prob(5))
			T.visible_message(SPAN("warning", "The water sizzles as it lands on \the [T]!"))

	else if(amount >= 100 && slippery)
		var/turf/simulated/S = T
		S.wet_floor(1, TRUE)

/datum/reagent/water/touch_obj(obj/O)
	if(istype(O, /obj/item/reagent_containers/food/monkeycube))
		var/obj/item/reagent_containers/food/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()
	else if(istype(O, /obj/item/clothing/mask/smokable))
		var/obj/item/clothing/mask/smokable/smokable = O
		smokable.die(FALSE, TRUE)
	else if(istype(O, /obj/item/flame/lighter))
		var/obj/item/flame/lighter/lighter = O
		lighter.shutoff(silent = TRUE)
	else if(istype(O, /obj/item/flame/candle))
		var/obj/item/flame/candle/candle = O
		candle.lit = FALSE
		candle.update_icon()
	else if(istype(O, /obj/item/flame/match))
		var/obj/item/flame/match/match = O
		match.burn_out()

/datum/reagent/water/touch_mob(mob/living/L, amount)
	if(istype(L))
		var/removed_amount = L.fire_stacks
		L.adjust_fire_stacks(-1 * ceil(amount / 10))
		removed_amount = L.fire_stacks - removed_amount
		remove_self(removed_amount)

/datum/reagent/water/affect_touch(mob/living/carbon/M, alien, removed)
	if(!istype(M, /mob/living/carbon/metroid) && alien != IS_METROID)
		return
	M.adjustToxLoss(removed)	// Babies have 150 health, adults have 200; So, 150ml and 200ml
	var/mob/living/carbon/metroid/S = M
	if(!S.client && istype(S))
		if(S.Target) // Like cats
			S.Target = null
		if(S.Victim)
			S.Feedstop()
	if(M.chem_doses[type] == removed)
		M.visible_message("<span class='warning'>[S]'s flesh sizzles where the water touches it!</span>", "<span class='danger'>Your flesh burns in the water!</span>")
		M.confused = max(M.confused, 2)

/// Acetone
/datum/reagent/acetone
	name = "Acetone"
	description = "A colorless liquid solvent used in chemical synthesis."

	taste_description = "paint stripper" // "nail polish remover" appears to be a bit too long.
	taste_mult = 25.0

	reagent_state = LIQUID
	color = "#808080"

	metabolism = REM * 0.5

/datum/reagent/acetone/affect_blood(mob/living/carbon/M, alien, removed, affecting_dose)
	M.adjustToxLoss(removed * 3)
	if(affecting_dose > 5.0)
		M.adjustBrainLoss(removed * 12.5) // Acetone causes nerve tissue damage, don't chug on it

/datum/reagent/acetone/touch_obj(obj/O)	//I copied this wholesale from ethanol and could likely be converted into a shared proc. ~Techhead
	if(istype(O, /obj/item/paper))
		var/obj/item/paper/paperaffected = O
		paperaffected.clearpaper()
		to_chat(usr, "The solution dissolves the ink on the paper.")
		return
	if(istype(O, /obj/item/book))
		if(volume < 15)
			return
		if(istype(O, /obj/item/book/tome))
			to_chat(usr, "<span class='notice'>The solution does nothing. Whatever this is, it isn't normal ink.</span>")
			return
		var/obj/item/book/affectedbook = O
		affectedbook.dat = null
		to_chat(usr, "<span class='notice'>The solution dissolves the ink on the book.</span>")
	return

/// Aluminum
/datum/reagent/aluminum
	name = "Aluminum"
	description = "A silvery white and ductile member of the boron group of chemical elements."

	taste_description = "metal"
	taste_mult = 1.1

	reagent_state = SOLID
	color = "#a8a8a8"

	metabolism = REM * 0.1
	ingest_met = METABOLISM_NONE // Feels right to just ignore such tiny values

/datum/reagent/aluminum/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	M.adjustToxLoss(removed)

/// Ammonia
/datum/reagent/ammonia
	name = "Ammonia"
	taste_description = "ammonia"
	taste_mult = 25.0
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = LIQUID
	color = "#404030"
	metabolism = REM * 0.5

/datum/reagent/ammonia/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_VOX)
		M.adjustOxyLoss(-removed * 10)
	else if(alien != IS_DIONA)
		M.adjustToxLoss(removed * 1.5)

/// Carbon
/datum/reagent/carbon
	name = "Carbon"
	description = "A chemical element, the building block of life."

	taste_description = "sour chalk"
	taste_mult = 1.5

	forced_metabolism = TRUE
	reagent_state = SOLID
	color = "#1c1300"

	ingest_met = REM * 3.0
	digest_met = REM * 5.0

/datum/reagent/carbon/affect_ingest(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	var/datum/reagents/ingested = M.get_ingested_reagents()
	if(ingested?.reagent_list.len > 1) // Need to have at least 2 reagents - cabon and something to remove
		var/effect = 1 / (ingested.reagent_list.len - 1)
		for(var/datum/reagent/R in ingested.reagent_list)
			if(R == src)
				continue
			ingested.remove_reagent(R.type, removed * effect)

/datum/reagent/carbon/affect_digest(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	var/datum/reagents/digested = M.get_digested_reagents()
	if(digested?.reagent_list.len > 1) // Need to have at least 2 reagents - cabon and something to remove
		var/effect = 1 / (digested.reagent_list.len - 1)
		for(var/datum/reagent/R in digested.reagent_list)
			if(R == src)
				continue
			digested.remove_reagent(R.type, removed * effect)

/datum/reagent/carbon/touch_turf(turf/T)
	if(!istype(T, /turf/space))
		var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, T)
		if (!dirtoverlay)
			dirtoverlay = new /obj/effect/decal/cleanable/dirt(T)
			dirtoverlay.alpha = volume * 30
		else
			dirtoverlay.alpha = min(dirtoverlay.alpha + volume * 30, 255)

/// Copper
/datum/reagent/copper
	name = "Copper"
	description = "A highly ductile metal."

	taste_description = "copper"

	reagent_state = SOLID
	color = "#6e3b08"

	metabolism = REM * 0.1
	ingest_met = METABOLISM_NONE

/// Hydrazine
/datum/reagent/hydrazine
	name = "Hydrazine"
	description = "A toxic, colorless, flammable liquid with a strong ammonia-like odor, in hydrate form."

	taste_description = "sweet tasting metal"

	reagent_state = LIQUID
	color = "#808080"

	metabolism = REM * 0.2
	ingest_met = METABOLISM_NONE
	touch_met = 5.0

/datum/reagent/hydrazine/affect_blood(mob/living/carbon/M, alien, removed)
	M.adjustToxLoss(4 * removed)

/datum/reagent/hydrazine/touch_mob(mob/living/L, amount)
	if(istype(L))
		L.adjust_fire_stacks(ceil(amount / 5))

/datum/reagent/hydrazine/affect_touch(mob/living/carbon/M, alien, removed) // Hydrazine is both toxic and flammable.
	M.adjustToxLoss(0.2 * removed)

/datum/reagent/hydrazine/touch_turf(turf/T)
	new /obj/effect/decal/cleanable/liquid_fuel(T, volume)
	remove_self(volume)
	return

/// Iron
/datum/reagent/iron
	name = "Iron"
	description = "Pure iron is a metal."

	taste_description = "rust"
	taste_mult = 5.0

	reagent_state = SOLID
	color = "#353535"

	metabolism = REM * 0.25
	ingest_met = METABOLISM_NONE
	digest_absorbability = 0.75
	overdose = REAGENTS_OVERDOSE

/datum/reagent/iron/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien != IS_DIONA)
		M.add_chemical_effect(CE_BLOODRESTORE, 30 * removed)

/// Lithium
/datum/reagent/lithium
	name = "Lithium"
	description = "A chemical element, used as antidepressant."

	taste_description = "metal"
	reagent_state = SOLID

	color = "#808080"

/datum/reagent/lithium/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien != IS_DIONA)
		if(istype(M.loc, /turf/space))
			M.SelfMove(pick(GLOB.cardinal))
		if(prob(5))
			M.emote(pick("twitch", "drool", "moan"))

/// Mercury
/datum/reagent/mercury
	name = "Mercury"
	description = "A chemical element."

	taste_mult = 0 //mercury apparently is tasteless. IDK

	color = "#484848"
	reagent_state = LIQUID

	metabolism = REM * 0.2
	ingest_met = METABOLISM_NONE

/datum/reagent/mercury/affect_blood(mob/living/carbon/M, alien, removed)
	if(alien == IS_DIONA)
		return
	if(isturf(M.loc))
		M.SelfMove(pick(GLOB.cardinal))
	if(prob(5))
		M.emote(pick("twitch", "drool", "moan"))
	M.adjustBrainLoss(1.0)

/// Phosphorus
/datum/reagent/phosphorus
	name = "Phosphorus"
	description = "A chemical element, the backbone of biological energy carriers."

	taste_description = "vinegar"

	reagent_state = SOLID
	color = "#832828"

/datum/reagent/phosphorus/affect_blood(mob/living/carbon/M, alien, removed)
	M.adjustToxLoss(3 * removed)

/// Potassium
/datum/reagent/potassium
	name = "Potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."

	taste_description = "sweetness" //potassium is bitter in higher doses but sweet in lower ones.

	reagent_state = SOLID
	color = "#a0a0a0"

	metabolism = REM * 0.5
	overdose = REAGENTS_OVERDOSE

/datum/reagent/potassium/affect_blood(mob/living/carbon/M, alien, removed)
	M.adjustBrainLoss(-0.5 * removed)

/// Radium
/datum/reagent/radium
	name = "Radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."

	taste_description = "the color blue, and regret"

	forced_metabolism = TRUE
	reagent_state = SOLID
	color = "#c7c7c7"

	radiation = new /datum/radiation/preset/radium_226

/datum/reagent/radium/affect_blood(mob/living/carbon/M, alien, removed)
	radiation.activity = radiation.specific_activity * volume
	M.radiation += radiation.calc_equivalent_dose(AVERAGE_HUMAN_WEIGHT)

	if(M.virus2.len)
		for(var/ID in M.virus2)
			var/datum/disease2/disease/V = M.virus2[ID]
			if(prob(5))
				M.antibodies |= V.antigen
				if(prob(50))
					M.radiation += radiation.calc_equivalent_dose(AVERAGE_HUMAN_WEIGHT) * 10 // curing it that way may kill you instead
					var/absorbed = 0
					var/obj/item/organ/internal/diona/nutrients/rad_organ = locate() in M.internal_organs
					if(rad_organ && !rad_organ.is_broken())
						absorbed = 1
					if(!absorbed)
						M.adjustToxLoss(100)

/datum/reagent/radium/touch_turf(turf/T)
	if(volume >= 5)
		if(!istype(T, /turf/space))
			var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)

			if(!glow)
				glow = new (T)
				glow.create_reagents(volume)

			glow.reagents.maximum_volume = glow.reagents.total_volume + volume
			glow.reagents.add_reagent(type, volume, get_data(), FALSE)

/// Sulphuric Acid
/datum/reagent/acid
	name = "Sulphuric acid"
	description = "A very corrosive mineral acid with the molecular formula H2SO4."

	taste_description = "acid"
	taste_mult = 50.0 // It's hard not to notice your tongue melting down.

	reagent_state = LIQUID
	color = "#db5008"

	metabolism = REM * 2.0
	ingest_met = METABOLISM_FALLBACK
	touch_met = 25.0 // It's acid!
	forced_metabolism = TRUE

	var/power = 5
	var/meltdose = 10 // How much is needed to melt

/datum/reagent/acid/affect_blood(mob/living/carbon/M, alien, removed)
	M.take_organ_damage(0, removed * power * 2)

/datum/reagent/acid/affect_ingest(mob/living/carbon/M, alien, removed, affecting_dose)
	if(!ishuman(M))
		affect_blood(M, alien, removed)
		return

	var/mob/living/carbon/human/H = M

	// Burn the stomach if it's present and not broken
	var/obj/item/organ/internal/stomach/S = H.internal_organs_by_name[BP_STOMACH]
	if(S && S.damage < S.max_damage)
		S.take_internal_damage(removed * power * 0.5)
		return

	// Stomach is either missing or peforated, burning the chest
	var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
	if(istype(chest))
		chest.take_burn_damage(removed * power * 0.5, "Corrosive Chemicals")
	return

/datum/reagent/acid/affect_digest(mob/living/carbon/M, alien, removed, affecting_dose)
	if(!ishuman(M))
		affect_blood(M, alien, removed)
		return

	var/mob/living/carbon/human/H = M

	// Burn the intestines
	var/obj/item/organ/internal/intestines/I = H.internal_organs_by_name[BP_INTESTINES]
	if(I && I.damage < I.max_damage)
		I.take_internal_damage(removed * power * 0.75)
		return

	// Intestines are done, melting the groin and chest
	var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
	if(istype(chest))
		chest.take_burn_damage(removed * power * 0.25, "Corrosive Chemicals")
	var/obj/item/organ/external/groin = H.get_organ(BP_GROIN)
	if(istype(groin))
		groin.take_burn_damage(removed * power * 0.5, "Corrosive Chemicals")
	return

/datum/reagent/acid/affect_touch(mob/living/carbon/M, alien, removed) // This is the most interesting
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.head)
			if(H.head.unacidable)
				to_chat(H, "<span class='danger'>Your [H.head] protects you from the acid.</span>")
				remove_self(volume)
				return
			else if(removed > meltdose)
				to_chat(H, "<span class='danger'>Your [H.head] melts away!</span>")
				qdel(H.head)
				H.update_inv_head(1)
				H.update_hair(1)
				H.update_facial_hair(1)
				removed -= meltdose
		if(removed <= 0)
			return

		if(H.wear_mask)
			if(H.wear_mask.unacidable)
				to_chat(H, "<span class='danger'>Your [H.wear_mask] protects you from the acid.</span>")
				remove_self(volume)
				return
			else if(removed > meltdose)
				to_chat(H, "<span class='danger'>Your [H.wear_mask] melts away!</span>")
				qdel(H.wear_mask)
				H.update_inv_wear_mask(1)
				H.update_hair(1)
				H.update_facial_hair(1)
				removed -= meltdose
		if(removed <= 0)
			return

		if(H.glasses)
			if(H.glasses.unacidable)
				to_chat(H, "<span class='danger'>Your [H.glasses] partially protect you from the acid!</span>")
				removed /= 2
			else if(removed > meltdose)
				to_chat(H, "<span class='danger'>Your [H.glasses] melt away!</span>")
				qdel(H.glasses)
				H.update_inv_glasses(1)
				removed -= meltdose / 2
		if(removed <= 0)
			return

	if(M.unacidable)
		return

	if(volume < meltdose) // Not enough to melt anything
		M.take_organ_damage(0, removed * power * 0.1) //burn damage, since it causes chemical burns. Acid doesn't make bones shatter, like brute trauma would.
	else
		M.take_organ_damage(0, removed * power * 0.1)
		if(removed && ishuman(M) && prob(100 * removed / meltdose)) // Applies disfigurement
			var/mob/living/carbon/human/H = M
			var/screamed
			for(var/obj/item/organ/external/affecting in H.external_organs)
				if(!screamed && affecting.can_feel_pain())
					screamed = 1
					H.emote("scream")

/datum/reagent/acid/touch_obj(obj/O)
	if(O.unacidable)
		return
	if((istype(O, /obj/item) || istype(O, /obj/effect/vine)) && (volume > meltdose))
		var/obj/effect/decal/cleanable/molten_item/I = new /obj/effect/decal/cleanable/molten_item(O.loc)
		I.desc = "Looks like this was \an [O] some time ago."
		for(var/mob/M in viewers(5, O))
			to_chat(M, "<span class='warning'>\The [O] melts.</span>")
		qdel(O)
		remove_self(meltdose) // 10 ml of acid will not melt EVERYTHING on the tile

/// Hydrochloric Acid
/datum/reagent/acid/hydrochloric //Like sulfuric, but less toxic and more acidic.
	name = "Hydrochloric Acid"
	description = "A very corrosive mineral acid with the molecular formula HCl."

	taste_description = "stomach acid"
	taste_mult = 50.0

	reagent_state = LIQUID
	color = "#808080"

	power = 3
	meltdose = 8

// Polytrinic Acid
/datum/reagent/acid/polyacid
	name = "Polytrinic Acid"
	description = "Polytrinic acid is a an extremely corrosive chemical substance."

	taste_description = "your tongue melting"
	taste_mult = 50.0

	reagent_state = LIQUID
	color = "#8e18a9"

	power = 10
	meltdose = 4

// Stomach Acid
/datum/reagent/acid/stomach
	name = "Stomach Acid"

	taste_description = "coppery foulness"

	color = "#d8ff00"

	power = 1
	meltdose = 100

/// Silicon
/datum/reagent/silicon
	name = "Silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."

	color = "#a8a8a8"
	reagent_state = SOLID

	metabolism = REM * 0.1 // Totally inert
	ingest_met = METABOLISM_NONE
	excretion = 20.0

/// Sodium
/datum/reagent/sodium
	name = "Sodium"
	description = "A chemical element, readily reacts with water."

	taste_description = "salty metal"

	reagent_state = SOLID
	color = "#808080"

/// Sugar
/datum/reagent/sugar
	name = "Sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."

	taste_description = "sweetness"
	taste_mult = 7.5

	reagent_state = SOLID
	color = "#ffffff"

	metabolism = REM * 2.0
	digest_met = REM * 5.0
	digest_absorbability = 0.5

	glass_name = "sugar"
	glass_desc = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	glass_icon = DRINK_ICON_NOISY

/datum/reagent/sugar/affect_blood(mob/living/carbon/M, alien, removed)
	M.add_nutrition(removed * 10.0)

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

/// Sulfur
/datum/reagent/sulfur
	name = "Sulfur"
	description = "A chemical element with a pungent smell."

	taste_description = "old eggs"
	reagent_state = SOLID

	color = "#bf8c00"

/// Tungsten
/datum/reagent/tungsten
	name = "Tungsten"
	description = "A chemical element, and a strong oxidising agent."

	taste_mult = 0 //no taste

	reagent_state = SOLID
	color = "#dcdcdc"

	metabolism = REM * 0.1
	ingest_met = METABOLISM_NONE
