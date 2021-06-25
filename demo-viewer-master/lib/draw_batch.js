'use strict';

// stolen straight from the unfinished webgl branch of Bluespess
class DrawBatch {
	constructor(client) {
		this.icon_list = [];
		this.num_vertices = 0;
		this.client = client;
		this.init_buffers();
		this.program = this.client.shader_default;
		if(this.client.gl_current_batch) {
			throw new Error(`GL batch already exists`);
		}
		this.client.gl_current_batch = this;
	}

	init_buffers() {
		let gl = this.client.gl;
		this.max_vertices = 4096;
		this.buffers = {
			vertices:        {buf: new Float32Array(this.max_vertices*2), size: 2, attrib: "a_position",   gl_buf: null, gl_pos: null, type: gl.FLOAT},
			uv:              {buf: new Float32Array(this.max_vertices*2), size: 2, attrib: "a_uv",         gl_buf: null, gl_pos: null, type: gl.FLOAT},
			colors:          {buf: new Float32Array(this.max_vertices*4), size: 4, attrib: "a_color",      gl_buf: null, gl_pos: null, type: gl.FLOAT},
			texture_indices: {buf: new Uint8Array(this.max_vertices),   size: 1, attrib: "a_tex_index",  gl_buf: null, gl_pos: null, type: gl.UNSIGNED_BYTE},
		};
	}

	reset() {
		this.num_vertices = 0;
		this.icon_list.length = 0;
	}

	bind_textures() {
		const gl = this.client.gl;
		for(let i = 0; i < this.icon_list.length; i++) {
			let uniform_loc = gl.getUniformLocation(this.program, `u_texture[${i}]`);
			gl.uniform1i(uniform_loc, i);
			gl.activeTexture(gl.TEXTURE0 + i);
			gl.bindTexture(gl.TEXTURE_2D, this.client.get_texture(this.icon_list[i]));
		}
	}

	can_fit(num_verts, textures) {
		if(this.num_vertices + num_verts > this.max_vertices)
			return false;
		if(typeof textures == "string") {
			if(this.icon_list.includes(textures))
				return true;
			if(this.icon_list.length < this.client.max_icons_per_batch)
				return true;
			return false;
		}
		let num_textures = this.icon_list;
		for(let texture of textures) {
			if(!this.icon_list.includes(texture))
				num_textures++;
		}
		if(num_textures > this.client.max_icons_per_batch)
			return false;
		return true;
	}

	assign_uniforms() {
		const gl = this.client.gl;
		let uniforms = this.client.gl_uniform_cache.get(this.program);
		gl.uniform2fv(uniforms.u_viewport_size, this.client.gl_viewport);
	}

	draw() {
		if(!this.num_vertices)
			return;
		if(this.client.gl_current_batch != this)
			throw new Error(`Cannot draw non-active batch`);
		let gl = this.client.gl;
		gl.useProgram(this.program);
		this.bind_textures();
		this.assign_uniforms();
		for(let obj of Object.values(this.buffers)) {
			let gl_buffer = obj.gl_buf = gl.createBuffer();
			gl.bindBuffer(gl.ARRAY_BUFFER, gl_buffer);
			gl.bufferData(gl.ARRAY_BUFFER, obj.buf.subarray(0, this.num_vertices * obj.size), gl.STREAM_DRAW);
			let gl_pos = obj.gl_pos = gl.getAttribLocation(this.program, obj.attrib);
			gl.vertexAttribPointer(gl_pos, obj.size, obj.type, false, 0, 0);
			gl.enableVertexAttribArray(gl_pos);
		}
		gl.drawArrays(gl.TRIANGLES, 0, this.num_vertices);
		for(let obj of Object.values(this.buffers)) {
			gl.deleteBuffer(obj.gl_buf);
			obj.gl_buf = null;
		}
		this.reset();
	}
}

module.exports = DrawBatch;
