{ modulesPath, pkgs, ... }:
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
  ];

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
      "157.180.34.237" = {
        enableACME = true;
        addSSL = true;
      };
    };
  };

  services.fastd = {
    "testService" = {
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
      ];
      mtu = 1406;
      secretKeyIncludeFile = "/opt/supersecret";
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
