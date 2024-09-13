![RX-M, llc.](http://rx-m.com/rxm-cnc.svg)


# Certified Data Science Practitioner

This is the lab system setup README for the CDSPv2 course, circa 9/15/2024.


## Lab system setup

1. Login to your lab vm (t3.medium/50GBdisk/Ubuntu24.04; get IP and key from instructor)
   `ssh -i key.pem ubuntu@x.x.x.x`
2. Run the cdsp install script:
   `$ wget -O- https://raw.githubusercontent.com/RX-M/classfiles/master/data-science/cdsp/cdsp_setup.bash | bash`
4. Browse to the URL displayed by the script with chrome: `https://<PUBLIC IP>:8080`
5. In the "Your connection is not private" page, click the `Advanced` button, then click `Proceed to x.x.x.x (unsafe)`
   (the server TLS cert is self signed)
6. Use the password displayed by the script to login

The script is idempotent and can be run as many times as needed. If you stop the Jupyter server
and would like to restart it, you can rerun the script but it is faster to just run the last line
of the script:

```
$ jupyter notebook --no-browser --port=8080 --ip=0.0.0.0 --certfile=cert.pem --keyfile=key.pem
```

Press `CTRL+C` twice to stop the server.
