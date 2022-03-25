/obj/item/implant/abductor
	name = "recall implant"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	var/obj/machinery/abductor/pad/home
	var/cooldown = 60 SECONDS
	var/on_cooldown
	action_button_name = "Bail Out"

/obj/item/implant/abductor/activate()
	. = ..()
	if(world.time < on_cooldown)
		to_chat(imp_in, SPAN_WARNING("You must wait [(on_cooldown-world.time)*0.1] seconds to use [src] again!"))
		return

	home.Retrieve(imp_in,1)
	on_cooldown = world.time+cooldown

/obj/item/implant/abductor/implant_in_mob(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	if(..())
		var/obj/machinery/abductor/console/console
		if(ishuman(target))
			var/datum/abductor/A = target.mind.abductor
			if(A)
				console = get_abductor_console(A.team.team_number)
				home = console.pad

		if(!home)
			var/list/consoles = list()
			for(var/obj/machinery/abductor/console/C in GLOB.machines)
				consoles += C
			console = pick(consoles)
			home = console.pad

		return TRUE
/obj/item/implant/abductor/ui_action_click()
	activate()
