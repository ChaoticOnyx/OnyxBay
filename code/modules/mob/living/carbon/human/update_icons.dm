/*
	Global associative list for caching humanoid icons.
	Index format m or f, followed by a string of 0 and 1 to represent bodyparts followed by husk fat hulk skeleton 1 or 0.
	TODO: Proper documentation
	icon_key is [species.race_key][g][husk][fat][hulk][skeleton][s_tone]
*/
var/global/list/human_icon_cache = list()
var/global/list/tail_icon_cache = list() //key is [species.race_key][r_skin][g_skin][b_skin]
var/global/list/light_overlay_cache = list()
GLOBAL_LIST_EMPTY(limb_overlays_cache)


/proc/overlay_image(icon, icon_state, color, flags, plane, layer)
	var/image/ret = image(icon,icon_state)
	if(plane)
		ret.plane = plane
	if(layer)
		ret.layer = layer
	ret.color = color
	ret.appearance_flags = DEFAULT_APPEARANCE_FLAGS | flags
	return ret

	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*
Calling this  a system is perhaps a bit trumped up. It is essentially update_clothing dismantled into its
core parts. The key difference is that when we generate overlays we do not generate either lying or standing
versions. Instead, we generate both and store them in two fixed-length lists, both using the same list-index
(The indexes are in update_icons.dm): Each list for humans is (at the time of writing) of length 19.
This will hopefully be reduced as the system is refined.

	var/overlays_lying[19]			//For the lying down stance
	var/overlays_standing[19]		//For the standing stance

When we call update_icons, the 'lying' variable is checked and then the appropriate list is assigned to our overlays!
That in itself uses a tiny bit more memory (no more than all the ridiculous lists the game has already mind you).

On the other-hand, it should be very CPU cheap in comparison to the old system.
In the old system, we updated all our overlays every life() call, even if we were standing still inside a crate!
or dead!. 25ish overlays, all generated from scratch every second for every xeno/human/monkey and then applied.
More often than not update_clothing was being called a few times in addition to that! CPU was not the only issue,
all those icons had to be sent to every client. So really the cost was extremely cumulative. To the point where
update_clothing would frequently appear in the top 10 most CPU intensive procs during profiling.

Another feature of this new system is that our lists are indexed. This means we can update specific overlays!
So we only regenerate icons when we need them to be updated! This is the main saving for this system.

In practice this means that:
	everytime you fall over, we just switch between precompiled lists. Which is fast and cheap.
	Everytime you do something minor like take a pen out of your pocket, we only update the in-hand overlay
	etc...


There are several things that need to be remembered:

>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src) )
	You will need to call the relevant update_inv_* proc:
		update_inv_head()
		update_inv_wear_suit()
		update_inv_gloves()
		update_inv_shoes()
		update_inv_w_uniform()
		update_inv_glasse()
		update_inv_l_hand()
		update_inv_r_hand()
		update_inv_belt()
		update_inv_wear_id()
		update_inv_ears()
		update_inv_s_store()
		update_inv_pockets()
		update_inv_back()
		update_inv_handcuffed()
		update_inv_wear_mask()

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	metroid etc. Instead, it'll just return without doing any work. So no harm in calling it for metroids and such.


>	There are also these special cases:
		update_mutations()	//handles updating your appearance for certain mutations.  e.g TK head-glows
		UpdateDamageIcon()	//handles damage overlays for brute/burn damage //(will rename this when I geta round to it)
		update_body()	//Handles updating your mob's icon to reflect their gender/race/complexion etc
		update_hair()	//Handles updating your hair overlay (used to be update_face, but mouth and
																			...eyes were merged into update_body)
		update_facial_hair() // Handles updating your facial hair overlay. Used to be a part of update_hair(), but was forked because of the mask alt layer.
		update_deformities() //handles updating your mob's deformities overlay.		e.g missing eyes, glasgow smile
		update_targeted() // Updates the target overlay when someone points a gun at you

