shader_type canvas_item; 
uniform sampler2D pallete;

uniform vec3 mult = vec3(0.6,0.05,0.4);
uniform vec3 color1 = vec3(0.565, 0.643, 0.682);

void fragment(){
	vec4 rgba = texture(TEXTURE, UV);
	vec4 final_color = vec4(color1,rgba.a);
	COLOR = final_color;
	
	//vec4 final_color = texture(pallete, vec2(rgba.r, rgba.g));
	//final_color.a = rgba.a;
	
}