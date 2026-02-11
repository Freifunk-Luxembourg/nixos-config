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

  #networking.useNetworkd = true;

  # Mullvad WireGuard configuration
  networking.wireguard.interfaces.mullvad = {
    privateKeyFile = "/opt/wireguard";
    table = "100";
    listenPort = 51821;
    ips = [ "10.68.151.245/32" ];
    peers = [{
      publicKey = "GE2WP6hmwVggSvGVWLgq2L10T3WM2VspnUptK5F4B0U=";
      allowedIPs = [ "0.0.0.0/0" ];
      endpoint = "91.90.123.2:51820";
      persistentKeepalive = 25;
    }];
  };

  #systemd.network.networks."30-mullvad" = {
  #  matchConfig.Name = "mullvad";
  #  address = [ "10.68.151.245/32" ];
  #  routingPolicyRules = [{
  #    FirewallMark = 51820;
  #    Table = 100;
  #    Priority = 100;
  #  }];
  #};

  # This kind of config is needed for the freifunky-things, but we're not doing that yet, but clearly stuff is broken enough
  #boot.kernel.sysctl = {
  #  "net.ipv4.conf.mullvad.rp_filter" = 0;
  #};

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 1000 ];
    allowedUDPPorts = [ 51821 ];
    #trustedInterfaces = [ "mullvad" ];
  };

  # NixOS Hotfix: Bypass rpfilter for mullvad interface to allow VPN return traffic
  # Not really a hotfix, as sometimes you need to run it again manually when firewall configuration happens???
  system.activationScripts.vpn-rpfilter = ''
    ${pkgs.iptables}/bin/iptables -t mangle -I nixos-fw-rpfilter -i mullvad -j RETURN 2>/dev/null || true
  '';

  # System packages
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
