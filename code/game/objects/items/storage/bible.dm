/obj/item/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state = "bible"
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = 4
	var/mob/affecting = null
	var/deity_name = "Christ"

/obj/item/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state = "bible"

	startswith = list(
		/obj/item/reagent_containers/vessel/bottle/small/beer,
		/obj/item/spacecash/bundle/c50,
		/obj/item/spacecash/bundle/c50,
		)

/obj/item/storage/bible/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(target)
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		if(ishuman(target))
			var/mob/living/carbon/human/human_target = target
			if(prob(10))
				human_target.adjustBrainLoss(5)
				to_chat(human_target, SPAN("warning", "You feel dumber."))
				visible_message(SPAN("warning", "[user] beats [human_target] over the head with \the [src]!"))
			else
				human_target.visible_message(SPAN("warning", "[user] heals [human_target] with the power of [src.deity_name]!"), \
											 SPAN("warning", "May the power of [src.deity_name] compel you to be healed!"))
				human_target.heal_overall_damage(20,20)
			playsound(src.loc, SFX_FIGHTING_PUNCH, 25, 1, -1)
		else
			if(target.reagents && target.reagents.has_reagent(/datum/reagent/water)) //blesses all the water in the holder
				to_chat(user, SPAN("notice", "You bless \the [target]."))
				var/water2holy = target.reagents.get_reagent_amount(/datum/reagent/water)
				target.reagents.del_reagent(/datum/reagent/water)
				target.reagents.add_reagent(/datum/reagent/water/holywater,water2holy)

/obj/item/storage/bible/attackby(obj/item/W, mob/user)
	if(src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)
	return ..()
