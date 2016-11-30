# SSHing into a Raspberry Pi 

If you (your laptop at least) and your Raspberry Pi are both behind firewall/nat
systems and you can not reach the Pi directly, you can still login through an
intermediary on the Internet. Here are the steps using an AWS EC instance as
the intermediary (any cloud instance with a public IP will do). 


1: boot an ubuntu 14.04 box on aws (or somewhere)


2: copy the instance private key to the pi and the laptop (you could put it on S3 and download it)
Make sure the key file is mode 600.


3: add the line "GatewayPorts yes" to /etc/ssh/sshd_config and   

```$ sudo service ssh restart```


4: from the Pi   

```$  ssh -R 19999:localhost:22 ubuntu@52.53.219.151 -i prikey.pem```

- `-R` says remote proxy
- `19999` is whatever port you want the aws box to listen on
- `localhost` is host interface for the aws box to listen on
- the rest is just the login for the aws cloud instance (be sure to substitute you cloud instance ip and key filename)


5: from your laptop ssh into aws box

```$  ssh ubuntu@52.53.219.151 -i prikey.pem```


6: finally from laptop aws session ssh to the Pi through the reverse proxy

```$ ssh pi@localhost -p 19999```

- `pi` is the default RaspberryPi login name (or use the one you set), the default password is "raspberry"
- `localhost` connects to the aws instance local loopback
- `-p 19999` connects to port 19999 (which is reverse proxied to the Pi


You should now see this:

```
ubuntu@ip-10-0-0-41:~$ ssh pi@localhost -p 19999
pi@localhost's password:

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Sep 12 13:57:47 2016
pi@raspberrypi:~ $ 
```
