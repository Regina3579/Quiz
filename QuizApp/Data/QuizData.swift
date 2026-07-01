//
//  QuizData.swift
//  QuizApp
//
//  The Adventure Map content: ten themed islands. Each level has ten
//  clear, friendly questions aimed at ages 7+ — easy to medium, and
//  written so kids actually learn something fun.
//
//  Levels are being filled in island-by-island. Every island below has at
//  least its first level ready; more levels can be appended to `levels`
//  without any other code changes.
//

import SwiftUI

enum QuizData {

    /// All islands, in map order.
    static let islands: [Island] = [
        jungleKingdom,
        galaxyQuest,
        dinoValley,
        oceanParadise,
        explorersTrail,
        blossomGarden,
        scienceLab,
        brainCastle,
        ancientKingdom,
        championsSummit
    ]

    /// Look up an island by its id.
    static func island(id: Int) -> Island? {
        islands.first { $0.id == id }
    }

    // MARK: - 🌳 1. Jungle Kingdom 🦁

    static let jungleKingdom = Island(
        id: 0,
        name: "Jungle Kingdom",
        emoji: "🦁",
        accentEmoji: "🌳",
        blurb: "Explore amazing animals and wildlife!",
        palette: .init(
            start: Color(red: 0.36, green: 0.80, blue: 0.44),
            end: Color(red: 0.16, green: 0.60, blue: 0.36)
        ),
        levels: [
            Level(number: 1, questions: [
                Question(prompt: "Which animal is known as the 'King of the Jungle'?",
                         options: ["Tiger", "Lion", "Bear", "Wolf"], correctIndex: 1,
                         explanation: "The lion is called the King of the Jungle!"),
                Question(prompt: "What is the tallest animal in the world?",
                         options: ["Giraffe", "Elephant", "Horse", "Camel"], correctIndex: 0,
                         explanation: "Giraffes have long necks to reach tall leaves."),
                Question(prompt: "Which animal can change color to hide?",
                         options: ["Rabbit", "Chameleon", "Cow", "Dog"], correctIndex: 1,
                         explanation: "Chameleons change color to blend in. So sneaky!"),
                Question(prompt: "What do we call a baby dog?",
                         options: ["Kitten", "Cub", "Puppy", "Calf"], correctIndex: 2,
                         explanation: "A baby dog is called a puppy!"),
                Question(prompt: "Which animal is the biggest land animal?",
                         options: ["Elephant", "Rhino", "Hippo", "Giraffe"], correctIndex: 0,
                         explanation: "The elephant is the largest animal on land."),
                Question(prompt: "How many legs does a spider have?",
                         options: ["6", "8", "10", "4"], correctIndex: 1,
                         explanation: "Spiders have 8 legs!"),
                Question(prompt: "Which bird cannot fly?",
                         options: ["Eagle", "Penguin", "Parrot", "Sparrow"], correctIndex: 1,
                         explanation: "Penguins can't fly, but they are great swimmers!"),
                Question(prompt: "What do bees make?",
                         options: ["Milk", "Honey", "Silk", "Web"], correctIndex: 1,
                         explanation: "Busy bees make sweet honey."),
                Question(prompt: "Which animal says 'Moo'?",
                         options: ["Sheep", "Cow", "Goat", "Pig"], correctIndex: 1,
                         explanation: "Cows say 'Moo'! 🐄"),
                Question(prompt: "What do we call animals that eat only plants?",
                         options: ["Carnivores", "Herbivores", "Omnivores", "Insects"], correctIndex: 1,
                         explanation: "Plant-eating animals are called herbivores.")
            ]),
            Level(number: 2, questions: [
                Question(prompt: "Which animal has black and white stripes?",
                         options: ["Zebra", "Lion", "Bear", "Fox"], correctIndex: 0,
                         explanation: "Zebras have beautiful black and white stripes!"),
                Question(prompt: "What is a group of lions called?",
                         options: ["Herd", "Pack", "Pride", "Flock"], correctIndex: 2,
                         explanation: "A family of lions is called a pride."),
                Question(prompt: "Which animal is famous for a very long trunk?",
                         options: ["Elephant", "Kangaroo", "Monkey", "Panda"], correctIndex: 0,
                         explanation: "Elephants use their trunk to drink and grab food."),
                Question(prompt: "What do we call a baby cat?",
                         options: ["Puppy", "Kitten", "Chick", "Foal"], correctIndex: 1,
                         explanation: "A baby cat is called a kitten!"),
                Question(prompt: "Which animal hops and carries its baby in a pouch?",
                         options: ["Rabbit", "Kangaroo", "Frog", "Deer"], correctIndex: 1,
                         explanation: "Kangaroos carry their joeys in a pouch."),
                Question(prompt: "Which of these animals lives in water?",
                         options: ["Fish", "Cat", "Horse", "Chicken"], correctIndex: 0,
                         explanation: "Fish live in water and breathe using gills."),
                Question(prompt: "What is the fastest land animal?",
                         options: ["Cheetah", "Lion", "Horse", "Dog"], correctIndex: 0,
                         explanation: "The cheetah can run super fast!"),
                Question(prompt: "Which animal is known for a great memory and big ears?",
                         options: ["Elephant", "Mouse", "Cat", "Duck"], correctIndex: 0,
                         explanation: "Elephants have big ears and never forget!"),
                Question(prompt: "What do we call a baby sheep?",
                         options: ["Lamb", "Calf", "Cub", "Kid"], correctIndex: 0,
                         explanation: "A baby sheep is called a lamb."),
                Question(prompt: "Which animal is awake at night and sleeps in the day?",
                         options: ["Owl", "Sparrow", "Rooster", "Duck"], correctIndex: 0,
                         explanation: "Owls are awake at night — they are nocturnal!")
            ])
        ]
    )

