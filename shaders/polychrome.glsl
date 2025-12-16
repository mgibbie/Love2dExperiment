// Polychrome shader - VIVID iridescent oil-slick rainbow effect
// Dramatic, unmistakable rainbow iridescence

extern float iTime;
extern vec2 uRotation;

vec3 hsv2rgb(vec3 c) {
    vec3 p = abs(fract(c.xxx + vec3(0.0, 1.0/3.0, 2.0/3.0)) * 6.0 - 3.0);
    return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 t = Texel(tex, texture_coords);
    
    if (t.a < 0.1) {
        discard;
    }
    
    vec2 uv = texture_coords;
    vec2 centeredUV = uv - vec2(0.5);
    
    // Swirl center moves with tilt
    vec2 swirlCenter = uRotation * 0.5;
    vec2 offset = centeredUV - swirlCenter;
    
    float dist = length(offset);
    float angle = atan(offset.y, offset.x);
    
    // STRONG swirling pattern
    float swirl = angle * 2.0 + dist * 10.0 - iTime * 2.0;
    swirl += sin(dist * 15.0 - iTime * 3.0) * 0.5;
    swirl += cos(angle * 3.0 + iTime) * 0.3;
    
    // Tilt dramatically shifts the hue
    float tiltShift = (uRotation.x + uRotation.y) * 2.0;
    
    // Calculate hue - cycles through full rainbow
    float hue = fract(swirl * 0.15 + tiltShift + iTime * 0.1);
    
    // FULL saturation, FULL brightness rainbow
    vec3 rainbow = hsv2rgb(vec3(hue, 1.0, 1.0));
    
    // Make colors even more vivid - boost specific channels
    rainbow.r = pow(rainbow.r, 0.8);
    rainbow.g = pow(rainbow.g, 0.8);
    rainbow.b = pow(rainbow.b, 0.8);
    
    // Secondary rainbow layer offset
    float hue2 = fract(hue + 0.33);
    vec3 rainbow2 = hsv2rgb(vec3(hue2, 1.0, 1.0));
    
    // Blend the two rainbow layers
    float blend2 = sin(dist * 20.0 + iTime * 2.0) * 0.5 + 0.5;
    rainbow = mix(rainbow, rainbow2, blend2 * 0.4);
    
    // Effect strength - STRONG everywhere, stronger on lighter areas
    float brightness = dot(t.rgb, vec3(0.299, 0.587, 0.114));
    float effectStrength = 0.5 + smoothstep(0.0, 0.5, brightness) * 0.5;
    
    // Balanced color overlay - toned down 50%
    vec3 finalColor = t.rgb * (0.8 + rainbow * 0.3);  // Multiply blend
    finalColor += rainbow * effectStrength * 0.2;     // Additive glow
    
    // Extra shimmer highlights
    float shimmer = pow(sin(swirl * 2.0) * 0.5 + 0.5, 3.0);
    finalColor += rainbow * shimmer * 0.15;
    
    // Ensure colors stay vivid
    float gray = dot(finalColor, vec3(0.299, 0.587, 0.114));
    finalColor = mix(vec3(gray), finalColor, 1.4);  // Boost saturation
    
    return vec4(finalColor, t.a);
}
