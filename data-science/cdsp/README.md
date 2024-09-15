![RX-M, llc.](http://rx-m.com/rxm-cnc.svg)


# Certified Data Science Practitioner

This is the lab system setup README for the CDSPv2 course, circa 9/15/2024.
All lab work except the Fine Tuning Module can be completed on a system equivalent
to the following cloud instance:

- AWS t3.medium (2 CPU/4GB RAM)
- 50GB root volume
- Ubuntu 24.04 AMI

The Fine Tuning Module training step requires a t3.xlarge (4 CPU/16GB RAM)
to complete, and will run out of memory on systems with less than 12GB of RAM.
The installation consumes almost 14GB of disk so 20GB of disk space is probably
a reasonable minimum.


## Lab system setup

1. Login to your lab vm (get IP and key from instructor):
    - `ssh -i key.pem ubuntu@x.x.x.x`
3. Run the cdsp install script (takes ~5 minutes):
    - `wget -qO- https://raw.githubusercontent.com/RX-M/classfiles/master/data-science/cdsp/cdsp_setup.bash | bash`
4. Browse to the URL displayed by the script with chrome: `https://<PUBLIC IP>:8080`
5. In the **"Your connection is not private"** page, click the `Advanced` button, then click `Proceed to x.x.x.x (unsafe)`
   (the server TLS cert is self signed)
6. Use the password displayed by the script to login

The script is idempotent and can be run multiple times. If you stop the Jupyter server and would like to
restart it, you can rerun the script but it is faster to just run the server directly:

```
$ source ~/.profile  #ensure your path is updated
$ cd /home/student   #start the server here (many files look on this relative path)
$ jupyter notebook --no-browser --port=8080 --ip=0.0.0.0 --certfile=cert.pem --keyfile=key.pem
```

Press `CTRL+C` twice to stop the server.