    // MARK: - 🚀 2. Galaxy Quest 🌌

    static let galaxyQuest = Island(
        id: 1,
        name: "Galaxy Quest",
        emoji: "🚀",
        accentEmoji: "🌌",
        blurb: "Journey through planets, stars and space!",
        palette: .init(
            start: Color(red: 0.44, green: 0.36, blue: 0.95),
            end: Color(red: 0.72, green: 0.34, blue: 0.90)
        ),
        levels: [
            Level(number: 1, questions: [
                Question(prompt: "Which planet do we live on?",
                         options: ["Mars", "Earth", "Venus", "Jupiter"], correctIndex: 1,
                         explanation: "We all live on planet Earth!"),
                Question(prompt: "Which planet is called the Red Planet?",
                         options: ["Mars", "Saturn", "Earth", "Mercury"], correctIndex: 0,
                         explanation: "Mars looks red because of its rusty dust."),
                Question(prompt: "What is the big star that gives us light in the day?",
                         options: ["The Moon", "The Sun", "A comet", "Jupiter"], correctIndex: 1,
                         explanation: "The Sun is a giant star that lights our day."),
                Question(prompt: "What do we call a person who travels to space?",
                         options: ["Pilot", "Astronaut", "Sailor", "Diver"], correctIndex: 1,
                         explanation: "Astronauts fly to space in rockets!"),
                Question(prompt: "What glows in the sky at night and changes shape?",
                         options: ["The Sun", "The Moon", "A cloud", "A plane"], correctIndex: 1,
                         explanation: "The Moon lights up the night sky."),
                Question(prompt: "Which planet has beautiful rings?",
                         options: ["Saturn", "Earth", "Mars", "Mercury"], correctIndex: 0,
                         explanation: "Saturn's rings are made of ice and rock."),
                Question(prompt: "How many planets are in our Solar System?",
                         options: ["8", "5", "12", "3"], correctIndex: 0,
                         explanation: "There are 8 planets orbiting the Sun."),
                Question(prompt: "What do we ride to blast off into space?",
                         options: ["A car", "A rocket", "A boat", "A train"], correctIndex: 1,
                         explanation: "Rockets blast off with a big burst of fire!"),
                Question(prompt: "Which planet is closest to the Sun?",
                         options: ["Mercury", "Earth", "Neptune", "Mars"], correctIndex: 0,
                         explanation: "Mercury is the closest planet to the Sun."),
                Question(prompt: "What are the tiny twinkling lights in the night sky?",
                         options: ["Stars", "Fish", "Rocks", "Lamps"], correctIndex: 0,
                         explanation: "Those twinkling lights are faraway stars!")
            ])
        ]
    )

