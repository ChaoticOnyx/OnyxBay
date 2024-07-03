//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "A SalonPro Nano-Mirror(TM) brand mirror! The leading technology in hair salon products, utilizing nano-machinery to style your hair just right."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = 0
	anchored = 1
	var/shattered = FALSE
	var/list/ui_users = list()

	/// Visual object for handling the viscontents
	var/weakref/ref
	vis_flags = VIS_HIDE
	var/timerid = null

/obj/structure/mirror/Initialize()
	. = ..()
	var/obj/effect/reflection/reflection = new(src.loc)
	reflection.setup_visuals(src)
	ref = weakref(reflection)
	if(shattered)
		shattered = FALSE
		shatter()

/obj/structure/mirror/attack_hand(mob/user as mob)

	if(shattered)	return

	if(ishuman(user))
		if(jobban_isbanned(user, "APPEARANCE"))
			to_chat(src, "<span class='danger'>This is useless for you.</span>")
			return

		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		if(!AC)
			AC = new(src, user)
			AC.name = "SalonPro Nano-Mirror&trade;"
			ui_users[user] = AC
		AC.ui_interact(user)

/obj/structure/mirror/proc/shatter()
	if(shattered)	return
	shattered = TRUE
	icon_state = "mirror_broke"
	playsound(src, SFX_BREAK_WINDOW, 70, 1)
	desc = "Oh no, seven years of bad luck!"

	var/obj/effect/reflection/reflection = ref.resolve()
	if(istype(reflection))
		reflection.alpha_icon_state = "mirror_mask_broken"
		reflection.update_mirror_filters()

/obj/structure/mirror/bullet_act(obj/item/projectile/Proj)

	if(prob(Proj.get_structure_damage() * 2))
		if(!shattered)
			shatter()
		else
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	..()

/obj/structure/mirror/attackby(obj/item/I as obj, mob/user as mob)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return

	if(prob(I.force * 2))
		visible_message("<span class='warning'>[user] smashes [src] with [I]!</span>")
		shatter()
	else
		visible_message("<span class='warning'>[user] hits [src] with [I]!</span>")
		playsound(src.loc, GET_SFX(SFX_GLASS_HIT), 70, 1)
	user.setClickCooldown(I.update_attack_cooldown())
	user.do_attack_animation(src)

/obj/structure/mirror/attack_generic(mob/user, damage)
	attack_animation(user)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return 0

	if(damage)
		user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
		shatter()
	else
		user.visible_message("<span class='danger'>[user] hits [src] and bounces off!</span>")
	return 1

/obj/structure/mirror/Destroy()
	for(var/user in ui_users)
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		qdel(AC)
	ui_users.Cut()

	var/obj/effect/reflection/reflection = ref.resolve()
	if(istype(reflection))
		unregister_signal(src.loc, SIGNAL_ENTERED)
		unregister_signal(src.loc, SIGNAL_EXITED)
		qdel(reflection)
		ref = null
	return ..()

// The following mirror is ~special~.
/obj/structure/mirror/raider
	name = "cracked mirror"
	desc = "Something seems strange about this old, dirty mirror. Your reflection doesn't look like you remember it."
	icon_state = "mirrormagic_broke"
	shattered = 1

/obj/structure/mirror/raider/attack_hand(mob/living/carbon/human/user)
	if(istype(get_area(src),/area/syndicate_mothership))
		if(istype(user) && user.mind && user.mind.special_role == "Raider" && user.species.name != SPECIES_VOX)
			var/choice = input("Do you wish to become a true Vox of the Shoal? This is not reversible.") as null|anything in list("No","Yes")
			if(choice && choice == "Yes")
				var/mob/living/carbon/human/vox/vox = new(get_turf(src),SPECIES_VOX)
				vox.gender = user.gender
				GLOB.raiders.equip(vox)
				if(user.mind)
					user.mind.transfer_to(vox)
				spawn(1)
					var/newname = sanitizeSafe(input(vox,"Enter a name, or leave blank for the default name.", "Name change","") as text, MAX_NAME_LEN)
					if(!newname || newname == "")
						var/datum/language/L = all_languages[vox.species.default_language]
						newname = L.get_random_name()
					vox.real_name = newname
					vox.SetName(vox.real_name)
					GLOB.raiders.update_access(vox)
				qdel(user)
	..()

