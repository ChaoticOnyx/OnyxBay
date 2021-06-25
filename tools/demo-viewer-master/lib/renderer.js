'use strict';
const DrawBatch = require('./draw_batch.js');
const parse_color = require('color-parser');
const Matrix = require('./matrix.js');

const dir_progressions = [
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2], // 0 dirs
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2], // 1 dir
	[3,3,3,3,12,3,3,3,12,3,3,3,12,3,3,3], // 2 dirs
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2], // 3 dirs
	[2,1,2,2,4,4,2,4,8,8,8,4,1,2,2,2], // 4 dirs
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2], // 5 dirs
	[3,3,3,3,12,5,6,12,12,9,10,12,12,3,3,3], // 6 dirs
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2], // 7 dirs
	[2,1,2,2,4,5,6,4,8,9,10,8,4,1,2,2], // 8 dirs
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2], // 9 dirs
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2], // 10 dirs
	[3,3,3,3,12,5,6,7,12,9,10,11,12,13,14,15], // 11 dirs
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2], // 12 dirs
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2], // 13 dirs
	[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2], // 14 dirs
	[2,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], // 15 dirs
	[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15] // 16 dirs
];

// stolen straight from the unfinished webgl branch of Bluespess
function init_rendering() {
	this.gl = document.createElement("canvas").getContext("webgl");
	const gl = this.gl;
	// build the default shader
	this.max_icons_per_batch = Math.min(gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS),256);
	let texture_switch = (function build_texture_switch(s, l) { // fancy ass recursive binary tree thingy for SANIC SPEED... I hope
		if(l == 0)
			return "";
		else if(l == 1)
			return `color *= texture2D(u_texture[${s}], v_uv);`;
		else {
			let split_point = Math.ceil(l/2);
			return `if(v_tex_index < ${split_point+s}.0){${build_texture_switch(s, split_point)}}else{${build_texture_switch(s+split_point, l-split_point)}}`;
		}
	}(0, this.max_icons_per_batch)); // it would be so much easier if I could just index the goddamn array normally but no they had to be fuckers and now I have this super convoluted if/else tree god damn it glsl why you do this to me
	this.shader_default = this.compile_shader_program(`
precision mediump float;
attribute vec2 a_position;
attribute vec4 a_color;
varying vec4 v_color;
attribute vec2 a_uv;
varying vec2 v_uv;
attribute float a_tex_index;
varying float v_tex_index;
uniform vec2 u_viewport_size;
void main() {
	v_color = a_color;
	v_uv = a_uv;
	v_tex_index = a_tex_index;
	gl_Position = vec4(a_position / u_viewport_size * 2.0, 0.0, 1.0);
}
`,`
precision mediump float;
uniform sampler2D u_texture[${this.max_icons_per_batch}];
varying vec4 v_color;
varying vec2 v_uv;
varying float v_tex_index;
uniform vec2 u_viewport_size;
void main() {     // fucking shit why is there no bitwise and
	vec4 color = v_color;
	${texture_switch}
	gl_FragColor = color;
}
`);

	this.gl_viewport = [32, 32];
	this.gl_current_batch = null;

	this.gl_texture_cache = new Map();
	this.gl_uniform_cache = new Map();

	this.gl_uniform_cache.set(this.shader_default, {
		u_viewport_size: gl.getUniformLocation(this.shader_default, "u_viewport_size"),
		u_viewport_tile_size: gl.getUniformLocation(this.shader_default, "u_viewport_tile_size"),
		u_world_origin: gl.getUniformLocation(this.shader_default, "u_world_origin")
	});

	this.gl_white_texture = gl.createTexture();
	gl.bindTexture(gl.TEXTURE_2D, this.gl_white_texture);
	gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, new Uint8Array([255,255,255,255]));

	gl.enable(gl.BLEND);
	gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
}

function get_texture(key) {
	const gl = this.gl;
	if(this.gl_texture_cache.has(key)) {
		return this.gl_texture_cache.get(key);
	}
	if(this.icons.has(key)) {
		let img = this.icons.get(key).image;
		if(!img || !img.complete)
			return this.gl_white_texture;
		let texture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		this.gl_texture_cache.set(key, texture);
		return texture;
	}
	return this.gl_white_texture;
}