>	All of these procs update our overlays_lying and overlays_standing, and then call update_icons() by default.
	If you wish to update several overlays at once, you can set the argument to 0 to disable the update and call
	it manually:
		e.g.
		update_inv_head(0)
		update_inv_l_hand(0)
		update_inv_r_hand()		//<---calls update_icons()

	or equivillantly:
		update_inv_head(0)
		update_inv_l_hand(0)
		update_inv_r_hand(0)
		update_icons()

>	If you need to update all overlays you can use regenerate_icons(). it works exactly like update_clothing used to.

>	I reimplimented an old unused variable which was in the code called (coincidentally) var/update_icon
	It can be used as another method of triggering regenerate_icons(). It's basically a flag that when set to non-zero
	will call regenerate_icons() at the next life() call and then reset itself to 0.
	The idea behind it is icons are regenerated only once, even if multiple events requested it.

This system is confusing and is still a WIP. It's primary goal is speeding up the controls of the game whilst
reducing processing costs. So please bear with me while I iron out the kinks. It will be worth it, I promise.
If I can eventually free var/lying stuff from the life() process altogether, stuns/death/status stuff
will become less affected by lag-spikes and will be instantaneous! :3

If you have any questions/constructive-comments/bugs-to-report/or have a massivly devestated butt...
Please contact me on #coderbus IRC. ~Carn x
*/

/mob/living/carbon/human
	var/list/overlays_standing[HO_TOTAL_LAYERS]
	var/previous_damage_appearance // store what the body last looked like, so we only have to update it if something changed

//UPDATES OVERLAYS FROM OVERLAYS_LYING/OVERLAYS_STANDING
/mob/living/carbon/human/update_icons()
	if(QDELING(src))
		return
	update_hud()		//TODO: remove the need for this

	var/list/overlays_to_apply = list()
	if(icon_update)
		ClearOverlays()
		var/list/visible_overlays
		if(is_cloaked())
			icon = 'icons/mob/human.dmi'
			icon_state = "blank"
			visible_overlays = list(overlays_standing[HO_R_HAND_LAYER], overlays_standing[HO_L_HAND_LAYER])
		else
			icon = stand_icon
			icon_state = null
			visible_overlays = overlays_standing

		var/matrix/M = matrix()
		if(lying && (species.prone_overlay_offset[1] || species.prone_overlay_offset[2]))
			M.Translate(species.prone_overlay_offset[1], species.prone_overlay_offset[2])

		for(var/i = 1 to LAZYLEN(visible_overlays))
			var/entry = visible_overlays[i]
			if(istype(entry, /image))
				var/image/overlay = entry
				if(i != HO_BODY_LAYER)
					overlay.transform = M
				overlays_to_apply += overlay
			else if(istype(entry, /list))
				for(var/image/overlay in entry)
					if(i != HO_BODY_LAYER)
						overlay.transform = M
					overlays_to_apply += overlay

	if(auras)
		overlays_to_apply |= auras

	if(active_typing_indicator)
		overlays_to_apply |= active_typing_indicator

	if(active_thinking_indicator)
		overlays_to_apply |= active_thinking_indicator

	SetOverlays(overlays_to_apply)

	update_transform()

var/global/list/damage_icon_parts = list()

//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/UpdateDamageIcon(update_icons = 1)
	// first check whether something actually changed about damage appearance
	var/damage_appearance = ""

	if(!species.damage_overlays || !body_build?.dam_mask)
		return

	for(var/obj/item/organ/external/O in organs)
		if(O.is_stump())
			continue
		damage_appearance += O.damage_state

	if(damage_appearance == previous_damage_appearance)
		// nothing to do here
		return

	previous_damage_appearance = damage_appearance

	var/image/standing_image = image(species.damage_overlays, icon_state = "00")

	// blend the individual damage states with our icons
	for(var/obj/item/organ/external/O in organs)
		O.update_damstate()
		O.update_icon()
		if(O.damage_state == "00")
			continue
		var/icon/DI
		var/use_colour = (BP_IS_ROBOTIC(O) ? SYNTH_BLOOD_COLOUR : O.species.get_blood_colour(src))
		var/cache_index = "[O.damage_state]/[O.icon_name]/[use_colour]/[species.name]/[body_build.name]"
		if(damage_icon_parts[cache_index] == null)
			DI = new /icon(species.get_damage_overlays(src), O.damage_state)			// the damage icon for whole human
			DI.Blend(new /icon(body_build.dam_mask, "[O.icon_name]"), ICON_MULTIPLY)	// mask with this organ's pixels
			DI.Blend(use_colour, ICON_MULTIPLY)
			damage_icon_parts[cache_index] = DI
		else
			DI = damage_icon_parts[cache_index]

		standing_image.AddOverlays(DI)

	overlays_standing[HO_DAMAGE_LAYER]	= standing_image
	update_bandages(update_icons)

	if(update_icons)
		queue_icon_update()

