#define VALUE_REDUCTION 2 //We divide healing/damage of the staff by this value
#define HEALING_THRESHOLD_MINOR 3 //Basically it means that the necromancer must suck life from 5 or move people around him
#define HEALING_THRESHOLD_MAJOR 200 //How much damage to accumulate before organs, bones and bleedings can be healed
#define DAMAGE_THRESHOLD 300 //Value which unlocks supercharged strike
#define DAMAGE_PER_TICK 2 //How much damage we deliver when siphoning

/obj/item/staff/plague_bell
	name = "Cursed Plague Bell"
	desc = "A staff made of bones with an attached bell."
	icon_state = "plague_bell"

	var/siphon = FALSE //Used to toggle life siphoning from surrounding mobs
	var/accumulated_heal = 0 //Stores accumulated charge that is spent on healing attacks
	var/can_heal = FALSE
	var/accumulated_damage = 0 //Stores accumulated charge to spend on charged attacks
	var/can_damage = FALSE
	var/invocation_heal = "Ut curatio!"
	var/heal_notification = "A strange unnatural energy spreads through your body, mending tissues and sealing wounds!"
	var/invocation_damage = "Adepto eam!"
	var/damage_notification = "You are hit with a blast of vile and abhorrent energy!"
	action_button_name = "Toggle Siphon"
	clumsy_unaffected = TRUE
	var/minor_heal
	var/major_heal

/obj/item/staff/plague_bell/Initialize()
	. = ..()
	minor_heal = new /datum/spell/targeted/siphon_heal(src)
	major_heal = new /datum/spell/targeted/siphon_heal/major(src)

/obj/item/staff/plague_bell/attack_self(mob/user)
	if(!master)
		master = user
		to_chat(master, "You bind the [src] to yourself. You and you alone are now its master!")
		return FALSE

	toggle_siphon(!siphon, user)
	to_chat(user, SPAN_WARNING("You toggle life siphoning [siphon ? "on" : "off"]"))
	user.update_action_buttons()
	return TRUE

/obj/item/staff/plague_bell/proc/toggle_siphon(state, mob/living/M)
	if(M != master)
		M.adjustBruteLoss(10)
		to_chat(M, SPAN_DANGER("The staff resists your will!"))
		return

	siphon = state
	if(siphon)
		set_next_think(world.time +1 SECONDS)
	else
		set_next_think(0)

/obj/item/staff/plague_bell/dropped()
	siphon = FALSE
	set_next_think(0)
	return ..()

/obj/item/staff/plague_bell/think()
	if(!isliving(loc) || !ishuman(loc))
		siphon = FALSE
		set_next_think(0)
		return

	var/mob/living/carbon/human/holder = loc
	if(holder != master)
		holder.adjustBruteLoss(10)
		to_chat(holder, SPAN_DANGER("The staff resists your will!"))
		siphon = FALSE
		set_next_think(0)
		return

	var/damage_delivered = 0 //The necromancer will be healed by a percentage of the total damage delivered this tick.

	for(var/mob/living/M in GLOB.living_mob_list_) // Here we will actually damage mobs in range
		if(get_dist(master, get_turf(M)) > world.view)
			continue

		if(M == master)
			continue

		if(M.isSynthetic() || isundead(M))
			continue

		M.adjustBruteLoss(DAMAGE_PER_TICK)
		damage_delivered += DAMAGE_PER_TICK

		if(M.client || M.teleop) //If no client/SSD - we do not count their for damage so users wont supercharge this staff on monkeys
			accumulated_damage += DAMAGE_PER_TICK
			to_chat(M, SPAN_DANGER("You feel a sudden pain, as if something is sucking the life out of you!"))

	accumulated_heal += damage_delivered
	damage_delivered = damage_delivered/VALUE_REDUCTION

	if(damage_delivered > 0) //No damage means no healing
		to_chat(holder, SPAN_DANGER("You experience a pleasant sensation as vital energies of others are sucked into you!"))
		holder.adjustBruteLoss(-damage_delivered)
		holder.adjustFireLoss(-damage_delivered)
		holder.adjustToxLoss(-damage_delivered)
		holder.adjustOxyLoss(-damage_delivered)

	if(damage_delivered >= HEALING_THRESHOLD_MINOR) //Regenerate blood, brain and remove rad after a certain threshold
		holder.radiation -= damage_delivered
		holder.regenerate_blood(damage_delivered*2)
		holder.adjustBrainLoss(-damage_delivered)
		holder.wizard_heal(minor_heal)

	if(accumulated_damage >= DAMAGE_THRESHOLD && !can_damage)
		to_chat(holder, SPAN_DANGER("The [src] feels hot to the touch. It is now ready for an amplified attack!"))
		can_damage = TRUE
	if(accumulated_heal >= HEALING_THRESHOLD_MAJOR && !can_heal)
		to_chat(holder, SPAN_DANGER("The [src] vibrates softly. It is now ready for a major healing!"))
		can_heal = TRUE

	set_next_think(world.time + 1 SECONDS)

/obj/item/staff/plague_bell/_examine_text(mob/user)
	. = ..()
	if(user != master)
		return

	. += SPAN_NOTICE("The [src] [siphon ? "actively siphons off life energy" : "is silent"].\n")
	. += SPAN_NOTICE("It has [accumulated_heal >= HEALING_THRESHOLD_MAJOR ? "" : "not"] enough charge for a major healing!\n")
	. += SPAN_NOTICE("It has [accumulated_damage >= DAMAGE_THRESHOLD ? "" : "not"] enough charge for an amplified attack!\n")

/obj/item/staff/plague_bell/attack(mob/living/target, mob/living/user, target_zone)
	if(user != master)
		user.adjustBruteLoss(10)
		to_chat(user, SPAN_DANGER("The staff resists your will!"))
		return FALSE

	if(!isliving(target))
		return FALSE

	var/mob/living/carbon/human/attacker = user
	if(attacker.a_intent == I_HELP && ishuman(target) && accumulated_heal >= HEALING_THRESHOLD_MAJOR)
		invocation(user, target, invocation_heal, heal_notification)
		var/mob/living/carbon/human/human = target
		human.wizard_heal(major_heal)
	else if(attacker.a_intent == I_HURT && accumulated_damage >= DAMAGE_THRESHOLD)
		target.adjustBruteLoss(accumulated_damage / VALUE_REDUCTION)
		invocation(user, target, invocation_damage, damage_notification)
	else
		return ..()

	playsound(src, "sound/effects/weapons/misc/plague_bell.ogg", 50, FALSE)

/obj/item/staff/plague_bell/proc/invocation(mob/living/user, mob/living/target, invocation, notification)
	if(!user.is_muzzled() && !user.silent)
		user.say(invocation)

	to_chat(target, SPAN_DANGER(notification))
	accumulated_damage = 0
	accumulated_heal = 0
	can_heal = FALSE
	can_damage = FALSE

/datum/spell/targeted/siphon_heal
	name = "Siphon heal"
	desc = "A spell to reduce copypasta. You should not see this at all."

	heals_internal_bleeding = TRUE
	amt_radiation = -(1 SIEVERT)

/datum/spell/targeted/siphon_heal/major
	heals_external_bleeding = TRUE
	heal_bones = TRUE
	amt_organ = 20
	removes_embeded = TRUE

#undef VALUE_REDUCTION
#undef HEALING_THRESHOLD_MINOR
#undef HEALING_THRESHOLD_MAJOR
#undef DAMAGE_THRESHOLD
#undef DAMAGE_PER_TICK
