//
//  ProQuestions.swift
//  QuizApp
//
//  The question bank behind the Pro Challenge modes. These are written
//  fresh rather than borrowed from the islands, so a Pro round always
//  feels like new ground even for a child who has cleared the whole map.
//
//  Three tiers, following the same rules as the island content: four
//  options each, a rich "Did you know?" explanation that teaches something
//  ABOUT the answer instead of repeating it, and correct answers spread
//  evenly across A/B/C/D.
//
//    easy   — instant recall for a 7 year old, for the Lightning Round
//    medium — needs a moment's thought
//    hard   — precise facts, genuinely challenging for kids
//
//  Category Master doesn't use this bank: picking one island and drawing
//  from its own ten levels is exactly what "one category only" means.
//

import Foundation

enum ProQuestions {

    // MARK: - Easy

    static let easy: [Question] = [
        Question(
            prompt: "What do we call the person who flies an aeroplane?",
            options: ["A sailor", "A driver", "A pilot", "A guard"],
            correctIndex: 2,
            explanation: "Two of them sit up front and they are required to eat different meals, so that one bad dish can never affect both at once. Most of a modern flight is flown by computer, with the crew watching over it and taking the controls for take-off and landing."),
        Question(
            prompt: "What colour do you get when you mix red and yellow?",
            options: ["Purple", "Green", "Brown", "Orange"],
            correctIndex: 3,
            explanation: "Red and yellow are two of the three primary colours, the ones that cannot be mixed from anything else. Painters have known this for centuries. Mix all three primaries together and you get a muddy brown — which is why paint water goes murky so fast."),
        Question(
            prompt: "How many days are there in one week?",
            options: ["Seven", "Five", "Ten", "Twelve"],
            correctIndex: 0,
            explanation: "The week is the one unit of time that has nothing to do with the sky. Days come from Earth spinning and years from its orbit, but the week is a human invention, roughly a quarter of a moon's cycle. Almost every country on Earth now uses it."),
        Question(
            prompt: "What do bees make inside their hive?",
            options: ["Butter", "Honey", "Milk", "Jam"],
            correctIndex: 1,
            explanation: "Bees fan their wings over nectar to dry it into something thick that never spoils. Jars of it have been found in ancient Egyptian tombs, still perfectly good after three thousand years. One small worker bee makes about a twelfth of a teaspoon in her whole life."),
        Question(
            prompt: "How many sides does a triangle have?",
            options: ["Four", "Five", "Two", "Three"],
            correctIndex: 3,
            explanation: "This is the sturdiest shape in the world. Push on a square and it squashes into a lopsided diamond, but a triangle cannot change shape without a side actually breaking. That is why you spot them inside bridges, cranes, roofs and bicycle frames everywhere."),
        Question(
            prompt: "What is frozen water called?",
            options: ["Steam", "Sand", "Ice", "Salt"],
            correctIndex: 2,
            explanation: "Here is the strange part: it floats. Almost everything else shrinks and sinks when it freezes, but water spreads out instead, so it sits on top. If it sank, ponds would freeze solid from the bottom and the fish inside would have nowhere to survive the winter."),
        Question(
            prompt: "Which animal carries its baby in a pouch?",
            options: ["Kangaroo", "Camel", "Donkey", "Goat"],
            correctIndex: 0,
            explanation: "A newborn is the size of a jellybean, pink and blind, and it must crawl all the way to the pouch by itself. It stays in there for about six months, drinking milk and growing. Once it hops out it still dives back in head first when it is startled."),
        Question(
            prompt: "What do caterpillars turn into?",
            options: ["Spiders", "Butterflies", "Beetles", "Frogs"],
            correctIndex: 1,
            explanation: "Inside the chrysalis the caterpillar almost completely dissolves into a soup, then rebuilds itself into something with wings. Astonishingly, memories can survive the change: a caterpillar taught to avoid a smell still avoids it after it has wings. Same creature, entirely new body."),
        Question(
            prompt: "What do we call a house built from blocks of snow?",
            options: ["A tent", "An igloo", "A barn", "A cabin"],
            correctIndex: 1,
            explanation: "Snow is full of trapped air, which makes it a surprisingly good blanket. Inside one of these it can be forty degrees warmer than the freezing night outside, warmed by nothing more than the bodies of the people sheltering in it."),
        Question(
            prompt: "Which shape has no corners at all?",
            options: ["Square", "Triangle", "Circle", "Rectangle"],
            correctIndex: 2,
            explanation: "Every single point on its edge sits exactly the same distance from the middle, which is why it rolls so smoothly. It is also the greediest shape there is: for any given length of edge, nothing else can wrap up more space inside than this one does."),
        Question(
            prompt: "What do we call the water that falls from clouds?",
            options: ["Dust", "Rain", "Smoke", "Wind"],
            correctIndex: 1,
            explanation: "Cartoons draw the drops as teardrops with a pointed top, but real ones are shaped more like tiny burger buns, flat underneath from pushing through the air. They fall surprisingly fast too — a big drop hits the ground at around thirty kilometres an hour."),
        Question(
            prompt: "How many fingers are there on two hands?",
            options: ["Ten", "Eight", "Twelve", "Five"],
            correctIndex: 0,
            explanation: "This is very likely why we count in tens instead of some other number. The word 'digit' means both a finger and a number, because people counted on their hands long before they wrote anything down. Your thumb is the clever one — it lets you grip and hold."),
        Question(
            prompt: "Which sense do you use with your nose?",
            options: ["Hearing", "Smell", "Sight", "Touch"],
            correctIndex: 1,
            explanation: "This is the sense most tightly wired to memory, which is why one sniff of a place can throw you back years in an instant. It also does most of the work you think your tongue is doing — pinch your nose while eating and the flavour nearly vanishes."),
        Question(
            prompt: "What do you call a baby cat?",
            options: ["Cub", "Foal", "Kitten", "Calf"],
            correctIndex: 2,
            explanation: "They are born deaf and blind, with their eyes sealed shut for about a week. Every one of them starts out with blue eyes, and the real colour only arrives at a couple of months old. The purring begins remarkably early, at just a few days."),
        Question(
            prompt: "What season comes straight after winter?",
            options: ["Autumn", "Summer", "Winter again", "Spring"],
            correctIndex: 3,
            explanation: "Seasons happen because Earth leans over as it travels, tipping each half of the world towards the Sun in turn. That means the seasons are swapped between the top and bottom of the planet — while one country is warming up, the other is heading into its cold."),
        Question(
            prompt: "Which animal is famous for its black and white stripes?",
            options: ["Zebra", "Lion", "Bear", "Fox"],
            correctIndex: 0,
            explanation: "No two of them share a pattern, exactly like fingerprints, and a foal learns its own mother by the stripes on her back. Scientists now think the pattern is mostly about flies: biting insects find it very hard to land on stripes."),
        Question(
            prompt: "Which meal do people usually eat first thing in the morning?",
            options: ["Dinner", "Supper", "Breakfast", "Lunch"],
            correctIndex: 2,
            explanation: "The word simply means breaking the fast — the long stretch overnight when you eat nothing at all. Your body has been running on stored energy for hours by the time you wake, which is why that first meal makes such a difference to how the morning feels."),
        Question(
            prompt: "What do we call the Moon's journey around the Earth?",
            options: ["A bounce", "A tumble", "A slide", "An orbit"],
            correctIndex: 3,
            explanation: "It takes about 27 days, and here is the curious part: the Moon spins exactly once in that same time. Because the two match perfectly, the very same face is turned towards us always. Nobody on Earth saw the far side until a spacecraft flew past in 1959."),
        Question(
            prompt: "What do we call a young sheep?",
            options: ["A lamb", "A calf", "A piglet", "A chick"],
            correctIndex: 0,
            explanation: "They can stand within minutes of being born and recognise their mother's voice among hundreds of others in the flock. Their wool starts out soft and curly, and the first coat shorn from a young sheep is the finest and most valuable of all."),
        Question(
            prompt: "Which animal carries its house on its back and moves very slowly?",
            options: ["Mouse", "Snail", "Rabbit", "Duck"],
            correctIndex: 1,
            explanation: "The shell grows along with its owner, curling round in a spiral, and it can never be swapped or left behind. Underneath, the whole animal glides along on one enormous muscular foot, laying down slime so it can even cross a knife blade without a scratch."),
        Question(
            prompt: "What do we call a baby frog?",
            options: ["Chick", "Cub", "Tadpole", "Puppy"],
            correctIndex: 2,
            explanation: "It starts life looking nothing like its parents — no legs, a long swimming tail, and gills for breathing underwater like a fish. Over a few weeks the legs sprout, the tail shrinks away, and lungs take over so it can finally climb out onto land."),
        Question(
            prompt: "How many letters are in the English alphabet?",
            options: ["Twenty", "Thirty", "Fifty", "Twenty-six"],
            correctIndex: 3,
            explanation: "The order has barely changed in two thousand years, handed down from the Romans. English used to have a few more, including a letter called 'thorn' that made the 'th' sound. Printers had no block for it, so they swapped in a 'y' — hence 'Ye Olde Shoppe'."),
        Question(
            prompt: "Which food comes from a cow?",
            options: ["Milk", "Rice", "Bread", "Apples"],
            correctIndex: 0,
            explanation: "A cow has one stomach but four separate chambers inside it, and she brings her food back up to chew it all over again. She spends around eight hours a day just chewing. All that work is what turns tough grass into something so rich and creamy."),
        Question(
            prompt: "What is the hottest thing in our sky during the day?",
            options: ["A cloud", "The wind", "The Sun", "A bird"],
            correctIndex: 2,
            explanation: "It is so vast that a million Earths would fit inside it, and it holds well over 99 percent of everything in the solar system. Its light takes just over eight minutes to reach us, so you always see it as it looked eight minutes ago."),
        Question(
            prompt: "What do plants use to soak up water from the soil?",
            options: ["Petals", "Leaves", "Thorns", "Roots"],
            correctIndex: 3,
            explanation: "They spread out much further underground than most people imagine — often as wide as the branches overhead. They grip the plant against the wind, and the very tips are covered in tiny hairs, far too small to see, that do nearly all of the drinking."),
        Question(
            prompt: "How many wheels does a bicycle have?",
            options: ["Two", "Three", "Four", "One"],
            correctIndex: 0,
            explanation: "It is the most efficient way of travelling ever invented — you go further on the energy in one bowl of porridge than a car does on the same energy. Staying upright is partly a trick of steering: you are constantly making tiny corrections without noticing."),
        Question(
            prompt: "What do we call frozen rain that falls as soft white flakes?",
            options: ["Hail", "Snow", "Fog", "Mist"],
            correctIndex: 1,
            explanation: "Every flake grows six arms, never five or seven, because of the way water molecules lock together as they freeze. Each one takes a slightly different path down through the cloud, so no two ever grow into quite the same shape on the way."),
        Question(
            prompt: "Which part of your body do you use to hear?",
            options: ["Nose", "Elbow", "Ears", "Knees"],
            correctIndex: 2,
            explanation: "They do a second job you would never guess: keeping you balanced. Deep inside sit tiny loops of fluid that slosh about as you move, telling your brain which way up you are. Spin around fast and the fluid keeps swirling, which is why you feel dizzy."),
        Question(
            prompt: "What colour is grass usually?",
            options: ["Blue", "Red", "Purple", "Green"],
            correctIndex: 3,
            explanation: "The colour comes from chlorophyll, the substance that lets a plant catch sunlight and turn it into food. It soaks up red and blue light but bounces this colour straight back at your eyes. In autumn the chlorophyll drains away, letting other colours finally show."),
        Question(
            prompt: "Which instrument has black and white keys?",
            options: ["A piano", "A drum", "A flute", "A violin"],
            correctIndex: 0,
            explanation: "There are 88 keys, and pressing one swings a small felt hammer at a tightly stretched wire inside. All that tension adds up: the frame has to hold back a pull of roughly twenty tonnes, which is why the instrument is built around a plate of solid iron.")
    ]

