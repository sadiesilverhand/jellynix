{
  description = "jellynix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ({
          config,
          pkgs,
          ...
        }: {
          system.stateVersion = "25.05";

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          fileSystems."/" = {
            device = "/dev/nvme0n1p2";
            fsType = "ext4";
          };

          fileSystems."/boot" = {
            device = "/dev/nvme0n1p1";
            fsType = "vfat";
          };

          users.users.youruser = {
            isNormalUser = true;
            extraGroups = ["wheel" "video" "input"];
            password = "password";
          };

          users.users.greeter = {
            isSystemUser = true;
          };

          services.xserver.enable = false;
          hardware.opengl.enable = true;

          environment.systemPackages = with pkgs; [
            cage
            greetd.tuigreet
            jellyfin-web
          ];

          services.greetd = {
            enable = true;
            settings = {
              default_session = {
                command = ''
                  ${pkgs.greetd.tuigreet}/bin/tuigreet \
                    --time \
                    --cmd "${pkgs.cage}/bin/cage ${pkgs.jellyfin-web}/bin/jellyfin-web"
                '';
                user = "greeter";
              };
            };
          };

          networking.networkmanager.enable = true;

          services.dbus.enable = true;
        })
      ];
    };
  };
}
