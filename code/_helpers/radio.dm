/// Converts frequency value to a corresponding css class.
/proc/frequency_span_class(frequency)
	if(frequency in GLOB.ANTAG_FREQS)
		return "syndradio"

	if(frequency in GLOB.CENT_FREQS)
		return "centradio"

	if(frequency == COMM_FREQ)
		return "comradio"

	if(frequency == AI_FREQ)
		return "airadio"

	if(frequency == SEC_FREQ)
		return "secradio"

	if(frequency == ENG_FREQ)
		return "engradio"

	if(frequency == SCI_FREQ)
		return "sciradio"

	if(frequency == MED_FREQ)
		return "medradio"

	if(frequency == SUP_FREQ)
		return "supradio"

	if(frequency == SRV_FREQ)
		return "srvradio"

	if(frequency == ENT_FREQ)
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
