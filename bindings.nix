# LVGL Odin Bindings - Declarative specification
# Types use Odin syntax, pointers are ^Type
{
  # Opaque types (forward declarations)
  opaqueTypes = [
    "lv_obj_t"
    "lv_display_t"
    "lv_indev_t"
    "lv_group_t"
    "lv_event_t"
    "lv_anim_t"
    "lv_timer_t"
    "lv_font_t"
    "lv_style_t"
    "lv_theme_t"
    "lv_draw_buf_t"
  ];

  # Enums
  enums = {
    lv_flex_flow_t = [
      "LV_FLEX_FLOW_ROW"
      "LV_FLEX_FLOW_COLUMN"
      "LV_FLEX_FLOW_ROW_WRAP"
      "LV_FLEX_FLOW_COLUMN_WRAP"
      "LV_FLEX_FLOW_ROW_REVERSE"
      "LV_FLEX_FLOW_COLUMN_REVERSE"
      "LV_FLEX_FLOW_ROW_WRAP_REVERSE"
      "LV_FLEX_FLOW_COLUMN_WRAP_REVERSE"
    ];

    lv_flex_align_t = [
      "LV_FLEX_ALIGN_START"
      "LV_FLEX_ALIGN_END"
      "LV_FLEX_ALIGN_CENTER"
      "LV_FLEX_ALIGN_SPACE_EVENLY"
      "LV_FLEX_ALIGN_SPACE_AROUND"
      "LV_FLEX_ALIGN_SPACE_BETWEEN"
    ];

    lv_align_t = [
      "LV_ALIGN_DEFAULT"
      "LV_ALIGN_TOP_LEFT"
      "LV_ALIGN_TOP_MID"
      "LV_ALIGN_TOP_RIGHT"
      "LV_ALIGN_BOTTOM_LEFT"
      "LV_ALIGN_BOTTOM_MID"
      "LV_ALIGN_BOTTOM_RIGHT"
      "LV_ALIGN_LEFT_MID"
      "LV_ALIGN_RIGHT_MID"
      "LV_ALIGN_CENTER"
    ];

    lv_event_code_t = [
      "LV_EVENT_PRESSED"
      "LV_EVENT_PRESSING"
      "LV_EVENT_RELEASED"
      "LV_EVENT_CLICKED"
      "LV_EVENT_LONG_PRESSED"
      "LV_EVENT_FOCUSED"
      "LV_EVENT_DEFOCUSED"
      "LV_EVENT_VALUE_CHANGED"
      "LV_EVENT_READY"
      "LV_EVENT_CANCEL"
    ];

    lv_state_t = [
      "LV_STATE_DEFAULT"
      "LV_STATE_CHECKED"
      "LV_STATE_FOCUSED"
      "LV_STATE_EDITED"
      "LV_STATE_HOVERED"
      "LV_STATE_PRESSED"
      "LV_STATE_DISABLED"
    ];

    lv_part_t = [
      "LV_PART_MAIN"
      "LV_PART_SCROLLBAR"
      "LV_PART_INDICATOR"
      "LV_PART_KNOB"
      "LV_PART_SELECTED"
      "LV_PART_ITEMS"
      "LV_PART_CURSOR"
      "LV_PART_CUSTOM_FIRST"
    ];

    lv_obj_flag_t = [
      "LV_OBJ_FLAG_HIDDEN"
      "LV_OBJ_FLAG_CLICKABLE"
      "LV_OBJ_FLAG_CLICK_FOCUSABLE"
      "LV_OBJ_FLAG_CHECKABLE"
      "LV_OBJ_FLAG_SCROLLABLE"
      "LV_OBJ_FLAG_SCROLL_ELASTIC"
      "LV_OBJ_FLAG_SCROLL_MOMENTUM"
      "LV_OBJ_FLAG_SNAPPABLE"
      "LV_OBJ_FLAG_PRESS_LOCK"
      "LV_OBJ_FLAG_FLOATING"
      "LV_OBJ_FLAG_OVERFLOW_VISIBLE"
    ];

    lv_text_align_t = [
      "LV_TEXT_ALIGN_AUTO"
      "LV_TEXT_ALIGN_LEFT"
      "LV_TEXT_ALIGN_CENTER"
      "LV_TEXT_ALIGN_RIGHT"
    ];
  };

  # Type aliases
  aliases = {
    lv_coord_t = "i32";
    lv_opa_t = "u8";
    lv_color_t = "u32";  # ARGB8888 at 32-bit depth
    lv_event_cb_t = "proc \"c\" (e: ^lv_event_t)";
  };

  # Functions grouped by category
  functions = {
    # === Core / Init ===
    lv_init = {
      ret = "void";
      args = [];
    };

    lv_deinit = {
      ret = "void";
      args = [];
    };

    lv_timer_handler = {
      ret = "u32";
      args = [];
    };

    lv_tick_inc = {
      ret = "void";
      args = [{ name = "tick_period"; type = "u32"; }];
    };

    # === Display ===
    lv_display_get_default = {
      ret = "^lv_display_t";
      args = [];
    };

    lv_display_get_horizontal_resolution = {
      ret = "i32";
      args = [{ name = "disp"; type = "^lv_display_t"; }];
    };

    lv_display_get_vertical_resolution = {
      ret = "i32";
      args = [{ name = "disp"; type = "^lv_display_t"; }];
    };

    lv_screen_active = {
      ret = "^lv_obj_t";
      args = [];
    };

    lv_screen_load = {
      ret = "void";
      args = [{ name = "scr"; type = "^lv_obj_t"; }];
    };

    # === GLFW Window (OpenGL ES backend) ===
    lv_opengles_glfw_window_create = {
      ret = "^lv_display_t";
      args = [
        { name = "hor_res"; type = "i32"; }
        { name = "ver_res"; type = "i32"; }
      ];
    };

    lv_opengles_glfw_window_set_title = {
      ret = "void";
      args = [
        { name = "disp"; type = "^lv_display_t"; }
        { name = "title"; type = "cstring"; }
      ];
    };

    # === Object Core ===
    lv_obj_create = {
      ret = "^lv_obj_t";
      args = [{ name = "parent"; type = "^lv_obj_t"; }];
    };

    lv_obj_delete = {
      ret = "void";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    lv_obj_clean = {
      ret = "void";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    lv_obj_set_parent = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "parent"; type = "^lv_obj_t"; }
      ];
    };

    lv_obj_get_parent = {
      ret = "^lv_obj_t";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    # === Size / Position ===
    lv_obj_set_size = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "w"; type = "i32"; }
        { name = "h"; type = "i32"; }
      ];
    };

    lv_obj_set_width = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "w"; type = "i32"; }
      ];
    };

    lv_obj_set_height = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "h"; type = "i32"; }
      ];
    };

    lv_obj_set_pos = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "x"; type = "i32"; }
        { name = "y"; type = "i32"; }
      ];
    };

    lv_obj_set_x = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "x"; type = "i32"; }
      ];
    };

    lv_obj_set_y = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "y"; type = "i32"; }
      ];
    };

    lv_obj_set_align = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "align"; type = "lv_align_t"; }
      ];
    };

    lv_obj_align = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "align"; type = "lv_align_t"; }
        { name = "x_ofs"; type = "i32"; }
        { name = "y_ofs"; type = "i32"; }
      ];
    };

    lv_obj_get_width = {
      ret = "i32";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    lv_obj_get_height = {
      ret = "i32";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    lv_obj_get_x = {
      ret = "i32";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    lv_obj_get_y = {
      ret = "i32";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    # === Flags ===
    lv_obj_add_flag = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "f"; type = "lv_obj_flag_t"; }
      ];
    };

    lv_obj_remove_flag = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "f"; type = "lv_obj_flag_t"; }
      ];
    };

    lv_obj_has_flag = {
      ret = "bool";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "f"; type = "lv_obj_flag_t"; }
      ];
    };

    # === State ===
    lv_obj_add_state = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "state"; type = "lv_state_t"; }
      ];
    };

    lv_obj_remove_state = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "state"; type = "lv_state_t"; }
      ];
    };

    lv_obj_has_state = {
      ret = "bool";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "state"; type = "lv_state_t"; }
      ];
    };

    # === Events ===
    lv_obj_add_event_cb = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "event_cb"; type = "lv_event_cb_t"; }
        { name = "filter"; type = "lv_event_code_t"; }
        { name = "user_data"; type = "rawptr"; }
      ];
    };

    lv_event_get_code = {
      ret = "lv_event_code_t";
      args = [{ name = "e"; type = "^lv_event_t"; }];
    };

    lv_event_get_target = {
      ret = "^lv_obj_t";
      args = [{ name = "e"; type = "^lv_event_t"; }];
    };

    lv_event_get_user_data = {
      ret = "rawptr";
      args = [{ name = "e"; type = "^lv_event_t"; }];
    };

    # === Flex Layout ===
    lv_obj_set_flex_flow = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "flow"; type = "lv_flex_flow_t"; }
      ];
    };

    lv_obj_set_flex_align = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "main_place"; type = "lv_flex_align_t"; }
        { name = "cross_place"; type = "lv_flex_align_t"; }
        { name = "track_place"; type = "lv_flex_align_t"; }
      ];
    };

    lv_obj_set_flex_grow = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "grow"; type = "u8"; }
      ];
    };

    # === Styling ===
    lv_obj_set_style_bg_color = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "lv_color_t"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    lv_obj_set_style_bg_opa = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "lv_opa_t"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    lv_obj_set_style_text_color = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "lv_color_t"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    lv_obj_set_style_text_font = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "^lv_font_t"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    lv_obj_set_style_radius = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "i32"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    lv_obj_set_style_border_color = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "lv_color_t"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    lv_obj_set_style_border_width = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "i32"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    # Note: lv_obj_set_style_pad_all is a C macro, use Odin helper instead

    lv_obj_set_style_pad_top = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "i32"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    lv_obj_set_style_pad_bottom = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "i32"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    lv_obj_set_style_pad_left = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "i32"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    lv_obj_set_style_pad_right = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "i32"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    lv_obj_set_style_pad_row = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "i32"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    lv_obj_set_style_pad_column = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "value"; type = "i32"; }
        { name = "selector"; type = "u32"; }
      ];
    };

    # === Color helpers ===
    lv_color_hex = {
      ret = "lv_color_t";
      args = [{ name = "c"; type = "u32"; }];
    };

    lv_color_make = {
      ret = "lv_color_t";
      args = [
        { name = "r"; type = "u8"; }
        { name = "g"; type = "u8"; }
        { name = "b"; type = "u8"; }
      ];
    };

    # === Widgets: Label ===
    lv_label_create = {
      ret = "^lv_obj_t";
      args = [{ name = "parent"; type = "^lv_obj_t"; }];
    };

    lv_label_set_text = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "text"; type = "cstring"; }
      ];
    };

    lv_label_set_text_static = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "text"; type = "cstring"; }
      ];
    };

    lv_label_get_text = {
      ret = "cstring";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    lv_label_set_long_mode = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "mode"; type = "i32"; }  # lv_label_long_mode_t
      ];
    };

    # === Widgets: Button ===
    lv_button_create = {
      ret = "^lv_obj_t";
      args = [{ name = "parent"; type = "^lv_obj_t"; }];
    };

    # === Widgets: Textarea ===
    lv_textarea_create = {
      ret = "^lv_obj_t";
      args = [{ name = "parent"; type = "^lv_obj_t"; }];
    };

    lv_textarea_set_text = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "text"; type = "cstring"; }
      ];
    };

    lv_textarea_get_text = {
      ret = "cstring";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    lv_textarea_set_placeholder_text = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "text"; type = "cstring"; }
      ];
    };

    lv_textarea_set_one_line = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "en"; type = "bool"; }
      ];
    };

    lv_textarea_set_password_mode = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "en"; type = "bool"; }
      ];
    };

    lv_textarea_add_char = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "c"; type = "u32"; }
      ];
    };

    lv_textarea_add_text = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "text"; type = "cstring"; }
      ];
    };

    lv_textarea_delete_char = {
      ret = "void";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    lv_textarea_delete_char_forward = {
      ret = "void";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    # === Widgets: Image ===
    lv_image_create = {
      ret = "^lv_obj_t";
      args = [{ name = "parent"; type = "^lv_obj_t"; }];
    };

    lv_image_set_src = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "src"; type = "rawptr"; }  # Can be path string or lv_image_dsc_t*
      ];
    };

    lv_image_set_scale = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "zoom"; type = "u32"; }  # 256 = 100%
      ];
    };

    lv_image_set_rotation = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "angle"; type = "i32"; }  # 0.1 degree units
      ];
    };

    # === Scrolling ===
    lv_obj_scroll_to = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "x"; type = "i32"; }
        { name = "y"; type = "i32"; }
        { name = "anim_en"; type = "bool"; }
      ];
    };

    lv_obj_scroll_by = {
      ret = "void";
      args = [
        { name = "obj"; type = "^lv_obj_t"; }
        { name = "x"; type = "i32"; }
        { name = "y"; type = "i32"; }
        { name = "anim_en"; type = "bool"; }
      ];
    };

    lv_obj_get_scroll_x = {
      ret = "i32";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    lv_obj_get_scroll_y = {
      ret = "i32";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    # === Invalidation / Redraw ===
    lv_obj_invalidate = {
      ret = "void";
      args = [{ name = "obj"; type = "^lv_obj_t"; }];
    };

    lv_refr_now = {
      ret = "void";
      args = [{ name = "disp"; type = "^lv_display_t"; }];
    };
  };
}
