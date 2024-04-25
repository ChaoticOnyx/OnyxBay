/datum/evolution_holder/lust
	evolution_categories = list(
		/datum/evolution_category/greed
	)
	default_modifiers = list(/datum/modifier/sin/lust)

/datum/evolution_category/lust
	name = "Sin of Lust"
	items = list(
		/datum/evolution_package/suggest,
		/datum/evolution_package/void_pull,
		/datum/evolution_package/quickgrab,
	)

/datum/evolution_package/suggest
	name = "Spell of Suggest"
	desc = "Gain proficiency in persuasion. Command others at will."
	actions = list(
		/datum/action/cooldown/spell/suggest
	)

/datum/evolution_package/void_pull
	name = "Void Pull"
	desc = "A powerful spell designed at incapacitating people."
	actions = list(
		/datum/action/cooldown/spell/aoe/void_pull
	)

/datum/evolution_package/quickgrab
	name = "Tenacious Hands"
	desc = "Enhance your grip with unnatural energies."
	actions = list(
		/datum/action/cooldown/spell/quickgrab
	)

#define LUST_SLOT_BLOCK_FIRST_STAGE list(slot_wear_suit, slot_head)
#define LUST_SLOT_BLOCK_SECOND_STAGE list(slot_gloves, slot_belt, slot_legs)
#define LUST_SLOT_BLOCK_LAST_STAGE list(slot_w_uniform, slot_shoes)
#define LUST_UNDIES_MESSAGES list("Why do i even need underwear?", "My undergarments feel quite uncomfortable...")
#define LUST_UNDIES_MESSAGES_UNTIL_UNDRESSS 5

/datum/modifier/sin/lust
	blocks_underwear = TRUE
	blocked_slots = LUST_SLOT_BLOCK_FIRST_STAGE

/datum/modifier/sin/lust/New()
	. = ..()
	add_think_ctx("undies_ctx", CALLBACK(src, nameof(.proc/undies_ctx)), 0)
	add_think_ctx("clothes_ctx", CALLBACK(src, nameof(.proc/clothes_ctx)), 0)

/datum/modifier/sin/lust/on_applied()
	set_next_think_ctx("undies_ctx", world.time + 1 SECOND)

/datum/modifier/sin/lust/proc/undies_ctx(times_shown = 0)
	if(times_shown >= LUST_UNDIES_MESSAGES_UNTIL_UNDRESSS)
		remove_undies()
		return

	to_chat(holder, SPAN_NOTICE(pick(LUST_UNDIES_MESSAGES)))
	times_shown += 1
	set_next_think_ctx("undies_ctx", world.time + 15 SECONDS, times_shown++)

/datum/modifier/sin/lust/proc/remove_undies()
	var/mob/living/carbon/human/human_holder = holder
	ASSERT(human_holder)
	for(var/obj/item/underwear/undie in holder.contents)
		human_holder.worn_underwear -= undie
		human_holder.drop(undie, force = TRUE)
		human_holder.update_underwear()
	set_next_think_ctx("clothes_ctx", world.time + 10 MINUTES)

/datum/modifier/sin/lust/proc/clothes_ctx()
	sin_stage++
	switch(sin_stage)
		if(SIN_STAGE_ADVANCED)
			first_stage()
		if(SIN_STAGE_BLASPHEMY)
			second_stage()
		if(SIN_STAGE_SACRILEGE)
			third_stage()

	set_next_think_ctx("clothes_ctx", world.time + 10 MINUTES)

/datum/modifier/sin/lust/proc/first_stage()
	blocked_slots = LUST_SLOT_BLOCK_FIRST_STAGE

/datum/modifier/sin/lust/proc/second_stage()
	blocked_slots = LUST_SLOT_BLOCK_SECOND_STAGE + LUST_SLOT_BLOCK_FIRST_STAGE

/datum/modifier/sin/lust/proc/third_stage()
	blocked_slots = LUST_SLOT_BLOCK_LAST_STAGE + LUST_SLOT_BLOCK_SECOND_STAGE + LUST_SLOT_BLOCK_FIRST_STAGE
