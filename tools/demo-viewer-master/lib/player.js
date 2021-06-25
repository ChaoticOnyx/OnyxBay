'use strict';
const Matrix = require('./matrix.js');

class RenderInstance {
	constructor(appearance, x, y, atom) {
		this.appearance = appearance;
		this.x = x;
		this.y = y;
		this.atom = atom;
	}
}

class Turf {
	constructor(loc, appearance) {
		this.appearance = appearance;
		let split = loc.split(",");
		this.x = +split[0];
		this.y = +split[1];
		this.z = +split[2];
		this.ref = loc;
		this.loc = loc;
	}
}

class Obj {
	constructor(loc, appearance, time, ref) {
		this.appearance = appearance;
		this.loc = loc;
		this.last_loc = loc;
		this.last_move = time;
		this.ref = ref;
	}
}

class DemoPlayer {
	constructor(demo, icons) {
		console.log(demo);
		this.demo = demo;
		this.icons = icons;
		document.body.innerHTML = ``;

		this.main_panel = document.createElement("div");
		document.body.appendChild(this.main_panel);
		this.main_panel.classList.add("main_panel");

		this.canvas = document.createElement("canvas");
		this.main_panel.appendChild(this.canvas);
		this.canvas.classList.add("fill_canvas");
		this.canvas.tabIndex = 0;
		this.canvas.addEventListener("mousedown", this.canvas_mousedown.bind(this));
		this.canvas.addEventListener("wheel", this.canvas_wheel.bind(this));
		this.canvas.addEventListener("dblclick", this.canvas_dblclick.bind(this));
		document.addEventListener("keydown", this.keydown.bind(this));
		document.addEventListener("click", this.click.bind(this));

		this.right_panel = document.createElement("div");
		document.body.appendChild(this.right_panel);
		this.right_panel.classList.add("right_panel");

		let controls_section = document.createElement("div");
		controls_section.classList.add("controls");
		this.right_panel.appendChild(controls_section);

		this.scrub_slider = document.createElement("input");
		this.scrub_slider.type = "range";
		this.scrub_slider.min = 0;
		this.scrub_slider.step = 0;
		this.scrub_slider.max = this.demo.duration;
		this.scrub_slider.classList.add("scrub_slider");
		controls_section.appendChild(this.scrub_slider);
		this.scrub_slider.addEventListener("input", this.scrub.bind(this));

		this.time_display = document.createElement("div");
		controls_section.appendChild(this.time_display);

		this.rewind_button = document.createElement("input");
		this.rewind_button.type = "button";
		this.rewind_button.value = "Rewind";
		this.rewind_button.addEventListener("click", () => {this.playback_speed = -3;});
		controls_section.appendChild(this.rewind_button);

		this.play_button = document.createElement("input");
		this.play_button.type = "button";
		this.play_button.value = "Pause/Play";
		this.play_button.addEventListener("click", () => {this.playback_speed = (this.playback_speed == 0) ? 1 : 0;});
		controls_section.appendChild(this.play_button);

		this.fastfoward_button = document.createElement("input");
		this.fastfoward_button.type = "button";
		this.fastfoward_button.value = "Fast-foward";
		this.fastfoward_button.addEventListener("click", () => {this.playback_speed = 5;});
		controls_section.appendChild(this.fastfoward_button);

		this.inspect_table = document.createElement("div");
		this.inspect_table.classList.add("inspect_table");
		this.right_panel.appendChild(this.inspect_table);
		this.inspect_elem = document.createElement("div");
		let client_list_label = document.createElement("div");
		client_list_label.textContent = "Clients:"
		this.client_list_elem = document.createElement("div");
		this.inspect_table.appendChild(this.inspect_elem);
		this.inspect_table.appendChild(client_list_label);
		this.inspect_table.appendChild(this.client_list_elem);

		this.chat_window = document.createElement("div");
		this.chat_window.classList.add("chat_window");
		this.chat_window.addEventListener("scroll", () => {
			this.is_chat_scrolled_to_bottom = Math.ceil(this.chat_window.clientHeight + this.chat_window.scrollTop) >= Math.floor(this.chat_window.scrollHeight);
		});
		this.right_panel.appendChild(this.chat_window);

		this.last_timestamp = null;

		this.turf_grid = [];
		this.object_ref_list = [];

		this.clients = new Set();
		this.client_mobs = new Map();

		for(let init_obj of demo.init_objs) {
			this.set_object(init_obj.ref, new Obj(init_obj.loc, init_obj.appearance, 0, init_obj.ref));
		}
		for(let z = 1; z <= demo.maxz; z++) {
			for(let i = 0; i < this.demo.init_turfs[z-1].length; i++) {
				let loc_string = `${(i % this.demo.maxx) + 1},${(Math.floor(i / this.demo.maxy) + 1)},${z}`;
				this.set_object(loc_string, new Turf(loc_string, this.demo.init_turfs[z-1][i]));
			}
		}

		this.playhead = -1;
		this.timeframe_index = -1;

		this.playback_speed = 1;

		this.follow_desc = null;
		this.inspect_desc = null;
		this.see_invisible = 60; // this is the default
		this.mapwindow_x = demo.maxx / 2;
		this.mapwindow_y = demo.maxy / 2;
		this.mapwindow_z = 2;
		this.mapwindow_zoom = 1;
		this.mapwindow_log_zoom = 0;

		this.is_chat_scrolled_to_bottom = true;

		this.advance_playhead(0);

		this.update_from_hash();
		window.addEventListener("hashchange", this.update_from_hash.bind(this));
		this.init_rendering();

		// this should happen last - if there are any errors we should abort
		window.requestAnimationFrame(this.animation_frame_callback.bind(this));
	}

