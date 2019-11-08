/obj/item/instrument
	name = "instrument"
	desc = "You can`t see this, mkay?"
	force = 0
	var/datum/song/song
	var/playing = 0
	var/help = 0
	var/edit = 1
	var/repeat = 0
	var/InstrumentId = "instrument"
	icon = 'icons/obj/musician.dmi'

/obj/item/instrument/proc/playnote(var/note as text)
//	log_debug("Note: [note]")

	var/soundfile
	if(InstrumentId == "guitar")
		switch(note)
			if("Ab3") soundfile = 'sound/guitar/Ab3.ogg'
			if("Ab4") soundfile = 'sound/guitar/Ab4.ogg'
			if("Ab5") soundfile = 'sound/guitar/Ab5.ogg'
			if("Ab6") soundfile = 'sound/guitar/Ab6.ogg'
			if("An3") soundfile = 'sound/guitar/An3.ogg'
			if("An4") soundfile = 'sound/guitar/An4.ogg'
			if("An5") soundfile = 'sound/guitar/An5.ogg'
			if("An6") soundfile = 'sound/guitar/An6.ogg'
			if("Bb3") soundfile = 'sound/guitar/Bb3.ogg'
			if("Bb4") soundfile = 'sound/guitar/Bb4.ogg'
			if("Bb5") soundfile = 'sound/guitar/Bb5.ogg'
			if("Bb6") soundfile = 'sound/guitar/Bb6.ogg'
			if("Bn3") soundfile = 'sound/guitar/Bn3.ogg'
			if("Bn4") soundfile = 'sound/guitar/Bn4.ogg'
			if("Bn5") soundfile = 'sound/guitar/Bn5.ogg'
			if("Bn6") soundfile = 'sound/guitar/Bn6.ogg'
			if("Cb4") soundfile = 'sound/guitar/Cn4.ogg'
			if("Cb5") soundfile = 'sound/guitar/Cn5.ogg'
			if("Cb6") soundfile = 'sound/guitar/Cn6.ogg'
			if("Cb7") soundfile = 'sound/guitar/Cn6.ogg'
			if("Cn4") soundfile = 'sound/guitar/Cn4.ogg'
			if("Cn5") soundfile = 'sound/guitar/Cn5.ogg'
			if("Cn6") soundfile = 'sound/guitar/Cn6.ogg'
			if("Db4") soundfile = 'sound/guitar/Db4.ogg'
			if("Db5") soundfile = 'sound/guitar/Db5.ogg'
			if("Db6") soundfile = 'sound/guitar/Db6.ogg'
			if("Dn4") soundfile = 'sound/guitar/Dn4.ogg'
			if("Dn5") soundfile = 'sound/guitar/Dn5.ogg'
			if("Dn6") soundfile = 'sound/guitar/Dn6.ogg'
			if("Eb4") soundfile = 'sound/guitar/Eb4.ogg'
			if("Eb5") soundfile = 'sound/guitar/Eb5.ogg'
			if("Eb6") soundfile = 'sound/guitar/Eb6.ogg'
			if("En3") soundfile = 'sound/guitar/En3.ogg'
			if("En4") soundfile = 'sound/guitar/En4.ogg'
			if("En5") soundfile = 'sound/guitar/En5.ogg'
			if("En6") soundfile = 'sound/guitar/En6.ogg'
			if("Fb3") soundfile = 'sound/guitar/Fn3.ogg'
			if("Fb4") soundfile = 'sound/guitar/Fn4.ogg'
			if("Fb5") soundfile = 'sound/guitar/Fn5.ogg'
			if("Fb6") soundfile = 'sound/guitar/Fn6.ogg'
			if("Fn3") soundfile = 'sound/guitar/Fn3.ogg'
			if("Fn4") soundfile = 'sound/guitar/Fn4.ogg'
			if("Fn5") soundfile = 'sound/guitar/Fn5.ogg'
			if("Fn6") soundfile = 'sound/guitar/Fn6.ogg'
			if("Gb3") soundfile = 'sound/guitar/Gb3.ogg'
			if("Gb4") soundfile = 'sound/guitar/Gb4.ogg'
			if("Gb5") soundfile = 'sound/guitar/Gb5.ogg'
			if("Gb6") soundfile = 'sound/guitar/Gb6.ogg'
			if("Gn3") soundfile = 'sound/guitar/Gn3.ogg'
			if("Gn4") soundfile = 'sound/guitar/Gn4.ogg'
			if("Gn5") soundfile = 'sound/guitar/Gn5.ogg'
			if("Gn6") soundfile = 'sound/guitar/Gn6.ogg'
	else if(InstrumentId == "violin")
		switch(note)
			if("Cn1")	soundfile = 'sound/violin/Cn1.mid'
			if("C#1")	soundfile = 'sound/violin/C#1.mid'
			if("Db1")	soundfile = 'sound/violin/Db1.mid'
			if("Dn1")	soundfile = 'sound/violin/Dn1.mid'
			if("D#1")	soundfile = 'sound/violin/D#1.mid'
			if("Eb1")	soundfile = 'sound/violin/Eb1.mid'
			if("En1")	soundfile = 'sound/violin/En1.mid'
			if("E#1")	soundfile = 'sound/violin/E#1.mid'
			if("Fb1")	soundfile = 'sound/violin/Fb1.mid'
			if("Fn1")	soundfile = 'sound/violin/Fn1.mid'
			if("F#1")	soundfile = 'sound/violin/F#1.mid'
			if("Gb1")	soundfile = 'sound/violin/Gb1.mid'
			if("Gn1")	soundfile = 'sound/violin/Gn1.mid'
			if("G#1")	soundfile = 'sound/violin/G#1.mid'
			if("Ab1")	soundfile = 'sound/violin/Ab1.mid'
			if("An1")	soundfile = 'sound/violin/An1.mid'
			if("A#1")	soundfile = 'sound/violin/A#1.mid'
			if("Bb1")	soundfile = 'sound/violin/Bb1.mid'
			if("Bn1")	soundfile = 'sound/violin/Bn1.mid'
			if("B#1")	soundfile = 'sound/violin/B#1.mid'
			if("Cb2")	soundfile = 'sound/violin/Cb2.mid'
			if("Cn2")	soundfile = 'sound/violin/Cn2.mid'
			if("C#2")	soundfile = 'sound/violin/C#2.mid'
			if("Db2")	soundfile = 'sound/violin/Db2.mid'
			if("Dn2")	soundfile = 'sound/violin/Dn2.mid'
			if("D#2")	soundfile = 'sound/violin/D#2.mid'
			if("Eb2")	soundfile = 'sound/violin/Eb2.mid'
			if("En2")	soundfile = 'sound/violin/En2.mid'
			if("E#2")	soundfile = 'sound/violin/E#2.mid'
			if("Fb2")	soundfile = 'sound/violin/Fb2.mid'
			if("Fn2")	soundfile = 'sound/violin/Fn2.mid'
			if("F#2")	soundfile = 'sound/violin/F#2.mid'
			if("Gb2")	soundfile = 'sound/violin/Gb2.mid'
			if("Gn2")	soundfile = 'sound/violin/Gn2.mid'
			if("G#2")	soundfile = 'sound/violin/G#2.mid'
			if("Ab2")	soundfile = 'sound/violin/Ab2.mid'
			if("An2")	soundfile = 'sound/violin/An2.mid'
			if("A#2")	soundfile = 'sound/violin/A#2.mid'
			if("Bb2")	soundfile = 'sound/violin/Bb2.mid'
			if("Bn2")	soundfile = 'sound/violin/Bn2.mid'
			if("B#2")	soundfile = 'sound/violin/B#2.mid'
			if("Cb3")	soundfile = 'sound/violin/Cb3.mid'
			if("Cn3")	soundfile = 'sound/violin/Cn3.mid'
			if("C#3")	soundfile = 'sound/violin/C#3.mid'
			if("Db3")	soundfile = 'sound/violin/Db3.mid'
			if("Dn3")	soundfile = 'sound/violin/Dn3.mid'
			if("D#3")	soundfile = 'sound/violin/D#3.mid'
			if("Eb3")	soundfile = 'sound/violin/Eb3.mid'
			if("En3")	soundfile = 'sound/violin/En3.mid'
			if("E#3")	soundfile = 'sound/violin/E#3.mid'
			if("Fb3")	soundfile = 'sound/violin/Fb3.mid'
			if("Fn3")	soundfile = 'sound/violin/Fn3.mid'
			if("F#3")	soundfile = 'sound/violin/F#3.mid'
			if("Gb3")	soundfile = 'sound/violin/Gb3.mid'
			if("Gn3")	soundfile = 'sound/violin/Gn3.mid'
			if("G#3")	soundfile = 'sound/violin/G#3.mid'
			if("Ab3")	soundfile = 'sound/violin/Ab3.mid'
			if("An3")	soundfile = 'sound/violin/An3.mid'
			if("A#3")	soundfile = 'sound/violin/A#3.mid'
			if("Bb3")	soundfile = 'sound/violin/Bb3.mid'
			if("Bn3")	soundfile = 'sound/violin/Bn3.mid'
			if("B#3")	soundfile = 'sound/violin/B#3.mid'
			if("Cb4")	soundfile = 'sound/violin/Cb4.mid'
			if("Cn4")	soundfile = 'sound/violin/Cn4.mid'
			if("C#4")	soundfile = 'sound/violin/C#4.mid'
			if("Db4")	soundfile = 'sound/violin/Db4.mid'
			if("Dn4")	soundfile = 'sound/violin/Dn4.mid'
			if("D#4")	soundfile = 'sound/violin/D#4.mid'
			if("Eb4")	soundfile = 'sound/violin/Eb4.mid'
			if("En4")	soundfile = 'sound/violin/En4.mid'
			if("E#4")	soundfile = 'sound/violin/E#4.mid'
			if("Fb4")	soundfile = 'sound/violin/Fb4.mid'
			if("Fn4")	soundfile = 'sound/violin/Fn4.mid'
			if("F#4")	soundfile = 'sound/violin/F#4.mid'
			if("Gb4")	soundfile = 'sound/violin/Gb4.mid'
			if("Gn4")	soundfile = 'sound/violin/Gn4.mid'
			if("G#4")	soundfile = 'sound/violin/G#4.mid'
			if("Ab4")	soundfile = 'sound/violin/Ab4.mid'
			if("An4")	soundfile = 'sound/violin/An4.mid'
			if("A#4")	soundfile = 'sound/violin/A#4.mid'
			if("Bb4")	soundfile = 'sound/violin/Bb4.mid'
			if("Bn4")	soundfile = 'sound/violin/Bn4.mid'
			if("B#4")	soundfile = 'sound/violin/B#4.mid'
			if("Cb5")	soundfile = 'sound/violin/Cb5.mid'
			if("Cn5")	soundfile = 'sound/violin/Cn5.mid'
			if("C#5")	soundfile = 'sound/violin/C#5.mid'
			if("Db5")	soundfile = 'sound/violin/Db5.mid'
			if("Dn5")	soundfile = 'sound/violin/Dn5.mid'
			if("D#5")	soundfile = 'sound/violin/D#5.mid'
			if("Eb5")	soundfile = 'sound/violin/Eb5.mid'
			if("En5")	soundfile = 'sound/violin/En5.mid'
			if("E#5")	soundfile = 'sound/violin/E#5.mid'
			if("Fb5")	soundfile = 'sound/violin/Fb5.mid'
			if("Fn5")	soundfile = 'sound/violin/Fn5.mid'
			if("F#5")	soundfile = 'sound/violin/F#5.mid'
			if("Gb5")	soundfile = 'sound/violin/Gb5.mid'
			if("Gn5")	soundfile = 'sound/violin/Gn5.mid'
			if("G#5")	soundfile = 'sound/violin/G#5.mid'
			if("Ab5")	soundfile = 'sound/violin/Ab5.mid'
			if("An5")	soundfile = 'sound/violin/An5.mid'
			if("A#5")	soundfile = 'sound/violin/A#5.mid'
			if("Bb5")	soundfile = 'sound/violin/Bb5.mid'
			if("Bn5")	soundfile = 'sound/violin/Bn5.mid'
			if("B#5")	soundfile = 'sound/violin/B#5.mid'
			if("Cb6")	soundfile = 'sound/violin/Cb6.mid'
			if("Cn6")	soundfile = 'sound/violin/Cn6.mid'
			if("C#6")	soundfile = 'sound/violin/C#6.mid'
			if("Db6")	soundfile = 'sound/violin/Db6.mid'
			if("Dn6")	soundfile = 'sound/violin/Dn6.mid'
			if("D#6")	soundfile = 'sound/violin/D#6.mid'
			if("Eb6")	soundfile = 'sound/violin/Eb6.mid'
			if("En6")	soundfile = 'sound/violin/En6.mid'
			if("E#6")	soundfile = 'sound/violin/E#6.mid'
			if("Fb6")	soundfile = 'sound/violin/Fb6.mid'
			if("Fn6")	soundfile = 'sound/violin/Fn6.mid'
			if("F#6")	soundfile = 'sound/violin/F#6.mid'
			if("Gb6")	soundfile = 'sound/violin/Gb6.mid'
			if("Gn6")	soundfile = 'sound/violin/Gn6.mid'
			if("G#6")	soundfile = 'sound/violin/G#6.mid'
			if("Ab6")	soundfile = 'sound/violin/Ab6.mid'
			if("An6")	soundfile = 'sound/violin/An6.mid'
			if("A#6")	soundfile = 'sound/violin/A#6.mid'
			if("Bb6")	soundfile = 'sound/violin/Bb6.mid'
			if("Bn6")	soundfile = 'sound/violin/Bn6.mid'
			if("B#6")	soundfile = 'sound/violin/B#6.mid'
			if("Cb7")	soundfile = 'sound/violin/Cb7.mid'
			if("Cn7")	soundfile = 'sound/violin/Cn7.mid'
			if("C#7")	soundfile = 'sound/violin/C#7.mid'
			if("Db7")	soundfile = 'sound/violin/Db7.mid'
			if("Dn7")	soundfile = 'sound/violin/Dn7.mid'
			if("D#7")	soundfile = 'sound/violin/D#7.mid'
			if("Eb7")	soundfile = 'sound/violin/Eb7.mid'
			if("En7")	soundfile = 'sound/violin/En7.mid'
			if("E#7")	soundfile = 'sound/violin/E#7.mid'
			if("Fb7")	soundfile = 'sound/violin/Fb7.mid'
			if("Fn7")	soundfile = 'sound/violin/Fn7.mid'
			if("F#7")	soundfile = 'sound/violin/F#7.mid'
			if("Gb7")	soundfile = 'sound/violin/Gb7.mid'
			if("Gn7")	soundfile = 'sound/violin/Gn7.mid'
			if("G#7")	soundfile = 'sound/violin/G#7.mid'
			if("Ab7")	soundfile = 'sound/violin/Ab7.mid'
			if("An7")	soundfile = 'sound/violin/An7.mid'
			if("A#7")	soundfile = 'sound/violin/A#7.mid'
			if("Bb7")	soundfile = 'sound/violin/Bb7.mid'
			if("Bn7")	soundfile = 'sound/violin/Bn7.mid'
			if("B#7")	soundfile = 'sound/violin/B#7.mid'
			if("Cb8")	soundfile = 'sound/violin/Cb8.mid'
			if("Cn8")	soundfile = 'sound/violin/Cn8.mid'
			if("C#8")	soundfile = 'sound/violin/C#8.mid'
			if("Db8")	soundfile = 'sound/violin/Db8.mid'
			if("Dn8")	soundfile = 'sound/violin/Dn8.mid'
			if("D#8")	soundfile = 'sound/violin/D#8.mid'
			if("Eb8")	soundfile = 'sound/violin/Eb8.mid'
			if("En8")	soundfile = 'sound/violin/En8.mid'
			if("E#8")	soundfile = 'sound/violin/E#8.mid'
			if("Fb8")	soundfile = 'sound/violin/Fb8.mid'
			if("Fn8")	soundfile = 'sound/violin/Fn8.mid'
			if("F#8")	soundfile = 'sound/violin/F#8.mid'
			if("Gb8")	soundfile = 'sound/violin/Gb8.mid'
			if("Gn8")	soundfile = 'sound/violin/Gn8.mid'
			if("G#8")	soundfile = 'sound/violin/G#8.mid'
			if("Ab8")	soundfile = 'sound/violin/Ab8.mid'
			if("An8")	soundfile = 'sound/violin/An8.mid'
			if("A#8")	soundfile = 'sound/violin/A#8.mid'
			if("Bb8")	soundfile = 'sound/violin/Bb8.mid'
			if("Bn8")	soundfile = 'sound/violin/Bn8.mid'
			if("B#8")	soundfile = 'sound/violin/B#8.mid'
			if("Cb9")	soundfile = 'sound/violin/Cb9.mid'
			if("Cn9")	soundfile = 'sound/violin/Cn9.mid'
	else if(InstrumentId == "accordion")
		switch(note)
			if("Ab2") soundfile = 'sound/accordion/Ab2.mid'
			if("Ab3") soundfile = 'sound/accordion/Ab3.mid'
			if("Ab4") soundfile = 'sound/accordion/Ab4.mid'
			if("Ab5") soundfile = 'sound/accordion/Ab5.mid'
			if("Ab6") soundfile = 'sound/accordion/Ab6.mid'
			if("Ab2") soundfile = 'sound/accordion/Ab2.mid'
			if("An3") soundfile = 'sound/accordion/An3.mid'
			if("An4") soundfile = 'sound/accordion/An4.mid'
			if("An5") soundfile = 'sound/accordion/An5.mid'
			if("An6") soundfile = 'sound/accordion/An6.mid'
			if("Bb2") soundfile = 'sound/accordion/Bb2.mid'
			if("Bb3") soundfile = 'sound/accordion/Bb3.mid'
			if("Bb4") soundfile = 'sound/accordion/Bb4.mid'
			if("Bb5") soundfile = 'sound/accordion/Bb5.mid'
			if("Bb6") soundfile = 'sound/accordion/Bb6.mid'
			if("Bn2") soundfile = 'sound/accordion/Bn2.mid'
			if("Bn3") soundfile = 'sound/accordion/Bn3.mid'
			if("Bn4") soundfile = 'sound/accordion/Bn4.mid'
			if("Bn5") soundfile = 'sound/accordion/Bn5.mid'
			if("Bn6") soundfile = 'sound/accordion/Bn6.mid'
			if("Cb2") soundfile = 'sound/accordion/Cn2.mid'
			if("Cb3") soundfile = 'sound/accordion/Cn3.mid'
			if("Cb4") soundfile = 'sound/accordion/Cn4.mid'
			if("Cb5") soundfile = 'sound/accordion/Cn5.mid'
			if("Cb6") soundfile = 'sound/accordion/Cn6.mid'
			if("Cn2") soundfile = 'sound/accordion/Cn2.mid'
			if("Cn3") soundfile = 'sound/accordion/Cn3.mid'
			if("Cn4") soundfile = 'sound/accordion/Cn4.mid'
			if("Cn5") soundfile = 'sound/accordion/Cn5.mid'
			if("Cn6") soundfile = 'sound/accordion/Cn6.mid'
			if("Db2") soundfile = 'sound/accordion/Db2.mid'
			if("Db3") soundfile = 'sound/accordion/Db3.mid'
			if("Db4") soundfile = 'sound/accordion/Db4.mid'
			if("Db5") soundfile = 'sound/accordion/Db5.mid'
			if("Db6") soundfile = 'sound/accordion/Db6.mid'
			if("Dn2") soundfile = 'sound/accordion/Dn2.mid'
			if("Dn3") soundfile = 'sound/accordion/Dn3.mid'
			if("Dn4") soundfile = 'sound/accordion/Dn4.mid'
			if("Dn5") soundfile = 'sound/accordion/Dn5.mid'
			if("Dn6") soundfile = 'sound/accordion/Dn6.mid'
			if("Eb2") soundfile = 'sound/accordion/Eb2.mid'
			if("Eb3") soundfile = 'sound/accordion/Eb3.mid'
			if("Eb4") soundfile = 'sound/accordion/Eb4.mid'
			if("Eb5") soundfile = 'sound/accordion/Eb5.mid'
			if("Eb6") soundfile = 'sound/accordion/Eb6.mid'
			if("En2") soundfile = 'sound/accordion/En2.mid'
			if("En3") soundfile = 'sound/accordion/En3.mid'
			if("En4") soundfile = 'sound/accordion/En4.mid'
			if("En5") soundfile = 'sound/accordion/En5.mid'
			if("En6") soundfile = 'sound/accordion/En6.mid'
			if("Fb2") soundfile = 'sound/accordion/Fn2.mid'
			if("Fb3") soundfile = 'sound/accordion/Fn3.mid'
			if("Fb4") soundfile = 'sound/accordion/Fn4.mid'
			if("Fb5") soundfile = 'sound/accordion/Fn5.mid'
			if("Fb6") soundfile = 'sound/accordion/Fn6.mid'
			if("Fn2") soundfile = 'sound/accordion/Fn2.mid'
			if("Fn3") soundfile = 'sound/accordion/Fn3.mid'
			if("Fn4") soundfile = 'sound/accordion/Fn4.mid'
			if("Fn5") soundfile = 'sound/accordion/Fn5.mid'
			if("Fn6") soundfile = 'sound/accordion/Fn6.mid'
			if("Gb2") soundfile = 'sound/accordion/Gb2.mid'
			if("Gb3") soundfile = 'sound/accordion/Gb3.mid'
			if("Gb4") soundfile = 'sound/accordion/Gb4.mid'
			if("Gb5") soundfile = 'sound/accordion/Gb5.mid'
			if("Gb6") soundfile = 'sound/accordion/Gb6.mid'
			if("Gn2") soundfile = 'sound/accordion/Gn2.mid'
			if("Gn3") soundfile = 'sound/accordion/Gn3.mid'
			if("Gn4") soundfile = 'sound/accordion/Gn4.mid'
			if("Gn5") soundfile = 'sound/accordion/Gn5.mid'
			if("Gn6") soundfile = 'sound/accordion/Gn6.mid'
	else if(InstrumentId == "harmonica")
		switch(note)
			if("Ab2") soundfile = 'sound/harmonica/Ab2.mid'
			if("Ab3") soundfile = 'sound/harmonica/Ab3.mid'
			if("Ab4") soundfile = 'sound/harmonica/Ab4.mid'
			if("Ab5") soundfile = 'sound/harmonica/Ab5.mid'
			if("Ab6") soundfile = 'sound/harmonica/Ab6.mid'
			if("Ab2") soundfile = 'sound/harmonica/Ab2.mid'
			if("An3") soundfile = 'sound/harmonica/An3.mid'
			if("An4") soundfile = 'sound/harmonica/An4.mid'
			if("An5") soundfile = 'sound/harmonica/An5.mid'
			if("An6") soundfile = 'sound/harmonica/An6.mid'
			if("Bb2") soundfile = 'sound/harmonica/Bb2.mid'
			if("Bb3") soundfile = 'sound/harmonica/Bb3.mid'
			if("Bb4") soundfile = 'sound/harmonica/Bb4.mid'
			if("Bb5") soundfile = 'sound/harmonica/Bb5.mid'
			if("Bb6") soundfile = 'sound/harmonica/Bb6.mid'
			if("Bn2") soundfile = 'sound/harmonica/Bn2.mid'
			if("Bn3") soundfile = 'sound/harmonica/Bn3.mid'
			if("Bn4") soundfile = 'sound/harmonica/Bn4.mid'
			if("Bn5") soundfile = 'sound/harmonica/Bn5.mid'
			if("Bn6") soundfile = 'sound/harmonica/Bn6.mid'
			if("Cb2") soundfile = 'sound/harmonica/Cn2.mid'
			if("Cb3") soundfile = 'sound/harmonica/Cn3.mid'
			if("Cb4") soundfile = 'sound/harmonica/Cn4.mid'
			if("Cb5") soundfile = 'sound/harmonica/Cn5.mid'
			if("Cb6") soundfile = 'sound/harmonica/Cn6.mid'
			if("Cn2") soundfile = 'sound/harmonica/Cn2.mid'
			if("Cn3") soundfile = 'sound/harmonica/Cn3.mid'
			if("Cn4") soundfile = 'sound/harmonica/Cn4.mid'
			if("Cn5") soundfile = 'sound/harmonica/Cn5.mid'
			if("Cn6") soundfile = 'sound/harmonica/Cn6.mid'
			if("Db2") soundfile = 'sound/harmonica/Db2.mid'
			if("Db3") soundfile = 'sound/harmonica/Db3.mid'
			if("Db4") soundfile = 'sound/harmonica/Db4.mid'
			if("Db5") soundfile = 'sound/harmonica/Db5.mid'
			if("Db6") soundfile = 'sound/harmonica/Db6.mid'
			if("Dn2") soundfile = 'sound/harmonica/Dn2.mid'
			if("Dn3") soundfile = 'sound/harmonica/Dn3.mid'
			if("Dn4") soundfile = 'sound/harmonica/Dn4.mid'
			if("Dn5") soundfile = 'sound/harmonica/Dn5.mid'
			if("Dn6") soundfile = 'sound/harmonica/Dn6.mid'
			if("Eb2") soundfile = 'sound/harmonica/Eb2.mid'
			if("Eb3") soundfile = 'sound/harmonica/Eb3.mid'
			if("Eb4") soundfile = 'sound/harmonica/Eb4.mid'
			if("Eb5") soundfile = 'sound/harmonica/Eb5.mid'
			if("Eb6") soundfile = 'sound/harmonica/Eb6.mid'
			if("En2") soundfile = 'sound/harmonica/En2.mid'
			if("En3") soundfile = 'sound/harmonica/En3.mid'
			if("En4") soundfile = 'sound/harmonica/En4.mid'
			if("En5") soundfile = 'sound/harmonica/En5.mid'
			if("En6") soundfile = 'sound/harmonica/En6.mid'
			if("Fb2") soundfile = 'sound/harmonica/Fn2.mid'
			if("Fb3") soundfile = 'sound/harmonica/Fn3.mid'
			if("Fb4") soundfile = 'sound/harmonica/Fn4.mid'
			if("Fb5") soundfile = 'sound/harmonica/Fn5.mid'
			if("Fb6") soundfile = 'sound/harmonica/Fn6.mid'
			if("Fn2") soundfile = 'sound/harmonica/Fn2.mid'
			if("Fn3") soundfile = 'sound/harmonica/Fn3.mid'
			if("Fn4") soundfile = 'sound/harmonica/Fn4.mid'
			if("Fn5") soundfile = 'sound/harmonica/Fn5.mid'
			if("Fn6") soundfile = 'sound/harmonica/Fn6.mid'
			if("Gb2") soundfile = 'sound/harmonica/Gb2.mid'
			if("Gb3") soundfile = 'sound/harmonica/Gb3.mid'
			if("Gb4") soundfile = 'sound/harmonica/Gb4.mid'
			if("Gb5") soundfile = 'sound/harmonica/Gb5.mid'
			if("Gb6") soundfile = 'sound/harmonica/Gb6.mid'
			if("Gn2") soundfile = 'sound/harmonica/Gn2.mid'
			if("Gn3") soundfile = 'sound/harmonica/Gn3.mid'
			if("Gn4") soundfile = 'sound/harmonica/Gn4.mid'
			if("Gn5") soundfile = 'sound/harmonica/Gn5.mid'
			if("Gn6") soundfile = 'sound/harmonica/Gn6.mid'
	else if(InstrumentId == "saxophone")
		switch(note)
			if("Ab2") soundfile = 'sound/saxophone/Ab2.mid'
			if("Ab3") soundfile = 'sound/saxophone/Ab3.mid'
			if("Ab4") soundfile = 'sound/saxophone/Ab4.mid'
			if("Ab5") soundfile = 'sound/saxophone/Ab5.mid'
			if("Ab6") soundfile = 'sound/saxophone/Ab6.mid'
			if("Ab2") soundfile = 'sound/saxophone/Ab2.mid'
			if("An3") soundfile = 'sound/saxophone/An3.mid'
			if("An4") soundfile = 'sound/saxophone/An4.mid'
			if("An5") soundfile = 'sound/saxophone/An5.mid'
			if("An6") soundfile = 'sound/saxophone/An6.mid'
			if("Bb2") soundfile = 'sound/saxophone/Bb2.mid'
			if("Bb3") soundfile = 'sound/saxophone/Bb3.mid'
			if("Bb4") soundfile = 'sound/saxophone/Bb4.mid'
			if("Bb5") soundfile = 'sound/saxophone/Bb5.mid'
			if("Bb6") soundfile = 'sound/saxophone/Bb6.mid'
			if("Bn2") soundfile = 'sound/saxophone/Bn2.mid'
			if("Bn3") soundfile = 'sound/saxophone/Bn3.mid'
			if("Bn4") soundfile = 'sound/saxophone/Bn4.mid'
			if("Bn5") soundfile = 'sound/saxophone/Bn5.mid'
			if("Bn6") soundfile = 'sound/saxophone/Bn6.mid'
			if("Cb2") soundfile = 'sound/saxophone/Cn2.mid'
			if("Cb3") soundfile = 'sound/saxophone/Cn3.mid'
			if("Cb4") soundfile = 'sound/saxophone/Cn4.mid'
			if("Cb5") soundfile = 'sound/saxophone/Cn5.mid'
			if("Cb6") soundfile = 'sound/saxophone/Cn6.mid'
			if("Cn2") soundfile = 'sound/saxophone/Cn2.mid'
			if("Cn3") soundfile = 'sound/saxophone/Cn3.mid'
			if("Cn4") soundfile = 'sound/saxophone/Cn4.mid'
			if("Cn5") soundfile = 'sound/saxophone/Cn5.mid'
			if("Cn6") soundfile = 'sound/saxophone/Cn6.mid'
			if("Db2") soundfile = 'sound/saxophone/Db2.mid'
			if("Db3") soundfile = 'sound/saxophone/Db3.mid'
			if("Db4") soundfile = 'sound/saxophone/Db4.mid'
			if("Db5") soundfile = 'sound/saxophone/Db5.mid'
			if("Db6") soundfile = 'sound/saxophone/Db6.mid'
			if("Dn2") soundfile = 'sound/saxophone/Dn2.mid'
			if("Dn3") soundfile = 'sound/saxophone/Dn3.mid'
			if("Dn4") soundfile = 'sound/saxophone/Dn4.mid'
			if("Dn5") soundfile = 'sound/saxophone/Dn5.mid'
			if("Dn6") soundfile = 'sound/saxophone/Dn6.mid'
			if("Eb2") soundfile = 'sound/saxophone/Eb2.mid'
			if("Eb3") soundfile = 'sound/saxophone/Eb3.mid'
			if("Eb4") soundfile = 'sound/saxophone/Eb4.mid'
			if("Eb5") soundfile = 'sound/saxophone/Eb5.mid'
			if("Eb6") soundfile = 'sound/saxophone/Eb6.mid'
			if("En2") soundfile = 'sound/saxophone/En2.mid'
			if("En3") soundfile = 'sound/saxophone/En3.mid'
			if("En4") soundfile = 'sound/saxophone/En4.mid'
			if("En5") soundfile = 'sound/saxophone/En5.mid'
			if("En6") soundfile = 'sound/saxophone/En6.mid'
			if("Fb2") soundfile = 'sound/saxophone/Fn2.mid'
			if("Fb3") soundfile = 'sound/saxophone/Fn3.mid'
			if("Fb4") soundfile = 'sound/saxophone/Fn4.mid'
			if("Fb5") soundfile = 'sound/saxophone/Fn5.mid'
			if("Fb6") soundfile = 'sound/saxophone/Fn6.mid'
			if("Fn2") soundfile = 'sound/saxophone/Fn2.mid'
			if("Fn3") soundfile = 'sound/saxophone/Fn3.mid'
			if("Fn4") soundfile = 'sound/saxophone/Fn4.mid'
			if("Fn5") soundfile = 'sound/saxophone/Fn5.mid'
			if("Fn6") soundfile = 'sound/saxophone/Fn6.mid'
			if("Gb2") soundfile = 'sound/saxophone/Gb2.mid'
			if("Gb3") soundfile = 'sound/saxophone/Gb3.mid'
			if("Gb4") soundfile = 'sound/saxophone/Gb4.mid'
			if("Gb5") soundfile = 'sound/saxophone/Gb5.mid'
			if("Gb6") soundfile = 'sound/saxophone/Gb6.mid'
			if("Gn2") soundfile = 'sound/saxophone/Gn2.mid'
			if("Gn3") soundfile = 'sound/saxophone/Gn4.mid'
			if("Gn4") soundfile = 'sound/saxophone/Gn4.mid'
			if("Gn5") soundfile = 'sound/saxophone/Gn5.mid'
			if("Gn6") soundfile = 'sound/saxophone/Gn6.mid'
	else if(InstrumentId == "recorder")
		switch(note)
			if("Ab2") soundfile = 'sound/recorder/Ab2.mid'
			if("Ab3") soundfile = 'sound/recorder/Ab3.mid'
			if("Ab4") soundfile = 'sound/recorder/Ab4.mid'
			if("Ab5") soundfile = 'sound/recorder/Ab5.mid'
			if("Ab6") soundfile = 'sound/recorder/Ab6.mid'
			if("Ab2") soundfile = 'sound/recorder/Ab2.mid'
			if("An3") soundfile = 'sound/recorder/An3.mid'
			if("An4") soundfile = 'sound/recorder/An4.mid'
			if("An5") soundfile = 'sound/recorder/An5.mid'
			if("An6") soundfile = 'sound/recorder/An6.mid'
			if("Bb2") soundfile = 'sound/recorder/Bb2.mid'
			if("Bb3") soundfile = 'sound/recorder/Bb3.mid'
			if("Bb4") soundfile = 'sound/recorder/Bb4.mid'
			if("Bb5") soundfile = 'sound/recorder/Bb5.mid'
			if("Bb6") soundfile = 'sound/recorder/Bb6.mid'
			if("Bn2") soundfile = 'sound/recorder/Bn2.mid'
			if("Bn3") soundfile = 'sound/recorder/Bn3.mid'
			if("Bn4") soundfile = 'sound/recorder/Bn4.mid'
			if("Bn5") soundfile = 'sound/recorder/Bn5.mid'
			if("Bn6") soundfile = 'sound/recorder/Bn6.mid'
			if("Cb2") soundfile = 'sound/recorder/Cn2.mid'
			if("Cb3") soundfile = 'sound/recorder/Cn3.mid'
			if("Cb4") soundfile = 'sound/recorder/Cn4.mid'
			if("Cb5") soundfile = 'sound/recorder/Cn5.mid'
			if("Cb6") soundfile = 'sound/recorder/Cn6.mid'
			if("Cn2") soundfile = 'sound/recorder/Cn2.mid'
			if("Cn3") soundfile = 'sound/recorder/Cn3.mid'
			if("Cn4") soundfile = 'sound/recorder/Cn4.mid'
			if("Cn5") soundfile = 'sound/recorder/Cn5.mid'
			if("Cn6") soundfile = 'sound/recorder/Cn6.mid'
			if("Db2") soundfile = 'sound/recorder/Db2.mid'
			if("Db3") soundfile = 'sound/recorder/Db3.mid'
			if("Db4") soundfile = 'sound/recorder/Db4.mid'
			if("Db5") soundfile = 'sound/recorder/Db5.mid'
			if("Db6") soundfile = 'sound/recorder/Db6.mid'
			if("Dn2") soundfile = 'sound/recorder/Dn2.mid'
			if("Dn3") soundfile = 'sound/recorder/Dn3.mid'
			if("Dn4") soundfile = 'sound/recorder/Dn4.mid'
			if("Dn5") soundfile = 'sound/recorder/Dn5.mid'
			if("Dn6") soundfile = 'sound/recorder/Dn6.mid'
			if("Eb2") soundfile = 'sound/recorder/Eb2.mid'
			if("Eb3") soundfile = 'sound/recorder/Eb3.mid'
			if("Eb4") soundfile = 'sound/recorder/Eb4.mid'
			if("Eb5") soundfile = 'sound/recorder/Eb5.mid'
			if("Eb6") soundfile = 'sound/recorder/Eb6.mid'
			if("En2") soundfile = 'sound/recorder/En2.mid'
			if("En3") soundfile = 'sound/recorder/En3.mid'
			if("En4") soundfile = 'sound/recorder/En4.mid'
			if("En5") soundfile = 'sound/recorder/En5.mid'
			if("En6") soundfile = 'sound/recorder/En6.mid'
			if("Fb2") soundfile = 'sound/recorder/Fn2.mid'
			if("Fb3") soundfile = 'sound/recorder/Fn3.mid'
			if("Fb4") soundfile = 'sound/recorder/Fn4.mid'
			if("Fb5") soundfile = 'sound/recorder/Fn5.mid'
			if("Fb6") soundfile = 'sound/recorder/Fn6.mid'
			if("Fn2") soundfile = 'sound/recorder/Fn2.mid'
			if("Fn3") soundfile = 'sound/recorder/Fn3.mid'
			if("Fn4") soundfile = 'sound/recorder/Fn4.mid'
			if("Fn5") soundfile = 'sound/recorder/Fn5.mid'
			if("Fn6") soundfile = 'sound/recorder/Fn6.mid'
			if("Gb2") soundfile = 'sound/recorder/Gb2.mid'
			if("Gb3") soundfile = 'sound/recorder/Gb3.mid'
			if("Gb4") soundfile = 'sound/recorder/Gb4.mid'
			if("Gb5") soundfile = 'sound/recorder/Gb5.mid'
			if("Gb6") soundfile = 'sound/recorder/Gb6.mid'
			if("Gn2") soundfile = 'sound/recorder/Gn2.mid'
			if("Gn3") soundfile = 'sound/recorder/Gn3.mid'
			if("Gn4") soundfile = 'sound/recorder/Gn4.mid'
			if("Gn5") soundfile = 'sound/recorder/Gn5.mid'
			if("Gn6") soundfile = 'sound/recorder/Gn6.mid'
	else	return

	sound_to(hearers(15, get_turf(src)), sound(soundfile))

