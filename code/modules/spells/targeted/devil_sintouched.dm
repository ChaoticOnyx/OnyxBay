#define DAMAGE_PER_PUNISH 20

/datum/spell/contractmaster
	name = "Contractmaster 3000"
	desc = "1C: Контракты"
	feedback = "CM"
	school = "inferno"
	invocation_type = SPI_NONE
	spell_flags = 0
	range = 1
	charge_max = 2 SECONDS
	icon_state = "wiz_disint"
	cast_sound = 'sound/effects/squelch2.ogg'

/datum/spell/contractmaster/cast(list/targets, mob/user)
	tgui_interact(user)

/datum/spell/contractmaster/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

/datum/spell/contractmaster/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "InfernalLathe", "Infernal Lathe")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/spell/contractmaster/tgui_data()
	var/list/data = list()
	var/mob/living/user = holder
	if(!istype(user) || !user.mind?.deity)
		return

	for(var/datum/mind/M in user.mind.deity.followers)
		var/mob/living/L = M.current
		if(!istype(L))
			continue


// /datum/spell/targeted/devil_follower/choose_targets(mob/user = usr)
// 	var/mob/living/target = tgui_input_list(user, "Choose the target for the spell.", "Targeting", user.mind?.deity?.followers)
// 	if(!istype(target))
// 		return

// 	return target

// /datum/spell/targeted/devil_follower/punish_sintouched
// 	name = "Punish"
// 	desc = "Punish your follower."
// 	feedback = "PF"
// 	school = "conjuration"

// 	invocation_type = SPI_NONE

// 	spell_flags = SELECTABLE
// 	range = 1
// 	max_targets = 1

// 	charge_max = 15 SECONDS

// 	icon_state = "wiz_disint"

// 	cast_sound = 'sound/effects/squelch2.ogg'

// /datum/spell/targeted/devil_follower/punish_sintouched/cast(mob/living/target, mob/user)
// 	target.adjustFireLoss(DAMAGE_PER_PUNISH)
// 	to_chat(target, SPAN_DANGER("You are being burned by infernal fire!"))
// 	to_chat(target, SPAN_DANGER("You punish \the [user]!"))

// /datum/spell/targeted/devil_follower/reward_sintouched
// 	name = "Reward"
// 	desc = "Reward your follower."
// 	feedback = "RF"
// 	school = "conjuration"

// 	invocation_type = SPI_NONE

// 	spell_flags = SELECTABLE
// 	range = 1
// 	max_targets = 1

// 	charge_max = 30 SECONDS

// 	icon_state = "wiz_disint"

// 	cast_sound = 'sound/effects/squelch2.ogg'

// /datum/spell/targeted/devil_follower/reward_sintouched/cast(mob/living/target, mob/user)
// 	target.adjustBruteLoss(-DAMAGE_PER_PUNISH)
// 	target.adjustFireLoss(-DAMAGE_PER_PUNISH)
// 	target.adjustToxLoss(-DAMAGE_PER_PUNISH)
// 	target.adjustOxyLoss(-DAMAGE_PER_PUNISH)
// 	to_chat(target, SPAN_DANGER("You have been rewarded by your master!"))
// 	to_chat(user, SPAN_DANGER("You reward \the [user]!"))

// #undef DAMAGE_PER_PUNISH
