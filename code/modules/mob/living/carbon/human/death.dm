/mob/living/carbon/human/gib(anim, do_gibs)
	if(status_flags & GODMODE)
		return

	visible_message(SPAN("danger", "[src]'s body gets [pick("torn apart", "torn into pieces", "gibbed")]!"), \
					SPAN("moderate", "<b>Your body gets torn apart!</b>"), \
					SPAN("danger", "You hear the sickening sound of somebody getting torn into pieces!"))

	playsound(src, SFX_GIB, 75, 1)
	for(var/obj/item/organ/I in internal_organs)
		I.removed(null, TRUE, TRUE)
		if(!QDELETED(I) && isturf(loc))
			I.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1, 3), 1)

	playsound(src, SFX_FIGHTING_CRUNCH, 75, 1)
	for(var/obj/item/organ/external/E in organs)
		E.droplimb(TRUE, DROPLIMB_EDGE, TRUE, TRUE)

	sleep(1)

	for(var/obj/item/I in src)
		if(I.loc == src) // Belts are dropped after uni removal etc.
			drop(I, force = TRUE)
		if(!QDELETED(I) && isturf(I.loc))
			I.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1, 3), 1)

	gibs(loc, MobDNA = dna, fleshcolor = species.get_flesh_colour(src), bloodcolor = species.get_blood_colour(src))
	..(species.gibbed_anim, FALSE)

/mob/living/carbon/human/dust()
	if(status_flags & GODMODE)
		return
	if(species)
		..(species.dusted_anim, species.remains_type)
	else
		..()

/mob/living/carbon/human/death(gibbed, deathmessage = "seizes up and falls limp...", show_dead_message = "You have died.")

	if(is_ic_dead())
		return

	if(mind?.wizard?.lich)
		mind.wizard.escape_to_lich(mind)

	BITSET(hud_updateflag, HEALTH_HUD)
	BITSET(hud_updateflag, STATUS_HUD)
	BITSET(hud_updateflag, LIFE_HUD)

	//backs up lace if available.
	var/obj/item/organ/internal/stack/s = get_organ(BP_STACK)
	if(s)
		s.do_backup()

	//Handle species-specific deaths.
	species.handle_death(src)

	animate_tail_stop()

	callHook("death", list(src, gibbed))

	if(SSticker.mode)
		sql_report_death(src)
		SSticker.mode.check_win()

	if(wearing_rig)
		wearing_rig.notify_ai("<span class='danger'>Warning: user death event. Mobility control passed to integrated intelligence system.</span>")

	. = ..(gibbed, "no message", show_dead_message) // I don't know why second argument exists, it's not me.
	if(!gibbed)
		handle_organs()
		if(species.death_sound)
			playsound(loc, species.death_sound, 80, 1, 1)
	handle_hud_list()

/mob/living/carbon/human/proc/ChangeToHusk()
	if(MUTATION_HUSK in mutations)
		return

	RemoveHairAndFacials()

	add_mutation(MUTATION_HUSK)
	for(var/obj/item/organ/external/head/h in organs)
		h.status |= ORGAN_DISFIGURED
	update_body(1)
	return

/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	mutations |= MUTATION_HUSK
	return

/mob/living/carbon/human/proc/ChangeToSkeleton()
	if(MUTATION_SKELETON in src.mutations)
		return

	RemoveHairAndFacials()

	add_mutation(MUTATION_SKELETON)
	for(var/obj/item/organ/external/head/h in organs)
		h.status |= ORGAN_DISFIGURED
	update_body(1)
	return

/mob/living/carbon/human/proc/RemoveHairAndFacials()
	if(f_style)
		f_style = "Shaved"
	if(h_style)
		h_style = "Bald"
	update_hair(FALSE)