    // MARK: - 🦖 3. Dino Valley 🦕

    static let dinoValley = Island(
        id: 2,
        name: "Dino Valley",
        emoji: "🦕",
        accentEmoji: "🦖",
        blurb: "Travel back to the age of dinosaurs!",
        palette: .init(
            start: Color(red: 0.52, green: 0.78, blue: 0.30),
            end: Color(red: 0.28, green: 0.60, blue: 0.26)
        ),
        levels: [
            Level(number: 1, questions: [
                Question(prompt: "Which dinosaur had big sharp teeth and was a fierce hunter?",
                         options: ["Triceratops", "T. rex", "Brachiosaurus", "Stegosaurus"], correctIndex: 1,
                         explanation: "Tyrannosaurus rex had huge, sharp teeth!"),
                Question(prompt: "Dinosaurs hatched from what?",
                         options: ["Eggs", "Seeds", "Clouds", "Rocks"], correctIndex: 0,
                         explanation: "Baby dinosaurs hatched from eggs, like birds do."),
                Question(prompt: "Which dinosaur had three horns on its head?",
                         options: ["Triceratops", "T. rex", "Raptor", "Diplodocus"], correctIndex: 0,
                         explanation: "Triceratops had three strong horns."),
                Question(prompt: "What did plant-eating dinosaurs eat?",
                         options: ["Meat", "Plants", "Fish", "Rocks"], correctIndex: 1,
                         explanation: "Herbivore dinosaurs munched on plants."),
                Question(prompt: "What do we call a scientist who digs up dinosaur bones?",
                         options: ["Chef", "Paleontologist", "Pilot", "Painter"], correctIndex: 1,
                         explanation: "Paleontologists study dinosaur fossils."),
                Question(prompt: "Dinosaurs lived a very, very ___ time ago.",
                         options: ["Short", "Long", "Recent", "Modern"], correctIndex: 1,
                         explanation: "Dinosaurs lived millions of years ago!"),
                Question(prompt: "What do we call dinosaur bones found in the ground?",
                         options: ["Fossils", "Crystals", "Shells", "Coins"], correctIndex: 0,
                         explanation: "Old bones turned to stone are called fossils."),
                Question(prompt: "Which dinosaur had bony plates along its back?",
                         options: ["Stegosaurus", "T. rex", "Raptor", "Pterodactyl"], correctIndex: 0,
                         explanation: "Stegosaurus had cool plates on its back."),
                Question(prompt: "Which flying reptile lived in the age of dinosaurs?",
                         options: ["Pterodactyl", "Eagle", "Bat", "Owl"], correctIndex: 0,
                         explanation: "Pterodactyls glided through the ancient skies."),
                Question(prompt: "A dinosaur with a very long neck to reach tall trees was the...",
                         options: ["Brachiosaurus", "Triceratops", "T. rex", "Raptor"], correctIndex: 0,
                         explanation: "Brachiosaurus used its long neck to reach treetops.")
            ])
        ]
    )

    // MARK: - 🌊 4. Ocean Paradise 🐬

