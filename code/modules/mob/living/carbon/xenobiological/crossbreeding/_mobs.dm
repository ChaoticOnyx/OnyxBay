/// Transformed metroid - from Burning Black
/mob/living/carbon/metroid/transformed_metroid

// Just in case.
/mob/living/carbon/metroid/transformed_metroid/Reproduce()
	to_chat(src, SPAN_WARNING("I can't reproduce...")) // Mood
	return

//metroid corgi - Chilling Pink
/mob/living/simple_animal/corgi/puppy/metroid
	name = "\improper metroid corgi puppy"
	real_name = "metroid corgi puppy"
	desc = "An unbearably cute pink metroid corgi puppy."
	icon_state = "metroid_puppy"
	icon_living = "metroid_puppy"
	icon_dead = "metroid_puppy_dead"
	speak_emote = list("blorbles", "bubbles", "borks")
	emote_hear = list("bubbles!", "splorts.", "splops!")
	emote_see = list("gets goop everywhere.", "flops.", "jiggles!")
