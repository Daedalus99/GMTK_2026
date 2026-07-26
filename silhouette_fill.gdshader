shader_type canvas_item;

void fragment() {
    // 1. Draw the silhouette normally so you don't need a duplicate node
    COLOR = texture(TEXTURE, UV);
}

void light() {
    // 2. Look at the silhouette's transparency (TEXTURE, UV) at this pixel
    float mask_alpha = texture(TEXTURE, UV).a;
    
    // 3. Invert it: Wherever the silhouette is solid (1.0), make it transparent (0.0).
    // Wherever the silhouette is empty space (0.0), let the child draw (1.0).
    float inverted_mask = 1.0 - mask_alpha;
    
    // 4. Assign the final vec4 to the LIGHT output variable
    LIGHT = vec4(LIGHT_COLOR.rgb, LIGHT_COLOR.a * inverted_mask);
}
