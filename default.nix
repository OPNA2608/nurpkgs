# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Bumped Halide, dependency. PR #100202
  halide-10 = pkgs.callPackage ./pkgs/halide-10 {
    llvmPackages = pkgs.llvmPackages_9;
  };

  hdr-plus = pkgs.callPackage ./pkgs/hdr-plus {
    halide = halide-10;
  };

  libvgm = pkgs.callPackage ./pkgs/libvgm { };
  mmlgui = pkgs.callPackage ./pkgs/mmlgui { };

  ptcollab = pkgs.libsForQt5.callPackage ./pkgs/ptcollab { };
}

