/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		Empty box, starter boxes (survival/engineer),
 *		Latex glove and sterile mask boxes,
 *		Syringe, beaker, dna injector boxes,
 *		Blanks, flashbangs, and EMP grenade boxes,
 *		Tracking and chemical implant boxes,
 *		Prescription glasses and drinking glass boxes,
 *		Condiment bottle and silly cup boxes,
 *		Donkpocket and monkeycube boxes,
 *		ID and security PDA cart boxes,
 *		Handcuff, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes.
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

/obj/item/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/boxes.dmi'
	icon_state = "box"
	item_state = "box"
	inspect_state = "box-open"
	max_storage_space = DEFAULT_BOX_STORAGE
	var/obj/item/foldable = /obj/item/stack/material/cardboard // BubbleWrap - if set, can be folded (when empty) into a sheet of cardboard
	use_sound = SFX_SEARCH_CLOTHES

	drop_sound = SFX_DROP_CARDBOARD
	pickup_sound = SFX_PICKUP_CARDBOARD

/obj/item/storage/box/on_update_icon()
	ClearOverlays()
	if(being_inspected && istext(inspect_state))
		AddOverlays(OVERLAY(icon, inspect_state))

// BubbleWrap - A box can be folded up to make card
/obj/item/storage/box/attack_self(mob/user)
	if(..())
		return
	//try to fold it.
	if(contents.len)
		return

	if(!ispath(src.foldable))
		return
	var/found = 0
	// Close any open UI windows first
	for(var/mob/M in range(1))
		if (M.s_active == src)
			src.close(M)
		if ( M == user )
			found = 1
	if(!found)	// User is too far away
		return
	// Now make the cardboard
	var/obj/item/I
	if(ispath(foldable, /obj/item/stack))
		var/stack_amt = max(2**(w_class - 3), 1)
		I = new src.foldable(get_turf(src), stack_amt)
		to_chat(user, SPAN("notice", "You fold [src] flat."))
	else
		I = new src.foldable(get_turf(src))
		to_chat(user, SPAN("notice", "You fold [src] into \a [I]."))
	qdel(src)
	user.pick_or_drop(I)

/obj/item/storage/box/make_exact_fit()
	..()
	foldable = null //special form fitted boxes should not be foldable.


/obj/item/storage/box/large
	name = "large box"
	icon_state = "largebox"
	inspect_state = "large-open"
	w_class = ITEM_SIZE_LARGE
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_LARGEBOX_STORAGE

/obj/item/storage/box/survival
	name = "crew survival kit"
	desc = "A durable plastic box decorated in warning colors that contains a limited supply of survival tools. The panel and white stripe indicate this one contains oxygen. It has special foldlines, making it able to be folded into an emergency crowbar."
	icon_state = "survival"
	inspect_state = "survival-open"
	item_state = "box_survival"
	foldable = /obj/item/crowbar/emergency
	startswith = list(/obj/item/clothing/mask/breath = 1,
					/obj/item/tank/emergency/oxygen = 1,
					/obj/item/reagent_containers/hypospray/autoinjector = 1,
					/obj/item/stack/medical/patches = 1,
					/obj/item/device/flashlight/glowstick = 1,
					/obj/item/reagent_containers/food/packaged/nutribar = 1)

/obj/item/storage/box/vox
	name = "vox survival kit"
	desc = "A durable plastic box decorated in warning colors that contains a limited supply of survival tools. The panel and black stripe indicate this one contains nitrogen. It has special foldlines, making it able to be folded into an emergency crowbar."
	icon_state = "survivalvox"
	inspect_state = "survival-open"
	item_state = "box_survival"
	foldable = /obj/item/crowbar/emergency/vox
	startswith = list(/obj/item/clothing/mask/breath = 1,
					/obj/item/tank/emergency/nitrogen = 1,
					/obj/item/stack/medical/patches = 1,
					/obj/item/device/flashlight/glowstick = 1,
					/obj/item/reagent_containers/food/packaged/nutribar = 1)

