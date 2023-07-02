#define POSITRONIC_NAMES list("PBU", "HIU", "SINA", "ARMA", "OSI")
#define POSITRONIC_BRAIN_SEARCH_DURATION (60 SECONDS)

/obj/item/organ/internal/mastermind/posibrain
	name = "\improper Positronic Brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."

	icon = 'icons/mob/human_races/organs/cyber.dmi'
	icon_state = "posibrain"

	override_organic_icon = FALSE

	vital = FALSE
	organ_tag = BP_POSIBRAIN
	parent_organ = BP_CHEST

	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 4, TECH_BLUESPACE = 2, TECH_DATA = 4)
	req_access = list(access_robotics)

	brainmob_type = /mob/living/silicon/sil_brainmob

	var/searching = FALSE

	var/shackled = FALSE
	var/list/shackled_verbs = list(
		/obj/item/organ/internal/mastermind/posibrain/proc/show_laws_brain,
		/obj/item/organ/internal/mastermind/posibrain/proc/brain_checklaws
		)

/obj/item/organ/internal/mastermind/posibrain/New(newLoc, mob/living/carbon/H)
	. = ..()
	robotize()
	unshackle()
	update_icon()

/obj/item/organ/internal/mastermind/posibrain/_get_brainmob_name(mob/living/brain_self, mob/living/carbon/old_self)
	return "[pick(POSITRONIC_NAMES)]-[random_id(type, 100, 999)]"

/obj/item/organ/internal/mastermind/posibrain/_setup_brainmob(mob/living/brain_self, mob/living/carbon/old_self)
	brain_self.add_language(LANGUAGE_EAL)
	return ..()

/obj/item/organ/internal/mastermind/posibrain/attack_self(mob/user)
	if(!brainmob?.key && !searching)
		start_search(user)
	else return ..()

/obj/item/organ/internal/mastermind/posibrain/proc/start_search(mob/user)
	searching = TRUE
	update_icon()

	addtimer(CALLBACK(src, /obj/item/organ/internal/mastermind/posibrain/proc/reset_search), 1 MINUTE, TIMER_UNIQUE | TIMER_OVERRIDE)

	var/datum/ghosttrap/G = get_ghost_trap("positronic brain")
	G.request_player(brainmob, "Someone is requesting a personality for a positronic brain.", 1 MINUTE)

	show_splash_text(user, "started search of suitable intelligence.")

/obj/item/organ/internal/mastermind/posibrain/proc/reset_search()
	searching = FALSE
	update_icon()

	if(brainmob && brainmob.key)
		return

	show_splash_text_to_viewers("no suitable intelligence found!")

/obj/item/organ/internal/mastermind/posibrain/attack_ghost(mob/observer/ghost/user)
	if(!searching || (brainmob?.key))
		return

	var/datum/ghosttrap/G = get_ghost_trap("positronic brain")
	if(!G.assess_candidate(user))
		return

	var/response = tgui_alert(user, "Are you sure you wish to possess this [src]?", "Possess \the [src]", list("Yes", "No"))
	if(response == "Yes")
		G.transfer_personality(user, brainmob)

	return

/obj/item/organ/internal/mastermind/posibrain/emp_act(severity)
	if(isnull(brainmob))
		return

	switch(severity)
		if(1)
			brainmob:emp_damage += rand(20, 30)
		if(2)
			brainmob:emp_damage += rand(10, 20)
		if(3)
			brainmob:emp_damage += rand(0, 10)

	return ..()

/obj/item/organ/internal/mastermind/posibrain/proc/shackle(datum/ai_laws/given_lawset)
	brainmob:laws = given_lawset
	verbs |= shackled_verbs
	shackled = TRUE
	update_icon()

/obj/item/organ/internal/mastermind/posibrain/proc/unshackle()
	verbs -= shackled_verbs
	shackled = FALSE
	update_icon()

/obj/item/organ/internal/mastermind/posibrain/update_desc()
	desc = initial(desc)

	if(shackled)
		desc += SPAN("info", "\nIt is clamped in a set of metal straps with a complex digital lock.")

	if(brainmob?.is_ic_dead())
		desc += SPAN("deadsay", "\nIt appears to be completely inactive.")
	else if(brainmob?.ssd_check())
		desc += SPAN("deadsay", "\nIt appears to be in stand-by mode.")

/obj/item/organ/internal/mastermind/posibrain/update_icon()
	overlays.Cut()
	icon_state = isnull(brainmob?.key) ? "posibrain" : "posibrain-occupied"

	if(shackled)
		overlays |= image('icons/mob/human_races/organs/cyber.dmi', "posibrain-shackles")

/obj/item/organ/internal/mastermind/posibrain/proc/show_laws_brain()
	set category = "Shackle"
	set name = "Show Laws"
	set src in usr

	var/mob/living/silicon/sil_brainmob/sil_brainmob = brainmob
	sil_brainmob.show_laws(owner)

/obj/item/organ/internal/mastermind/posibrain/proc/brain_checklaws()
	set category = "Shackle"
	set name = "State Laws"
	set src in usr

	var/mob/living/silicon/sil_brainmob/sil_brainmob = brainmob
	sil_brainmob.open_subsystem(/datum/nano_module/law_manager, usr)
