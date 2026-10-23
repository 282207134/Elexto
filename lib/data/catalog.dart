class Track {
  const Track(this.id, this.title, this.artist, this.artwork, this.audio);
  final String id, title, artist, artwork, audio;
}

const tracks = [
  Track('1', 'Girl Like You', 'Avinci John', 'song-1', 'demo-1'),
  Track('2', 'Someone You Live', 'Arian Grande', 'song-2', 'demo-2'),
  Track('3', 'In My Feelings', 'Alan Walker', 'song-3', 'demo-3'),
  Track('4', 'Love You To Love Me', 'Maroon 5', 'song-4', 'demo-1'),
  Track('5', 'Hot Girl Bummer', 'Blackbear', 'song-2', 'demo-2'),
  Track('6', '10,000 Hours', 'Justin Bieber', 'song-1', 'demo-3'),
  Track('7', 'Stupid Love', 'Alan Walker', 'song-3', 'demo-1'),
  Track('8', 'Escape From LA', 'The Weekend', 'song-4', 'demo-2'),
  Track('9', 'My Heart Will Go On', 'Céline Dion', 'album-2', 'demo-3'),
  Track(
    '10',
    'Mashup: We Dont Talk Anymore',
    'Charlie Puth',
    'album-1',
    'demo-1',
  ),
  Track('11', 'Mashup Bad Liar - What', 'Young Thug', 'weekly', 'demo-2'),
  Track('12', 'My Oh My', 'Camila Cabello, DaBaby', 'song-4', 'demo-3'),
];
const genreNames = [
  'Avant Garde',
  'Baroque',
  'High Classical',
  'Chant',
  'Classical Crossover',
  'Early Music',
  'Chamber Music',
  'Choral',
];
const topicNames = ['Classic', 'POP', 'Jazz', 'Dance', 'Metal', 'R&B'];
