//Various types of colorblindness	R2R		R2G		R2B		G2R		G2G		G2B		B2R		B2G		B2B
#define MATRIX_Monochromia      list(0.33,	0.33,	0.33,	0.59,	0.59,	0.59,	0.11,	0.11,	0.11)
#define MATRIX_Protanopia       list(0.57,	0.43, 	0,		0.56, 	0.44, 	0, 		0, 		0.24,	0.76)
#define MATRIX_Protanomaly      list(0.82,	0.18, 	0,		0.33,	0.67, 	0, 		0, 		0.13,	0.88)
#define MATRIX_Deuteranopia     list(0.63,	0.38, 	0,		0.70, 	0.30, 	0, 		0, 		0.30, 	0.70)
#define MATRIX_Deuteranomaly    list(0.80, 	0.20, 	0,		0.26,	0.74,	0, 		0, 		0.14,	0.86)
#define MATRIX_Tritanopia       list(0.95, 	0.05, 	0,		0,		0.43, 	0.57,	0, 		0.48, 	0.53)
#define MATRIX_Tritanomaly      list(0.97,	0.03, 	0,		0,		0.73, 	0.27,	0, 		0.18,	0.82)
#define MATRIX_Achromatopsia    list(0.30,	0.59, 	0.11, 	0.30, 	0.59, 	0.11, 	0.30, 	0.59, 	0.11)
#define MATRIX_Achromatomaly    list(0.62,	0.32, 	0.06, 	0.16, 	0.78, 	0.06, 	0.16, 	0.32, 	0.52)
#define MATRIX_Vulp_Colorblind  list(0.50,	0.40,	0.10,	0.50,	0.40,	0.10,	0,		0.20,	0.80)
#define MATRIX_Taj_Colorblind   list(0.40,	0.20,	0.40,	0.40,	0.60,	0,		0.20,	0.20,	0.60)


/datum/modifier/trait
	flags = MODIFIER_GENETIC	// We want traits to persist if the person gets cloned.


/datum/modifier/trait/flimsy
	name = "flimsy"
	desc = "You're more fragile than most, and have less of an ability to endure harm."

	on_created_text = "<span class='warning'>You feel rather weak.</span>"
	on_expired_text = "<span class='notice'>You feel your strength returning to you.</span>"

	max_health_percent = 0.8

/datum/modifier/trait/frail
	name = "frail"
	desc = "Your body is very fragile, and has even less of an ability to endure harm."

	on_created_text = "<span class='warning'>You feel really weak.</span>"
	on_expired_text = "<span class='notice'>You feel your strength returning to you.</span>"

	max_health_percent = 0.6

/datum/modifier/trait/weak
	name = "weak"
	desc = "A lack of physical strength causes a diminshed capability in close quarters combat"

	outgoing_melee_damage_percent = 0.8

/datum/modifier/trait/wimpy
	name = "wimpy"
	desc = "An extreme lack of physical strength causes greatly diminished capability in close quarters combat."

	outgoing_melee_damage_percent = 0.6

/datum/modifier/trait/haemophilia
	name = "haemophilia"
	desc = "You bleed much faster than average."

	bleeding_rate_percent = 3.0

/datum/modifier/trait/inaccurate
	name = "Inaccurate"
	desc = "You're rather inexperienced with guns, you've never used one in your life, or you're just really rusty.  \
	Regardless, you find it quite difficult to land shots where you wanted them to go."

	accuracy = -15
	accuracy_dispersion = 1

/datum/modifier/trait/high_metabolism
	name = "High Metabolsim"
	desc = "Your body's metabolism is faster than average."

	metabolism_percent = 2.0
	incoming_healing_percent = 1.4

/datum/modifier/trait/low_metabolism
	name = "Low Metabolism"
	desc = "Your body's metabolism is slower than average."

	metabolism_percent = 0.5
	incoming_healing_percent = 0.6

/datum/modifier/trait/colorblind_protanopia
	name = "Protanopia"
	desc = "You have a form of red-green colorblindness. You cannot see reds, and have trouble distinguishing them from yellows and greens."

	client_color = MATRIX_Protanopia

/datum/modifier/trait/colorblind_deuteranopia
	name = "Deuteranopia"
	desc = "You have a form of red-green colorblindness. You cannot see greens, and have trouble distinguishing them from yellows and reds."

	client_color = MATRIX_Deuteranopia

