# express-api-setup

# Ubuntu 20.04
run the one line cli command on mac
```
curl -sSL https://raw.githubusercontent.com/cookii-king/express-api-setup/main/mac/setup-server.sh -o setup-server.sh && chmod +x setup-server.sh && ./setup-server.sh
```

if you have an issue when restarting or shutting down your server,
run the one line cli command on mac
```
curl -sSL https://raw.githubusercontent.com/cookii-king/express-api-setup/main/mac/reset-nginx-solution.sh -o reset-nginx-solution.sh && chmod +x reset-nginx-solution.sh && ./reset-nginx-solution.sh
```

The select option 1 so that it can attempt to reinstall the certificates instead of renewing because you limited to 5 renews per week with certbot.
