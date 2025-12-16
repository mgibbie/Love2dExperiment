// Negative shader - inverted colors with dark energy glow
// Creates an otherworldly, inverted appearance

extern float iTime;
extern vec2 uRotation;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 t = Texel(tex, texture_coords);
    
    if (t.a < 0.1) {
        discard;
    }
    
    // Invert the colors
    vec3 inverted = vec3(1.0) - t.rgb;
    
    // Add a dark/purple tint to the inverted colors
    vec3 tint = vec3(0.4, 0.3, 0.6);
    vec3 tinted = inverted * tint * 2.0;
    
    // Edge glow effect
    vec2 center = vec2(0.5, 0.5) + uRotation * 0.1;  // Center shifts with tilt
    float dist = length(texture_coords - center);
    
    // Pulsing glow
    float pulse = sin(iTime * 2.0) * 0.5 + 0.5;
    
    // Glow color (dark purple/blue energy) - shifts with rotation
    vec3 glowColor = vec3(0.5 + uRotation.x * 0.2, 0.2, 0.8 + uRotation.y * 0.2);
    
    // Add swirling energy effect
    float angle = atan(texture_coords.y - 0.5, texture_coords.x - 0.5);
    float swirl = sin(angle * 3.0 + iTime * 2.0 + dist * 10.0) * 0.5 + 0.5;
    
    // Combine effects
    float brightness = dot(t.rgb, vec3(0.299, 0.587, 0.114));
    
    // Dark areas get the glow effect
    float glowAmount = (1.0 - brightness) * 0.4 * (0.7 + pulse * 0.3);
    
    vec3 finalColor = tinted;
    finalColor += glowColor * glowAmount * swirl;
    
    // Add subtle edge highlight
    float edge = smoothstep(0.3, 0.5, dist);
    finalColor += glowColor * edge * 0.2 * pulse;
    
    return vec4(finalColor, t.a);
}

