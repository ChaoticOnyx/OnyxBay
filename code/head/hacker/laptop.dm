obj/item/weapon/laptop
	name = "Laptop"
	icon = 'laptop.dmi'
	icon_state = "laptop_0"
	var/datum/os/OS = new()
	var/on = 0
	var/mob/console_user
obj/item/weapon/laptop/proc/updateicon()
	icon_state = "laptop_[on]"
obj/item/weapon/laptop/attack_self(mob/user as mob)
	if(!on)
		winshow(user, "console", 1)
		on = 1
		console_user = user
		user.comp = OS
		OS.owner = user
		OS.Boot()
	else
		winshow(user, "console", 0)
		on = 0
		return
		// DO MORE SHIT HERE
obj/item/weapon/laptop/process()
	if(!console_user in range(1,src))
		console_user.comp = null
		OS.owner = null
		console_user = null