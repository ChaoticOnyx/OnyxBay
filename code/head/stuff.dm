/obj/item/weapon/recorder
	name = "Voice Recorder"
	desc = "Records voice"
	icon = 'items.dmi'
	icon_state = "implantpad-0"
	w_class = 2.0
	var/obj/item/weapon/voicedisk/disk
	var/recording = 0
	var/playing = 0
	var/playingall = 0
/obj/item/weapon/recorder/New()
	disk = new()
/obj/item/weapon/recorder/attack_self(mob/user as mob)
	var/dat = "<head><title>Recorder interface</title></head>"
	if(!disk)
		dat += "<BR>Error Missing Datadisk!"
		user << browse(dat,"window=recorder")
		return
	if(recording)
		dat += "<BR><a href=?src=\ref[src];action=stop>Stop Recording</a>"
	else
		dat += "<BR><a href=?src=\ref[src];action=start>Start Recording</a>"
	dat += "<BR>Memory"
	var/count = 0
	for(var/T in disk.memory)
		count++
		dat += "<li><a href=?src=\ref[src];play=[T]>Record#[count]</a>"
	if(disk)
		dat += "<BR><a href=?src=\ref[src];action=eject>Eject Disk</a>"
	if(disk.memory.len >= 1)
		dat += "<BR><a href=?src=\ref[src];playall=1>Play All</a>"
	if(playingall)
		dat += "dat += <BR><a href=?src=\ref[src];stop=1>Stop Playback.</a>"
	user << browse(dat,"window=recorder")
/obj/item/weapon/recorder/proc/updatewindow(mob/user as mob)
	src.attack_self(user)
/obj/item/weapon/recorder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/voicedisk/))
		if(!src.disk)
			for(var/mob/M in viewers(world.view,user))
				M << "[user] inserts the [W] in the [src]"
			usr.drop_item()
			W.loc = src
			src.disk = W
			return
	return ..()

/obj/item/weapon/recorder/Topic(href,href_list[],hsrc)
	switch(href_list["action"])
		if("start")
			if(!disk)
				return
			recording = 1
			attack_self(usr)
			return
		if("stop")
			recording = 0
			attack_self(usr)
			return
		if("eject")
			if(!disk)
				return
			var/mob/holder
			if(ismob(src.loc))
				holder = src.loc
			disk.loc = holder ? holder.loc : src.loc
			disk = null
			recording = 0
			attack_self(usr)
			return

	if("play")
		if(!disk)
			return
		if(playing)
			return
		playing = 1
		attack_self(usr)
		spawn(10) playing = 0
		var/id = href_list["play"]
		var/msg = disk.memory["[id]"]
		var/types = disk.mobtype["[id]"]
		if(types == "human" || types == "cyborg" || types == "ai")
			var/mob/holder
			if(ismob(src.loc))
				holder = src.loc
			for(var/mob/M in viewers(world.view,holder ? holder : src ))
				if(istype(M,/mob/living/silicon) || istype(M,/mob/living/carbon/human))
					M << "<span class='game recorder'><span class='name'></span><b> \icon[src]\[[src.name]\]</b> <span class='message'>[msg]</span></span>"
				else
					M << Ellipsis(msg)
			return
		if(types == "alien")
			for(var/mob/M in viewers(world.view,src))
				if(istype(M,/mob/living/carbon/alien))
					M << "<span class='game recorder'><span class='name'></span><b> \icon[src]\[[src.name]\]</b> <span class='message'>[msg]</span></span>"
				else
					M << "You hear a faint hisses from \the [src]"
			return
		if(types == "monkey")
			for(var/mob/M in viewers(world.view,src))
				if(istype(M,/mob/living/carbon/monkey))
					M << "<span class='game recorder'><span class='name'></span><b> \icon[src]\[[src.name]\]</b> <span class='message'>[msg]</span></span>"
				else
					M << "You hear chimpering from \the [src]"
	if("playall")
		playingall = 1
		attack_self(usr)
		for(var/t in disk.memory)
			if(!playingall)
				return
			sleep(10)
			var/id = t
			var/msg = disk.memory["[id]"]
			var/types = disk.mobtype["[id]"]
			if(types == "human" || types == "bot")
				var/mob/holder
				if(ismob(src.loc))
					holder = src.loc
				for(var/mob/M in viewers(world.view,holder ? holder : src ))
					if(istype(M,/mob/living/silicon) || istype(M,/mob/living/carbon/human))
						M << "<span class='game recorder'><span class='name'></span><b> \icon[src]\[[src.name]\]</b> <span class='message'>[msg]</span></span>"
					else
						M << Ellipsis(msg)
			if(types == "alien")
				for(var/mob/M in viewers(world.view,src))
					if(istype(M,/mob/living/carbon/alien))
						M << "<span class='game recorder'><span class='name'></span><b> \icon[src]\[[src.name]\]</b> <span class='message'>[msg]</span></span>"
					else
						M << "You hear a faint hisses from \the [src]"
			if(types == "monkey")
				for(var/mob/M in viewers(world.view,src))
					if(istype(M,/mob/living/carbon/monkey))
						M << "<span class='game recorder'><span class='name'></span><b> \icon[src]\[[src.name]\]</b> <span class='message'>[msg]</span></span>"
					else
						M << "You hear chimpering from \the [src]"
	if("stop")
		playingall = 0
		return

/obj/item/weapon/voicedisk/
	name = "Voice Disk"
	icon = 'items.dmi'
	icon_state = "datadisk0"
	item_state = "card-id"
	w_class = 1.0
	var/list/memory = list()
	var/list/mobtype = list()

