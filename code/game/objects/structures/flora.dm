//trees
/obj/structure/flora/tree
	name = "tree"
	anchored = 1
	density = 1
	pixel_x = -16

	layer = ABOVE_HUMAN_LAYER

/obj/structure/flora/tree/pine
	name = "pine tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"

/obj/structure/flora/tree/pine/New()
	..()
	icon_state = "pine_[rand(1, 3)]"

/obj/structure/flora/tree/pine/xmas
	name = "xmas tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_c"

/obj/structure/flora/tree/pine/xmas/New()
	..()
	icon_state = "pine_c"

/obj/structure/flora/tree/dead/deadtree_0
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"

/obj/structure/flora/tree/dead/deadtree_1
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_4"

/obj/structure/flora/tree/dead/deadtree_2
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_5"

/obj/structure/flora/tree/dead/deadtree_3
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_6"

/obj/structure/flora/tree/dead/deadtree_4
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_10"

/obj/structure/flora/tree/dead/deadtree_5
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_11"

/obj/structure/flora/tree/dead/deadtree_6
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_12"

/obj/structure/flora/tree/dead/deadtree/New()
	..()
	icon_state = "tree_[rand(1, 12)]"

/obj/structure/flora/tree/tall/New()
	icon_state = "tree_[rand(1,6)]"
	..()

/obj/structure/flora/tree/pine/old_pinteree
	name = "xmas tree"
	desc = "Masha, get rid of this fucking yolka!"
	icon = 'icons/obj/flora/old_pinetrees.dmi'
	icon_state = "old_pinetree"

/obj/structure/flora/tree/pine/old_pinteree/New()
	..()
	icon_state = "old_pinetree"

/obj/structure/flora/tree/green
	name = "tree"
	pixel_x = -48
	pixel_y = -16
	icon = 'icons/obj/flora/hdtrees.dmi'
	icon_state = "tree1"

/obj/structure/flora/tree/green/tree2
	icon_state = "tree2"

/obj/structure/flora/tree/green/tree3
	icon_state = "tree3"

/obj/structure/flora/tree/green/tree4
	icon_state = "tree4"

/obj/structure/flora/tree/green/tree5
	icon_state = "tree5"

/obj/structure/flora/tree/green/tree6
	icon_state = "tree6"

/obj/structure/flora/tree/green/tree7
	icon_state = "tree7"

/obj/structure/flora/tree/green/tree8
	icon_state = "tree8"

/obj/structure/flora/tree/green/tree9
	icon_state = "tree9"

/obj/structure/flora/tree/green/tree10
	icon_state = "tree10"

/obj/structure/flora/tree/green/small
	pixel_x = -32
	pixel_y = 0
	icon = 'icons/obj/flora/hdtreesmall.dmi'
	icon_state = "tree"

/obj/structure/flora/tree/green/small/tree1
	icon_state = "tree1"

/obj/structure/flora/tree/green/small/tree2
	icon_state = "tree2"

/obj/structure/flora/tree/green/small/tree3
	icon_state = "tree3"

/obj/structure/flora/tree/green/small/tree4
	icon_state = "tree4"

/obj/structure/flora/tree/green/small/tree5
	icon_state = "tree5"

/obj/structure/flora/tree/green/small/tree6
	icon_state = "tree6"


/*
I need help here with chopping the trees (delete the tree and checking the active of chainsaw)
/obj/structure/flora/tree/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/material/twohanded/chainsaw))
		var/obj/item/weapon/material/twohanded/chainsaw = W
		if (chainsaw.chainsaw_active)
			src.visible_message("<span class='warning'>[usr] cutting wood with a chainsaw!</span>")
			user.put_in_hands(new /obj/item/stack/material/wood/ten)
*/

//grass
/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	anchored = 1
	layer = BELOW_DOOR_LAYER

/obj/structure/flora/grass/brown
	icon_state = "snowgrass1bb"

/obj/structure/flora/grass/brown/New()
	..()
	icon_state = "snowgrass[rand(1, 3)]bb"


/obj/structure/flora/grass/green
	icon_state = "snowgrass1gb"

/obj/structure/flora/grass/green/New()
	..()
	icon_state = "snowgrass[rand(1, 3)]gb"

/obj/structure/flora/grass/both
	icon_state = "snowgrassall1"

/obj/structure/flora/grass/both/New()
	..()
	icon_state = "snowgrassall[rand(1, 3)]"


//bushes
/obj/structure/flora/bush
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"
	anchored = 1

/obj/structure/flora/bush/New()
	..()
	icon_state = "snowbush[rand(1, 6)]"

