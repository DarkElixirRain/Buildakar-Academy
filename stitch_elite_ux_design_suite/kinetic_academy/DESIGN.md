---
name: Kinetic Academy
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#424754'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#727785'
  outline-variant: '#c2c6d6'
  surface-tint: '#005ac2'
  primary: '#0058be'
  on-primary: '#ffffff'
  primary-container: '#2170e4'
  on-primary-container: '#fefcff'
  inverse-primary: '#adc6ff'
  secondary: '#a73a00'
  on-secondary: '#ffffff'
  secondary-container: '#fd651e'
  on-secondary-container: '#571a00'
  tertiary: '#924700'
  on-tertiary: '#ffffff'
  tertiary-container: '#b75b00'
  on-tertiary-container: '#fffbff'
  error: '#DC2626'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#ffdbce'
  secondary-fixed-dim: '#ffb599'
  on-secondary-fixed: '#370e00'
  on-secondary-fixed-variant: '#7f2b00'
  tertiary-fixed: '#ffdcc6'
  tertiary-fixed-dim: '#ffb786'
  on-tertiary-fixed: '#311400'
  on-tertiary-fixed-variant: '#723600'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
  background-light: '#F8FAFC'
  background-dark: '#0B1220'
  surface-light: '#FFFFFF'
  surface-dark: '#151E2E'
  text-primary-light: '#0F172A'
  text-primary-dark: '#F1F5F9'
  border-light: '#E2E8F0'
  border-dark: '#263349'
typography:
  display-lg:
    fontFamily: Sora
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  display-lg-mobile:
    fontFamily: Sora
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Sora
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Sora
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
  numeric-tabular:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  margin-screen: 16px
  gutter-grid: 12px
  section-gap: 24px
  target-min: 44px
  nav-bar-h: 64px
---

## Brand & Style

The design system for this learning platform is anchored in a **Corporate Modern** aesthetic with high-performance, mobile-first sensibilities. It rejects generic "AI-wrapper" visuals in favor of a bespoke, technical atmosphere that feels both academic and professional. 

The brand personality is **energetic, precise, and authoritative**. By combining geometric precision with warm, legible typography, the UI creates a "Learn. Build. Achieve." workflow that feels like a premium engineering environment rather than a standard social feed. Visual interest is driven by semantic color usage and a "Bento" layout logic that organizes complex educational data into digestible, high-contrast modules.

## Colors

The palette is designed for high functional contrast. **Electric Blue** serves as the primary engine for navigation and standard interaction, while **Burnt Orange** is strictly reserved for high-urgency conversions and live states.

### Color Modes
- **Light Mode**: Utilizes a slate-tinted off-white background (`#F8FAFC`) to reduce eye strain compared to pure white.
- **Dark Mode**: Employs a deep navy navy (`#0B1220`) with surfaces that rise in value to create depth. For Dark Mode, brand colors (Blue and Orange) should be increased by **8% brightness** to maintain WCAG accessibility on dark surfaces.

### Semantic Gradients
- **Premium/Action Gradient**: `135deg, #EA580C to #D16900`. 
- **Restriction**: Do not mix Primary Blue and Secondary Orange in gradients; they must remain distinct to separate "Navigation" from "Critical Action."

## Typography

This system uses a dual-font strategy to balance technical precision with user warmth.

- **Headings (Sora)**: Geometric and confident. Used for page titles, section headers, and prominent wordmarks.
- **Body & UI (Plus Jakarta Sans)**: Highly legible at small sizes. Used for all interactive components, descriptions, and metadata.
- **Specialty Styles**: 
    - **Labels**: Small uppercase labels use 0.5px tracking to improve legibility on mobile screens.
    - **Numerals**: Always utilize **tabular figures** (monospaced numbers) for prices, ratings, and countdown timers to prevent horizontal layout shift.

## Layout & Spacing

The layout follows a **Mobile-First Fluid Grid** with a strict 4px/8px baseline rhythm. 

- **Grid Logic**: Uses a "Bento Box" grouping method—asymmetric containers that snap to a 12px gutter.
- **Mobile Safe Zones**: Screen margins are fixed at 16px. Vertical sections are separated by 24px to ensure content breathability.
- **Interactive Targets**: Every interactive element must adhere to a minimum 44x44px tap target, even if the visual asset is smaller. 
- **Transitions**: When transitioning from list to detail, use shared element transitions (280ms ease-out) to morph thumbnails into header images.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and **1px Hairline Borders** rather than heavy shadows.

- **Hairline Borders**: 1px solid borders (`#E2E8F0` in light mode) define the boundaries of cards and inputs, providing a "technical drawing" feel.
- **Shadows**: Only one standard shadow is permitted: `0 2px 8px rgba(15, 23, 42, 0.04)`. This is a "barely-there" lift for active cards.
- **Focused Elevation**: For active inputs or focused buttons, replace the 1px hairline with a 2px Primary Blue border.
- **Glassmorphism**: Restricted exclusively to video player controls and "Live Now" status overlays to imply transparency over active content.

## Shapes

The shape language is structured to reflect component scale and hierarchy:
- **8px (Small)**: Used for chips, tags, and status badges.
- **12px (Default)**: Standard for buttons, input fields, and video thumbnails.
- **16px (Large)**: Used for content cards and container modules.
- **24px (Sheet)**: Reserved for bottom sheets and top-level modal containers.

All icons must be part of a custom 1.5px stroke-weight set with rounded caps and 2px "nub" terminals to maintain visual alignment with the soft-rounded corners of the UI.

## Components

### Buttons
- **Primary**: 48px height, 12px radius. Background: Primary Blue. Text: White. 
- **CTA/Premium**: Background: Secondary Gradient (Orange/Amber). Scale down to 0.97 on press.
- **Ghost**: 1.5px stroke Primary Blue or Slate for secondary actions.

### Cards
- **Container**: 16px radius, 1px hairline border, standard soft shadow.
- **Surface**: Background matches the mode's surface color (`#FFFFFF` or `#151E2E`).
- **Interaction**: On tap, provide a subtle background ripple rather than an elevation lift.

### Input Fields
- **Default**: 48px height, 12px radius, 1px Slate border. 
- **Focus**: 2px Primary Blue border.
- **OTP/Verification**: Fixed size 44x52px boxes with centered 600-weight Sora text.

### Chips & Badges
- **Live Badge**: Secondary Orange background, "Live" text in white, subtle pulse animation.
- **Category Chips**: 8px radius, Slate background at 10% opacity, 14px Plus Jakarta Sans text.

### Icons
- **Weight**: 1.5px consistent stroke.
- **Active State**: Primary Blue stroke with a 20% opacity filled background of the same hue (Duotone effect).