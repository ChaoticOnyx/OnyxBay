GLOBAL_LIST_INIT(whitelisted_mmi_species, list(
	SPECIES_HUMAN, SPECIES_TAJARA, SPECIES_VOX,
	SPECIES_UNATHI, SPECIES_SKRELL, SPECIES_MONKEY,
	SPECIES_FARWA, SPECIES_NEAERA, SPECIES_STOK))

/obj/item/organ/internal/cerebrum/mmi
	name = "Man-Machine Interface"
	desc = "A complex life support shell that interfaces between a brain and electronic devices."

	icon = 'icons/mob/human_races/organs/mmi.dmi'
	icon_state = "mmi-empty"

	override_organic_icon = FALSE

	brainmob_type = /mob/living/carbon/brain

	var/locked = FALSE

	var/obj/item/organ/internal/cerebrum/brain/brainobj = null

/obj/item/organ/internal/cerebrum/mmi/New(newLoc, mob/living/carbon/human/old_shell)
	robotize()
	if(istype(old_shell)) _create_brain(old_shell)
	return ..()

/obj/item/organ/internal/cerebrum/mmi/proc/_create_brain(mob/living/carbon/human/brain_owner)
	var/obj/item/organ/internal/cerebrum/brain/new_brain = new(src)

	new_brain.species = brain_owner?.get_species() || pick(GLOB.whitelisted_mmi_species)
	new_brain.update_icon()

	brainobj = new_brain
	locked = TRUE

/obj/item/organ/internal/cerebrum/mmi/Destroy()
	QDEL_NULL(brainobj)
	return ..()

/obj/item/organ/internal/cerebrum/mmi/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/organ/internal/cerebrum/brain))
		try_add_brain(O, user)
		return

	if(brainobj && istype(O, /obj/item/card/id) || istype(O, /obj/item/device/pda))
		try_access(user)

	if(brainmob)
		O.attack(brainmob, user)

/obj/item/organ/internal/cerebrum/mmi/proc/try_add_brain(obj/item/organ/internal/cerebrum/brain/new_brain, mob/user)
	if(!istype(new_brain) || !istype(user))
		return
	if(brainobj || brainmob?.key)
		show_splash_text(user, "already has a brain inside!")
		return
	if(new_brain.damage >= new_brain.max_damage)
		show_splash_text(user, "brain is truly dead!")
		return
	if(!new_brain.brainmob || !(new_brain.species?.name in GLOB.whitelisted_mmi_species))
		show_splash_text(user, "won't fit into device!")
		return
	_add_brain(new_brain, user)
	show_splash_text(user, "sticks brain into device.")
	feedback_inc("cyborg_mmis_filled", 1)

/obj/item/organ/internal/cerebrum/mmi/proc/try_access(mob/user)
	if(!istype(user))
		return
	if(!allowed(user))
		show_splash_text(user, "access denied!")
		return
	if(isnull(brainobj))
		show_splash_text(user, "no suitable brain to lock!")
		return
	locked = !locked
	show_splash_text(user, "device [locked ? "locked" : "unlocked"].")
	update_icon()

/obj/item/organ/internal/cerebrum/mmi/attack_self(mob/user)
	if(locked)
		show_splash_text(user, "brain is clamped into place!")
		return
	_remove_brain()
	show_splash_text_to_viewers("brain ejected.")

/obj/item/organ/internal/cerebrum/mmi/relaymove(mob/user, direction)
	if(user.stat || user.stunned)
		return

	var/obj/item/rig/rig = get_rig()
	if(istype(rig))
		rig.forced_move(direction, user)

	if(istype(loc, /obj/item/integrated_circuit/input/mmi_tank))
		var/obj/item/integrated_circuit/input/mmi_tank/tank = loc
		tank.relaymove(user, direction)

/obj/item/organ/internal/cerebrum/mmi/proc/_add_brain(obj/item/organ/internal/cerebrum/brain/new_brain, mob/user)
	if(!istype(user))
		return
	if(!user.drop(new_brain, src))
		return

	locked = TRUE
	brainobj = new_brain

	_add_brainmob(new_brain)

	update_name()
	update_desc()
	update_icon()

/obj/item/organ/internal/cerebrum/mmi/proc/_add_brainmob(obj/item/organ/internal/cerebrum/brain/new_brain)
	var/mob/living/carbon/brain/new_occupant = new_brain.brainmob
	if(!istype(new_occupant))
		return

	brainmob = new_occupant
	new_brain.brainmob = null
	new_occupant.forceMove(src)
	new_occupant.container = src
	new_occupant.set_stat(CONSCIOUS)
	new_occupant.switch_from_dead_to_living_mob_list()
	new_occupant?.client?.eye = src

	_register_mob_signals()

/obj/item/organ/internal/cerebrum/mmi/proc/_remove_brainmob(obj/item/organ/internal/cerebrum/brain/new_container)
	_unregister_mob_signals()

	var/mob/living/carbon/brain/living_brainmob = brainmob
	living_brainmob.container = null
	living_brainmob.forceMove(new_container)
	living_brainmob.remove_from_living_mob_list()
	living_brainmob?.client?.eye = new_container

	new_container.brainmob = living_brainmob
	brainmob = null

/obj/item/organ/internal/cerebrum/mmi/proc/_drop_brain()
	if(isnull(brainobj))
		return new brainobj(get_turf(src))

	var/obj/item/organ/internal/cerebrum/brain/new_brain
	brainobj.forceMove(get_turf(src))
	new_brain = brainobj
	brainobj = null

	return new_brain

/obj/item/organ/internal/cerebrum/mmi/proc/_remove_brain()
	var/obj/item/organ/internal/cerebrum/brain/new_brain = _drop_brain()

	_remove_brainmob(new_brain)

	update_name()
	update_desc()
	update_icon()

/obj/item/organ/internal/cerebrum/mmi/update_name()
	SetName(isnull(brainmob) ? initial(name) : "[initial(name)]: [brainmob?.real_name]")

/obj/item/organ/internal/cerebrum/mmi/update_desc()
	desc = initial(desc)
	if(brainmob?.is_ic_dead())
		desc += SPAN_DEADSAY("\nScans indicate that \the [brainmob?.name] seems to be dead.")
	else if(brainmob?.ssd_check())
		desc += SPAN_DEADSAY("\nScans indicate that \the [brainmob?.name] seems to be unconscious.")

/obj/item/organ/internal/cerebrum/mmi/update_icon()
	overlays.Cut()
	if(isnull(brainobj))
		icon_state = "mmi-empty"
		return

	icon_state = "mmi-inner"

	var/brain_overlay = "mmi-[lowertext(brainobj?.species)]"
	overlays += (brain_overlay in icon_states(icon)) ? brain_overlay : "mmi-error"

	if(locked)
		overlays += "mmi-lid"

	overlays += "mmi-outer"

	if(brainmob?.is_ic_dead())
		overlays += "mmi-dead"
	else if(brainmob?.ssd_check())
		overlays += "mmi-ssd"
	else
		overlays += "mmi-stable"

	return
