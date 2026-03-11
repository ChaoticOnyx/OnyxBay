/mob/living/carbon/larva/diona/confirm_evolution()

	if(!is_species_whitelisted(src, SPECIES_DIONA))
		to_chat(src, alert("You are currently not whitelisted to play as a full diona."))
		return null

	if(amount_grown < max_grown)
		to_chat(src, "You are not yet ready for your growth...")
		return null

	src.split()

	if(istype(loc, /obj/item/holder/diona))
		var/obj/item/holder/diona/H = loc
		src.forceMove(get_turf(H))
		qdel(H)

	src.visible_message(
	    SPAN("warning", "\The [src] begins to shift and quiver, and erupts in a shower of shed bark as it splits into a tangle of nearly a dozen new dionaea."),
	    SPAN("warning", "You begin to shift and quiver, feeling your awareness splinter. All at once, we consume our stored nutrients to surge with growth, splitting into a tangle of at least a dozen new dionaea. We have attained our gestalt form.")
	)
	return SPECIES_DIONA
