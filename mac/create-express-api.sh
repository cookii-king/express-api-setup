#!/bin/bash

# If an argument was provided, use it as the application name
if [ $# -eq 1 ]; then
    app_name=$1
else
    # Ask the user for the application name
    read -p "Enter the application name: " app_name
fi

# Create a new directory for your project
mkdir $app_name

# Navigate into the directory
cd $app_name

# Initialize a new Node.js application
npm init -y

# Install Express.js
npm install express

# Add some basic code to your application using a Here Document
cat << EOF > app.js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log(\`App listening at http://localhost:\${port}\`);
});
EOF

echo "Express API named '$app_name' has been created and is ready to use."
echo "Navigate to the application folder and start your app with 'node app.js'"

sudo rm -r /home/ubuntu/create-express-api.sh
