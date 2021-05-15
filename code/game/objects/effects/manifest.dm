/obj/effect/manifest
	name = "manifest"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	unacidable = 1//Just to be sure.

/obj/effect/manifest/New()

	src.invisibility = 101
	return

/obj/effect/manifest/proc/manifest()
	var/dat = "<B>Crew Manifest</B>:<BR>"
	for(var/mob/living/carbon/human/M in SSmobs.mob_list)
		dat += text("    <B>[]</B> -  []<BR>", M.name, M.get_assignment())
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(loc)
	P.set_content(dat, "paper- 'Crew Manifest'", TRUE)
	//SN src = null
	qdel(src)
	return
