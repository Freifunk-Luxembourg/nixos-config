{ ... }:
{
  services.openssh = {
    enable = true;
    authorizedKeysInHomedir = false;
    settings.PasswordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys =
  [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLFCOqpPOTZEQiWcY9TyVQnMoc5bCYlxLaRKhiB/uxo" # trix
  ];
}