/obj/item/storage/box/engineer
	name = "engineer survival kit"
	desc = "A durable plastic box decorated in warning colors that contains a limited supply of survival tools. The panel and orange stripe indicate this one as the engineering variant. It has special foldlines, making it able to be folded into an emergency crowbar."
	icon_state = "survivaleng"
	inspect_state = "survival-open"
	item_state = "box_survival"
	foldable = /obj/item/crowbar/emergency/eng
	startswith = list(/obj/item/clothing/mask/breath = 1,
					/obj/item/tank/emergency/oxygen/engi = 1,
					/obj/item/reagent_containers/hypospray/autoinjector = 1,
					/obj/item/reagent_containers/hypospray/autoinjector/detox = 1,
					/obj/item/stack/medical/patches = 1,
					/obj/item/device/flashlight/glowstick/orange = 1,
					/obj/item/reagent_containers/food/packaged/nutribar = 1)

/obj/item/storage/box/security
	name = "security survival kit"
	desc = "A durable plastic box decorated in warning colors that contains a limited supply of survival tools. The panel and red & black stripe indicate this one as the security variant. It has special foldlines, making it able to be folded into an emergency crowbar."
	icon_state = "survivalsec"
	inspect_state = "survival-open"
	item_state = "box_survival"
	foldable = /obj/item/crowbar/emergency/sec
	startswith = list(/obj/item/clothing/mask/breath = 1,
					/obj/item/tank/emergency/oxygen = 1,
					/obj/item/reagent_containers/hypospray/autoinjector = 1,
					/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 1,
					/obj/item/stack/medical/patches = 1,
					/obj/item/device/flashlight/glowstick/red = 1,
					/obj/item/reagent_containers/food/packaged/nutribar = 1)

/obj/item/storage/box/gloves
	name = "box of sterile gloves"
	desc = "Contains sterile gloves."
	icon_state = "latex"
	startswith = list(/obj/item/clothing/gloves/latex = 5,
					/obj/item/clothing/gloves/latex/nitrile = 2)

/obj/item/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"
	startswith = list(/obj/item/clothing/mask/surgical = 7)


/obj/item/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	icon_state = "syringe"
	startswith = list(/obj/item/reagent_containers/syringe = 7)

/obj/item/storage/box/syringegun
	name = "box of syringe gun cartridges"
	desc = "A box full of compressed gas cartridges."
	icon_state = "syringe"
	startswith = list(/obj/item/syringe_cartridge = 7)


/obj/item/storage/box/beakers
	name = "box of beakers"
	icon_state = "beaker"
	startswith = list(/obj/item/reagent_containers/vessel/beaker = 7)

/obj/item/storage/box/blanks
	name = "box of blank shells"
	desc = "It has a picture of a gun and several warning symbols on the front."
	startswith = list(/obj/item/ammo_casing/shotgun/blank = 7)

	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX

/obj/item/storage/box/flash
	name = "box of illumination shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	startswith = list(/obj/item/ammo_casing/shotgun/flash = 7)

/obj/item/storage/box/shotgun
	icon = 'icons/obj/shotgunshells.dmi'
	storage_slots = 20
	max_storage_space = 20
	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX
	inspect_state = FALSE

/obj/item/storage/box/shotgun/on_update_icon()
	ClearOverlays()

	if(!length(contents))
		return

	for(var/i = 1, i < contents.len, i++)
		if(i == 1 || i % 3 == 0)
			var/icon/I = icon(icon, "[contents[i].icon_state]")
			if(i != 1)
				I.Shift(WEST, i)
			AddOverlays(I)

/obj/item/storage/box/shotgun/shells
	icon_state = "shotgunshells"
	name = "box of shotgun shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	startswith = list(/obj/item/ammo_casing/shotgun/pellet = 20)

/obj/item/storage/box/shotgun/slugs
	icon_state = "shotgunslugs"
	name = "box of shotgun slugs"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	startswith = list(/obj/item/ammo_casing/shotgun = 20)

/obj/item/storage/box/shotgun/beanbags
	icon_state = "shotgunbeanbag"
	name = "box of beanbag shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	startswith = list(/obj/item/ammo_casing/shotgun/beanbag = 20)

