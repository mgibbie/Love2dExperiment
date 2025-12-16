// Balatro-style psychedelic background shader
// Ported from Three.js TSL to Love2D GLSL

extern float iTime;
extern vec2 iResolution;

// Shader parameters
const float PIXEL_SIZE_FAC = 700.0;
const float SPIN_EASE = 0.5;
const vec4 colour_1 = vec4(0.85, 0.2, 0.2, 1.0);       // Red
const vec4 colour_2 = vec4(0.0, 0.612, 1.0, 1.0);      // Cyan (156/255 = 0.612)
const vec4 colour_3 = vec4(0.0, 0.0, 0.0, 1.0);        // Black
const float spin_amount = 0.4;
const float contrast = 1.5;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 fragCoord = screen_coords;
    
    // Calculate UV coordinates centered on screen
    vec2 uv = (fragCoord - iResolution.xy) / 3000.0;
    float uv_len = length(uv);
    
    // Spinning animation
    float speed = iTime * SPIN_EASE * 0.1 + 302.2;
    
    // Calculate spin angle based on distance from center
    float spin_factor = 1.0 * spin_amount * uv_len + (1.0 - 1.0 * spin_amount);
    float new_pixel_angle = atan(uv.y, uv.x) + speed - SPIN_EASE * 20.0 * spin_factor;
    
    // Apply rotation to UV
    uv = vec2(
        uv_len * cos(new_pixel_angle),
        uv_len * sin(new_pixel_angle)
    );
    
    uv *= 15.0;
    speed = iTime * 1.0;
    
    vec2 uv2 = vec2(uv.x + uv.y, uv.x - uv.y);
    
    // Distortion loop (5 iterations)
    for (int i = 0; i < 5; i++) {
        uv2 += uv + cos(length(uv));
        uv += 0.5 * vec2(
            cos(5.1123314 + 0.353 * uv2.y + speed * 0.131121),
            sin(uv2.x - 0.113 * speed)
        );
        uv -= 1.0 * cos(uv.x + uv.y) - 1.0 * sin(uv.x * 0.711 - uv.y);
    }
    
    // Calculate color blending
    float contrast_mod = 0.25 * contrast + 0.5 * spin_amount + 1.2;
    float paint_res = clamp(length(uv) * 0.035 * contrast_mod, 0.0, 2.0);
    
    // Color channel weights
    float c1p = max(0.0, 1.0 - contrast_mod * abs(1.0 - paint_res));
    float c2p = max(0.0, 1.0 - contrast_mod * abs(paint_res));
    float c3p = 1.0 - min(1.0, c1p + c2p);
    
    // Final color calculation
    vec4 ret_col = (0.3 / contrast) * colour_1 +
        (1.0 - 0.3 / contrast) * (
            colour_1 * c1p +
            colour_2 * c2p +
            vec4(c3p * colour_3.rgb, c3p * colour_1.a)
        ) +
        0.3 * max(c1p * 5.0 - 4.0, 0.0) +
        0.4 * max(c2p * 5.0 - 4.0, 0.0);
    
    return ret_col;
}

