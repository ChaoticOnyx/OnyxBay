#define TRAIT_PACIFISM 			/datum/modifier/trait/pacifism
#define TRAIT_COLDRESIST 		/datum/modifier/trait/cold_resist
#define TRAIT_NOSLIP 			/datum/modifier/trait/noslip
#define TRAIT_TOXINLOVER 		/datum/modifier/trait/toxinlover
#define TRAIT_RESISTHEATHANDS 	/datum/modifier/trait/resist_heat_hands
#define TRAIT_METROIDRECALL 	/datum/modifier/status_effect/metroidrecall
#define TRAIT_NOBLOOD 			/datum/modifier/trait/noblood
#define TRAIT_BLOOD_DEFICIENCY 	/datum/modifier/trait/blooddeficiency
#define TRAIT_RADIMMUNE 		/datum/modifier/trait/radimmune
#define TRAIT_HOLY 				/datum/modifier/trait/holy
#define TRAIT_ANTIMAGIC 		/datum/modifier/trait/magicimmune
#define TRAIT_GHOSTATTACKABLE 	/datum/modifier/status_effect/ghostattackable  //Used for wizard's spell "No remorse" which allows ghosts to attack target
#define TRAIT_FAKEFULLHEALTH    /datum/modifier/fake_full_health

#define ADD_TRAIT(holder,trait_type) 	holder.add_modifier(trait_type)
#define REMOVE_TRAIT(holder,trait_type) holder.remove_modifiers_of_type(trait_type)
#define HAS_TRAIT(holder,trait_type) 	holder.has_modifier_of_type(trait_type)
