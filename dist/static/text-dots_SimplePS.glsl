//#version 330

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

uniform sampler2D u_tex0; //404 texture
uniform sampler2D u_tex1; //noise texture

#define circleCellSize 0.01
#define circleCellFill 1.

//out vec4 gl_FragColor;

float circle(in vec2 uv, in vec2 pos, in float _radius){
    vec2 dist = uv-pos;
	return 1.-smoothstep(_radius-(_radius*0.),
                         _radius+(_radius*0.1
                         ),
                         dot(dist,dist)*4.);
}

void main( void ) {

	//=====
	//init
	float t = u_time;
    vec3 col = vec3(0.);
    
    vec2 uv = gl_FragCoord.xy / u_resolution.xy; // 0 <> 1
	uv -= .5;
    uv.y *= u_resolution.y/u_resolution.x;
    
    #ifdef SHADERedEditor
    vec2 pointer = u_mouse;
    #else
    vec2 pointer = u_mouse/u_resolution;
    #endif
    pointer -= .5;
  	pointer.y *= u_resolution.y/u_resolution.x;
    //pointer = vec2(.0);
    
    //=====
    //color
    
	col += vec3(abs(sin(t)),abs(sin(t+180.)),abs(sin(t+360.)));
	
	//=====
	//shapes
	
	vec2 pointUv = mod(uv, circleCellSize);
	
	//---
	//circles generation
	float maxRadius = pow(circleCellSize, 2.)*circleCellFill;
	float radius = pow(circleCellSize, 2.)*circleCellFill;
	float scale = pow(distance(pointer, uv)/.5, .5);
	scale *= 1.-sin(t*.5)*0.05;
	scale = 1.-clamp(scale, circleCellSize, 0.99);
	radius *= scale;
	
	//---
	//text shape
	{
		vec2 texUv = uv-pointUv;
		#ifdef SHADERedEditor
		vec2 texSize = textureSize(u_tex0, 0);
		texUv.y *= texSize.x/texSize.y;
		#else
		//in webgl textureSize doesn't work
		texUv.y *= 2.6;
		#endif
		vec4 tex = texture2D(u_tex0, texUv+.5);
		radius *= tex.r;
	}
	//---
	//noise shape
	{
		vec4 tex = texture2D(u_tex1, gl_FragCoord.xy / u_resolution.xy * sin(t*.1));
		radius *= smoothstep(0., tex.r, radius/maxRadius);
	}
	
	col *= circle(pointUv, vec2(circleCellSize/2.), radius);
	col *= smoothstep(0.1, 0.13, radius/maxRadius);
	
    gl_FragColor = vec4(col, 1.0);
}