/mob/living/carbon/human/proc/update_bandages(update_icons = TRUE)
	var/bandage_icon = body_build.bandages_icon
	if(!bandage_icon)
		return
	var/image/standing_image = image(bandage_icon, icon_state = "0")
	if(overlays_standing[HO_DAMAGE_LAYER])
		for(var/obj/item/organ/external/O in organs)
			if(O.is_stump())
				continue
			var/bandage_level = O.bandage_level()
			if(bandage_level)
				standing_image.AddOverlays(image(bandage_icon, "[O.icon_name][bandage_level]"))

		overlays_standing[HO_BANDAGE_LAYER] = standing_image
	if(update_icons)
		queue_icon_update()

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(update_icons = TRUE)
	//Update all limbs and visible organs one by one
	var/list/needs_update = list()
	var/limb_count_update = FALSE
	for(var/organ_tag in species.has_limbs)
		var/obj/item/organ/external/limb = organs_by_name[organ_tag]
		if(!QDELETED(limb))
			var/old_key = limb_render_keys?[organ_tag] // Checks the mob's icon render key list for the bodypart
			var/new_key = json_encode(limb.get_icon_key()) // Generates a key for the current bodypart
			limb_render_keys[organ_tag] = new_key
			if(new_key != old_key) // If the keys match, that means the limb doesn't need to be redrawn
				needs_update += limb
		else
			//Limb is missing?
			limb_render_keys -= organ_tag
			limb_count_update = TRUE

	if(length(needs_update) || limb_count_update)
		//GENERATE NEW LIMBS
		var/list/new_limbs = list()
		for(var/obj/item/organ/external/limb in organs)
			if(limb in needs_update)
				var/list/limb_overlays = limb.get_overlays()
				GLOB.limb_overlays_cache[limb_render_keys[limb.organ_tag]] = limb_overlays
				new_limbs += limb_overlays
			else
				new_limbs += GLOB.limb_overlays_cache[limb_render_keys[limb.organ_tag]]

		if(length(new_limbs))
			overlays_standing[HO_BODY_LAYER] = new_limbs

	//tail
	update_tail_showing(0)

	if(update_icons)
		queue_icon_update()

//UNDERWEAR OVERLAY

/mob/living/carbon/human/proc/update_underwear(update_icons=1)
	overlays_standing[HO_UNDERWEAR_LAYER] = list()

	overlays_standing[HO_WRISTS_UNDER_LAYER] = list()
	overlays_standing[HO_WRIST_UNIFORM_LAYER] = list()
	overlays_standing[HO_WRISTS_OVER_LAYER] = list()

	for(var/obj/item/underwear/UW in worn_underwear)
		var/image/I = image(body_build.get_mob_icon(slot_hidden_str, UW.icon_state), UW.icon_state)
		I.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
		I.color = UW.color
		if(istype(UW, /obj/item/underwear/wrist))
			var/obj/item/underwear/wrist/W = UW
			overlays_standing[W.mob_wear_layer] += I

		else
			overlays_standing[HO_UNDERWEAR_LAYER] += I

	if(update_icons)
		queue_icon_update()

