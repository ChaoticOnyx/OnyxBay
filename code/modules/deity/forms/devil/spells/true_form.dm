#define ASTRAL_TIME_MAX 10 SECONDS

/datum/action/cooldown/spell/true_form
	name = "True Form."
	desc = "Spread your wings."
	button_icon_state = "devil_astral"

	cooldown_time = 10 SECONDS
	smoke_amt = 2
	/// In case the devil is ascended this spells allows to switch between combat and true forms freely.
	var/ascended = FALSE
	var/mob/real_owner

/datum/action/cooldown/spell/true_form/New()
	. = ..()
	if(!ascended)
		add_think_ctx("forced_reveal", CALLBACK(src, nameof(.proc/forced_reveal)), world.time + 30 SECONDS)

/datum/action/cooldown/spell/true_form/Destroy()
	real_owner = null
	return ..()

/datum/action/cooldown/spell/true_form/cast()
	if(!ascended)
		var/mob/living/carbon/human/devil = owner
		if(!istype(devil))
			return

		devil.set_species(SPECIES_DEVIL)
		devil.change_appearance(APPEARANCE_ALL, devil.loc, devil, TRUE, state = GLOB.z_state)
		return

	if(ishuman(owner))
		var/mob/living/simple_animal/hostile/devil/D = new /mob/living/simple_animal/hostile/devil(get_turf(owner), owner)
		owner.forceMove(D)
		owner.mind.transfer_to(D)

	if(istype(owner, /mob/living/simple_animal/hostile/devil))
		real_owner.forceMove(get_turf(owner))
		owner.mind.transfer_to(real_owner)
		owner.forceMove(real_owner)

/datum/action/cooldown/spell/true_form/proc/forced_reveal()
	if(!ascended)
		cast(owner)

/mob/living/simple_animal/hostile/devil
	name = "Devil"
	desc = "The Devil himself"
	icon = 'icons/mob/deity.dmi'
	icon_state = "devil"
	icon_living = "devil"
	speak_chance = 0
	turns_per_move = 1
	response_help = "passes through"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	maxHealth = 9999
	health = 9999

	harm_intent_damage = 50
	melee_damage_lower = 50
	melee_damage_upper = 50
	attacktext = "eviscerated"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	min_gas = null
	max_gas = null
	minbodytemp = 0

	faction = "averno"
	supernatural = TRUE
	bodyparts = /decl/simple_animal_bodyparts/faithless

/mob/living/simple_animal/hostile/devil/Initialize(mapload, owner)
	. = ..()
	var/datum/action/cooldown/spell/true_form/tf = new /datum/action/cooldown/spell/true_form()
	tf.ascended = TRUE
	tf.real_owner = owner
	tf.Grant(src)
