---
name: Weatherling Pixel-Prime
colors:
  surface: '#1d0c24'
  surface-dim: '#1d0c24'
  surface-bright: '#46324c'
  surface-container-lowest: '#18071e'
  surface-container-low: '#26152c'
  surface-container: '#2b1931'
  surface-container-high: '#36233c'
  surface-container-highest: '#412e47'
  on-surface: '#f6d9fa'
  on-surface-variant: '#dac2b4'
  inverse-surface: '#f6d9fa'
  inverse-on-surface: '#3c2942'
  outline: '#a28c80'
  outline-variant: '#544339'
  surface-tint: '#ffb68a'
  primary: '#ffc4a1'
  on-primary: '#522300'
  primary-container: '#ff9d5c'
  on-primary-container: '#743500'
  inverse-primary: '#95490d'
  secondary: '#deb7ff'
  on-secondary: '#480e76'
  secondary-container: '#622f91'
  on-secondary-container: '#d4a5ff'
  tertiary: '#f8ca60'
  on-tertiary: '#3f2e00'
  tertiary-container: '#daaf48'
  on-tertiary-container: '#5a4300'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdbc8'
  primary-fixed-dim: '#ffb68a'
  on-primary-fixed: '#321300'
  on-primary-fixed-variant: '#743500'
  secondary-fixed: '#f1dbff'
  secondary-fixed-dim: '#deb7ff'
  on-secondary-fixed: '#2d0050'
  on-secondary-fixed-variant: '#602c8e'
  tertiary-fixed: '#ffdf9b'
  tertiary-fixed-dim: '#edc157'
  on-tertiary-fixed: '#251a00'
  on-tertiary-fixed-variant: '#5b4300'
  background: '#1d0c24'
  on-background: '#f6d9fa'
  surface-variant: '#412e47'
  dusk-amber: '#E87C3E'
  twilight-indigo: '#3B2657'
  horizon-glow: '#FFC078'
  deep-plum: '#1A0F1F'
  status-hunger: '#FF4D6D'
  status-energy: '#4CC9F0'
  status-love: '#F72585'
typography:
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  pixel-display:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  pixel-unit: 4px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 32px
  touch-target-min: 48px
  container-padding: 12px
---

## Brand & Style

The design system embodies a "Premium Retro Pixel Art" aesthetic, blending the nostalgia of 16-bit JRPGs with the polished usability of a high-end modern mobile application. It is designed to evoke a sense of "Atmospheric Coziness"—a feeling of safety, warmth, and companionship that mirrors the user's real-world environment.

The design style is a hybrid of **High-Fidelity Pixel Art** and **Modern Functionalism**. It avoids the raw "crunchiness" of lo-fi aesthetics in favor of lush, anti-aliased-by-hand textures, intricate 9-patch borders, and a sophisticated lighting engine. The UI should feel like a physical, tactile game console from an alternate timeline where pixel art remained the pinnacle of premium design. Every interaction should feel "juicy," utilizing squash-and-stretch physics and soft glows to emphasize the living nature of the virtual companion.

## Colors

The "Golden Hour/Dusk" theme serves as the foundational palette, emphasizing warmth and transition. While the system is dynamic based on time-of-day, the UI components remain anchored in these "Dusk" tones to ensure visual consistency.

- **Primary**: A vibrant amber-orange, used for active states and focal points.
- **Secondary**: A deep, royal purple that provides high-contrast depth for containers.
- **Tertiary**: A soft, pale gold used for highlights and "juice" indicators.
- **Neutral**: A rich, desaturated plum-black used for backgrounds to maintain the atmospheric weight.

Color is used functionally to indicate state: "Status" colors for hunger, energy, and love are more saturated than the environmental palette to ensure they pop against the atmospheric background. All surfaces should use a subtle gradient or "dithering" effect to bridge the gap between pixel art and modern display tech.

## Typography

The typography system balances "Retro Character" with "Android Legibility." 

