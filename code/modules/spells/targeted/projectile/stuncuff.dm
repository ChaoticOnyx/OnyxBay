/datum/spell/targeted/projectile/dumbfire/stuncuff
	name = "Stun Cuff"
	desc = "This spell fires out a small curse that stuns and cuffs the target."
	feedback = "SC"
	proj_type = /obj/item/projectile/spell_projectile/stuncuff

	charge_type = SP_CHARGES
	charge_max = 6
	charge_counter = 6
	spell_flags = 0
	invocation = "Fu'Reai Diakan!"
	invocation_type = SPI_SHOUT
	range = 20

	level_max = list(SP_TOTAL = 1, SP_SPEED = 0, SP_POWER = 1)

	duration = 20
	proj_step_delay = 1

	amt_stunned = 6

	icon_state = "wiz_cuff"

/datum/spell/targeted/projectile/dumbfire/stuncuff/empower_spell()
	. = ..()
	charge_type = SP_RECHARGE // becomes rechargable
	charge_max = 40
	charge_counter = 40
	src.process()
	return "[src] are now rechargable"

/datum/spell/targeted/projectile/dumbfire/stuncuff/prox_cast(list/targets, spell_holder)
	for(var/mob/living/M in targets)
		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/obj/item/handcuffs/wizard/cuffs = new()
			cuffs.forceMove(H)
			H.handcuffed = cuffs
			H.update_inv_handcuffed()
			H.visible_message("Beams of light form around \the [H]'s hands!")
		apply_spell_damage(M)


/obj/item/handcuffs/wizard
	name = "beams of light"
	desc = "Undescribable and unpenetrable. Or so they say."

	breakouttime = 300 //30 seconds

/obj/item/handcuffs/wizard/dropped(mob/user)
	..()
	qdel(src)

/obj/item/projectile/spell_projectile/stuncuff
	name = "stuncuff"
	icon_state = "spell"