    static let oceanParadise = Island(
        id: 3,
        name: "Ocean Paradise",
        emoji: "🐬",
        accentEmoji: "🌊",
        blurb: "Dive into the amazing underwater world!",
        palette: .init(
            start: Color(red: 0.24, green: 0.74, blue: 0.92),
            end: Color(red: 0.16, green: 0.48, blue: 0.85)
        ),
        levels: [
            Level(number: 1, questions: [
                Question(prompt: "Which sea animal has eight arms?",
                         options: ["Fish", "Octopus", "Crab", "Turtle"], correctIndex: 1,
                         explanation: "An octopus has eight wiggly arms!"),
                Question(prompt: "What is the biggest animal in the ocean?",
                         options: ["Shark", "Blue whale", "Dolphin", "Tuna"], correctIndex: 1,
                         explanation: "The blue whale is the largest animal on Earth!"),
                Question(prompt: "Which fish is famous for its sharp teeth?",
                         options: ["Shark", "Goldfish", "Clownfish", "Seahorse"], correctIndex: 0,
                         explanation: "Sharks have rows of sharp teeth."),
                Question(prompt: "How do fish breathe underwater?",
                         options: ["With lungs", "With gills", "With a nose", "With fins"], correctIndex: 1,
                         explanation: "Fish use gills to breathe in water."),
                Question(prompt: "Which sea animal is very smart and loves to jump?",
                         options: ["Dolphin", "Crab", "Jellyfish", "Snail"], correctIndex: 0,
                         explanation: "Dolphins are clever and playful!"),
                Question(prompt: "What color is most ocean water?",
                         options: ["Blue", "Pink", "Purple", "Orange"], correctIndex: 0,
                         explanation: "The ocean usually looks blue."),
                Question(prompt: "Which animal has a hard shell and lives in the sea?",
                         options: ["Turtle", "Shark", "Eel", "Whale"], correctIndex: 0,
                         explanation: "Sea turtles carry their shell with them."),
                Question(prompt: "Starfish live in the...",
                         options: ["Desert", "Ocean", "Forest", "Sky"], correctIndex: 1,
                         explanation: "Starfish live on the ocean floor."),
                Question(prompt: "Which of these can sting you in the sea?",
                         options: ["Jellyfish", "Clownfish", "Seahorse", "Goldfish"], correctIndex: 0,
                         explanation: "Jellyfish can sting with their tentacles."),
                Question(prompt: "What do we call water that is salty?",
                         options: ["Sea water", "Rain water", "Juice", "Milk"], correctIndex: 0,
                         explanation: "Ocean water is salty sea water.")
            ])
        ]
    )

    // MARK: - 🌍 5. Explorer's Trail 🧭

    static let explorersTrail = Island(
        id: 4,
        name: "Explorer's Trail",
        emoji: "🧭",
        accentEmoji: "🌍",
        blurb: "Discover countries, flags and landmarks!",
        palette: .init(
            start: Color(red: 0.98, green: 0.66, blue: 0.28),
            end: Color(red: 0.94, green: 0.44, blue: 0.30)
        ),
        levels: [
            Level(number: 1, questions: [
                Question(prompt: "How many continents are there on Earth?",
                         options: ["5", "7", "10", "3"], correctIndex: 1,
                         explanation: "There are 7 continents on Earth."),
                Question(prompt: "Which is the largest ocean?",
                         options: ["Atlantic", "Pacific", "Indian", "Arctic"], correctIndex: 1,
                         explanation: "The Pacific Ocean is the biggest."),
                Question(prompt: "The Great Pyramids are in which country?",
                         options: ["Egypt", "Italy", "Japan", "Brazil"], correctIndex: 0,
                         explanation: "The famous pyramids are in Egypt."),
                Question(prompt: "The Eiffel Tower is found in which city?",
                         options: ["London", "Paris", "Rome", "Tokyo"], correctIndex: 1,
                         explanation: "The Eiffel Tower is in Paris, France."),
                Question(prompt: "Which tool helps you find direction (North, South)?",
                         options: ["A ruler", "A compass", "A clock", "A spoon"], correctIndex: 1,
                         explanation: "A compass points you the right way!"),
                Question(prompt: "Kangaroos are a famous symbol of which country?",
                         options: ["Canada", "Australia", "India", "Spain"], correctIndex: 1,
                         explanation: "Kangaroos live in Australia."),
                Question(prompt: "What do we call a drawing that shows countries and places?",
                         options: ["A map", "A menu", "A letter", "A poster"], correctIndex: 0,
                         explanation: "A map shows us where places are."),
                Question(prompt: "The coldest, iciest place at the bottom of Earth is...",
                         options: ["Antarctica", "Africa", "Asia", "Europe"], correctIndex: 0,
                         explanation: "Antarctica is covered in ice and snow."),
                Question(prompt: "Which country is famous for pizza and pasta?",
                         options: ["Italy", "China", "Mexico", "Kenya"], correctIndex: 0,
                         explanation: "Italy is famous for delicious pizza and pasta!"),
                Question(prompt: "What do we call the lines that show hot and cold parts of the map?",
                         options: ["Colors", "Continents", "Countries", "Rivers"], correctIndex: 1,
                         explanation: "Big land areas on a map are called continents.")
            ])
        ]
    )

    // MARK: - 🌸 6. Blossom Garden 🌺

