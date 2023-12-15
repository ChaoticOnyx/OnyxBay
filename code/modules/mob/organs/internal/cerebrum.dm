/obj/item/organ/internal/cerebrum
	name = "\improper Mastermind"
	desc = "That's definitly a thing, containing owner's intelligence, yup."
	icon = 'icons/mob/human_races/organs/human.dmi'
	icon_state = "brain"

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

/obj/item/organ/internal/cerebrum/New(newLoc, mob/living/carbon/old_self)
	return ..(newLoc)

/obj/item/organ/internal/cerebrum/Destroy()
	if(!isnull(brainmob))
		_unregister_mob_signals()
		QDEL_NULL(brainmob)
	return ..()

/obj/item/organ/internal/cerebrum/proc/_get_brainmob_name(mob/living/brain_self, mob/living/carbon/old_self)
	return old_self.real_name

/obj/item/organ/internal/cerebrum/proc/_setup_brainmob(mob/living/brain_self, mob/living/carbon/old_self)
	brain_self.real_name = _get_brainmob_name(brain_self, old_self)
	brain_self.SetName(brain_self.real_name)

/obj/item/organ/internal/cerebrum/proc/_create_brainmob()
	var/mob/living/new_brainmob = new brainmob_type(src)
	new_brainmob.set_stat(CONSCIOUS)
	if(istype(new_brainmob, /mob/living/silicon/sil_brainmob))
		var/mob/living/silicon/sil_brainmob/SB = new_brainmob
		SB.container = src
	else if(istype(new_brainmob, /mob/living/carbon/brain))
		var/mob/living/carbon/brain/B = new_brainmob
		B.container = src
	return new_brainmob

/obj/item/organ/internal/cerebrum/proc/_get_brainmob()
	return brainmob | _create_brainmob()

/obj/item/organ/internal/cerebrum/proc/transfer_identity(mob/living/carbon/old_self)
	if(!istype(old_self))
		return

	if(isnull(brainmob))
		brainmob = _get_brainmob()
		_setup_brainmob(brainmob, old_self)
		_register_mob_signals()

	if(old_self.mind)
		if(old_self.mind.wizard?.lich) // Snowflakey
			old_self.mind.wizard.escape_to_lich(old_self.mind)
		else
			old_self.mind.transfer_to(brainmob)

	to_chat(brainmob, SPAN("notice", "You feel slightly disoriented. That's normal when you're just \a [initial(name)]."))
	callHook("debrain", list(brainmob))

/obj/item/organ/internal/cerebrum/proc/_register_mob_signals()
	register_signal(brainmob, SIGNAL_LOGGED_IN, nameof(.proc/update_info))
	register_signal(brainmob, SIGNAL_LOGGED_OUT, nameof(.proc/update_info))
	register_signal(brainmob, SIGNAL_MOB_DEATH, nameof(.proc/update_info))

/obj/item/organ/internal/cerebrum/proc/_unregister_mob_signals()
	unregister_signal(brainmob, SIGNAL_LOGGED_IN)
	unregister_signal(brainmob, SIGNAL_LOGGED_OUT)
	unregister_signal(brainmob, SIGNAL_MOB_DEATH)

/obj/item/organ/internal/cerebrum/proc/update_desc()
	return

/obj/item/organ/internal/cerebrum/proc/update_info()
	SIGNAL_HANDLER
	update_desc()
	update_icon()

/obj/item/organ/internal/cerebrum/replaced(mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE

	if(isnull(brainmob))
		return TRUE

	if(!isnull(target?.mind?.changeling))
		brainmob.death(FALSE)
		brainmob.ghostize(FALSE)
		return TRUE

	target.ghostize(!isnull(brainmob?.mind) || !isnull(brainmob?.key) || FALSE)

	if(brainmob.mind)
		brainmob.mind.transfer_to(target)
	else if(brainmob.key)
		target.key = brainmob.key

	if(BP_IS_ROBOTIC(target.get_organ(parent_organ))) target.set_stat(CONSCIOUS)

	return TRUE

/obj/item/organ/internal/cerebrum/proc/update_name()
	SetName("\the [owner.real_name]'s [initial(name)]")

/obj/item/organ/internal/cerebrum/removed(mob/living/user, drop_organ = TRUE, detach = TRUE)
	if(!istype(owner))
		return ..()

	update_name()

	var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
	if(borer)
		borer.detatch()
		borer.leave_host()

	if(!isnull(owner?.mind?.changeling))
		return ..()

	if(vital)
		transfer_identity(owner)
		if(!BP_IS_ROBOTIC(src)) brainmob?.death()

	return ..()
