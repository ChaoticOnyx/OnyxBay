/obj/item/implant/pacifism
	name = "pacifism implant"
	desc = "Put this into somebody who punches people more often than you'd prefer."
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 2, TECH_ILLEGAL = 2)
	known = FALSE
	var/mob/living/holder
	var/datum/modifier/trait/pacifism/pacifism_trait

/obj/item/implant/pacifism/get_data()
	return {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> P-03 Internal Pacifier Prototype<BR>
	<b>Life:</b> 1-3 months<BR>
	<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
	<HR>
	<b>Implant Details:</b> <BR>
	<b>Function:</b> Suppresses violent actions in the subject.<BR>
	<b>Special Features:</b> Upon implantation, establishes a connection to the subject's nervous system.
	This allows the device to analyze and selectively suppress nerve signals
	connected to most actions with a violent intent.
	The implant's long-term lifetime is relatively short due to the complexity of its systems,
	and may vary depending on the subject's capability to adapt.
	However, influence within 48 hours after implantation is extremely effective."}

/obj/item/implant/pacifism/implanted(mob/living/source)
	if(!istype(source))
		return FALSE
	holder = source
	pacifism_trait = ADD_TRAIT(holder, TRAIT_PACIFISM)
	if(!pacifism_trait) // They might already be a pacifist (loadout/harmban), so the implant won't do much.
		holder.visible_message(SPAN_NOTICE("[holder]'s behaviour doesn't seem to shift at all after getting implanted..."),
							   SPAN_NOTICE("You feel something try to suppress violence in you... but you're a pacifist already. It can't find much to suppress."))
		return FALSE
	pacifism_trait.innate = FALSE
	return TRUE

/obj/item/implant/pacifism/removed()
	if(!QDELETED(holder) && pacifism_trait && !pacifism_trait.innate)
		REMOVE_TRAIT(holder, TRAIT_PACIFISM)
	pacifism_trait = null
	holder = null
	return ..()

/obj/item/implanter/pacifism
	name = "implanter (P)"
	imp = /obj/item/implant/pacifism

/obj/item/implantcase/pacifism
	name = "glass case - 'pacifier'"
	imp = /obj/item/implant/pacifism
