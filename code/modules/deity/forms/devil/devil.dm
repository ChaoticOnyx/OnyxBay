GLOBAL_LIST_INIT(devil_default_spells, list(
	/datum/action/cooldown/spell/summon_contract,
	/datum/action/cooldown/spell/summon_pitchfork,
	/datum/action/cooldown/spell/mind_dominate,
	/datum/action/cooldown/spell/devil_astral,
	))

#define FOLLOWERS_TO_ASCEND 8
#define FOLLOWERS_UNTIL_DEVIL 4

/datum/deity_form/devil
	name = "Devil"
	desc = "What’s better than a devil you don’t know? A devil you do."
	form_state = "devil"

	buildables = list(/datum/deity_power/structure/devil_teleport)
	phenomena = list(/datum/deity_power/phenomena/conversion, /datum/deity_power/phenomena/devils_ressurection)
	boons = list()
	resources = list(/datum/deity_resource/souls)
	evo_holder = /datum/evolution_holder/devil

	/// Path to an associated bane
	var/bane
	var/mob/living/carbon/current_devil_shell
	var/turf/devil_spawn
	var/respawn_points = 1

	conversion_text = "By accepting this proposal you will sell your soul."

/datum/deity_form/devil/setup_form(mob/living/deity/D)
	. = ..()
	bane = pick(DEVIL_BANES)

	var/datum/map_template/devil_level/dlevel = new /datum/map_template/devil_level()
	devil_spawn = dlevel.load_new_z()
	if(!istype(devil_spawn))
		CRASH("Somehow loading devil's zlevel failed. Contact coders.")

	create_devils_shell(D)

/datum/deity_form/devil/on_follower_add()
	if(length(deity.followers) >= FOLLOWERS_UNTIL_DEVIL && length(deity.followers) < FOLLOWERS_TO_ASCEND)
		var/mob/mob_to_alert = istype(current_devil_shell) ? current_devil_shell : deity
		tgui_alert(mob_to_alert, "You have now enough followers, soon you will no longer be able to hide your identity. It is better to hide somewhere, as this process leaves you defenseless for a moment.", "Your power grows.")
		var/datum/action/cooldown/spell/true_form/tf = new /datum/action/cooldown/spell/true_form()
		tf.Grant(current_devil_shell)

	if(length(deity.followers) >= FOLLOWERS_TO_ASCEND)
		ascend()

/datum/deity_form/devil/proc/ascend()
	if(!istype(current_devil_shell))
		create_devils_shell()

	var/mob/living/simple_animal/hostile/devil/D = new /mob/living/simple_animal/hostile/devil(get_turf(current_devil_shell), current_devil_shell)
	current_devil_shell.forceMove(D)
	current_devil_shell.mind.transfer_to(D)
	SetUniversalState(/datum/universal_state/averno)

/datum/deity_form/devil/proc/create_devils_shell(mob/living/deity/D, turf = null)
	var/mob/living/carbon/human/devil_new = new /mob/living/carbon/human(!isnull(turf) ? turf : devil_spawn)
	if(length(deity.followers) >= FOLLOWERS_UNTIL_DEVIL && length(deity.followers) < FOLLOWERS_TO_ASCEND)
		devil_new.set_species(SPECIES_DEVIL)

	D.mind.deity = D
	current_devil_shell = devil_new
	ADD_TRAIT(devil_new, bane)
	D.mind?.transfer_to(devil_new)

	for(var/path in GLOB.devil_default_spells)
		var/datum/action/new_act = new path()
		new_act.Grant(devil_new)

	grant_verb(devil_new, /mob/living/carbon/human/verb/deity_tgui_interact)

/mob/living/carbon/human/verb/deity_tgui_interact()
	set name = "Deity Menu"
	set category = "Godhood"

	if(istype(mind.deity))
		mind.deity.tgui_interact(src)

/datum/deity_form/devil/proc/on_shell_death(datum/mind/M)
	M.transfer_to(deity)
	if(respawn_points <= 0)
		tgui_alert(deity, "Your shell is dead and you have no more chances!", "Your shell is dead!")
		devil_nde()

	var/datum/deity_power/phenomena/devils_ressurection/ressurection_spell = locate(/datum/deity_power/phenomena/devils_ressurection) in phenomena
	ressurection_spell?.manifest(deity, deity)

/datum/deity_form/devil/proc/devil_nde()
	deity.say("Your master is mortally wounded. Conduct a ritual of ressurection, or they will die. Make haste, time is of the essence!")
	for(var/datum/mind/M in deity.followers)
		var/datum/action/cooldown/spell/ressurection_ritual/ra = new /datum/action/cooldown/spell/ressurection_ritual()
		ra.Grant(M.current)

/datum/deity_form/devil/proc/quasit_ressurection(datum/mind/M)
	var/datum/evolution_package/devil/second_life/SL = locate(/datum/evolution_package/devil/second_life) in evo_holder.evolution_categories
	if(!istype(SL))
		return FALSE

	var/mob/living/carbon/human/quasit = new /mob/living/carbon/human/quasit(devil_spawn)
	M.transfer_to(quasit)
	var/datum/evolution_package/devil/second_life_enchancement/upgrade = locate() in evo_holder.unlocked_packages
	if(istype(upgrade))
		upgrade_quasit(quasit)
	return TRUE

/datum/deity_form/devil/proc/upgrade_quasit(mob/living/carbon/human/quasit)
	quasit.add_modifier(/datum/modifier/upgraged_quasit)

/datum/deity_form/devil/proc/upgrade_all_quasits()
	for(var/datum/mind/M in deity.followers)
		var/mob/living/carbon/human/H = M.current
		if(!istype(H))
			continue

		if(!istype(H.species, /datum/species/monkey/quasit))
			continue

		upgrade_quasit(H)

/datum/modifier/upgraged_quasit
	max_health_flat = 50
	incoming_damage_percent = 0.75

/datum/deity_resource/souls
	name = "Souls"

/datum/evolution_holder/devil
	evolution_categories = list(
		/datum/evolution_category/devil/followers,
	)