    static let blossomGarden = Island(
        id: 5,
        name: "Blossom Garden",
        emoji: "🌺",
        accentEmoji: "🦋",
        blurb: "Flowers, trees, birds and butterflies!",
        palette: .init(
            start: Color(red: 0.98, green: 0.52, blue: 0.72),
            end: Color(red: 0.82, green: 0.36, blue: 0.70)
        ),
        levels: [
            Level(number: 1, questions: [
                Question(prompt: "What do plants need from the sky to grow?",
                         options: ["Sunlight and rain", "Only darkness", "Ice cream", "Candy"], correctIndex: 0,
                         explanation: "Plants love sunlight and water to grow."),
                Question(prompt: "Which insect turns from a caterpillar into a beautiful flyer?",
                         options: ["Ant", "Butterfly", "Beetle", "Spider"], correctIndex: 1,
                         explanation: "A caterpillar becomes a butterfly!"),
                Question(prompt: "What part of a plant is usually colorful and smells nice?",
                         options: ["Root", "Flower", "Stem", "Seed"], correctIndex: 1,
                         explanation: "Flowers are the pretty, sweet-smelling part."),
                Question(prompt: "What do we call a baby plant that grows into a big tree?",
                         options: ["A seed", "A rock", "A leaf", "A shell"], correctIndex: 0,
                         explanation: "Trees grow from tiny seeds!"),
                Question(prompt: "Which of these can fly?",
                         options: ["Bird", "Fish", "Snail", "Worm"], correctIndex: 0,
                         explanation: "Birds have wings and can fly."),
                Question(prompt: "What color are most leaves?",
                         options: ["Green", "Blue", "Purple", "Black"], correctIndex: 0,
                         explanation: "Leaves are usually green."),
                Question(prompt: "Bees visit flowers to collect...",
                         options: ["Nectar", "Water", "Sand", "Stones"], correctIndex: 0,
                         explanation: "Bees gather nectar to make honey."),
                Question(prompt: "Which of these is a bird?",
                         options: ["Sparrow", "Frog", "Ant", "Bee"], correctIndex: 0,
                         explanation: "A sparrow is a small, friendly bird."),
                Question(prompt: "The part of the plant that holds it in the soil is the...",
                         options: ["Root", "Flower", "Petal", "Fruit"], correctIndex: 0,
                         explanation: "Roots hold the plant in the ground and drink water."),
                Question(prompt: "What season do many flowers bloom in?",
                         options: ["Spring", "Winter", "Never", "Midnight"], correctIndex: 0,
                         explanation: "Many flowers bloom in the spring!")
            ])
        ]
    )

    // MARK: - 🔬 7. Science Lab ⚗️

    static let scienceLab = Island(
        id: 6,
        name: "Science Lab",
        emoji: "🔬",
        accentEmoji: "⚗️",
        blurb: "Experiments, inventions and robots!",
        palette: .init(
            start: Color(red: 0.30, green: 0.72, blue: 0.98),
            end: Color(red: 0.32, green: 0.46, blue: 0.94)
        ),
        levels: [
            Level(number: 1, questions: [
                Question(prompt: "What color do you get by mixing blue and yellow?",
                         options: ["Green", "Purple", "Orange", "Pink"], correctIndex: 0,
                         explanation: "Blue + yellow makes green!"),
                Question(prompt: "What do we call frozen water?",
                         options: ["Steam", "Ice", "Juice", "Sand"], correctIndex: 1,
                         explanation: "Very cold water turns into ice."),
                Question(prompt: "Which invisible force pulls things down to the ground?",
                         options: ["Magic", "Gravity", "Wind", "Music"], correctIndex: 1,
                         explanation: "Gravity pulls everything down."),
                Question(prompt: "Which body part do you use to smell?",
                         options: ["Ear", "Nose", "Elbow", "Knee"], correctIndex: 1,
                         explanation: "Your nose helps you smell things."),
                Question(prompt: "What happens to water when it gets very hot?",
                         options: ["It turns to steam", "It freezes", "It turns pink", "Nothing"], correctIndex: 0,
                         explanation: "Boiling water turns into steam!"),
                Question(prompt: "A machine that can be built to do jobs for us is a...",
                         options: ["Robot", "Rock", "Cloud", "Tree"], correctIndex: 0,
                         explanation: "Robots are machines that help us."),
                Question(prompt: "Which of these gives us electricity at home?",
                         options: ["A plug socket", "A pillow", "A spoon", "A shoe"], correctIndex: 0,
                         explanation: "Electricity comes through plug sockets."),
                Question(prompt: "What do magnets do to metal like iron?",
                         options: ["Pull it", "Eat it", "Paint it", "Melt it"], correctIndex: 0,
                         explanation: "Magnets pull (attract) some metals."),
                Question(prompt: "Which of these floats on water?",
                         options: ["A wooden boat", "A big rock", "A metal key", "A brick"], correctIndex: 0,
                         explanation: "Light things like wooden boats float."),
                Question(prompt: "What do we call the study of nature and how things work?",
                         options: ["Science", "Cooking", "Dancing", "Sleeping"], correctIndex: 0,
                         explanation: "Science helps us understand the world!")
            ])
        ]
    )