/obj/item/storage/box/shotgun/stunshells
	icon_state = "shotgunstuns"
	name = "box of stun shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	startswith = list(/obj/item/ammo_casing/shotgun/stunshell = 20)

/obj/item/storage/box/practiceshells
	name = "box of practice shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	startswith = list(/obj/item/ammo_casing/shotgun/practice = 7)
	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX


/obj/item/storage/box/sniperammo
	name = "box of 14.5mm shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	startswith = list(/obj/item/ammo_casing/a145 = 7)
	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX

/obj/item/storage/box/sniperammo/apds
	name = "box of 14.5mm APDS shells"
	startswith = list(/obj/item/ammo_casing/a145/apds = 3)

/obj/item/storage/box/flashbangs
	name = "box of flashbangs"
	desc = "A box containing 7 antipersonnel flashbang grenades.<br> WARNING: These devices are extremely dangerous and can cause blindness or deafness from repeated use."
	icon_state = "flashbang"
	inspect_state = "sec-open"
	startswith = list(/obj/item/grenade/flashbang = 7)
	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX

/obj/item/storage/box/teargas
	name = "box of pepperspray grenades"
	desc = "A box containing 7 tear gas grenades. A gas mask is printed on the label.<br> WARNING: Exposure carries risk of serious injury or death. Keep away from persons with lung conditions."
	icon_state = "peppers"
	inspect_state = "sec-open"
	startswith = list(/obj/item/grenade/chem_grenade/teargas = 7)
	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX

/obj/item/storage/box/emps
	name = "box of emp grenades"
	desc = "A box containing 5 military grade EMP grenades.<br> WARNING: Do not use near unshielded electronics or biomechanical augmentations, death or permanent paralysis may occur."
	icon_state = "EMPs"
	inspect_state = "sec-open"
	startswith = list(/obj/item/grenade/empgrenade = 5)
	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX

/obj/item/storage/box/frags
	name = "box of frag grenades"
	desc = "A box containing 5 military grade fragmentation grenades.<br> WARNING: Live explosives. Misuse may result in serious injury or death."
	icon_state = "frags"
	inspect_state = "sec-open"
	startswith = list(/obj/item/grenade/frag = 5)
	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX

/obj/item/storage/box/fragshells
	name = "box of frag shells"
	desc = "A box containing 5 military grade fragmentation shells.<br> WARNING: Live explosive munitions. Misuse may result in serious injury or death."
	icon_state = "fragshells"
	inspect_state = "sec-open"
	startswith = list(/obj/item/grenade/frag/shell = 5)
	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX

/obj/item/storage/box/smokes
	name = "box of smoke bombs"
	desc = "A box containing 5 smoke bombs."
	icon_state = "smokebombs"
	inspect_state = "sec-open"
	startswith = list(/obj/item/grenade/smokebomb = 5)
	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX

/obj/item/storage/box/anti_photons
	name = "box of anti-photon grenades"
	desc = "A box containing 5 experimental photon disruption grenades."
	icon_state = "antiphotons"
	inspect_state = "sec-open"
	startswith = list(/obj/item/grenade/anti_photon = 5)
	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX

/obj/item/storage/box/supermatters
	name = "box of supermatter grenades"
	desc = "A box containing 5 highly experimental supermatter grenades."
	icon_state = "radbox"
	startswith = list(/obj/item/grenade/supermatter = 5)
	drop_sound = SFX_DROP_AMMOBOX
	pickup_sound = SFX_PICKUP_AMMOBOX

/obj/item/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"
	startswith = list(/obj/item/implantcase/tracking = 4,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1,
		/obj/item/locator = 1)

/obj/item/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"
	startswith = list(/obj/item/implantcase/chem = 5,
					/obj/item/implanter = 1,
					/obj/item/implantpad = 1)

/obj/item/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"
	startswith = list(/obj/item/clothing/glasses/regular = 7)