	add_chat(chat, index) {
		if(!chat.clients.includes(this.follow_desc) && !chat.clients.includes("world"))
			return; // first make sure it's relevant.
		let div = document.createElement("div");
		div.dataset.index = index;
		if(typeof chat.message == "object") {
			if(chat.message.text) div.textContent = chat.message.text;
			else if(chat.message.html) div.innerHTML = chat.message.html;
		} else {
			div.innerHTML = chat.message;
		}
		this.chat_window.appendChild(div);
	}

	reset_chat() {
		this.chat_window.innerHTML = '';
		for(let i = 0; i <= this.timeframe_index; i++) {
			let timeframe = this.demo.timeframes[i];
			for(let chat of timeframe.chat) {
				this.add_chat(chat, i);
			}
		}
		this.chat_window.scrollTop = this.chat_window.scrollHeight - this.chat_window.clientHeight;
	}

	advance_playhead(target) {
		if(target < 0) {
			target = 0;
			if(this.playback_speed < 0) this.playback_speed = 0;
		} else if(target > this.demo.duration) {
			target = this.demo.duration;
			if(this.playback_speed > 0 && !this.demo.streaming) this.playback_speed = 0;
		}
		if(target > this.playhead) {
			while(this.demo.timeframes[this.timeframe_index+1] && this.demo.timeframes[this.timeframe_index+1].time <= target) {
				this.timeframe_index++;
				let timeframe = this.demo.timeframes[this.timeframe_index];
				this.apply_timeframe(timeframe, timeframe.forward);
				for(let chat of timeframe.chat) {
					this.add_chat(chat,this.timeframe_index);
				}
			}
		} else if(target < this.playhead) {
			while(this.demo.timeframes[this.timeframe_index] && this.demo.timeframes[this.timeframe_index].time > target) {
				let timeframe = this.demo.timeframes[this.timeframe_index];
				this.apply_timeframe(timeframe, timeframe.backward);
				this.timeframe_index--;
			}
			for(let i = this.chat_window.children.length - 1; i >= 0; i--) {
				let child = this.chat_window.children[i];
				if(child.dataset.index > this.timeframe_index) {
					this.chat_window.removeChild(child);
				}
			}
		}
		this.playhead = target;
		this.scrub_slider.value = this.playhead;
		this.time_display.textContent = format_duration(Math.round(this.playhead / 10)) + " / " + format_duration(Math.round(this.demo.duration / 10));
		this.scrub_slider.max = this.demo.duration;
		for(let [ckey, ref] of this.client_mobs) {
			let span = this.client_list_elem.querySelector(`[data-ckey=${JSON.stringify(ckey)}] .mob_span`);
			if(span) {
				let mob = this.get_object(ref);
				if(mob && mob.appearance) {
					span.textContent = mob.appearance.name;
				} else {
					span.textContent = "?";
				}
			}
		}
		if(this.is_chat_scrolled_to_bottom) {
			this.chat_window.scrollTop = this.chat_window.scrollHeight - this.chat_window.clientHeight;
		}
	}
	apply_timeframe(timeframe, subtimeframe) {
		for(let del of subtimeframe.del_atoms) {
			this.set_object(del, undefined);
		}
		for(let update of subtimeframe.change_atoms) {
			let obj = this.get_object(update.ref);
			if(obj) {
				obj.appearance = update.appearance;
				obj.loc = update.loc;
				obj.last_loc = update.last_loc;
				obj.last_move = update.last_move;
				if(obj.loc && obj.loc[0] != "[" && !this.get_object(obj.loc)) {
					this.set_object(obj.loc, new Turf(obj.loc));
				}
			}
		}
		for(let add of subtimeframe.add_atoms) {
			let obj = new Obj(add.loc, add.appearance, 0, add.ref);
			obj.last_loc = add.last_loc;
			obj.last_move = add.last_move;
			this.set_object(add.ref, obj);
			if(add.loc && add.loc[0] != "[" && !this.get_object(add.loc)) {
				this.set_object(add.loc, new Turf(add.loc));
			}
		}
		for(let turf_change of subtimeframe.turf_changes) {
			let turf = this.get_object(turf_change.loc);
			if(turf instanceof Turf) {
				turf.appearance = turf_change.appearance;
			} else if(turf == null) {
				turf = new Turf(turf_change.loc, turf_change.appearance);
				this.set_object(turf_change.loc, turf);
			}
		}
		for(let login of subtimeframe.login) {
			this.clients.add(login);
			let elem = this.client_list_elem.querySelector(`[data-ckey=${JSON.stringify(login)}]`);
			if(!elem) {
				elem = document.createElement("div");
				elem.dataset.ckey = login;
				let follow_button = document.createElement("input");
				follow_button.dataset.follow = login;
				follow_button.type = "button";
				follow_button.value = "FLW";
				//let inspect_button = document.createElement("input");
				//inspect_button.dataset.inspect = login;
				//inspect_button.type = "button";
				//inspect_button.value = "INSPECT";
				elem.appendChild(follow_button);
				//elem.appendChild(inspect_button);
				let ckey_span = document.createElement("span");
				ckey_span.classList.add("ckey_span");
				ckey_span.textContent = login;
				elem.appendChild(ckey_span);
				elem.appendChild(document.createTextNode("("));
				let mob_span = document.createElement("span");
				mob_span.classList.add("mob_span");
				let mobref = this.client_mobs.get(login);
				mob_span.textContent = "?";
				if(mobref){
					let mob = this.get_object(mobref);
					if(mob && mob.appearance) {
						mob_span.textContent = mob.appearance.name;
					}
				}
				elem.appendChild(mob_span);
				elem.appendChild(document.createTextNode(")"));
				this.client_list_elem.appendChild(elem);
			}
		}
		for(let logout of subtimeframe.logout) {
			this.clients.delete(logout);
			let elem = this.client_list_elem.querySelector(`[data-ckey=${JSON.stringify(logout)}]`);
			if(elem) {
				this.client_list_elem.removeChild(elem);
			}
		}
		for(let setmob of subtimeframe.setmob) {
			this.client_mobs.set(setmob.ckey, setmob.ref);
		}
	}

