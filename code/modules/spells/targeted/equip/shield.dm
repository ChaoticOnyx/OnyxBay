/datum/spell/targeted/equip_item/shield
	name = "Summon Shield"
	desc = "Summons the most holy of shields, the riot shield. Commonly used during wizard riots."
	feedback = "SH"
	school = "conjuration"
	invocation = "Sia helda!"
	invocation_type = SPI_SHOUT
	spell_flags = INCLUDEUSER | NEEDSCLOTHES
	range = 0
	max_targets = 1

	compatible_mobs = list(/mob/living/carbon/human)

	level_max = list(SP_TOTAL = 3, SP_SPEED = 2, SP_POWER = 1)
	charge_type = SP_RECHARGE
	charge_max = 900
	cooldown_min = 300
	equipped_summons = list("off hand" = /obj/item/shield/)
	duration = 300
	delete_old = 0
	var/item_color = "#6666ff"
	var/mod_shield = 2.0

	icon_state = "wiz_shield"

/datum/spell/targeted/equip_item/shield/summon_item(new_type)
	var/obj/item/shield/I = new new_type()
	I.icon_state = "buckler"
	I.color = item_color
	I.SetName("Wizard's Shield")
	I.mod_shield = mod_shield
	I.block_tier = BLOCK_TIER_PROJECTILE
	return I

/datum/spell/targeted/equip_item/shield/empower_spell()
	if(!..())
		return 0

	item_color = "#6600ff"
	mod_shield = 2.5

	return "Your summoned shields will now reflect bullets."
