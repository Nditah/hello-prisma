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
