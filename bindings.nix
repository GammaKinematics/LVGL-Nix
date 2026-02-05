# LVGL Odin Bindings - Declarative specification
# Types are auto-parsed from LVGL headers
{ lvglSrc }:
{
  # C to Odin type mapping
  typeMap = {
    # Primitives
    "void" = "void";
    "bool" = "bool";
    "char" = "u8";
    "int" = "i32";
    "unsigned" = "u32";
    "unsigned int" = "u32";
    "float" = "f32";
    "double" = "f64";

    # Fixed-width integers
    "int8_t" = "i8";
    "int16_t" = "i16";
    "int32_t" = "i32";
    "int64_t" = "i64";
    "uint8_t" = "u8";
    "uint16_t" = "u16";
    "uint32_t" = "u32";
    "uint64_t" = "u64";
    "size_t" = "uint";

    # Strings
    "char *" = "cstring";
    "const char *" = "cstring";
    "char const *" = "cstring";  # Alternative order

    # Void pointers
    "void *" = "rawptr";
    "const void *" = "rawptr";
    "void const *" = "rawptr";  # Alternative order

    # Image descriptor (const pointer)
    "lv_image_dsc_t const *" = "^lv_image_dsc_t";
    "const lv_image_dsc_t *" = "^lv_image_dsc_t";

    # Internal/external types (not LVGL public API)
    "struct _lv_obj_t" = "lv_obj_t";
    "struct _lv_obj_t *" = "^lv_obj_t";
    "struct _lv_display_t *" = "^lv_display_t";
    "GLFWwindow *" = "rawptr";  # External GLFW type
  };

  # Typedefs - parsed from headers
  typedefs = [
    { name = "lv_opa_t"; header = "src/misc/lv_types.h"; }
    { name = "lv_style_selector_t"; header = "src/core/lv_obj_style.h"; }
    { name = "lv_anim_enable_t"; header = "src/misc/lv_anim.h"; }
  ];

  # Opaque types - only used via pointers, no field access
  opaqueTypes = [
    "lv_obj_t"
    "lv_display_t"
    "lv_indev_t"
    "lv_group_t"
    "lv_event_t"
    "lv_event_dsc_t"
    "lv_anim_t"
    "lv_timer_t"
    "lv_font_t"
    "lv_style_t"
    "lv_theme_t"
    "lv_draw_buf_t"
    "lv_opengles_window_t"
    "lv_opengles_window_texture_t"
    "lv_image_dsc_t"
  ];

  # Enums - parsed from headers
  enums = [
    { name = "lv_result_t"; header = "src/misc/lv_types.h"; }
    { name = "lv_state_t"; header = "src/core/lv_obj_style.h"; }
    { name = "lv_part_t"; header = "src/core/lv_obj_style.h"; }
    { name = "lv_obj_flag_t"; header = "src/core/lv_obj.h"; }
    { name = "lv_align_t"; header = "src/misc/lv_area.h"; }
    { name = "lv_flex_flow_t"; header = "src/layouts/flex/lv_flex.h"; }
    { name = "lv_flex_align_t"; header = "src/layouts/flex/lv_flex.h"; }
    { name = "lv_event_code_t"; header = "src/misc/lv_event.h"; }
    { name = "lv_text_align_t"; header = "src/misc/lv_text.h"; }
    { name = "lv_label_long_mode_t"; header = "src/widgets/label/lv_label.h"; }
    # Input device
    { name = "lv_indev_type_t"; header = "src/indev/lv_indev.h"; }
    { name = "lv_indev_state_t"; header = "src/indev/lv_indev.h"; }
    { name = "lv_indev_mode_t"; header = "src/indev/lv_indev.h"; }
    { name = "lv_key_t"; header = "src/core/lv_group.h"; }
  ];

  # Structs - parsed from headers
  structs = [
    { name = "lv_color_t"; header = "src/misc/lv_color.h"; }
    { name = "lv_color32_t"; header = "src/misc/lv_color.h"; }
    { name = "lv_area_t"; header = "src/misc/lv_area.h"; }
    { name = "lv_point_t"; header = "src/misc/lv_area.h"; }
  ];

  # Macros - pattern matched from headers
  macros = [
    { pattern = "LV_FLEX_(COLUMN|WRAP|REVERSE)"; header = "src/layouts/flex/lv_flex.h"; }
    { pattern = "LV_SYMBOL_[A-Z_]+"; header = "src/font/lv_symbol_def.h"; }
    { pattern = "LV_COORD_TYPE_SHIFT"; header = "src/misc/lv_area.h"; }
    { pattern = "LV_COORD_TYPE_SPEC"; header = "src/misc/lv_area.h"; }
    { pattern = "LV_COORD_MAX"; header = "src/misc/lv_area.h"; }
  ];

  # Functions - parsed from headers
  functions = [
    # Core / Init
    { name = "lv_init"; header = "src/lv_init.h"; }
    { name = "lv_deinit"; header = "src/lv_init.h"; }
    { name = "lv_timer_handler"; header = "src/misc/lv_timer.h"; }
    { name = "lv_tick_inc"; header = "src/tick/lv_tick.h"; }

    # Display
    { name = "lv_display_get_default"; header = "src/display/lv_display.h"; }
    { name = "lv_display_set_default"; header = "src/display/lv_display.h"; }
    { name = "lv_display_get_horizontal_resolution"; header = "src/display/lv_display.h"; }
    { name = "lv_display_get_vertical_resolution"; header = "src/display/lv_display.h"; }
    { name = "lv_display_get_screen_active"; header = "src/display/lv_display.h"; }
    { name = "lv_display_delete"; header = "src/display/lv_display.h"; }
    { name = "lv_screen_active"; header = "src/display/lv_display.h"; }
    { name = "lv_screen_load"; header = "src/display/lv_display.h"; }
    { name = "lv_display_set_theme"; header = "src/display/lv_display.h"; }
    { name = "lv_display_set_color_format"; header = "src/display/lv_display.h"; }

    # Themes
    { name = "lv_theme_create"; header = "src/themes/lv_theme.h"; }
    { name = "lv_theme_set_apply_cb"; header = "src/themes/lv_theme.h"; }

    # OpenGL ES Window
    { name = "lv_opengles_glfw_window_create"; header = "src/drivers/opengles/lv_opengles_glfw.h"; }
    { name = "lv_opengles_glfw_window_set_title"; header = "src/drivers/opengles/lv_opengles_glfw.h"; }
    { name = "lv_opengles_glfw_window_get_glfw_window"; header = "src/drivers/opengles/lv_opengles_glfw.h"; }
    { name = "lv_opengles_window_display_create"; header = "src/drivers/opengles/lv_opengles_window.h"; }
    { name = "lv_opengles_texture_create"; header = "src/drivers/opengles/lv_opengles_texture.h"; }
    { name = "lv_opengles_texture_get_texture_id"; header = "src/drivers/opengles/lv_opengles_texture.h"; }
    { name = "lv_opengles_window_add_texture"; header = "src/drivers/opengles/lv_opengles_window.h"; }
    { name = "lv_opengles_window_texture_remove"; header = "src/drivers/opengles/lv_opengles_window.h"; }
    { name = "lv_opengles_window_texture_set_x"; header = "src/drivers/opengles/lv_opengles_window.h"; }
    { name = "lv_opengles_window_texture_set_y"; header = "src/drivers/opengles/lv_opengles_window.h"; }
    { name = "lv_opengles_window_texture_set_opa"; header = "src/drivers/opengles/lv_opengles_window.h"; }
    { name = "lv_opengles_texture_create_from_texture_id"; header = "src/drivers/opengles/lv_opengles_texture.h"; }

    # Object Core
    { name = "lv_obj_create"; header = "src/core/lv_obj.h"; }
    { name = "lv_obj_delete"; header = "src/core/lv_obj_tree.h"; }
    { name = "lv_obj_clean"; header = "src/core/lv_obj_tree.h"; }
    { name = "lv_obj_set_parent"; header = "src/core/lv_obj_tree.h"; }
    { name = "lv_obj_get_parent"; header = "src/core/lv_obj_tree.h"; }

    # Object Size / Position
    { name = "lv_obj_set_size"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_set_width"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_set_height"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_set_pos"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_set_x"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_set_y"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_set_align"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_align"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_center"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_get_width"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_get_height"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_get_x"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_obj_get_y"; header = "src/core/lv_obj_pos.h"; }

    # Object Flags
    { name = "lv_obj_add_flag"; header = "src/core/lv_obj.h"; }
    { name = "lv_obj_remove_flag"; header = "src/core/lv_obj.h"; }
    { name = "lv_obj_has_flag"; header = "src/core/lv_obj.h"; }

    # Object State
    { name = "lv_obj_add_state"; header = "src/core/lv_obj.h"; }
    { name = "lv_obj_remove_state"; header = "src/core/lv_obj.h"; }
    { name = "lv_obj_has_state"; header = "src/core/lv_obj.h"; }

    # Events
    { name = "lv_obj_add_event_cb"; header = "src/core/lv_obj_event.h"; }
    { name = "lv_event_get_code"; header = "src/misc/lv_event.h"; }
    { name = "lv_event_get_target"; header = "src/misc/lv_event.h"; }
    { name = "lv_event_get_user_data"; header = "src/misc/lv_event.h"; }

    # Flex Layout
    { name = "lv_obj_set_flex_flow"; header = "src/layouts/flex/lv_flex.h"; }
    { name = "lv_obj_set_flex_align"; header = "src/layouts/flex/lv_flex.h"; }
    { name = "lv_obj_set_flex_grow"; header = "src/layouts/flex/lv_flex.h"; }

    # Styling
    { name = "lv_obj_set_style_bg_color"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_bg_opa"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_text_color"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_text_font"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_radius"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_border_color"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_border_width"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_pad_top"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_pad_bottom"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_pad_left"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_pad_right"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_pad_row"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_pad_column"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_layout"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_outline_width"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_outline_color"; header = "src/core/lv_obj_style_gen.h"; }
    { name = "lv_obj_set_style_outline_opa"; header = "src/core/lv_obj_style_gen.h"; }

    # Coordinate helpers
    { name = "lv_pct"; header = "src/misc/lv_area.h"; }

    # Color helpers
    { name = "lv_color_hex"; header = "src/misc/lv_color.h"; }
    { name = "lv_color_make"; header = "src/misc/lv_color.h"; }
    { name = "lv_color_white"; header = "src/misc/lv_color.h"; }
    { name = "lv_color_black"; header = "src/misc/lv_color.h"; }

    # Widgets: Label
    { name = "lv_label_create"; header = "src/widgets/label/lv_label.h"; }
    { name = "lv_label_set_text"; header = "src/widgets/label/lv_label.h"; }
    { name = "lv_label_set_text_static"; header = "src/widgets/label/lv_label.h"; }
    { name = "lv_label_get_text"; header = "src/widgets/label/lv_label.h"; }
    { name = "lv_label_set_long_mode"; header = "src/widgets/label/lv_label.h"; }

    # Widgets: Button
    { name = "lv_button_create"; header = "src/widgets/button/lv_button.h"; }

    # Widgets: Textarea
    { name = "lv_textarea_create"; header = "src/widgets/textarea/lv_textarea.h"; }
    { name = "lv_textarea_set_text"; header = "src/widgets/textarea/lv_textarea.h"; }
    { name = "lv_textarea_get_text"; header = "src/widgets/textarea/lv_textarea.h"; }
    { name = "lv_textarea_set_placeholder_text"; header = "src/widgets/textarea/lv_textarea.h"; }
    { name = "lv_textarea_set_one_line"; header = "src/widgets/textarea/lv_textarea.h"; }
    { name = "lv_textarea_set_password_mode"; header = "src/widgets/textarea/lv_textarea.h"; }
    { name = "lv_textarea_add_char"; header = "src/widgets/textarea/lv_textarea.h"; }
    { name = "lv_textarea_add_text"; header = "src/widgets/textarea/lv_textarea.h"; }
    { name = "lv_textarea_delete_char"; header = "src/widgets/textarea/lv_textarea.h"; }
    { name = "lv_textarea_delete_char_forward"; header = "src/widgets/textarea/lv_textarea.h"; }

    # Widgets: Image
    { name = "lv_image_create"; header = "src/widgets/image/lv_image.h"; }
    { name = "lv_image_set_src"; header = "src/widgets/image/lv_image.h"; }
    { name = "lv_image_set_scale"; header = "src/widgets/image/lv_image.h"; }
    { name = "lv_image_set_rotation"; header = "src/widgets/image/lv_image.h"; }

    # Scrolling
    { name = "lv_obj_scroll_to"; header = "src/core/lv_obj_scroll.h"; }
    { name = "lv_obj_scroll_by"; header = "src/core/lv_obj_scroll.h"; }
    { name = "lv_obj_get_scroll_x"; header = "src/core/lv_obj_scroll.h"; }
    { name = "lv_obj_get_scroll_y"; header = "src/core/lv_obj_scroll.h"; }

    # Invalidation / Redraw
    { name = "lv_obj_invalidate"; header = "src/core/lv_obj_pos.h"; }
    { name = "lv_refr_now"; header = "src/core/lv_refr.h"; }

    # Input Device
    { name = "lv_indev_create"; header = "src/indev/lv_indev.h"; }
    { name = "lv_indev_delete"; header = "src/indev/lv_indev.h"; }
    { name = "lv_indev_set_type"; header = "src/indev/lv_indev.h"; }
    { name = "lv_indev_set_read_cb"; header = "src/indev/lv_indev.h"; }
    { name = "lv_indev_set_driver_data"; header = "src/indev/lv_indev.h"; }
    { name = "lv_indev_get_driver_data"; header = "src/indev/lv_indev.h"; }
    { name = "lv_indev_set_display"; header = "src/indev/lv_indev.h"; }
    { name = "lv_indev_set_group"; header = "src/indev/lv_indev.h"; }
    { name = "lv_indev_set_mode"; header = "src/indev/lv_indev.h"; }
    { name = "lv_indev_read"; header = "src/indev/lv_indev.h"; }

    # Groups (keyboard navigation)
    { name = "lv_group_create"; header = "src/core/lv_group.h"; }
    { name = "lv_group_delete"; header = "src/core/lv_group.h"; }
    { name = "lv_group_add_obj"; header = "src/core/lv_group.h"; }
    { name = "lv_group_remove_obj"; header = "src/core/lv_group.h"; }
    { name = "lv_group_focus_obj"; header = "src/core/lv_group.h"; }
    { name = "lv_group_get_focused"; header = "src/core/lv_group.h"; }
    { name = "lv_group_send_data"; header = "src/core/lv_group.h"; }
    { name = "lv_group_set_editing"; header = "src/core/lv_group.h"; }
    { name = "lv_group_get_editing"; header = "src/core/lv_group.h"; }
  ];

  # Type aliases
  aliases = {
    lv_event_cb_t = "proc \"c\" (e: ^lv_event_t)";
    lv_theme_apply_cb_t = "proc \"c\" (theme: ^lv_theme_t, obj: ^lv_obj_t)";
    lv_indev_read_cb_t = "proc \"c\" (indev: ^lv_indev_t, data: ^lv_indev_data_t)";
  };

  # Manual additions - raw Odin code appended as-is
  manual = ''
    // === Size Constants ===
    // LV_SIZE_CONTENT = LV_COORD_SET_SPEC(LV_COORD_MAX) = LV_COORD_MAX | LV_COORD_TYPE_SPEC
    LV_SIZE_CONTENT :: LV_COORD_MAX | LV_COORD_TYPE_SPEC

    // === Opacity Constants ===
    LV_OPA_TRANSP : u8 : 0
    LV_OPA_COVER  : u8 : 255

    // === Color Format (subset — auto-gen chokes on hex literals) ===
    lv_color_format_t :: enum i32 {
        LV_COLOR_FORMAT_UNKNOWN          = 0x00,
        LV_COLOR_FORMAT_RGB565           = 0x03,
        LV_COLOR_FORMAT_RGB888           = 0x0F,
        LV_COLOR_FORMAT_ARGB8888         = 0x10,
        LV_COLOR_FORMAT_XRGB8888         = 0x11,
    }

    // === Input Device Data ===
    lv_indev_data_t :: struct {
        point: lv_point_t,
        key: u32,
        btn_id: u32,
        enc_diff: i16,
        state: lv_indev_state_t,
    }
  '';
}
