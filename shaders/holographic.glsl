// Holographic shader - Linear rainbow film effect
// Horizontal bands that shift with viewing angle - like a holographic sticker

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
    
    // Linear bands - primarily horizontal with slight diagonal
    // Angle shifts dramatically with card tilt (like real holographic)
    float tiltInfluence = uRotation.x * 3.0 + uRotation.y * 2.0;
    
    // Main band position - horizontal lines that shift with tilt
    float bandPos = uv.y * 12.0  // Horizontal bands
                  + uv.x * 2.0   // Slight diagonal
                  + tiltInfluence * 8.0  // Strong tilt response
                  + iTime * 0.5;  // Slow drift
    
    // Sharp band edges for that holographic sticker look
    float band = fract(bandPos);
    
    // Create sharp rainbow bands (not smooth gradient)
    float hue = floor(bandPos) * 0.15;  // Discrete color steps
    hue = fract(hue + tiltInfluence * 0.5);  // Tilt shifts all colors
    
    // Add sub-bands for complexity
    float subBand = sin(bandPos * 6.28318 * 3.0) * 0.5 + 0.5;
    subBand = pow(subBand, 2.0);
    
    // Rainbow color with high saturation
    vec3 rainbow = hsv2rgb(vec3(hue, 0.9, 1.0));
    
    // Secondary color for sub-bands
    vec3 rainbow2 = hsv2rgb(vec3(fract(hue + 0.3), 0.8, 1.0));
    
    // Mix main and sub-band colors
    vec3 holoColor = mix(rainbow, rainbow2, subBand * 0.5);
    
    // Scan line effect - fine horizontal lines
    float scanLine = sin(uv.y * 200.0) * 0.5 + 0.5;
    scanLine = pow(scanLine, 8.0) * 0.3;
    
    // Shimmer based on tilt
    float shimmer = pow(max(0.0, sin(bandPos * 3.14159)), 4.0);
    
    // Effect strength based on texture brightness
    float brightness = dot(t.rgb, vec3(0.299, 0.587, 0.114));
    float effectStrength = smoothstep(0.1, 0.5, brightness) * 0.7;
    
    // Apply holographic effect
    vec3 finalColor = t.rgb;
    finalColor += holoColor * effectStrength * 0.6;
    finalColor += shimmer * vec3(1.0) * 0.3 * effectStrength;
    finalColor += scanLine * holoColor * effectStrength;
    
    return vec4(finalColor, t.a);
}
