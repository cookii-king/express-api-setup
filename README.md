# 🌐 Express API Setup

# 💻 Mac

This repository contains the necessary scripts and instructions to set up an Express API server on your Mac.

🚀 To set up your server, you can use AWS, GCP, or Genesis Cloud.

- [Genesis Cloud](https://gnsiscld.co/f8a53) ☁️

Use your SSH public key to connect to the server.

Now, set up the Express API:

```
curl -sSL https://raw.githubusercontent.com/cookii-king/express-api-setup/main/mac/setup-server.sh -o setup-server.sh && chmod +x setup-server.sh && ./setup-server.sh
```

Next, create a new Express API project:

```
curl -sSL https://raw.githubusercontent.com/cookii-king/express-api-setup/main/mac/create-express-api.sh -o create-express-api.sh && chmod +x create-express-api.sh && ./create-express-api.sh
```

You can also provide an application name as an argument when running the script:

```
./create-express-api.sh my-app-name
```

Or execute the script in one line with an application name:

```
curl -sSL https://raw.githubusercontent.com/cookii-king/express-api-setup/main/mac/create-express-api.sh -o create-express-api.sh && chmod +x create-express-api.sh && ./create-express-api.sh my-app-name
```

After creating the Express API project, navigate to the application folder and start your app with:

```
cd my-app-name
node app.js
```

To run your app using PM2, install PM2 globally if you haven't already:

```
npm install pm2 -g
```

Then, start your app with PM2:

```
pm2 start app.js
```

To make sure your app starts automatically on system boot, run:

```
pm2 startup
```

Follow the instructions provided by PM2 to complete the startup configuration.

Finally, save the current PM2 process list:

```
pm2 save
```

🔗 Contains affiliate links.
