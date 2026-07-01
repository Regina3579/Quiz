//
//  QuizData.swift
//  QuizApp
//
//  Bundled kid-friendly quiz content. Eight playful "adventures",
//  each with fun, age-appropriate questions and cheerful explanations.
//

import SwiftUI

/// Provides the built-in quizzes shipped with the app.
enum QuizData {

    /// All categories, in the order they appear on the home screen.
    static let all: [Quiz] = [
        exploreTheWorld,
        journeyToSpace,
        wildKingdom,
        dinoAdventure,
        scienceLab,
        timeMachine,
        brainChallenge,
        dailyChallenge
    ]

    // MARK: - 🌍 Explore the World

    static let exploreTheWorld = Quiz(
        title: "Explore the World",
        subtitle: "Countries, oceans & wonders",
        emoji: "🌍",
        symbol: "globe.americas.fill",
        palette: .init(
            start: Color(red: 0.20, green: 0.78, blue: 0.72),
            end: Color(red: 0.16, green: 0.55, blue: 0.85)
        ),
        questions: [
            Question(
                prompt: "How many continents are there on Earth?",
                options: ["5", "7", "10", "3"],
                correctIndex: 1,
                explanation: "There are 7 continents, like Asia, Africa and Antarctica!"
            ),
            Question(
                prompt: "Which is the biggest ocean in the world?",
                options: ["Atlantic", "Indian", "Pacific", "Arctic"],
                correctIndex: 2,
                explanation: "The Pacific Ocean is the largest and deepest of them all!"
            ),
            Question(
                prompt: "The Great Pyramids are found in which country?",
                options: ["Egypt", "Italy", "Japan", "Brazil"],
                correctIndex: 0,
                explanation: "The amazing pyramids are in Egypt, in Africa."
            ),
            Question(
                prompt: "Which animal is a famous symbol of Australia?",
                options: ["Panda", "Kangaroo", "Lion", "Penguin"],
                correctIndex: 1,
                explanation: "Kangaroos hop all around Australia!"
            ),
            Question(
                prompt: "What do we call the frozen land at the very bottom of Earth?",
                options: ["Desert", "Jungle", "Antarctica", "Island"],
                correctIndex: 2,
                explanation: "Antarctica is super cold and covered in ice and snow!"
            )
        ]
    )

    // MARK: - 🚀 Journey to Space

    static let journeyToSpace = Quiz(
        title: "Journey to Space",
        subtitle: "Planets, stars & rockets",
        emoji: "🚀",
        symbol: "sparkles",
        palette: .init(
            start: Color(red: 0.44, green: 0.36, blue: 0.95),
            end: Color(red: 0.72, green: 0.34, blue: 0.90)
        ),
        questions: [
            Question(
                prompt: "Which planet is known as the Red Planet?",
                options: ["Earth", "Mars", "Venus", "Neptune"],
                correctIndex: 1,
                explanation: "Mars looks red because of the rusty dust on it!"
            ),
            Question(
                prompt: "What do we call a person who travels to space?",
                options: ["Pilot", "Astronaut", "Sailor", "Diver"],
                correctIndex: 1,
                explanation: "Astronauts wear special suits and fly in rockets!"
            ),
            Question(
                prompt: "What is the big bright star that gives us daylight?",
                options: ["The Moon", "The Sun", "Jupiter", "A comet"],
                correctIndex: 1,
                explanation: "The Sun is a giant star that keeps us warm and bright!"
            ),
            Question(
                prompt: "What goes around the Earth and glows at night?",
                options: ["The Moon", "A plane", "The Sun", "A cloud"],
                correctIndex: 0,
                explanation: "The Moon orbits Earth and lights up the night sky."
            ),
            Question(
                prompt: "Which planet has beautiful rings around it?",
                options: ["Mercury", "Saturn", "Earth", "Mars"],
                correctIndex: 1,
                explanation: "Saturn has stunning rings made of ice and rock!"
            )
        ]
    )

    // MARK: - 🦁 Wild Kingdom