/obj/item/storage/box/cdeathalarm_kit
	name = "death alarm kit"
	desc = "Box of stuff used to implant death alarms."
	icon_state = "implant"
	item_state = "syringe_kit"
	startswith = list(/obj/item/implanter = 1,
				/obj/item/implantcase/death_alarm = 6)

/obj/item/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."
	startswith = list(/obj/item/reagent_containers/vessel/condiment = 6)

/obj/item/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	icon_state = "papercups"
	startswith = list(/obj/item/reagent_containers/vessel/sillycup = 7)

/obj/item/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"
	startswith = list(/obj/item/reagent_containers/food/donkpocket = 6)

/obj/item/storage/box/sinpockets
	name = "box of sin-pockets"
	desc = "<B>Instructions:</B> <I>Crush bottom of package to initiate chemical heating. Wait for 20 seconds before consumption. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"
	startswith = list(/obj/item/reagent_containers/food/donkpocket/sinpocket = 6)

/obj/item/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/food.dmi'
	icon_state = "monkeycubebox"
	inspect_state = TRUE
	can_hold = list(/obj/item/reagent_containers/food/monkeycube)
	startswith = list(/obj/item/reagent_containers/food/monkeycube/wrapped = 5)

/obj/item/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes, shipped from Ahdomai. Just add water!"
	startswith = list(/obj/item/reagent_containers/food/monkeycube/wrapped/farwacube = 5)

/obj/item/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes, shipped from Moghes. Just add water!"
	startswith = list(/obj/item/reagent_containers/food/monkeycube/wrapped/stokcube = 5)

/obj/item/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes, shipped from Jargon 4. Just add water!"
	startswith = list(/obj/item/reagent_containers/food/monkeycube/wrapped/neaeracube = 5)

/obj/item/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"
	startswith = list(/obj/item/card/id = 7)

/obj/item/storage/box/large/ids
	name = "box of spare IDs"
	desc = "Has so, so many empty IDs."
	icon_state = "id_large"
	startswith = list(/obj/item/card/id = 14)

/obj/item/storage/box/seccarts
	name = "box of spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon_state = "seccarts"
	inspect_state = "sec-open"
	startswith = list(/obj/item/cartridge/security = 7)

/obj/item/storage/box/handcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"
	inspect_state = "sec-open"
	startswith = list(/obj/item/handcuffs = 7)

/obj/item/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<B><FONT color='red'>WARNING:</FONT></B> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"
	startswith = list(/obj/item/device/assembly/mousetrap = 6)

/obj/item/storage/box/mousetraps/empty
	startswith = null

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	icon_state = "pillbox"
	desc = "It has pictures of pill bottles on its front."
	startswith = list(/obj/item/storage/pill_bottle = 7)

/obj/item/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	inspect_state = TRUE
	can_hold = list(/obj/item/toy/snappop)
	startswith = list(/obj/item/toy/snappop = 8)

/obj/item/storage/box/matches
	name = "matchbox"
	desc = "A small box of 'Space-Proof' premium matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	inspect_state = FALSE
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_BELT
	can_hold = list(/obj/item/flame/match)
	startswith = list(/obj/item/flame/match = 10)

	drop_sound = SFX_DROP_MATCHBOX
	pickup_sound = SFX_PICKUP_MATCHBOX

	attackby(obj/item/flame/match/W as obj, mob/user as mob)
		if(istype(W) && !W.lit && !W.burnt)
			W.lit = 1
			W.damtype = "burn"
			W.icon_state = "match_lit"
			W.set_light(0.2, 0.5, 2, 3.5, "#e38f46")
			set_next_think(world.time)
			playsound(src.loc, 'sound/items/match.ogg', 60, 1, -4)
			user.visible_message("<span class='notice'>[user] strikes the match on the matchbox.</span>")
		W.update_icon()
		return

/obj/item/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe"

	startswith = list(/obj/item/reagent_containers/hypospray/autoinjector = 7)

/obj/item/storage/box/lights
	name = "box of replacement bulbs"
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/storage/box/lights/Initialize()
	. = ..()
	make_exact_fit()

