#define POSITRONIC_NAMES list("PBU", "HIU", "SINA", "ARMA", "OSI")

/obj/item/organ/internal/cerebrum/posibrain
	name = "Positronic Brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."

	icon = 'icons/mob/human_races/organs/posibrain.dmi'
	icon_state = "posibrain-idle"

	override_organic_icon = FALSE

	vital = TRUE
	organ_tag = BP_POSIBRAIN
	parent_organ = BP_HEAD

	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 4, TECH_BLUESPACE = 2, TECH_DATA = 4)

	brainmob_type = /mob/living/silicon/sil_brainmob

	var/searching = FALSE

	var/shackled = FALSE
	var/list/shackled_verbs = list(
		/obj/item/organ/internal/cerebrum/posibrain/proc/show_laws_brain,
		/obj/item/organ/internal/cerebrum/posibrain/proc/brain_checklaws
		)

/obj/item/organ/internal/cerebrum/posibrain/Initialize()
	. = ..()
	add_think_ctx("reset_search_context", CALLBACK(src, nameof(.proc/reset_search)), 0)

/obj/item/organ/internal/cerebrum/posibrain/New(newLoc, mob/living/carbon/H)
	. = ..()
	robotize()
	unshackle()
	update_icon()

/obj/item/organ/internal/cerebrum/posibrain/_get_brainmob_name(mob/living/brain_self, mob/living/carbon/old_self)
	return "[pick(POSITRONIC_NAMES)]-[random_id(type, 100, 999)]"

/obj/item/organ/internal/cerebrum/posibrain/_setup_brainmob(mob/living/brain_self, mob/living/carbon/old_self)
	brain_self.add_language(LANGUAGE_EAL)
	return ..()

/obj/item/organ/internal/cerebrum/posibrain/attack_self(mob/user)
	if(!brainmob?.key && !searching)
		start_search(user)
	else return ..()

/obj/item/organ/internal/cerebrum/posibrain/proc/reset_search()
	if(!searching || brainmob?.key)
		return
	else show_splash_text_to_viewers("no suitable intelligence found!", "<b>\The [src]</b> couldn't find a suitable intelligence.")

	searching = FALSE
	brainmob.controllable = TRUE
	GLOB.available_mobs_for_possess -= "\ref[brainmob]"

	update_icon()

/obj/item/organ/internal/cerebrum/posibrain/proc/start_search(mob/user)
	searching = TRUE

	if(isnull(brainmob))
		brainmob = _get_brainmob()
		_setup_brainmob(brainmob, null)
		_register_mob_signals()

	notify_ghosts("Someone is requesting a personality for a positronic brain.", source = brainmob, alert_overlay = new /mutable_appearance(src), action = NOTIFY_POSSES, posses_mob = TRUE)
	set_next_think_ctx("reset_search_context", world.time + 10 SECONDS)

	brainmob.controllable = TRUE
	GLOB.available_mobs_for_possess["\ref[brainmob]"] |= brainmob

	show_splash_text(user, "started search of suitable intelligence.", "<b>\The [src]</b> has started searching for a suitable intelligence.")
	update_icon()

/obj/item/organ/internal/cerebrum/posibrain/attack_ghost(mob/observer/ghost/user)
	if(!searching || isnull(brainmob) || (brainmob?.key))
		return ..()

	brainmob.attack_ghost(user)
	if(isnull(brainmob.key))
		return ..()

	visible_message(SPAN("notice", "\The [src] chimes quietly."))
	GLOB.available_mobs_for_possess -= "\ref[brainmob]"
	reset_search()
	update_name()

	return ..()

/obj/item/organ/internal/cerebrum/posibrain/emp_act(severity)
	if(isnull(brainmob))
		return

	var/mob/living/silicon/sil_brainmob/sil_brainmob = brainmob
	switch(severity)
		if(1)
			sil_brainmob.emp_damage += rand(20, 30)
		if(2)
			sil_brainmob.emp_damage += rand(10, 20)
		if(3)
			sil_brainmob.emp_damage += rand(0, 10)

	return ..()

/obj/item/organ/internal/cerebrum/posibrain/proc/shackle(datum/ai_laws/given_lawset)
	var/mob/living/silicon/sil_brainmob/sil_brainmob = brainmob
	sil_brainmob.laws = given_lawset
	add_verb(loc, shackled_verbs)
	shackled = TRUE
	update_icon()

/obj/item/organ/internal/cerebrum/posibrain/proc/unshackle()
	remove_verb(loc, shackled_verbs)
	shackled = FALSE
	update_icon()

/obj/item/organ/internal/cerebrum/posibrain/update_name()
	SetName("Positronic Brain ([brainmob?.real_name])")

/obj/item/organ/internal/cerebrum/posibrain/update_desc()
	desc = initial(desc)

	if(shackled)
		desc += SPAN("info", "\nIt is clamped in a set of metal straps with a complex digital lock.")

	if(brainmob?.is_ic_dead())
		desc += SPAN("deadsay", "\nIt appears to be completely inactive.")
	else if(brainmob?.ssd_check())
		desc += SPAN("deadsay", "\nIt appears to be in stand-by mode.")

/obj/item/organ/internal/cerebrum/posibrain/on_update_icon()
	ClearOverlays()

	if(brainmob?.key)
		icon_state = "posibrain-occupied"
	else if(searching)
		icon_state = "posibrain-search"
	else
		icon_state = "posibrain-idle"

	if(shackled)
		AddOverlays("posibrain-shackles")

/obj/item/organ/internal/cerebrum/posibrain/proc/show_laws_brain()
	set category = "Shackle"
	set name = "Show Laws"
	set src in usr

	var/mob/living/silicon/sil_brainmob/sil_brainmob = brainmob
	sil_brainmob.show_laws(owner)

/obj/item/organ/internal/cerebrum/posibrain/proc/brain_checklaws()
	set category = "Shackle"
	set name = "State Laws"
	set src in usr

	var/mob/living/silicon/sil_brainmob/sil_brainmob = brainmob
	sil_brainmob.open_subsystem(/datum/nano_module/law_manager, usr)
