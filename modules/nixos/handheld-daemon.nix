{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.handheld-daemon;
in
{
  options.services.handheld-daemon.adjustor = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the HHD Adjustor for TDP control.";
    };
    acpiCall = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable acpi_call at boot, required for Adjustor TDP control on most devices.";
      };
    };
  };

  config = mkIf (cfg.enable && cfg.adjustor.enable) (mkMerge [
    (
      let
        hhdPython = pkgs.python3.withPackages (ps: [ ps.handheld-daemon-adjustor ]);
        handheld-daemon-with-adjustor = pkgs.handheld-daemon.overrideAttrs (attrs: rec {
          version = "3.17.4";
          src = pkgs.fetchFromGitHub {
            owner = "hhd-dev";
            repo = "hhd";
            tag = "v${version}";
            hash = "sha256-406pcIdQeKS5BJjLfaXcauq5U3gVfl8vEgDeFGsAFRs=";
          };
          nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [ hhdPython.pkgs.wrapPython ];
          propagatedBuildInputs = (attrs.propagatedBuildInputs or [ ]) ++ (with pkgs.python3Packages; [
            handheld-daemon-adjustor
          ]) ++ (with pkgs; [
            busybox
            mount
          ]);
          postFixup = ''
            wrapProgram "$out/bin/hhd" \
              --prefix PYTHONPATH : "$PYTHONPATH" \
              --prefix PATH : "${hhdPython}/bin"
          '';
        });
      in
      {
        services.handheld-daemon.package = handheld-daemon-with-adjustor;
        # Adjustor assumes it can talk PPD protocol over dbus
        services.power-profiles-daemon.enable = true;
      }
    )

    (mkIf cfg.adjustor.acpiCall.enable {
      boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
      boot.kernelModules = [ "acpi_call" ];
    })

  ]);

}
