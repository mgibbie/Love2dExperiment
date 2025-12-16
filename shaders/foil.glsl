// Foil shader - Authentic Balatro foil effect
// Ported from https://godotshaders.com/shader/balatro-foil-card-effect/

extern float iTime;
extern vec2 uRotation;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texel = Texel(tex, texture_coords);
    
    if (texel.a < 0.1) {
        discard;
    }
    
    vec2 uv = texture_coords;
    vec2 adjusted_uv = uv - vec2(0.5, 0.5);
    
    // Calculate color range for effect masking
    float low = min(texel.r, min(texel.g, texel.b));
    float high = max(texel.r, max(texel.g, texel.b));
    float delta = min(high, max(0.5, 1.0 - low));
    
    // Foil animation - time + rotation offset
    float speed = 1.0;
    vec2 foil = vec2(iTime * speed + uRotation.x * 2.0, uRotation.y * 2.0);
    
    // Complex wave pattern 1 - radial waves
    float fac = max(min(
        2.0 * sin(
            (length(90.0 * adjusted_uv) + foil.x * 2.0) + 
            3.0 * (1.0 + 0.8 * cos(length(113.1121 * adjusted_uv) - foil.x * 3.121))
        ) - 1.0 - max(5.0 - length(90.0 * adjusted_uv), 0.0),
        1.0), 0.0);
    
    // Complex wave pattern 2 - angular sweep
    vec2 rotater = vec2(cos(foil.x * 0.1221), sin(foil.x * 0.3512));
    float angle = dot(rotater, adjusted_uv) / (length(rotater) * length(adjusted_uv) + 0.001);
    float fac2 = max(min(
        5.0 * cos(
            foil.y * 0.3 + angle * 3.14 * (2.2 + 0.9 * sin(foil.x * 1.65 + 0.2 * foil.y))
        ) - 4.0 - max(2.0 - length(20.0 * adjusted_uv), 0.0),
        1.0), 0.0);
    
    // Horizontal shimmer waves
    float fac3 = 0.3 * max(min(
        2.0 * sin(foil.x * 5.0 + uv.x * 3.0 + 3.0 * (1.0 + 0.5 * cos(foil.x * 7.0))) - 1.0,
        1.0), -1.0);
    
    // Vertical shimmer waves
    float fac4 = 0.3 * max(min(
        2.0 * sin(foil.x * 6.66 + uv.y * 3.8 + 3.0 * (1.0 + 0.5 * cos(foil.x * 3.414))) - 1.0,
        1.0), -1.0);
    
    // Combine all factors
    float maxfac = max(
        max(fac, max(fac2, max(fac3, max(fac4, 0.0)))) + 
        2.2 * (fac + fac2 + fac3 + fac4),
        0.0);
    
    // Apply foil coloring - reduces red/green, boosts blue
    texel.r = texel.r - delta + delta * maxfac * 0.3;
    texel.g = texel.g - delta + delta * maxfac * 0.3;
    texel.b = texel.b + delta * maxfac * 1.9;
    
    // Keep original alpha (don't fade like the original does for overlay use)
    return texel;
}