//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair(update_icons=1)

	if(!src) return
	//Reset our hair
	overlays_standing[HO_HAIR_LAYER]	= null

	var/obj/item/organ/external/head/head_organ = get_organ(BP_HEAD)
	if(!head_organ || head_organ.is_stump() )
		if(update_icons) queue_icon_update()
		return

	//masks and helmets can obscure our hair.
	if( (head && (head.flags_inv & BLOCKHAIR)) || (wear_mask && (wear_mask.flags_inv & BLOCKHAIR)))
		if(update_icons) queue_icon_update()
		return

	overlays_standing[HO_HAIR_LAYER]	= head_organ.get_hair_icon()

	if(update_icons) queue_icon_update()

/// BEARD OVERLAY
/mob/living/carbon/human/proc/update_facial_hair(update_icons=1)

	if(!src)
		return

	//Reset our hair
	overlays_standing[HO_FACIAL_HAIR_LAYER] = null

	var/obj/item/organ/external/head/head_organ = get_organ(BP_HEAD)
	if(!head_organ || head_organ.is_stump())
		if(update_icons)
			queue_icon_update()
		return

	//masks and helmets can obscure our hair.
	if((head && (head.flags_inv & BLOCKHAIR)) || (wear_mask && (wear_mask.flags_inv & BLOCKHAIR)))
		if(update_icons)
			queue_icon_update()
		return

	overlays_standing[HO_FACIAL_HAIR_LAYER]= head_organ.get_facial_hair_icon()

	if(update_icons)
		queue_icon_update()

/mob/living/carbon/human/proc/update_skin(update_icons=1)
	overlays_standing[HO_SKIN_LAYER] = species.update_skin(src)

	if(update_icons) queue_icon_update()

/mob/living/carbon/human/proc/update_deformities(update_icons=1)

	overlays_standing[HO_DEFORM_LAYER] = null

	var/obj/item/organ/external/head/head_organ = get_organ(BP_HEAD)
	if(!head_organ || head_organ.is_stump() )
		if(update_icons) queue_icon_update()
		return

	//masks and helmets can obscure our hair.
	if( (head && (head.flags_inv & HIDEFACE)) || (wear_mask && (wear_mask.flags_inv & HIDEFACE)))
		if(update_icons) queue_icon_update()
		return

	var/image/standing = overlay_image('icons/mob/deformities.dmi')
	var/add_image = 0

	if(head_organ.deformities == 1)
		standing.AddOverlays("bloodysmile")
		add_image = 1

	var/obj/item/organ/internal/eyes/E = src.internal_organs_by_name[BP_EYES]
	if(!E && should_have_organ(BP_EYES))
		standing.AddOverlays("eyeloss")
		add_image = 1

	if(add_image)
		overlays_standing[HO_DEFORM_LAYER] = standing

	if(update_icons) queue_icon_update()


/mob/living/carbon/human/update_mutations(update_icons=1)
	var/image/standing	= overlay_image('icons/effects/genetics.dmi', flags=RESET_COLOR)
	var/add_image = 0
	for(var/mut in mutations)
		switch(mut)
			if(MUTATION_LASER)
				standing.overlays	+= "lasereyes_s"
				add_image = 1
	if(add_image)
		overlays_standing[HO_MUTATIONS_LAYER]	= standing
	else
		overlays_standing[HO_MUTATIONS_LAYER]	= null

	if(update_icons) queue_icon_update()

/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	..()
	if(HasMovementHandler(/datum/movement_handler/mob/transformation) || QDELETED(src))
		return

	update_mutations(0)
	update_body(0)
	update_skin(0)
	update_underwear(0)
	update_hair(0)
	update_facial_hair(0)
	update_deformities(0)
	update_inv_w_uniform(0)
	update_inv_wear_id(0)
	update_inv_gloves(0)
	update_inv_glasses(0)
	update_inv_ears(0)
	update_inv_shoes(0)
	update_inv_s_store(0)
	update_inv_wear_mask(0)
	update_inv_head(0)
	update_inv_belt(0)
	update_inv_back(0)
	update_inv_wear_suit(0)
	update_inv_r_hand(0)
	update_inv_l_hand(0)
	update_inv_handcuffed(0)
	update_inv_pockets(0)
	update_fire(0)
	update_surgery(0)
	UpdateDamageIcon()
	queue_icon_update()
	//Hud Stuff
	update_hud()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform(update_icons=1)
	if(istype(w_uniform, /obj/item/clothing/under) && !(wear_suit && wear_suit.flags_inv & HIDEJUMPSUIT))
		overlays_standing[HO_UNIFORM_LAYER]	= w_uniform.get_mob_overlay(src, slot_w_uniform_str)
	else
		overlays_standing[HO_UNIFORM_LAYER]	= null

	if(update_icons) queue_icon_update()

