/obj/item/paper/infernal_contract
	var/contract_type = SIN_SLOTH
	var/mob/living/deity/owner

/obj/item/paper/infernal_contract/Initialize(mapload, owner, contract_type)
	. = ..()
	src.contract_type = contract_type
	src.owner = owner

/obj/item/paper/infernal_contract/attack_self(mob/living/user)
	ASSERT(owner && contract_type)

	var/datum/deity_power/phenomena/conversion/convert_spell = locate(/datum/deity_power/phenomena/conversion) in owner.form.phenomena
	ASSERT(convert_spell)

	if(convert_spell.manifest(user, owner))
		var/datum/deity_form/devil/devil_form = owner.form
		user.add_modifier(/datum/modifier/noattack, origin = owner, additional_params = devil_form.current_devil_shell)
		switch(contract_type)
			if(SIN_LUST)
				ADD_TRAIT(user, /datum/modifier/sin/lust)
				devil_form.grant_spells(user, list(/datum/spell/hand/lust_suggestion))
			if(SIN_GLUTTONY)
				ADD_TRAIT(user, /datum/modifier/sin/gluttony)
				devil_form.grant_spells(user, list(/datum/spell/targeted/gluttony_heal))
			if(SIN_GREED)
				ADD_TRAIT(user, /datum/modifier/sin/greed)
				//devil_form.grant_spells(user, /datum/spell/targeted/gluttony_heal)
			if(SIN_SLOTH)
				//ADD_TRAIT(user, /datum/modifier/sin/greed)
				devil_form.grant_spells(user, list(/datum/spell/hand/build_teleport))
			if(SIN_WRATH)
				ADD_TRAIT(user, /datum/modifier/sin/wrath)
				//devil_form.grant_spells(user, /datum/spell/hand/build_teleport)
			if(SIN_ENVY)
				//ADD_TRAIT(user, /datum/modifier/sin/wrath)
				//devil_form.grant_spells(user, /datum/spell/hand/build_teleport)
			if(SIN_PRIDE)
				ADD_TRAIT(user, TRAIT_FAKEFULLHEALTH)
				devil_form.grant_spells(user, list(/datum/spell/toggled/pride))
