/mob/living/carbon/
	gender = MALE
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/list/stomach_contents = list()
	var/list/datum/disease2/disease/virus2 = list()
	var/list/antibodies = list()

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	//Surgery info
	var/datum/surgery_status/surgery_status = new()
	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
	//Active emote/pose
	var/pose = null
	var/list/chem_effects = list()
	var/list/chem_traces = list() // Long-lasting "inactive" metabolism products, mostly for analyzing and simulating chemical tolerance
	var/list/chem_doses = list() // "Active" metabolized reagents, cleared as soon as the corresponding reagent leaves the mob's system
	var/datum/reagents/metabolism/bloodstr = null
	var/datum/reagents/metabolism/touching = null
	var/losebreath = 0 //if we failed to breathe last tick

	var/coughedtime = null

	var/cpr_time = 1.0
	var/lastpuke = 0
	var/nutrition = 400
	var/last_nutrition_speed_update

	var/obj/item/tank/internal = null//Human/Monkey


	//these two help govern taste. The first is the last time a taste message was shown to the plaer.
	//the second is the message in question.
	var/last_taste_time = 0
	var/last_taste_text = ""

	// organ-related variables, see organ.dm and human_organs.dm
	var/list/internal_organs = list()
	var/list/organs = list()
	var/list/organs_by_name = list() // map organ names to organs
	var/list/internal_organs_by_name = list() // so internal organs have less ickiness too

	var/list/stasis_sources = list()
	var/stasis_value
	var/does_not_breathe = FALSE
	var/seeDarkness = FALSE
	can_use_hands = TRUE // use only for short-term restrictions (climbing in ventilation, being in stasis, etc.)
