# playlist

## [How To Build a REST API with Node, Prisma and PostgreSQL](https://dev.to/nditah/how-to-build-a-rest-api-with-node-prisma-and-postgresql-429a)

## Introduction

[Prisma](https://www.prisma.io/) is an open-source ORM for [Nodejs](https://nodejs.org/en/about/) and [TypeScript](https://www.typescriptlang.org/) written in [Rust🦀](https://www.rust-lang.org/tools). It consists of 3 main tools:

🔷  [Prisma Client](https://www.prisma.io/client): Auto-generated and type-safe database client
🔷  [Prisma Migrate](https://www.prisma.io/migrate): Declarative data modeling and customizable migrations
🔷  [Prisma Studio](https://www.prisma.io/studio): A GUI to view and edit data in your database.

![Prisma Tools](https://imgur.com/CTGhQZ9.png "Prisma Tools")

These tools aim to increase an application developer’s productivity in their database workflows.

Prisma currently supports PostgreSQL, MySQL, SQLite, SQL Server (preview) and MongoDB (preview).

## Prerequisites
To practice this lesson, you need to have the following:

* Node.js v10 to v14 is installed on your computer.
* PostgreSQL v13 is running which can easily set up with [Docker](https://nditah.hashnode.dev/up-and-running-with-docker-in-5-minute) as demonstrated [here](https://nditah.hashnode.dev/up-and-running-with-docker-in-5-minute).
* Optionally, [VsCode](https://code.visualstudio.com/Download) and a nice cup of tea ☕️


## 🕐 Step 1 — Creating Your TypeScript Project

In this step, you will set up a plain TypeScript project using npm. This project will be the foundation for the REST API you’re going to build throughout the lesson.

First, let's create a new directory for the project:

    $    mkdir playlist


Next, navigate into the directory and initialize an empty npm project.

    $    cd playlist
    $    npm init -y


You will have something similar to this:

```json
Wrote to /home/user/Projects/lesson/playlist/package.json:

{
  "name": "playlist",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
```


Next, setup TypeScript in your project by executing the following command:

    $    npm install typescript ts-node @types/node -D
 
This installs three packages as development dependencies in your project:

🔷 *typescript*: The TypeScript toolchain.
🔷 *ts-node*: A package to run TypeScript applications without prior compilation to JavaScript.
🔷 *@types/node*: The TypeScript type definitions for Node.js.

And lastly, add a *tsconfig.json* file in the playlist directory to ensure TypeScript is properly configured for the project.

_playlist/tsconfig.json_

```json
{
  "compilerOptions": {
    "sourceMap": true,
    "outDir": "dist",
    "strict": true,
    "lib": ["esnext"],
    "esModuleInterop": true
  }
}
```

## 🕐 Step 2 — Setting Up Prisma with PostgreSQL

In this step, you will install the Prisma CLI, create your initial Prisma schema file, and set up PostgreSQL with Docker and connect Prisma to it. The Prisma schema is the main configuration file for your Prisma setup and contains your database schema.

Start by installing the Prisma CLI with the following command:

    $    npm install prisma -D

Next, you’ll set up your PostgreSQL database using Docker. Create a new Docker-Compose file with the following command:

    $    nano docker-compose.yml

Now add the following code to the newly created file:
_playlist/docker-compose.yml_

```yml
version: '3.8'
services:
  postgres:
    image: postgres:13
    restart: always
    environment:
      - POSTGRES_USER=africa
      - POSTGRES_PASSWORD=village_people
    volumes:
      - postgres:/var/lib/postgresql/data
    ports:
      - '5432:5432'
volumes:
  postgres:
```

This Docker Compose file configures a PostgreSQL database that can be accessed via port 5432 of the Docker container. Also note that the database credentials are currently set as **africa** (user name) and **village_people** (user password). You are free to adjust these credentials to your preferred user and password. Save and exit the file.

With this setup in place, go ahead and launch the PostgreSQL database server with the following command:


    $    docker-compose up -d

Hey, it may take a while because the docker image will be pulled and launched, unless you have ran it before. Sip your tea  ☕️  now. When it's done, run:

    $    docker ps 

The output of this command will be similar to this:
```

CONTAINER ID   IMAGE         COMMAND                  CREATED        STATUS        PORTS                                       NAMES
7621fce68710   postgres:13   "docker-entrypoint.s…"   13 hours ago   Up 13 hours   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   playlist_postgres_1

```

With the database server running, you can now create your Prisma setup. Run the following command from the Prisma CLI:

    $    npx prisma init
 
This will print the following output:
```
✔ Your Prisma schema was created at prisma/schema.prisma
  You can now open it in your favorite editor.
```

After you ran the command, the Prisma CLI created a new folder called _prisma_ in your project. It contains the following two files:

🔷 **schema.prisma**
The main configuration file for your Prisma project (will include your data model).

🔷 **.env**
A dotenv file to define your database connection URL.

To make sure Prisma knows about the location of your database, open the .env file and adjust the *DATABASE_URL* environment variable.

First open the **.env** file:

```env
# Set the appropriate value for the Database
DB_HOST=localhost
DB_PORT=5432
DB_SCHEMA=playlist
POSTGRES_USER=africa
POSTGRES_PASSWORD=village_people
POSTGRES_DB=playlist

DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${DB_HOST}:${DB_PORT}/${POSTGRES_DB}?schema=${DB_SCHEMA}&sslmode=prefer
```

## 🕐 Step 3 — Defining Your Data Model and Creating Database Tables

In this step, you will define your data model in the Prisma schema file. 
This data model will then be mapped to the database with Prisma Migrate, which will generate and send the SQL statements for creating the tables that correspond to your data model. 
Since you’re building a _playlist_ application, the main entities of the application will be _artists_ and _songs_.

Prisma uses its own data modeling language to define the shape of your application data.

First, open your *prisma/schema.prisma* file with your favourite editor and make these changes:

```
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}


model Artist {
  id    Int     @default(autoincrement()) @id
  email String  @unique
  name  String?
  songs Song[]
}

model Song {
  id        Int     @default(autoincrement()) @id
  title     String
  content   String?
  released Boolean @default(false)
  singer    Artist?   @relation(fields: [singerId], references: [id])
  singerId  Int?
}

```

You are defining two models, called *Artist* and *Song*. Each of these has a number of fields that represent the properties of the model. The models will be mapped to database tables; the fields represent the individual columns.

Also note that there’s a one-to-many relation between the two models, specified by the *songs* and *singer* relation fields on *Artist* and *Song*. This means that one artist can be associated with many songs.

With these models in place, you can now create the corresponding tables in the database using Prisma Migrate. In your terminal run the following command:

    $    npx prisma migrate dev --name "init"


This command creates a new SQL migration on your filesystem and sends it to the database. The output of this command will be similar to this:
```
Environment variables loaded from .env
Prisma schema loaded from prisma/schema.prisma
Datasource "db": PostgreSQL database "playlist", schema "public" at "localhost:5432"

PostgreSQL database playlist created at localhost:5432

The following migration(s) have been created and applied from new schema changes:

migrations/
  └─ 20210810103751_init/
    └─ migration.sql

Your database is now in sync with your schema.
```


The SQL migration file in the _/home/user/Projects/lesson/playlist/prisma/migrations/20210810103751_init/migration.sql_ directory has the following statements that were executed against the database:

```sql
-- CreateTable
CREATE TABLE "Artist" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT,

    PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Song" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT,
    "released" BOOLEAN NOT NULL DEFAULT false,
    "singerId" INTEGER,

    PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Artist.email_unique" ON "Artist"("email");

-- AddForeignKey
ALTER TABLE "Song" ADD FOREIGN KEY ("singerId") REFERENCES "Artist"("id") ON DELETE SET NULL ON UPDATE CASCADE;
```


## 🕐 Step 4 — Exploring Prisma Client Queries in a Plain Script

Prisma Client is an auto-generated and type-safe query builder that you can use to programmatically read and write data in a database from a Node.js or TypeScript application. You will use it for database access within your REST API routes, replacing traditional ORMs, plain SQL queries, custom data access layers, or any other method of talking to a database.

In this step, you will install Prisma Client and get familiar with the queries you can send with it. Before implementing the routes for your REST API in the next steps, you will first explore some of the Prisma Client queries in a plain, executable script.

First, go ahead and install Prisma Client in your project by opening up your terminal and installing the Prisma Client npm package:

    $    npm install @prisma/client


Next, create a new directory called **src** that will contain your source files and create a TypeScript file inside of the new directory:

    $    nano src/main.ts
 
All of the Prisma Client queries return promises that you can _await_ in your code. This requires you to send the queries inside of an _async_ function.

Add the following boilerplate with an async function that’s executed in your script:

```ts
// playlist/src/main.ts

import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  // ... your Prisma Client queries will go here
}

main()
  .catch((e) => console.error(e))
  .finally(async () => await prisma.disconnect())
```

Here’s a quick breakdown of the boilerplate:

🔷 You import the **PrismaClient** constructor from the previously installed **@prisma/client** _npm_ package.
🔷 You instantiate _PrismaClient_ by calling the constructor and obtain an instance called **prisma**.
🔷 You define an _async_ function called **main** where you’ll add your Prisma Client queries next.
🔷 You call the main function, while catching any potential exceptions and ensuring Prisma Client closes any open database connections by calling **prisma.disconnect()**.

With the main function in place, you can start adding Prisma Client queries to the script. Adjust index.ts to look as follows:

```ts

// playlist/src/main.ts

import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  const newArtist = await prisma.artist.create({
    data: {
      name: 'Osinachi Kalu',
      email: 'sinach@sinachmusic.com',
      songs: {
        create: {
          title: 'I Know Who I Am',
        },
      },
    },
  })
  console.log('Created new artist: ', newArtist)

  const allArtists = await prisma.artist.findMany({
    include: { songs: true },
  })
  console.log('All artists: ')
  console.dir(allArtists, { depth: null })
}

main()
  .catch((e) => console.error(e))
  .finally(async () => await prisma.$disconnect())
```


In this code, you’re using two Prisma Client queries:

1. _create_: Creates a new User record. Notice that you’re actually using a nested write, meaning you’re creating both a Artist and Song record in the same query.
2. _findMany_: Reads all existing Artist records from the database. You’re providing the include option that additionally loads the related Song records for each Artist record.
Now run the script with the following command:


```$    npx ts-node src/main.ts```


You will receive the following output in your terminal:

```
Created new artist:  { id: 1, email: 'sinach@sinachmusic.com', name: 'Osinachi Kalu' }
All artists: 
[
  {
    id: 1,
    email: 'sinach@sinachmusic.com',
    name: 'Osinachi Kalu',
    songs: [
      {
        id: 1,
        title: 'I Know Who I Am',
        content: null,
        released: false,
        singerId: 1
      }
    ]
  }
]
```

Alternatively, you can manipulate the record in the Postgres Database using **Prisma Studio** by running:

    $    npx prisma studio

The output:
```
Environment variables loaded from .env
Prisma schema loaded from prisma/schema.prisma
Prisma Studio is up on http://localhost:5555
```
Go to the browser at  http://localhost:5555 and explore your models. Then hit _Ctrl + C_ to stop _Prisma Studio_ at the terminal or just open a new terminal in the same playlist project directory.


## 🕐 Step 5 — Implementing Your First REST API Route

In this step, you will install Express in your application. Express is a popular web framework for Node.js that you will use to implement your REST API routes in this project. The first route you will implement will allow you to fetch all artists from the API using a GET request. The artist data will be retrieved from the database using Prisma Client.

Go ahead and install Express with the following command:

    $    npm install express
 
Since you’re using TypeScript, you’ll also want to install the respective types as development dependencies. Run the following command to do so:

    $    npm install @types/express -D


Create a new file in the src directory, index.ts and enter the following to start your REST API:

```ts

// playlist/src/index.ts

// #1
import { PrismaClient } from '@prisma/client'
import express from 'express'

// #2
const prisma = new PrismaClient()

// #3
const app = express()

// #4
app.use(express.json())

// #5
app.get('/artists', async (req, res) => {
  const artists = await prisma.artist.findMany()
  res.json({
    success: true,
    payload: artists,
    message: "Operation Successful",
  })
})

app.use((req, res, next) => {
    res.status(404);
    return res.json({
      success: false,
      payload: null,
      message: `API SAYS: Endpoint not found for path: ${req.path}`,
    });
  });

// #6
app.listen(3000, () =>
  console.log('REST API server ready at: http://localhost:3000'),
)
```

Here’s a quick breakdown of the code:

1. You import _PrismaClient_ and express from the respective npm packages.

2. You instantiate PrismaClient by calling the constructor and obtain an instance called _prisma_.

3. You create your Express app by calling express().

4. You add the _express.json()_ middleware to ensure JSON data can be processed properly by Express.

5. You implement your first route by adding the api endpoint between the calls to *app.use* and *app.listen*.

6. You start the server on port 3000.

The output:
```REST API server ready at: http://localhost:3000```


To test your route, open up a browser to [http://localhost:3000](http://localhost:3000/artists).  
Alternatively, open new terminal window or tab (so that your local web server can keep running) and execute the following command:

```curl http://localhost:3000/artists```

 
You will receive the User data that you created in the previous step:

The output:
```json
{"success":true,"payload":[{"id":1,"email":"sinach@sinachmusic.com","name":"Osinachi Kalu"}],"message":"Operation Successful"}
```


Step 6 — Implementing the Remaining REST API Routes

In this step, you will implement the remaining REST API routes for your blogging application. At the end, your web server will serve various *GET*, *POST*, *PUT*, and *DELETE* requests.

Here is an overview of the different routes you will implement:

SN|HTTP Method | Route	               | Description
--|------------|-----------------------|-------------------------
1 |    GET     |   /playlist           |   Fetches all released songs.
2 |    GET     |   /song/:id	       |   Fetches a specific song by its Id.
3 |    POST    |   /artist	           |   Creates a new artist.
4 |    POST    |   /song	           |   Creates (or compose) a new song (unreleased)
5 |    PUT     |   /song/release/:id   |   Sets the released field of a song to true.
6 |    DELETE  |   /song/:id	       |   Deletes a song by its database record Id.




Next, modify the index.ts file to implement the other API routes:
```
// playlist/src/index.ts

import { PrismaClient } from '@prisma/client'
import express from 'express'

const prisma = new PrismaClient()
const app = express()
app.use(express.json())

//* 1. Fetches all released songs.
app.get('/playlist', async (req, res) => {
    const songs = await prisma.song.findMany({
        where: { released: true },
        include: { singer: true }
    })
    res.json({
        success: true,
        payload: songs,
    })
})

//* 2. Fetches a specific song by its ID.
app.get(`/song/:id`, async (req, res) => {
    const { id } = req.params
    const song = await prisma.song.findFirst({
        where: { id: Number(id) },
    })
    res.json({
        success: true,
        payload: song,
    })
})

//* 3. Creates a new artist.
app.post(`/artist`, async (req, res) => {
    const result = await prisma.artist.create({
        data: { ...req.body },
    })
    res.json({
        success: true,
        payload: result,
    })
})

//* 4. Creates (or compose) a new song (unreleased)
app.post(`/song`, async (req, res) => {
    const { title, content, singerEmail } = req.body
    const result = await prisma.song.create({
        data: {
            title,
            content,
            released: false,
            singer: { connect: { email: singerEmail } },
        },
    })
    res.json({
        success: true,
        payload: result,
    })
})

//* 5. Sets the released field of a song to true.
app.put('/song/release/:id', async (req, res) => {
    const { id } = req.params
    const song = await prisma.song.update({
        where: { id: Number(id) },
        data: { released: true },
    })
    res.json({
        success: true,
        payload: song,
    })
})

//* 6. Deletes a song by its ID.
app.delete(`/song/:id`, async (req, res) => {
    const { id } = req.params
    const song = await prisma.song.delete({
        where: { id: Number(id) },
    })
    res.json({
        success: true,
        payload: song,
    })
})

//* 7. Fetches all Artist.
app.get('/artists', async (req, res) => {
    const artists = await prisma.artist.findMany()
    res.json({
        success: true,
        payload: artists,
    })
})

app.use((req, res, next) => {
    res.status(404);
    return res.json({
        success: false,
        payload: null,
        message: `API SAYS: Endpoint not found for path: ${req.path}`,
    });
});

// #6
app.listen(3000, () =>
    console.log('REST API server ready at: http://localhost:3000'),
)

```



You can test the new routes by stopping the server with _CTRL + C_. Then, restart the server using:

    $     npx ts-node src/index.ts


### Test the API routes


1. Fetches all released songs.

```curl http://localhost:3000/playlist
```

2. Fetches a specific song by its ID.

```curl http://localhost:3000/song/1
```

3. Creates a new artist.

```curl -X POST -H "Content-Type: application/json" -d '{"name":"Nditah Sam", "email":"contact@telixia.com"}' http://localhost:3000/artist
```

4. Creates (or compose) a new song (unreleased)

```curl -X POST -H "Content-Type: application/json" -d '{"title":"Take my hand", "singerEmail":"contact@telixia.com"}' http://localhost:3000/song
```

5. Sets the released field of a song to true.

```curl -X PUT http://localhost:3000/song/release/2
```

6. Deletes a song by its database record Id.

```curl -X DELETE http://localhost:3000/song/1
```

7. Re-query playlist again 

```curl http://localhost:3000/playlist
```



Conclusion
In this lesson, you created a REST API server with a number of different routes to create, read, update, and delete Artist and Song data for a sample playlist backend application. Inside of the API routes, you are using the _Prisma Client_ to send the respective queries to your postgres database.

In our next lesson, you will learn [How To Build a GraphQL API with Node, Prisma and Postgres](https://dev.to/nditah/how-to-build-a-graphql-api-with-node-prisma-and-postgres-ajg).

