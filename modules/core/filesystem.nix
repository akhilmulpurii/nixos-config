{ ... }:
{

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/0da7cad3-5fe8-403e-ab93-b8443d2cc5d2";
    fsType = "ext4";
    options = [ "defaults" ];
  };
}