	click(e) {
		let target = e.target;
		if(target.dataset.follow) {
			this.follow_desc = target.dataset.follow;
			this.reset_chat();
		}
		if(target.dataset.inspect) {
			this.inspect_desc = target.dataset.inspect;
			if(this.clients.has(this.inspect_desc)) {
				this.inspect_desc = this.client_mobs.get(this.inspect_desc);
			}
			this.inspect_elem.scrollTop = 0;
		}
	}

	scrub() {
		this.advance_playhead(+this.scrub_slider.value);
	}

	update_from_hash(e) {
		let hash = window.location.hash || '';
		if(hash[0] == '#') hash = hash.substring(1);
		if(e && e.newURL.includes("#")) hash = e.newURL.substring(e.newURL.indexOf("#") + 1);
		if(hash.length) {
			let split = hash.split(';');
			if(split[0] == +split[0]) this.advance_playhead(+split[0]);
			if(split[1] == +split[1]) this.mapwindow_x = +split[1];
			if(split[2] == +split[2]) this.mapwindow_y = +split[2];
			if(split[3] == +split[3]) this.mapwindow_z = Math.round(+split[3]);
			let new_follow_desc;
			if(split[4] == "null") new_follow_desc = null;
			else if(split[4]) new_follow_desc = split[4];
			if(new_follow_desc != this.follow_desc) {
				this.follow_desc = new_follow_desc
				this.reset_chat();
			}
		}
	}

