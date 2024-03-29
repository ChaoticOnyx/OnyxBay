/datum/spell/toggled/transform
	name = "False form"
	desc = "Reveal your false form"
	invocation = "none"
	invocation_type = SPI_NONE
	need_target = FALSE
	icon_state = "undead_lichform"
	mana_regen_per_tick = 10
	mana_max = 50
	charge_max = 50

	var/datum/icon_snapshot/original_snap

/datum/spell/toggled/transform/New()
	charge_counter = mana_max
	mana_current = mana_max

/datum/spell/toggled/transform/think()
	if(mana_current < mana_max)
		mana_current = min(mana_max, mana_current + mana_regen_per_tick)
		charge_counter = mana_current
		update_screen_button()
	else
		return

	set_next_think(world.time + 1 SECOND)


/datum/spell/toggled/transform/check_charge(skipcharge, mob/user)
	if(!skipcharge)
		switch(charge_type)
			if(SP_RECHARGE)
				if(mana_current < mana_max)
					to_chat(user, still_recharging_msg)
					return FALSE
	return TRUE

/datum/spell/toggled/transform/activate()
	if(mana_current < mana_max)
		toggled = FALSE
		return FALSE
	var/mob/living/H = holder
	if(original_snap == null)
		original_snap = copy_snap(H)
	var/datum/click_handler/wizard/transform/C = H.PushClickHandler(/datum/click_handler/wizard/transform)
	if(!istype(C))
		return
	C.set_spell(src)
	to_chat(H, SPAN("danger", "Select target!"))
	return TRUE

/datum/spell/toggled/transform/deactivate(no_message = TRUE)
	if(original_snap != null)
		set_snap(original_snap)
	var/mob/living/H = holder
	H.PopClickHandler()
	mana_current = 0
	charge_counter = 0
	set_next_think(world.time + 1 SECOND)
	. = ..()
	if(!.)
		return

/datum/spell/toggled/transform/proc/cast_copy(mob/living/target)
	var/mob/living/H = holder
	var/datum/icon_snapshot/target_snap = copy_snap(target)
	set_snap(target_snap)
	H.PopClickHandler()

/datum/spell/toggled/transform/proc/copy_snap(mob/living/target)
	var/mob/living/H = target
	var/datum/icon_snapshot/entry = new
	entry.real_name = H.real_name
	entry.name = H.name
	entry.icon = H.icon
	entry.examine = H.examine(H)
	entry.icon_state = H.icon_state
	entry.overlays = H.overlays.Copy()
	return entry

/datum/spell/toggled/transform/proc/set_snap(datum/icon_snapshot/snap)
	var/mob/living/H = holder
	if(H.name != snap.name)
		playsound(get_turf(H), 'sound/effects/blob/blobweld.ogg', 50, 1)
		anim(get_turf(H), H,'icons/mob/modifier_effects.dmi',,"pink_sparkles",,H.dir)
		H.real_name = snap.real_name
		H.name = snap.name
		H.icon = snap.icon
		H.icon_state = snap.icon_state
		H.desc = snap.examine
		H.overlays.Cut()
		H.overlays = snap.overlays.Copy()
		H.update_inv_l_hand()
		H.update_inv_r_hand()
