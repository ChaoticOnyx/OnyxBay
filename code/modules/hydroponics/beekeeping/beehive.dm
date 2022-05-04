/obj/machinery/beehive
	name = "beehive"
	icon = 'icons/obj/beekeeping.dmi'
	icon_state = "beehive"
	density = 1
	anchored = 1

	var/closed = 0
	var/bee_count = 0 // Percent
	var/smoked = 0 // Timer
	var/honeycombs = 0 // Percent
	var/frames = 0
	var/mut////Placeholder until I find out how to make it more compatible with our plants and make it inject reagents of plants growing near hive
	var/toxic//
	var/swarming //Amount of bees that can spawn from the hive
	var/maxFrames = 5
	var/list/owned_bee_swarms = list()//all bees that spawned from the hive

/obj/machinery/beehive/update_icon()
	overlays.Cut()
	icon_state = "beehive"
	if(closed)
		overlays += "lid"
	if(frames)
		overlays += "empty[frames]"
	if(honeycombs >= 100)
		overlays += "full[round(honeycombs / 100)]"
	if(!smoked)
		switch(bee_count)
			if(1 to 40)
				overlays += "bees1"
			if(41 to 80)
				overlays += "bees2"
			if(81 to 100)
				overlays += "bees3"

/obj/machinery/beehive/_examine_text(mob/user)
	. = ..()
	if(!closed)
		. += "\nThe lid is open."

/obj/machinery/beehive/attackby(obj/item/I, mob/user)
	if(isCrowbar(I))
		closed = !closed
		user.visible_message("<span class='notice'>\The [user] [closed ? "closes" : "opens"] \the [src].</span>", "<span class='notice'>You [closed ? "close" : "open"] \the [src].</span>")
		update_icon()
		return
	else if(isWrench(I))
		anchored = !anchored
		user.visible_message("<span class='notice'>\The [user] [anchored ? "wrenches" : "unwrenches"] \the [src].</span>", "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return
	else if(istype(I, /obj/item/bee_smoker))
		if(closed)
			to_chat(user, "<span class='notice'>You need to open \the [src] with a crowbar before smoking the bees.</span>")
			return
		user.visible_message("<span class='notice'>\The [user] smokes the bees in \the [src].</span>", "<span class='notice'>You smoke the bees in \the [src].</span>")
		smoked = 30
		update_icon()
		return
	else if(istype(I, /obj/item/honey_frame))
		if(closed)
			to_chat(user, "<span class='notice'>You need to open \the [src] with a crowbar before inserting \the [I].</span>")
			return
		if(frames >= maxFrames)
			to_chat(user, "<span class='notice'>There is no place for an another frame.</span>")
			return
		var/obj/item/honey_frame/H = I
		if(H.honey)
			to_chat(user, "<span class='notice'>\The [I] is full with beeswax and honey, empty it in the extractor first.</span>")
			return
		++frames
		user.visible_message("<span class='notice'>\The [user] loads \the [I] into \the [src].</span>", "<span class='notice'>You load \the [I] into \the [src].</span>")
		update_icon()
		user.drop_from_inventory(I)
		qdel(I)
		return
	else if(istype(I, /obj/item/bee_pack))
		var/obj/item/bee_pack/B = I
		if(B.full && bee_count)
			to_chat(user, "<span class='notice'>\The [src] already has bees inside.</span>")
			return
		if(!B.full && bee_count < 90)
			to_chat(user, "<span class='notice'>\The [src] is not ready to split.</span>")
			return
		if(!B.full && !smoked)
			to_chat(user, "<span class='notice'>Smoke \the [src] first!</span>")
			return
		if(closed)
			to_chat(user, "<span class='notice'>You need to open \the [src] with a crowbar before moving the bees.</span>")
			return
		if(B.full)
			user.visible_message("<span class='notice'>\The [user] puts the queen and the bees from \the [I] into \the [src].</span>", "<span class='notice'>You put the queen and the bees from \the [I] into \the [src].</span>")
			bee_count = 20
			B.empty()
		else
			user.visible_message("<span class='notice'>\The [user] puts bees and larvae from \the [src] into \the [I].</span>", "<span class='notice'>You put bees and larvae from \the [src] into \the [I].</span>")
			bee_count /= 2
			B.fill()
		update_icon()
		return
	else if(istype(I, /obj/item/device/analyzer/plant_analyzer))
		to_chat(user, "<span class='notice'>Scan result of \the [src]...</span>")
		to_chat(user, "Beehive is [bee_count ? "[round(bee_count)]% full" : "empty"].[bee_count > 90 ? " Colony is ready to split." : ""]")
		if(frames)
			to_chat(user, "[frames] frames installed, [round(honeycombs / 100)] filled.")
			if(honeycombs < frames * 100)
				to_chat(user, "Next frame is [round(honeycombs % 100)]% full.")
		else
			to_chat(user, "No frames installed.")
		if(smoked)
			to_chat(user, "The hive is smoked.")
		return 1
	else if(isScrewdriver(I))
		if(bee_count)
			to_chat(user, "<span class='notice'>You can't dismantle \the [src] with these bees inside.</span>")
			return
		to_chat(user, "<span class='notice'>You start dismantling \the [src]...</span>")
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 30, src))
			user.visible_message("<span class='notice'>\The [user] dismantles \the [src].</span>", "<span class='notice'>You dismantle \the [src].</span>")
			new /obj/item/beehive_assembly(loc)
			qdel(src)
		return

