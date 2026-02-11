{ modulesPath, config, pkgs, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./common.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  environment.systemPackages = with pkgs; [
    curl
    wget
    git
    vim
    python3
    batctl
  ];

  boot.extraModulePackages = with config.boot.kernelPackages; [ batman_adv ];

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
  };

  networking.firewall.allowedTCPPorts = [ 22 80 443 1000 ];
  security.acme = {
    defaults.email = "lkjxqljsxh5@temp.mailbox.org";
    defaults.profile = "shortlived";
    defaults.validMinDays = 3;
    defaults.extraLegoFlags = [ "--disable-cn" ];
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "49.12.220.75" = {
        enableACME = true;
        addSSL = true;
      };
    };
  };

  services.fastd = {
    "fflux" = {
      peers = [
        {
          name = "fflux";
          remote = [
            { address = "fflux.freifunk.lu"; port = 10000; }
          ];
          pubkey = "35461acdf925c688290095eb3cf83699925b045e566fb719266ab456a6aab9af";
          extraConfig = ''
            float yes;
          '';
        }
        {
          name = "fflux-gw1";
          remote = [
            { address = "fflux-gw1.freifunk.lu"; port = 10000; }
          ];
          pubkey = "d5af753220451b6c181cca469835da9c67d3ca9603465e13a5adb9b64f89f3c6";
          extraConfig = ''
            float yes;
          '';
        }
        {
          name = "fflux-gw2";
          remote = [
            { address = "fflux-gw2.freifunk.lu"; port = 10000; }
          ];
          pubkey = "3c42a77d863cb0475ec5a9e9b9c63ff557f8bac991b78a26427f100cc130462b";
          extraConfig = ''
            float yes;
          '';
        }
      ];
      peerLimit = 30;
      mtu = 1406;
      secretKeyIncludeFile = "/opt/fastd";
      method = [ "salsa2012+umac" "salsa2012+gmac" ];
      bind = [ "any port 1000" ];
      mode = "tap";
      extraConfig = ''
        interface "ze-tap";
      '';
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    nixPath = [
      "nixpkgs=${pkgs.path}"
    ];
  };

  system.stateVersion = "25.11";
}