/obj/item/storage/box/lights/bulbs
	startswith = list(/obj/item/light/bulb = 21)

/obj/item/storage/box/lights/bulbs/empty
	startswith = null

/obj/item/storage/box/lights/tubes
	name = "box of replacement tubes"
	icon_state = "lighttube"
	startswith = list(/obj/item/light/tube = 21)

/obj/item/storage/box/lights/tubes/empty
	startswith = null

/obj/item/storage/box/lights/mixed
	name = "box of replacement lights"
	icon_state = "lightmixed"
	startswith = list(/obj/item/light/tube = 16,
					/obj/item/light/bulb = 5)

/obj/item/storage/box/lights/mixed/empty
	startswith = null

/obj/item/storage/box/lights/bulbs/he
	name = "box of replacement high efficiency bulbs"
	icon_state = "hlight"
	startswith = list(/obj/item/light/bulb/he = 21)

/obj/item/storage/box/lights/bulbs/he/empty
	startswith = null

/obj/item/storage/box/lights/tubes/he
	name = "box of replacement high efficiency tubes"
	icon_state = "hlighttube"
	startswith = list(/obj/item/light/tube/he = 21)

/obj/item/storage/box/lights/tubes/he/empty
	startswith = null

/obj/item/storage/box/lights/mixed/he
	name = "box of replacement high efficiency lights"
	icon_state = "hlightmixed"
	startswith = list(/obj/item/light/tube/he = 16,
					/obj/item/light/bulb/he = 5)

/obj/item/storage/box/lights/mixed/he/empty
	startswith = null

/obj/item/storage/box/lights/bulbs/quartz
	name = "box of replacement quartz bulbs"
	icon_state = "qlight"
	startswith = list(/obj/item/light/bulb/quartz = 21)

/obj/item/storage/box/lights/bulbs/quartz/empty
	startswith = null

/obj/item/storage/box/lights/tubes/quartz
	name = "box of replacement quartz tubes"
	icon_state = "qlighttube"
	startswith = list(/obj/item/light/tube/quartz = 21)

/obj/item/storage/box/lights/tubes/quartz/empty
	startswith = null

/obj/item/storage/box/lights/mixed/quartz
	name = "box of replacement quartz lights"
	icon_state = "qlightmixed"
	startswith = list(/obj/item/light/tube/quartz = 16,
					/obj/item/light/bulb/quartz = 5)

/obj/item/storage/box/lights/mixed/quartz/empty
	startswith = null

/obj/item/storage/box/lights/bulbs/old
	name = "box of replacement brand new bulbs"
	icon_state = "oldlight"
	startswith = list(/obj/item/light/bulb/old = 21)

/obj/item/storage/box/lights/bulbs/old/empty
	startswith = null

/obj/item/storage/box/glowsticks
	name = "box of mixed glowsticks"
	icon_state = "glowsticks"
	startswith = list(/obj/item/device/flashlight/glowstick = 1, /obj/item/device/flashlight/glowstick/red = 1,
					/obj/item/device/flashlight/glowstick/blue = 1, /obj/item/device/flashlight/glowstick/orange = 1,
					/obj/item/device/flashlight/glowstick/yellow = 1, /obj/item/device/flashlight/glowstick/random = 1)

/obj/item/storage/box/greenglowsticks
	name = "box of green glowsticks"
	icon_state = "glowsticks_green"
	startswith = list(/obj/item/device/flashlight/glowstick = 6)

/obj/item/storage/box/freezer
	name = "portable freezer"
	desc = "This nifty shock-resistant device will keep your 'groceries' nice and non-spoiled."
	icon = 'icons/obj/storage/misc.dmi'
	icon_state = "portafreezer"
	item_state = "portafreezer"
	inspect_state = TRUE
	foldable = null
	max_w_class = ITEM_SIZE_NORMAL
	w_class = ITEM_SIZE_HUGE
	can_hold = list(/obj/item/organ, /obj/item/reagent_containers/food, /obj/item/reagent_containers/vessel, /obj/item/reagent_containers/ivbag)
	max_storage_space = DEFAULT_BACKPACK_STORAGE
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/storage/box/checkers
	name = "checkers box"
	desc = "This box holds a nifty portion of checkers. Foam-shaped on the inside so that only checkers may fit."
	icon_state = "checkers"
	max_storage_space = 24
	foldable = null
	can_hold = list(/obj/item/reagent_containers/food/checker)
	startswith = list(/obj/item/reagent_containers/food/checker = 12,
					/obj/item/reagent_containers/food/checker/red = 12)