1. **Display & Headings**: Uses **Space Grotesk**. While not a literal pixel font, its geometric and slightly technical construction mimics the structural feel of pixel art while remaining perfectly legible at high resolutions. For an even more "retro" feel, headers may use `text-transform: uppercase`.
2. **Body Text**: **Hanken Grotesk** provides a clean, contemporary sans-serif experience. This ensures that longer strings of text (weather descriptions, care instructions) are accessible and professional.
3. **Labels & Status**: **JetBrains Mono** is used for technical data, coin counts, and status levels. Its monospaced nature reinforces the "game UI" aesthetic and ensures numerical alignment in the HUD.

**Scaling**: For mobile, headlines downscale aggressively to prevent layout overflow. Interaction targets (labels on buttons) always maintain a minimum of 12px for accessibility.

## Layout & Spacing

This design system utilizes a **Fluid Grid with Rigid Components**. While the overall layout stretches to fit the Android screen, the individual UI components (buttons, panels) are built on a 4px "pixel unit" grid to maintain the integrity of the pixel art.

- **The Thumb Zone**: All primary navigation (Feed, Play, Skill, Shop) is anchored to the bottom 25% of the screen.
- **HUD**: The top-down status bars (Hunger, Energy) are pinned to the top, utilizing safe-area insets to avoid camera notches.
- **9-Patch Logic**: All containers must use 9-patch scaling. This means the corners (fixed at 16x16 pixels) remain sharp, while the center edges stretch to fill the layout.
- **Responsive Behavior**: On tablets, the single-column view expands into a "Dashboard" view where the creature remains centered and the UI panels flank the sides in modular side-carriages.

## Elevation & Depth

Elevation is conveyed through **Tonal Layering** and **Atmospheric Shaders** rather than traditional dropshadows.

1.  **Z-0 (Deepest)**: The weather-based background (parallax layers).
2.  **Z-1 (Environment)**: Foliage, furniture, and the Weatherling creature.
3.  **Z-2 (UI Panels)**: Ornate 9-patch containers. These use a "Soft Glow" (outer glow in primary/secondary color) rather than a shadow to suggest they are "holographic" or "magic."
4.  **Z-3 (Interactive)**: Buttons and Active Modals. These feature a "Bevel" effect (1px highlight on top-left, 1px lowlight on bottom-right) to look like physical plastic buttons.

**Juice**: When a user taps an element, it should "squash" (scale Y down, scale X up) and emit a small particle burst or soft bloom.

## Shapes

The shape language is **Soft-Pixel**. While the art is built on a square grid, the corners of all UI elements are "stepped" to create a rounded effect without using true vector curves.

- **Standard Elements**: Use a 1-step (4px) corner radius.
- **Large Panels**: Use a 2-step (8px) corner radius for a "cozier," friendlier feel.
- **Organic Nodes**: For the Skill Tree, shapes should be irregular "blob" pixel shapes to mimic leaves and branches, avoiding perfect squares.

## Components

- **Tactile Buttons**: Must have a distinct "Pressed" state where the 1px highlight disappears and the entire graphic shifts down by 2px. They should look like SNES-era controller buttons.
- **Floating Action Button (FAB)**: Represented as a circular pixel icon (e.g., a floating sun or moon) with a 2px outer stroke to separate it from the background.
- **9-Patch Containers**: Panels use a deep purple (`#2D1B33`) background with an ornate amber (`#FF9D5C`) border. The border pattern should be repeating and intricate.
- **Status Bars**: Traditional "experience bar" styling. Use a dark background track and a saturated, glowing fill color. Add a "shine" pixel line across the top 1/3 of the fill for a "glassy" feel.
- **Chips/Labels**: Small rectangular tags with inverted colors (light background, dark text) to indicate categories or life-stages.
- **Input Fields**: Inset "carved" boxes with a 1px inner shadow to look like they are recessed into the UI panel.
- **Particle VFX**: Subtle "dust motes" or "light rays" should occasionally pass over the UI to reinforce the atmospheric vibe.