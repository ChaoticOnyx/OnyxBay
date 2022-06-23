#define ORGAN_RESTORE_TIME 50
/obj/item/organ/internal/heart/gland/heal
	abductor_hint = "organic replicator. Forcibly ejects damaged and robotic organs from the abductee and regenerates them. Additionally, forcibly removes reagents (via vomit) from the abductee if they have moderate toxin damage or poison within the bloodstream, and regenerates blood to a healthy threshold if too low. The abductee will also reject implants such as mindshields."
	cooldown_low = 200
	cooldown_high = 400
	uses = -1
	human_only = TRUE
	icon_state = "health"
	mind_control_uses = 3
	mind_control_duration = 3000

/obj/item/organ/internal/heart/gland/heal/activate()
	for(var/limb in owner.organs_by_name)
		if(istype(limb, /obj/item/organ/external))
			var/obj/item/organ/external/part
			for(var/implant in part.implants)
				reject_implant(implant)
				if(prob(30))
					return

	var/obj/item/organ/internal/appendix/appendix = owner.internal_organs_by_name[BP_APPENDIX]
	if(!appendix || (appendix && ((appendix.status & ORGAN_BROKEN) || (appendix.status & ORGAN_DEAD) || (BP_IS_ROBOTIC(appendix)) || (BP_IS_ASSISTED(appendix)))))
		replace_appendix(appendix)
		return

	var/obj/item/organ/internal/liver/liver = owner.internal_organs_by_name[BP_LIVER]
	if(!liver || (liver && ((liver.damage >= liver.min_broken_damage) ||(BP_IS_ROBOTIC(liver))|| (BP_IS_ASSISTED(liver)))))
		replace_liver(liver)
		return

	var/obj/item/organ/internal/lungs/lungs = owner.internal_organs_by_name[BP_LUNGS]
	if(!lungs || (lungs && ((lungs.damage >= lungs.min_broken_damage) ||(BP_IS_ROBOTIC(lungs))|| (BP_IS_ASSISTED(lungs)))))
		replace_lungs(lungs)
		return

	var/obj/item/organ/internal/stomach/stomach = owner.internal_organs_by_name[BP_STOMACH]
	if(!stomach || (stomach && ((stomach.damage >= stomach.min_broken_damage) ||(BP_IS_ROBOTIC(stomach))|| (BP_IS_ASSISTED(stomach)))))
		replace_stomach(stomach)
		return

	var/obj/item/organ/internal/eyes/eyes = owner.internal_organs_by_name[BP_EYES]
	if(!eyes || (eyes && ((eyes.damage > eyes.min_bruised_damage) ||(BP_IS_ROBOTIC(eyes))|| (BP_IS_ASSISTED(eyes)))))
		replace_eyes(eyes)
		return

	for(var/limb in owner.organs)
		var/obj/item/organ/external/EO = limb
		if((EO.get_damage() >= (EO.max_damage/4)) && (!istype(EO,/obj/item/organ/external/chest)))
			replace_limb(EO)
			return


	if(owner.getToxLoss() > 60)
		replace_blood()
		return
	var/tox_amount = 0
	for(var/datum/reagent/toxin/T in owner.reagents.reagent_list)
		tox_amount += owner.reagents.get_reagent_amount(T.type)
	if(tox_amount > 20)
		replace_blood()
		return
	if(owner.get_blood_volume() < owner.species.blood_volume)
		owner.regenerate_blood(rand(40,owner.species.blood_volume/4))
		to_chat(owner, SPAN_WARNING("You feel your blood pulsing within you."))
		return

	var/obj/item/organ/external/chest/chest
	if((chest.get_damage() >= (chest.max_damage / 4)) || (BP_IS_ROBOTIC(chest)||BP_IS_ASSISTED(chest)))
		replace_chest(chest)
		return

/obj/item/organ/internal/heart/gland/heal/proc/reject_implant(obj/item/implant/implant)
	owner.visible_message(SPAN_WARNING("[owner] vomits up a tiny mangled implant!"), SPAN_DANGER("You suddenly vomit up a tiny mangled implant!"))
	owner.vomit(0,10,3)
	implant.removed()
	implant.forceMove(owner)