	frame(timestamp) {
		let dt = this.last_timestamp ? timestamp - this.last_timestamp : 0;
		this.last_timestamp = timestamp;
		if(this.playback_speed != 0) {
			this.advance_playhead(this.playhead + (dt * this.playback_speed / 100));
		}

		let rect = this.canvas.getBoundingClientRect();
		if(this.canvas.width != rect.width) this.canvas.width = rect.width;
		if(this.canvas.height != rect.height) this.canvas.height = rect.height;

		let ctx = this.canvas.getContext('2d');

		let follow_obj = null;
		let follow_turf = null;
		if(this.follow_desc) {
			follow_obj = this.get_object(this.follow_desc);
			if(!follow_obj && this.clients.has(this.follow_desc)) {
				follow_obj = this.get_object(this.client_mobs.get(this.follow_desc));
			} else if(!follow_obj) {
				this.follow_desc = null;
				this.reset_chat();
			}
			if(follow_obj) {
				while(follow_obj && follow_obj.loc && follow_obj.loc[0] == "[") {
					follow_obj = this.get_object(follow_obj.loc);
				}
				if(follow_obj instanceof Obj && follow_obj.loc == null) {
					ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
					return;
				}
				if(follow_obj instanceof Turf) {
					follow_turf = follow_obj;
				} else {
					follow_turf = this.get_object(follow_obj.loc);
				}
			}
		}
		if(follow_turf) {
			this.mapwindow_z = follow_turf.z || 2;
			this.mapwindow_x = (follow_turf.x || 128) + 0.5;
			this.mapwindow_y = (follow_turf.y || 128) + 0.5;
		}

		let render_instances = [];
		/*for(let i = 0; i < this.demo.init_turfs[this.mapwindow_z-1].length; i++) {
			//ctx.save();
			//ctx.translate((i % this.demo.maxx + 1) * 32, -(Math.floor(i / this.demo.maxy) + 1) * 32);
			render_instances.push(new RenderInstance(this.demo.init_turfs[this.mapwindow_z-1][i], (i % this.demo.maxx + 1), (Math.floor(i / this.demo.maxy) + 1)))
			//ctx.translate(-(i % this.demo.maxx + 1) * 32, (Math.floor(i / this.demo.maxy) + 1) * 32);
			//ctx.restore();
		}*/
		if(this.turf_grid[this.mapwindow_z-1]) {
			for(let y_array of this.turf_grid[this.mapwindow_z-1]) {
				if(!y_array) continue;
				for(let turf of y_array) {
					if(!turf) continue;
					render_instances.push(new RenderInstance(turf.appearance, turf.x, turf.y, turf))
				}
			}
		}
		for(let type_array of this.object_ref_list) {
			if(!type_array) continue;
			for(let obj of type_array) {
				if(!obj) continue;
				let turf;
				let x_offset = 0; // for gliding
				let y_offset = 0;
				let loc = this.get_object(obj.loc);
				if(loc instanceof Turf) {
					turf = loc;
				} else {
					continue;
				}
				let glide_size = 8; // almost nothing uses anything else so just hardcoding it.
				let glide_time = 32 / (glide_size) * 0.5; // also assuming a tick_lag 0f 0.5 (why the changing ticklag affects this is beyond me... or should I say BYOND me.)
				if((this.playhead - obj.last_move) < glide_time) {
					let last_loc = this.get_object(obj.last_loc);
					if(last_loc instanceof Turf && last_loc.z == loc.z) {
						let dx = loc.x - last_loc.x;
						let dy = loc.y - last_loc.y;
						let percent = (this.playhead - obj.last_move) / glide_time;
						if(Math.abs(dx) <= 1 && Math.abs(dy) <= 1) {
							x_offset -= Math.round(dx * 32 * (1-percent)) / 32;
							y_offset -= Math.round(dy * 32 * (1-percent)) / 32;
						}
					}
				}
				if(turf && turf.z == this.mapwindow_z) {
					if(follow_obj == obj) {
						this.mapwindow_x = turf.x + x_offset + 0.5;
						this.mapwindow_y = turf.y + y_offset + 0.5;
					}
					render_instances.push(new RenderInstance(obj.appearance, turf.x + x_offset, turf.y + y_offset, obj));
				}
			}
			this.update_inspector();
		}
		render_instances = render_instances.filter((instance) => {
			if(
				!instance || !instance.appearance ||
				instance.x > (this.mapwindow_x + (this.canvas.width / 32 / 2 / this.mapwindow_zoom)) + 2 ||
				instance.y > (this.mapwindow_y + (this.canvas.height / 32 / 2 / this.mapwindow_zoom)) + 2 ||
				instance.x < (this.mapwindow_x - (this.canvas.width / 32 / 2 / this.mapwindow_zoom)) - 2 ||
				instance.y < (this.mapwindow_y - (this.canvas.height / 32 / 2 / this.mapwindow_zoom)) - 2
			) {
				return false;
			}
			return true;
		});
		render_instances.sort((a,b) => {
			if(a.appearance.plane != b.appearance.plane) {
				return a.appearance.plane - b.appearance.plane;
			}
			if(a.appearance.layer != b.appearance.layer) {
				return a.appearance.layer - b.appearance.layer;
			}
			if(a.y != b.y) {
				return a.y - b.y;
			}
			return 0;
		});

		const gl = this.gl;
		let max_width = Math.max(gl.canvas.width, this.canvas.width);
		let max_height = Math.max(gl.canvas.height, this.canvas.height);
		if(max_width != gl.canvas.width || max_height != gl.canvas.height) {
			gl.canvas.width = max_width;
			gl.canvas.height = max_height;
		}
		gl.viewport(0, 0, this.canvas.width, this.canvas.height);
		gl.clearColor(0,0,0,0);
		gl.clear(gl.COLOR_BUFFER_BIT);
		this.gl_viewport = [this.canvas.width,this.canvas.height];
		// the +0.5 is to prevent aliasing issues.
		let transform = new Matrix(this.mapwindow_zoom, 0, 0, this.mapwindow_zoom, -Math.round(this.mapwindow_x * this.mapwindow_zoom * 32) + ((this.canvas.width % 2 == 1) ? 0.5 : 0), -Math.round(this.mapwindow_y * this.mapwindow_zoom * 32) + ((this.canvas.height % 2 == 1) ? 0.5 : 0));

		for(let instance of render_instances) {
			this.draw_appearance(transform.translate(instance.x * 32, instance.y * 32), instance.appearance, null, instance.atom);
		}

		if(this.gl_current_batch)
			this.gl_current_batch.draw();

		ctx.globalCompositeOperation = "copy";
		ctx.drawImage(gl.canvas, 0, this.canvas.height - gl.canvas.height);

		// build the hash
		let hash = `#${Math.round(this.playhead)};${this.mapwindow_x.toFixed(2)};${this.mapwindow_y.toFixed(2)};${Math.round(this.mapwindow_z)};${this.follow_desc}`;
		if(hash != window.location.hash)
			history.replaceState('', '', hash);

	}

