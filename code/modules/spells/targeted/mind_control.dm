/spell/targeted/mind_control
	name = "mind_control"
	desc = "Control the mind of unfortunate spaceman!"
	feedback = "TM"
	school = "illusion"
	charge_max = 400
	invocation = "Anta Di-Rai!"
	invocation_type = SpI_SHOUT
	time_between_channels = 150
	range = 2
	compatible_mobs = list(/mob/living/carbon/human)
	spell_flags = NEEDSCLOTHES
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 3, Sp_POWER = 0)
	cooldown_min = 400
	cooldown_reduc = 50
	message = "<span class='danger'>Something crumbles through your brain, changing you, chaining you!</span>"
	var/list/instructions = list("Serve the Wizard Federation!.")
	var/brainwashing = 0
	var/last_reminder
	var/confirmed = 0
/spell/targeted/mind_control/cast(list/targets, mob/user, channel)
	if(!src.cast_check(1, user, targets))
		return

	for(var/mob/living/target in targets)
		if(range > 0)
			if(!(target in view_or_range(range, holder, selection_type))) //filter at time of casting
				targets -= target
				continue
	var/mob/living/carbon/human/H = targets[1]
	interact(user)
	while(!confirmed)
		w
	implanted(H)

/spell/targeted/mind_control/proc/interact(user)

	var/datum/browser/popup = new(user, capitalize(name), capitalize(name), 300, 700, src)
	var/dat = get_data()
	popup.set_content(dat)
	popup.open()

/spell/targeted/mind_control/proc/get_data()
	. = {"
	<HR>
	You adjust your mind, with the Host mind. What you want from him to do?"}
	. += "<HR><B>Instructions:</B><BR>"
	for(var/i = 1 to instructions.len)
		. += "- [instructions[i]] <A href='byond://?src=\ref[src];edit=[i]'>Edit</A> <A href='byond://?src=\ref[src];del=[i]'>Remove</A><br>"
	. += "<A href='byond://?src=\ref[src];add=1'>Add</A>"
	. += "<A href='byond://src=\ref[src];confirm=1'>Confirm</A>"
/spell/targeted/mind_control/Topic(href, href_list)
	..()
	if (href_list["add"])
		var/mod = sanitize(input("Add an instruction", "Instructions") as text|null)
		if(mod)
			instructions += mod
		interact(usr)
	if (href_list["edit"])
		var/idx = text2num(href_list["edit"])
		var/mod = sanitize(input("Edit the instruction", "Instruction Editing", instructions[idx]) as text|null)
		if(mod)
			instructions[idx] = mod
			interact(usr)
	if (href_list["del"])
		instructions -= instructions[text2num(href_list["del"])]
		interact(usr)
	if (href_list["confirm"])
		confirmed = 1

/spell/targeted/mind_control/proc/implanted(/mob/living/carbon/human/H)
	var/msg = ""
	if (!H.reagents.has_reagent(/datum/reagent/water/holywater))
		msg += "<span class='danger'>The fog in your head clears, and you remember some important things. You hold following things as deep convictions, almost like synthetics' laws:</span><br>"
	else
		msg += "<span class='notice'>Something tried to crawl into you mind, but something Holy saved you!:</span><br>"
		return FALSE
	to_chat(H, msg)
	if(H.mind)
		H.mind.store_memory("<hr>[msg]")

	START_PROCESSING(SSobj, src)
	return TRUE

/obj/item/weapon/implant/imprinting/Process()
	if(world.time < last_reminder + 5 MINUTES)
		return
	last_reminder = world.time
	var/instruction = pick(instructions)
	if(brainwashing)
		instruction = "<span class='warning'>You recall one of your beliefs: \"[instruction]\"</span>"
	else
		instruction = "<span class='notice'>You remember suddenly: \"[instruction]\"</span>"
	to_chat(imp_in, instruction)

// /obj/item/weapon/implant/imprinting/removed()
// 	if(brainwashing)
// 		to_chat(imp_in,"<span class='notice'>You are no longer so sure of those beliefs you've had...</span>")
// 	..()
// 	STOP_PROCESSING(SSobj, src)

// /obj/item/weapon/implant/imprinting/Destroy()
// 	STOP_PROCESSING(SSobj, src)
// 	. = ..()