    static let wildKingdom = Quiz(
        title: "Wild Kingdom",
        subtitle: "Amazing animals everywhere",
        emoji: "🦁",
        symbol: "pawprint.fill",
        palette: .init(
            start: Color(red: 1.00, green: 0.66, blue: 0.24),
            end: Color(red: 0.96, green: 0.42, blue: 0.30)
        ),
        questions: [
            Question(
                prompt: "Which animal is called the 'King of the Jungle'?",
                options: ["Tiger", "Lion", "Bear", "Wolf"],
                correctIndex: 1,
                explanation: "The mighty lion is known as the King of the Jungle!"
            ),
            Question(
                prompt: "What is the tallest animal in the world?",
                options: ["Elephant", "Giraffe", "Horse", "Camel"],
                correctIndex: 1,
                explanation: "Giraffes have super long necks to reach tall trees!"
            ),
            Question(
                prompt: "Which animal can change its color to hide?",
                options: ["Chameleon", "Dog", "Rabbit", "Cow"],
                correctIndex: 0,
                explanation: "Chameleons change color to blend in. So sneaky!"
            ),
            Question(
                prompt: "What do bees make that is sweet and yummy?",
                options: ["Milk", "Honey", "Juice", "Jam"],
                correctIndex: 1,
                explanation: "Busy bees make delicious honey from flower nectar!"
            ),
            Question(
                prompt: "Which sea animal has eight arms?",
                options: ["Fish", "Octopus", "Crab", "Dolphin"],
                correctIndex: 1,
                explanation: "An octopus has eight wiggly arms called tentacles!"
            )
        ]
    )

    // MARK: - 🦕 Dino Adventure

    static let dinoAdventure = Quiz(
        title: "Dino Adventure",
        subtitle: "Roar with the dinosaurs",
        emoji: "🦕",
        symbol: "leaf.fill",
        palette: .init(
            start: Color(red: 0.40, green: 0.80, blue: 0.42),
            end: Color(red: 0.20, green: 0.62, blue: 0.40)
        ),
        questions: [
            Question(
                prompt: "Which dinosaur had a huge mouth full of sharp teeth?",
                options: ["T. rex", "Triceratops", "Brachiosaurus", "Stegosaurus"],
                correctIndex: 0,
                explanation: "Tyrannosaurus rex had giant, scary teeth!"
            ),
            Question(
                prompt: "What did plant-eating dinosaurs mostly munch on?",
                options: ["Meat", "Plants", "Rocks", "Fish"],
                correctIndex: 1,
                explanation: "Herbivore dinosaurs ate leaves and plants all day!"
            ),
            Question(
                prompt: "Which dinosaur had three horns on its head?",
                options: ["Triceratops", "Velociraptor", "T. rex", "Diplodocus"],
                correctIndex: 0,
                explanation: "Triceratops had three pointy horns to stay safe!"
            ),
            Question(
                prompt: "What do we call a scientist who digs up dinosaur bones?",
                options: ["Astronaut", "Paleontologist", "Chef", "Painter"],
                correctIndex: 1,
                explanation: "Paleontologists dig up fossils to learn about dinosaurs!"
            ),
            Question(
                prompt: "Dinosaurs hatched from what?",
                options: ["Eggs", "Seeds", "Clouds", "Bubbles"],
                correctIndex: 0,
                explanation: "Baby dinosaurs hatched out of eggs, just like birds!"
            )
        ]
    )

    // MARK: - 🔬 Science Lab

    static let scienceLab = Quiz(
        title: "Science Lab",
        subtitle: "Cool experiments & facts",
        emoji: "🔬",
        symbol: "atom",
        palette: .init(
            start: Color(red: 0.30, green: 0.74, blue: 0.98),
            end: Color(red: 0.30, green: 0.48, blue: 0.95)
        ),
        questions: [
            Question(
                prompt: "What do plants need to grow big and strong?",
                options: ["Only candy", "Sunlight and water", "Only darkness", "Ice cream"],
                correctIndex: 1,
                explanation: "Plants love sunlight and water to grow!"
            ),
            Question(
                prompt: "What color do you get by mixing blue and yellow?",
                options: ["Green", "Purple", "Orange", "Pink"],
                correctIndex: 0,
                explanation: "Blue + yellow makes a lovely green!"
            ),
            Question(
                prompt: "What do we call frozen water?",
                options: ["Steam", "Ice", "Juice", "Sand"],
                correctIndex: 1,
                explanation: "When water gets very cold, it turns into ice!"
            ),
            Question(
                prompt: "Which body part helps you smell yummy food?",
                options: ["Ear", "Nose", "Elbow", "Knee"],
                correctIndex: 1,
                explanation: "Your nose helps you smell all kinds of things!"
            ),
            Question(
                prompt: "What pulls things down to the ground when you drop them?",
                options: ["Magic", "Gravity", "Wind", "Music"],
                correctIndex: 1,
                explanation: "Gravity is the invisible force that pulls things down!"
            )
        ]
    )

    // MARK: - ⏰ Time Machine