/obj/item/organ/internal/heart/gland/heal/proc/replace_appendix(obj/item/organ/internal/appendix/appendix)
	if(appendix)
		owner.vomit(0,10,3)
		appendix.removed(owner)
		owner.visible_message(SPAN_WARNING("[owner] vomits up his [appendix.name]!"), SPAN_DANGER("You suddenly vomit up your [appendix.name]!"))
	else
		to_chat(owner, SPAN_WARNING("You feel a weird rumble in your bowels..."))

	if(do_after(owner, ORGAN_RESTORE_TIME, needhand = FALSE, progress=FALSE))
		owner.restore_organ(BP_APPENDIX)

/obj/item/organ/internal/heart/gland/heal/proc/replace_liver(obj/item/organ/internal/liver/liver)
	if(liver)
		owner.visible_message(SPAN_WARNING("[owner] vomits up his [liver.name]!"), SPAN_DANGER("You suddenly vomit up your [liver.name]!"))
		owner.vomit(0,10,3)
		liver.removed(owner)
	else
		to_chat(owner, SPAN_WARNING("You feel a weird rumble in your bowels..."))

	if(do_after(owner, ORGAN_RESTORE_TIME, needhand = FALSE, progress=FALSE))
		owner.restore_organ(BP_LIVER)

/obj/item/organ/internal/heart/gland/heal/proc/replace_lungs(obj/item/organ/internal/lungs/lungs)
	if(lungs)
		owner.visible_message(SPAN_WARNING("[owner] vomits up his [lungs.name]!"), SPAN_DANGER("You suddenly vomit up your [lungs.name]!"))
		owner.vomit(0,10,3)
		lungs.removed(owner)
	else
		to_chat(owner, SPAN_WARNING("You feel a weird rumble inside your chest..."))

	if(do_after(owner, ORGAN_RESTORE_TIME, needhand = FALSE, progress=FALSE))
		owner.restore_organ(BP_LUNGS)

/obj/item/organ/internal/heart/gland/heal/proc/replace_stomach(obj/item/organ/internal/stomach/stomach)
	if(stomach)
		owner.visible_message(SPAN_WARNING("[owner] vomits up his [stomach.name]!"), SPAN_DANGER("You suddenly vomit up your [stomach.name]!"))
		owner.vomit(0,10,3)
		stomach.removed(owner)
	else
		to_chat(owner, SPAN_WARNING("You feel a weird rumble in your bowels..."))

	if(do_after(owner, ORGAN_RESTORE_TIME, needhand = FALSE, progress=FALSE))
		owner.restore_organ(BP_STOMACH)

/obj/item/organ/internal/heart/gland/heal/proc/replace_eyes(obj/item/organ/internal/eyes/eyes)
	if(eyes)
		owner.visible_message(SPAN_WARNING("[owner]'s [eyes.name] fall out of their sockets!"), SPAN_DANGER("Your [eyes.name] fall out of their sockets!"))
		playsound(owner, 'sound/effects/splat.ogg', 50, TRUE)
		eyes.removed(owner)
	else
		to_chat(owner, SPAN_WARNING("You feel a weird rumble behind your eye sockets..."))

	addtimer(CALLBACK(src, .proc/finish_replace_eyes), rand(100, 200))

/obj/item/organ/internal/heart/gland/heal/proc/finish_replace_eyes()
	owner.restore_organ(BP_EYES)
	owner.visible_message(SPAN_WARNING("A pair of new eyes suddenly inflates into [owner]'s eye sockets!"), SPAN_DANGER("A pair of new eyes suddenly inflates into your eye sockets!"))

	owner.blinded = 0
	owner.eye_blind = 0
	owner.eye_blurry = 0

	owner.remove_nearsighted()
	owner.sdisabilities &= ~BLIND
	owner.remove_deaf() //Why not?