/obj/structure/flora/pottedplant
	name = "potted plant"
	icon = 'icons/obj/plants.dmi'
	icon_state = "plant-26"

	layer = ABOVE_HUMAN_LAYER
	var/dead = FALSE
	var/obj/item/stored_item

/obj/structure/flora/pottedplant/Destroy()
	stored_item.forceMove(loc)
	return ..()

/obj/structure/flora/pottedplant/proc/death()
	if (!dead)
		icon_state = "plant-dead"
		name = "dead [name]"
		desc = "This is the dried up remains of a dead plant. Someone should replace it."
		dead = TRUE

//No complex interactions, just make them fragile
/obj/structure/flora/pottedplant/ex_act()
	death()

/obj/structure/flora/pottedplant/fire_act()
	death()

/obj/structure/flora/pottedplant/attackby(obj/item/W, mob/user)
	if (W.edge && user.a_intent == I_HURT)
		user.visible_message(SPAN("warning", "[user] cuts down the [src]!"))
		user.do_attack_animation(src)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		death()
		return 1
	if(W.mod_weight >= 0.75 && user.a_intent == I_HURT)
		shake_animation(stime = 4)
		return ..()
	if(!ishuman(user))
		return 0
	if(istype(W, /obj/item/weapon/holder))
		return 0 //no hiding mobs in there
	user.visible_message("[user] begins digging around inside of \the [src].", "You begin digging around in \the [src], trying to hide \the [W].")
	playsound(loc, 'sound/effects/plantshake.ogg', rand(50, 75), TRUE)
	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	if(do_after(user, 20, src))
		if(!stored_item)
			if(W.w_class <= ITEM_SIZE_NORMAL)
				user.drop_from_inventory(W, src)
				stored_item = W
				to_chat(user, SPAN("notice", "You hide \the [W] in \the [src]."))
			else
				to_chat(user, SPAN("notice", "\The [W] can't be hidden in \the [src], it's too big."))
		else
			to_chat(user, SPAN("notice", "Something is already hidden in \the [src]."))
	return 0

/obj/structure/flora/pottedplant/attack_hand(mob/user as mob)
	user.visible_message("[user] begins digging around inside of \the [src].", "You begin digging around in \the [src], searching it.")
	playsound(loc, 'sound/effects/plantshake.ogg', rand(50, 75), TRUE)
	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	if(do_after(user, 40, src))
		if(!stored_item)
			to_chat(user, SPAN("notice", "There is nothing hidden in \the [src]."))
		else
			user.put_in_hands(stored_item)
			to_chat(user, SPAN("notice", "You take \the [stored_item] from \the [src]."))
			stored_item = null
		src.add_fingerprint(usr)

/obj/structure/flora/pottedplant/bullet_act(obj/item/projectile/Proj)
	if (prob(Proj.damage*2))
		death()
		return 1
	return ..()

//newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"
	anchored = 1
	layer = BELOW_DOOR_LAYER

/obj/structure/flora/ausbushes/New()
	..()
	icon_state = "firstbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/reedbush
	icon_state = "reedbush_1"

/obj/structure/flora/ausbushes/reedbush/New()
	..()
	icon_state = "reedbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/leafybush
	icon_state = "leafybush_1"

/obj/structure/flora/ausbushes/leafybush/New()
	..()
	icon_state = "leafybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/palebush
	icon_state = "palebush_1"

/obj/structure/flora/ausbushes/palebush/New()
	..()
	icon_state = "palebush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/stalkybush
	icon_state = "stalkybush_1"

/obj/structure/flora/ausbushes/stalkybush/New()
	..()
	icon_state = "stalkybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/grassybush
	icon_state = "grassybush_1"

/obj/structure/flora/ausbushes/grassybush/New()
	..()
	icon_state = "grassybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/fernybush
	icon_state = "fernybush_1"

/obj/structure/flora/ausbushes/fernybush/New()
	..()
	icon_state = "fernybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/sunnybush
	icon_state = "sunnybush_1"

/obj/structure/flora/ausbushes/sunnybush/New()
	..()
	icon_state = "sunnybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/genericbush
	icon_state = "genericbush_1"

/obj/structure/flora/ausbushes/genericbush/New()
	..()
	icon_state = "genericbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush_1"

/obj/structure/flora/ausbushes/pointybush/New()
	..()
	icon_state = "pointybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/lavendergrass
	icon_state = "lavendergrass_1"

/obj/structure/flora/ausbushes/lavendergrass/New()
	..()
	icon_state = "lavendergrass_[rand(1, 4)]"

/obj/structure/flora/ausbushes/ywflowers
	icon_state = "ywflowers_1"

/obj/structure/flora/ausbushes/ywflowers/New()
	..()
	icon_state = "ywflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/brflowers
	icon_state = "brflowers_1"

