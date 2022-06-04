/decl/appearance_handler
	var/priority = 15
	var/list/appearance_sources

/decl/appearance_handler/New()
	..()
	appearance_sources = list()

/decl/appearance_handler/proc/AddAltAppearance(source, list/images, list/viewers = list())
	if(source in appearance_sources)
		return FALSE
	appearance_sources[source] = new /datum/appearance_data(images, viewers, priority)
	register_signal(source, SIGNAL_QDELETING, /decl/appearance_handler/proc/RemoveAltAppearance)

/decl/appearance_handler/proc/RemoveAltAppearance(source)
	var/datum/appearance_data/ad = appearance_sources[source]
	if(ad)
		unregister_signal(source, SIGNAL_QDELETING)
		appearance_sources -= source
		qdel(ad)

/decl/appearance_handler/proc/DisplayAltAppearanceTo(source, viewer)
	var/datum/appearance_data/ad = appearance_sources[source]
	if(ad)
		ad.AddViewer(viewer)

/decl/appearance_handler/proc/DisplayAllAltAppearancesTo(viewer)
	for(var/entry in appearance_sources)
		DisplayAltAppearanceTo(entry, viewer)