    // MARK: - Medium

    static let medium: [Question] = [
        Question(
            prompt: "Which is the largest ocean on Earth?",
            options: ["Atlantic Ocean", "Indian Ocean", "Pacific Ocean", "Arctic Ocean"],
            correctIndex: 2,
            explanation: "It is so wide that every single continent could be dropped into it and there would still be room to spare. It holds about half of all the water on the planet. Its name means 'peaceful', given by sailors who happened to cross it in unusually calm weather."),
        Question(
            prompt: "Which gas do plants take in from the air to make their food?",
            options: ["Carbon dioxide", "Oxygen", "Helium", "Nitrogen"],
            correctIndex: 0,
            explanation: "Plants pull it in through thousands of tiny mouths on the underside of each leaf, which open and close through the day. Mixed with water and sunlight it becomes sugar, and oxygen is left over as waste — the very waste that every animal on Earth breathes."),
        Question(
            prompt: "What do we call a word that means the opposite of another?",
            options: ["A synonym", "An antonym", "A verb", "A rhyme"],
            correctIndex: 1,
            explanation: "English is unusually rich in these because it borrowed words from so many languages at once, often keeping several that mean nearly the same thing. That is why you can be small, little, tiny or minute, each with its own slightly different flavour."),
        Question(
            prompt: "Which punctuation mark belongs at the end of a question?",
            options: ["A comma", "A full stop", "An exclamation mark", "A question mark"],
            correctIndex: 3,
            explanation: "It grew out of the Latin word for question, once written above the last letter of a sentence and squashed over centuries into the squiggle we use now. Spanish is tidier about it and puts an upside-down one at the start as a warning."),
        Question(
            prompt: "At what temperature in Celsius does water freeze?",
            options: ["0 degrees", "10 degrees", "32 degrees", "100 degrees"],
            correctIndex: 0,
            explanation: "The Celsius scale was built around water on purpose, with freezing and boiling as its two fixed marks. Oddly, the inventor originally had it upside down, with 100 for freezing, and it was flipped to the sensible way round only after his death."),
        Question(
            prompt: "How many millimetres make one centimetre?",
            options: ["One", "Five", "Ten", "One hundred"],
            correctIndex: 2,
            explanation: "The whole metric system works in steps of ten, which is why converting is just a matter of sliding the decimal point. It was designed in France in the 1790s to sweep away hundreds of local measures that changed from one town to the next."),
        Question(
            prompt: "Which instrument has six strings and is usually strummed?",
            options: ["The harp", "The guitar", "The trumpet", "The cello"],
            correctIndex: 1,
            explanation: "The sound does not really come from the strings, which are far too thin to move much air. They shake the wooden body instead, and it is that big hollow box doing the singing — which is why the shape and the wood change the tone so much."),
        Question(
            prompt: "How many chambers does the human heart have?",
            options: ["Two", "Six", "Three", "Four"],
            correctIndex: 3,
            explanation: "It is really two pumps side by side: one pushes blood to the lungs to collect oxygen, the other sends it out to the rest of you. The whole thing beats around 100,000 times a day without a single rest, powered by its own built-in electrical pulse."),
        Question(
            prompt: "Which bird cannot fly but can run faster than a person?",
            options: ["Ostrich", "Eagle", "Swan", "Parrot"],
            correctIndex: 0,
            explanation: "It has just two toes on each foot, unusual among birds, and one of them carries a claw that can seriously injure a lion. Its eye is bigger than its brain — in fact bigger than the eye of almost any other land animal alive today."),
        Question(
            prompt: "Which gas makes up most of the air we breathe?",
            options: ["Oxygen", "Nitrogen", "Carbon dioxide", "Hydrogen"],
            correctIndex: 1,
            explanation: "It makes up about four fifths of every breath you take, yet your body does nothing with it at all and simply breathes it back out. Plants cannot use it straight from the air either — bacteria in the soil have to capture it first and pass it along."),
        Question(
            prompt: "How many colours are there in a rainbow?",
            options: ["Three", "Five", "Seven", "Ten"],
            correctIndex: 2,
            explanation: "There are really no separate bands at all — the colours blend smoothly and it was Isaac Newton who chose where to draw the lines, adding one extra so the count matched the notes in a musical scale. A rainbow is also a full circle; the ground hides the bottom."),
        Question(
            prompt: "What is the name for a shape with five sides?",
            options: ["A hexagon", "An octagon", "A rhombus", "A pentagon"],
            correctIndex: 3,
            explanation: "This shape almost never tiles a flat surface neatly, unlike its four and six sided cousins — leave five-sided tiles side by side and gaps appear. Mathematicians hunted for the rare exceptions for decades, and the search only finished in 2017."),
        Question(
            prompt: "What do we call the study of stars, planets and space?",
            options: ["Astronomy", "Geology", "Biology", "Geography"],
            correctIndex: 0,
            explanation: "It is the oldest science there is — people were tracking the sky and predicting eclipses thousands of years before writing existed. Because light takes so long to cross space, everyone who does it is really looking backwards in time at how things used to be."),
        Question(
            prompt: "Which planet is famous for the bright rings around it?",
            options: ["Mars", "Saturn", "Jupiter", "Neptune"],
            correctIndex: 1,
            explanation: "The rings are not solid at all but billions of tumbling chunks of ice, most no bigger than a snowball. They stretch out further than the distance from Earth to the Moon, yet they are startlingly thin — in most places only about ten metres from top to bottom."),
        Question(
            prompt: "What is the hardest natural substance on Earth?",
            options: ["Iron", "Gold", "Diamond", "Marble"],
            correctIndex: 2,
            explanation: "It is made of nothing but carbon, the very same stuff as the soft grey pencil lead that smudges on your page. The only difference is how the atoms are stacked. It takes enormous heat and pressure deep underground, over millions of years, to build one."),
        Question(
            prompt: "Which country gave the Statue of Liberty to the United States?",
            options: ["Spain", "Italy", "Germany", "France"],
            correctIndex: 3,
            explanation: "It arrived in 350 separate pieces packed into more than 200 crates and had to be bolted back together on the island. The outer skin is copper barely thicker than two coins, which is why sea air has turned the whole thing that soft green colour."),
        Question(
            prompt: "What do we call a map of the world drawn on a ball?",
            options: ["A globe", "A chart", "A poster", "A compass"],
            correctIndex: 0,
            explanation: "It is the only truly honest way to show our planet. Flatten the world onto paper and something always has to stretch — which is why Greenland looks about the size of Africa on many wall maps when it is really fourteen times smaller."),
        Question(
            prompt: "What is molten rock called once it flows out onto the surface?",
            options: ["Magma", "Lava", "Ash", "Coal"],
            correctIndex: 1,
            explanation: "Underground the very same stuff goes by a different name — it only earns this one after it escapes. It can pour out at over 1,000 degrees, hot enough to glow bright orange, yet it cools into rock so rich in minerals that farmers prize the soil it leaves behind."),
        Question(
            prompt: "Which part of a plant usually attracts bees and butterflies?",
            options: ["The roots", "The bark", "The flowers", "The stem"],
            correctIndex: 2,
            explanation: "Many carry markings invisible to us that blaze like landing lights under ultraviolet light, which bees can see and we cannot. The deal is simple: a sweet drink in exchange for carrying pollen to the next plant, since the plant itself can never move."),
        Question(
            prompt: "What is the young of a horse called?",
            options: ["A calf", "A lamb", "A kid", "A foal"],
            correctIndex: 3,
            explanation: "It can stand within an hour of being born and run alongside the herd the same day — essential when your family survives by fleeing danger. Its legs are already nearly the full adult length, which is why a newborn looks so comically long and wobbly."),
        Question(
            prompt: "Which shape has eight equal sides?",
            options: ["Octagon", "Hexagon", "Pentagon", "Heptagon"],
            correctIndex: 0,
            explanation: "Stop signs use this shape all over the world for a clever reason: a driver can recognise the outline from behind, or in snow, or when the paint has faded away entirely. No other road sign shares it, so the meaning is never in doubt."),
        Question(
            prompt: "What do we call animals that are awake at night and sleep by day?",
            options: ["Migratory", "Nocturnal", "Extinct", "Tropical"],
            correctIndex: 1,
            explanation: "Many have a mirror-like layer behind the eye that bounces light back through a second time, doubling what they can see in the dark. It is also why their eyes flash back at you in a torch beam — you are seeing that mirror, not the eye glowing."),
        Question(
            prompt: "Which large animal has a long trunk and huge flapping ears?",
            options: ["Rhino", "Hippo", "Elephant", "Buffalo"],
            correctIndex: 2,
            explanation: "The trunk holds about 40,000 muscles — your entire body has fewer than 700 — so it can uproot a tree or pick up a single blade of grass. The ears are full of blood vessels, and flapping them is really a way of cooling the blood down."),
        Question(
            prompt: "What is the name of the force that pulls everything towards the ground?",
            options: ["Friction", "Magnetism", "Pressure", "Gravity"],
            correctIndex: 3,
            explanation: "It is the weakest of nature's forces by far — a small magnet lifts a paperclip while the whole planet pulls the other way and loses. It only feels strong because Earth is so enormous, and it is the same pull that keeps the Moon circling us."),
        Question(
            prompt: "Which country is home to wild kangaroos and koalas?",
            options: ["Australia", "Canada", "Norway", "Brazil"],
            correctIndex: 0,
            explanation: "It drifted away from the other continents so long ago that its animals evolved almost entirely on their own, which is why so many are found nowhere else. It is the only country in the world that covers an entire continent all by itself."),
        Question(
            prompt: "How many players from one team are on a football pitch at a time?",
            options: ["Nine", "Eleven", "Seven", "Thirteen"],
            correctIndex: 1,
            explanation: "Only one of them is allowed to use their hands, and only inside the marked box. The number was settled in English schools in the 1800s and written into the rules in 1897. It is now the most played sport on Earth, in more countries than any other."),
        Question(
            prompt: "What do we call a scientist who studies the weather?",
            options: ["Geologist", "Botanist", "Meteorologist", "Chemist"],
            correctIndex: 2,
            explanation: "The name has nothing to do with meteors — it comes from an old Greek word meaning 'things high in the air'. They now feed millions of measurements into supercomputers, yet the atmosphere is so chaotic that forecasts beyond about ten days stay stubbornly unreliable."),
        Question(
            prompt: "Which liquid metal is used inside old thermometers?",
            options: ["Iron", "Copper", "Silver", "Mercury"],
            correctIndex: 3,
            explanation: "It is the only metal that stays liquid at room temperature, and it expands very evenly as it warms, which is what makes it so good at measuring. It is also poisonous, so most thermometers today use coloured alcohol or an electronic sensor instead."),
        Question(
            prompt: "How many zeros are there in the number one thousand?",
            options: ["Three", "Two", "Four", "Five"],
            correctIndex: 0,
            explanation: "Grouping numbers in threes is why we say thousand, million and billion. The idea of a symbol for nothing at all took a long time to catch on — ancient Rome had no zero, which is part of why doing sums with Roman numerals is so awkward."),
        Question(
            prompt: "Which ocean lies between Africa and Australia?",
            options: ["The Atlantic", "The Arctic", "The Indian Ocean", "The Southern Ocean"],
            correctIndex: 2,
            explanation: "It is the warmest of the great oceans, which makes it a powerful engine for weather — the monsoon rains that soak southern Asia every year are driven by it. It is also the youngest, formed as the continents around it pulled apart.")
    ]

