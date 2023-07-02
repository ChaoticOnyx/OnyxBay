/obj/item/organ/internal/mastermind
	name = "\improper Mastermind"
	desc = "That's definitly a thing, containing owner's intelligence, yup."
	icon = 'icons/mob/human_races/organs/human.dmi'
	icon_state = "brain2"

	vital = TRUE
	organ_tag = BP_BRAIN
	parent_organ = BP_HEAD

	force = 1
	throwforce = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("attacked", "slapped", "whacked")

	origin_tech = list(TECH_BIO = 3)
	req_access = list(access_robotics, access_medical)

	var/brainmob_type = /mob/living/carbon/brain

	var/mob/living/brainmob = null

/obj/item/organ/internal/mastermind/New(newLoc, mob/living/carbon/old_self)
	return ..(newLoc, newLoc)

/obj/item/organ/internal/mastermind/Destroy()
	if(!isnull(brainmob))
		_unregister_mob_signals()
		QDEL_NULL(brainmob)
	return ..()

/obj/item/organ/internal/mastermind/proc/_get_brainmob_name(mob/living/brain_self, mob/living/carbon/old_self)
	return old_self.real_name

/obj/item/organ/internal/mastermind/proc/_setup_brainmob(mob/living/brain_self, mob/living/carbon/old_self)
	brain_self.SetName(_get_brainmob_name(brain_self, old_self))
	brain_self.real_name = name

/obj/item/organ/internal/mastermind/proc/_create_brainmob()
	var/mob/living/new_brainmob = new brainmob_type(src)
	new_brainmob.set_stat(CONSCIOUS)
	new_brainmob:container = src
	return new_brainmob

/obj/item/organ/internal/mastermind/proc/_get_brainmob()
	return brainmob | _create_brainmob()

/obj/item/organ/internal/mastermind/proc/transfer_identity(mob/living/carbon/old_self)
	if(!istype(old_self))
		return

	brainmob = _get_brainmob()

	_setup_brainmob(brainmob, old_self)
	_register_mob_signals()

	old_self.mind?.transfer_to(brainmob)

	to_chat(brainmob, SPAN("notice", "You feel slightly disoriented. That's normal when you're just \a [initial(name)]."))
	callHook("debrain", list(brainmob))

/obj/item/organ/internal/mastermind/proc/_register_mob_signals()
	register_signal(brainmob, SIGNAL_LOGGED_IN, /obj/item/organ/internal/mastermind/proc/update_info)
	register_signal(brainmob, SIGNAL_LOGGED_OUT, /obj/item/organ/internal/mastermind/proc/update_info)
	register_signal(brainmob, SIGNAL_MOB_DEATH, /obj/item/organ/internal/mastermind/proc/update_info)

/obj/item/organ/internal/mastermind/proc/_unregister_mob_signals()
	unregister_signal(brainmob, SIGNAL_LOGGED_IN)
	unregister_signal(brainmob, SIGNAL_LOGGED_OUT)
	unregister_signal(brainmob, SIGNAL_MOB_DEATH)

/obj/item/organ/internal/mastermind/proc/update_desc()
	return

/obj/item/organ/internal/mastermind/proc/update_info()
	SIGNAL_HANDLER
	update_desc()
	update_icon()

/obj/item/organ/internal/mastermind/replaced(mob/living/target)
	. = ..()
	if(!.)
		return FALSE

	target.ghostize()

	if(isnull(brainmob))
		return TRUE

	if(brainmob?.mind)
		brainmob.mind.transfer_to(target)
	else
		target.key = brainmob.key

	target.set_stat(CONSCIOUS)

	return TRUE

/obj/item/organ/internal/mastermind/proc/update_name()
	SetName("\the [owner.real_name]'s [initial(name)]")

/obj/item/organ/internal/mastermind/removed(mob/living/user, drop_organ = TRUE, detach = TRUE)
	if(!istype(owner))
		return ..()

	update_name()

	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
	if(borer)
		borer.detatch()
		borer.leave_host()

	if(vital)
		transfer_identity(owner)

	return ..()