/obj/machinery/beehive/attack_hand(mob/user)
	if(!closed)
		if(honeycombs < 100)
			to_chat(user, "<span class='notice'>There are no filled honeycombs.</span>")
			return
		if(!smoked && bee_count)
			angry_swarm(user)
			to_chat(user, "<span class='notice'>The bees are angry, smoke them first.</span>")
			return
		user.visible_message("<span class='notice'>\The [user] starts taking the honeycombs out of \the [src].</span>", "<span class='notice'>You start taking the honeycombs out of \the [src]...</span>")
		while(honeycombs >= 100 && do_after(user, 30, src))
			new /obj/item/honey_frame/filled(loc)
			honeycombs -= 100
			--frames
			update_icon()
		if(honeycombs < 100)
			to_chat(user, "<span class='notice'>You take all filled honeycombs out.</span>")
		return

/obj/machinery/beehive/Process()
	if(closed && !smoked && bee_count)
		pollinate_flowers()
		update_icon()
		breed()
	smoked = max(0, smoked - 1)
	if(!smoked && bee_count)
		bee_count = min(bee_count * 1.005, 100)
		update_icon()

/obj/machinery/beehive/proc/pollinate_flowers()
	var/coef = bee_count / 100
	var/trays = 0
	for(var/obj/machinery/portable_atmospherics/hydroponics/H in view(7, src))
		if(H.seed && !H.dead)
			H.health += 0.05 * coef
			++trays
	honeycombs = min(honeycombs + 0.1 * coef * min(trays, 5), frames * 100)

/obj/machinery/beehive/proc/angry_swarm(mob/M)
	for(var/mob/living/simple_animal/bee/B in owned_bee_swarms)
		B.feral = 25
		B.set_target_mob(M)

	swarming = 25

	while(bee_count > 0)
		var/spawn_strength = bee_count
		if(bee_count >= 5)
			spawn_strength = 6

		var/mob/living/simple_animal/bee/B = new(get_turf(src), src)
		B.set_target_mob(M)
		B.strength = spawn_strength
		B.feral = 25
		B.mut = mut
		B.toxic = toxic
		bee_count -= spawn_strength

/obj/machinery/beehive/proc/breed()
	if(bee_count >= 80 && prob(bee_count * 10))
		var/mob/living/simple_animal/bee/B = new(get_turf(src), src)
		owned_bee_swarms.Add(B)
		B.mut = mut
		B.toxic = toxic
		bee_count -= 30

/obj/item/bee_smoker
	name = "bee smoker"
	desc = "A device used to calm down bees before harvesting honey."
	icon = 'icons/obj/device.dmi'
	icon_state = "battererburnt"
	w_class = ITEM_SIZE_SMALL

/obj/item/honey_frame
	name = "beehive frame"
	desc = "A frame for the beehive that the bees will fill with honeycombs."
	icon = 'icons/obj/beekeeping.dmi'
	icon_state = "honeyframe"
	w_class = ITEM_SIZE_SMALL

	var/honey = 0

/obj/item/honey_frame/filled
	name = "filled beehive frame"
	desc = "A frame for the beehive that the bees have filled with honeycombs."
	honey = 20

/obj/item/honey_frame/filled/New()
	..()
	overlays += "honeycomb"

/obj/item/beehive_assembly
	name = "beehive assembly"
	desc = "Contains everything you need to build a beehive."
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary"

/obj/item/beehive_assembly/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You start assembling \the [src]...</span>")
	if(do_after(user, 30, src))
		user.visible_message("<span class='notice'>\The [user] constructs a beehive.</span>", "<span class='notice'>You construct a beehive.</span>")
		new /obj/machinery/beehive(get_turf(user))
		user.drop_from_inventory(src)
		qdel(src)
	return

/obj/item/stack/wax
	name = "wax"
	singular_name = "wax piece"
	desc = "Soft substance produced by bees. Used to make candles."
	icon = 'icons/obj/beekeeping.dmi'
	icon_state = "wax"
	craft_tool = 1

/obj/item/stack/wax/New()
	..()
	recipes = wax_recipes

var/global/list/datum/stack_recipe/wax_recipes = list( \
	new /datum/stack_recipe("candle", /obj/item/flame/candle) \
)

/obj/item/bee_pack
	name = "bee pack"
	desc = "Contains a queen bee and some worker bees. Everything you'll need to start a hive!"
	icon = 'icons/obj/beekeeping.dmi'
	icon_state = "beepack"
	var/full = 1

/obj/item/bee_pack/New()
	..()
	overlays += "beepack-full"

/obj/item/bee_pack/proc/empty()
	full = 0
	name = "empty bee pack"
	desc = "A stasis pack for moving bees. It's empty."
	overlays.Cut()
	overlays += "beepack-empty"

/obj/item/bee_pack/proc/fill()
	full = initial(full)
	SetName(initial(name))
	desc = initial(desc)
	overlays.Cut()
	overlays += "beepack-full"

/obj/structure/closet/crate/hydroponics/beekeeping
	name = "beekeeping crate"
	desc = "All you need to set up your own beehive."

/obj/structure/closet/crate/hydroponics/beekeeping/New()
	..()
	new /obj/item/beehive_assembly(src)
	new /obj/item/bee_smoker(src)
	new /obj/item/honey_frame(src)
	new /obj/item/honey_frame(src)
	new /obj/item/honey_frame(src)
	new /obj/item/honey_frame(src)
	new /obj/item/honey_frame(src)
	new /obj/item/bee_pack(src)
	new /obj/item/crowbar(src)
