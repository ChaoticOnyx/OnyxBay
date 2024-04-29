/mob/observer/ghost/DblClickOn(atom/A, params)
	if(can_reenter_corpse && mind && mind.current)
		if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
			reenter_corpse()						// (cloning scanner, body bag, closet, mech, etc)
			return

	// Things you might plausibly want to follow
	if(ismovable(A))
		ManualFollow(A)

	// Otherwise jump
	else if(A.loc)
		forceMove(get_turf(A))

/mob/observer/ghost/ClickOn(atom/A, params)
	if(!canClick())
		return

	setClickCooldown(DEFAULT_QUICK_COOLDOWN)

	// You are responsible for checking config.ghost.ghost_interaction when you override this function
	// Not all of them require checking, see below
	var/list/modifiers = params2list(params)
	if(modifiers["alt"])
		var/target_turf = get_turf(A)
		if(target_turf)
			AltClickOn(target_turf)

	if(modifiers["shift"])
		if(!inquisitiveness)
			examinate(A)

	A.attack_ghost(src)

// Oh by the way this didn't work with old click code which is why clicking shit didn't spam you
/atom/proc/attack_ghost(mob/observer/ghost/user)
	if(!istype(user))
		return
	if(user.client)
		if(user.gas_scan)
			print_atmos_analysis(user, atmosanalyzer_scan(src))
		if(user.chem_scan)
			reagent_scanner_scan(user, src)
		if(user.rads_scan)
			var/dose = SSradiation.get_total_absorbed_dose_at_turf(get_turf(src), AVERAGE_HUMAN_WEIGHT)
			to_chat(user, EXAMINE_BLOCK(SPAN_NOTICE("Radiation: [fmt_siunit(dose, "Gy/s", 3)].")))
		if(user.inquisitiveness)
			user.examinate(src)
	return

/mob/living/attack_ghost(mob/observer/ghost/user)
	if(user.client && user.health_scan)
		show_browser(user, medical_scan_results(src, TRUE), "window=scanconsole;size=430x350")
	return ..()

// ---------------------------------------
// And here are some good things for free:
// Now you can click through portals, wormholes, gateways, and teleporters while observing. -Sayu

/obj/machinery/teleporter_gate/attack_ghost(mob/user)
	if(isnull(console))
		return

	var/atom/target_atom = console.target_ref.resolve()
	if(isnull(target_atom))
		return

	user.forceMove(get_turf(target_atom))

/obj/effect/portal/attack_ghost(mob/user)
	if(target)
		user.forceMove(get_turf(target))

/obj/machinery/gateway/centerstation/attack_ghost(mob/user)
	if(awaygate)
		user.forceMove(awaygate.loc)
	else
		to_chat(user, "[src] has no destination.")

/obj/machinery/gateway/centeraway/attack_ghost(mob/user)
	if(stationgate)
		user.forceMove(stationgate.loc)
	else
		to_chat(user, "[src] has no destination.")

// -------------------------------------------
// This was supposed to be used by adminghosts
// I think it is a *terrible* idea
// but I'm leaving it here anyway
// commented out, of course.
/*
/atom/proc/attack_admin(mob/user)
	if(!user || !user.client || !user.client.holder)
		return
	attack_hand(user)

*/
