# Increase default LVM on Ubuntu 18 & 20

This script assumes the following disk layout:

- Disk /dev/sda: 64 GiB, 68719476736 bytes, 134217728 sectors
- /dev/sda1      2048      4095     2048   1M BIOS boot
- /dev/sda2      4096   2101247  2097152   1G Linux filesystem
- /dev/sda3   2101248  67106815 65005568  31G Linux filesystem

After running the script the disk layout will be as followed:
Disk /dev/sda: 64 GiB, 68719476736 bytes, 134217728 sectors
Device        Start       End  Sectors Size Type
/dev/sda1      2048      4095     2048   1M BIOS boot
/dev/sda2      4096   2101247  2097152   1G Linux filesystem
/dev/sda3   2101248  67106815 65005568  31G Linux filesystem
/dev/sda4  67106816 134217694 67110879  32G Linux filesystem

After that the LVM will be increased by the following steps:
Extending the volume group with the vg extend command
Extending the logicalvolume with the lvextend command which usesses all the free space
Resizing the filesystem the use the newly free space.
