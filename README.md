
# DevOps User Management App

This is a full-stack application for managing users with a front-end built using HTML, CSS, and JavaScript, and a back-end powered by Node.js, Express, and MySQL.

## Table of Contents

- [DevOps User Management App](#devops-user-management-app)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Prerequisites](#prerequisites)
  - [Setup Instructions](#setup-instructions)
    - [1. Setting Up MySQL Server](#1-setting-up-mysql-server)
    - [2. Configuring and Running the Client](#2-configuring-and-running-the-client)
    - [3. Configuring and Running the Server](#3-configuring-and-running-the-server)
  - [Usage](#usage)
    - [User Management Features:](#user-management-features)
  - [License](#license)
    - [NOTE: This Application Should not be used for commercial purpose by anyone else other than DevOps Shack](#note-this-application-should-not-be-used-for-commercial-purpose-by-anyone-else-other-than-devops-shack)

## Features

- Add new users with a name, email, and role (User/Admin).
- View a list of all users.
- Edit user details.
- Delete users.
- Responsive and user-friendly UI.
- Smooth animations and minimalistic design.

## Prerequisites

Before setting up this project, ensure you have the following installed on your machine:

- [Node.js](https://nodejs.org/) (version 12.x or higher)
- [MySQL](https://www.mysql.com/) (version 5.7 or higher)

## Setup Instructions

### 1. Setting Up MySQL Server

First, you need to set up a MySQL server on your local machine.

1. **Update the package index:**

   ```bash
   sudo apt update
   ```

2. **Install the MySQL server:**

   ```bash
   sudo apt install mysql-server
   ```

3. **Log in to the MySQL shell as root:**

   ```bash
   sudo mysql -u root
   ```

4. **Set a password for the root user and update the authentication method:**

   ```sql
   ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
   FLUSH PRIVILEGES;
   ```

   Replace `'password'` with a secure password of your choice.

5. **Exit the MySQL shell:**

   ```sql
   exit;
   ```

6. **Log in to the MySQL shell again with the new password:**

   ```bash
   sudo mysql -u root -p
   ```
   Enter the password you set in the previous step.

   Check the user and host
   ```sh
   SELECT user, host, plugin FROM mysql.user WHERE user='root';
   ```

7. **Create a new database:**

   ```sql
   CREATE DATABASE test_db;
   ```

8. **Switch to the new database:**

   ```sql
   USE test_db;
   ```

9. **Create the `users` table:**

   ```sql
   CREATE TABLE users (
       id INT AUTO_INCREMENT PRIMARY KEY,
       name VARCHAR(255) NOT NULL,
       email VARCHAR(255) NOT NULL UNIQUE,
       role ENUM('Admin', 'User') NOT NULL
   );
   ```

   This table will store user information, including their name, email, and role.

### 2. Configuring and Running the Client

The client side of the application is built using modern JavaScript, HTML, and CSS. To configure and run the client:

1. **Navigate to the client folder:**

   ```bash
   cd client
   ```

2. **Install the required dependencies:**

[install nodejs and npm](https://nodejs.org/en/download/)

   ```bash
   npm install # both the server and client

   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

   ```

   ```sh
38 packages are looking for funding
  run `npm fund` for details

6 vulnerabilities (4 moderate, 2 high)
```
fix
```sh
npm audit
npm audit fix 

npm audit fix --force
```


1. **Build the client application:**

```sh
npm run build # only at client side
```

   This will create a production build of the client application, which will be served by the Express server.

### 3. Configuring and Running the Server

The server side is built using Node.js and Express and connects to the MySQL database to manage user data.

1. **Navigate to the server folder:**

   ```bash
   cd server
   ```

2. **Install the required dependencies:**

   ```bash
   npm install
   ```

3. **Start the server:**

   ```bash
   npm start
   ```

   The server will run on `http://localhost:5000` by default.

## Usage

After following the setup instructions, you can access the application by navigating to `http://localhost:5000` in your web browser.

### User Management Features:

- **Add User:** Fill in the name, email, and role in the form and click "Add User" to add a new user.
- **View Users:** The user list will be displayed below the form. Each user entry will have "Edit" and "Delete" buttons.
- **Edit User:** Click the "Edit" button next to a user entry to update their details.
- **Delete User:** Click the "Delete" button next to a user entry to remove them from the list.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### NOTE: This Application Should not be used for commercial purpose by anyone else other than DevOps Shack


```sh
docker compose down
docker compose up -d --build

docker logs -f app # very important

then: http://localhost:5000
```
-f means follow.

docker logs -f app streams the container’s logs in real time (like tail -f). It keeps the terminal attached and prints new lines as the app writes to stdout/stderr until you stop it (Ctrl+C).

Interactive way
```sh
# 1) Get a shell inside the MySQL container
docker exec -it mysql /bin/bash

# 2) Start the MySQL client (enter the root password when prompted: password)
mysql -u root -p
```

Inside the MySQL prompt:
```sh
SHOW DATABASES;
USE test_db;
SHOW TABLES;
SELECT * FROM users;
```

One-liners from the host (no shell inside)
```sh
# Show databases
docker exec -it mysql mysql -uroot -ppassword -e "SHOW DATABASES;"

# Switch DB and list tables
docker exec -it mysql mysql -uroot -ppassword -e "USE test_db; SHOW TABLES;"

# Query rows
docker exec -it mysql mysql -uroot -ppassword -e "USE test_db; SELECT * FROM users;"
```

(If you ever need to create the table)
```sh
docker exec -it mysql mysql -uroot -ppassword -e "
CREATE DATABASE IF NOT EXISTS test_db;
USE test_db;
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  role VARCHAR(50) NOT NULL
);"
```

Size of each running container’s writable layer

(How much the container has written on top of the image)
```sh
docker ps -s
# or
docker container ls -s
```

(Optional) Reclaim space — be careful!
```sh
docker container prune        # remove stopped containers
docker image prune -a         # remove unused images
docker volume prune           # remove unused volumes
docker system prune -a --volumes
```

Tip: For your stack, check quickly:
```sh
docker ps -s                   # writable size of app and mysql
docker system df -v            # see mysql_data volume size
```