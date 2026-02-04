# LVGL-Nix Default Theme
{ darkMode ? true }:

let
  light = {
    bg_prim  = "e4e6e9";  # Screen background
    bg_sec   = "ffffff";  # Cards, buttons, scrollbar thumb
    bg_ter   = "c4c6c9";  # Pressed/active states, borders
    accent   = "4a9eff";  # Focus outlines, selections
    text_pri = "3b3e42";  # Primary text
    text_sec = "8a8d91";  # Placeholders, dimmed text
  };

  dark = {
    bg_prim  = "15171a";  # Screen background
    bg_sec   = "282b30";  # Cards, buttons, scrollbar thumb
    bg_ter   = "3f4247";  # Pressed/active states, borders
    accent   = "4a9eff";  # Focus outlines, selections
    text_pri = "dfe1e5";  # Primary text
    text_sec = "5c5f63";  # Placeholders, dimmed text
  };

in {
  inherit darkMode;
  colors = if darkMode then dark else light;

  # === Sizing ===
  sizing = {
    padding = 8;   # Internal padding (inside widgets)
    gap = 10;      # Gap between sibling widgets

    radius = 10;

    # Border & outline
    borderWidth  = 2;
    outlineWidth = 3;

    # Scrollbar
    scrollbarWidth   = 5;
    scrollbarPadding = 7;
  };

  # === States ===
  states = {
    # Pressed: black recolor overlay (0-255)
    pressedRecolor = 35;

    # Disabled: grey recolor at 50% (128/255)
    disabledOpa = 128;

    # Focus outline opacity (0-255)
    outlineOpa = 128;  # 50%

    # Scrollbar opacity
    scrollbarOpa    = 102;  # 40% (LV_OPA_40)
    scrollbarActive = 255;  # 100% when scrolling
  };

  # === Transitions (ms) ===
  transitions = {
    duration = 150;
    delay    = 70;
  };
}
