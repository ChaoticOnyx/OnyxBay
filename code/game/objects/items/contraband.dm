//Let's get some REAL contraband stuff in here. Because come on, getting brigged for LIPSTICK is no fun.

//Illicit drugs~
/obj/item/storage/pill_bottle/happy
	name = "bottle of Happy pills"
	desc = "Highly illegal drug. When you want to see the rainbow."

/obj/item/storage/pill_bottle/happy/Initialize()
	..()
	new /obj/item/reagent_containers/pill/happy(src)
	new /obj/item/reagent_containers/pill/happy(src)
	new /obj/item/reagent_containers/pill/happy(src)
	new /obj/item/reagent_containers/pill/happy(src)
	new /obj/item/reagent_containers/pill/happy(src)
	new /obj/item/reagent_containers/pill/happy(src)
	new /obj/item/reagent_containers/pill/happy(src)

/obj/item/storage/pill_bottle/zoom
	name = "bottle of Zoom pills"
	desc = "Highly illegal drug. Trade brain for speed."

/obj/item/storage/pill_bottle/zoom/Initialize()
	..()
	new /obj/item/reagent_containers/pill/zoom(src)
	new /obj/item/reagent_containers/pill/zoom(src)
	new /obj/item/reagent_containers/pill/zoom(src)
	new /obj/item/reagent_containers/pill/zoom(src)
	new /obj/item/reagent_containers/pill/zoom(src)
	new /obj/item/reagent_containers/pill/zoom(src)
	new /obj/item/reagent_containers/pill/zoom(src)

/obj/item/reagent_containers/vessel/beaker/vial/random
	atom_flags = 0
	var/list/random_reagent_list = list(list(/datum/reagent/water = 15) = 1, list(/datum/reagent/space_cleaner = 15) = 1)

/obj/item/reagent_containers/vessel/beaker/vial/random/toxin
	random_reagent_list = list(
		list(/datum/reagent/mindbreaker = 10, /datum/reagent/space_drugs = 20) = 3,
		list(/datum/reagent/toxin/carpotoxin = 15)                             = 2,
		list(/datum/reagent/impedrezene = 15)                                  = 2,
		list(/datum/reagent/toxin/zombiepowder = 10)                           = 1)

/obj/item/reagent_containers/vessel/beaker/vial/random/Initialize()
	. = ..()
	if(is_open_container())
		atom_flags ^= ATOM_FLAG_OPEN_CONTAINER

	var/list/picked_reagents = util_pick_weight(random_reagent_list)
	for(var/reagent in picked_reagents)
		reagents.add_reagent(reagent, picked_reagents[reagent])

	var/list/names = new
	for(var/datum/reagent/R in reagents.reagent_list)
		names += R.name

	desc = "Contains [english_list(names)]."
	update_icon()

/// Rev Book
/obj/item/book/rev
	name = "Veridical Chronicles of NanoTrasen"
	icon_state = "bookrev"
	desc = "A rather shabby book with a crossed-out NT logo on its cover."
	w_class = 2
	unique = 1
	attack_verb = list("bashed", "whacked", "revoluted", "enlightened", "propagandized", "promulgated")
	var/list/readers = list()
	var/list/subjects = list()

/obj/item/book/rev/attack_self(mob/user)
	if(carved)
		if(!store)
			to_chat(user, SPAN("notice", "The pages of [title] have been cut out!"))
			return
		to_chat(user, SPAN("notice", "[store] falls out of [title]!"))
		store.dropInto(get_turf(loc))
		store = null
		return

	if(!user.IsAdvancedToolUser())
		to_chat(user, SPAN("notice", "You have absolutely no interest in history at all, and this book in particular."))
		return

	for(var/i in 1 to 5)
		if(!do_after(user, 6 SECOND, src, luck_check_type = LUCK_CHECK_COMBAT))
			to_chat(user, SPAN("warning", "Your reading has been interrupted."))
			return
		subjects.Cut()
		subjects = list(
			"the assassinations of independent press journalists",
			"trumped-up criminal cases",
			"lethal repression of peaceful protests",
			"the genocide of [pick("xenoraces", "tajaran", "unathi")]" = 2,
			"NanoTrasen killing own employees",
			"NanoTrasen [pick("getting involved in", "taking part in", "organizing", "establishing", "lobbying")] [pick("human", "drug", "arms")] trafficking" = 4,
			"a high-ranking NT employee revealed to be a [pick("rapist", "cannibal", "pervert", "murderer", "paedophile")]" = 3,
			"the surreptitious executions",
			"biological weapons [pick("usage", "trafficking", "development")]",
			"NanoTrasen security officers murdering [pick("", "tiny ", "cute ")][pick("kittens", "puppies")]",
			"[pick("illegal", "unethical")] experiments on [pick("humans", "employees")]" = 2,
			"the Death Squad activity",
			"a high-ranking NT employee stealing money from a charitable foundation",
			"NT using [pick("troops without insignia", "mercenaries")] to take over a [pick("neutral", "ally", "peaceful")] [pick("planet", "company", "system")]" = 2
		)
		to_chat(user, "You read about [util_pick_weight(subjects)] [pick("in", "in the year")] [rand(2125, 2564)].")

	if((user.real_name in readers) || player_is_antag(user.mind))
		to_chat(user, SPAN("notice", "You didn't learn anything new after the reading."))
		return

	readers.Add(user.real_name)
	if(!GLOB.revs.can_become_antag(user.mind, 1) || prob(50))
		to_chat(user, SPAN("notice", "You have resisted the influence of this propaganda [pick("pulp", "fiction", "nonsense", "bullshit")]."))
		return

	to_chat(user, SPAN("notice", "<b>Enough. This regime must be overthrown!</b>"))
	GLOB.revs.add_antagonist_mind(user.mind, 1, GLOB.revs.faction_role_text, GLOB.revs.faction_welcome)