    // MARK: - 🧩 8. Brain Castle 🏰

    static let brainCastle = Island(
        id: 7,
        name: "Brain Castle",
        emoji: "🧩",
        accentEmoji: "🏰",
        blurb: "Logic puzzles, riddles and memory!",
        palette: .init(
            start: Color(red: 0.66, green: 0.42, blue: 0.98),
            end: Color(red: 0.92, green: 0.40, blue: 0.78)
        ),
        levels: [
            Level(number: 1, questions: [
                Question(prompt: "What is 2 + 3?",
                         options: ["4", "5", "6", "7"], correctIndex: 1,
                         explanation: "2 plus 3 equals 5!"),
                Question(prompt: "Which shape has three sides?",
                         options: ["Circle", "Square", "Triangle", "Star"], correctIndex: 2,
                         explanation: "A triangle has three sides."),
                Question(prompt: "What comes next? 2, 4, 6, ___",
                         options: ["7", "8", "9", "5"], correctIndex: 1,
                         explanation: "Count by twos: 2, 4, 6, 8!"),
                Question(prompt: "Which number is the biggest?",
                         options: ["9", "4", "6", "2"], correctIndex: 0,
                         explanation: "9 is the biggest of these numbers."),
                Question(prompt: "What is 10 - 4?",
                         options: ["5", "6", "7", "8"], correctIndex: 1,
                         explanation: "10 take away 4 leaves 6."),
                Question(prompt: "Which one is an odd number?",
                         options: ["2", "4", "7", "8"], correctIndex: 2,
                         explanation: "7 is an odd number."),
                Question(prompt: "How many corners does a square have?",
                         options: ["3", "4", "5", "6"], correctIndex: 1,
                         explanation: "A square has 4 corners."),
                Question(prompt: "I am yellow, I am in the sky in the day. What am I?",
                         options: ["The Sun", "A fish", "A shoe", "A book"], correctIndex: 0,
                         explanation: "The Sun is yellow and shines in the day!"),
                Question(prompt: "What comes next? A, B, C, ___",
                         options: ["E", "D", "F", "Z"], correctIndex: 1,
                         explanation: "After A, B, C comes D!"),
                Question(prompt: "If you have 3 apples and get 2 more, how many do you have?",
                         options: ["4", "5", "6", "3"], correctIndex: 1,
                         explanation: "3 + 2 = 5 apples!")
            ])
        ]
    )

    // MARK: - 🏺 9. Ancient Kingdom 👑

