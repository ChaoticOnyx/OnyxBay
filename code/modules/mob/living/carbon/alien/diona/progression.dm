/mob/living/carbon/alien/diona/confirm_evolution()
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
