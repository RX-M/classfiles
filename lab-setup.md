# RX-M - Lab System Setup

The lab exercises for RX-M courses are designed for completion on a base Ubuntu 64 bit system (ideally the latest LTS
version). The system should have 2+ CPUs, 4+ GBs of RAM and 50+ GB of disk. Students who have access to an appropriate
existing system (e.g. a typical cloud instance or wsl2 ubuntu) can perform the lab exercises on that system, however, 
RX-M provides a prebuilt lab VM which offers a reliable and safe environment for experimentation.


#### Supported Platforms

The RX-M lab VM can be run on any virtualization platform compatible with VMware or OVA vm formats:

- VMware Workstation Pro (free for personal use but requires a Broadcom account) [Windows/Linux]: [https://my.vmware.com/web/vmware/downloads/info/slug/desktop_end_user_computing/vmware_workstation_player/16_0](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Workstation%20Pro)
- VMware Fusion Pro (Free for personal use but requires a Broadcom Account) [Mac]: https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Fusion
-  Virtual Box (free) [Mac/Windows/Linux] https://www.virtualbox.org/wiki/Downloads


#### Download the VM

The RX-M **VMware** configured lab virtual machine is 1.6GB in 7z compressed format and can be downloaded here: https://rx-m-vms.s3.us-west-1.amazonaws.com/rx-m-lab-vm-ubuntu-2404-vmware.7z (sha256 aca0328bf72fd36cde81ea62b1c72131c5f7bc936beae93e392adf67acf3fd64)

The RX-M **VirtualBox** configured lab virtual machine is 2.3 GB in OVA compressed format and can be downloaded here: https://rx-m-vms.s3.us-west-1.amazonaws.com/rx-m-lab-vm-ubuntu-2404-virtualbox.7z (sha256 d8701f1134ac84332b57ab423b882eee3041d4ae661a2e3b1adb5c26c1309d76)


#### Run the VM

To run the lab VM:
1. Download the lab system fully (do not attempt to manipulate the file until it has completely downloaded)
2. If using the .7z file, use any 7Zip compatible archiver:
     - __Windows:__ download 7zip here: http://www.7-zip.org/download.html
     - __Mac:__ search for the freeware "The Unarchiver" in the Mac app store
3. Launch the VM:
     - **VMware:** double click the .vmx file (e.g. `rx-m-lab-vm.vmx`) inside the decompressed folder (when
       asked, say you __copied__ the VM)
     - **VirtualBox:** double click the OVA file (when asked, agree to import the VM)
4. Login to the VM with the username "user" and the password "user"


## What could go wrong?

For most people (95%) the above steps work perfectly. However there are some common issues that may keep you from running the lab virtual machine (which are easily fixed):

- The virtualization system (VMware/VirtualBox) says it can not run a 64 bit virtual machine because "VTx is not
  enabled" (or similar message).

     - Intel/AMD processors have virtualization extensions (VT) that hypervisors use to improve VM performance and enable advanced functionality. If these extensions are not enabled you will not be able to run a 64 bit VM like the lab
     system. This is not generally a problem on Macs but many PCs (Lenovo laptops in particular) come with VTx
     disabled. To fix this, simply enter the BIOS configuration and enable VTx (your BIOS may call it "Virtualization
     Technology", "Intel VT", "AMD-V", "VT-d" or something else depending on your CPU and chipset). To enter the BIOS
     configuration you will need to reboot your computer and then press a key (usually \<Enter\>, \<F10\> or something
     similar) quickly before the OS starts. Every BIOS configuration menu is different but the settings are often found
     under "general" or "security" menus. Enable all of the virtualization features (there may be one or more options to
     enable), save the changes and reboot. You should now be able to run the lab VM.

- VMware complains that the VM was created by a VMware product that is incompatible with your version of VMware and cannot
be used

     - For Player and/or Workstation: open the file: `rx-m-lab-vm.vmx` with a text editor, find the property:
     `virtualHW.version = "12"` and change it to your version.

     - For Fusion:
       - Select the VM from the list in the Virtual Machine Library
       - Open Settings by either: using the Command + E shortcut (⌘E), clicking on the wrench icon, or right-clicking and
       choosing "Settings..." from the right-click menu, or opening the "Virtual Machine" menu and selecting "Settings..."
       - In the Settings dialog, select "Compatibility" (icon looks like a motherboard)
       - Open the "Advanced Options" drop-down option
       - Under the "Use Hardware Version" selector, select your hardware version

- DNS causes problems when the VM suspends on Virtual Box

    - On some (older?) versions of Virtual Box DNS issues can occur after suspending the VM and or moving between networks (e.g. wifi hot spots). Solution (on OSX) is to run: VBoxManage modifyvm "VM name" --natdnshostresolver1 on
