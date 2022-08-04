/obj/item/organ/internal/brain/vampiric_brain


/obj/item/organ/internal/brain/vampiric_brain/Process()
	if(owner)
		if(damage > max_damage / 2 && healed_threshold)
			spawn()
				alert(owner, "You have taken massive vampire brain damage! You will not be able to remember the events leading up to your injury.", "Brain Damaged")
			healed_threshold = 0

		if(damage < (max_damage / 4))
			healed_threshold = 1
		owner.nutrition = 400
		handle_disabilities()
		handle_damage_effects()            

/obj/item/organ/internal/heart/vampiric_heart
	max_damage = 150
	min_bruised_damage = 30
	min_broken_damage = 70
	vital = 1

/obj/item/organ/internal/heart/vampiric_heart/handle_pulse()	
	if(owner.status_flags & FAKELIVING)
		pulse = PULSE_NORM
	else
		pulse = PULSE_NONE
	owner.add_chemical_effect(CE_ANTIBIOTIC, 5)
	return


/obj/item/organ/internal/stomach/vampiric_stomach

/obj/item/organ/internal/stomach/vampiric_stomach/Process()  



/obj/item/organ/internal/lungs/vampiric_lungs


/obj/item/organ/internal/lungs/vampiric_lungs/Process()
	if(owner.status_flags & FAKELIVING)
		active_breathing = 1
	else
		active_breathing = 0
	..()

    
/obj/item/organ/internal/liver/vampiric_liver
/obj/item/organ/internal/liver/vampiric_liver/Process()


    
/obj/item/organ/internal/kidneys/vampiric_kidneys
/obj/item/organ/internal/kidneys/vampiric_kidneys/Process()


    
/obj/item/organ/internal/appendix/vampiric_appendix
/obj/item/organ/internal/appendix/vampiric_appendix/Process()
    
/obj/item/organ/internal/eyes/vampiric_eyes

    