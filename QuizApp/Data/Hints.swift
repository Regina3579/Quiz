//
//  Hints.swift
//  QuizApp
//
//  The written clue behind Hint 1.
//
//  Keyed on the question's own prompt rather than an id, because a Question's
//  id is a fresh UUID every launch and there is nothing else stable to hold
//  on to. The keys here are generated from QuizData itself, so they match it
//  exactly; a clue whose prompt is edited simply stops being found, and the
//  hint quietly falls back to crossing out a wrong answer instead.
//
//  A clue points towards the answer without ever containing it — that is
//  checked, not hoped for. It is also why the explanations could not be used:
//  788 of the first thousand contain their own answer outright, because they
//  are written to be read *after* the question is done.
//
//  Ten adventures, a hundred questions each. Jungle Kingdom is written; the
//  rest have none yet, and until they do their first hint crosses out a wrong
//  answer exactly as it did before.
//

import Foundation

enum HintBook {

    /// Whether this prompt has a written clue.
    static func hasClue(for prompt: String) -> Bool { clues[prompt] != nil }

    static func clue(for prompt: String) -> String? { clues[prompt] }

    /// How many questions are written, for anyone counting the gap.
    static var writtenCount: Int { clues.count }

    // MARK: - Jungle Kingdom

    private static let clues: [String: String] = [
        "Which animal is a mammal that says 'moo' and gives us milk?":
            "You might see one standing in a field, chewing grass all day long.",
        "What do we call a group of wolves that lives and hunts together?":
            "The word also means a bundle you carry on your back.",
        "Which animal is famous for its black-and-white stripes?":
            "A black-and-white crossing on the road is named after this animal.",
        "Which bird is well known for copying human words?":
            "A colourful pet, and the bird a storybook pirate keeps on his shoulder.",
        "What do bees make and store as food for the winter?":
            "Sweet, golden and sticky — you might spread it on your toast.",
        "Which animal is the tallest in the world?":
            "Look for the one that can reach leaves nobody else can.",
        "How many legs does a spider have?":
            "The same number as an octopus has arms.",
        "Which of these animals can truly fly?":
            "The only one here with wings made of skin instead of feathers.",
        "What is a baby kangaroo called?":
            "It is also a boy's name, short for Joseph.",
        "Which sea animal is famous for having eight arms?":
            "Its name starts like 'octagon', a shape with eight sides.",
        "Which animal is known as the 'King of the Jungle'?":
            "Golden fur, a mighty roar, and a great furry collar.",
        "What is the fastest land animal?":
            "Slim body, long legs and black spots — built for sprinting.",
        "Which animal carries its home, a shell, on its back?":
            "It leaves a silvery trail behind it wherever it goes.",
        "What do we call an animal that eats only plants?":
            "'Herb' means plant. That is your clue.",
        "Which animal is the largest on land?":
            "Big flapping ears, a long trunk and thick grey legs.",
        "Which bird cannot fly but is a superb swimmer?":
            "It wears a smart black-and-white 'suit' and lives where it is icy.",
        "What do we call a baby frog that lives in water?":
            "A tiny swimmer with a tail it will lose as it grows up.",
        "Which animal can change colour to blend into its surroundings?":
            "Its eyes can look two different ways at the same time.",
        "Which bird hunts silently at night with huge eyes?":
            "'Noct' is an old word for night.",
        "What do we call animals that are awake at night and asleep by day?":
            "It hoots in the dark and can turn its head almost right round.",
        "What do we call a scientist who studies animals?":
            "Think of the place you visit to see animals from around the world.",
        "Which animal builds dams across rivers and streams?":
            "Big orange front teeth and a flat, paddle-shaped tail.",
        "What is a group of lions called?":
            "The word also means feeling very pleased with yourself.",
        "Which sea mammal is the biggest animal that has ever lived?":
            "Bigger than any dinosaur that ever lived — and it swims.",
        "What do we call an animal that eats both plants and meat?":
            "'Omni' is an old word meaning everything.",
        "Which animal can sleep standing up and run soon after birth?":
            "You can ride it, and its baby is called a foal.",
        "Which reptile can live for over 100 years?":
            "Slow, with a hard shell, and it lives on land rather than in water.",
        "Which animal finds its food in the dark using echoes of its own sounds?":
            "It hangs upside down to sleep and hunts by listening.",
        "Which big cat actually enjoys swimming?":
            "The big cat with stripes rather than spots.",
        "What do we call the long yearly journeys some animals make for food or warmth?":
            "The word is close to 'move' — a long journey to somewhere better.",
        "What is the thick hair around a male lion's head called?":
            "It rhymes with 'rain', and it makes him look grander.",
        "A rhino's horn is made of the same material as your...?":
            "Look at the very ends of your own fingers.",
        "What does a camel store inside its hump?":
            "Not water, though almost everyone guesses that. It is stored food.",
        "Which animal has a tongue up to 45 cm long to strip leaves from trees?":
            "Its neck is long — and so is the thing it eats with.",
        "An elephant's long, curved tusks are actually giant...?":
            "You have a set of these in your mouth right now.",
        "How do fish take in oxygen underwater?":
            "Look just behind a fish's head for flaps that open and close.",
        "Which bird can fly backwards and hover in one spot?":
            "Its wings beat so fast that they make a buzzing sound.",
        "Which animal can drop and then regrow its tail to escape danger?":
            "A small reptile that suns itself on warm rocks and walls.",
        "Deer antlers, which fall off and regrow bigger each year, are made of...?":
            "The same hard stuff that is inside your arms and legs.",
        "Which animal defends itself by spraying a horrible smell?":
            "Small, black-and-white, and you would smell it long before you saw it.",
        "Which animal group is warm-blooded and feeds its babies milk?":
            "You are one of these yourself.",
        "Frogs, toads and newts belong to which animal group?":
            "They live partly in the water and partly on the land.",
        "Snakes, lizards and crocodiles are all types of...?":
            "They have scales, and they are cold-blooded.",
        "How many body parts does an insect have?":
            "Head, middle and end — count the sections.",
        "Which of these is NOT a mammal?":
            "Look for the one with scales that hatches out of an egg.",
        "A spider is not an insect. What group does it belong to?":
            "Named after Arachne, a weaver in an old Greek story.",
        "Cold-blooded animals get their body warmth from...?":
            "A lizard lies on a warm rock all morning. Ask yourself why.",
        "What feature do all birds have that no other animal has?":
            "Look at what covers a bird and covers nothing else alive.",
        "Crabs, lobsters and shrimp belong to which group?":
            "Their name begins like 'crust' — think of a hard outer shell.",
        "What do we call animals that have no backbone?":
            "Putting 'in' at the front of a word usually flips it to the opposite.",
        "Which animal is the fastest on Earth when diving through the air?":
            "A bird of prey that drops out of the sky faster than a racing car.",
        "Which animal has the most powerful bite of any living creature?":
            "It has scales and lurks in rivers where the sea creeps in.",
        "Which is the largest living bird, far too heavy to fly?":
            "Long legs, long neck, and it runs instead of flying.",
        "Which animal can hold its breath the longest underwater?":
            "It dives into the black deep to hunt giant squid.",
        "Which tiny animal can carry objects many times its own body weight?":
            "You might watch a line of them carrying crumbs across a path.",
        "Which creature has three hearts and blue blood?":
            "Eight arms, and it squirts ink when it is frightened.",
        "Which bird makes the longest migration, travelling pole to pole?":
            "A slim white seabird that chases summer from one end of the world to the other.",
        "Which mammal lays eggs instead of giving birth to live young?":
            "A duck's bill, a beaver's tail, and it lives in Australia.",
        "What is a group of crows usually called?":
            "The word sounds alarming — like a terrible crime.",
        "Which animal is famous for sleeping up to 20 hours every day?":
            "It lives in Australia and eats nothing but eucalyptus leaves.",
        "Which sea creature can change both its colour and its skin texture to hide?":
            "A cousin of the octopus and the squid, with a flat shell inside it.",
        "Which rare big cat lives high in cold, snowy mountains?":
            "A big cat with thick pale fur and a very long tail for balance.",
        "Which animal's stripes are found on its skin, not just its fur?":
            "Shave this animal and you would still see the pattern.",
        "Which bird lays its eggs in other birds' nests and lets them raise its chick?":
            "A famous wooden clock is named after this bird's call.",
        "Which animal has fingerprints so like ours they can be confused under a microscope?":
            "It dozes in a eucalyptus tree in Australia.",
        "Which is the only mammal capable of true, flapping flight?":
            "It sleeps hanging upside down and catches insects at night.",
        "Which fish can give a powerful electric shock to stun its prey?":
            "Long and snake-like, it lives in South American rivers.",
        "Which animal has a neck with the same number of bones as a human?":
            "Seven bones — the same as yours, only a great deal longer.",
        "Which meerkat behaviour helps keep the group safe while feeding?":
            "While the others eat, somebody has to be watching.",
        "How do honeybees tell the hive where to find good flowers?":
            "They cannot speak, so they say it by moving their bodies.",
        "How do emperor penguins survive the freezing Antarctic winter?":
            "Think what you would do in a crowd on a freezing cold day.",
        "Why do some animals hibernate through the winter?":
            "There is nothing to eat outside. What is the sensible thing to do?",
        "Why do camels have long eyelashes and nostrils they can close?":
            "Think about what the wind is full of where a camel lives.",
        "Why do peacocks fan out their huge, colourful tails?":
            "Only the males do it, and mostly in spring.",
        "How do dolphins find fish in dark or murky water?":
            "They make clicking sounds and listen for them coming back.",
        "Why do some harmless animals copy the bright colours of dangerous ones?":
            "If you looked poisonous, who would risk eating you?",
        "Why do wolves howl?":
            "They are far apart in a big dark forest and need to say so.",
        "What is a group of lookout-loving meerkats or a wolf family an example of?":
            "Meerkats, wolves and bees all share this: none of them lives alone.",
        "Why do arctic animals like the arctic fox turn white in winter?":
            "Think what colour everything around them turns in winter.",
        "Why do sharks never run out of teeth?":
            "There are rows and rows of spares waiting behind the front row.",
        "A giant panda's extra 'thumb' for gripping bamboo is really an enlarged...?":
            "Feel the part of your own arm just before your hand begins.",
        "What do we call an animal that is active mainly at dawn and dusk?":
            "A long word for the dim light at the very start and end of the day.",
        "Which animal has the largest eyes of any creature on Earth?":
            "It lives in the deep dark sea, where being able to see helps most.",
        "Which is the largest primate in the world?":
            "The biggest of all the apes, and the old males go silver on the back.",
        "What is the complete body change from caterpillar to butterfly called?":
            "A long Greek word meaning 'a change of shape'.",
        "Kangaroos and koalas raise tiny babies in a pouch. What group are they?":
            "Their name comes from an old word for a pouch.",
        "What is the tough protein that forms hair, claws, feathers and rhino horns?":
            "The same stuff your own fingernails are made of.",
        "Which egg-laying mammal, like the platypus, slurps up ants with a sticky tongue?":
            "Covered all over in spines, rather like a hedgehog.",
        "Which venomous sea animal is very dangerous yet has no brain, only a nerve net?":
            "Almost see-through, it drifts along with the current.",
        "What is the largest species of big cat in the world?":
            "It has stripes, and it lives somewhere that snows.",
        "What do we call animals that have a backbone?":
            "Think of the little bones running all the way down your back.",
        "Which venomous snake is the longest in the world?":
            "It can rear up high and spread a hood behind its head.",
        "What is the fastest fish in the ocean?":
            "Its huge back fin looks like something you would see on a boat.",
        "Which insects build tall mounds and live with a queen, workers and soldiers?":
            "Pale, ant-like, and they eat their way through wood.",
        "Which is the largest fish in the sea, yet feeds gently on tiny plankton?":
            "Spotted and gentle, it strains its tiny food out of the water.",
        "Which bird dives the deepest, plunging over 500 metres for food?":
            "A bird that cannot fly at all, but swims beautifully in Antarctica.",
        "The work of protecting animals and habitats so species do not die out is called...?":
            "It comes from an old word meaning 'to keep safe'.",
        "When every last member of an animal species is gone forever, we call it...?":
            "When a fire goes out for good, we say it has been ex-something.",
        "Which clever ocean mammal uses tools, such as a rock, to crack open shellfish?":
            "It floats along on its back, wrapped in thick brown fur.",
        "Which powerful eagle-like predator is the top hunter of the sky in its habitat?":
            "A huge bird of prey with a shining head and a hooked beak."
    ]
}