/obj/structure/flora/ausbushes/brflowers/New()
	..()
	icon_state = "brflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/ppflowers
	icon_state = "ppflowers_1"

/obj/structure/flora/ausbushes/ppflowers/New()
	..()
	icon_state = "ppflowers_[rand(1, 4)]"

/obj/structure/flora/ausbushes/sparsegrass
	icon_state = "sparsegrass_1"

/obj/structure/flora/ausbushes/sparsegrass/New()
	..()
	icon_state = "sparsegrass_[rand(1, 3)]"

/obj/structure/flora/ausbushes/fullgrass
	icon_state = "fullgrass_1"

/obj/structure/flora/ausbushes/fullgrass/New()
	..()
	icon_state = "fullgrass_[rand(1, 3)]"

/obj/structure/flora/goonbushes
	name = "shrub"
	icon = 'icons/obj/flora/goonbushes.dmi'
	icon_state = ""
	anchored = 1
	layer = ABOVE_HUMAN_LAYER

/obj/structure/flora/goonbushes/shrub
	name = "shrub"
	icon_state = "shrub"

/obj/structure/flora/goonbushes/leafy
	name = "shrub"
	icon_state = "leafy"

/obj/structure/flora/goonbushes/thick
	name = "shrub"
	icon_state = "thick"

/obj/structure/flora/goonbushes/fern
	name = "shrub"
	icon_state = "fern"

/obj/structure/flora/goonbushes/palm
	name = "shrub"
	icon_state = "palm"

/obj/structure/flora/goonbushes/bush
	name = "shrub"
	icon_state = "bush"

/obj/structure/flora/goonbushes/sick
	name = "shrub"
	icon_state = "sick"
	layer = BELOW_DOOR_LAYER

//potted plants credit: Flashkirby
/obj/structure/flora/pottedplant
	name = "potted plant"
	desc = "Really brings the room together."
	icon = 'icons/obj/plants.dmi'
	icon_state = "plant-01"

	layer = ABOVE_HUMAN_LAYER

/obj/structure/flora/pottedplant/large
	name = "large potted plant"
	desc = "This is a large plant. Three branches support pairs of waxy leaves."
	icon_state = "plant-26"

/obj/structure/flora/pottedplant/fern
	name = "potted fern"
	desc = "This is an ordinary looking fern. It looks like it could do with some water."
	icon_state = "plant-02"

/obj/structure/flora/pottedplant/overgrown
	name = "overgrown potted plants"
	desc = "This is an assortment of colourful plants. Some parts are overgrown."
	icon_state = "plant-03"

/obj/structure/flora/pottedplant/bamboo
	name = "potted bamboo"
	desc = "These are bamboo shoots. The tops looks like they've been cut short."
	icon_state = "plant-04"

/obj/structure/flora/pottedplant/largebush
	name = "large potted bush"
	desc = "This is a large bush. The leaves stick upwards in an odd fashion."
	icon_state = "plant-05"

/obj/structure/flora/pottedplant/thinbush
	name = "thin potted bush"
	desc = "This is a thin bush. It appears to be flowering."
	icon_state = "plant-06"

/obj/structure/flora/pottedplant/mysterious
	name = "mysterious potted bulbs"
	desc = "This is a mysterious looking plant. Touching the bulbs cause them to shrink."
	icon_state = "plant-07"

/obj/structure/flora/pottedplant/smalltree
	name = "small potted tree"
	desc = "This is a small tree. It is rather pleasant."
	icon_state = "plant-08"

/obj/structure/flora/pottedplant/unusual
	name = "unusual potted plant"
	desc = "This is an unusual plant. It's bulbous ends emit a soft blue light."
	icon_state = "plant-09"

/obj/structure/flora/pottedplant/unusual/Initialize()
	. = ..()
	set_light(0.4, 0.1, 2, 2, "#007fff")

/obj/structure/flora/pottedplant/orientaltree
	name = "potted oriental tree"
	desc = "This is a rather oriental style tree. It's flowers are bright pink."
	icon_state = "plant-10"

/obj/structure/flora/pottedplant/smallcactus
	name = "small potted cactus"
	desc = "This is a small cactus. Its needles are sharp."
	icon_state = "plant-11"

/obj/structure/flora/pottedplant/tall
	name = "tall potted plant"
	desc = "This is a tall plant. Tiny pores line its surface."
	icon_state = "plant-12"

/obj/structure/flora/pottedplant/sticky
	name = "sticky potted plant"
	desc = "This is an odd plant. Its sticky leaves trap insects."
	icon_state = "plant-13"

