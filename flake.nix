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
    nixosConfigurations.kiosk = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ({
          config,
          pkgs,
          ...
        }: {
          system.stateVersion = "25.05";

          users.users.youruser = {
            isNormalUser = true;
            extraGroups = ["wheel" "video" "input"];
            password = "password";
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
                    --cmd "${pkgs.cage}/bin/cage ${pkgs.yourApp}/bin/jellyfin-web"
                '';
                user = "greeter";
              };
            };
          };

          users.users.greeter = {
            isSystemUser = true;
          };

          networking.networkmanager.enable = true;

          services.dbus.enable = true;
        })
      ];
    };
  };
}