    // MARK: - Hard

    static let hard: [Question] = [
        Question(
            prompt: "How many hearts does an octopus have?",
            options: ["One", "Two", "Three", "Five"],
            correctIndex: 2,
            explanation: "Two of them push blood through the gills and the third serves the rest of the body — and that one actually stops beating whenever the animal swims, which is partly why it would rather crawl. Its blood is blue, because it carries oxygen using copper instead of iron."),
        Question(
            prompt: "Which bird is the fastest animal in the world when it dives?",
            options: ["Golden eagle", "Peregrine falcon", "Albatross", "Swift"],
            correctIndex: 1,
            explanation: "It tucks into a teardrop shape and drops at well over 300 kilometres an hour, faster than a racing car. At that speed air would wreck an ordinary bird's lungs, so it has small bony cones in its nostrils that slow the rushing air before it gets inside."),
        Question(
            prompt: "Which planet spins on its side, almost lying down as it orbits?",
            options: ["Neptune", "Mars", "Jupiter", "Uranus"],
            correctIndex: 3,
            explanation: "It is tipped by about 98 degrees, most likely knocked over by an enormous collision long ago. Because of that tilt each pole spends roughly 42 years in continuous sunlight and then 42 years in unbroken darkness — the most extreme seasons anywhere in the solar system."),
        Question(
            prompt: "What is the chemical symbol for gold?",
            options: ["Au", "Go", "Gd", "Ag"],
            correctIndex: 0,
            explanation: "It comes from 'aurum', the old Latin name meaning 'glowing dawn'. The metal is so unreactive that it never rusts or tarnishes, which is why treasure pulled from shipwrecks after centuries underwater still comes up gleaming, while the iron beside it has crumbled to nothing."),
        Question(
            prompt: "Which is the largest internal organ in the human body?",
            options: ["The heart", "The lungs", "The liver", "The stomach"],
            correctIndex: 2,
            explanation: "It handles over 500 different jobs, from cleaning the blood to storing energy, and it is the only organ you have that can regrow itself. Take away a large piece and the rest will steadily grow back to full size within a matter of months."),
        Question(
            prompt: "What is the name of the galaxy that Earth belongs to?",
            options: ["Andromeda", "Orion", "Cassiopeia", "The Milky Way"],
            correctIndex: 3,
            explanation: "It holds a few hundred billion stars and a giant black hole sits at the centre. Light takes around 100,000 years to cross it. Our whole solar system is drifting round that centre at about 800,000 kilometres an hour, and one lap takes 230 million years."),
        Question(
            prompt: "Which is the only mammal capable of true flapping flight?",
            options: ["The bat", "The flying squirrel", "The sugar glider", "The colugo"],
            correctIndex: 0,
            explanation: "The wing is really a hand: those long struts holding the skin taut are enormously stretched finger bones. The others in this list only glide, falling slowly with a flap of loose skin. These are also the only mammals that hunt by listening for their own echoes."),
        Question(
            prompt: "What is the deepest known place in the ocean called?",
            options: ["The Bermuda Deep", "The Mariana Trench", "The Coral Basin", "The Atlantic Gulf"],
            correctIndex: 1,
            explanation: "It plunges about eleven kilometres down — drop Mount Everest in and the peak would still be well over a kilometre beneath the waves. The pressure at the bottom is like balancing fifty jumbo jets on your shoulders, yet small living things still thrive down there."),
        Question(
            prompt: "Which vitamin does your skin make when sunlight falls on it?",
            options: ["Vitamin A", "Vitamin C", "Vitamin D", "Vitamin K"],
            correctIndex: 2,
            explanation: "It is the odd one out among vitamins, because your own body manufactures it rather than taking it from food. Its main job is helping you absorb calcium, so bones grow strong. Very few foods contain much of it — oily fish and egg yolks are among the best."),
        Question(
            prompt: "What is the study of fossils and ancient life called?",
            options: ["Archaeology", "Geology", "Zoology", "Palaeontology"],
            correctIndex: 3,
            explanation: "It is often confused with archaeology, but that one studies human history while this reaches back long before people existed. A fossil is not the original bone at all — minerals seep in over millions of years and gradually replace it, leaving a stone copy behind."),
        Question(
            prompt: "Which metal conducts electricity better than any other?",
            options: ["Silver", "Copper", "Gold", "Aluminium"],
            correctIndex: 0,
            explanation: "It just edges out copper, but it is far too expensive to run through a whole house, so copper does nearly all the real wiring in the world. It is used where cost matters less than performance — inside spacecraft, and in the finest electronics."),
        Question(
            prompt: "How many bones are there in an adult human hand and wrist?",
            options: ["Fifteen", "Twenty-seven", "Nineteen", "Thirty-four"],
            correctIndex: 1,
            explanation: "That is more than a quarter of every bone you own, packed into a small space — which is exactly what makes the hand so extraordinarily nimble. Eight of them are in the wrist alone, sliding over one another to let it bend in almost any direction."),
        Question(
            prompt: "What is frozen carbon dioxide commonly known as?",
            options: ["Black ice", "Sea ice", "Dry ice", "Glass ice"],
            correctIndex: 2,
            explanation: "It earns the name because it never melts into a puddle. Instead it turns straight from solid to gas, a trick called sublimation, leaving nothing behind at all. That gas is what makes the thick white fog used on stage, and it keeps ice cream frozen on long journeys."),
        Question(
            prompt: "Which bird is famous for perfectly copying sounds it hears, including chainsaws?",
            options: ["The mockingbird", "The parrot", "The starling", "The lyrebird"],
            correctIndex: 3,
            explanation: "It lives in the forests of Australia and its throat is the most complex of any songbird alive. A male will weave together the calls of twenty other species, plus camera shutters and car alarms, into one long performance to impress a watching female."),
        Question(
            prompt: "Which animal makes the longest migration of any on Earth?",
            options: ["The Arctic tern", "The blue whale", "The monarch butterfly", "The caribou"],
            correctIndex: 0,
            explanation: "It flies from the top of the world to the bottom and back every single year, chasing endless summer, and covers something like 70,000 kilometres. Over a lifetime of thirty years that adds up to roughly three return trips to the Moon."),
        Question(
            prompt: "What is the smallest building block of an ordinary substance called?",
            options: ["A cell", "An atom", "A crystal", "A grain"],
            correctIndex: 1,
            explanation: "They are almost entirely empty space. If one were blown up to the size of a football stadium, the heavy centre would be a pea on the halfway line and everything else would be emptiness. You are made of them, and nearly all of you is nothing at all."),
        Question(
            prompt: "Which is the largest species of shark in the ocean?",
            options: ["The great white", "The tiger shark", "The whale shark", "The hammerhead"],
            correctIndex: 2,
            explanation: "It grows longer than a bus, yet it is completely harmless to people — it cruises with its mouth open straining tiny plankton from the water. Each one carries a pattern of pale spots as individual as a fingerprint, which researchers use to tell them apart."),
        Question(
            prompt: "Which scientist first explained the theory of relativity?",
            options: ["Isaac Newton", "Marie Curie", "Galileo Galilei", "Albert Einstein"],
            correctIndex: 3,
            explanation: "The work showed that time itself runs slower the faster you travel — not as an illusion but genuinely. Satellite navigation has to correct for this every day, because clocks in orbit tick at a slightly different rate from the ones down here on the ground."),
        Question(
            prompt: "Which organ filters waste out of your blood and makes urine?",
            options: ["The kidneys", "The lungs", "The spleen", "The pancreas"],
            correctIndex: 0,
            explanation: "You have two, each about the size of a fist, and together they clean your entire blood supply around forty times a day. Inside each one sit roughly a million microscopic filters. A person can live a full and healthy life with only one of them working."),
        Question(
            prompt: "What is a group of crows properly called?",
            options: ["A chatter", "A murder", "A parliament", "A gaggle"],
            correctIndex: 1,
            explanation: "The gloomy name is a leftover from medieval superstition. The birds themselves are remarkable: they make and use tools, recognise individual human faces for years, and can even hold a grudge, passing their dislike of a particular person on to their young."),
        Question(
            prompt: "Roughly how many teeth does a typical adult human have?",
            options: ["Twenty-four", "Twenty-eight", "Thirty-two", "Forty"],
            correctIndex: 2,
            explanation: "Many people never fit the last four, the wisdom teeth, and have them taken out. The outer coating is the hardest material your body makes — tougher than bone — but unlike bone it cannot heal itself, so a chip stays chipped for good."),
        Question(
            prompt: "Which ancient wonder of the world is still standing today?",
            options: ["The Colossus of Rhodes", "The Hanging Gardens", "The Lighthouse of Alexandria", "The Great Pyramid of Giza"],
            correctIndex: 3,
            explanation: "It is the oldest of the seven and the only survivor, built around 4,500 years ago from over two million blocks of stone. For nearly 4,000 years nothing taller was ever built anywhere on Earth — a record no other structure has come close to holding."),
        Question(
            prompt: "What is a triangle with three equal sides called?",
            options: ["Equilateral", "Isosceles", "Scalene", "Obtuse"],
            correctIndex: 0,
            explanation: "All three of its angles come to exactly 60 degrees, and it is the only triangle where that is fixed no matter the size. Six of them fit perfectly around a point, which is the reason honeycomb settles into those neat six-sided cells."),
        Question(
            prompt: "Which sea creature is the loudest animal on the planet?",
            options: ["The dolphin", "The sperm whale", "The walrus", "The seal"],
            correctIndex: 1,
            explanation: "Its clicks are louder than a rocket launch and can be detected right across an ocean. The sound is made in a huge oil-filled chamber in its head and focused into a beam, used like sonar to hunt squid in water far too dark to see anything at all."),
        Question(
            prompt: "How many time zones does the world use in total?",
            options: ["Twelve", "Eighteen", "Twenty-four", "Thirty"],
            correctIndex: 2,
            explanation: "They exist because Earth turns one full circle each day, so noon arrives at different moments around the globe. The lines are anything but straight — countries bend them to keep themselves in one piece, and China uses a single one across its entire enormous width."),
        Question(
            prompt: "Which famous river flows north through Egypt?",
            options: ["The Amazon", "The Congo", "The Ganges", "The Nile"],
            correctIndex: 3,
            explanation: "Flowing north surprises people, but rivers simply follow the land downhill and this one starts on high ground far to the south. Its yearly flood once spread rich black silt across the fields, which is exactly why a great civilisation grew up along its banks."),
        Question(
            prompt: "Which part of a plant carries water up from the roots to the leaves?",
            options: ["The xylem", "The phloem", "The cuticle", "The stamen"],
            correctIndex: 0,
            explanation: "It works like a chain of drinking straws with no pump at all. Water evaporating from the leaves tugs on the column below, dragging it upwards, and the molecules cling to one another so tightly that the chain never breaks — even at the top of the tallest tree."),
        Question(
            prompt: "What is the hardest working muscle in the human body over a lifetime?",
            options: ["The tongue", "The heart", "The calf", "The jaw"],
            correctIndex: 1,
            explanation: "It never gets a proper rest, beating around two and a half billion times in an average life and moving enough blood to fill several swimming pools. It manages this because it relaxes fully between every beat — those tiny pauses are its only recovery."),
        Question(
            prompt: "Which planet in our solar system has the shortest day?",
            options: ["Mercury", "Mars", "Jupiter", "Earth"],
            correctIndex: 2,
            explanation: "Despite being by far the biggest, it spins right round in under ten hours. Turning that fast has visibly squashed it — the planet bulges at its middle and is noticeably flattened at the poles. That spin is also what smears its clouds into those famous stripes."),
        Question(
            prompt: "What is a number called if it can only be divided by 1 and itself?",
            options: ["A square number", "A prime number", "An even number", "A cube number"],
            correctIndex: 1,
            explanation: "They thin out the higher you count, yet they never run out — the Greeks proved that well over two thousand years ago. Modern codes that keep messages private rely on them, because multiplying two enormous ones is easy but undoing it is very nearly impossible.")
    ]

