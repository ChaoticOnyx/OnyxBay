/obj/item/clothing/under/chameleon/friend/change(picked in clothing_choices)
	set name = "Change Jumpsuit Appearance"
	set category = "Chameleon Items"
	set src in usr.loc
	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

/obj/item/clothing/under/chameleon/friend/emp_act(severity)
	return

/obj/item/clothing/suit/chameleon/friend/change(picked in clothing_choices)
	set name = "Change Oversuit Appearance"
	set category = "Chameleon Items"
	set src in usr.loc
	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

/obj/item/clothing/suit/chameleon/friend/emp_act(severity)
	return

/obj/item/clothing/shoes/chameleon/friend/change(picked in clothing_choices)
	set name = "Change Footwear Appearance"
	set category = "Chameleon Items"
	set src in usr.loc
	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

/obj/item/clothing/shoes/chameleon/friend/emp_act(severity)
	return

/obj/item/clothing/mask/chameleon/friend/change(picked in clothing_choices)
	set name = "Change Mask Appearance"
	set category = "Chameleon Items"
	set src in usr.loc
	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

/obj/item/clothing/mask/chameleon/friend/emp_act(severity)
	return

/obj/item/clothing/gloves/chameleon/friend/change(picked in clothing_choices)
	set name = "Change Gloves Appearance"
	set category = "Chameleon Items"
	set src in usr.loc
	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

/obj/item/clothing/gloves/chameleon/friend/emp_act(severity)
	return

/obj/item/clothing/glasses/chameleon/friend/change(picked in clothing_choices)
	set name = "Change Glasses Appearance"
	set category = "Chameleon Items"
	set src in usr.loc
	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

/obj/item/clothing/glasses/chameleon/friend/emp_act(severity)
	return

/obj/item/clothing/head/chameleon/friend/change(picked in clothing_choices)
	set name = "Change Hat/Helmet Appearance"
	set category = "Chameleon Items"
	set src in usr.loc
	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)
	update_clothing_icon()	//so our overlays update.

/obj/item/clothing/head/chameleon/friend/emp_act(severity)
	return

/obj/item/weapon/storage/backpack/chameleon/friend/change(picked in clothing_choices)
	set name = "Change Backpack Appearance"
	set category = "Chameleon Items"
	set src in usr.loc
	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)

	//so our overlays update.
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_back()

/obj/item/weapon/storage/backpack/chameleon/friend/emp_act(severity)
	return