// ID card
/mob/living/carbon/human/update_inv_wear_id(update_icons=1)
	var/image/id_overlay
	if(wear_id && istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = w_uniform
		if(U.displays_id && !U.rolled_down)
			id_overlay = wear_id.get_mob_overlay(src,slot_wear_id_str)

	overlays_standing[HO_ID_LAYER]	= id_overlay

	BITSET(hud_updateflag, ID_HUD)
	BITSET(hud_updateflag, WANTED_HUD)

	if(update_icons) queue_icon_update()

// Gloves
/mob/living/carbon/human/update_inv_gloves(update_icons=1)
	if(gloves && !(wear_suit && wear_suit.flags_inv & HIDEGLOVES))
		overlays_standing[HO_GLOVES_LAYER] = gloves.get_mob_overlay(src,slot_gloves_str)
	else
		if(is_bloodied && body_build.blood_icon)
			var/image/bloodsies	= overlay_image(body_build.blood_icon, "bloodyhands", hand_blood_color, DEFAULT_APPEARANCE_FLAGS | RESET_COLOR)
			overlays_standing[HO_GLOVES_LAYER] = bloodsies
		else
			overlays_standing[HO_GLOVES_LAYER] = null

	if(update_icons)
		queue_icon_update()

// Glasses
/mob/living/carbon/human/update_inv_glasses(update_icons=1)
	if(glasses)
		overlays_standing[glasses.use_alt_layer ? HO_GOGGLES_LAYER : HO_GLASSES_LAYER] = glasses.get_mob_overlay(src,slot_glasses_str)
		overlays_standing[glasses.use_alt_layer ? HO_GLASSES_LAYER : HO_GOGGLES_LAYER] = null
	else
		overlays_standing[HO_GLASSES_LAYER]	= null
		overlays_standing[HO_GOGGLES_LAYER]	= null

	if(update_icons)
		queue_icon_update()

// Ears
/mob/living/carbon/human/update_inv_ears(update_icons=1)
	overlays_standing[HO_EARS_LAYER] = null
	if((head && (head.flags_inv & (BLOCKHAIR | BLOCKHEADHAIR))) || (wear_mask && (wear_mask.flags_inv & (BLOCKHAIR | BLOCKHEADHAIR))))
		if(update_icons)
			queue_icon_update()
		return

	if(l_ear || r_ear)
		// Blank image upon which to layer left & right overlays.
		var/image/both = image("icon" = 'icons/effects/blank.dmi')
		if(l_ear)
			both.AddOverlays(l_ear.get_mob_overlay(src, slot_l_ear_str))
		if(r_ear)
			both.AddOverlays(r_ear.get_mob_overlay(src, slot_r_ear_str))
		overlays_standing[HO_EARS_LAYER] = both

	else
		overlays_standing[HO_EARS_LAYER] = null

	if(update_icons)
		queue_icon_update()

// Shoes
/mob/living/carbon/human/update_inv_shoes(update_icons=1)
	if(shoes && !((wear_suit && wear_suit.flags_inv & HIDESHOES) || (w_uniform && w_uniform.flags_inv & HIDESHOES)))
		overlays_standing[HO_SHOES_LAYER] = shoes.get_mob_overlay(src,slot_shoes_str)
	else
		if(feet_blood_color && body_build.blood_icon)
			var/image/bloodsies = overlay_image(body_build.blood_icon, "shoeblood", feet_blood_color, DEFAULT_APPEARANCE_FLAGS | RESET_COLOR)
			overlays_standing[HO_SHOES_LAYER] = bloodsies
		else
			overlays_standing[HO_SHOES_LAYER] = null

	if(update_icons) queue_icon_update()

// Suit Storage
/mob/living/carbon/human/update_inv_s_store(update_icons=1)
	if(s_store)
		overlays_standing[HO_SUIT_STORE_LAYER] = s_store.get_mob_overlay(src, slot_s_store_str)
	else
		overlays_standing[HO_SUIT_STORE_LAYER] = null

	if(update_icons) queue_icon_update()

// Head
/mob/living/carbon/human/update_inv_head(update_icons=1)
	if(head)
		overlays_standing[HO_HEAD_LAYER] = head.get_mob_overlay(src, slot_head_str)
	else
		overlays_standing[HO_HEAD_LAYER] = null

	if(update_icons) queue_icon_update()

// Belt
/mob/living/carbon/human/update_inv_belt(update_icons=1)
	if(belt)
		overlays_standing[belt.use_alt_layer ? HO_BELT_LAYER_ALT : HO_BELT_LAYER] = belt.get_mob_overlay(src,slot_belt_str)
		overlays_standing[belt.use_alt_layer ? HO_BELT_LAYER : HO_BELT_LAYER_ALT] = null
	else
		overlays_standing[HO_BELT_LAYER] = null
		overlays_standing[HO_BELT_LAYER_ALT] = null

	if(update_icons) queue_icon_update()

// Suit
/mob/living/carbon/human/update_inv_wear_suit(update_icons=1)
	if(wear_suit)
		overlays_standing[HO_SUIT_LAYER] = wear_suit.get_mob_overlay(src, slot_wear_suit_str)
		update_tail_showing(0)
	else
		overlays_standing[HO_SUIT_LAYER] = null
		update_tail_showing(0)
		update_inv_w_uniform(0)
		update_inv_shoes(0)
		update_inv_gloves(0)

	update_collar(0)

	if(update_icons) queue_icon_update()

// Pockets
/mob/living/carbon/human/update_inv_pockets(update_icons=1)

	if(update_icons) queue_icon_update()

// Mask
/mob/living/carbon/human/update_inv_wear_mask(update_icons=1)
	if(wear_mask && !(head && head.flags_inv & HIDEMASK))
		overlays_standing[wear_mask.use_alt_layer ? HO_FACEMASK_ALT_LAYER : HO_FACEMASK_LAYER] = wear_mask.get_mob_overlay(src, slot_wear_mask_str)
		overlays_standing[wear_mask.use_alt_layer ? HO_FACEMASK_LAYER : HO_FACEMASK_ALT_LAYER] = null
	else
		overlays_standing[HO_FACEMASK_LAYER] = null
		overlays_standing[HO_FACEMASK_ALT_LAYER] = null

	if(update_icons) queue_icon_update()

// Back
/mob/living/carbon/human/update_inv_back(update_icons=1)
	if(back)
		overlays_standing[HO_BACK_LAYER] = back.get_mob_overlay(src,slot_back_str)
	else
		overlays_standing[HO_BACK_LAYER] = null

	if(update_icons) queue_icon_update()

// HUD
/mob/living/carbon/human/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar

// Handcuffs
/mob/living/carbon/human/update_inv_handcuffed(update_icons=1)
	if(handcuffed)
		overlays_standing[HO_HANDCUFF_LAYER] = handcuffed.get_mob_overlay(src,slot_handcuffed_str)
	else
		overlays_standing[HO_HANDCUFF_LAYER] = null

	if(update_icons) queue_icon_update()

// Right Hand
/mob/living/carbon/human/update_inv_r_hand(update_icons=1)
	if(r_hand)
		. = r_hand.get_mob_overlay(src, slot_r_hand_str)
		if(.)
			if(islist(.))
				var/image/main = .[1]
				main.appearance_flags |= RESET_ALPHA
				main.appearance_flags |= PIXEL_SCALE
				overlays_standing[HO_R_HAND_LAYER] = main

				var/image/back = .[2]
				back.appearance_flags |= RESET_ALPHA
				back.appearance_flags |= PIXEL_SCALE
				overlays_standing[HO_R_HAND_LOW_LAYER] = back
			else
				var/image/standing = .
				standing.appearance_flags |= RESET_ALPHA
				standing.appearance_flags |= PIXEL_SCALE
				overlays_standing[HO_R_HAND_LAYER] = standing
				overlays_standing[HO_R_HAND_LOW_LAYER] = null

		else
			overlays_standing[HO_R_HAND_LAYER] = null
			overlays_standing[HO_R_HAND_LOW_LAYER] = null

		if (handcuffed) drop_r_hand() //this should be moved out of icon code
	else
		overlays_standing[HO_R_HAND_LAYER] = null
		overlays_standing[HO_R_HAND_LOW_LAYER] = null

	if(update_icons) queue_icon_update()

// Left Hand
/mob/living/carbon/human/update_inv_l_hand(update_icons=1)
	if(l_hand)
		. = l_hand.get_mob_overlay(src, slot_l_hand_str)
		if(.)
			if(islist(.))
				var/image/main = .[1]
				main.appearance_flags |= RESET_ALPHA
				main.appearance_flags |= PIXEL_SCALE
				overlays_standing[HO_L_HAND_LAYER] = main

				var/image/back = .[2]
				back.appearance_flags |= RESET_ALPHA
				back.appearance_flags |= PIXEL_SCALE
				overlays_standing[HO_L_HAND_LOW_LAYER] = back
			else
				var/image/standing = .
				standing.appearance_flags |= RESET_ALPHA
				standing.appearance_flags |= PIXEL_SCALE
				overlays_standing[HO_L_HAND_LAYER] = standing
				overlays_standing[HO_L_HAND_LOW_LAYER] = null

		else
			overlays_standing[HO_L_HAND_LAYER] = null
			overlays_standing[HO_L_HAND_LOW_LAYER] = null

		if (handcuffed) drop_l_hand() //This probably should not be here
	else
		overlays_standing[HO_L_HAND_LAYER] = null
		overlays_standing[HO_L_HAND_LOW_LAYER] = null

	if(update_icons) queue_icon_update()

// Tail overlay
/mob/living/carbon/human/proc/update_tail_showing(update_icons=1)
	overlays_standing[HO_TAIL_LAYER] = null

	var/species_tail = species.get_tail(src)

	if(species_tail && !(wear_suit && wear_suit.flags_inv & HIDETAIL))
		var/icon/tail_s = get_tail_icon()
		overlays_standing[HO_TAIL_LAYER] = image(tail_s, icon_state = "[species_tail]_s")
		animate_tail_reset(0)

	if(update_icons) queue_icon_update()

/mob/living/carbon/human/proc/get_tail_icon()
	var/icon_key = "[species.get_race_key(src)][r_skin][g_skin][b_skin][r_hair][g_hair][b_hair]"
	var/icon/tail_icon = tail_icon_cache[icon_key]
	if(!tail_icon)
		//generate a new one
		var/species_tail_anim = species.get_tail_animation(src)
		if(!species_tail_anim) species_tail_anim = 'icons/effects/species.dmi'
		tail_icon = new /icon(species_tail_anim)
		tail_icon.Blend(rgb(r_skin, g_skin, b_skin), species.tail_blend)
		// The following will not work with animated tails.
		var/use_species_tail = species.get_tail_hair(src)
		if(use_species_tail)
			var/icon/hair_icon = icon('icons/effects/species.dmi', "[species.get_tail(src)]_[use_species_tail]")
			hair_icon.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			tail_icon.Blend(hair_icon, ICON_OVERLAY)
		tail_icon_cache[icon_key] = tail_icon

	return tail_icon

/mob/living/carbon/human/proc/set_tail_state(t_state)
	var/image/tail_overlay = overlays_standing[HO_TAIL_LAYER]

	if(tail_overlay && species.get_tail_animation(src))
		tail_overlay.icon_state = t_state
		return tail_overlay
	return null

//Not really once, since BYOND can't do that.
//Update this if the ability to flick() images or make looping animation start at the first frame is ever added.
/mob/living/carbon/human/proc/animate_tail_once(update_icons=1)
	var/t_state = "[species.get_tail(src)]_once"

	var/image/tail_overlay = overlays_standing[HO_TAIL_LAYER]
	if(tail_overlay && tail_overlay.icon_state == t_state)
		return //let the existing animation finish

	tail_overlay = set_tail_state(t_state)
	if(tail_overlay)
		spawn(20)
			//check that the animation hasn't changed in the meantime
			if(overlays_standing[HO_TAIL_LAYER] == tail_overlay && tail_overlay.icon_state == t_state)
				animate_tail_stop()

	if(update_icons) queue_icon_update()

/mob/living/carbon/human/proc/animate_tail_start(update_icons=1)
	set_tail_state("[species.get_tail(src)]_slow[rand(0,9)]")

	if(update_icons) queue_icon_update()

/mob/living/carbon/human/proc/animate_tail_fast(update_icons=1)
	set_tail_state("[species.get_tail(src)]_loop[rand(0,9)]")

	if(update_icons) queue_icon_update()

/mob/living/carbon/human/proc/animate_tail_reset(update_icons=1)
	if(!is_ic_dead())
		set_tail_state("[species.get_tail(src)]_idle[rand(0,9)]")
	else
		set_tail_state("[species.get_tail(src)]")

	if(update_icons) queue_icon_update()

/mob/living/carbon/human/proc/animate_tail_stop(update_icons=1)
	set_tail_state("[species.get_tail(src)]")

	if(update_icons) queue_icon_update()


//Adds a collar overlay above the helmet layer if the suit has one
//	Suit needs an identically named sprite in icons/mob/collar.dmi
/mob/living/carbon/human/proc/update_collar(update_icons=1) // Do we actually use it? ~Toby
	if(istype(wear_suit,/obj/item/clothing/suit))
		var/obj/item/clothing/suit/S = wear_suit
		overlays_standing[HO_COLLAR_LAYER]	= S.get_collar()
	else
		overlays_standing[HO_COLLAR_LAYER]	= null

	if(update_icons) queue_icon_update()

// Burning overlay
/mob/living/carbon/human/update_fire(update_icons=1)
	overlays_standing[HO_FIRE_LAYER] = null
	if(on_fire)
		var/image/standing = overlay_image('icons/mob/onfire.dmi', "Standing", RESET_COLOR)
		overlays_standing[HO_FIRE_LAYER] = standing

	if(update_icons) queue_icon_update()

// Surgery overlays
/mob/living/carbon/human/proc/update_surgery(update_icons=1)
	overlays_standing[HO_SURGERY_LAYER] = null
	var/image/total = new
	for(var/obj/item/organ/external/E in organs)
		if(!BP_IS_ROBOTIC(E) && E.open())
			var/image/I = image("icon"='icons/mob/surgery.dmi', "icon_state"="[E.icon_name][round(E.open())]", "layer"=-HO_SURGERY_LAYER)
			total.AddOverlays(I)
	total.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
	overlays_standing[HO_SURGERY_LAYER] = total

	if(update_icons) queue_icon_update()



//Human Overlays Indexes/////////
#undef HO_MUTATIONS_LAYER
#undef HO_DAMAGE_LAYER
#undef HO_SURGERY_LAYER
#undef HO_UNIFORM_LAYER
#undef HO_ID_LAYER
#undef HO_SHOES_LAYER
#undef HO_GLOVES_LAYER
#undef HO_EARS_LAYER
#undef HO_SUIT_LAYER
#undef HO_TAIL_LAYER
#undef HO_GLASSES_LAYER
#undef HO_FACEMASK_LAYER
#undef HO_BELT_LAYER
#undef HO_SUIT_STORE_LAYER
#undef HO_BACK_LAYER
#undef HO_HAIR_LAYER
#undef HO_DEFORM_LAYER
#undef HO_HEAD_LAYER
#undef HO_COLLAR_LAYER
#undef HO_HANDCUFF_LAYER
#undef HO_L_HAND_LAYER
#undef HO_R_HAND_LAYER
#undef HO_TARGETED_LAYER
#undef HO_FIRE_LAYER
#undef HO_TOTAL_LAYERS
