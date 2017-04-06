# RX-M - Lab System Setup

The lab exercises for RX-M courses are designed for completion on a base Ubuntu 16.04 64 bit system. The 
system should have 2+ CPUs, 2+ GBs of RAM and 30+ GB of disk. Students who have access to an appropriate 
existing system (e.g. a typical cloud instance) can perform the lab exercises on that system, however, 
RX-M provides a prebuilt lab VM which offers a more reliable and safe environment for experimentation.

The RX-M lab VM can be run on any of these virtualization platforms:
- VMware Player (free) [Windows/Linux] https://my.vmware.com/web/vmware/free#desktop_end_user_computing/vmware_workstation_player/12_0
- VMware Workstation (requires a commercial license) [Windows]
- VMware Fusion (requires a commercial license) [Mac]
- Virtual Box (free) [Mac/Windows/Linux] https://www.virtualbox.org/wiki/Downloads

The RX-M VMware configured lab virtual machine is 770MB in 7z compressed format and can be downloaded here: https://s3-us-west-1.amazonaws.com/rx-m-vms/ubuntu-16.04.7z

The RX-M VirtualBoxconfigured lab virtual machine is 1GB in OVA compressed format and can be downloaded here: https://s3-us-west-1.amazonaws.com/rx-m-vms/Ubuntu_Xenial_Xerus.vbvm.ova

To run the lab VM:
- Download the lab system fully (do not attempt to manipulate the file until it has completely downloaded)
- If using the .7z file, uncompress the file (you can use a 7zip compatible archiver or download 7zip here: http://www.7-zip.org/download.html)
- Launch the VM:
     - If using VMware, double click the .vmx file (e.g. "Ubuntu 64-bit.vmx") inside the decompressed folder (if asked, say you copied the VM))
     - If using Virtual Box, double click the OVA file (if asked, agree to import the VM)
- Login to the VM with the user name "user" and the password "user"
