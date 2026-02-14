# LVGL-Nix Theme Generator
# Generates lv_theme_nix.c from a theme configuration
# Follows stock LVGL theme pattern (lv_theme_default.c)
{ pkgs, themeConfig }:

let
  c = themeConfig.colors;
  s = themeConfig.sizing;
  st = themeConfig.states;
  t = themeConfig.transitions;

  # Convert hex string to C literal
  hex = color: "0x${color}";

  # Dark mode flag for C
  darkModeFlag = if themeConfig.darkMode then "1" else "0";

in pkgs.writeText "lv_theme_nix.c" ''
/**
 * @file lv_theme_nix.c
 * LVGL-Nix Generated Theme
 * Auto-generated from Nix theme configuration
 * Dark mode: ${if themeConfig.darkMode then "yes" else "no"}
 */

/*********************
 *      INCLUDES
 *********************/
#include "lvgl.h"

#if LV_USE_THEME_NIX

#include "../lv_theme_private.h"
#include "../../core/lv_global.h"

/*********************
 *      DEFINES
 *********************/

#define MODE_DARK 1
#define theme_def (*(nix_theme_t **)(&LV_GLOBAL_DEFAULT()->theme_nix))

/**********************
 *      TYPEDEFS
 **********************/

typedef struct {
    lv_style_t scr;
    lv_style_t container;
    lv_style_t card;
    lv_style_t btn;
    lv_style_t scrollbar;
    lv_style_t scrollbar_active;
    lv_style_t hovered;
    lv_style_t pressed;
    lv_style_t disabled;
    lv_style_t focus;
    lv_style_t ta_cursor;
    lv_style_t ta_placeholder;
} nix_theme_styles_t;

typedef struct {
    lv_theme_t base;
    nix_theme_styles_t styles;
    bool inited;
} nix_theme_t;

/**********************
 *  STATIC PROTOTYPES
 **********************/

static void style_init(nix_theme_t * theme);
static void style_init_reset(lv_style_t * style);
static void theme_apply(lv_theme_t * th, lv_obj_t * obj);

/**********************
 *   STYLE INIT
 **********************/

