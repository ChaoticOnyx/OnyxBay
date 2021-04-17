/spell/targeted/projectile/dumbfire/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."
	feedback = "FB"
	proj_type = /obj/item/projectile/spell_projectile/fireball

	school = "conjuration"
	charge_max = 100
	spell_flags = 0
	invocation = "Oni-Soma!"
	invocation_type = SpI_SHOUT
	range = 20

	level_max = list(Sp_TOTAL = 5, Sp_SPEED = 0, Sp_POWER = 5)

	spell_flags = 0

	duration = 20
	proj_step_delay = 1

	amt_dam_brute = 20
	amt_dam_fire = 30

	var/ex_severe = -1
	var/ex_heavy = 1
	var/ex_light = 2
	var/ex_flash = 5

	hud_state = "wiz_fireball"

/spell/targeted/projectile/dumbfire/fireball/prox_cast(list/targets, spell_holder)
	for(var/mob/living/M in targets)
		apply_spell_damage(M)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/list/cig_places = list(H.wear_mask, H.l_ear, H.r_ear, H.r_hand, H.l_hand)
			for(var/obj/item/clothing/mask/smokable/cig in cig_places)
				cig.light(src, H)
	explosion(get_turf(spell_holder), ex_severe, ex_heavy, ex_light, ex_flash)

/spell/targeted/projectile/dumbfire/fireball/empower_spell()
	if(!..())
		return 0

	amt_dam_brute += 10
	amt_dam_fire += 25

	if(spell_levels[Sp_POWER]%2 == 1)
		ex_severe++
	ex_heavy++
	ex_light++
	ex_flash++

	return "The spell [src] now has a larger explosion."

//PROJECTILE

/obj/item/projectile/spell_projectile/fireball
	name = "fireball"
	icon_state = "fireball"
