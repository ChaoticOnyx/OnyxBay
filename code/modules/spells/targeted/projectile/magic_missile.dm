/datum/spell/targeted/projectile/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."
	feedback = "MM"
	school = "conjuration"
	charge_max = 150
	spell_flags = NEEDSCLOTHES
	invocation = "Forti Gy-Ama!"
	invocation_type = SPI_SHOUT
	range = 7
	level_max = list(SP_TOTAL = 3, SP_SPEED = 2, SP_POWER = 3)
	cooldown_min = 90 //15 deciseconds reduction per rank

	max_targets = 0

	proj_type = /obj/item/projectile/spell_projectile/seeking/magic_missile
	duration = 10
	proj_step_delay = 5

	icon_state = "wiz_mm"

	amt_paralysis = 3
	amt_stunned = 3

	amt_dam_fire = 10

/datum/spell/targeted/projectile/magic_missile/prox_cast(list/targets, atom/spell_holder)
	spell_holder.visible_message("<span class='danger'>\The [spell_holder] pops with a flash!</span>")
	for(var/mob/living/M in targets)
		apply_spell_damage(M)
	return

/datum/spell/targeted/projectile/magic_missile/empower_spell()
	if(!..())
		return 0

	if(spell_levels[SP_POWER] == level_max[SP_POWER])
		amt_paralysis += 2
		amt_stunned += 2
		return "[src] will now stun people for a longer duration."
	amt_dam_fire += 5

	return "[src] does more damage now."



//PROJECTILE

/obj/item/projectile/spell_projectile/seeking/magic_missile
	name = "magic missile"
	icon_state = "magicm"

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"