static void style_init(nix_theme_t * theme)
{
    /* Screen style - transparent for GPU compositing (web content texture behind) */
    style_init_reset(&theme->styles.scr);
    lv_style_set_bg_opa(&theme->styles.scr, LV_OPA_TRANSP);
    lv_style_set_bg_color(&theme->styles.scr, lv_color_hex(${hex c.bg_prim}));
    lv_style_set_text_color(&theme->styles.scr, lv_color_hex(${hex c.text_pri}));

    /* Container style (transparent layout containers) */
    style_init_reset(&theme->styles.container);
    lv_style_set_bg_opa(&theme->styles.container, LV_OPA_TRANSP);
    lv_style_set_border_width(&theme->styles.container, 0);
    lv_style_set_radius(&theme->styles.container, 0);

    /* Card style (containers, inputs) */
    style_init_reset(&theme->styles.card);
    lv_style_set_bg_opa(&theme->styles.card, LV_OPA_COVER);
    lv_style_set_bg_color(&theme->styles.card, lv_color_hex(${hex c.bg_sec}));
    lv_style_set_text_color(&theme->styles.card, lv_color_hex(${hex c.text_pri}));
    lv_style_set_border_color(&theme->styles.card, lv_color_hex(${hex c.bg_ter}));
    lv_style_set_border_width(&theme->styles.card, ${toString s.borderWidth});
    lv_style_set_radius(&theme->styles.card, ${toString s.radius});
    lv_style_set_pad_all(&theme->styles.card, ${toString s.padding});
    // lv_style_set_pad_row(&theme->styles.card, ${toString s.gap});
    // lv_style_set_pad_column(&theme->styles.card, ${toString s.gap});

    /* Button style (blends with background) */
    style_init_reset(&theme->styles.btn);
    lv_style_set_bg_opa(&theme->styles.btn, LV_OPA_COVER);
    lv_style_set_bg_color(&theme->styles.btn, lv_color_hex(${hex c.bg_prim}));
    lv_style_set_text_color(&theme->styles.btn, lv_color_hex(${hex c.text_pri}));
    lv_style_set_radius(&theme->styles.btn, ${toString s.radius});
    lv_style_set_pad_all(&theme->styles.btn, ${toString s.padding});

    /* Scrollbar style (thumb) */
    style_init_reset(&theme->styles.scrollbar);
    lv_style_set_bg_opa(&theme->styles.scrollbar, ${toString st.scrollbarOpa});
    lv_style_set_bg_color(&theme->styles.scrollbar, lv_color_hex(${hex c.bg_sec}));
    lv_style_set_radius(&theme->styles.scrollbar, LV_RADIUS_CIRCLE);
    lv_style_set_pad_all(&theme->styles.scrollbar, ${toString s.scrollbarPadding});
    lv_style_set_width(&theme->styles.scrollbar, ${toString s.scrollbarWidth});

    /* Scrollbar active (while scrolling) */
    style_init_reset(&theme->styles.scrollbar_active);
    lv_style_set_bg_opa(&theme->styles.scrollbar_active, ${toString st.scrollbarActive});
    lv_style_set_bg_color(&theme->styles.scrollbar_active, lv_color_hex(${hex c.bg_ter}));

    /* Hovered state */
    style_init_reset(&theme->styles.hovered);
    lv_style_set_bg_color(&theme->styles.hovered, lv_color_hex(${hex c.bg_sec}));

    /* Pressed state */
    style_init_reset(&theme->styles.pressed);
    lv_style_set_recolor(&theme->styles.pressed, lv_color_black());
    lv_style_set_recolor_opa(&theme->styles.pressed, ${toString st.pressedRecolor});

    /* Disabled state */
    style_init_reset(&theme->styles.disabled);
    lv_style_set_recolor(&theme->styles.disabled, lv_color_hex(${hex c.bg_ter}));
    lv_style_set_recolor_opa(&theme->styles.disabled, ${toString st.disabledOpa});

    /* Focus outline */
    style_init_reset(&theme->styles.focus);
    lv_style_set_outline_color(&theme->styles.focus, lv_color_hex(${hex c.accent}));
    lv_style_set_outline_width(&theme->styles.focus, ${toString s.outlineWidth});
    lv_style_set_outline_pad(&theme->styles.focus, ${toString s.outlineWidth});
    lv_style_set_outline_opa(&theme->styles.focus, ${toString st.outlineOpa});

    /* Textarea cursor */
    style_init_reset(&theme->styles.ta_cursor);
    lv_style_set_border_color(&theme->styles.ta_cursor, lv_color_hex(${hex c.accent}));
    lv_style_set_border_width(&theme->styles.ta_cursor, 2);
    lv_style_set_border_side(&theme->styles.ta_cursor, LV_BORDER_SIDE_LEFT);
    lv_style_set_anim_duration(&theme->styles.ta_cursor, 500);

    /* Textarea placeholder */
    style_init_reset(&theme->styles.ta_placeholder);
    lv_style_set_text_color(&theme->styles.ta_placeholder, lv_color_hex(${hex c.text_sec}));
}

/**********************
 *   THEME APPLY
 **********************/

