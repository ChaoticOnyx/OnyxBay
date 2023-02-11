#define TRAIT_PACIFISM /datum/modifier/trait/pacifism
#define TRAIT_RESISTCOLD /datum/modifier/trait/cold_resist
#define TRAIT_NOSLIPWATER /datum/modifier/trait/noslip
#define TRAIT_TOXINLOVER /datum/modifier/trait/toxinlover
#define TRAIT_RESISTHEATHANDS /datum/modifier/trait/resist_heat_hands

#define ADD_TRAIT(holder,trait_type) holder.add_modifier(trait_type)
#define REMOVE_TRAIT(holder,trait_type) holder.remove_modifiers_of_type(trait_type)
#define HAS_TRAIT(holder,trait_type) holder.has_modifier_of_type(trait_type)
