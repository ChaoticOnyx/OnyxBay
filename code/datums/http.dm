GLOBAL_LIST_EMPTY(__http_requests)

/datum/http_request
	var/id
	var/in_progress = FALSE

	var/method
	var/body
	var/headers
	var/url
	/// If present response body will be saved to this file.
	var/output_file

	var/_raw_response

/datum/http_request/Destroy(force)
	if(in_progress)
		util_crash_with("Deleting an asynchronous HTTP request leads to a memory leak. Waiting until completion...")

	while(!is_complete())
		stoplag()

	GLOB.__http_requests -= src

	. = ..()

/datum/http_request/think()
	if(!in_progress)
		return
	if(is_complete())
		GLOB.__http_requests -= src
		return

	set_next_think(world.time + 1 SECOND)

/datum/http_request/proc/prepare(method, url, body = "", list/headers, output_file)
	if (!length(headers))
		headers = ""
	else
		headers = json_encode(headers)

	src.method = method
	src.url = url
	src.body = body
	src.headers = headers
	src.output_file = output_file

/datum/http_request/proc/execute_blocking()
	_raw_response = rustg_http_request_blocking(method, url, body, headers, build_options())

/datum/http_request/proc/begin_async()
	if (in_progress)
		CRASH("Attempted to re-use a request object.")

	id = rustg_http_request_async(method, url, body, headers, build_options())

	if (isnull(text2num(id)))
		util_crash_with("Proc error: [id]")
		_raw_response = "Proc error: [id]"
	else
		in_progress = TRUE

	GLOB.__http_requests += src
	set_next_think(world.time + 1 SECOND)

/datum/http_request/proc/build_options()
	if(output_file)
		return json_encode(list("output_filename"=output_file,"body_filename"=null))
	return null

/datum/http_request/proc/is_complete()
	if (isnull(id))
		return TRUE

	if (!in_progress)
		return TRUE

	var/r = rustg_http_check_request(id)

	if (r == RUSTG_JOB_NO_RESULTS_YET)
		return FALSE
	else
		_raw_response = r
		in_progress = FALSE
		return TRUE

/datum/http_request/proc/into_response()
	var/datum/http_response/R = new()

	try
		var/list/L = json_decode(_raw_response)
		R.status_code = L["status_code"]
		R.headers = L["headers"]
		R.body = L["body"]
	catch
		R.errored = TRUE
		R.error = _raw_response

	return R

/datum/http_response
	var/status_code
	var/body
	var/list/headers

	var/errored = FALSE
	var/error
