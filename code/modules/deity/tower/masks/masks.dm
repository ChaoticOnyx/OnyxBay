/obj/item/clothing/mask/deity_mask
	name = "Abyssal Mask"
	desc = "A mask created from the suffering of existence. Looking down it's eyes, you notice something gazing back at you."
	icon_state = "deitymask"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	body_parts_covered = FACE|EYES
	w_class = ITEM_SIZE_NORMAL

	/// Ref to a wearer of this mask
	var/mob/living/carbon/human/wearer
	/// Weakref to a linked deity
	var/weakref/linked_deity

	/// Amount of agony delivered on mask removal
	var/agony_amount = 75
	/// Amount of agony delivered on mask removal
	var/stun_amount = 6
	/// Minimal amount of braindamage taken on mask removal
	var/braindamage_min = 5
	/// Max amount of braindamage taken on mask removal
	var/braindamage_max

	var/list/debuff_modifiers = list()
	var/list/buff_modifiers = list()
	var/list/buff_spells = list()

/obj/item/clothing/mask/deity_mask/Destroy()
	wearer = null
	linked_deity = null
	return ..()

/obj/item/clothing/mask/deity_mask/equipped(mob/user, slot)
	. = ..()

	if(slot == slot_wear_mask && ishuman(user) && user.mind)
		wearer = user
		to_chat(user, SPAN_DANGER("\The [src] clamps tightly to your face as you feel your soul draining away!"))
		give_debuffs(user)
		var/mob/living/deity/D = linked_deity?.resolve()
		if(istype(D) && IS_DEITYSFOLLOWER(D, user))
			give_buffs(user)

/// For giving debuffs. Called on 'equipped()'.
/obj/item/clothing/mask/deity_mask/proc/give_debuffs(mob/living/user)
	if(!islist(debuff_modifiers))
		return

	for(var/mod in debuff_modifiers)
		ADD_TRAIT(user, mod)

/// For giving buffs. Called on 'equipped()'.
/obj/item/clothing/mask/deity_mask/proc/give_buffs(mob/living/user)
	if(islist(buff_spells))
		var/mob/living/deity/linked_d = linked_deity?.resolve()
		for(var/mod in buff_spells)
			var/datum/spell/new_spell = new mod()
			user.add_spell(new_spell, deity = linked_d)

	if(islist(buff_modifiers))
		for(var/mod in buff_modifiers)
			ADD_TRAIT(user, mod)

/// For removing debuffs. Called on 'dropped()'.
/obj/item/clothing/mask/deity_mask/proc/remove_debuffs(mob/living/user)
	if(!islist(debuff_modifiers))
		return

	for(var/mod in debuff_modifiers)
		REMOVE_TRAIT(user, mod)

/// For removing buffs. Called on 'dropped()'.
/obj/item/clothing/mask/deity_mask/proc/remove_buffs(mob/living/user)
	if(islist(buff_spells))
		for(var/mod in buff_spells)
			user.remove_spell(mod)

	if(islist(buff_modifiers))
		for(var/mod in buff_modifiers)
			REMOVE_TRAIT(user, mod)

/obj/item/clothing/mask/deity_mask/can_be_unequipped_by(mob/user, slot, disable_warning)
	if(user == wearer && slot == slot_wear_mask) // Nope
		return FALSE

	return ..()

/obj/item/clothing/mask/deity_mask/dropped(mob/user)
	if(wearer == loc) // Just in case something went awry
		remove_buffs(user)
		remove_debuffs(user)
		var/mob/living/deity/D = linked_deity?.resolve()
		if(IS_DEITYSFOLLOWER(D, user))

		else // Removing this mask from a non-cultist damages one's body and soul.
			//Since ancient greeks were wrong and there are no souls, brain takes damage.
			var/obj/item/organ/internal/cerebrum/brain/brain = wearer.internal_organs_by_name[BP_BRAIN]
			if(istype(brain))
				brain.take_general_damage(rand(braindamage_min, braindamage_max))
				wearer.handle_tasing(agony_amount, stun_amount, BP_HEAD, src)
				wearer.emote("scream_long")

	wearer = null
	return ..()

/obj/item/clothing/mask/deity_mask/vengeance
	name = "Mask of Vengeance"
	debuff_modifiers = list(/datum/modifier/deitymask_debuff/vengeance)
	buff_spells = list(/datum/spell/vengeance)

/obj/item/clothing/mask/deity_mask/terror
	name = "Mask of Terror"
	debuff_modifiers = list(/datum/modifier/deitymask_debuff/terror)
	buff_spells = list(/datum/spell/curse_of_terror)

/obj/item/clothing/mask/deity_mask/regret
	name = "Mask of Regret"
	debuff_modifiers = list(/datum/modifier/deitymask_debuff/regret)

/obj/item/clothing/mask/deity_mask/servitude
	name = "Mask of Servitude"