/datum/modifier/trait/colorblind_tritanopia
	name = "Tritanopia"
	desc = "You have a form of blue-yellow colorblindness. You have trouble distinguishing between blues, greens, and yellows, and see blues and violets as dim."

	client_color = MATRIX_Tritanopia

/datum/modifier/trait/colorblind_taj
	name = "Colorblind - Blue-red"
	desc = "You are colorblind. You have a minor issue with blue colors and have difficulty recognizing them from red colors."

	client_color = MATRIX_Taj_Colorblind

/datum/modifier/trait/colorblind_vulp
	name = "Colorblind - Red-green"
	desc = "You are colorblind. You have a severe issue with green colors and have difficulty recognizing them from red colors."

	client_color = MATRIX_Vulp_Colorblind

/datum/modifier/trait/colorblind_monochrome
	name = "Monochromacy"
	desc = "You are fully colorblind. Your condition is rare, but you can see no colors at all."

	client_color = MATRIX_Monochromia

/datum/modifier/trait/stammering
	name = "Stutterer"
	desc = "Its a speech disorder in which the flow of speech is disrupted by involuntary repetitions and prolongations of sounds, syllables, words or phrases as well as involuntary silent pauses or blocks in which the person who stutters is unable to produce sounds."

	stammering = TRUE

/datum/modifier/trait/burrieng
	name = "Burry"
	desc = "You have a speech impediment - you do not pronounce some sounds."

	burrieng = TRUE

/datum/modifier/trait/lisping
	name = "Lisp"
	desc = "A lisp is a speech impediment in which a person misarticulates sibilants."

	lisping = TRUE

/datum/modifier/trait/vent_breaker
	name = "Vent Breaker"
	desc = "Allows to break welded vents."
	var/ignore_size_restrictions = FALSE
	hidden = TRUE

//Responsible for processing the audibility of sounds depending on the volume of the headphones
/datum/modifier/trait/headphones_volume
	name = "Headphones Volume"
	desc = "Changes the audibility depending on the volume of the music"

	var/volume_status = LOW_VOLUME

/datum/modifier/trait/pacifism
	name = "Pacifism"
	desc = "You can't attack!"

/datum/modifier/trait/pacifism/on_applied()
	holder.a_intent_change(I_HELP)

/datum/modifier/trait/cold_resist
	name = "Cold Resistance"
	desc = "You don't feel cold!"

/datum/modifier/trait/cold_resist/on_applied()
	holder.add_mutation(MUTATION_COLD_RESISTANCE)

/datum/modifier/trait/cold_resist/on_expire()
	holder.remove_mutation(MUTATION_COLD_RESISTANCE)

/datum/modifier/trait/noslip
	name = "No Slip"
	desc = "You can't slip!"

/datum/modifier/trait/toxinlover
	incoming_tox_damage_percent = -0.2

/datum/modifier/trait/resist_heat_hands
	incoming_fire_damage_percent = 0.2

/datum/modifier/trait/blooddeficiency
	name = "Blood Deficiency"
	desc = "Your body can't produce enough blood to sustain itself."
	var/min_blood = BLOOD_VOLUME_BAD // just barely survivable without treatment


/datum/modifier/trait/blooddeficiency/on_applied()
	if(!ishuman(holder))
		return

	// for making sure the roundstart species has the right blood pack sent to them
	var/mob/living/carbon/human/carbon_target = holder
	carbon_target.dna.b_type = "O-"

/datum/modifier/trait/blooddeficiency/proc/lose_blood()
	if(holder.stat == DEAD)
		return

	if(!ishuman(holder))
		return

	var/mob/living/carbon/human/carbon_target = holder
	if(carbon_target.species.species_flags & SPECIES_FLAG_NO_BLOOD) //can't lose blood if your species doesn't have any
		return

	if (carbon_target.get_blood_volume() == min_blood)
		return

	if (carbon_target.get_blood_volume() < min_blood)
		carbon_target.regenerate_blood(carbon_target.species.blood_volume*min_blood - carbon_target.get_blood_volume_abs())
		return
	// Ensures that we don't reduce total blood volume below min_blood.
	carbon_target.remove_blood(1.525 * 0.1)

/datum/modifier/trait/radimmune
	name = "Radiation Immunity"
	desc = "You're immune to radiation"

/datum/modifier/trait/holy
	name = "Holy"
	desc = "You're immune to cult magic and evil spirits"

/datum/modifier/trait/magicimmune
	name = "Magic Immunity"
	desc = "You're immune to magic"

/datum/modifier/fake_full_health
	name = "Fake Full Health"
	hidden = TRUE
