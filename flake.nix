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
      odinBindingsFile = import ./binder.nix { inherit pkgs; };

      # Build LVGL with configurable options
      mkLvgl = {
        # Library type
        shared ? false,

        # Display backends (pick one)
        glfw ? true,
        wayland ? false,
        x11 ? false,

        # Features
        opengl ? true,
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
      }: let
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

/* OpenGL */
#define LV_USE_OPENGLES ${if opengl then "1" else "0"}
#define LV_USE_DRAW_OPENGLES ${if opengl then "1" else "0"}

/* Input */
#define LV_USE_EVDEV ${if evdev then "1" else "0"}

/* Required for OpenGL */
#define LV_USE_FLOAT 1
#define LV_USE_MATRIX 1

/* Vector graphics */
#define LV_USE_VECTOR_GRAPHIC 1
#define LV_USE_THORVG_INTERNAL 1

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
