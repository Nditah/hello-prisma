
// playlist/src/index.ts

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
