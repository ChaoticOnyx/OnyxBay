/datum/spell/aoe_turf/conjure/summon/skull
	name = "Summon skull-protector"
	desc = "This spell summons an undead creature that will guard you."
	feedback = "SS"

	charge_max = 4 MINUTES
	spell_flags = NEEDSCLOTHES
	invocation = "Capita veniunt!"
	invocation_type = SPI_SHOUT
	level_max = list(SP_TOTAL = 0, SP_SPEED = 0, SP_POWER = 0)

	range = 1

	summon_amt = 1
	summon_type = list(/mob/living/simple_animal/hostile/commanded/skull_protector)

	icon_state = "wiz_protector"
	override_base = "const"

/datum/spell/aoe_turf/conjure/summon/skull/before_cast()
	newVars["master"] = holder //why not do this in the beginning? MIND SWITCHING.
	return ..()
