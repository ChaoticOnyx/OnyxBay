/datum/spell/targeted/equip_item/party_hardy
	name = "Summon Party"
	desc = "This spell was invented for the sole purpose of getting crunked at 11am on a Tuesday. Does not require wizard garb."
	feedback = "PY"
	school = "conjuration"
	charge_type = SP_RECHARGE
	charge_max = 900
	cooldown_min = 600
	spell_flags = INCLUDEUSER
	invocation = "Llet'Su G'iit Rrkned!" //Let's get wrecked.
	invocation_type = SPI_SHOUT
	range = 6
	max_targets = 0
	level_max = list(SP_TOTAL = 3, SP_SPEED = 1, SP_POWER = 2)
	delete_old = 0

	icon_state = "wiz_party"

	compatible_mobs = list(/mob/living/carbon/human)
	equipped_summons = list("active hand" = /obj/item/reagent_containers/vessel/bottle/small/beer)

/datum/spell/targeted/equip_item/party_hardy/empower_spell()
	if(!..())
		return 0
	switch(spell_levels[SP_POWER])
		if(1)
			equipped_summons = list("active hand" = /obj/item/reagent_containers/vessel/bottle/small/beer,
								"off hand" = /obj/item/reagent_containers/food/poppypretzel)
			return "The spell will now give everybody a preztel as well."
		if(2)
			equipped_summons = list("active hand" = /obj/item/reagent_containers/vessel/bottle/absinthe,
								"off hand" = /obj/item/reagent_containers/food/poppypretzel,
								"[slot_head]" = /obj/item/clothing/head/collectable/wizard)
			return "Woo! Now everybody gets a cool wizard hat and MORE BOOZE!"

	return 0