	update_inspector() {
		this.inspect_desc = this.follow_desc;
		if(this.clients.has(this.inspect_desc)) {
			this.inspect_desc = this.client_mobs.get(this.inspect_desc);
		}
		let inspected_object = this.get_object(this.inspect_desc);
		if(!inspected_object) {
			this.inspect_desc = null;
		}
		if(this.inspect_elem.dataset.inspecting != this.inspect_desc) {
			this.inspect_elem.dataset.inspecting = this.inspect_desc;
			this.inspect_elem.innerHTML = "";
			if(this.inspect_desc == null) {
				return;
			} else {
				let inspecting_label = document.createElement("div");
				inspecting_label.textContent = "Inspecting:"
				let self_elem = document.createElement("div");
				self_elem.classList.add("inspect_self");
				let parent_label = document.createElement("div");
				parent_label.textContent = "Loc:";
				let parent_elem = document.createElement("div");
				parent_elem.classList.add("inspect_parent");
				let contents_label = document.createElement("div");
				contents_label.textContent = "Contents:";
				let contents_elem = document.createElement("div");
				contents_elem.classList.add("inspect_contents");
				if(!(inspected_object instanceof Turf)) {
					this.inspect_elem.appendChild(parent_label);
					this.inspect_elem.appendChild(parent_elem);
				}
				this.inspect_elem.appendChild(inspecting_label);
				this.inspect_elem.appendChild(self_elem);
				this.inspect_elem.appendChild(contents_label);
				this.inspect_elem.appendChild(contents_elem);
				self_elem.style.paddingLeft = "15px";
				inspecting_label.style.paddingLeft = "15px";
				contents_elem.style.paddingLeft = "30px";
				contents_label.style.paddingLeft = "30px";
			}
		}
		if(this.inspect_desc == null) return;
		let self_elem = this.inspect_elem.querySelector(".inspect_self");
		let parent_elem = this.inspect_elem.querySelector(".inspect_parent");
		let contents_elem = this.inspect_elem.querySelector(".inspect_contents");

		let upd_list = [];
		upd_list.push([self_elem, inspected_object]);
		if(!(inspected_object instanceof Turf)) {
			upd_list.push([parent_elem, this.get_object(inspected_object.loc)]);
		}

		let contents = new Set();
		for(let type_array of this.object_ref_list) {
			if(!type_array) continue;
			for(let obj of type_array) {
				if(!obj || obj.loc != this.inspect_desc) continue;
				contents.add(obj.ref);
				let obj_elem = contents_elem.querySelector("div[data-ref=" + JSON.stringify(obj.ref) + "]");
				if(!obj_elem) {
					obj_elem = document.createElement("div");
					contents_elem.appendChild(obj_elem);
					obj_elem.dataset.ref = obj.ref;
				}
				upd_list.push([obj_elem, obj]);
			}
		}
		for(let i = contents_elem.children.length - 1; i >= 0; i--) {
			if(!contents.has(contents_elem.children[i].dataset.ref)) {
				contents_elem.removeChild(contents_elem.children[i]);
			}
		}
		for(let [elem, obj] of upd_list) {
			if(elem.classList.contains("inspect_exists") && obj == null) {
				elem.classList.remove("inspect_exists");
				elem.innerHTML = `null`;
			} else if(obj) {
				let label;
				let follow_ckey_button
				if(!elem.classList.contains("inspect_exists")) {
					elem.classList.add("inspect_exists");
					elem.innerHTML = ``;
					let canvas = document.createElement("canvas");
					canvas.width = 32;
					canvas.height = 32;
					elem.appendChild(canvas);
					let follow_button = document.createElement("input");
					follow_button.dataset.follow = obj.ref;
					follow_button.type = "button";
					follow_button.value = "FLW";
					follow_ckey_button = document.createElement("input");
					follow_ckey_button.dataset.follow = null;
					follow_ckey_button.type = "button";
					follow_ckey_button.style.display = "none";
					follow_ckey_button.value = "FLW CKEY";
					follow_ckey_button.classList.add("follow_ckey");
					//let inspect_button = document.createElement("input");
					//inspect_button.dataset.inspect = obj.ref;
					//inspect_button.type = "button";
					//inspect_button.value = "INSPECT";
					elem.appendChild(follow_button);
					elem.appendChild(follow_ckey_button);
					//elem.appendChild(inspect_button);
					label = document.createElement("span");
					label.classList.add("label");
					elem.appendChild(label);
				} else {
					label = elem.querySelector(".label");
					follow_ckey_button = elem.querySelector(".follow_ckey");
				}
				label.textContent = obj.appearance ? obj.appearance.name : null;
				let do_follow_ckey = false;
				for(let ckey of this.clients) {
					if(this.client_mobs.get(ckey) == obj.ref) {
						follow_ckey_button.dataset.follow = ckey;
						do_follow_ckey = true;
						break;
					}
				}
				follow_ckey_button.style.display = do_follow_ckey ? "inline-block" : "none";
			}
		}
		for(let [elem, obj] of upd_list) {
			if(obj == null) continue;
			let canvas = elem.querySelector("canvas");
			if(canvas == null) continue;
			const gl = this.gl;
			let max_width = Math.max(gl.canvas.width, canvas.width);
			let max_height = Math.max(gl.canvas.height, canvas.height);
			if(max_width != gl.canvas.width || max_height != gl.canvas.height) {
				gl.canvas.width = max_width;
				gl.canvas.height = max_height;
			}
			gl.viewport(0, 0, canvas.width, canvas.height);
			gl.clearColor(0,0,0,0);
			gl.clear(gl.COLOR_BUFFER_BIT);
			this.gl_viewport = [canvas.width,canvas.height];
			// the +0.5 is to prevent aliasing issues.
			let transform = new Matrix(1, 0, 0, 1, -16, -16);

			this.draw_appearance(transform, obj.appearance, null, obj);

			if(this.gl_current_batch)
				this.gl_current_batch.draw();

			let ctx = canvas.getContext('2d');
			ctx.globalCompositeOperation = "copy";
			ctx.drawImage(gl.canvas, 0, canvas.height - gl.canvas.height);
		}
	}

