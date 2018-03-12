# RX-M - SSH setup for Cloud Lab Access

RX-M courses can be delivered in conjunction with a cloud based lab environment. To access a cloud lab 
system students will need to have an ssh client installed on their computer and internet ssh access 
(port 22). 

Any mainstream ssh client will work and OSX/Linux computer systems have a good ssh client preinstalled. 

Here are some suggested ssh client tools for Windows systems:

- Putty (free) [Windows] https://www.putty.org/
- MobaXTerm (free and paid) [Windows] https://mobaxterm.mobatek.net/download.html
- GitBash ssh command line client (free, part of Git distribution) [Windows/OSX/Linux] https://git-scm.com/downloads

GUI clients like Putty and MobaXTerm have thier own help systems and client access configuration. 
Command line clients can generally access the cloud lab site with a command something like this:

```
$ ssh -i key.pem ubuntu@host.ip.ad.dr
```

Where "ubuntu" is the default user name (the instructor may supply students with a different user name 
in class) and "host.ip.ad.dr" is the host IP address of the student lab system supplied by the instructor 
during class (e.g. 54.23.87.45). The -i switch (for identity) is optional and may be required in some 
classes. This allows you to pass a key file to the ssh client ("key.pem" in the example) for extra security.

Student lab system IP addresses and passwords are passed out on day one of classes with cloud based labs.
