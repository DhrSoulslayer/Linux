#Increase LVM on Ubuntu
vg_default_name=ubuntu-vg
lv_default_name=ubuntu-lv
lv_default_location=/dev/$vg_default_name/$lv_default_name
(
echo n # Add a new partition
echo p # Primary partition
echo   # Partition number
echo   # First sector (Accept default: 1)
echo   # Last sector (Accept default: varies)
echo w # Write changes
) | sudo fdisk /dev/sda
sudo vgextend $vg_default_name /dev/sda4
sudo lvextend -l +100%FREE $lv_default_location
sudo resize2fs $lv_default_location