	canvas_mousedown(e) {
		if(e.button != 2) {
			let lastE = e;
			let mouseup = () => {
				document.removeEventListener("mouseup", mouseup);
				document.removeEventListener("mousemove", mousemove);
			}
			let mousemove = (e) => {
				this.mapwindow_x -= (e.screenX - lastE.screenX) / 32 / this.mapwindow_zoom * devicePixelRatio;
				this.mapwindow_y += (e.screenY - lastE.screenY) / 32 / this.mapwindow_zoom * devicePixelRatio;
				if(this.mapwindow_x < 1) this.mapwindow_x = 1;
				if(this.mapwindow_y < 1) this.mapwindow_y = 1;
				if(this.mapwindow_x > this.demo.maxx) this.mapwindow_x = this.demo.maxx;
				if(this.mapwindow_y > this.demo.maxy) this.mapwindow_y = this.demo.maxy;
				lastE = e;
				if(this.follow_desc) {
					this.follow_desc = null;
					this.reset_chat();
				}
			}
			document.addEventListener("mouseup", mouseup);
			document.addEventListener("mousemove", mousemove);
			e.preventDefault();
		}
	}
	canvas_dblclick(e) {
		let x = Math.floor((e.offsetX*devicePixelRatio - (this.canvas.width/2)) / this.mapwindow_zoom/32 + this.mapwindow_x);
		let y = Math.floor(-(e.offsetY*devicePixelRatio - (this.canvas.height/2)) / this.mapwindow_zoom/32 + this.mapwindow_y);
		let z = this.mapwindow_z;
		this.follow_desc = `${x},${y},${z}`;
	}
	keydown(e) {
		this.canvas.focus();
		if(e.code == "PageDown") {
			this.mapwindow_z = Math.max(this.mapwindow_z - 1, 1);
		} else if(e.code == "PageUp") {
			this.mapwindow_z = Math.min(this.mapwindow_z + 1, this.demo.maxz);
		} else if(e.code == "Space") {
			if(e.shiftKey) {
				this.playback_speed = (this.playback_speed != 5) ? 5 : 1;
			} else if(e.ctrlKey) {
				this.playback_speed = (this.playback_speed != -3) ? -3 : 1;
			} else {
				this.playback_speed = (this.playback_speed == 0) ? 1 : 0;
			}
			e.preventDefault();
		} else if(e.code == "ArrowLeft") {
			this.advance_playhead(this.playhead - 50);
		} else if(e.code == "ArrowRight") {
			this.advance_playhead(this.playhead + 50);
		}
	}

