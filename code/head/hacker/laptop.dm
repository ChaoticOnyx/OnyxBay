obj/item/weapon/laptop
	name = "Laptop"
	icon = 'laptop.dmi'
	icon_state = "laptop_0"
	var/datum/os/OS
	var/on = 0
	var/mob/console_user
	var/address

obj/item/weapon/laptop/New()
	..()
	address = 0
	OS = new(src)

obj/item/weapon/laptop/proc/receive_packet(var/obj/machinery/sender, var/datum/packet/P)

obj/item/weapon/laptop/proc/updateicon()
	icon_state = "laptop_[on]"
obj/item/weapon/laptop/attack_self(mob/user as mob)
	if(!on)
		on = 1
		user.display_console(src)
	else
		user.hide_console()
		on = 0
		return
		// DO MORE SHIT HERE
obj/item/weapon/laptop/process()
	if(!(console_user in range(1,src)))
		console_user.comp = null
		console_user.console_device = null
		OS.owner = null
		console_user = null