/spell/hand/mind_control
	name = "Mind Control"
	desc = "Control the mind of unfortunate spaceman!"
	feedback = "TM"
	school = "illusion"
	invocation = "Anta Di-Rai!"
	invocation_type = SpI_SHOUT
	time_between_channels = 150
	range = 1
	hand_state = "domination_spell"
	hud_state = "wiz_dominate"
	show_message = " puts his hand on target head, it's starting to glow brightly."
	spell_flags = NEEDSCLOTHES
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 3, Sp_POWER = 0)
	spell_delay = 3000
	compatible_targets = list(/mob/living/carbon/human)
	var/list/instructions = list("Serve the Wizard Federation!")
	spell_cast_delay = 50

/spell/hand/mind_control/cast(list/targets, mob/user, channel)
	for(var/mob/M in targets)
		if(M.get_active_hand())
			to_chat(user, SPAN_WARNING("You need an empty hand to cast this spell."))
			return
		var/obj/item/magic_hand/control_hand/H = new (src)
		if(!M.put_in_active_hand(H))
			qdel(H)
			return
	return 1

/spell/hand/mind_control/cast_hand(atom/A, mob/user)
	var/mob/living/target = A
	if(target == user)
		to_chat(user, SPAN_DANGER("You tried to control yourself, thankfully spell didn't worked!"))
		return // Prevents you from stupid thing
	var/datum/magical_imprint/magical_imprint = new(instructions)
	magical_imprint.implant_in_mob(target, BP_HEAD)

/spell/hand/mind_control/proc/interact(user)
	var/datum/browser/popup = new(user, capitalize(name), capitalize(name), 300, 700, src)
	var/data = get_data()
	popup.set_content(data)
	popup.open()

/spell/hand/mind_control/proc/get_data()
	. = {"
	<HR>
	You prepare your instructions, what you want?"}
	. += "<HR><B>Instructions:</B><BR>"
	for(var/i = 1 to instructions.len)
		. += "- [instructions[i]] <A href='byond://?src=\ref[src];edit=[i]'>Edit</A> <A href='byond://?src=\ref[src];del=[i]'>Remove</A><br>"
	. += "<A href='byond://?src=\ref[src];add=1'>Add</A>"

/spell/hand/mind_control/Topic(href, href_list)
	..()
	if(href_list["add"])
		var/mod = sanitize(input("Add an instruction", "Instructions") as text|null)
		if(mod)
			instructions += mod
		interact(usr)
	if(href_list["edit"])
		var/idx = text2num(href_list["edit"])
		var/mod = sanitize(input("Edit the instruction", "Instruction Editing", instructions[idx]) as text|null)
		if(mod)
			instructions[idx] = mod
			interact(usr)
	if(href_list["del"])
		instructions -= instructions[text2num(href_list["del"])]
		interact(usr)

/datum/magical_imprint
	var/message = "<span class='danger'>Something crumbles through your brain, changing you, chaining you!</span>"
	var/brainwashing = 0
	var/confirmed = 0
	var/list/instructions
	var/last_reminder
	var/mob/living/carbon/human/implanted_in

/datum/magical_imprint/New(list/inst)
	instructions = inst

/datum/magical_imprint/proc/implanted(mob/target)
	var/mob/living/carbon/human/H = target
	to_chat(H, message)
	var/msg = ""
	if (!H.reagents.has_reagent(/datum/reagent/water/holywater))
		msg += "<span class='danger'>The fog in your head clears, and you remember some important things. You hold following things as deep convictions, almost like synthetics' laws:</span><br>"
	else
		msg = "<span class='notice'>Something tried to crawl into you mind, but you protected yourself!</span><br>"
		to_chat(H, msg)
		Destroy()
		return FALSE
	for(var/thing in instructions)
		msg += "- [thing]<br>"
	to_chat(target, msg)
	if(target.mind)
		target.mind.store_memory("<hr>[msg]")

	START_PROCESSING(SSprocessing, src)
	return TRUE

/datum/magical_imprint/Process()
	if(implanted_in.reagents.has_reagent(/datum/reagent/water/holywater))
		var/message_ender = "<span class='danger'>Water frees you from magical influence, you are free now:<br> You no longer have to follow any previous laws!</span>"
		to_chat(implanted_in, message_ender)
		if(implanted_in.mind)
			implanted_in.mind.store_memory(message_ender)
		Destroy()
		return
	if (implanted_in.stat == DEAD)
		Destroy()

	if(world.time < last_reminder + 5 MINUTES)
		return
	last_reminder = world.time
	var/instruction = pick(instructions)

	instruction = "<span class='warning'>You recall one of your beliefs: \"[instruction]\"</span>"
	to_chat(implanted_in, instruction)

/datum/magical_imprint/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/datum/magical_imprint/proc/implant_in_mob(mob/M, target_zone)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		BITSET(H.hud_updateflag, IMPLOYAL_HUD)
		implanted_in = M
		implanted(M)
