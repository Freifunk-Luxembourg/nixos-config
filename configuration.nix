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

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
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
      "91.98.42.110" = {
        enableACME = true;
        addSSL = true;
      };
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