/obj/structure/mirror/magic
	name = "magic mirror"
	desc = "Something seems strange about this mirror. Your reflection doesn't look like you remember it."
	icon_state = "mirrormagic"

/obj/structure/mirror/magic/shatter()
	if(shattered)
		return
	shattered = TRUE
	icon_state = "mirrormagic_broke"
	playsound(src, SFX_BREAK_WINDOW, 70, 1)
	desc = "Oh no, seven years of bad luck!"

	var/obj/effect/reflection/reflection = ref.resolve()
	if(istype(reflection))
		reflection.alpha_icon_state = "mirror_mask_broken"
		reflection.update_mirror_filters()

/obj/item/mirror
	name = "mirror"
	desc = "A SalonPro Nano-Mirror(TM) brand mirror! Now a portable version."
	icon = 'icons/obj/items.dmi'
	icon_state = "mirror"
	var/list/ui_users = list()

/obj/item/mirror/attack_self(mob/user as mob)
	if(ishuman(user))
		if(jobban_isbanned(user, "APPEARANCE"))
			to_chat(src, "<span class='danger'>This is useless for you.</span>")
			return

		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		if(!AC)
			AC = new(src, user)
			AC.name = "SalonPro Nano-Mirror&trade;"
			AC.flags = APPEARANCE_HAIR
			ui_users[user] = AC
		AC.ui_interact(user)

/obj/item/mirror/Destroy()
	for(var/user in ui_users)
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		qdel(AC)
	ui_users.Cut()

	return ..()

/obj/effect/reflection
	name = "reflection"
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	mouse_opacity = 0
	vis_flags = VIS_HIDE
	layer = ABOVE_OBJ_LAYER
	var/alpha_icon = 'icons/obj/watercloset.dmi'
	var/alpha_icon_state = "mirror_mask"
	var/obj/mirror
	desc = "Why are you locked in the bathroom?"
	anchored = TRUE
	unacidable = TRUE

	var/blur_filter

/obj/effect/reflection/proc/setup_visuals(target)
	mirror = target
	register_signal(mirror.loc, SIGNAL_ENTERED, nameof(.proc/check_vampire_enter))
	register_signal(mirror.loc, SIGNAL_EXITED, nameof(.proc/check_vampire_exit))

	if(mirror.pixel_x > 0)
		dir = WEST
	else if (mirror.pixel_x < 0)
		dir = EAST

	if(mirror.pixel_y > 0)
		dir = SOUTH
	else if (mirror.pixel_y < 0)
		dir = NORTH

	pixel_x = mirror.pixel_x
	pixel_y = mirror.pixel_y

	blur_filter = filter(type="blur", size = 1)

	update_mirror_filters()

/obj/effect/reflection/proc/update_mirror_filters()
	filters = null

	vis_contents = null

	if(!mirror)
		return

	var/matrix/M = matrix()
	if(dir == WEST || dir == EAST)
		M.Scale(-1, 1)
	else if(dir == SOUTH|| dir == NORTH)
		M.Scale(1, -1)
		pixel_y = mirror.pixel_y + 5

	transform = M

	filters += filter("type" = "alpha", "icon" = icon(alpha_icon, alpha_icon_state), "x" = 0, "y" = 0)
	for(var/mob/living/carbon/human/H in loc)
		check_vampire_enter(H.loc, H)

	vis_contents += get_turf(mirror)

/obj/effect/reflection/proc/check_vampire_enter(turf/T, mob/living/carbon/human/H)
	if(!istype(H))
		return
	if (!H.mind)
		return
	var/datum/vampire/V = H.mind.vampire
	if(V)
		if(V.vamp_status & VAMP_ISTHRALL)
			filters += blur_filter
		else
			H.vis_flags |= VIS_HIDE

/obj/effect/reflection/proc/check_vampire_exit(turf/T, mob/living/carbon/human/H)
	if(!istype(H))
		return
	if (!H.mind)
		return
	var/datum/vampire/V = H.mind.vampire
	if(V)
		if(V.vamp_status & VAMP_ISTHRALL)
			filters -= blur_filter
		else
			H.vis_flags &= ~VIS_HIDE
