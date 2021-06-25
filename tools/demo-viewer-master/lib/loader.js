'use strict';
const Appearance = require('./appearance.js');
const read_icon = require('./icon_reader.js');

module.exports = class Demo {
	constructor(source) { // source can be a Response, or a Blob/File
		this.initialized_promise = new Promise((resolve, reject) => {
			this._line_processor = this._line_processor_function(resolve);
			this._line_processor.next();
			this.load_error = reject;
		});
		this.initialized = false;

		this.read_buffer = null;
		this.read_buffer_end_pointer = 0;

		this.loaded_icons = new Map();
		this.version = undefined;
		this.init_turfs = [];
		this.init_objs = [];
		this.timeframes = [];
		this.commit = undefined;
		this.maxx = undefined;
		this.maxy = undefined;
		this.maxz = undefined;
		this.total_bytes_fetched = 0;
		this.streaming = false;
		if(!(source instanceof Response) && !source.stream) {
			// in case user's browser doesn't support reading a blob as a stream.
			let reader = new FileReader();
			reader.onload = () => {
				let text = reader.result;
				let lines = text.split(/\r?\n/g);
				lines.length--;
				for(let line of lines) {
					this.process_line(line);
				}
			};
			reader.readAsText(source);
		} else {
			let readable_stream = source.body || source.stream();
			this.read_stream(readable_stream).then(async () => {
				if(source instanceof Response) {
					let this_response = source;
					while(this_response.headers.get("accept-ranges") == "bytes" ||
						this_response.headers.get("x-allow-ss13-replay-streaming") == "true" // Why the snowflakey HTTP header? because the FUCKING CLOUDFLARE BLOCKS THE ACCEPT-RANGES HEADER. FUCK YOU FOR THAT CLOUD FLARE BY THE WAY.
					) {
						this.streaming = true;
						await new Promise(resolve => {setTimeout(resolve, 10000)});
						let querystring = new URLSearchParams(window.location.search);
						this_response = await fetch(this_response.url, {
							credentials: +querystring.get('send_credentials') ? 'include' : 'same-origin',
							headers: {
								'Range': 'bytes=' + this.total_bytes_fetched + '-'
							}
						});
						if(this_response.status == 206) {
							await this.read_stream(this_response.body);
						} else if(this_response.status != 416) {
							break;
						}
					}
					this.streaming = false;
				}
			});

		}
	}

	async read_stream(readable_stream) {
		let decoder = new TextDecoder('utf-8');
		if(!this.read_buffer) {
			this.read_buffer = new Uint8Array(2 * 1024 * 1024);
		}
		let reader = readable_stream.getReader();
		let chunk;
		let total_length = 0;
		while(((chunk = await reader.read()), !chunk.done)) {
			this.total_bytes_fetched += chunk.value.length;
			if(this.read_buffer_end_pointer + chunk.value.length > this.read_buffer.length) {
				let proposed_length = this.read_buffer.length;
				while(this.read_buffer_end_pointer + chunk.value.length > proposed_length) proposed_length *= 2;
				let new_buf = new Uint8Array(proposed_length);
				new_buf.set(this.read_buffer);
				this.read_buffer = new_buf;
			}
			this.read_buffer.set(chunk.value, this.read_buffer_end_pointer);
			this.read_buffer_end_pointer += chunk.value.length;
			let line_start = 0;
			for(let i = 0; i < this.read_buffer_end_pointer; i++) {
				if(this.read_buffer[i] == 0x0A) {
					let line_end = i;
					if(i > 0 && this.read_buffer[i-1] == 0x0D) line_end--;
					let line = decoder.decode(this.read_buffer.subarray(line_start, line_end));
					this.process_line(line);
					line_start = i+1;
				}
			}
			if(line_start > 0) {
				this.read_buffer.set(this.read_buffer.subarray(line_start));
				this.read_buffer_end_pointer -= line_start;
			}
		}
		if(!this.initialized) {
			this.load_error(new Error("Incomplete header on demo file"));
		}
	}

	process_line(line) {
		try {
			this._line_processor.next(line);
		} catch(e) {
			if(!this.initialized) {
				this.load_error();
			}
			throw e;
		}
	}

	*_line_processor_function(initialized_callback) {
		let first_line = yield;
		if(!first_line.startsWith("demo version "))
			throw new Error("No version");
		let version = first_line.split(" ")[2];
		if(!(version <= 1))
			throw new Error("Unsupported demo version " + version);
		console.log("version " + version);
		let obj = {version, init_turfs: [], init_objs: [], timeframes: []};
		let timeframe = null;

		let icon_cache = [];
		let icon_state_caches = [];
		let name_cache = [];
		this.icons_used = icon_cache;
		this.icon_state_caches = icon_state_caches;
		this.name_cache = name_cache;

		this.running_objs = new Map();
		this.running_turfs = new Map();
		this.running_client_mobs = new Map();
		let last_chat = null;

		let i = 0;
		while(true) {
			i++;
			let line = yield;
			if(line.length == 0) continue;
			let command = /^([a-z]+) /i.exec(line)[1];
			let content = line.substring(command.length + 1);
			if(command == "commit")
				this.commit = content;
			else if(command == "init") {
				let worldsize_arr = content.split(" ");
				this.maxx = +worldsize_arr[0];
				this.maxy = +worldsize_arr[1];
				this.maxz = +worldsize_arr[2];

				for(let z = 1; z <= this.maxz; z++) {
					let zline = yield;
					let p = {txt: zline, idx: 0, line: i};
					let zlevel = [];
					let last_appearance = null;
					while(p.idx < p.txt.length) {
						if('0123456789'.includes(p.txt[p.idx])) {
							let amount = this.read_number(p);
							for(let j = 1; j < amount; j++) {
								this.running_turfs.set(`${(zlevel.length % this.maxx) + 1},${Math.floor(zlevel.length / this.maxx) + 1},${z}`, {appearance: last_appearance});
								zlevel.push(last_appearance);
							}
						} else {
							last_appearance = this.read_appearance(p, last_appearance, true, (zlevel.length % this.maxx) + 1, Math.floor(zlevel.length / this.maxx) + 1, z);
							this.running_turfs.set(`${(zlevel.length % this.maxx) + 1},${Math.floor(zlevel.length / this.maxx) + 1},${z}`, {appearance: last_appearance});
							zlevel.push(last_appearance);
						}
						if(zlevel.length > this.maxx*this.maxy) throw new Error(`Exceeded z-level size at ${p.line+1}:${p.idx+1}`);
						if(p.txt[p.idx] == ',') {
							p.idx++;
						}
					}
					this.init_turfs.push(zlevel);
				}
				for(let z = 1; z <= this.maxz; z++) {
					let zline = yield;
					let p = {txt: zline, idx: 0, line: i};
					let index = 0;
					while(p.idx < p.txt.length) {
						if('0123456789'.includes(p.txt[p.idx])) {
							index += this.read_number(p);
						} else {
							this.read_init_obj(p, `${index % this.maxx + 1},${Math.floor(index / this.maxx) + 1},${z}`);
						}
						if(index > this.maxx*this.maxy) throw new Error(`Exceeded z-level size at ${p.line+1}:${p.idx+1}`);
						if(p.txt[p.idx] == ',') {
							p.idx++;
						}
					}
				}
				{
					let zline = yield;
					let p = {txt: zline, idx: 0, line: i};
					while(p.idx < p.txt.length) {
						this.read_init_obj(p, null);
						if(p.txt[p.idx] == ',') {
							p.idx++;
						} else {
							break;
						}
					}
				}
				this.initialized = true;
				initialized_callback();
			} else if(command == "time") {
				timeframe = {
					time: +content,
					forward: {
						turf_changes: [],
						add_atoms: [], change_atoms: [], del_atoms: [],
						login: [], logout: [], setmob: []
					},
					backward:
					{
						turf_changes: [],
						add_atoms: [], change_atoms: [], del_atoms: [],
						login: [], logout: [], setmob: []
					},
					chat: []
				};
				this.timeframes.push(timeframe);
				this.duration = timeframe.time;
			} else if(command == "new") {
				let p = {txt: content, idx: 0, line: i};
				while(p.idx < p.txt.length) {
					let ref = this.read_ref(p);
					let old_running_obj = this.running_objs.get(ref);
					if(old_running_obj) { // if the object already exists, delete the original
						//console.warn(`Created new object with already-used ref at ${p.line+1}:${p.idx+1}`);
						timeframe.backward.add_atoms.push(Object.assign({ref}, old_running_obj));
						timeframe.forward.del_atoms.push(ref);
					}
					if(p.txt[p.idx] != ' ') throw new Error(`Expected " " at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead.`);
					p.idx++;
					let loc = this.read_loc(p);
					if(p.txt[p.idx] != ' ') throw new Error(`Expected " " at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead.`);
					p.idx++;
					let appearance = this.read_appearance(p);

					let running_obj = {loc, appearance, last_loc: loc, last_move: timeframe.time};
					this.running_objs.set(ref, running_obj)
					timeframe.forward.add_atoms.push(Object.assign({ref}, running_obj));
					timeframe.backward.del_atoms.push(ref);
					if(p.txt[p.idx] == ',') p.idx++;
				}
			} else if(command == "del") {
				let p = {txt: content, idx: 0, line: i};
				while(p.idx < p.txt.length) {
					let ref = this.read_ref(p);
					let old_running_obj = this.running_objs.get(ref);
					if(old_running_obj) { // if the object already exists, delete the original
						timeframe.backward.add_atoms.push(Object.assign({ref}, old_running_obj));
						timeframe.forward.del_atoms.push(ref);
						this.running_objs.delete(ref);
					} else {
						//console.warn(`Deleting non-existent object at ${p.line+1}:${p.idx+1}`);
					}
					if(p.txt[p.idx] == ',') p.idx++;
				}
			} else if(command == "update") {
				let p = {txt: content, idx: 0, line: i};
				while(p.idx < p.txt.length) {
					let ref = this.read_ref(p);
					let running_obj = this.running_objs.get(ref);
					if(p.txt[p.idx] != ' ') throw new Error(`Expected " " at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead.`);
					p.idx++;
					let loc = this.read_loc(p, running_obj ? running_obj.loc : undefined);
					if(p.txt[p.idx] != ' ') throw new Error(`Expected " " at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead.`);
					p.idx++;
					let appearance = this.read_appearance(p, running_obj ? running_obj.appearance : undefined);
					if(running_obj) {
						timeframe.backward.change_atoms.push(Object.assign({ref}, running_obj));
						running_obj.appearance = appearance;
						if(loc != running_obj.loc) {
							running_obj.last_loc = running_obj.loc;
							running_obj.loc = loc;
							running_obj.last_move = timeframe.time;
						}
						timeframe.forward.change_atoms.push(Object.assign({ref}, running_obj));
						if(p.txt[p.idx] == ',') p.idx++;
					} else {
						//console.warn(`Updating non-existent atom ${ref} - creating new instead.`);
						running_obj = {loc, appearance, last_loc: loc, last_move: timeframe.time};
						this.running_objs.set(ref, running_obj)
						timeframe.forward.add_atoms.push(Object.assign({ref}, running_obj));
						timeframe.backward.del_atoms.push(ref);
						if(p.txt[p.idx] == ',') p.idx++;
					}
				}
			} else if(command == "turf") {
				let p = {txt: content, idx: 0, line: i};
				while(p.idx < p.txt.length) {
					if(p.txt[p.idx] != '(') throw new Error(`Expected ( at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead.`);
					p.idx++;
					let loc = this.read_loc(p);
					if(p.txt[p.idx] != ')') throw new Error(`Expected ) at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead.`);
					p.idx++;
					if(p.txt[p.idx] != '=') throw new Error(`Expected = at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead.`);
					p.idx++;
					let running_turf = this.running_turfs.get(loc);
					if(!running_turf) {
						running_turf = {appearance: null};
						this.running_turfs.set(running_turf);
					}
					let appearance = this.read_appearance(p, running_turf ? running_turf.appearance : undefined);

					timeframe.backward.turf_changes.push(Object.assign({loc}, running_turf));
					running_turf.appearance = appearance;
					timeframe.forward.turf_changes.push(Object.assign({loc}, running_turf));
					if(p.txt[p.idx] == ',') p.idx++;
				}
			} else if(command == "login") {
				timeframe.forward.login.push(content);
				timeframe.backward.logout.push(content);
			} else if(command == "logout") {
				timeframe.forward.logout.push(content);
				timeframe.backward.login.push(content);
			} else if(command == "setmob") {
				let [ckey, ref] = content.split(" ");
				let old_mob = this.running_client_mobs.get(ckey);
				timeframe.backward.setmob.splice(0, 0, {ckey, ref: old_mob});
				this.running_client_mobs.set(ckey, ref);
				timeframe.forward.setmob.push({ckey, ref});
			} else if(command == "chat") {
				let result = /^([^ ]+) (.+)$/.exec(content);
				let clients = result[1].split(",");
				let message = result[2];
				if(message == "=") {
					message = last_chat;
				} else {
					message = JSON.parse(message);
					last_chat = message;
				}
				timeframe.chat.push({
					clients,
					message
				});
			}
		}
	}
	read_number(p) {
		let start_index = p.idx;
		while("01234567890.-eE".includes(p.txt[p.idx])) {
			p.idx++;
		}
		return +p.txt.substring(start_index, p.idx);
	}
	read_ref(p) {
		if(p.txt[p.idx] != '[') throw new Error(`Expected [ at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead.`);
		let start_index = p.idx;
		while('[0x123456789abcdefABCDEF'.includes(p.txt[p.idx])) {
			p.idx++;
		}
		if(p.txt[p.idx] != ']') throw new Error(`Expected ] at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead.`);
		p.idx++
		return p.txt.substring(start_index, p.idx);
	}
	read_loc(p, orig) {
		if(p.txt[p.idx] == '=') {
			p.idx++;
			return orig;
		} else if(p.txt[p.idx] == '[') {
			return this.read_ref(p);
		} else if(p.txt[p.idx] == 'n') {
			p.idx += 4;
			return null;
		} else {
			let x = this.read_number(p);
			if(p.txt[p.idx] != ',') throw new Error(`Expected , at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
			p.idx++;
			let y = this.read_number(p);
			if(p.txt[p.idx] != ',') throw new Error(`Expected , at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
			p.idx++;
			let z = this.read_number(p);
			return `${x},${y},${z}`;
		}
	}
	read_string(p) {
		let start_index = p.idx;
		if(p.txt[p.idx] != '"') return "";
		p.idx++;
		while(p.txt[p.idx] != '"') {
			if(p.txt[p.idx] == '\\') {
				p.idx++;
			}
			p.idx++;
		}
		p.idx++;
		return JSON.parse(p.txt.substring(start_index, p.idx));
	}

	read_appearance(p, comparison, inherit_overlays = true, x=0, y=0, z=0) {
		if(p.txt[p.idx] == 'n') {
			p.idx++;
			return null;
		}
		if(p.txt[p.idx] == '=') {
			p.idx++;
			return comparison
		}
		if(p.txt[p.idx] == 's' || p.txt[p.idx] == 't') {
			let appearance = new Appearance({
				icon: 'icons/turf/space.dmi',
				icon_state: "?",
				name: "space",
				layer: 1.8,
				plane: -95
			});
			if(p.txt[p.idx] == 't') {
				p.idx++;
				appearance.dir = +p.txt[p.idx];
				switch(p.txt[p.idx]) {
					case "1":
						appearance.transform = [-1,0,0,0,-1,0];
						break;
					case "4":
						appearance.transform = [0,-1,0,1,0,0];
						break;
					case "8":
						appearance.transform = [0,1,0,-1,0,0];
						break;
				}
				appearance.icon_state = `speedspace_ns_?`;
			}
			p.idx++;
			return appearance;
		}
		let appearance = null;
		if(p.txt[p.idx] == '~') {
			p.idx++;
			if(!comparison) {
				console.log(`Comparison to null at ${p.line+1}:${p.idx+1}`)
			}
			appearance = new Appearance(comparison);
			if(!inherit_overlays) {
				appearance.overlays = [];
				appearance.underlays = [];
			}

		} else {
			appearance = new Appearance();
		}
		if(p.txt[p.idx] != '{') {
			throw new Error(`Expected { at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead.`);
		}
		p.idx++;
		let icon_state_cache;
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') {
			if(p.txt[p.idx] == '"') {
				appearance.icon = this.read_string(p);
				this.icons_used.push(appearance.icon);
				this.load_icon_resource(appearance.icon);
				icon_state_cache = [];
				this.icon_state_caches.push(icon_state_cache);
			} else if(p.txt[p.idx] == 'n') {
				p.idx += 4;
				appearance.icon = null;
				this.icons_used.push(appearance.icon);
				icon_state_cache = [];
				icon_state_caches.push([]);
			} else {
				let num = this.read_number(p);
				appearance.icon = this.icons_used[num-1];
				icon_state_cache = this.icon_state_caches[num-1];
			}
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			if(!icon_state_cache) {
				console.log(this.icons_used);
				console.log(icon_state_cache);
				throw new Error(`Unknown icon at ${p.line+1}:${p.idx+1}`);
			}
			if(p.txt[p.idx] == '"') {
				appearance.icon_state = this.read_string(p);
				icon_state_cache.push(appearance.icon_state);
			} else if(p.txt[p.idx] == 'n') {
				p.idx += 4;
				appearance.icon_state = null;
				icon_state_cache.push(appearance.icon_state);
			} else {
				let num = this.read_number(p);

				appearance.icon_state = icon_state_cache ? icon_state_cache[num-1] : "";
			}
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			if(p.txt[p.idx] == '"') {
				appearance.name = this.read_string(p);
				this.name_cache.push(appearance.name);
			} else if(p.txt[p.idx] == 'n') {
				p.idx += 4;
				appearance.name = null;
				this.name_cache.push(appearance.name);
			} else {
				let num = this.read_number(p);
				appearance.name = this.name_cache[num-1];
			}
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			appearance.appearance_flags = this.read_number(p);
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			appearance.layer = this.read_number(p);
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			appearance.plane = this.read_number(p);
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			appearance.dir = this.read_number(p);
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			if(p.txt[p.idx] == 'w') {
				appearance.color = '#ffffff';
				p.idx++;
			} else if(p.txt[p.idx] == '#') {
				appearance.color = p.txt.substring(p.idx, p.idx + 7);
				p.idx += 7;
			} else {
				appearance.color = [];
				while('-.0123456789'.includes(p.txt[p.idx])) {
					appearance.color.push(this.read_number(p) / 255);
					if(p.txt[p.idx] == ',')  p.idx++;
				}
			}
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			appearance.alpha = this.read_number(p);
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') { throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);}
		p.idx++;
		if(p.txt[p.idx] != ';') {
			appearance.pixel_x = this.read_number(p);
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			appearance.pixel_y = this.read_number(p);
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			appearance.blend_mode = this.read_number(p);
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			if(p.txt[p.idx] == 'i') {
				appearance.transform = [1,0,0,0,1,0];
				p.idx++;
			} else {
				appearance.transform = [];
				while('-.0123456789'.includes(p.txt[p.idx])) {
					appearance.transform.push(this.read_number(p));
					if(p.txt[p.idx] == ',')  p.idx++;
				}
			}
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			appearance.invisibility = this.read_number(p);
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			appearance.pixel_w = this.read_number(p);
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] != ';') {
			appearance.pixel_z = this.read_number(p);
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] == '[') {
			appearance.overlays = [];
			while('[,'.includes(p.txt[p.idx])) {
				p.idx++;
				if(p.txt[p.idx] == ']') break;
				appearance.overlays.push(this.read_appearance(p, appearance, false, x, y, z));
			}
			if(p.txt[p.idx] == '[' && !appearance.overlays.length) p.idx++;
			if(p.txt[p.idx] != ']') throw new Error(`Expected ] or , at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
			p.idx++;
		}
		if(p.txt[p.idx] == '}') { p.idx++; return appearance; }
		if(p.txt[p.idx] != ';') throw new Error(`Expected ; at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		if(p.txt[p.idx] == '[') {
			appearance.underlays = [];
			while('[,'.includes(p.txt[p.idx])) {
				p.idx++;
				if(p.txt[p.idx] == ']') break;
				appearance.underlays.push(this.read_appearance(p, appearance, false, x, y, z));
			}
			if(p.txt[p.idx] == '[' && !appearance.underlays.length) p.idx++;
			if(p.txt[p.idx] != ']') throw new Error(`Expected ] or , at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
			p.idx++;
		}
		if(p.txt[p.idx] != '}') throw new Error(`Expected } at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		return appearance;
	}
	read_init_obj(p, loc) {
		let desc = {loc};
		desc.ref = this.read_ref(p);
		this.init_objs.push(desc);
		if(p.txt[p.idx] != '=') throw new Error(`Expected = at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
		p.idx++;
		desc.appearance = this.read_appearance(p);
		if(p.txt[p.idx] == '(') {
			p.idx++;
			while(p.txt[p.idx] != ')') {
				this.read_init_obj(p, desc.ref);
				if(!'),'.includes(p.txt[p.idx])) throw new Error(`Expected ) or , at ${p.line+1}:${p.idx+1}, found ${p.txt[p.idx]} instead`);
				if(p.txt[p.idx] == ',')
					p.idx++;
			}
			p.idx++;
		}
		this.running_objs.set(desc.ref, {appearance: desc.appearance, loc, last_loc: loc, last_move: 0});
	}

	async load_icon_resource(icon) {
		let url = "https://cdn.jsdelivr.net/gh/" + window.repository + "@" + this.commit + "/" + icon;
		console.log(url);
		try {
			this.loaded_icons.set(icon, await read_icon(url));
		} catch(e) {
			console.error(e);
		}
	}
}
