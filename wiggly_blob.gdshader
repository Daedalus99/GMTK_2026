shader_type canvas_item;

uniform float wiggle_speed = 1.0;
uniform float wiggle_amount = 0.1;
uniform float pulse_amount = 1.0;
uniform vec4 blob_color = vec4(0.8, 0.4, 0.6, 1.0);
uniform vec4 core_color = vec4(1.0, 0.6, 0.8, 1.0);
uniform float size = 0.4;
uniform float wall_thickness = 0.05;
uniform float wiggle_seed = 0.0;
uniform bool auto_seed = false;
uniform vec2 node_world_location;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV - 0.5; // Center the blob
    float t = TIME * wiggle_speed;
    
    // Create wiggly distortion using multiple sine waves
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    
    // Add wiggle to radius using multiple frequencies with seed offset
	    float seed = hash(node_world_location * 0.01) * 20.0;    float wiggle = sin(angle * 3.0 + t + seed) * 0.3;
    wiggle += sin(angle * 7.0 - t * 1.5 + seed * 1.7) * 0.2;
    wiggle += sin(angle * 11.0 + t * 0.8 + seed * 2.3) * 0.15;
    wiggle *= wiggle_amount;
    
    // Pulsing size variation
    float pulse = 1.0 + sin(t * 2.0) * 0.1 * pulse_amount;
    float blob_radius = size * pulse;
    
    // Distance from center with wiggle applied
    float dist = radius - wiggle;
    
    // Main blob outer edge
    float outer_mask = 1.0 - smoothstep(blob_radius - 0.005, blob_radius + 0.005, dist);
    
    // Inner edge for cell wall
    float inner_radius = blob_radius - wall_thickness;
    float inner_mask = 1.0 - smoothstep(inner_radius - 0.005, inner_radius + 0.005, dist);
    
    // Cell wall is the difference between outer and inner
    float wall_mask = outer_mask - inner_mask;
    
    // Interior fill
    vec4 final_color = core_color * inner_mask;
    
    // Add cell wall
    final_color += blob_color * wall_mask;
    
    // Set alpha
    final_color.a = outer_mask;
    
    COLOR = final_color;
}