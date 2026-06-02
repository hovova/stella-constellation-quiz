import '../models/constellation.dart';

const List<Constellation> beginnerConstellations = [
  Constellation(
    id: 'orion',
    name: 'Orion',
    difficulty: 'Beginner',
    hemisphere: 'Northern and Southern',
    bestSeason: 'Winter',
    brightestStar: 'Rigel',
    imagePath: 'assets/constellations/orion.png',
    description:
        'Orion is one of the most recognisable constellations in the night sky. Its three-star belt makes it easy to identify.',
    mythology:
        'In Greek mythology, Orion was a great hunter. The constellation is often shown as a hunter holding a club and shield.',
  ),
  Constellation(
    id: 'ursa_major',
    name: 'Ursa Major',
    difficulty: 'Beginner',
    hemisphere: 'Northern',
    bestSeason: 'Spring',
    brightestStar: 'Alioth',
    imagePath: 'assets/constellations/ursa_major.png',
    description:
        'Ursa Major is famous for containing the Big Dipper asterism, one of the easiest star patterns to find.',
    mythology:
        'Its name means Great Bear. In mythology, it is often connected to the story of Callisto, who was transformed into a bear.',
  ),
  Constellation(
    id: 'ursa_minor',
    name: 'Ursa Minor',
    difficulty: 'Beginner',
    hemisphere: 'Northern',
    bestSeason: 'All year',
    brightestStar: 'Polaris',
    imagePath: 'assets/constellations/ursa_minor.png',
    description:
        'Ursa Minor contains Polaris, the North Star, which has historically been used for navigation.',
    mythology:
        'Its name means Little Bear. It is often linked with Ursa Major in ancient sky stories.',
  ),
  Constellation(
    id: 'cassiopeia',
    name: 'Cassiopeia',
    difficulty: 'Beginner',
    hemisphere: 'Northern',
    bestSeason: 'Autumn',
    brightestStar: 'Schedar',
    imagePath: 'assets/constellations/cassiopeia.png',
    description:
        'Cassiopeia is easy to recognise because its brightest stars form a clear W or M shape in the sky.',
    mythology:
        'Cassiopeia was a queen in Greek mythology, known for her beauty and pride.',
  ),
  Constellation(
    id: 'scorpius',
    name: 'Scorpius',
    difficulty: 'Beginner',
    hemisphere: 'Southern',
    bestSeason: 'Summer',
    brightestStar: 'Antares',
    imagePath: 'assets/constellations/scorpius.png',
    description:
        'Scorpius has a curved shape that resembles a scorpion and contains the bright red star Antares.',
    mythology:
        'Scorpius is associated with the scorpion that killed Orion in Greek mythology.',
  ),
  Constellation(
    id: 'leo',
    name: 'Leo',
    difficulty: 'Beginner',
    hemisphere: 'Northern and Southern',
    bestSeason: 'Spring',
    brightestStar: 'Regulus',
    imagePath: 'assets/constellations/leo.png',
    description:
        'Leo represents a lion and is one of the zodiac constellations. Its sickle-shaped pattern is fairly easy to spot.',
    mythology:
        'Leo is commonly linked to the Nemean Lion defeated by Heracles in Greek mythology.',
  ),
  Constellation(
    id: 'cygnus',
    name: 'Cygnus',
    difficulty: 'Beginner',
    hemisphere: 'Northern',
    bestSeason: 'Summer',
    brightestStar: 'Deneb',
    imagePath: 'assets/constellations/cygnus.png',
    description:
        'Cygnus is known as the Swan and forms a cross-like shape in the Milky Way.',
    mythology:
        'Cygnus is associated with several myths involving swans, transformation and the gods.',
  ),
  Constellation(
    id: 'lyra',
    name: 'Lyra',
    difficulty: 'Beginner',
    hemisphere: 'Northern',
    bestSeason: 'Summer',
    brightestStar: 'Vega',
    imagePath: 'assets/constellations/lyra.png',
    description:
        'Lyra is a small constellation containing Vega, one of the brightest stars in the night sky.',
    mythology:
        'Lyra represents the lyre of Orpheus, the legendary musician of Greek mythology.',
  ),
  Constellation(
    id: 'taurus',
    name: 'Taurus',
    difficulty: 'Beginner',
    hemisphere: 'Northern and Southern',
    bestSeason: 'Winter',
    brightestStar: 'Aldebaran',
    imagePath: 'assets/constellations/taurus.png',
    description:
        'Taurus represents a bull and contains the bright star Aldebaran and the famous Pleiades star cluster.',
    mythology:
        'Taurus is linked to several ancient bull myths, including the Greek myth of Zeus transforming into a bull.',
  ),
  Constellation(
    id: 'gemini',
    name: 'Gemini',
    difficulty: 'Beginner',
    hemisphere: 'Northern and Southern',
    bestSeason: 'Winter',
    brightestStar: 'Pollux',
    imagePath: 'assets/constellations/gemini.png',
    description:
        'Gemini is one of the zodiac constellations and is recognised by its two bright stars, Castor and Pollux.',
    mythology:
        'Gemini represents the twins Castor and Pollux from Greek and Roman mythology.',
  ),
];

const List<Constellation> allConstellations = [
  ...beginnerConstellations,
];