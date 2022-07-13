 # Initial Setup
 Before you run the base-uefi.sh install script there is some manual initial steps you need to perform like partitioning your disk(s)

 | Mount point   | Partition                  | Partition type        | Suggested size           |
 |---------------|----------------------------|-----------------------|--------------------------|
 | `/mnt/boot`   | `/dev/efi_system_partition`| `EFI system partition`| `At least 300 MiB`       |
 | `[SWAP]`      | `/dev/swap_partition`      |`Linux swap`           |`More than 512 MiB`       |
 | `/mnt`        | `/dev/root_partition`      |`Linux x86-64 root(/)` | `Remainder of the device`|
 
### Format the partitions
---
Create an Ext4 file system on `/dev/root_partition`

`# mkfs.ext4 /dev/root_partition`

Initialize the swap partition

`# mkswap /dev/swap_partition`

Format the EFI system partition to FAT32

`# mkfs.fat -F 32 /dev/efi_system_partition`

### Mount the file sytems
---
Mount the root volume to `/mnt`

`# mount /dev/root_partition /mnt`

Mount the EFI system partition

`# mount --mkdir /dev/efi_system_partition /mnt/boot`

Enable the swap volume

`# swapon /dev/swap_partition`
