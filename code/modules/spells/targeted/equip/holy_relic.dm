/datum/spell/targeted/equip_item/holy_relic
	name = "Summon Holy Relic"
	desc = "This spell summons a relic of purity into your hand for a short while."
	feedback = "SR"
	school = "conjuration"
	charge_type = SP_RECHARGE
	charge_max = 600
	spell_flags = NEEDSCLOTHES | INCLUDEUSER
	invocation = "Yee'Ro Su!"
	invocation_type = SPI_SHOUT
	range = 0
	max_targets = 1
	level_max = list(SP_TOTAL = 2, SP_SPEED = 1, SP_POWER = 1)
	duration = 250
	cooldown_min = 350
	delete_old = 0
	compatible_mobs = list(/mob/living/carbon/human)

	icon_state = "purge1"

	equipped_summons = list("active hand" = /obj/item/nullrod)

/datum/spell/targeted/equip_item/holy_relic/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/M in targets)
		M.visible_message("A rod of metal appears in \the [M]'s hand!")

/datum/spell/targeted/equip_item/holy_relic/empower_spell()
	if(!..())
		return 0

	duration += 50

	return "The holy relic now lasts for [duration/10] seconds."
