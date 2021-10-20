#!/bin/bash
volume_name=nfs
number_of_servers=2
datadir=/glusterfs_brick
clientdir=/glusterfs_node
host1=$(ip address | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
host2=10.60.60.62
local_ip=$(ip address | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

#Install en setup GlusterFS 2 Node Mirror Cluster
add-apt-repository ppa:gluster/glusterfs-7 -y
apt update
apt install -y glusterfs-server keepalived glusterfs-client

#Starting GlusterFS Services:
systemctl start glusterd.service
systemctl enable glusterd.service
gluster peer probe $host2

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