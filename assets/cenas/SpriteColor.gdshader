shader_type canvas_item;
//uniform sampler2D pallete;
//uniform vec3 mult = vec3(0.6,0.05,0.4);
uniform vec4 C[8];

void fragment(){
	vec4 rgba = texture(TEXTURE, UV);
	vec4 final_color = vec4(0,0,0,0);
	if(rgba.a > 0.1){
		final_color = vec4(C[int((1.0-rgba.r)*8.0)]);
	}
	COLOR = final_color;

	//vec4 final_color = texture(pallete, vec2(rgba.r, rgba.g));
	//final_color.a = rgba.a;

}