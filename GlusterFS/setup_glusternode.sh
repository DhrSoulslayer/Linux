#!/bin/bash
volume_name=nfs
number_of_servers=2
datadir=/glusterfs_brick
clientdir=/glusterfsnode
host1=10.60.60.61
host2=10.60.60.62
local_host=hostname
probe_neighbour=$(ip a | grep 10.60.60 | awk '{print $2}' | awk -F "/" '{print $1}')

#Mount databrick on seperate harddrive
mount /dev/sdb1 $datadir

#Install en setup GlusterFS 2 Node Mirror Cluster
add-apt-repository ppa:gluster/glusterfs-7 -y
apt update
apt install -y glusterfs-server keepalived glusterfs-client

#Starting GlusterFS Services:
systemctl start glusterd.service
systemctl enable glusterd.service
gluster peer probe $probe_neighbour

#Create and start gluster volume
gluster volume create $volume_name replica $number_of_servers $host1:$datadir $host2:$datadir force
gluster volume start $volume_name

#Setup Ganesha NFS share
apt -y install nfs-ganesha-gluster
mv /etc/ganesha/ganesha.conf /etc/ganesha/ganesha.conf.org
cat <<EOT >> /etc/ganesha/ganesha.conf
# create new
NFS_CORE_PARAM {
    # possible to mount with NFSv3 to NFSv4 Pseudo path
    mount_path_pseudo = true;
    # NFS protocol
    Protocols = 3,4;
}
EXPORT_DEFAULTS {
    # default access mode
    Access_Type = RW;
}
EXPORT {
    # uniq ID
    Export_Id = 101;
    # mount path of Gluster Volume
    Path = "$datadir";
    FSAL {
    	# any name
        name = GLUSTER;
        # hostname or IP address of this Node
        hostname="$local_host";
        # Gluster volume name
        volume="NFS_Share";
    }
    # config for root Squash
    Squash="No_root_squash";
    # NFSv4 Pseudo path
    Pseudo="/nfs_distributed";
    # allowed security options
    SecType = "sys";
}
LOG {
    # default log level
    Default_Log_Level = WARN;
}
EOT

systemctl restart nfs-ganesha
systemctl enable nfs-ganesha

#Mount gluster node on server
mkdir $clientdir
mount -t glusterfs $host1:$volume_name $clientdir

#Setup so that fstab will mount the glsuteclient after gluster service has started
mkdir /etc/systemd/system/glusternode.mount.d/
touch override.conf
cat <<EOT >> /etc/systemd/system/glusternode.mount.d/override.conf
[Unit]
After=glusterfs-server.service
Wants=glusterfs-server.service
EOT

#Setup glusternode in fstab
echo localhost:/$volume_name $clientdir glusterfs defaults,_netdev 0 0 > /etc/fstab