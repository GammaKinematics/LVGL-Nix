{
  description = "LVGL graphics library for Nix - static/shared builds with configurable backends";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lvgl-src = {
      url = "git+https://github.com/lvgl/lvgl?shallow=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, lvgl-src }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # Generate Odin bindings
      odinBindingsFile = import ./binder.nix { inherit pkgs; lvglSrc = lvgl-src; };

      # Build LVGL with configurable options
      mkLvgl = {
        # Library type
        shared ? false,

        # Display backends (pick one)
        glfw ? true,
        wayland ? false,
        x11 ? false,
        sdl ? false,

        # SDL options
        sdlAccelerated ? true,      # Use hardware acceleration
        sdlRenderMode ? "direct",   # partial, direct, full

        # Features
        opengl ? true,          # LV_USE_OPENGLES - enables GL context and texture APIs
        openglDraw ? opengl,    # LV_USE_DRAW_OPENGLES - use GPU for widget drawing (can be false with opengl=true for SW rendering + GL context)
        evdev ? true,
        tinyTtf ? false,

        # Config
        colorDepth ? 32,
        dpi ? 130,
        refreshPeriod ? 16,

        # Logging
        logging ? false,
        logLevel ? "NONE",  # TRACE, INFO, WARN, ERROR, USER, NONE

        # Fonts - Montserrat sizes to include (list of integers)
        montserratSizes ? [ 14 16 20 ],
        defaultFontSize ? 14,

        # Special fonts
        fontDejaVu ? false,      # Persian/Hebrew/Arabic
        fontCjk ? false,         # Chinese/Japanese/Korean (14 and 16)
        fontMonospace ? false,   # UNSCII 8 and 16

        # Compiler optimizations
        optimize ? true,         # -O3
        lto ? false,             # -flto
        march ? null,            # "native", "x86-64-v3", etc.
        fastMath ? false,        # -ffast-math

        # Odin bindings
        odinBindings ? false,

        # Theme
        darkMode ? true,       # Light or dark mode
        customTheme ? {},      # Override default theme values
      }: let
        # Theme config (exposed via passthru for downstream consumers)
        themeConfig = (import ./default_theme.nix { inherit darkMode; }) // customTheme;

        # Generate theme C file
        themeCFile = import ./theme.nix {
          inherit pkgs themeConfig;
        };
      in let
        # Build optimization flags
        optFlags = pkgs.lib.optionals optimize [ "-O3" ]
          ++ pkgs.lib.optionals (march != null) [ "-march=${march}" ]
          ++ pkgs.lib.optionals fastMath [ "-ffast-math" ]
          ++ pkgs.lib.optionals lto [ "-flto" ];
        optFlagsStr = builtins.concatStringsSep " " optFlags;
      in pkgs.stdenv.mkDerivation {
        pname = "lvgl";
        version = "9.2.0";
        src = lvgl-src;

        nativeBuildInputs = with pkgs; [ cmake ninja pkg-config ];

        buildInputs =
          [ pkgs.libGL pkgs.mesa ]
          ++ pkgs.lib.optionals glfw [ pkgs.glfw pkgs.glew ]
          ++ pkgs.lib.optionals wayland [ pkgs.wayland pkgs.wayland-protocols pkgs.libxkbcommon ]
          ++ pkgs.lib.optionals x11 [ pkgs.xorg.libX11 ]
          ++ pkgs.lib.optionals sdl [ pkgs.SDL2 pkgs.xorg.libX11 ]
          ++ pkgs.lib.optionals evdev [ pkgs.libevdev ];

        # Generate lv_conf.h
        postPatch = let
          # Generate Montserrat font defines
          allMontserratSizes = [ 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 ];
          montserratDefines = builtins.concatStringsSep "\n" (map (size:
            "#define LV_FONT_MONTSERRAT_${toString size} ${if builtins.elem size montserratSizes then "1" else "0"}"
          ) allMontserratSizes);
        in ''
          cat > lv_conf.h << 'EOF'
#ifndef LV_CONF_H
#define LV_CONF_H

#define LV_COLOR_DEPTH ${toString colorDepth}

/* Stdlib */
#define LV_USE_STDLIB_MALLOC LV_STDLIB_CLIB
#define LV_USE_STDLIB_STRING LV_STDLIB_CLIB
#define LV_USE_STDLIB_SPRINTF LV_STDLIB_CLIB

/* HAL */
#define LV_DEF_REFR_PERIOD ${toString refreshPeriod}
#define LV_DPI_DEF ${toString dpi}

/* Display backends */
#define LV_USE_GLFW ${if glfw then "1" else "0"}
#define LV_USE_WAYLAND ${if wayland then "1" else "0"}
#define LV_USE_X11 ${if x11 then "1" else "0"}
#define LV_X11_HIDE_CURSOR 0  /* Keep native X11 cursor */

/* SDL */
#define LV_USE_SDL ${if sdl then "1" else "0"}
#if LV_USE_SDL
    #define LV_SDL_INCLUDE_PATH <SDL2/SDL.h>
    #define LV_SDL_RENDER_MODE LV_DISPLAY_RENDER_MODE_${pkgs.lib.strings.toUpper sdlRenderMode}
    #define LV_SDL_BUF_COUNT 1
    #define LV_SDL_ACCELERATED ${if sdlAccelerated then "1" else "0"}
    #define LV_SDL_FULLSCREEN 0
    #define LV_SDL_DIRECT_EXIT 1
    #define LV_SDL_MOUSEWHEEL_MODE LV_SDL_MOUSEWHEEL_MODE_ENCODER
#endif

/* OpenGL */
#define LV_USE_OPENGLES ${if opengl then "1" else "0"}
#if LV_USE_OPENGLES
    #define LV_USE_OPENGLES_DEBUG 1
#endif
#define LV_USE_DRAW_OPENGLES ${if openglDraw then "1" else "0"}

/* Input */
#define LV_USE_EVDEV ${if evdev then "1" else "0"}

/* Required for OpenGL */
#define LV_USE_FLOAT 1
#define LV_USE_MATRIX 1

/* Software renderer - needed even with OpenGL ES (GLES renders to textures using SW) */
#define LV_USE_DRAW_SW 1
#if LV_USE_DRAW_SW
    #define LV_DRAW_SW_SUPPORT_RGB565 1
    #define LV_DRAW_SW_SUPPORT_RGB565_SWAPPED 1
    #define LV_DRAW_SW_SUPPORT_RGB565A8 1
    #define LV_DRAW_SW_SUPPORT_RGB888 1
    #define LV_DRAW_SW_SUPPORT_XRGB8888 1
    #define LV_DRAW_SW_SUPPORT_ARGB8888 1
    #define LV_DRAW_SW_SUPPORT_ARGB8888_PREMULTIPLIED 1
    #define LV_DRAW_SW_SUPPORT_L8 1
    #define LV_DRAW_SW_SUPPORT_AL88 1
    #define LV_DRAW_SW_SUPPORT_A8 1
    #define LV_DRAW_SW_SUPPORT_I1 1
    #define LV_DRAW_SW_DRAW_UNIT_CNT 1
    #define LV_DRAW_SW_COMPLEX 1
#endif

/* OpenGL ES texture cache */
#if LV_USE_DRAW_OPENGLES
    #define LV_DRAW_OPENGLES_TEXTURE_CACHE_COUNT 64
#endif

/* Layouts */
#define LV_USE_FLEX 1
#define LV_USE_GRID 1

/* Widgets */
#define LV_WIDGETS_HAS_DEFAULT_VALUE 1
#define LV_USE_ANIMIMG 1
#define LV_USE_ARC 1
#define LV_USE_BAR 1
#define LV_USE_BUTTON 1
#define LV_USE_BUTTONMATRIX 1
#define LV_USE_CANVAS 1
#define LV_USE_CHECKBOX 1
#define LV_USE_DROPDOWN 1
#define LV_USE_IMAGE 1
#define LV_USE_IMAGEBUTTON 1
#define LV_USE_KEYBOARD 1
#define LV_USE_LABEL 1
#define LV_USE_LED 1
#define LV_USE_LINE 1
#define LV_USE_LIST 1
#define LV_USE_MENU 1
#define LV_USE_MSGBOX 1
#define LV_USE_ROLLER 1
#define LV_USE_SCALE 1
#define LV_USE_SLIDER 1
#define LV_USE_SPAN 1
#define LV_USE_SPINBOX 1
#define LV_USE_SPINNER 1
#define LV_USE_SWITCH 1
#define LV_USE_TABLE 1
#define LV_USE_TABVIEW 1
#define LV_USE_TEXTAREA 1
#define LV_USE_TILEVIEW 1
#define LV_USE_WIN 1

/* Themes - using nix-generated theme */
#define LV_USE_THEME_DEFAULT 0
#define LV_USE_THEME_SIMPLE 0
#define LV_USE_THEME_NIX 1

/* Vector graphics */
#define LV_USE_VECTOR_GRAPHIC 1
#define LV_USE_THORVG_INTERNAL 1

/* Observer */
#define LV_USE_OBSERVER 1

/* Logging */
#define LV_USE_LOG ${if logging then "1" else "0"}
#define LV_LOG_LEVEL LV_LOG_LEVEL_${logLevel}
#define LV_LOG_PRINTF 1

/* Fonts - Montserrat */
${montserratDefines}

/* Special fonts */
#define LV_FONT_MONTSERRAT_28_COMPRESSED 0
#define LV_FONT_DEJAVU_16_PERSIAN_HEBREW ${if fontDejaVu then "1" else "0"}
#define LV_FONT_SOURCE_HAN_SANS_SC_14_CJK ${if fontCjk then "1" else "0"}
#define LV_FONT_SOURCE_HAN_SANS_SC_16_CJK ${if fontCjk then "1" else "0"}
#define LV_FONT_UNSCII_8 ${if fontMonospace then "1" else "0"}
#define LV_FONT_UNSCII_16 ${if fontMonospace then "1" else "0"}

#define LV_FONT_DEFAULT &lv_font_montserrat_${toString defaultFontSize}

/* Runtime font loading */
#define LV_USE_TINY_TTF ${if tinyTtf then "1" else "0"}
#if LV_USE_TINY_TTF
    #define LV_TINY_TTF_FILE_SUPPORT 1
#endif

/* Assert */
#define LV_ASSERT_HANDLER_INCLUDE <assert.h>
#define LV_ASSERT_HANDLER assert(0);

#endif
EOF

          # Create nix theme folder and copy files
          mkdir -p src/themes/nix
          cp ${themeCFile} src/themes/nix/lv_theme_nix.c

          # Create lv_theme_nix.h header
          cat > src/themes/nix/lv_theme_nix.h << 'HEADER_EOF'
/**
 * @file lv_theme_nix.h
 * LVGL-Nix Generated Theme Header
 */

#ifndef LV_THEME_NIX_H
#define LV_THEME_NIX_H

#ifdef __cplusplus
extern "C" {
#endif

#include "../lv_theme.h"

#if LV_USE_THEME_NIX

lv_theme_t * lv_theme_nix_init(void);
bool lv_theme_nix_is_inited(void);
lv_theme_t * lv_theme_nix_get(void);
void lv_theme_nix_deinit(void);

#endif

#ifdef __cplusplus
}
#endif

#endif /* LV_THEME_NIX_H */
HEADER_EOF

          # Patch lv_global.h - add theme_nix storage slot
          substituteInPlace src/core/lv_global.h \
            --replace-fail \
              '#if LV_USE_THEME_DEFAULT
    void * theme_default;
#endif' \
              '#if LV_USE_THEME_DEFAULT
    void * theme_default;
#endif
#if LV_USE_THEME_NIX
    void * theme_nix;
#endif'

          # Patch lv_theme.h - include our header
          substituteInPlace src/themes/lv_theme.h \
            --replace-fail \
              '#include "simple/lv_theme_simple.h"' \
              '#include "simple/lv_theme_simple.h"
#include "nix/lv_theme_nix.h"'

          # Patch lv_display.c - add theme check
          substituteInPlace src/display/lv_display.c \
            --replace-fail \
              '#elif LV_USE_THEME_MONO' \
              '#elif LV_USE_THEME_NIX
    if(lv_theme_nix_is_inited() == false) {
        disp->theme = lv_theme_nix_init();
    }
    else {
        disp->theme = lv_theme_nix_get();
    }
#elif LV_USE_THEME_MONO'

          # Patch lv_init.c - add deinit call
          substituteInPlace src/lv_init.c \
            --replace-fail \
              '#if LV_USE_THEME_DEFAULT
    lv_theme_default_deinit();
#endif' \
              '#if LV_USE_THEME_DEFAULT
    lv_theme_default_deinit();
#endif
#if LV_USE_THEME_NIX
    lv_theme_nix_deinit();
#endif'
        '';

        env = pkgs.lib.optionalAttrs (optFlagsStr != "") {
          NIX_CFLAGS_COMPILE = optFlagsStr;
        };

        cmakeFlags = [
          "-DBUILD_SHARED_LIBS=${if shared then "ON" else "OFF"}"
          "-DCMAKE_BUILD_TYPE=Release"
          "-DLV_CONF_PATH=${placeholder "out"}/include/lv_conf.h"
          "-DCONFIG_LV_BUILD_DEMOS=OFF"
          "-DCONFIG_LV_BUILD_EXAMPLES=OFF"
        ];

        postInstall = ''
          ${pkgs.lib.optionalString odinBindings ''
            mkdir -p $out/odin
            cp ${odinBindingsFile} $out/odin/lvgl.odin
          ''}
        '';

        passthru = { theme = themeConfig; };

        meta = {
          description = "LVGL - Light and Versatile Graphics Library";
          homepage = "https://lvgl.io/";
          license = pkgs.lib.licenses.mit;
          platforms = [ "x86_64-linux" ];
        };
      };

    in {
      packages.${system} = {
        # Default: static library with GLFW + OpenGL + TinyTTF
        default = mkLvgl { };

        # Static variants
        static-glfw = mkLvgl { shared = false; glfw = true; };
        static-wayland = mkLvgl { shared = false; wayland = true; glfw = false; };
        static-x11 = mkLvgl { shared = false; x11 = true; glfw = false; };

        # Shared variants
        shared-glfw = mkLvgl { shared = true; glfw = true; };
        shared-wayland = mkLvgl { shared = true; wayland = true; glfw = false; };
      };

      # Expose mkLvgl for custom configurations
      lib.mkLvgl = mkLvgl;
    };
}
