# RX-M - Lab System Setup

The lab exercises for RX-M courses are designed for completion on a base Ubuntu 64 bit system (ideally the latest LTS
version). The system should have 2+ CPUs, 4+ GBs of RAM and 50+ GB of disk. Students who have access to an appropriate
existing system (e.g. a typical cloud instance or wsl2 ubuntu) can perform the lab exercises on that system, however, 
RX-M provides a prebuilt lab VM which offers a reliable and safe environment for experimentation.


#### Supported Platforms

The RX-M lab VM can be run on any virtualization platform compatible with VMware or OVA vm formats:

- Virtual Box (free) [Mac/Windows/Linux] https://www.virtualbox.org/wiki/Downloads
- VMware Workstation Player (free) [Windows/Linux] [vmware_workstation_player/17_0](https://www.vmware.com/content/vmware/vmware-published-sites/us/products/workstation-player/workstation-player-evaluation.html.html)
- VMware Workstation (free trial but later requires a commercial license) [Windows]
- VMware Fusion Player (Free for personal use but requires a VMWare Account) [Mac]
- VMware Fusion (requires a commercial license) [Mac]

#### Download the VM

The RX-M **VMware** configured lab virtual machine is 1.3GB in 7z compressed format and can be downloaded here: https://rx-m-vms.s3.us-west-1.amazonaws.com/rx-m-lab-vm.7z (sha256 0bd8e76b38f9ba56403a151eff7a62d3ccfb044af656a1418282e1a7e6482386)

The RX-M **VirtualBox** configured lab virtual machine is 1GB in OVA compressed format and can be downloaded here: https://rx-m-vms.s3.us-west-1.amazonaws.com/rx-m-lab-ubuntu-20.04-virtualbox.7z (sha256 58BEE8A0E23FAF300FB2F687B16C9DD900CEC51DDEB490D9EFAD0DD99FC374CB)


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