    // MARK: - Drawing a round

    /// Builds the question list for one play of a mode. Questions are shuffled
    /// so a repeat play is never the same round twice.
    static func draw(for mode: ProMode, islandID: Int? = nil) -> [Question] {
        switch mode {
        case .dailyChallenge:
            // A broad mix, so the daily set is a fair test of everything.
            return Array(easy.shuffled().prefix(3))
                 + Array(medium.shuffled().prefix(4))
                 + Array(hard.shuffled().prefix(3))

        case .lightningRound:
            return Array(easy.shuffled().prefix(mode.questionCount))

        case .timedChallenge:
            return Array(medium.shuffled().prefix(mode.questionCount))

        case .jewelRush:
            // A gentle climb, so an early streak is within reach for everyone.
            let opener = easy.shuffled().prefix(3)
            let rest = medium.shuffled().prefix(mode.questionCount - 3)
            return Array(opener) + Array(rest)

        case .perfectRun:
            // Ramps up: the further you get, the more it asks of you.
            return Array(easy.shuffled().prefix(3))
                 + Array(medium.shuffled().prefix(4))
                 + Array(hard.shuffled().prefix(3))

        case .categoryMaster:
            return categoryQuestions(islandID: islandID, count: mode.questionCount)
        }
    }

    /// Fifteen questions spread across one island's ten levels, walking from
    /// its gentlest content up to its hardest.
    private static func categoryQuestions(islandID: Int?, count: Int) -> [Question] {
        guard let islandID, let island = QuizData.island(id: islandID) else { return [] }

        // Take from every level in order so the difficulty still climbs, but
        // pick randomly within each level so the round varies between plays.
        var picked: [Question] = []
        let levels = island.levels.sorted { $0.number < $1.number }
        guard !levels.isEmpty else { return [] }

        var perLevel = Array(repeating: count / levels.count, count: levels.count)
        // Spread the remainder over the later, harder levels.
        var leftover = count % levels.count
        var i = levels.count - 1
        while leftover > 0 && i >= 0 {
            perLevel[i] += 1
            leftover -= 1
            i -= 1
        }

        for (index, level) in levels.enumerated() {
            picked += level.questions.shuffled().prefix(perLevel[index])
        }
        return Array(picked.prefix(count))
    }
}