static void theme_apply(lv_theme_t * th, lv_obj_t * obj)
{
    LV_UNUSED(th);

    nix_theme_t * theme = theme_def;
    lv_obj_t * parent = lv_obj_get_parent(obj);

    /* Screen (root object) */
    if(parent == NULL) {
        lv_obj_add_style(obj, &theme->styles.scr, 0);
        lv_obj_add_style(obj, &theme->styles.scrollbar, LV_PART_SCROLLBAR);
        return;
    }

    /* Button */
    if(lv_obj_check_type(obj, &lv_button_class)) {
        lv_obj_add_style(obj, &theme->styles.btn, 0);
        lv_obj_add_style(obj, &theme->styles.hovered, LV_STATE_HOVERED);
        lv_obj_add_style(obj, &theme->styles.pressed, LV_STATE_PRESSED);
        lv_obj_add_style(obj, &theme->styles.disabled, LV_STATE_DISABLED);
        lv_obj_add_style(obj, &theme->styles.focus, LV_STATE_FOCUS_KEY);
        return;
    }

    /* Textarea */
    if(lv_obj_check_type(obj, &lv_textarea_class)) {
        lv_obj_add_style(obj, &theme->styles.card, 0);
        lv_obj_add_style(obj, &theme->styles.scrollbar, LV_PART_SCROLLBAR);
        lv_obj_add_style(obj, &theme->styles.scrollbar_active, LV_PART_SCROLLBAR | LV_STATE_SCROLLED);
        lv_obj_add_style(obj, &theme->styles.ta_cursor, LV_PART_CURSOR | LV_STATE_FOCUSED);
        lv_obj_add_style(obj, &theme->styles.ta_placeholder, LV_PART_TEXTAREA_PLACEHOLDER);
        lv_obj_add_style(obj, &theme->styles.focus, LV_STATE_FOCUS_KEY);
        return;
    }

    /* Label - inherit from parent, nothing to add */
    if(lv_obj_check_type(obj, &lv_label_class)) {
        return;
    }

    /* Generic lv_obj: apply transparent container style */
    lv_obj_add_style(obj, &theme->styles.container, 0);
    lv_obj_add_style(obj, &theme->styles.scrollbar, LV_PART_SCROLLBAR);
    lv_obj_add_style(obj, &theme->styles.scrollbar_active, LV_PART_SCROLLBAR | LV_STATE_SCROLLED);
}

/**********************
 *   STATIC FUNCTIONS
 **********************/

static void style_init_reset(lv_style_t * style)
{
    if(lv_theme_nix_is_inited()) {
        lv_style_reset(style);
    }
    else {
        lv_style_init(style);
    }
}

/**********************
 *   PUBLIC FUNCTIONS
 **********************/

lv_theme_t * lv_theme_nix_init(void)
{
    if(!lv_theme_nix_is_inited()) {
        theme_def = lv_malloc_zeroed(sizeof(nix_theme_t));
        LV_ASSERT_MALLOC(theme_def);
    }

    nix_theme_t * theme = theme_def;

    theme->base.disp = NULL;
    theme->base.color_primary = lv_color_hex(${hex c.accent});
    theme->base.color_secondary = lv_color_hex(${hex c.accent});
    theme->base.font_small = LV_FONT_DEFAULT;
    theme->base.font_normal = LV_FONT_DEFAULT;
    theme->base.font_large = LV_FONT_DEFAULT;
    theme->base.apply_cb = theme_apply;
    theme->base.flags = ${darkModeFlag};

    style_init(theme);

    theme->inited = true;

    return &theme->base;
}

bool lv_theme_nix_is_inited(void)
{
    nix_theme_t * theme = theme_def;
    if(theme == NULL) return false;
    return theme->inited;
}

lv_theme_t * lv_theme_nix_get(void)
{
    if(!lv_theme_nix_is_inited()) {
        return NULL;
    }
    return (lv_theme_t *)theme_def;
}

void lv_theme_nix_deinit(void)
{
    nix_theme_t * theme = theme_def;
    if(theme) {
        if(theme->inited) {
            lv_style_t * theme_styles = (lv_style_t *)(&(theme->styles));
            uint32_t i;
            for(i = 0; i < sizeof(nix_theme_styles_t) / sizeof(lv_style_t); i++) {
                lv_style_reset(theme_styles + i);
            }
        }
        lv_free(theme_def);
        theme_def = NULL;
    }
}

#endif /* LV_USE_THEME_NIX */
''