function compile_shader(code, type) {
	const gl = this.gl;
	let shader = gl.createShader(type);
	gl.shaderSource(shader, code);
	gl.compileShader(shader);
	if(!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
		throw new Error((type == gl.VERTEX_SHADER ? "VERTEX SHADER " : "FRAGMENT SHADER ") + gl.getShaderInfoLog(shader));
	}
	return shader;
}

function compile_shader_program(vertex_code, fragment_code) {
	const gl = this.gl;
	let program = gl.createProgram();
	gl.attachShader(program, this.compile_shader(vertex_code, gl.VERTEX_SHADER));
	gl.attachShader(program, this.compile_shader(fragment_code, gl.FRAGMENT_SHADER));
	gl.linkProgram(program);
	if(!gl.getProgramParameter(program, gl.LINK_STATUS)) {
		throw new Error(gl.getProgramInfoLog (program));
	}
	return program;
}

function draw_appearance(transform, obj, parent_properties = null, atom, original_transform = transform) {
	if(obj.plane == 15) return; // remove lighting
	if(obj.invisibility > this.see_invisible) return; // nah
	//let effective_dir = ((obj.dir == 0) && parent_dir != null) ? parent_dir : obj.dir;
	let inh = {
		color: obj.color,
		dir: obj.dir,
		alpha: obj.alpha
	}
	if(parent_properties) {
		if(inh.dir == 0) inh.dir = parent_properties.dir;
		if(!(obj.appearance_flags & 4)) { // RESET_ALPHA
			inh.alpha *= (parent_properties.alpha / 255);
		}
		if(!(obj.appearance_flags & 2)) { // RESET_COLOR
			if(!inh.color || (typeof inh.color == "string" && inh.color.toLowerCase() == "#ffffff")) inh.color = parent_properties.color;
		}
	}
	if(obj.appearance_flags & 8) { // RESET_TRANSFORM
		transform = original_transform
	}

	transform = transform.translate(obj.pixel_x, obj.pixel_y);
	if(obj.transform) {
		if(obj.transform[0] == 1 && obj.transform[1] == 0 && obj.transform[3] == 0 && obj.transform[4] == 1) {
			// this is a glorified move.
			transform = transform.translate(obj.transform[2], obj.transform[5]);
		} else {
			transform = transform.translate(16,16).multiply(new Matrix(obj.transform[0],obj.transform[3],obj.transform[1],obj.transform[4],obj.transform[2],obj.transform[5])).translate(-16,-16);
		}
	}
	// slight hack:
	// I am not separating the overlays out to be sorted, because fuck that.
	for(let underlay of obj.underlays) {
		this.draw_appearance(transform, underlay, inh, atom, original_transform);
	}
	let icon_meta = this.icons.get(obj.icon);
	if(icon_meta) {
		let icon_state = obj.icon_state;
		if(icon_state == "?" && obj.icon == "icons/turf/space.dmi") {
			icon_state = `${(((atom.x + atom.y) ^ ~(atom.x * atom.y) + atom.z) % 25 + 25) % 25}`;
		}
		let icon_state_meta = icon_meta.icon_states.get(icon_state) || icon_meta.icon_states.get(" ") || icon_meta.icon_states.get("");
		if(icon_state_meta) {
			let dir_meta = null;
			let progression = dir_progressions[icon_state_meta.dir_count] || dir_progressions[1];
			dir_meta = icon_state_meta.dirs.get(progression[inh.dir]) || icon_state_meta.dirs.get(2);
			if(dir_meta) {
				let icon_time = this.playhead % dir_meta.total_delay;
				let icon_frame = 0;
				let accum_delay = 0;
				for(let i = 0; i < dir_meta.frames.length; i++) {
					accum_delay += dir_meta.frames[i].delay;
					if(accum_delay > icon_time) {
						icon_frame = i;
						break;
					}
				}
				let frame_meta = dir_meta.frames[icon_frame >= 0 && icon_frame < dir_meta.frames.length ? icon_frame : 0];

				if(!this.gl_current_batch || this.gl_current_batch.constructor != DrawBatch || !this.gl_current_batch.can_fit(6, obj.icon)) {
					if(this.gl_current_batch)
						this.gl_current_batch.draw();
					if(!this.gl_current_batch || this.gl_current_batch.constructor != DrawBatch)
						this.gl_current_batch = new DrawBatch(this);
				}


				let batch = this.gl_current_batch;
				let image = icon_meta.image;
				let inv_img_width = 1/image.width;
				let inv_img_height = 1/image.height;
				let texture_index = batch.icon_list.indexOf(obj.icon);
				if(texture_index == -1) {
					texture_index = batch.icon_list.length;
					batch.icon_list.push(obj.icon);
				}
				let icon_state_width = icon_state_meta.width;
				let icon_state_height = icon_state_meta.height;
				let parsed_color = (inh.color && typeof inh.color == "string") ? parse_color(inh.color) : null;
				let alpha = inh.alpha / 255;
				alpha = (alpha == null ? 1 : alpha);
				for(let ia = 0; ia < 2; ia++) for(let ib = 0; ib < 3; ib++) { // iterates in ther order 0,1,2,1,2,3
					let i = ia + ib;
					let sx = (i & 1);
					let sy = (i & 2) >> 1;
					let vertex_num = batch.num_vertices;
					batch.buffers.texture_indices.buf[vertex_num] = texture_index;
					let transformed_coords = transform.multiply([sx*icon_state_width,sy*icon_state_height]);
					batch.buffers.vertices.buf[(vertex_num<<1)] = transformed_coords[0];
					batch.buffers.vertices.buf[(vertex_num<<1)+1] = transformed_coords[1];
					batch.buffers.uv.buf[(vertex_num<<1)] = (frame_meta.x + (sx*icon_state_width)) * inv_img_width;
					batch.buffers.uv.buf[(vertex_num<<1) + 1] = (frame_meta.y + ((1-sy)*icon_state_height)) * inv_img_height;
					if(parsed_color) {
						batch.buffers.colors.buf[(vertex_num<<2)] = parsed_color.r / 255;
						batch.buffers.colors.buf[(vertex_num<<2)+1] = parsed_color.g / 255;
						batch.buffers.colors.buf[(vertex_num<<2)+2] = parsed_color.b / 255;
						batch.buffers.colors.buf[(vertex_num<<2)+3] = parsed_color.a * alpha;
					} else {
						batch.buffers.colors.buf[(vertex_num<<2)] = 1;
						batch.buffers.colors.buf[(vertex_num<<2)+1] = 1;
						batch.buffers.colors.buf[(vertex_num<<2)+2] = 1;
						batch.buffers.colors.buf[(vertex_num<<2)+3] = 1 * alpha;
					}
					batch.num_vertices++;
				}

				//ctx.drawImage(image, frame_meta.x, frame_meta.y, icon_state_meta.width, icon_state_meta.height, inh.pixel_x+obj.pixel_w, 32-icon_state_meta.height-inh.pixel_y-obj.pixel_z, icon_state_meta.width, icon_state_meta.height);
			}
		}
	}
	if(!obj.sorted_overlays) {
		obj.sorted_overlays = [...obj.overlays].sort((a,b) => {
			let a_layer = a.layer < 0 ? obj.layer : a.layer;
			let b_layer = b.layer < 0 ? obj.layer : b.layer;
			if(a_layer < b_layer)
				return a_layer - b_layer;
			let a_float_layer = a.layer < 0 ? a.layer : -1;
			let b_float_layer = b.layer < 0 ? b.layer : -1;
			if(a_float_layer < b_float_layer)
				return a_float_layer - b_float_layer;
			return 0;
		});
	}
	for(let overlay of obj.sorted_overlays) {
		this.draw_appearance(transform, overlay, inh, atom, original_transform);
	}
}

module.exports = {init_rendering, compile_shader, compile_shader_program, get_texture, draw_appearance};