    static let ancientKingdom = Island(
        id: 8,
        name: "Ancient Kingdom",
        emoji: "👑",
        accentEmoji: "🏺",
        blurb: "Egypt, Rome, kings, queens and history!",
        palette: .init(
            start: Color(red: 0.86, green: 0.66, blue: 0.30),
            end: Color(red: 0.70, green: 0.44, blue: 0.22)
        ),
        levels: [
            Level(number: 1, questions: [
                Question(prompt: "The giant pointy stone buildings of ancient Egypt are called...",
                         options: ["Pyramids", "Castles", "Towers", "Tents"], correctIndex: 0,
                         explanation: "The ancient Egyptians built huge pyramids."),
                Question(prompt: "A king's or queen's fancy head crown is called a...",
                         options: ["Crown", "Hat", "Helmet", "Cap"], correctIndex: 0,
                         explanation: "Kings and queens wear a crown."),
                Question(prompt: "Ancient Egyptian kings were called...",
                         options: ["Pharaohs", "Pilots", "Farmers", "Wizards"], correctIndex: 0,
                         explanation: "Egyptian kings were called pharaohs."),
                Question(prompt: "Big stone homes where kings and queens lived are called...",
                         options: ["Castles", "Huts", "Caves", "Tents"], correctIndex: 0,
                         explanation: "Royalty lived in grand castles."),
                Question(prompt: "Knights long ago wore metal suits called...",
                         options: ["Armor", "Pajamas", "Raincoats", "Costumes"], correctIndex: 0,
                         explanation: "Knights wore armor to stay safe."),
                Question(prompt: "What did people write on in ancient Egypt?",
                         options: ["Papyrus", "Phones", "Glass", "Plastic"], correctIndex: 0,
                         explanation: "Egyptians wrote on papyrus, an early kind of paper."),
                Question(prompt: "The ancient Romans built strong roads and...",
                         options: ["Bridges", "Rockets", "Cars", "Computers"], correctIndex: 0,
                         explanation: "Romans were famous builders of roads and bridges."),
                Question(prompt: "A story from long ago about the past is called...",
                         options: ["History", "Science", "Music", "Art"], correctIndex: 0,
                         explanation: "History is the study of the past."),
                Question(prompt: "Egyptians wrapped mummies in...",
                         options: ["Cloth bandages", "Leaves", "Paper cups", "Bubble wrap"], correctIndex: 0,
                         explanation: "Mummies were wrapped in long cloth bandages."),
                Question(prompt: "Cave people long ago discovered how to make...",
                         options: ["Fire", "Television", "Cars", "Phones"], correctIndex: 0,
                         explanation: "Making fire kept early people warm and cooked food.")
            ])
        ]
    )

    // MARK: - 🏆 10. Champion's Summit 🌟

    static let championsSummit = Island(
        id: 9,
        name: "Champion's Summit",
        emoji: "🏆",
        accentEmoji: "🌟",
        blurb: "The ultimate mixed quiz challenge!",
        palette: .init(
            start: Color(red: 1.00, green: 0.72, blue: 0.24),
            end: Color(red: 1.00, green: 0.46, blue: 0.36)
        ),
        levels: [
            Level(number: 1, questions: [
                Question(prompt: "How many colors are in a rainbow?",
                         options: ["7", "3", "5", "10"], correctIndex: 0,
                         explanation: "A rainbow has 7 beautiful colors!"),
                Question(prompt: "Which planet is the Red Planet?",
                         options: ["Mars", "Earth", "Venus", "Saturn"], correctIndex: 0,
                         explanation: "Mars is the Red Planet."),
                Question(prompt: "How many legs does a spider have?",
                         options: ["6", "8", "4", "10"], correctIndex: 1,
                         explanation: "Spiders have 8 legs."),
                Question(prompt: "What is 5 + 5?",
                         options: ["9", "10", "11", "12"], correctIndex: 1,
                         explanation: "5 + 5 = 10!"),
                Question(prompt: "Which animal is the King of the Jungle?",
                         options: ["Lion", "Tiger", "Bear", "Wolf"], correctIndex: 0,
                         explanation: "The lion is the King of the Jungle."),
                Question(prompt: "What do fish use to breathe?",
                         options: ["Gills", "Lungs", "Nose", "Ears"], correctIndex: 0,
                         explanation: "Fish breathe with gills."),
                Question(prompt: "How many days are in one week?",
                         options: ["5", "7", "10", "12"], correctIndex: 1,
                         explanation: "There are 7 days in a week."),
                Question(prompt: "What do bees make?",
                         options: ["Honey", "Milk", "Silk", "Juice"], correctIndex: 0,
                         explanation: "Bees make sweet honey."),
                Question(prompt: "Which shape is perfectly round?",
                         options: ["Circle", "Square", "Triangle", "Star"], correctIndex: 0,
                         explanation: "A circle is perfectly round."),
                Question(prompt: "What gives us light and warmth in the daytime?",
                         options: ["The Sun", "The Moon", "A lamp", "A star"], correctIndex: 0,
                         explanation: "The Sun gives us light and warmth!")
            ])
        ]
    )
}
