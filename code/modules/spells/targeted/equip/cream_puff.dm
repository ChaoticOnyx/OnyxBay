
/datum/spell/targeted/equip_item/cream_puff
	name = "Workout Meal"
	desc = "You take out one of the cream puffs you're always carrying with you."
	feedback = "WM"
	delete_old = FALSE
	single_item = FALSE

	spell_flags = INCLUDEUSER
	invocation_type = SPI_EMOTE
	invocation = "casually takes out a cream puff."

	equipped_summons = list("active hand" = /obj/item/reagent_containers/food/cream_puff)
	compatible_mobs = list(/mob/living/carbon/human)

	charge_max = 15 SECONDS

	range = 0
	max_targets = 1

	icon_state = "wiz_cream_puff"