/obj/item/instrument/proc/playsong()
	do
		var/cur_oct[7]
		var/cur_acc[7]
		for(var/i = 1 to 7)
			cur_oct[i] = "3"
			cur_acc[i] = "n"

		for(var/line in song.lines)
//			log_debug(line)

			for(var/beat in splittext(lowertext(line), ","))
//				log_debug("beat: [beat]")

				var/list/notes = splittext(beat, "/")
				for(var/note in splittext(notes[1], "-"))
//					log_debug("note: [note]")

					if(!playing || !isliving(loc))//If the instrument is playing, or isn't held by a person
						playing = 0
						return
					if(lentext(note) == 0)
						continue
//					log_debug("Parse: [copytext(note,1,2)]")

					var/cur_note = text2ascii(note) - 96
					if(cur_note < 1 || cur_note > 7)
						continue
					for(var/i=2 to lentext(note))
						var/ni = copytext(note,i,i+1)
						if(!text2num(ni))
							if(ni == "#" || ni == "b" || ni == "n")
								cur_acc[cur_note] = ni
							else if(ni == "s")
								cur_acc[cur_note] = "#" // so shift is never required
						else
							cur_oct[cur_note] = ni
					playnote(uppertext(copytext(note,1,2)) + cur_acc[cur_note] + cur_oct[cur_note])
				if(notes.len >= 2 && text2num(notes[2]))
					sleep(song.tempo / text2num(notes[2]))
				else
					sleep(song.tempo)
		if(repeat > 0)
			repeat-- //Infinite loops are baaaad.
	while(repeat > 0)
	playing = 0