/obj/item/organ/internal/heart/gland/heal/proc/replace_limb(obj/item/organ/external/limb)

	if(limb && !istype(limb, /obj/item/organ/external/groin) && !istype(limb, /obj/item/organ/external/head))
		owner.visible_message(SPAN_WARNING("[owner]'s [limb.name] suddenly detaches from \his body!"), SPAN_DANGER("Your [limb.name] suddenly detaches from your body!"))
		playsound(owner, "desecration", 50, TRUE, -1)
		if(!istype(limb, /obj/item/organ/external/stump))
			limb.removed()
			owner.regenerate_icons()
	else
		to_chat(owner, SPAN_WARNING("You feel a weird tingle in your [limb.name]."))

	addtimer(CALLBACK(src, .proc/finish_replace_limb, limb), rand(150, 300))

/obj/item/organ/internal/heart/gland/heal/proc/finish_replace_limb(obj/item/organ/external/limb)
	owner.visible_message(SPAN_WARNING("With a loud snap, [owner]'s [limb.name] rapidly grows back from \his body!"),
	SPAN_DANGER("With a loud snap, your [limb.name] rapidly grows back from your body!"),
	SPAN_WARNING("Your hear a loud snap."))
	playsound(owner, 'sound/magic/demon_consume.ogg', 50, TRUE)
	var/obj/item/organ/external/new_organ = owner.species.has_limbs[limb.organ_tag]["path"]
	new new_organ(owner)
	owner.restore_limb(limb.organ_tag)
	//Hands restore
	if(limb.organ_tag == BP_L_ARM||limb.organ_tag == BP_R_ARM)
		owner.restore_limb(limb.organ_tag==BP_L_ARM?BP_L_HAND:BP_R_HAND)
	//Foot restore
	if(limb.organ_tag == BP_L_LEG||limb.organ_tag == BP_R_LEG)
		owner.restore_limb(limb.organ_tag==BP_L_LEG?BP_L_FOOT:BP_R_FOOT)

	owner.regenerate_icons()

/obj/item/organ/internal/heart/gland/heal/proc/replace_blood()
	owner.visible_message(SPAN_WARNING("[owner] starts vomiting huge amounts of blood!"), SPAN_DANGER("You suddenly start vomiting huge amounts of blood!"))
	keep_replacing_blood()

/obj/item/organ/internal/heart/gland/heal/proc/keep_replacing_blood()
	var/keep_going = FALSE
	owner.vomit(1,10,3)
	var/turf/location = loc
	if (istype(location, /turf/simulated))
		for(var/i in 1 to 3)
			location.add_blood(owner)
	owner.Stun(15)
	owner.adjustToxLoss(-15)
	owner.regenerate_blood(25)
	if(owner.get_blood_volume() < owner.species.blood_volume)
		keep_going = TRUE

	if(owner.getToxLoss())
		keep_going = TRUE

	for(var/datum/reagent/toxin/R in owner.reagents.reagent_list)
		owner.reagents.remove_reagent(R.type, 4)
		if(owner.reagents.has_reagent(R.type))
			keep_going = TRUE
	if(keep_going)
		addtimer(CALLBACK(src, .proc/keep_replacing_blood), 30)

/obj/item/organ/internal/heart/gland/heal/proc/replace_chest(obj/item/organ/external/chest/chest)
	if(BP_IS_ROBOTIC(chest))
		owner.visible_message(SPAN_WARNING("[owner]'s [chest.name] rapidly expels its mechanical components, replacing them with flesh!"), SPAN_DANGER("Your [chest.name] rapidly expels its mechanical components, replacing them with flesh!"))
		playsound(owner, 'sound/magic/anima_fragment_attack.ogg', 50, TRUE)
		var/list/dirs = GLOB.alldirs.Copy()
		for(var/i in 1 to 3)
			var/obj/effect/decal/cleanable/blood/gibs/robot/debris = new(get_turf(owner))
			debris.streak(dirs)
	else
		owner.visible_message(SPAN_WARNING("[owner]'s [chest.name] sheds off its damaged flesh, rapidly replacing it!"), SPAN_WARNING("Your [chest.name] sheds off its damaged flesh, rapidly replacing it!"))
		playsound(owner, 'sound/effects/splat.ogg', 50, TRUE)
		var/list/dirs = GLOB.alldirs.Copy()
		for(var/i in 1 to 3)
			var/obj/effect/decal/cleanable/blood/gibs/gibs = new(get_turf(owner))
			gibs.streak(dirs)

	chest.rejuvenate(TRUE)
	qdel(chest)
