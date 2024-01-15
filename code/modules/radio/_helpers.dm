/// Converts frequency value to a corresponding css class.
/proc/frequency_span_class(frequency)
	if(frequency in GLOB.ANTAG_FREQS)
		return "syndradio"

	if(frequency in GLOB.CENT_FREQS)
		return "centradio"

	if(frequency == GLOB.COMM_FREQ)
		return "comradio"

	if(frequency == GLOB.AI_FREQ)
		return "airadio"

	if(frequency == GLOB.SEC_FREQ)
		return "secradio"

	if(frequency == GLOB.ENG_FREQ)
		return "engradio"

	if(frequency == GLOB.SCI_FREQ)
		return "sciradio"

	if(frequency == GLOB.MED_FREQ)
		return "medradio"

	if(frequency == GLOB.SUP_FREQ)
		return "supradio"

	if(frequency == GLOB.SRV_FREQ)
		return "srvradio"

	if(frequency == GLOB.ENT_FREQ)
		return "entradio"

	if(frequency in GLOB.DEPT_FREQS)
		return "deptradio"

	return "radio"


/// Returns frequency's name if exists, frequency's code otherwise.
/proc/get_frequency_name(display_freq)
	if(display_freq in GLOB.ANTAG_FREQS)
		return "#unkn"

	var/freq_text
	for(var/channel in GLOB.RADIO_CHANNELS)
		if(GLOB.RADIO_CHANNELS[channel] == display_freq)
			freq_text = channel
			break

	if(!freq_text)
		freq_text = format_frequency(display_freq)

	return freq_text