/obj/item/instrument/attack_self(mob/user as mob)
	if(!isliving(user) || user.stat || user.restrained() || user.lying)	return
	user.set_machine(src)

	var/dat = "<HEAD><TITLE>instrument</TITLE></HEAD><BODY>"

	if(song)
		if(song.lines.len > 0 && !(playing))
			dat += "<A href='?src=\ref[src];play=1'>Play Song</A><BR><BR>"
			dat += "<A href='?src=\ref[src];repeat=1'>Repeat Song: [repeat] times.</A><BR><BR>"
		if(playing)
			dat += "<A href='?src=\ref[src];stop=1'>Stop Playing</A><BR>"
			dat += "Repeats left: [repeat].<BR><BR>"
	if(!edit)
		dat += "<A href='?src=\ref[src];edit=2'>Show Editor</A><BR><BR>"
	else
		dat += "<A href='?src=\ref[src];edit=1'>Hide Editor</A><BR>"
		dat += "<A href='?src=\ref[src];newsong=1'>Start a New Song</A><BR>"
		dat += "<A href='?src=\ref[src];import=1'>Import a Song</A><BR><BR>"
		if(song)
			var/calctempo = (10/song.tempo)*60
			dat += "Tempo : <A href='?src=\ref[src];tempo=10'>-</A><A href='?src=\ref[src];tempo=1'>-</A> [calctempo] BPM <A href='?src=\ref[src];tempo=-1'>+</A><A href='?src=\ref[src];tempo=-10'>+</A><BR><BR>"
			var/linecount = 0
			for(var/line in song.lines)
				linecount += 1
				dat += "Line [linecount]: [line] <A href='?src=\ref[src];deleteline=[linecount]'>Delete Line</A> <A href='?src=\ref[src];modifyline=[linecount]'>Modify Line</A><BR>"
			dat += "<A href='?src=\ref[src];newline=1'>Add Line</A><BR><BR>"
		if(help)
			dat += "<A href='?src=\ref[src];help=1'>Hide Help</A><BR>"
			dat += {"
					Lines are a series of chords, separated by commas (,), each with notes seperated by hyphens (-).<br>
					Every note in a chord will play together, with chord timed by the tempo.<br>
					<br>
					Notes are played by the names of the note, and optionally, the accidental, and/or the octave number.<br>
					By default, every note is natural and in octave 3. Defining otherwise is remembered for each note.<br>
					Example: <i>C,D,E,F,G,A,B</i> will play a C major scale.<br>
					After a note has an accidental placed, it will be remembered: <i>C,C4,C,C3</i> is <i>C3,C4,C4,C3</i><br>
					Chords can be played simply by seperating each note with a hyphon: <i>A-C#,Cn-E,E-G#,Gn-B</i><br>
					A pause may be denoted by an empty chord: <i>C,E,,C,G</i><br>
					To make a chord be a different time, end it with /x, where the chord length will be length<br>
					defined by tempo / x: <i>C,G/2,E/4</i><br>
					Combined, an example is: <i>E-E4/4,/2,G#/8,B/8,E3-E4/4</i>
					<br>
					Lines may be up to 50 characters.<br>
					A song may only contain up to 50 lines.<br>
					"}
		else
			dat += "<A href='?src=\ref[src];help=2'>Show Help</A><BR>"
	dat += "</BODY></HTML>"
	user << browse(dat, "window=instrument;size=700x300")
	onclose(user, "instrument")

/obj/item/instrument/Topic(href, href_list)
	if(..())
		return 1
	if(!in_range(src, usr) || issilicon(usr) || !isliving(usr) || !usr.canmove || usr.restrained())
		usr << browse(null, "window=instrument;size=700x300")
		onclose(usr, "instrument")
		return

	if(href_list["newsong"])
		song = new()
	else if(song)
		if(href_list["repeat"]) //Changing this from a toggle to a number of repeats to avoid infinite loops.
			if(playing) return //So that people cant keep adding to repeat. If the do it intentionally, it could result in the server crashing.
			var/tempnum = input("How many times do you want to repeat this piece? (max:10)") as num|null
			if(tempnum > 10)
				tempnum = 10
			if(tempnum < 0)
				tempnum = 0
			repeat = round(tempnum)

		else if(href_list["tempo"])
			song.tempo += round(text2num(href_list["tempo"]))
			if(song.tempo < 1)
				song.tempo = 1

		else if(href_list["play"])
			if(song)
				playing = 1
				spawn() playsong()

		else if(href_list["newline"])
			var/newline = html_encode(input("Enter your line: ", "instrument") as text|null)
			if(!newline)
				return
			if(song.lines.len > 50)
				return
			if(lentext(newline) > 50)
				newline = copytext(newline, 1, 50)
			song.lines.Add(newline)

		else if(href_list["deleteline"])
			var/num = round(text2num(href_list["deleteline"]))
			if(num > song.lines.len || num < 1)
				return
			song.lines.Cut(num, num+1)

		else if(href_list["modifyline"])
			var/num = round(text2num(href_list["modifyline"]),1)
			var/content = html_encode(input("Enter your line: ", "instrument", song.lines[num]) as text|null)
			if(!content)
				return
			if(lentext(content) > 50)
				content = copytext(content, 1, 50)
			if(num > song.lines.len || num < 1)
				return
			song.lines[num] = content

		else if(href_list["stop"])
			playing = 0

		else if(href_list["help"])
			help = text2num(href_list["help"]) - 1

		else if(href_list["edit"])
			edit = text2num(href_list["edit"]) - 1

		else if(href_list["import"])
			var/t = ""
			do
				t = html_encode(input(usr, "Please paste the entire song, formatted:", text("[]", name), t)  as message)
				if(!in_range(src, usr))
					return

				if(lentext(t) >= 3072)
					var/cont = input(usr, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
					if(cont == "no")
						break
			while(lentext(t) > 3072)

			//split into lines
			spawn()
				var/list/lines = splittext(t, "\n")
				var/tempo = 5
				if(copytext(lines[1],1,6) == "BPM: ")
					tempo = 600 / text2num(copytext(lines[1],6))
					lines.Cut(1,2)
				if(lines.len > 50)
					to_chat(usr, "Too many lines!")
					lines.Cut(51)
				var/linenum = 1
				for(var/l in lines)
					if(lentext(l) > 50)
						to_chat(usr, "Line [linenum] too long!")
						lines.Remove(l)
					else
						linenum++
				song = new()
				song.lines = lines
				song.tempo = tempo

	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	return


/obj/item/instrument/guitar
	name = "guitar"
	desc = "Wooden frame with some metall strings. Touch them, and make some music."
	icon_state = "guitar"
	item_state = "guitar"
	force = 6
	InstrumentId = "guitar"
	attack_verb = list("played hard", "attacked", "crashed")

/obj/item/instrument/harmonica
	name = "harmonica"
	desc = "If you see this, you should be in the prison. "
	icon_state = "harmonica"
	item_state = "harmonica"
	force = 0
	InstrumentId  = "harmonica"

/obj/item/instrument/accordion
	name = "accordion"
	desc = "Sretch and squeeze it to make music."
	icon_state = "accordion"
	item_state = "accordion"
	force = 0
	InstrumentId  = "accordion"

/obj/item/instrument/recorder
	name = "recorder"
	desc = "Wooden stick with holes. Blow into it to make some music."
	icon_state = "recorder"
	item_state = "recorder"
	force = 3
	InstrumentId  = "recorder"
	attack_verb = list("played hard", "blowed", "played")

/obj/item/instrument/saxophone
	name = "saxophone"
	desc = "Curved metal stick with tube and multiple holes. Blow into it to make some music."
	icon_state = "saxophone"
	item_state = "saxophone"
	force = 3
	InstrumentId  = "saxophone"
	attack_verb = list("played hard", "blowed", "played")

/obj/item/instrument/violin
	name = "violin"
	desc = "A wooden musical instrument with four strings and a bow."
	icon_state = "violin"
	item_state = "violin"
	force = 4
	InstrumentId  = "violin"
	attack_verb = list("played hard", "bowed", "played")

