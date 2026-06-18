---
name: Neo-Centric Brutalism
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f4'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#5b4040'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f0f1f1'
  outline: '#8f6f6f'
  outline-variant: '#e3bebd'
  surface-tint: '#ba1830'
  primary: '#b9172f'
  on-primary: '#ffffff'
  primary-container: '#dc3545'
  on-primary-container: '#ffffff'
  inverse-primary: '#ffb3b2'
  secondary: '#006d41'
  on-secondary: '#ffffff'
  secondary-container: '#90f4b7'
  on-secondary-container: '#007144'
  tertiary: '#5e5d5d'
  on-tertiary: '#ffffff'
  tertiary-container: '#777676'
  on-tertiary-container: '#ffffff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad9'
  primary-fixed-dim: '#ffb3b2'
  on-primary-fixed: '#410008'
  on-primary-fixed-variant: '#92001f'
  secondary-fixed: '#93f7ba'
  secondary-fixed-dim: '#77da9f'
  on-secondary-fixed: '#002110'
  on-secondary-fixed-variant: '#00522f'
  tertiary-fixed: '#e5e2e1'
  tertiary-fixed-dim: '#c8c6c5'
  on-tertiary-fixed: '#1b1c1c'
  on-tertiary-fixed-variant: '#474746'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
  bg-gray: '#EFECEC'
  border-slate: '#E2E8F0'
  black-charcoal: '#222222'
typography:
  display-lg:
    fontFamily: Bricolage Grotesque
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Bricolage Grotesque
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Bricolage Grotesque
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Bricolage Grotesque
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Bricolage Grotesque
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-bold:
    fontFamily: Bricolage Grotesque
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
  display-lg-mobile:
    fontFamily: Bricolage Grotesque
    fontSize: 28px
    fontWeight: '800'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-page: 16px
  gutter-grid: 12px
  appbar-padding: 12px
  stack-gap: 16px
  inner-padding: 12px
---

## Brand & Style

The design system embodies a **Neo-Brutalist** aesthetic tailored for a high-impact mobile experience. It is characterized by high-contrast visuals, heavy structural lines, and a raw, "built-to-last" digital atmosphere. The target audience—active members and administrators—requires a UI that is both assertive and functional.

**Key visual drivers:**
- **Bold Structure:** Thick 2px black borders on all interactive and container elements.
- **Flat Depth:** Reliance on hard, non-blurred shadows (offset shadows) rather than organic lighting to create hierarchy.
- **Intentional Friction:** High-contrast color blocks that clearly delineate different functional zones.
- **Playful Rigidity:** A mix of strict geometric layouts with "bouncy" tactile feedback to soften the industrial tone.

## Colors

The palette is anchored by **POLICY Red**, a high-energy primary color used for critical actions and brand presence. The system operates strictly in **light mode** to maximize the impact of the black structural lines.

- **Primary (#DC3545):** Used for "destructive" actions, primary buttons, and critical branding.
- **Success (#198754):** Reserved for positive statuses, "Lunas" indicators, and completion states.
- **Charcoal (#222222):** The structural backbone. Used for all text, heavy 2px borders, and hard shadows.
- **Background (#EFECEC):** A cool light gray that provides enough contrast for white cards to pop without the harshness of pure white.

## Typography

This design system uses **Bricolage Grotesque** across all levels to maintain the quirky, expressive nature of Neo-Brutalism. The typeface's unique terminals and variable widths provide the "character" needed for a standout brand identity.

- **Scale:** High contrast between display titles and body text.
- **Weight:** Headings should always be Bold (700) or ExtraBold (800) to stand up against the thick 2px borders of the UI.
- **Labels:** Small labels use heavy weights and slight letter spacing to ensure legibility despite the expressive font style.

## Layout & Spacing

The layout follows a **fluid-to-safe-margin** model, prioritizing the mobile viewport.

- **Floating Architecture:** The AppBar and Bottom Navbar do not touch the screen edges. They maintain a 12px-16px margin from all sides, creating a "card-on-canvas" feel.
- **Structural Dividers:** Sections are separated by "MyDivider"—a custom dotted or dashed line that reinforces the technical, "in-progress" look of Brutalism.
- **Safe Zones:** A standard 16px margin is maintained at the page level to prevent content from crowding the device edges.

## Elevation & Depth

Standard Gaussian blurs and soft shadows are prohibited. Depth is achieved through **Hard Shadow Offsets**:

- **Hard Shadows:** Use a solid Charcoal (#222222) block offset by 4px (X) and 4px (Y). This gives cards a "lifted sticker" effect.
- **Tonal Layering:** White (#FFFFFF) cards sit atop the Light Gray (#EFECEC) background.
- **Structural Borders:** Every elevated element must have a 2px solid Charcoal border to define its bounds.
- **Active State:** On tap (BounceTapper), the shadow offset should reduce to 0px or 1px as the element "depresses" into the page.

## Shapes

The shape language balances Brutalist aggression with mobile friendliness.

- **Corner Radius:** A consistent 0.5rem (8px) is the standard.
- **Navigational Elements:** The Floating Appbar and Bottom Navbar use a more aggressive 16px to 30px radius (Pill-shaped) to distinguish them from content cards.
- **Buttons:** Match the 16px radius of the Appbar to create a cohesive interactive language.

## Components

### Buttons
- **Primary:** #DC3545 background, #FFFFFF text, 2px Charcoal border, Hard Shadow.
- **Interaction:** Must use the `BounceTapper` effect (5% scale reduction).
- **Secondary:** #FFFFFF background, #222222 text, 2px Charcoal border.

### Cards
- **Style:** White background, 2px Charcoal border, 4px Hard Shadow (Charcoal).
- **Header:** Often separated from the body by a dotted `MyDivider`.

### Input Fields
- **Background:** #F6F8FA (Light gray-blue tint).
- **Border:** 2px Charcoal border on focus; 1px Slate-200 border when inactive.
- **Labels:** Bold Bricolage Grotesque (12pt) sitting directly above the field.

### Navigation
- **Floating Appbar:** 16px radius, white background, 2px border, hovering 12px from the top.
- **Bottom Navbar:** 30px radius (capsule), white background, 2px border, hovering 16px from the bottom.

### Dividers (MyDivider)
- **Visual:** Dotted or Dashed lines using the Slate-200 or Charcoal color. Avoid solid lines for section breaks to maintain the Neo-Brutalist character.