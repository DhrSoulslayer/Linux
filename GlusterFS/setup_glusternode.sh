#!/bin/bash
volume_name=nfs
number_of_servers=2
datadir=/glusterfs
host1=10.60.60.61
host2=10.60.60.62
local_host=hostname

#Install en setup GlusterFS 2 Node Mirror Cluster
mkdir $datadir
apt update
add-apt-repository ppa:gluster/glusterfs-7
apt update
apt install -y glusterfs-server keepalived

#Starting GlusterFS Services:
systemctl start glusterd.service
systemctl enable glusterd.service

#Create and start gluster volume
gluster volume create $volume_name replica $number_of_servers $host1:$datadir $host2:$datadir force
gluster volume start $volume_name

#Setup NFS share for keepalive
gluster volume set $volume_name nfs.disable
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