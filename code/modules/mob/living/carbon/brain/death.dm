/mob/living/carbon/brain/death(gibbed)
	if(!gibbed && istype(container, /obj/item/organ/internal/cerebrum/mmi)) //If not gibbed but in a container.
		return ..(gibbed, "beeps shrilly as the MMI flatlines!")
	else
		return ..(gibbed, "no message")

/mob/living/carbon/brain/gib(anim, do_gibs)
	if(istype(container, /obj/item/organ/internal/cerebrum/mmi))
		qdel(container)//Gets rid of the MMI if there is one
	if(istype(loc, /obj/item/organ/internal/cerebrum/brain))
		qdel(loc)//Gets rid of the brain item
	return ..(null, FALSE)
