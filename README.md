# Agar.pw
This repository contains the original Agar.pw source code for the client and server(s).

## Brief Introduction
### Me
The following code for Agar.pw is not necessarily the best code available. You might notice many mistakes, wrong use of code, and simply just very unorganized and unprofessional. I kindly ask you to please refrain from criticizing my work harshly. I am only a high school student and have taken no classes on computer science. Everything here was the result of me teaching myself how to code with the famous tool we have today called the internet. On the other hand, I would appreciate any good programmers to give me suggestions on how to improve my coding skills.
### Agar.pw History (Why I shut it down!?)
This project originally started as a fun mod/cheat for Miniclip's version of Agario (agar.io). After being shutdown by Miniclip for copyright infringement, I decided to make my own clone of Agario using flash. This was my first time developing a game and I learned a lot during the process. Unfortunately, Agar.pw never regained the amount of users it once had and because school started, I don't have much time to spend updating the game. Additionally, I also am having trouble paying the bills for servers due to lack of funds and ad revenue. I still struggled to keep Agar.pw online, but what ultimately set the nail in the coffin for Agar.pw was Miniclip. I have again been attacked by Miniclip, but this time for trademark infringement. I am tired of dealing with this nonsense and I decided to shut the game down and start a new project. For anyone curious, my next project involves the game "American Truck Simulator".

## Game Servers
### Notice:
- All our game servers are based on [Ogar](https://github.com/OgarProject/Ogar) however, due to some modifications, the original Ogar server will not work with the Agar.pw client!!
- All instructions below are based on an Ubuntu 14.04 Server (however they should work for other linux servers such as Debian with little to no modifications)

### Basic Necessities
The following instructions assume that you have installed a LAMP stack on your server (Apache, MySQL, PHP).

If you haven't and need help with this use Google. There are many tutorials on how to do this.

### Set up policy server
Due to flash security, in order to connect to an Agar.pw Server, you must have a flash socket policy server running on each of your Agar.pw gameservers.

#### Step 1 - Updating & Installing Nodejs
In the linux terminal type in the following commands to update the server and install node.js and npm.
- **Node.js:** "javascript platform for server-side programming"
- **npm:** "Node.js package manager"
```
sudo apt-get update
sudo apt-get install nodejs
sudo apt-get install npm
```

#### Step 2 - Installing Policy Server
Installing the socket policy server is easy if nodejs is successfuly installed. Simply input the following command in the linux terminal.
```
npm install -g socket-policy-server
```

#### Step 3 - Configuring the Policy Server
Create a file named `socket_policy.xml` in your /root/ directory on your server.
Inside this file paste the following code:
```xml
<?xml version='1.0'?>
<cross-domain-policy>
	<allow-access-from domain="*" to-ports="PORTS_HERE"/>
</cross-domain-policy>
```
After the `to-ports` attribute you will need to state all the ports of all the gameservers that will be running on this particular server along with the ports of the stats server (more on this later).
To state multiple ports use a comma without a space like this: `2000,2001`. You can also try using ranges; however, I am **not sure** if they work: `2000-3000`.

#### Step 4 - Applying the Configuration
To apply the configuration to the socket policy server type in the following command in the terminal:
```
npm config --global set socket-policy-server:policyfile /root/socket_policy.xml
```

#### Step 5 - Running the Server
You will need the following commands for running, stopping, and/or restarting the policy server.
```
npm -g start socket-policy-server
```
Starts the server
```
npm -g stop socket-policy-server
```
Stops the server
```
npm -g restart socket-policy-server
```
Restarts the server

### Create the Agar.pw Skins Database
To avoid running into any technical difficulties, it is best to set up the Agar.pw skins database even if you are not going to be using custom skins.

#### Step 1 - Loging in MySQL
In the linux terminal of the server you want to have the skins database on, type in the following to connect to the mysql database.
```
mysql -u [user] -p
```
Replace `[user]` with your mysql user.

After you press enter and typed in your database's password, type in the following sql code:
```
CREATE DATABASE `agarpw`;
USE `agarpw`;
source /root/database.sql;
```
If everything went smoothly press `CTRL+C` to log out of MySQL.

You have now created a agar pw skins database with one skin. (sample skin id= `opensource`)

### Set up the Agar.pw Gameserver
You're done installing the policy server and now it's time to install and set up the actual agar.pw gameserver!

**Reminder:** Credit goes to the [Ogar Project](https://github.com/OgarProject/Ogar), as this is just an Ogar server with modifications.

#### Step 1 - Downloading the Gameserver
Please download `/server/pwserver.zip` from this repository and extract it into your `/root` folder on your server.

#### Step 2 - Setting Up the Gameserver
```
cd /root/pwserver
```
With the linux terminal navigate to the pwserver folder holding the src folder and the Ogar README and LICENSE files.
```
npm install ws
npm install mysql
```
Now install the required nodejs packages.
```
cd src
```
Navigate to the src folder within the pwserver folder to begin configuring the gameserver.
```
nano gameserver.ini
```
Use nano, vi, or your favorite text editor to modify the gameserver.ini file.

First look for the `serverPort` attribute and change it to the port you want your server to run on.

Next look for the `serverStatsPort` attribute and change it to the port you want your stats server to run on. This is the server that reports how many people are playing on the current gameserver.

*These ports must match the ports you added in your socket policy configuration file (`socket_policy.xml`) in the previous steps.*

Save and close the file. To do this with the `nano` editor, press `CTRL + X`, then the `y` key, and finally the `enter` key.

#### Step 3 - More Set-Up
```
nano PacketHandler.js
```
Now we need to modify the PacketHandler file still in the src directory.

Scroll down till you see the `MySQL CONFIGURATION` comment.

Change the `host` attribute to the ip address of your server with the skins database. If this is on the same server then leave it as `localhost`.

Modify the `user` and `password` attribute to match one of your database's users which has access to the skins table in your agarpw database. If the host is not `localhost` be sure that you also allowed different hosts to connect to the database with that user.

Save and close this file.

### Step 4 - Testing & Running the Agar.pw Server
Congratulations! You should now be able to start your new Agar.pw gameserver with the following command:
```
nodejs index.js
```
If the above did not work, try this:
```
node index.js
```

## Game Client
Simply upload the `agarpw.swf` on a public html page on your web server with the servers.xml file in the directory.

Need more help with the client? [Vote Here](http://strawpoll.me/6932390)