	canvas_wheel(e) {
		this.mapwindow_log_zoom -= Math.max(-1, Math.min(1, e.deltaY / 100));
		this.mapwindow_log_zoom = Math.max(-5, Math.min(5, this.mapwindow_log_zoom));
		this.mapwindow_zoom = 2 ** Math.round(this.mapwindow_log_zoom);
		e.preventDefault();
	}

	animation_frame_callback(timestamp) {
		try {
			this.frame(timestamp);
		} catch(e) {
			console.error(e);
		}
		window.requestAnimationFrame(this.animation_frame_callback.bind(this));
	}

	get_object(ref) {
		if(ref == null) return;
		if(ref[0] == '[') {
			let number = parseInt(ref.substring(1)); // parseInt ignores trailing characters, so no need to worry about the ] at the end. Also it handles the 0x at the front
			let ref_type = number >> 24;
			let ref_id = number & 0xFFFFFF;
			let type_array = this.object_ref_list[ref_type];
			if(type_array) {
				return type_array[ref_id];
			}
		} else {
			// this used to use split(). Line-by-line JS profiling revealed that was slow as shit. Now it doesn't.
			let comma1 = ref.indexOf(",");
			let comma2 = ref.indexOf(",", comma1+1);
			let x = +ref.substring(0, comma1);
			let y = +ref.substring(comma1+1,comma2);
			let z = +ref.substring(comma2+1);
			let z_array = this.turf_grid[z-1];
			if(z_array) {
				let y_array = z_array[y-1];
				if(y_array) {
					return y_array[x-1];
				}
			}
		}
	}
	set_object(ref, obj) {
		if(ref == null) return;
		if(ref[0] == '[') {
			let number = parseInt(ref.substring(1)); // parseInt ignores trailing characters, so no need to worry about the ] at the end. Also it handles the 0x at the front
			let ref_type = number >> 24;
			let ref_id = number & 0xFFFFFF;
			let type_array = this.object_ref_list[ref_type];
			if(!type_array) {
				this.object_ref_list[ref_type] = type_array = [];
			}
			type_array[ref_id] = obj;
		} else {
			let split = ref.split(",");
			let x = +split[0];
			let y = +split[1];
			let z = +split[2];
			let z_array = this.turf_grid[z-1];
			if(!z_array) {
				this.turf_grid[z-1] = z_array = [];
			}
			let y_array = z_array[y-1];
			if(!y_array) {
				z_array[y-1] = y_array = [];
			}
			y_array[x-1] = obj;
		}
	}
}
Object.assign(DemoPlayer.prototype, require('./renderer.js'));

function format_duration(total_seconds) {
	let hours = Math.floor(total_seconds / 3600);
	let minutes = Math.floor((total_seconds - (hours * 3600)) / 60);
	let seconds = total_seconds - (hours * 3600) - (minutes * 60);

	return `${hours}`.padStart(2, 0) + ":" + `${minutes}`.padStart(2, 0) + ":" + `${seconds}`.padStart(2, 0)
}

module.exports = DemoPlayer;