/obj/structure/flora/pottedplant/smelly
	name = "smelly potted plant"
	desc = "This is some kind of tropical plant. It reeks of rotten eggs."
	icon_state = "plant-14"

/obj/structure/flora/pottedplant/small
	name = "small potted plant"
	desc = "This is a pot of assorted small flora. Some look familiar."
	icon_state = "plant-15"

/obj/structure/flora/pottedplant/aquatic
	name = "aquatic potted plant"
	desc = "This is apparently an aquatic plant. It's probably fake."
	icon_state = "plant-16"

/obj/structure/flora/pottedplant/shoot
	name = "small potted shoot"
	desc = "This is a small shoot. It still needs time to grow."
	icon_state = "plant-17"

/obj/structure/flora/pottedplant/flower
	name = "potted flower"
	desc = "This is a slim plant. Sweet smelling flowers are supported by spindly stems."
	icon_state = "plant-18"

/obj/structure/flora/pottedplant/crystal
	name = "crystalline potted plant"
	desc = "These are rather cubic plants. Odd crystal formations grow on the end."
	icon_state = "plant-19"

/obj/structure/flora/pottedplant/subterranean
	name = "subterranean potted plant"
	desc = "This is a subterranean plant. It's bulbous ends glow faintly."
	icon_state = "plant-20"

/obj/structure/flora/pottedplant/subterranean/Initialize()
	. = ..()
	set_light(0.4, 0.1, 2, 2, "#ff6633")

/obj/structure/flora/pottedplant/minitree
	name = "potted tree"
	desc = "This is a miniature tree. Apparently it was grown to 1/5 scale."
	icon_state = "plant-21"

/obj/structure/flora/pottedplant/stoutbush
	name = "stout potted bush"
	desc = "This is a stout bush. Its leaves point up and outwards."
	icon_state = "plant-22"

/obj/structure/flora/pottedplant/drooping
	name = "drooping potted plant"
	desc = "This is a small plant. The drooping leaves make it look like its wilted."
	icon_state = "plant-23"

/obj/structure/flora/pottedplant/tropical
	name = "tropical potted plant"
	desc = "This is some kind of tropical plant. It hasn't begun to flower yet."
	icon_state = "plant-24"

/obj/structure/flora/pottedplant/flowerbushblue
	name = "flower potted bush"
	desc = "This is a flower bush. It has blue flowers."
	icon_state = "plant-25"

/obj/structure/flora/pottedplant/flowerbushred
	name = "flower potted bush"
	desc = "This is a flower bush. It has red flowers."
	icon_state = "plant-27"

/obj/structure/flora/pottedplant/largeleaves
	name = "potted plant with large leaves"
	desc = "This is plant with large leaves. They are really huge."
	icon_state = "plant-28"

/obj/structure/flora/pottedplant/overgrownbush
	name = "overgrown potted bush"
	desc = "This is a overgrown bush. It needs to be cut."
	icon_state = "plant-29"

/obj/structure/flora/pottedplant/tropicaltree
	name = "tropical potted tree"
	desc = "This is tropical tree. Someday it will grow."
	icon_state = "plant-30"

/obj/structure/flora/pottedplant/tropicalflowers
	name = "tropical potted flowers"
	desc = "This is tropical flowers. It has white big flowers."
	icon_state = "plant-31"

/obj/structure/flora/pottedplant/faketree
	name = "potted tree"
	desc = "This is tree. In fact it is a badly growling bush."
	icon_state = "plant-32"

/obj/structure/flora/pottedplant/autumn
	name = "potted autumn tree"
	desc = "This is autumn tree. It thinks that now it's autumn."
	icon_state = "plant-33"

/obj/structure/flora/pottedplant/pink
	name = "potted pink tree"
	desc = "This is pink tree. It tries to look like sakura."
	icon_state = "plant-34"

/obj/structure/flora/pottedplant/ugly
	name = "potted ugly plant"
	desc = "This is ugly tree. Someday it becomes a white swan."
	icon_state = "plant-35"

/obj/structure/flora/pottedplant/eye
	name = "potted plant with eye"
	desc = "This is plant with eye. It stares into your soul."
	icon_state = "plant-36"

/obj/structure/flora/pottedplant/decorative
	name = "decorative potted plant"
	desc = "This is a decorative shrub. It's been trimmed into the shape of an apple."
	icon_state = "applebush"

/obj/structure/flora/pottedplant/dead
	name = "dead potted plant"
	desc = "This is the dried up remains of a dead plant. Someone should replace it."
	icon_state = "plant-dead"

/obj/structure/flora/pottedplant/monkey
	name = "potted monkey plant"
	desc = "Perhaps, this is why we no longer have a genetics lab?"
	icon_state = "monkeyplant"