/obj/item/storage/box/checkers/chess
	name = "black chess box"
	desc = "This box holds all the pieces needed for the black side of the chess board."
	icon_state = "chess_b"
	startswith = list(/obj/item/reagent_containers/food/checker/pawn = 8,
				/obj/item/reagent_containers/food/checker/knight = 2,
				/obj/item/reagent_containers/food/checker/bishop = 2,
				/obj/item/reagent_containers/food/checker/rook = 2,
				/obj/item/reagent_containers/food/checker/queen = 1,
				/obj/item/reagent_containers/food/checker/king = 1)

/obj/item/storage/box/checkers/chess/red
	name = "red chess box"
	desc = "This box holds all the pieces needed for the red side of the chess board."
	icon_state = "chess_r"
	startswith = list(/obj/item/reagent_containers/food/checker/pawn/red = 8,
				/obj/item/reagent_containers/food/checker/knight/red = 2,
				/obj/item/reagent_containers/food/checker/bishop/red = 2,
				/obj/item/reagent_containers/food/checker/rook/red = 2,
				/obj/item/reagent_containers/food/checker/queen/red = 1,
				/obj/item/reagent_containers/food/checker/king/red = 1)


/obj/item/storage/box/headset
	name = "box of spare headsets"
	desc = "A box full of headsets."
	startswith = list(/obj/item/device/radio/headset = 7)

//Spare Armbands

/obj/item/storage/box/armband/engine
	name = "box of spare engineering armbands"
	desc = "A box full of engineering armbands. For use in emergencies when provisional engineering peronnel are needed."
	startswith = list(/obj/item/clothing/accessory/armband/engine = 5)

/obj/item/storage/box/armband/med
	name = "box of spare medical armbands"
	desc = "A box full of medical armbands. For use in emergencies when provisional medical personnel are needed."
	startswith = list(/obj/item/clothing/accessory/armband/med = 5)

/obj/item/storage/box/imprinting
	name = "box of education implants"
	desc = "A box full of neural implants for on-job training."
	startswith = list(
		/obj/item/implanter,
		/obj/item/implantpad,
		/obj/item/implantcase/imprinting = 3
		)

/obj/item/storage/box/balloons
	name = "box of balloons"
	desc = "A box full of balloons."
	icon_state = "balloons"
	startswith = list(/obj/item/balloon_flat = 14)

/obj/item/storage/box/cleanerpods
	name = "box of cleaner pods"
	desc = "A box full of tasty, colorful space cleaner pods."
	icon_state = "cleanerpods"
	startswith = list(/obj/item/reagent_containers/pill/cleanerpod = 14)

/obj/item/storage/box/coffeepack
	name = "arabica beans"
	desc = "A bag containing fresh, dry coffee arabica beans. Ethically sourced and packaged by Waffle Corp."
	startswith = list(/obj/item/reagent_containers/food/grown/coffee = 5)

/obj/item/storage/box/coffeepack/robusta
	icon_state = "robusta_beans"
	name = "robusta beans"
	desc = "A bag containing fresh, dry coffee robusta beans. Ethically sourced and packaged by Waffle Corp."
	startswith = list(/obj/item/reagent_containers/food/grown/coffee/robusta = 5)

/obj/item/storage/box/coffeemaking_kit
	name = "coffeemaking kit"
	desc = "A box containing coffee beans and a coffeepot."
	startswith = list(/obj/item/reagent_containers/food/grown/coffee = 3,
						/obj/item/reagent_containers/food/grown/coffee/robusta = 2,
						/obj/item/reagent_containers/vessel/coffeepot
						)