    static let timeMachine = Quiz(
        title: "Time Machine",
        subtitle: "Long, long ago...",
        emoji: "⏰",
        symbol: "hourglass",
        palette: .init(
            start: Color(red: 0.95, green: 0.55, blue: 0.72),
            end: Color(red: 0.80, green: 0.36, blue: 0.66)
        ),
        questions: [
            Question(
                prompt: "What did people ride before cars were invented?",
                options: ["Rockets", "Horses", "Airplanes", "Trains only"],
                correctIndex: 1,
                explanation: "Long ago, people traveled on horses and carts!"
            ),
            Question(
                prompt: "Ancient knights wore metal suits called what?",
                options: ["Pajamas", "Armor", "Raincoats", "Costumes"],
                correctIndex: 1,
                explanation: "Knights wore shiny armor to protect themselves!"
            ),
            Question(
                prompt: "What did people use to write before pencils and pens?",
                options: ["Feathers", "Phones", "Crayons", "Markers"],
                correctIndex: 0,
                explanation: "People wrote with feather quills dipped in ink!"
            ),
            Question(
                prompt: "Big stone homes for kings and queens are called what?",
                options: ["Tents", "Castles", "Huts", "Caves"],
                correctIndex: 1,
                explanation: "Kings and queens lived in grand castles!"
            ),
            Question(
                prompt: "Cavemen long ago discovered how to make what?",
                options: ["Fire", "Television", "Cars", "Robots"],
                correctIndex: 0,
                explanation: "Making fire helped early people stay warm and cook!"
            )
        ]
    )

    // MARK: - 🧠 Brain Challenge

    static let brainChallenge = Quiz(
        title: "Brain Challenge",
        subtitle: "Puzzles, numbers & riddles",
        emoji: "🧠",
        symbol: "puzzlepiece.fill",
        palette: .init(
            start: Color(red: 0.66, green: 0.42, blue: 0.98),
            end: Color(red: 0.92, green: 0.38, blue: 0.76)
        ),
        questions: [
            Question(
                prompt: "What is 2 + 3?",
                options: ["4", "5", "6", "7"],
                correctIndex: 1,
                explanation: "2 plus 3 equals 5. Great counting!"
            ),
            Question(
                prompt: "Which shape has three sides?",
                options: ["Circle", "Square", "Triangle", "Star"],
                correctIndex: 2,
                explanation: "A triangle has three straight sides!"
            ),
            Question(
                prompt: "What comes next? 2, 4, 6, __ ?",
                options: ["7", "8", "9", "5"],
                correctIndex: 1,
                explanation: "We count by twos: 2, 4, 6, 8!"
            ),
            Question(
                prompt: "How many legs does a spider have?",
                options: ["6", "8", "4", "10"],
                correctIndex: 1,
                explanation: "Spiders have 8 legs. That's a lot of legs!"
            ),
            Question(
                prompt: "Which one is the odd number?",
                options: ["2", "4", "7", "8"],
                correctIndex: 2,
                explanation: "7 is odd because it can't be split into equal pairs!"
            )
        ]
    )

    // MARK: - ⭐ Daily Challenge (a fun mix of everything)

    static let dailyChallenge = Quiz(
        title: "Daily Challenge",
        subtitle: "A fun mix for today!",
        emoji: "⭐",
        symbol: "star.fill",
        palette: .init(
            start: Color(red: 1.00, green: 0.72, blue: 0.24),
            end: Color(red: 1.00, green: 0.48, blue: 0.36)
        ),
        questions: [
            Question(
                prompt: "How many colors are in a rainbow?",
                options: ["3", "7", "5", "10"],
                correctIndex: 1,
                explanation: "A rainbow has 7 beautiful colors!"
            ),
            Question(
                prompt: "Which planet do we live on?",
                options: ["Mars", "Earth", "Saturn", "Venus"],
                correctIndex: 1,
                explanation: "We all live together on planet Earth!"
            ),
            Question(
                prompt: "What sound does a cow make?",
                options: ["Woof", "Moo", "Meow", "Quack"],
                correctIndex: 1,
                explanation: "Cows say 'Moo'! 🐄"
            ),
            Question(
                prompt: "How many days are in one week?",
                options: ["5", "7", "10", "12"],
                correctIndex: 1,
                explanation: "There are 7 days in a week!"
            ),
            Question(
                prompt: "What do you use to see in the dark?",
                options: ["A spoon", "A flashlight", "A pillow", "A shoe"],
                correctIndex: 1,
                explanation: "A flashlight helps you see when it's dark!"
            )
        ]
    )
}
