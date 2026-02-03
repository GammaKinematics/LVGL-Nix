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

      # Build LVGL with configurable options
      mkLvgl = {
        # Library type
        shared ? false,

        # Display backends
        glfw ? true,
        wayland ? false,
        x11 ? false,

        # Features
        opengl ? true,
        evdev ? true,

        # Config
        colorDepth ? 32,
      }: pkgs.stdenv.mkDerivation {
        pname = "lvgl";
        version = "9.2.0";
        src = lvgl-src;

        nativeBuildInputs = with pkgs; [ cmake ninja pkg-config ];

        buildInputs = with pkgs; [
          # OpenGL
          libGL mesa
        ]
        ++ pkgs.lib.optionals glfw [ glfw glew ]
        ++ pkgs.lib.optionals wayland [ wayland wayland-protocols libxkbcommon ]
        ++ pkgs.lib.optionals x11 [ xorg.libX11 ]
        ++ pkgs.lib.optionals evdev [ libevdev ];

        # Generate lv_conf.h
        postPatch = ''
          cat > lv_conf.h << 'EOF'
#ifndef LV_CONF_H
#define LV_CONF_H

#define LV_COLOR_DEPTH ${toString colorDepth}

/* Stdlib */
#define LV_USE_STDLIB_MALLOC LV_STDLIB_CLIB
#define LV_USE_STDLIB_STRING LV_STDLIB_CLIB
#define LV_USE_STDLIB_SPRINTF LV_STDLIB_CLIB

/* HAL */
#define LV_DEF_REFR_PERIOD 16
#define LV_DPI_DEF 130

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
#define LV_USE_LOG 1
#define LV_LOG_LEVEL LV_LOG_LEVEL_WARN
#define LV_LOG_PRINTF 1

/* Fonts */
#define LV_FONT_MONTSERRAT_14 1
#define LV_FONT_MONTSERRAT_16 1
#define LV_FONT_MONTSERRAT_20 1

/* Assert */
#define LV_ASSERT_HANDLER_INCLUDE <assert.h>
#define LV_ASSERT_HANDLER assert(0);

#endif
EOF
        '';

        cmakeFlags = [
          "-DBUILD_SHARED_LIBS=${if shared then "ON" else "OFF"}"
          "-DCMAKE_BUILD_TYPE=Release"
          "-DLV_CONF_PATH=${placeholder "out"}/include/lv_conf.h"
        ];

        # Install headers alongside library
        postInstall = ''
          mkdir -p $out/include
          cp lv_conf.h $out/include/
          cp -r src/*.h $out/include/
          cp -r src/core $out/include/
          cp -r src/draw $out/include/
          cp -r src/misc $out/include/
          cp -r src/widgets $out/include/
          cp -r src/display $out/include/
          cp -r src/drivers $out/include/
          cp -r src/font $out/include/
          cp -r src/indev $out/include/
          cp -r src/layouts $out/include/
          cp -r src/libs $out/include/
          cp -r src/lv_api_map*.h $out/include/ 2>/dev/null || true
          cp -r src/others $out/include/
          cp -r src/stdlib $out/include/
          cp -r src/themes $out/include/
          cp -r src/tick $out/include/
          cp -r src/osal $out/include/
          cp lvgl.h $out/include/
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
        # Default: static library with GLFW + OpenGL
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
