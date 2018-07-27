# RX-M - SSH setup for Cloud Lab Access

RX-M courses can be delivered in conjunction with a cloud based lab environment. To access a cloud lab
system, students will need to have an ssh client installed on their computer and internet ssh access
(port 22).

Any mainstream ssh client will work and OSX/Linux computer systems have a good ssh client preinstalled.

Here are some suggested ssh client tools for Windows systems (you do _not_ need to install all of them;
choose one that works best for you):

- GitBash ssh command line client (free, part of Git distribution) [Windows/OSX/Linux] https://git-scm.com/downloads
- MobaXTerm (free and paid) [Windows] https://mobaxterm.mobatek.net/download.html
- PuTTY (free) [Windows] \* https://www.putty.org/

GUI clients like Putty and MobaXTerm have their own help systems and client access configuration.


### Command Line Client

Command line clients can generally access the cloud lab site with a command something like this:

```
$ ssh -i key.pem ubuntu@host.ip.ad.dr
```

Where "ubuntu" is the default user name (the instructor may supply students with a different user name  in class) and
"host.ip.ad.dr" is the host IP address of the student lab system supplied by the instructor during class (e.g.
54.23.87.45). The `-i` switch (for identity) is optional and may be required in some classes. This allows you to pass a
key file to the ssh client ("key.pem" in the example) for extra security.

In order to use this private key file with ssh on Linux systems, you must change its security attributes so that you alone have READ-ONLY access. Use the following bash command to achieve this result:

```
$ chmod 400 key.pem
```

The file will retain these permissions after you perform this step once.

Student lab system IP addresses and passwords are passed out on day one of classes with cloud based labs.


### MobaXTerm

Start MobaXTerm and add a new session by clicking on the "Session" icon in the top-left corner or by selecting the
"Sessions" menu and clicking on "New session".

In the "Session settings" window, click on SSH and enter the following information:

1. In the "Remote host" text box, enter the IP address assigned to you (sent via email or assigned in class)
  - Check the box next to "Specify username" and enter `ubuntu`
2. Click on the "Advanced SSH settings" tab
3. Check the box next to "Use private key" and type the path to your .pem file or click on the browse icon which will
let you navigate to the location where you saved it using Windows explorer.

<img alt="auth" width="500px" src="./images/m01.png"/>

Click on the [OK] button to start your SSH session.


### PuTTY

PuTTY does not natively support the PEM format that AWS uses, so you need to convert your PEM file to a PPK file (PPK =
PuTTY Private Key) before gaining access to AWS. To do this, you use the PuTTYgen utility.


#### PuTTYgen

To start the utility you can type `puttygen` in the Windows start dialog box.

<img alt="start" width="250px" src="./images/p01.png"/>

In the PuTTYgen dialog box, click the [Load] button:

<img alt="puttygen" width="350px" src="./images/p02.png"/>

When browsing for your pem file be sure to select **All Files** in the dropdown list that is located to the right of the
File name field:

<img alt="key" width="350px" src="./images/p03.png"/>

Select the .pem file that you received (called "student.pem" in the screenshot above) and click [Open].

Read the PuTTYgen Notice and then click [Ok].

<img alt="notice" width="250px" src="./images/p04.png"/>

As the notice states, click on [Save private key]:

> N.B. if you are asked if you want to save they key without a passphrase you can safely click "Yes".

<img alt="save" width="350px" src="./images/p05.png"/>

Name the private key file and save it to a path that is easy to remember (we will use the path to the file in putty).


#### Launch PuTTY

Now that you have converted the pem file to a ppk file, you are ready to use PuTTY. Open putty and type connection
information in the "Host Name" text field:

- The user name for ubuntu VMs running on AWS is "ubuntu"
- The IP address assigned to you (sent via email or assigned in class)

The format should look similar to: `ubuntu@15.16.17.18` (substituting your assigned IP for the example)

<img alt="hostname" width="350px" src="./images/p06.png"/>

Next, in the "Category" column on the left, click on the "+" icon next to the SSH field to expand the section.

In the newly expanded section, click on "Auth".

In the "Private key file for authentication" text field, either type the path to your ppk file or click on the
"Browse..." button to open the "Select private key file" dialog which will let you navigate to the location where you
saved it using Windows explorer.

<img alt="auth" width="350px" src="./images/p07.png"/>

Click the [Open] button to start your SSH session.
