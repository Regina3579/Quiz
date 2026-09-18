//
//  Hints.swift
//  QuizApp
//
//  The written clue behind Hint 1. One for every question in the game.
//
//  Keyed on the question's own prompt rather than an id, because a Question's
//  id is a fresh UUID every launch and there is nothing else stable to hold
//  on to. The keys are generated from QuizData itself, so they match it
//  exactly; a clue whose prompt is later edited simply stops being found, and
//  that question's first hint quietly crosses out a wrong answer instead.
//
//  A clue points towards the answer without ever containing it, and that is
//  checked rather than hoped for — every clue is compared against its own
//  answer word by word, allowing for plurals, and against the digits and
//  number-words of a numeric answer. The check caught roughly forty leaks
//  while these were being written, including a clue that used the word
//  "eight" for an answer of Eight.
//
//  It is also why the explanations could not be used instead: 788 of the
//  first thousand contain their own answer outright, because they are
//  written to be read *after* the question has been answered.
//
//  Brain Castle is sums and riddles, so its clues point at a method rather
//  than a fact — "Count back five from twelve" instead of naming a number.
//

import Foundation

enum HintBook {

    /// Whether this prompt has a written clue.
    static func hasClue(for prompt: String) -> Bool { clues[prompt] != nil }

    static func clue(for prompt: String) -> String? { clues[prompt] }

    /// How many questions are written.
    static var writtenCount: Int { clues.count }

    private static let clues: [String: String] = [

        // MARK: Jungle Kingdom

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
            "A huge bird of prey with a shining head and a hooked beak.",
        // MARK: Galaxy Quest

        "Which planet do we live on?":
            "You are standing on it right now.",
        "What is the bright star that gives Earth light and warmth in the day?":
            "It is up there every clear morning, far too bright to look at.",
        "What glows in the night sky and changes shape through the month?":
            "Sometimes a thin curve, sometimes a full circle.",
        "What do we call a person who travels into space?":
            "A job with a helmet and a very long way to travel to work.",
        "What do we ride to blast off into space?":
            "Tall and pointed, and it leaves a pillar of fire behind it.",
        "Which planet is known as the Red Planet?":
            "Its soil is rusty, and it is named after a god of war.",
        "Which planet is famous for its beautiful rings?":
            "Picture a world wearing a hoop around its middle.",
        "What do we call the tiny points of light we see at night?":
            "There are thousands of them, and they twinkle.",
        "How many planets travel around our Sun?":
            "Count them from the closest to the Sun out to the farthest.",
        "Where do astronauts go to float and see Earth from far away?":
            "The place that begins where the sky runs out.",
        "Which planet is closest to the Sun?":
            "It shares its name with the silvery liquid in old thermometers.",
        "Which is the largest planet in our Solar System?":
            "Named after the king of the Roman gods.",
        "What does the Moon do around the Earth?":
            "It goes round and round, never getting closer or further away.",
        "What are the floating homes where astronauts live and circle the Earth called?":
            "A home built in orbit, piece by piece, that never comes down.",
        "What is the name of our home galaxy?":
            "On a very dark night it looks like a pale streak spilled across the sky.",
        "Which planet is the hottest in the Solar System?":
            "Not the closest to the Sun, but wrapped in a thick blanket of cloud.",
        "What do we call a rock smaller than a planet that orbits the Sun?":
            "A lump of rock too small ever to be a world of its own.",
        "What do we call a ball of ice and dust that grows a glowing tail near the Sun?":
            "A dirty snowball that grows a tail when it comes near the Sun.",
        "How long does the Earth take to travel once around the Sun?":
            "Think about what we celebrate on a birthday.",
        "What causes day and night on Earth?":
            "The Sun does not really move across the sky. Something else is moving.",
        "Which planet spins on its side, almost lying down?":
            "It rolls around the Sun like a barrel instead of a spinning top.",
        "Which planet is the farthest from the Sun?":
            "Named after the Roman god of the sea, and it looks deep blue.",
        "What is the giant centuries-old storm on Jupiter called?":
            "A storm bigger than our whole world, and it has a colour in its name.",
        "What do we call it when the Moon blocks the Sun and darkens the daytime sky?":
            "For a few minutes in the middle of the day, everything goes dark.",
        "Why do we see different shapes of the Moon during the month?":
            "Half of it is always lit. What changes is which half we can see.",
        "Which force keeps the planets circling the Sun instead of flying away?":
            "The same pull that brings a dropped ball back down to you.",
        "Which planet has the most moons?":
            "The one with the rings also has a great many little companions.",
        "What do we call the huge belt of rocks between Mars and Jupiter?":
            "A ring of rubble sitting between the rusty world and the giant one.",
        "How many moons does Earth have?":
            "You can see it from your window on a clear night.",
        "Which planet, like Earth, is a rocky world rather than a ball of gas?":
            "The rusty red one you could in theory stand on.",
        "What is the Sun mostly made of?":
            "It has no surface at all that you could ever land on.",
        "What do we call a pattern of stars that forms a picture in the sky?":
            "Join the dots in the sky and you might see a hunter or a bear.",
        "What are the dark, bowl-shaped holes on the Moon called?":
            "Made by rocks crashing down, and they are shaped like bowls.",
        "Which is bigger, the Sun or the Earth?":
            "One of these could swallow the other a million times over.",
        "Why do stars twinkle when we look at them?":
            "Seen from space they do not twinkle at all. Ask yourself why.",
        "What is a shooting star, really?":
            "It is not a star, and it never was one.",
        "About how long does sunlight take to reach the Earth?":
            "About long enough to boil an egg.",
        "Which star is the closest one to Earth?":
            "It looks enormous only because it is so very close.",
        "What is the North Star mainly used for?":
            "Sailors watched it for centuries. What did they most need to know?",
        "What do we call a moon or machine that orbits a planet?":
            "Anything that circles a planet, whether it was built or born there.",
        "Who was the first person to walk on the Moon?":
            "He said something about one small step.",
        "What do astronauts wear to survive outside their spacecraft?":
            "It carries its own air, and it takes a long time to put on.",
        "Why do astronauts float around inside their spacecraft?":
            "There is almost nothing pulling them down towards the floor.",
        "What do we call a robot vehicle that drives around exploring another planet?":
            "It has wheels and a camera, but nobody sitting at the controls.",
        "What is the powerful pushing force from the bottom of a rocket called?":
            "It rhymes with 'dust', and it is the push that lifts the whole thing.",
        "What machine do scientists use to see faraway planets and stars up close?":
            "Put one eye to it and something far away comes close.",
        "Which country's astronaut, Yuri Gagarin, was the first human in space?":
            "At the time, the country was called the Soviet Union.",
        "What do we call the curved path a spacecraft or planet follows around another object?":
            "The path itself, not the journey — a loop that keeps repeating.",
        "Can you hear sounds in outer space?":
            "Sound needs something to travel through. Is there anything out there?",
        "What do we shout backwards just before a rocket launches?":
            "Ten, nine, eight, seven...",
        "Pluto used to be called the ninth planet. What is it now called?":
            "Still round and still there — it simply has a smaller title now.",
        "What is the name of the icy region beyond Neptune where Pluto lives?":
            "A second ring of debris, much further out, made of ice rather than rock.",
        "What is the largest volcano in the Solar System, found on Mars?":
            "Named after the mountain where the Greek gods were said to live.",
        "What sits at the centre of our Solar System?":
            "Everything else goes round it.",
        "Which planet has a day that is longer than its year?":
            "It turns so slowly that a single spin takes longer than a whole lap.",
        "What do we call a group of billions of stars held together by gravity?":
            "Ours is one of them, and it is shaped like a whirlpool.",
        "What is the name of the giant telescope launched into space in 1990?":
            "Named after the astronomer who discovered other galaxies.",
        "What do we call a cloud of gas and dust in space where new stars are born?":
            "A nursery for stars, made of gas and dust.",
        "Roughly how many moons does Jupiter have?":
            "Far more than one or two, but not yet hundreds.",
        "A comet's glowing tail always points away from what?":
            "Something blows the tail outwards, always away from the same thing.",
        "What colour are the hottest stars?":
            "Think of a flame. Is the hottest part the red bit, or the other one?",
        "What is a collapsed object whose gravity is so strong even light cannot escape?":
            "Nothing that goes in ever comes back, and it gives off no light at all.",
        "What do we call a star that suddenly explodes at the end of its life?":
            "The word has 'new' buried inside it, though it marks an ending.",
        "What shape is our Milky Way galaxy?":
            "Like water going down a plughole, or the shell of a snail.",
        "What is the closest star to our Sun, besides the Sun itself?":
            "Its name begins like 'proximity', which means nearness.",
        "What do scientists call the huge event they think started the Universe?":
            "Named for a sound, although there was nobody there to hear it.",
        "Which galaxy is the nearest large neighbour to our Milky Way?":
            "Named after a princess chained to a rock in a Greek myth.",
        "What do we call the distance light travels in one year, used to measure space?":
            "It sounds like a length of time, but it measures distance.",
        "What do we call a group of many galaxies held together by gravity?":
            "A crowd of star-cities, all held together in one place.",
        "Our Sun is a star that is roughly... newborn, middle-aged, or dying today?":
            "It has burned for about five billion years and has five billion left.",
        "What is the International Space Station?":
            "Not a rocket and not a planet, but people do science aboard it.",
        "Why does everything weigh less on the Moon than on Earth?":
            "It is much smaller, so the pull it can manage is much smaller too.",
        "What was the name of the NASA missions that first landed people on the Moon?":
            "Named after a Greek god who drove the chariot of the Sun.",
        "What do we call the speed needed to break free of a planet's gravity for good?":
            "You have to go fast enough that you never fall back down again.",
        "What do we call space rocks that actually survive the fall and land on the ground?":
            "Most of them burn away. These are the ones that reach the ground.",
        "Which two probes launched in 1977 have now travelled beyond all the planets?":
            "Their name means travellers, and each carries a golden record.",
        "What was the first man-made satellite launched into orbit, back in 1957?":
            "A Russian word meaning 'companion', and all it did was beep.",
        "Why can't astronauts breathe in space without help?":
            "Look at what a spacesuit has to carry along with it.",
        "What do we call the blanket of gases held around a planet, like Earth's air?":
            "The word ends in 'sphere', because it wraps all the way round.",
        "Roughly how many stars are in our Milky Way galaxy?":
            "Far more than you could count in a lifetime of clear nights.",
        "What is the speed of light, the fastest speed in the Universe?":
            "Nothing goes faster; it could circle the Earth seven times while you blink.",
        "What do we call the four giant gas and ice worlds of the outer Solar System?":
            "They are enormous, and you could never stand on any of them.",
        "What is the powerful telescope launched in 2021 to see the earliest galaxies?":
            "Newer than Hubble, and it sees warmth rather than visible light.",
        "What do we call the boundary of a black hole, beyond which nothing can return?":
            "A line you can cross going in, but never coming back out.",
        "Which planet has a giant moon, Titan, with rivers and lakes of liquid methane?":
            "The ringed one, whose biggest moon has weather of its own.",
        "Sunlight reaches Earth in 8 minutes. Roughly how long to reach far-off Neptune?":
            "It sits about thirty times further from the Sun than we do.",
        "Isaac Newton explained how which force holds the whole Solar System together?":
            "An apple is supposed to have given him the idea.",
        "What do we call a Sun-like star once it swells up huge and red near the end of its life?":
            "Near the end it swells up enormously and cools to a warm colour.",
        "What mostly causes the ocean tides on Earth?":
            "The sea rises and falls twice a day, following something overhead.",
        "In which constellation do three bright stars in a row form a famous 'Belt'?":
            "The hunter, with a sword hanging from his middle.",
        "About how old is the Universe?":
            "Roughly three times as old as the Earth itself.",
        "In which part of the Sun is its energy actually made?":
            "The very middle, where it is hottest and most tightly squeezed.",
        "What do we call the moment a planet passes across the face of the Sun as a tiny dot?":
            "The same word we use for something passing across.",
        "What is the name of the dwarf planet that is the biggest object in the asteroid belt?":
            "Named after the Roman goddess of the harvest.",
        "Which planet is so light for its size that it would float in water?":
            "The ringed one is mostly gas, so for its size it weighs very little.",
        "What do we call the giant shell of icy objects thought to wrap far around the Solar System?":
            "Named after a Dutch astronomer, and it lies extremely far out.",
        "A neutron star, the crushed core of an exploded star, is famous for being extremely...?":
            "A single teaspoon of it would weigh as much as a mountain.",
        "Which planet is tipped so far that its poles take turns facing the Sun for years?":
            "The one that lies on its side.",
        "What is the name of the science that studies stars, planets and space?":
            "'Astro' is an old word for star.",
        "If the Sun were the size of a beach ball, the Earth would be about the size of what?":
            "Something round and green you might leave at the side of your plate.",
        // MARK: Dino Valley

        "Which fierce dinosaur was a mighty meat-eater with huge jaws and sharp teeth?":
            "Tiny arms, an enormous head, and the most famous name of them all.",
        "How did baby dinosaurs come into the world?":
            "The same way chicks and ducklings arrive.",
        "Which dinosaur had three horns and a wide bony frill around its neck?":
            "Its face was a shield, and it wore three sharp points on the front.",
        "What did plant-eating dinosaurs mostly eat?":
            "Look at what grows out of the ground and does not run away.",
        "What do we call dinosaur bones and remains found buried in rock?":
            "What is left in the stone long after the animal has gone.",
        "Which dinosaur had rows of bony plates standing up along its back?":
            "Its back looked like a row of upright shields, and its tail had spikes.",
        "Did dinosaurs live before or after people existed?":
            "There was nobody at all around to see them.",
        "Which dinosaur had a very long neck to reach leaves high in the trees?":
            "The tallest one, built rather like a crane.",
        "What do we call a dinosaur that ate meat?":
            "'Carne' is an old word for meat.",
        "Are the giant dinosaurs still alive on Earth today?":
            "Look around you. Do you see any?",
        "What do we call a scientist who studies dinosaurs and fossils?":
            "'Paleo' means ancient, and 'ology' means the study of something.",
        "Which flying reptile lived in the age of dinosaurs?":
            "A great winged reptile with a crest on its head and no teeth.",
        "Which small, speedy meat-eater had a large curved claw on each foot?":
            "Small, fast, feathered, and famous from the films — though smaller in life.",
        "Which armoured dinosaur had a heavy bony club on the end of its tail?":
            "Built like a tank, with a hammer on the end of its tail.",
        "How big were even the largest dinosaur eggs, roughly?":
            "Surprisingly small for such huge animals — you could hold one in two hands.",
        "What did many small dinosaurs have covering their bodies, as fossils now show?":
            "The same thing that keeps a bird warm today.",
        "Which period is often called the 'Age of Dinosaurs'?":
            "'Meso' means middle, and 'zoic' means life.",
        "Which huge meat-eater, even bigger than T. rex, had a sail on its back?":
            "Even longer than the famous one, and it had a great fin down its spine.",
        "What shape were the teeth of plant-eating dinosaurs usually?":
            "Think about how your own back teeth work on tough food.",
        "Roughly how long ago did the last dinosaurs die out?":
            "Long enough ago that the continents have moved since.",
        "What does the name 'Tyrannosaurus rex' mean?":
            "It was the biggest hunter of all, and its name says so grandly.",
        "What does the name 'Triceratops' mean?":
            "Count the sharp points on the front of its head.",
        "What do we call the group of two-legged meat-eating dinosaurs?":
            "'Theros' means beast — these were the two-legged hunters.",
        "What do we call the group of giant long-necked plant-eaters?":
            "'Sauros' means lizard — these were the enormous long-necked ones.",
        "What do we call the sharp spikes on the tail of a Stegosaurus?":
            "It was named as a joke in a cartoon, and the name stuck.",
        "Iguanodon had an unusual spike. Where was it?":
            "Look at the one digit on your own hand that points sideways.",
        "Which very long dinosaur had a thin, whip-like tail and could stretch over 25 metres?":
            "Extremely long and thin, with a tail like a stockwhip.",
        "During which period did T. rex and Triceratops both live?":
            "The last of the three periods, right at the end.",
        "Which big meat-eater hunted during the Jurassic, long before T. rex appeared?":
            "The great hunter of its day, but it died out long before the famous one.",
        "In which country's desert were the first Velociraptor fossils found?":
            "A country in Asia, famous for the Gobi Desert.",
        "Why did some plant-eating dinosaurs swallow smooth stones?":
            "They had no teeth for chewing. Something had to do the job instead.",
        "Which flying reptile was one of the largest ever, with wings as wide as a small plane?":
            "Its name comes from an Aztec feathered serpent god.",
        "Which giant sea reptile was a fierce ocean hunter during the dinosaur age?":
            "A huge swimming lizard, not unlike a crocodile built for the open sea.",
        "Were pterosaurs and sea reptiles actually dinosaurs?":
            "They flew or swam, and true members of the group did neither.",
        "What do we call plant-eating dinosaurs by their diet?":
            "'Herb' means plant.",
        "How do scientists think a running meat-eater's long, stiff tail helped it?":
            "Try sprinting while holding a long pole out behind you.",
        "Which dinosaur was one of the smallest, about the size of a chicken?":
            "About the size of something you might keep in a farmyard.",
        "How do scientists work out how fast a dinosaur could move?":
            "They left marks in soft mud that turned to stone.",
        "What might duck-billed dinosaurs like Parasaurolophus have used their head crests for?":
            "They were hollow tubes joined to the nose. What could you do with that?",
        "Which armoured dinosaur was protected by bony plates set right into its skin?":
            "Built like a tank, with plates set right into its hide.",
        "What special word means fossilised dinosaur poop?":
            "'Copro' is an old word for dung, and 'lite' means stone.",
        "Which dinosaur was the very first to be given a scientific name, back in 1824?":
            "Its name simply means 'great lizard', which was enough at the time.",
        "Fossils are most often found in which kind of rock?":
            "The kind of stone made from layers of mud and sand settling.",
        "How long does it usually take for a fossil to form?":
            "Far longer than a person could ever wait.",
        "When a dinosaur skeleton is missing bones, how do scientists complete it?":
            "If one bone is missing, they look at a cousin that still has it.",
        "What was Maiasaura, meaning 'good mother lizard', famous for?":
            "Her name says she was a good mother. What would a good mother do?",
        "Why did many plant-eating dinosaurs live together in herds?":
            "A lone animal is easy to catch. A crowd is not.",
        "Which ostrich-like dinosaurs were built for speed with long legs and toothless beaks?":
            "Long legs and a beak with no teeth — built like a modern running bird.",
        "What do we call the study of ancient life through fossils?":
            "'Paleo' means ancient, and 'ology' means the study of it.",
        "On how many continents have dinosaur fossils been found?":
            "They have been found even in Antarctica.",
        "What are the three periods of the Age of Dinosaurs, in order?":
            "Three long names ending in '-assic' and '-aceous', oldest first.",
        "Which enormous plant-eater, found in Argentina, was among the biggest land animals ever?":
            "It is named after the South American country where it was dug up.",
        "Which sea reptiles had four wide flippers and often very long necks?":
            "Four wide paddles and a neck like a swan's.",
        "Today's birds are most closely related to which group of dinosaurs?":
            "The two-legged hunters, oddly enough — not the gentle giants.",
        "What do we call the flying reptiles of the dinosaur age as a group?":
            "'Ptero' means wing.",
        "Stegosaurus is famous for having a brain about the size of what?":
            "Something you might crack open at Christmas.",
        "Which dinosaur had a sail on its back and hunted mainly in the water?":
            "The one with the great fin down its spine.",
        "Which winged dinosaur relative had a large head crest and a toothless beak?":
            "A crested head and a toothless beak, gliding above the sea.",
        "Besides defence, what may the plates on a Stegosaurus have helped with?":
            "They were full of blood vessels. Think what that is useful for.",
        "Which dinosaur had a very thick, domed skull it may have used for head-butting?":
            "'Pachy' means thick, and 'cephalo' means head.",
        "What is the scientific word for a dinosaur that walks on two legs?":
            "'Bi' means two, and 'ped' means foot.",
        "Which raptor, larger than Velociraptor, had a big sickle claw and lived in North America?":
            "Its name means 'terrible claw', and it hunted in North America.",
        "Which dinosaur's name means 'roofed lizard', for the plates on its back?":
            "The plates along its spine looked to its discoverer like roof tiles.",
        "About how many teeth could a T. rex have in its powerful jaws?":
            "About five dozen.",
        "Which plant-eater is famous as one of the first dinosaurs ever discovered and studied?":
            "Named after a lizard alive today, because its teeth looked the same.",
        "What do we call an animal, like a few dinosaurs, that eats both plants and meat?":
            "'Omni' means everything.",
        "Which giant sauropod's name means 'arm lizard', for its long front legs?":
            "Its front legs were longer than its back ones, like a giraffe's.",
        "Fossil skin impressions show that many dinosaurs had skin that was mostly...?":
            "Feel the skin of a lizard or a crocodile.",
        "What was the tail club of an Ankylosaurus made of, used to defend itself?":
            "The same hard stuff as the rest of its skeleton.",
        "What helped scientists learn what colour a few dinosaurs may have been?":
            "Look very closely at a preserved wing and you can see what once gave it its shade.",
        "What do most scientists think helped cause the dinosaurs' extinction?":
            "Something enormous fell out of the sky.",
        "Where did the giant asteroid leave a huge buried crater?":
            "A country just south of the United States.",
        "Besides the asteroid, what else may have harmed the dinosaurs' world?":
            "Think of mountains that pour out fire and smoke for thousands of years.",
        "After the dinosaurs died out, which animals grew larger and spread across the world?":
            "The warm-blooded animals that fed their babies milk got their chance.",
        "Which group of dinosaurs did NOT die out completely, surviving as a familiar animal today?":
            "Look out of the window at anything with feathers.",
        "What do we call the moment when a whole kind of animal dies out forever?":
            "When the very last one of a kind is gone, and none will come again.",
        "Why is it hard to know exactly how the dinosaurs died out?":
            "Nobody was there to write it down.",
        "How long did dinosaurs rule the Earth, roughly?":
            "Far longer than people have existed — over a hundred times longer.",
        "What can studying dinosaurs teach us about our own planet?":
            "Whole kinds of creature come and go. What does that show us?",
        "Rocks from the time dinosaurs died hold a rare metal called iridium. Where does it usually come from?":
            "It is rare in our rocks but common in the things that fall from the sky.",
        "What is the proper name for the whole 'Age of Dinosaurs'?":
            "'Meso' means middle, and 'zoic' means life.",
        "Which dinosaur's name means 'good mother lizard'?":
            "Her nests full of babies gave her the name.",
        "What do we call the group of horned, frilled dinosaurs that includes Triceratops?":
            "'Cerat' means horn, and these ones wore them on their faces.",
        "Which dinosaur's name means 'terrible claw', for the sickle claw on its foot?":
            "The sickle on its foot gave it a frightening name.",
        "Which enormous long-necked dinosaur was once mistakenly known as 'Brontosaurus'?":
            "The famous wrong name was 'thunder lizard'. This is the real one.",
        "Which early fossil, with feathers and wings but teeth and a bony tail, links dinosaurs and birds?":
            "Its name means 'ancient wing', and it is the missing link.",
        "Which sea reptile group, though not dinosaurs, looked a lot like today's dolphins?":
            "They were shaped for speed in the water, with a fin on the back.",
        "What is a 'trackway' that scientists study?":
            "A whole line of prints, showing how the animal actually moved.",
        "Roughly how high could Brachiosaurus reach up to feed?":
            "Tall enough to look in at a window several floors up.",
        "Giant flying reptiles ruled the skies in the Age of Dinosaurs, but they were not dinosaurs. What were they?":
            "'Ptero' means wing, and they were only cousins of the dinosaurs.",
        "About when did the very first dinosaurs appear on Earth?":
            "Before the first of the three great periods had finished.",
        "Which of these was NOT a dinosaur at all?":
            "It flew, and nothing that flew belonged to the group.",
        "What is the buried crater near Mexico, evidence of the dinosaurs' doom, called?":
            "Named after a small town on the Yucatan coast.",
        "Which giant meat-eater is measured as possibly the longest of all, from North Africa?":
            "The one with the fin on its back may have been the longest of all.",
        "Which period came right in the middle of the Age of Dinosaurs?":
            "The middle one of the three, and the one a famous film is named after.",
        "Birds are the living descendants of which dinosaur group?":
            "The two-legged hunters, the same group as the terrible claw.",
        "Which armoured dinosaur could swing a heavy bony club to break an attacker's bones?":
            "It carried a bony hammer on its tail.",
        "Which name means 'three-horned face' in Greek?":
            "Count the points on its face.",
        "What do we call a scientist who might spend months digging out a single dinosaur skeleton?":
            "'Paleo' means ancient, and 'ology' means the study of something.",
        "Roughly how long ago did the dinosaurs' long reign finally end?":
            "Long enough ago that the continents have shifted since.",
        // MARK: Ocean Paradise

        "Which sea animal has eight wiggly arms?":
            "Its name begins like 'octagon', a shape with eight sides.",
        "What is the biggest animal living in the ocean?":
            "Bigger than any dinosaur that ever walked, and it has a colour in its name.",
        "How do most fish breathe underwater?":
            "Look just behind the head for flaps that open and close.",
        "Which clever sea animal loves to leap and play?":
            "It rides the bow wave of boats and seems to be smiling.",
        "Which sea creature can sting with its trailing tentacles?":
            "See-through, drifting, and best not touched.",
        "Which fish is famous for its many rows of sharp teeth?":
            "A fin above the water is the warning everyone knows.",
        "Which sea animal carries a hard shell it can never leave?":
            "It comes ashore to bury its eggs in the sand.",
        "Which sea creature scuttles sideways and has strong pincers?":
            "It walks to the left or the right, never straight ahead.",
        "Which upright little fish is shaped like a tiny horse?":
            "The male is the one who carries the babies.",
        "Most of the Earth's surface is covered by what?":
            "Look at a globe and see which colour covers most of it.",
        "What makes ocean water taste different from a river?":
            "Sprinkle a little on your chips.",
        "Why must whales and dolphins swim up to the surface?":
            "They have lungs, exactly as you do.",
        "What do we call the sandy edge where the sea meets the land?":
            "Bucket and spade country.",
        "What do we call a big group of fish swimming together?":
            "The same word as the place you go on weekday mornings.",
        "Which bird dives beak-first into the sea using a stretchy throat pouch?":
            "Its enormous beak works like a fishing net.",
        "Penguins cannot fly through the air, but they are brilliant at what?":
            "They shoot through the water like little torpedoes.",
        "Which sea animal breathes through a blowhole on top of its head?":
            "Watch for the spout of spray shooting upwards.",
        "Which shellfish can grow a shiny pearl inside its shell?":
            "Look for a rough, hinged shell that clamps tightly shut.",
        "Crabs, lobsters and shrimp all have a...":
            "Like a suit of armour worn on the outside.",
        "Which is far bigger, an ocean or a lake?":
            "One holds a boat; the other holds continents apart.",
        "How do dolphins find food and 'see' in dark water?":
            "They make clicking sounds and listen for them bouncing back.",
        "Whales, dolphins and seals are not fish. They are actually...":
            "They feed their babies milk and breathe air.",
        "What is a baby whale called?":
            "The same word we use for a young cow.",
        "Which tiny, shrimp-like food do giant baleen whales strain from the sea?":
            "So small that a giant must eat millions in a single mouthful.",
        "Which sea mammal cracks open shellfish using a rock on its belly?":
            "It floats along on its back, wrapped in thick brown fur.",
        "What keeps whales and seals warm in freezing water?":
            "A generous padding of fat, wrapped right around under the skin.",
        "Which whale is famous for singing long, haunting songs?":
            "The males sing for hours, and the songs change each year.",
        "Which barking sea mammal has long whiskers and walks on its flippers?":
            "It barks, and it can prop itself up on its front flippers.",
        "What do we call the family group that dolphins live and travel in?":
            "Peas grow in one of these.",
        "How long can some diving whales hold their breath?":
            "Longer than you could possibly manage in a swimming pool.",
        "Which is the biggest fish in the sea, a gentle giant that eats plankton?":
            "Enormous, spotted and gentle — it strains its food from the water.",
        "A shark's skeleton is not made of bone. What is it made of?":
            "The same springy stuff that is in the tip of your own nose.",
        "What helps a shark notice a few drops of blood from far away?":
            "Think of what a bloodhound is famous for doing with its nose.",
        "Which fish blows up into a spiky ball when it feels scared?":
            "It swells into a prickly ball when frightened.",
        "Which little fish makes its home among a stinging sea anemone?":
            "It is orange and white, and a famous film was made about one.",
        "What do we call the fin on the top of a fish's back?":
            "'Dorsum' is an old word for back.",
        "A flatfish like a flounder has both of its eyes...":
            "It lies flat on the sea bed, so it needs to look upwards.",
        "Which long, snake-like fish hides in rocky holes with just its head out?":
            "Long, ribbon-like and lurking, with only its jaws showing.",
        "Which flat cousin of the shark 'flies' along by flapping wide fins?":
            "It flaps like a bird and carries a barb on its tail.",
        "What thin, overlapping covering protects the body of most fish?":
            "Little overlapping plates, like shingles on a roof.",
        "A coral reef is built by which tiny living creatures?":
            "They look like plants but they are not, and they build homes of stone.",
        "Which enormous reef is so big it can be seen from space?":
            "The biggest one lies off the coast of Australia.",
        "Where do corals get much of their bright colour and food?":
            "Something green and microscopic lodges within, making food from sunlight.",
        "Which reef fish scrapes at coral and turns it into soft white sand?":
            "It has a beak like a bird's, and it crunches stone all day.",
        "How does a sea anemone catch the small fish it eats?":
            "Think about how a jellyfish catches its dinner.",
        "Which brightly coloured sea creature is a kind of soft sea slug?":
            "A garden pest lives on land; this cousin is in the sea and far prettier.",
        "For the animals that live there, a coral reef mainly provides...":
            "A reef is crowded because it offers two things every animal needs.",
        "Which small fish cleans bigger fish by nibbling pests off their skin?":
            "Bigger fish queue up for it, and it never gets eaten.",
        "When the sea gets too warm and coral turns ghostly white, this is called...":
            "When the colourful helpers inside leave, all that is left is white.",
        "Which reef giant can grow over a metre wide and live more than 100 years?":
            "It is a shellfish, but far too big to hold in two hands.",
        "The pitch-black deep sea where no sunlight reaches is called the...":
            "The very deepest, blackest part, where the sun has never reached.",
        "Which deep-sea fish dangles a glowing lure to attract its dinner?":
            "It fishes with a rod of its own, right above its mouth.",
        "What is it called when a living thing makes its own light?":
            "'Bio' means life, and 'luminous' means giving off light.",
        "What is the name of the deepest place in all the oceans?":
            "A deep valley in the Pacific, named after nearby islands.",
        "Which deep-sea giant has the largest eyes of any animal, like dinner plates?":
            "So huge it was a legend for centuries before anyone photographed one.",
        "Why is the deep ocean so cold and dark?":
            "Think how far light can push down through water before it gives up.",
        "The dim layer just below the sunny surface waters is called the...":
            "Not quite day and not quite night — the dim layer in between.",
        "What must deep-sea creatures survive as they live far below the surface?":
            "Imagine eleven kilometres of sea piled on top of you.",
        "Which hot cracks on the sea floor let strange creatures thrive without sunlight?":
            "Hot water pours out of the sea floor and a whole town grows round it.",
        "What do many deep-sea animals eat as it drifts down from above?":
            "It drifts down softly from far above, and it is not really weather.",
        "Which is the fastest fish in the whole ocean?":
            "Its huge back fin looks like something on a boat.",
        "Which sea creature has three hearts and blue blood?":
            "Eight arms, and it squirts ink when it is frightened.",
        "Which animal shoots out a dark ink cloud to escape danger?":
            "It has ten arms, and a long torpedo-shaped body.",
        "Which animal can grow a whole new arm if it loses one?":
            "It has five points and no face.",
        "Which fish can 'walk' on muddy shores and breathe out of water?":
            "A fish with a taste for dry land, hopping about in the mud.",
        "Which clever creature can change its colour and skin texture in a second?":
            "A cousin of the octopus with a flat shell inside it.",
        "Which small sea animal throws the fastest punch in the ocean?":
            "Very small, and it strikes so fast the water itself boils.",
        "Which flat fish can give a strong electric shock to stun its prey?":
            "Flat, wide and shocking to touch.",
        "Which fish can leap from the sea and glide above the waves?":
            "It bursts out of the waves and soars on stiff, wide fins.",
        "Which animal uses Earth's magnetic field like a compass to find its way home?":
            "It has a shell and it comes back to the same beach it hatched on.",
        "How many oceans does the Earth have?":
            "One more than the number of fingers on one hand.",
        "Which is the largest and deepest ocean on Earth?":
            "It is the one between America and Asia, and its name means peaceful.",
        "What causes the ocean's tides to rise and fall each day?":
            "Something enormous overhead is quietly tugging at the water.",
        "Which is the smallest and coldest ocean, capped with ice at the North Pole?":
            "The one at the very top of the globe.",
        "What is the name of a giant wave set off by an undersea earthquake?":
            "A Japanese word meaning 'harbour wave'.",
        "What do we call the giant rivers of water that flow within the sea?":
            "The water itself travels, like a road moving under you.",
        "About how much of the Earth's surface is covered by ocean?":
            "Rather more than two thirds.",
        "What are the huge floating chunks of ice that break off glaciers called?":
            "The part you see is only a tenth of it.",
        "Which warm Atlantic current helps keep western Europe mild?":
            "Named after a body of water beside Mexico, and it carries warmth north.",
        "Where does most of the oxygen we breathe actually come from?":
            "Not the forests, as most people guess. Look at what covers most of Earth.",
        "A blue whale's heart is roughly the size of a...":
            "Big enough that a person could crawl through its blood vessels.",
        "Which small Arctic whale is nicknamed the 'unicorn of the sea'?":
            "It has a single long spiral spike growing out of its head.",
        "The narwhal's long spiral tusk is really a giant...":
            "You have thirty-two of these, though none quite so long.",
        "Which is the largest hunting fish, with rows of jagged teeth?":
            "It is famous from a frightening film, and its name has a colour in it.",
        "Which gentle, slow sea mammal is nicknamed the 'sea cow'?":
            "Slow, round and gentle, it grazes on sea grass like cattle.",
        "Which sea creature looks like one jellyfish but is really a colony of many?":
            "It looks like one creature, but it is really a whole crowd working together.",
        "Which simple sea animal has no brain, heart or muscles and pumps water to feed?":
            "You might have one in your bathroom, though not a living one.",
        "A pufferfish protects itself with a body full of...":
            "Puffing up is only half its defence. The other half is chemical.",
        "Which shore creature is a 'living fossil' older than the dinosaurs, with blue blood?":
            "Its shell is shaped like the thing a blacksmith nails onto a hoof.",
        "Which is the largest sea turtle, with a rubbery shell instead of a hard one?":
            "The biggest of them all, and its back is rubbery rather than hard.",
        "What is the name of the deepest known point in any ocean, almost 11 km down?":
            "Named after a famous British survey ship.",
        "Which heavy deep-sea hunter near Antarctica has the largest eyes of any animal?":
            "Even heavier than the giant one, and it lives in the freezing south.",
        "About how deep is the ocean floor on average?":
            "Deeper than the tallest mountain on land is high.",
        "Which tiny drifting plants make a huge share of the world's oxygen?":
            "'Phyto' means plant, and they drift where the light still reaches.",
        "Which shark is the longest-living animal with a backbone, over 400 years old?":
            "It swims slowly in the cold north and can outlive twenty generations of people.",
        "Which mammal dives the deepest, plunging nearly 3 km down to hunt squid?":
            "It has a pointed snout, and it is named after the man who first described it.",
        "Which tiny jellyfish can grow young again and is nicknamed 'immortal'?":
            "It can turn back into a baby, which is why it is nicknamed as it is.",
        "What do scientists call the vast, flat, freezing plain that covers much of the sea floor?":
            "A word we also use for any bottomless pit.",
        "Warm and cold seawater flow around the world in a slow loop nicknamed the...":
            "Warm and cold seawater travelling the world on one very slow loop.",
        "Because every sea joins together, scientists say Earth really has just one...":
            "There are five names, but really no walls between any of them.",
        // MARK: Explorer's Trail

        "How many continents are there on Earth?":
            "One more than the days in a week? No — exactly the same.",
        "Which is the largest ocean in the world?":
            "Its name means peaceful, and it lies between America and Asia.",
        "Which tool has a needle that points north to help you find your way?":
            "Its needle always swings to the same end of the Earth.",
        "What do we call a drawing that shows countries, land and seas?":
            "You unfold it, and it shows you where everything is.",
        "The Eiffel Tower stands in which city?":
            "The city of croissants and the River Seine.",
        "The Great Pyramids are found in which country?":
            "The land of the Nile and the Sphinx.",
        "Which frozen continent sits at the very bottom of the Earth?":
            "Penguins live there, and almost nobody else.",
        "Kangaroos are a famous symbol of which country?":
            "The land of the outback and the boomerang.",
        "Which country is famous for pizza and pasta?":
            "The country shaped like a boot.",
        "What do we call the huge blocks of land like Africa and Asia?":
            "Africa, Asia and Europe are three of them.",
        "Which country is famously shaped like a boot?":
            "Home of pizza, and it looks ready to kick Sicily.",
        "The Statue of Liberty is a proud symbol of which country?":
            "Fifty stars on its flag.",
        "Giant pandas are a beloved symbol of which country?":
            "The land of the Great Wall and bamboo forests.",
        "Which country is famous for the beautiful Taj Mahal?":
            "A white marble tomb built for a beloved wife.",
        "Which country has a red maple leaf on its flag and makes maple syrup?":
            "Its flag carries a single red leaf.",
        "Koalas, the outback and the Great Barrier Reef are all found in?":
            "The land down under, where the reef is.",
        "Flamenco dancing, paella and lively festivals come from which country?":
            "The country of bullfights and the guitar, next to Portugal.",
        "What do we call brave people who travel to discover new places?":
            "People who go first, where nobody has mapped.",
        "Which country holds most of the vast Amazon rainforest?":
            "The biggest country in South America, where they speak Portuguese.",
        "Big Ben, red double-decker buses and black taxis are famous sights of?":
            "The land of the Queen, fish and chips and the London Eye.",
        "What is the capital city of France?":
            "The city with the iron tower.",
        "What is the capital city of Japan?":
            "The biggest city in the land of the rising sun.",
        "A flag with a single red circle on a white background belongs to?":
            "The rising sun on a plain white field.",
        "What is the capital of the United States?":
            "A city that is not in any state, named after the first president.",
        "A flag with a bold white cross on red, from a land of Alps and chocolate, is?":
            "Famous for watches, banks and mountain cheese.",
        "What is the capital city of England?":
            "The city with Big Ben beside the river.",
        "A flag with saffron, white and green stripes and a blue wheel belongs to?":
            "A spinning wheel sits in the middle of it.",
        "What is the capital city of Italy?":
            "The city built on seven hills, with a colosseum.",
        "A flag with 50 stars and 13 stripes belongs to which country?":
            "One stripe for each of the first colonies.",
        "What is the capital city of Egypt?":
            "The city beside the pyramids.",
        "The Great Wall is a huge ancient structure in which country?":
            "You could walk along it for thousands of kilometres.",
        "The ancient Colosseum arena stands in which city?":
            "The old city where gladiators once fought.",
        "In which city's harbour does the Statue of Liberty stand?":
            "An island city with yellow taxis and very tall buildings.",
        "Machu Picchu, an ancient city high in the mountains, is in which country?":
            "An ancient stone city high in the Andes, in South America.",
        "Petra, a whole city carved into rose-red rock, is found in?":
            "A city cut straight into a cliff, in the Middle East.",
        "The famous Leaning Tower is found in which country?":
            "It leans in the country shaped like a boot.",
        "The giant statue of Christ the Redeemer overlooks which city?":
            "Its beaches and carnival are famous, and it is in Brazil.",
        "The Opera House shaped like billowing white sails is in which country?":
            "The building looks like sails in the harbour of Sydney.",
        "The huge ancient temple of Angkor Wat is found in which country?":
            "A vast stone temple in South-East Asia, next to Thailand.",
        "The Pyramids of Giza were built by which ancient people?":
            "The people of the pharaohs.",
        "What is the tallest mountain on Earth?":
            "It sits on the border of Nepal and Tibet.",
        "What is the largest hot desert in the world?":
            "It stretches right across the top of Africa.",
        "Which enormous rainforest is found mostly in Brazil?":
            "The great river and forest share the same name.",
        "Which long river flows north through Egypt?":
            "The long one that Egypt is built along.",
        "Which mountain range holds the highest peaks, including Everest?":
            "The range in Asia whose name means 'home of snow'.",
        "What do we call a slow-moving river of ice on a mountain?":
            "Ice so thick and heavy that it creeps slowly downhill.",
        "Which is the highest mountain in Africa, snow-capped even near the Equator?":
            "A lone snow-capped peak in Tanzania.",
        "What do we call a mountain that can erupt with hot lava?":
            "A mountain that can blow its top.",
        "The Grand Canyon, a giant gorge carved by a river, is in which country?":
            "A vast gorge in Arizona, cut by the Colorado.",
        "What do we call a place that gets very little rain, with few plants?":
            "Dry, sandy and almost nothing grows.",
        "Which explorer sailed across the Atlantic in 1492 and reached the Americas?":
            "He sailed with the Nina, the Pinta and the Santa Maria.",
        "Whose expedition first sailed all the way around the world?":
            "A strait at the tip of South America is named after him.",
        "Which Italian traveller journeyed along the Silk Road to China long ago?":
            "A swimming-pool game is named after this Venetian traveller.",
        "Who was the first person to reach the South Pole?":
            "A Norwegian who beat Scott to the bottom of the world.",
        "Who first reached the summit of Everest, with Tenzing Norgay?":
            "A New Zealander who got to the top first, in 1953.",
        "Which explorer first sailed around Africa to reach India by sea?":
            "A Portuguese sailor who found the sea route to India.",
        "Which captain famously mapped the coasts of New Zealand and eastern Australia?":
            "An English captain, and a strait between Alaska and Russia bears his name.",
        "Tenzing Norgay, who climbed Everest, was a Sherpa from which country?":
            "The mountain kingdom where Everest stands.",
        "Who led an expedition across America with Clark, guided by Sacagawea?":
            "His name comes first in a famous pair, ahead of Clark.",
        "What do we call a long, planned journey to explore or discover something?":
            "A journey with a purpose, and usually a long list of supplies.",
        "What is the imaginary line around the middle of the Earth called?":
            "The line exactly halfway between the two poles.",
        "The top half of the Earth, above the Equator, is called the?":
            "The half you live in if you live in Europe or North America.",
        "What do we call the point at the very top of the Earth?":
            "Where all the lines of longitude finally meet, up at the top.",
        "On most maps, which direction is at the top?":
            "The direction a compass needle points.",
        "The lines that run east-west, measuring how far north or south you are, are lines of?":
            "They run the same way as the Equator, like rungs on a ladder.",
        "What do we call the star-shaped symbol on a map that shows directions?":
            "A star-shaped drawing showing which way is which.",
        "What do we call a whole book of maps?":
            "Every map you own, bound together in one cover.",
        "What do we call one half of the Earth, like the Eastern or Western part?":
            "'Hemi' means half, and 'sphere' means ball.",
        "The imaginary lines running from the North Pole to the South Pole are lines of?":
            "They run from pole to pole, like the segments of an orange.",
        "What do we call the box on a map that explains its symbols and colours?":
            "A story has one of these too, and it explains the symbols.",
        "What is the capital of Australia?":
            "Not Sydney and not Melbourne, but the city built between them.",
        "What is the capital of Canada?":
            "Not Toronto, and it sits on a river of the same name.",
        "What is the capital of Brazil?":
            "A brand-new city built in the middle of the country in the 1950s.",
        "What is the capital of Russia?":
            "The city of the Kremlin and Red Square.",
        "What is the capital of Germany?":
            "A wall once divided this city in two.",
        "What is the capital of China?":
            "The city of the Forbidden City.",
        "Mount Fuji, an almost perfectly cone-shaped volcano, is in which country?":
            "A perfect cone that appears on countless paintings and postcards.",
        "Which country is made of over 17,000 islands and includes Bali?":
            "A country of thousands of islands, north of Australia.",
        "What is the capital of Spain?":
            "The capital of the country famous for flamenco.",
        "Which tiny country is home to the Pope and sits inside the city of Rome?":
            "Smaller than many parks, yet it is a country of its own.",
        "Which is the largest country in the world by area?":
            "It stretches from Europe all the way to the Pacific.",
        "Which is the smallest country in the world?":
            "It is smaller than a large farm, and the Pope lives there.",
        "What is the driest desert on Earth, where rain almost never falls?":
            "A bone-dry strip of Chile where some places have never recorded rain.",
        "Which is usually counted as the longest river in the world?":
            "The one Egypt is built along.",
        "What is the highest waterfall in the world?":
            "It drops nearly a kilometre, in Venezuela.",
        "What is the largest lake in the world, so big it is called a sea?":
            "It has 'sea' in its name, but it is surrounded by land.",
        "What is the deepest ocean trench on Earth?":
            "The deepest gash in the sea floor, in the Pacific.",
        "Which is the largest island in the world?":
            "It is covered in ice, yet its name promises the opposite.",
        "What is the largest structure ever built by living creatures?":
            "Built by tiny creatures off the coast of Australia.",
        "Which is the largest continent, home to more people than all the others together?":
            "The one with China and India in it.",
        "About how tall is Mount Everest?":
            "Nearly nine thousand metres up.",
        "The Ural Mountains form the dividing line between which two continents?":
            "A range in Russia divides one continent from the next.",
        "Which huge country stretches across eleven different time zones?":
            "When it is breakfast at one end, it is evening at the other.",
        "What is the imaginary line at 0° longitude, running through Greenwich, called?":
            "The starting line for longitude, drawn through a London suburb.",
        "Which salty lake is so buoyant that swimmers float on it like corks?":
            "It is so salty that nothing can live in it, and you cannot sink.",
        "Which is actually the largest desert on Earth, even though it is freezing cold?":
            "It is dry and almost rainless, which is what counts — not the heat.",
        "Roughly how many countries are there in the world today?":
            "A little under two hundred.",
        "Measured from its base on the ocean floor, which is actually the tallest mountain?":
            "A Hawaiian volcano, most of it hidden under the sea.",
        "Which line of latitude marks the northern edge of the tropics?":
            "It shares its name with a crab and a star sign.",
        "What do we call a person who studies the world and draws maps?":
            "'Carto' means map, and 'grapher' means one who draws.",
        // MARK: Blossom Garden

        "What two things from the sky do plants need to grow?":
            "One arrives on a bright day, the other on a grey one.",
        "Which insect changes from a caterpillar into a beautiful flyer?":
            "It starts life crawling and ends it with wings.",
        "What do we call the colourful, sweet-smelling part of a plant?":
            "The pretty bit you would pick and put in a vase.",
        "What do we call the tiny thing a plant grows from?":
            "You bury it, water it, and wait.",
        "Bees visit flowers to collect a sweet liquid called...":
            "The sweet drink at the bottom of a bloom.",
        "What colour are most leaves?":
            "The same shade as grass.",
        "Which part of a plant holds it in the soil and drinks water?":
            "The hidden part, down in the dark.",
        "In which season do many flowers first bloom?":
            "After the winter and before the summer.",
        "Which garden visitor has wings, feathers and can fly?":
            "It sings in the morning and builds in the branches.",
        "What do we call the tall middle part of a plant that holds it up?":
            "The upright part in the middle, between the roots and the bloom.",
        "What does a hungry caterpillar love to eat?":
            "It munches holes in the greenery all day long.",
        "Which small round beetle is red with black spots?":
            "Small, domed and spotty — thought to bring good luck.",
        "What good thing do earthworms do for a garden?":
            "Think what happens to earth when something burrows all through it.",
        "What do we call the cosy home a bird builds for its eggs?":
            "A cup of twigs and moss, tucked into a tree.",
        "Which busy insect makes honey?":
            "It buzzes, and it wears black and yellow stripes.",
        "What do snails carry around on their backs?":
            "A spiral house they never move out of.",
        "Which creature spins a silky web to catch its food?":
            "Eight legs, and it builds a sticky trap.",
        "What hatches out of a bird's egg?":
            "A fluffy baby with a tiny beak.",
        "Which insect glows with its own light on summer nights?":
            "A beetle that blinks in the dark like a tiny lantern.",
        "What do we call a young frog with a tail that lives in water?":
            "It swims now, but one day it will hop.",
        "What is it called when plants make their own food using sunlight?":
            "'Photo' means light, and 'synthesis' means putting together.",
        "What do we call it when pollen moves between flowers to make seeds?":
            "The delivery job that bees do without meaning to.",
        "What do we call a baby plant just sprouting from a seed?":
            "Just out of the ground, with its first pair of leaves.",
        "What gas do plants give out that people and animals need to breathe?":
            "The gas you are breathing in right now.",
        "Trees that drop all of their leaves in autumn are called...":
            "They go bare in the winter and green again in the spring.",
        "What do we call plants that farmers grow on purpose for food?":
            "Wheat, rice and corn are all examples.",
        "What do we call the fine yellow powder found inside flowers?":
            "It gets on your nose when you sniff a bloom, and it makes you sneeze.",
        "How do the fluffy seeds of a dandelion usually travel to new places?":
            "You blow on the fluffy ball and make a wish.",
        "What do we call trees like pines that stay green all year round?":
            "They still have needles on at Christmas.",
        "After a flower is pollinated, which part of it can grow into a fruit?":
            "The swollen part left behind once the petals fall.",
        "Which tall flower turns its head to follow the sun across the sky?":
            "It is tall, golden and named after what it follows.",
        "Which sweet-smelling flower is famous for the sharp thorns on its stem?":
            "Red, romantic, and you must hold the stem carefully.",
        "A mighty oak tree grows from which small nut?":
            "A squirrel would bury one of these.",
        "Which plant stores water in a thick stem and is covered in sharp spines?":
            "Prickly, and it can go months without a drink.",
        "Which flower grows from a bulb and is a famous symbol of the Netherlands?":
            "A cup-shaped bloom, and Amsterdam is full of them.",
        "What do we call the tight little swellings that open into leaves or flowers?":
            "The tight little parcels that have not opened yet.",
        "Which fruit grows on a tree and, people say, keeps the doctor away?":
            "Red or green, and it might be in your lunchbox.",
        "What do we call the tough outer skin that protects a tree's trunk?":
            "The rough coat on the outside of a trunk.",
        "Which plant floats on ponds with big flat leaves and pretty flowers?":
            "Monet painted these in his pond over and over.",
        "What do we call a garden plant that comes back on its own every year?":
            "It does not need replanting — it returns by itself each spring.",
        "What do we call the busy home where thousands of bees live together?":
            "Thousands of workers, all in one wooden box.",
        "Which special bee lays all of the eggs in the whole hive?":
            "There is only one of her, and everyone else works for her.",
        "How do honeybees tell each other where good flowers are?":
            "They cannot speak, so they move their bodies in a figure of eight.",
        "Which orange-and-black butterfly travels thousands of miles each year?":
            "Orange and black, and it flies from Canada to Mexico.",
        "What do butterflies use to sip nectar from deep inside flowers?":
            "Think how you get the last of a milkshake from the bottom of the glass.",
        "Besides bees, which tiny hovering bird also pollinates flowers as it feeds?":
            "It hovers, it is tiny, and its wings beat too fast to see.",
        "What do we call any animal that carries pollen from flower to flower?":
            "The name for anyone doing the delivery job — bee, bird or bat.",
        "What do bees carry back to the hive in tiny baskets on their legs?":
            "The yellow dust they gather on their back legs.",
        "Which resting stage comes between a caterpillar and a butterfly?":
            "The hard case it sleeps in while it changes.",
        "Why are bees so important for the food that we eat?":
            "Without their delivery round, a great many of our crops would give us nothing.",
        "What do we call it when birds fly to warmer places for the winter?":
            "The long journey birds make when the days get short.",
        "Which tiny bird can hover in one spot and even fly backwards?":
            "It hovers in one spot like a tiny helicopter.",
        "Which bird can turn its head almost all the way around and hunts at night?":
            "It hoots, and it hunts in the dark.",
        "Which bird drums its beak against tree trunks to find insects?":
            "You hear it hammering long before you spot it.",
        "What are birds' bodies covered in to help them fly and stay warm?":
            "The light covering that only birds have.",
        "Which bird is the fastest animal on Earth, diving to catch its prey?":
            "It drops out of the sky faster than a racing car.",
        "Which bird is the largest of all, cannot fly, but can sprint very fast?":
            "Long legs, long neck, and it runs instead of flying.",
        "Which colourful bird can copy human words and other sounds?":
            "A pirate's shoulder companion.",
        "Which clever black bird can use tools to reach its food?":
            "A very clever black bird, and a group of them has a grim name.",
        "What special feature helps make birds light enough to fly?":
            "Their skeletons are not solid — think what that saves.",
        "How can you tell the age of a tree that has been cut down?":
            "Look at the circles inside the cut trunk.",
        "What green substance in leaves catches sunlight to make food?":
            "It is what makes a leaf the colour it is.",
        "Why do many leaves turn red, orange and yellow in autumn?":
            "Something drains out of the leaf, and what was hiding underneath shows through.",
        "What do we call the leafy top layer of a forest where the branches spread out?":
            "The leafy roof of a forest, high above your head.",
        "What do we call a young tree, taller than a seedling but still slim?":
            "Older than a seedling, younger than a tree.",
        "What do the roots of trees quietly do underground to help each other?":
            "Underground, they are all joined up, passing things along.",
        "What do trees take in from the air to help make their food?":
            "The gas we breathe out, and they breathe in.",
        "What carries water all the way up from the roots to the highest leaves?":
            "Think how a straw carries a drink upwards.",
        "What do we call a very old forest that has grown undisturbed for centuries?":
            "Nobody has cut it down for hundreds of years.",
        "What do we call all the branches and leaves at the top of a tree together?":
            "The same word as the thing a king wears, and it sits at the very top.",
        "What do we call the amazing change from caterpillar to butterfly?":
            "A long Greek word meaning 'a change of shape'.",
        "How many legs does an insect have?":
            "Two more than a spider has.",
        "Which tiny insects live in huge colonies and can lift many times their own weight?":
            "They march in a line and can lift far more than they weigh.",
        "Which fast-flying insect has four wings, huge eyes, and darts around ponds?":
            "Four wings, enormous eyes, and it darts above the water.",
        "What do we call the hard outer shell that protects an insect's body?":
            "'Exo' means outside — its skeleton is worn on the outside.",
        "Which insect chirps by rubbing its wings or legs together?":
            "You hear it on warm evenings, though you rarely see it.",
        "How does a snail slide along the ground?":
            "It leaves a shiny silver streak behind it.",
        "What do we call the feelers on an insect's head used to smell and touch?":
            "The two feelers waving about on top of its head.",
        "Which insect is so light it can walk on the surface of a pond?":
            "It is so light it never breaks the surface, and it skates about.",
        "What do we call a group of insects like ants or bees living and working together?":
            "A whole town of insects, all related and all working.",
        "Which plant traps and eats insects by snapping its leaves shut?":
            "Its leaves snap shut like a pair of jaws.",
        "Which is the largest single flower in the world, smelling of rotting meat?":
            "It smells horrible on purpose, to attract flies.",
        "Which is the tallest kind of tree on Earth, growing over 100 metres high?":
            "Taller than a thirty-storey building, and it grows in California.",
        "Some bristlecone pine trees are among the oldest living things, at almost how old?":
            "Older than the pyramids.",
        "Which giant desert cactus can live 150 years and grow tall arms?":
            "A tall prickly giant from the American west, with arms held up.",
        "What is the world's smallest flowering plant, a tiny green dot floating on ponds?":
            "So small that a whole plant sits on your fingertip.",
        "Which tree, the giant sequoia, is the largest living thing by size?":
            "Not the tallest, but by far the biggest and heaviest.",
        "Which flower opens mainly at night and is pollinated by moths and bats?":
            "It waits for the dark, when its visitors come out.",
        "Which fast-growing plant can shoot up almost a metre in a single day?":
            "You could almost watch it grow, and pandas eat it.",
        "Which strange tree oozes a bright red sap and is named after a mythical beast?":
            "Its sap runs red, and it is named after a fire-breathing beast.",
        "What do we call the male part of a flower that makes pollen?":
            "It is the part that makes the yellow dust.",
        "What do we call the female part of a flower that receives pollen?":
            "It is the part that catches the yellow dust.",
        "After pollination, which swelling part of a flower ripens into a fruit?":
            "'Ovum' is an old word for egg.",
        "Some flowers are pollinated not by insects at all, but by...?":
            "No insect visits at all — something else carries it.",
        "What do we call the tiny holes on leaves that let gases move in and out?":
            "Tiny mouths on the underside of a leaf.",
        "What do we call plants like pines that grow their seeds in cones, not flowers?":
            "They keep their seeds in a woody case you might find on the forest floor.",
        "What sugary food do plants make for themselves during photosynthesis?":
            "The same sweet stuff you might stir into a cup of tea.",
        "What do we call the deep, sleep-like resting state a seed can wait in for years?":
            "A long sleep, waiting for the right moment to begin.",
        "Which process do plants use to release water vapour from their leaves?":
            "Plants sweat too, in their own quiet way.",
        "What do we call a scientist who studies plants?":
            "'Botany' is the study of plants.",
        // MARK: Science Lab

        "What do we call water that has frozen solid and gone cold?":
            "You would find it in the freezer, or clinking in a glass.",
        "Which invisible force pulls a dropped ball down to the ground?":
            "The reason nothing you drop ever stays up.",
        "What do we call a machine, sometimes shaped like a person, built to do jobs for us?":
            "It works for us, it is built not born, and it never gets tired.",
        "Which colour do you make by mixing blue and yellow paint?":
            "The shade of grass and of leaves.",
        "What do we call a person whose job is doing experiments to learn about the world?":
            "Someone in a white coat asking 'what happens if?'",
        "Which of these will float on water?":
            "Think what a duck sits on, and what a stone does instead.",
        "Which organ pumps blood all around your body?":
            "You can feel it thumping if you put a hand on your chest.",
        "What do magnets pull towards themselves?":
            "Try one on a fridge door, then on a plastic bowl.",
        "What do we breathe in from the air to stay alive?":
            "About a fifth of the air is this, and without it you have minutes.",
        "Which part of your body do you use to smell things?":
            "The bit in the middle of your face.",
        "How many main senses do people have?":
            "One for each finger on a hand.",
        "What do we call the hard frame of bones inside your body?":
            "You can feel bits of it through your skin at your elbow and knee.",
        "Which organ do you use to think, remember and dream?":
            "It sits inside your skull and never stops working.",
        "Which material is hard and shiny and used to make spoons and cars?":
            "Tap it and it rings. Gold and iron are both examples.",
        "Which light, bendy material is used to make many toys and bottles?":
            "Nearly every toy has some, and it is made from oil.",
        "What do we call a material you can see straight through, like clear glass?":
            "Like a window — the light goes straight through.",
        "What happens to an ice cube left in a warm room?":
            "It turns from a solid back into what it was before it was frozen.",
        "Which part of your body do you use to taste food?":
            "The pink thing behind your teeth.",
        "Which material comes from trees and is used to build furniture?":
            "It was alive once, and it still has rings inside it.",
        "What do we call water when it floats in the air as an invisible gas?":
            "It is still the same stuff as in your glass, but you cannot see it at all.",
        "The three states of matter are solid, liquid and...?":
            "Air is one of these, and so is steam.",
        "When a solid is heated until it turns into a liquid, this is called...?":
            "Butter in a warm pan does this.",
        "When a liquid cools down and turns into a solid, this is called...?":
            "It is what a puddle does on a very cold night.",
        "When water slowly dries up and turns into invisible vapour, this is...?":
            "A wet pavement goes dry on a sunny day. Where did the water go?",
        "When water vapour cools and turns back into tiny droplets, this is...?":
            "The reason a cold glass goes wet on the outside.",
        "Which state of matter keeps its own shape, like a rock or a brick?":
            "Drop it and it keeps its shape.",
        "Which state of matter can be poured and takes the shape of its container?":
            "Pour it into a jug and it becomes jug-shaped.",
        "What do we use a thermometer to measure?":
            "You use one when you feel poorly.",
        "At what temperature does water freeze into ice, in Celsius?":
            "The number right in the middle, between plus and minus.",
        "At what temperature does water boil, in Celsius?":
            "The number you get when a kettle is doing its loudest.",
        "What do we call the force that slows things down when they rub together?":
            "It is why you can strike a match, and why brakes work.",
        "A push or a pull is an example of a...?":
            "Pushing and pulling are both examples of the same thing.",
        "What do we call how fast something is moving?":
            "A car has a dial on the dashboard showing it.",
        "Which simple round shape helps carts and cars roll along easily?":
            "Round, and it was one of the very first inventions.",
        "Why does a parachute make someone fall slowly through the air?":
            "Look at how big and wide it is, and think what it catches.",
        "What do we call a force that acts without touching, like a magnet's invisible pull?":
            "The invisible pull a fridge door has on a paperclip.",
        "Which ramp-like simple machine helps us move heavy things up more easily?":
            "A slope, a ramp, a hill — the same idea with a scientific name.",
        "What happens when you rub your hands together quickly?":
            "Try it now for ten seconds and feel what happens.",
        "What happens when you push the same poles of two magnets together?":
            "Try it and your hands will be forced apart.",
        "A see-saw in the playground is an example of which simple machine?":
            "A bar balanced on a point, with a load at one end.",
        "Which organs do you use to breathe air in and out?":
            "A pair of them, and they fill and empty as your chest rises.",
        "About how many bones are there in a grown-up's body?":
            "A little over two hundred.",
        "What do we call the red liquid that carries oxygen around your body?":
            "It is red, and it runs through every part of you.",
        "What do we call the bendy places where two bones meet, like your knee?":
            "The places that bend — elbows, knees, knuckles.",
        "What do your muscles pull on to make your body move?":
            "Muscles cannot push. They can only pull on something hard.",
        "What do we call the pipe that carries food from your mouth down to your stomach?":
            "A tube that takes a swallowed mouthful downwards.",
        "Which body parts let you see the world around you?":
            "You have two, and they are shut right now if you are asleep.",
        "What do we call the hard white parts in your mouth used for chewing?":
            "You lose your first set and grow a second.",
        "Which is the largest organ of your body, covering you all over?":
            "You are wearing it all over, and it is the biggest one you have.",
        "Which organ turns the food you eat into energy your body can use?":
            "A bag below your chest where a meal is broken up.",
        "What do we call it when light bounces off a mirror?":
            "Look in a mirror. What is light doing to come back to you?",
        "Light normally travels in what kind of path?":
            "That is why you cannot see round a corner.",
        "What do we call the band of seven colours that light can split into?":
            "A rainbow is one, spread out for you to see.",
        "Sound is made when something does what very quickly?":
            "Touch a speaker while music plays and feel what it is doing.",
        "What do we call a sound that bounces back to you, like in a cave?":
            "Shout in a tunnel and wait a moment.",
        "Which travels faster, light or sound?":
            "You see the flash before you hear the thunder. Which one arrived first?",
        "What do we call how high or low a sound is?":
            "A squeak is high and a rumble is low. What is that called?",
        "What do we call the dark shape made when something blocks the light?":
            "Stand in the sun and look at the ground beside your feet.",
        "Which curved piece of glass bends light to make small or far things look bigger?":
            "A magnifying glass has one, and so do your own eyes.",
        "What do we call all the colours of light mixed together?":
            "Put every colour of the rainbow together and this is what you get.",
        "What do we call the loop that electricity flows around to light a bulb?":
            "It has to go all the way round, like a running track.",
        "Materials that let electricity flow through them are called...?":
            "Copper wire does it; a wooden stick does not.",
        "Materials that stop electricity, like rubber and plastic, are called...?":
            "They are wrapped around wires to keep the electricity safely inside.",
        "What stores electricity to power a torch or a toy?":
            "You buy them in packs and they eventually run out.",
        "What do we call the crackly electricity that can make your hair stand up?":
            "Rub a balloon on your jumper and stick it to the wall.",
        "Every magnet has two ends called...?":
            "One at each end, and they have the names of the ends of the Earth.",
        "What happens when the north poles of two magnets are pushed together?":
            "Try it and they will refuse to meet.",
        "Which metal is most strongly attracted to a magnet?":
            "Nails and paperclips are usually made of it.",
        "A compass needle points north because the whole Earth acts like a giant...?":
            "The whole planet quietly behaves like the thing on your fridge door.",
        "For electricity to flow all the way round, a circuit must be...?":
            "If there is a gap anywhere, nothing happens at all.",
        "What do we call the tiny building blocks that everything is made of?":
            "So small that millions would fit on this full stop.",
        "When two or more atoms join together, they form a...?":
            "Two of them joined together make the next thing up.",
        "What do we call a pure substance made of only one kind of atom, like gold?":
            "Gold and oxygen are both examples, and they cannot be broken down.",
        "When you stir sugar into water until it disappears, you make a...?":
            "The sugar has not gone. It is still in there, just spread about.",
        "What do we call a mix of things that can be separated again, like cereal in a bowl?":
            "Nothing has actually joined together — you could pick it apart again.",
        "Which gas makes fizzy drinks bubbly and is the gas we breathe out?":
            "The gas you breathe out, and the one that makes lemonade fizz.",
        "What do we call a sour substance like lemon juice or vinegar?":
            "Lemon juice and vinegar are both examples, and they taste sharp.",
        "Which gas is lighter than air and makes party balloons float?":
            "Breathe it in and your voice goes squeaky.",
        "What do we call the famous table that lists all the known elements?":
            "A chart on every laboratory wall, arranged in rows and columns.",
        "Which gas makes up most of the air all around us?":
            "Nearly four fifths of every breath, and it does nothing much at all.",
        "Which scientist explained gravity after supposedly seeing an apple fall?":
            "He also worked out the laws of motion, and there is an apple in the story.",
        "Who invented a practical light bulb and held over 1,000 patents?":
            "He is said to have tried a thousand materials before one glowed.",
        "Which famous scientist came up with E=mc² and the theory of relativity?":
            "He had wild white hair and thought about riding on a beam of light.",
        "Which scientist won two Nobel Prizes for her work on radioactivity?":
            "A Polish-French scientist, and an element is named after her.",
        "Who is credited with inventing the telephone?":
            "His surname is the sound one makes when someone is at the door.",
        "Which two brothers built and flew the first powered aeroplane?":
            "Two of them ran a bicycle shop, and flew at Kitty Hawk in 1903.",
        "Which scientist explained how living things change over time through evolution?":
            "He sailed on the Beagle and studied finches.",
        "Who showed that lightning is electricity by flying a kite in a storm?":
            "He is also on the American hundred-dollar note.",
        "Who created the first vaccine, which protected people against smallpox?":
            "He noticed that milkmaids who caught cowpox never fell ill.",
        "What do we call a person who designs and builds machines, bridges and structures?":
            "Someone who builds bridges and machines rather than studying them.",
        "What do we call the tiny living units that make up every plant and animal?":
            "So small you need a microscope, and every living thing is built from them.",
        "Which molecule inside cells carries the instructions for life, shaped like a twisted ladder?":
            "It is shaped like a twisted ladder, and it is spelled with three letters.",
        "What are the three kinds of particle that make up an atom?":
            "Two kinds sit in the middle and one kind whizzes around the outside.",
        "Roughly how fast does light travel?":
            "Fast enough to circle the Earth seven times before you finish blinking.",
        "Energy cannot be created or destroyed, only...?":
            "A battery goes flat, but the energy has not vanished. Where did it go?",
        "What do we call stored-up energy, like in a stretched spring or a raised weight?":
            "A stretched catapult has it, though nothing is moving yet.",
        "What do we call the energy that a moving object has?":
            "A rolling ball has it; a still ball does not.",
        "What do we call the centre of an atom, where protons and neutrons sit?":
            "The very middle, the same word as the centre of a cell.",
        "What do we call the amount of matter in an object, measured in kilograms?":
            "Your bathroom scales are measuring it.",
        "What do we call a scientist who studies forces, energy and how the universe works?":
            "The science of forces and energy is named after this job.",
        // MARK: Brain Castle

        "How many sides does a square have?":
            "Count the corners of this screen.",
        "What number comes next: 2, 4, 6, 8, ...?":
            "Keep adding two each time.",
        "Which one is the odd one out: apple, banana, carrot, orange?":
            "Three of them belong in a fruit bowl. One belongs in a stew.",
        "What is the opposite of 'up'?":
            "Which way does a dropped ball go?",
        "What is 3 + 4?":
            "Start at three and count on four more.",
        "Which number is missing: 1, 2, __, 4, 5?":
            "It sits between two and four.",
        "If today is Monday, what day comes tomorrow?":
            "The day after the start of the school week.",
        "Which is the biggest number: 9, 6, 3, 1?":
            "The one nearest to ten.",
        "What comes next in the pattern: red, blue, red, blue, ...?":
            "The pattern just takes turns. What did it start with?",
        "Which is the smallest number: 3, 7, 1, 5?":
            "Start counting upwards and see which of them you reach first.",
        "How many days are there in a week?":
            "Count them from Monday through to Sunday.",
        "What is double 4?":
            "Add it to itself.",
        "Which word rhymes with 'cat'?":
            "Something you wear on your head.",
        "What is the opposite of 'hot'?":
            "How the inside of a freezer feels.",
        "How many months are there in a year?":
            "One for each number on a clock face.",
        "What comes next: circle, square, circle, square, ...?":
            "The pattern takes turns. What did it begin with?",
        "If you have 3 apples and pick 2 more, how many do you have?":
            "Count on two from three.",
        "Which is heavier, a feather or a brick?":
            "Imagine one of each landing on your toe.",
        "What is the opposite of 'day'?":
            "When the stars come out.",
        "Put these in order, smallest first: 5, 2, 8. Which comes first?":
            "The one you would reach first when counting up.",
        "What number comes next: 5, 10, 15, 20, ...?":
            "It climbs by five each time.",
        "What is 2 × 3?":
            "Two lots of three.",
        "What is half of 10?":
            "Half of the fingers on two hands.",
        "Which number is missing: 10, 20, __, 40?":
            "It climbs by ten each time.",
        "What number comes next: 1, 2, 4, 8, ...?":
            "Every number is the one before it, added to itself.",
        "A riddle: I have hands but cannot clap. What am I?":
            "It also has a face, and it ticks.",
        "What is 12 − 5?":
            "Count back five from twelve.",
        "Which shape has more sides, a triangle or a square?":
            "One has three corners and the other has four.",
        "What is 4 × 2?":
            "Four, then four again.",
        "If a week has 7 days, how many days are there in 2 weeks?":
            "Seven, and seven again.",
        "What number comes next: 3, 6, 9, 12, ...?":
            "It climbs by three each time.",
        "How many minutes are there in one hour?":
            "The same as the number of seconds in a minute.",
        "If one pencil costs 5 coins, how much do 3 pencils cost?":
            "Five, three times over.",
        "How many corners does a cube have?":
            "A dice has the same number of corners.",
        "What is 20 − 8?":
            "Count back eight from twenty.",
        "A riddle: What has to be broken before you can use it?":
            "You would crack it into a frying pan.",
        "What is 7 × 2?":
            "Seven, and seven again.",
        "Which is longer, 1 metre or 100 centimetres?":
            "Think about how many centimetres make up a whole metre.",
        "If you count by fives, what comes right after 25?":
            "Five more than twenty-five.",
        "What is half of 20?":
            "Half of the fingers and toes you own altogether.",
        "Hand is to glove as foot is to...?":
            "What goes on a foot to keep it dry.",
        "Which fraction is bigger, one half or one quarter?":
            "Which gives you more cake, cutting it in two or cutting it in four?",
        "A riddle: The more you take, the more you leave behind. What are they?":
            "Think about walking along a sandy beach.",
        "Tom is taller than Sam. Sam is taller than Ben. Who is the tallest?":
            "Follow the chain from the shortest person upwards.",
        "What is one half of 8?":
            "Cut eight in two.",
        "Which number is the odd one out: 2, 4, 7, 8?":
            "All the others can be shared into two equal piles.",
        "Big is to small as tall is to...?":
            "The opposite of tall.",
        "What number comes next: 100, 90, 80, ...?":
            "It falls by ten each time.",
        "A riddle: What gets wetter the more it dries?":
            "You reach for one when you climb out of the bath.",
        "If you turn a triangle upside down, how many sides does it have?":
            "Turning something around does not change what it is.",
        "What number comes next: 1, 4, 9, 16, ...?":
            "Each one is a number multiplied by itself.",
        "What is 6 × 6?":
            "Six lots of six.",
        "What is 100 ÷ 10?":
            "How many tens will fit inside a hundred.",
        "In Roman numerals, what number is 'V'?":
            "Count the fingers on one hand.",
        "A farmer has 17 sheep, and all but 9 run away. How many are left?":
            "Read it very slowly. The tricky words are 'all but'.",
        "What number comes next: 1, 3, 5, 7, ...?":
            "Odd numbers, climbing by two.",
        "What is 9 × 3?":
            "Nine, three times over.",
        "How many months of the year have at least 28 days?":
            "Even the shortest month manages twenty-eight.",
        "Which is heavier, 1 kilogram of feathers or 1 kilogram of stones?":
            "Look carefully at the number written before each one.",
        "In Roman numerals, what number is 'X'?":
            "On a clock face it sits right at the top.",
        "What number comes next: 3, 6, 12, 24, ...?":
            "Every number is the one before it, added to itself.",
        "Is 15 an odd number or an even number?":
            "Try sharing fifteen into two equal piles.",
        "A riddle: What has many keys but cannot open a single lock?":
            "You press them, and music comes out.",
        "How many degrees are there in a right angle, a perfect square corner?":
            "A full turn is three hundred and sixty. Take a quarter of that.",
        "What is 8 × 4?":
            "Eight, four times over.",
        "Which is the odd one out: 3, 5, 9, 10, 11?":
            "All the others cannot be shared into two equal piles.",
        "A riddle: What has a neck but no head?":
            "You pour a drink out of it.",
        "If a clock shows 3 o'clock, how many hours until it reaches 7 o'clock?":
            "Count on from three until you reach seven.",
        "What number is exactly halfway between 10 and 20?":
            "Add the two numbers together, then cut the answer in two.",
        "What letter comes next: Z, Y, X, W, ...?":
            "Go backwards through the alphabet.",
        "There are 4 boxes with 5 balls in each. How many balls in total?":
            "Five, four times over.",
        "What number comes next: 5, 10, 20, 40, ...?":
            "Every number is the one before it, added to itself.",
        "How many centimetres are there in one metre?":
            "'Centi' is the same beginning as in 'century'.",
        "A riddle: What can travel all around the world while staying in one corner?":
            "You lick it and stick it on an envelope.",
        "What is 7 × 7?":
            "Seven lots of seven.",
        "If you share 12 sweets equally between 4 children, how many does each get?":
            "Share twelve into four equal piles.",
        "Which number is missing: 2, 4, 8, 16, __, 64?":
            "Every number is the one before it, added to itself.",
        "How many sides does a hexagon have?":
            "A cell in a honeycomb has exactly the same shape.",
        "Sarah is 8 years old now. How old will she be in 5 years?":
            "Add five to the age she is now.",
        "A riddle: What has words on every page but never speaks?":
            "You turn its pages.",
        "What is 12 × 12?":
            "A dozen dozen.",
        "What number comes next: 1, 1, 2, 3, 5, 8, ...?":
            "Add the two numbers before it together.",
        "What is 144 ÷ 12?":
            "It undoes the multiplication from two questions ago.",
        "A riddle: The more of it there is, the less you see. What is it?":
            "Turn off the light and see what happens.",
        "If 5 machines make 5 toys in 5 minutes, how long for 100 machines to make 100 toys?":
            "Each machine makes one toy. Does adding machines change how long one takes?",
        "What number comes next: 1, 8, 27, 64, ...?":
            "Each one is a number multiplied by itself, and then by itself again.",
        "What is 15 × 4?":
            "Fifteen, four times over.",
        "In Roman numerals, what number is 'L'?":
            "In Roman numerals it is halfway to a hundred.",
        "A riddle: I am an odd number. Take away one letter and I become even. What am I?":
            "Take the very first letter off the front and read what is left.",
        "What is 1000 − 555?":
            "Count up from five hundred and fifty-five until you reach a thousand.",
        "What is 25 × 4?":
            "Think of quarters: four of them make a whole.",
        "What number comes next: 2, 3, 5, 7, 11, ...?":
            "These numbers can only be divided by themselves and by one.",
        "A riddle: What has a thumb and four fingers but is not alive?":
            "You wear a pair of them in winter.",
        "If half of a number is 12, what is the whole number?":
            "Double twelve.",
        "What is 9 × 9?":
            "Nine lots of nine.",
        "A riddle: What can you catch but never throw?":
            "You might get one in winter, and it makes you sneeze.",
        "What is 7 × 8?":
            "Seven eights.",
        "What letter comes next: O, T, T, F, F, S, S, ...?":
            "One, Two, Three, Four, Five, Six, Seven...",
        "A snail climbs 3 metres up a well by day but slips back 2 metres each night. How much higher is it after one full day and night?":
            "It climbs, then slides back a little. What is left over?",
        "What is 6 × 12?":
            "Half of a dozen dozen.",
        // MARK: Ancient Kingdom

        "The giant pointed stone tombs of ancient Egypt are called...":
            "Four sloping sides meeting at a single point, out in the desert sand.",
        "A king's or queen's fancy jewelled headpiece is called a...":
            "Gold, jewelled, and worn only on the head.",
        "Ancient Egyptian kings were called...":
            "Tutankhamun was one of them.",
        "A strong stone home with high walls, where kings and knights lived, is a...":
            "Thick walls, towers, and a drawbridge at the front.",
        "A soldier in shining armour who rode a horse into battle long ago was a...":
            "He wore metal from head to toe and carried a lance.",
        "A dead body wrapped in bandages to preserve it in ancient Egypt is a...":
            "Wrapped in linen from head to foot, and kept for thousands of years.",
        "Who rules a kingdom and sits upon a throne?":
            "The one wearing the crown.",
        "What do we call the study of things that happened long ago?":
            "The school subject full of dates and old kings.",
        "The ancient Egyptians wrote using little pictures called...":
            "Birds, eyes and wavy lines carved into stone instead of letters.",
        "What deep water-filled ditch around a castle helped keep enemies out?":
            "Fill the ditch with water and nobody can walk across.",
        "The giant statue with a lion's body and a human head in Egypt is the...":
            "A lion's body, a person's face, and a missing nose.",
        "In ancient Rome, fighters who battled each other in an arena were called...":
            "They fought for their lives while crowds cheered.",
        "What did knights wear to protect their bodies in battle?":
            "Metal plates covering the body, and it clanked.",
        "In old tales, brave knights often fought fierce fire-breathing...":
            "Scaly, winged, and it breathes fire.",
        "What do we call an old story passed down about gods and heroes?":
            "An old tale, half true and half not, told again and again.",
        "Ancient Egyptians preserved a pharaoh's body so he could live on in the...":
            "The Egyptians believed life carried on after you died. Where?",
        "What long cloth robe did people in ancient Rome wrap around themselves to wear?":
            "A single long sheet of cloth, wound around and over one shoulder.",
        "The son or daughter of a king or queen is called a...":
            "The royal child, waiting for a turn on the throne.",
        "What grand royal chair did a king sit on to rule his kingdom?":
            "The grand chair, up on a step, that only one person may sit in.",
        "What do we call a very old object dug up that teaches us about the past?":
            "Anything old that an archaeologist digs up and puts in a museum.",
        "Which boy pharaoh's treasure-filled tomb was famously discovered in 1922?":
            "His golden mask is the most famous face from the ancient world.",
        "Which ancient Egyptian god had the head of a jackal and guarded the dead?":
            "He has the head of a dog-like desert animal, and he guards the dead.",
        "Which ancient Egyptian sun god was seen as the king of all the gods?":
            "His name is short, and he is the sun itself.",
        "What do we call the special jars that held a mummy's organs?":
            "When a body was preserved, the insides went into separate containers.",
        "Which famous Egyptian queen was the last pharaoh to rule Egypt?":
            "She is said to have met both Caesar and Mark Antony.",
        "What paper-like material, made from a river plant, did Egyptians write on?":
            "It grew as a reed by the Nile and was flattened into sheets.",
        "What do we call a person who digs up and studies ancient remains?":
            "Someone with a trowel and a brush, working in a careful square hole.",
        "Which stone finally helped scholars learn to read Egyptian hieroglyphs?":
            "It was found by Napoleon's soldiers, and it had the same words three ways.",
        "Near which place do the Great Sphinx and the largest pyramids stand?":
            "A place just outside Cairo, where the three great tombs stand together.",
        "Which small pet did the Egyptians treasure so much that they even mummified them?":
            "They purr, and the Egyptians thought them sacred.",
        "Which famous Roman leader was warned to 'beware the Ides of March'?":
            "He was stabbed in the senate, and a month is named after him.",
        "What did the Romans build long, straight and strong to cross their whole empire?":
            "Long, straight and paved, so an army could march quickly.",
        "Roman soldiers marched and fought together in large groups called...":
            "Thousands of soldiers marching as one, under an eagle standard.",
        "What clever stone channels did the Romans build to carry water into their cities?":
            "Tall stone arches marching across the countryside, carrying a stream.",
        "Legend says Rome was founded by twin brothers raised by a wolf, Romulus and...":
            "His twin brother's name is in the city's own name.",
        "The huge round arena in Rome where games and gladiator fights were held was the...":
            "A vast oval where fifty thousand people once sat to watch.",
        "What language did the ancient Romans speak?":
            "The language that gives us words like 'aqua' and 'video'.",
        "Who was the very first emperor of ancient Rome?":
            "A month in late summer is named after him.",
        "What did victorious Roman generals wear on their heads, made from leaves?":
            "A circle of leaves, worn like a crown of victory.",
        "Who could decide whether a defeated gladiator lived or died?":
            "Thumbs up or thumbs down — and only one person's counted.",
        "In which country did the very first Olympic Games begin, long ago?":
            "The land of Zeus, Athens and Olympus.",
        "Who was the king of the ancient Greek gods, hurling thunderbolts from Mount Olympus?":
            "He is the one with the thunderbolt.",
        "The ancient Greeks invented a way of ruling where people vote, called...":
            "'Demos' means the people, and 'cracy' means rule.",
        "In a famous legend, the Greeks sneaked soldiers into Troy hidden inside a giant wooden...":
            "It was hollow, and full of soldiers.",
        "The great temple with tall columns on a hill in Athens is the...":
            "The ruined temple on the hill above Athens.",
        "Wise ancient Greek thinkers who asked big questions about life were called...":
            "'Philo' means loving, and 'sophia' means wisdom.",
        "Which tough Greek city was famous for training its boys to be fierce warriors?":
            "Its name is still used for anything plain and tough.",
        "The ancient Greek hero famous for his super strength and twelve great labours was...":
            "He wore a lion skin and completed twelve impossible tasks.",
        "What do we call the tall stone pillars that held up ancient Greek temples?":
            "The tall round stone posts holding up the roof.",
        "Which ancient Greek god of the sea carried a three-pronged spear?":
            "He carries a three-pronged fork and rules the waves.",
        "What do we call the sport where two knights charged at each other with lances on horseback?":
            "Two riders, two lances, and one of them ends up on the ground.",
        "What was a castle's drawbridge mainly used for?":
            "Think what lies just outside the castle gate, full of water.",
        "Fierce seafaring warriors from the north who raided in longships were the...":
            "They came from Scandinavia, wore helmets, and sailed narrow boats.",
        "What was the strongest, safest tower at the heart of a castle called?":
            "The last place to retreat to when the walls have fallen.",
        "A knight promised to follow a code of honour and good behaviour called...":
            "A knight's set of rules about honour, courtesy and protecting the weak.",
        "What did castle defenders fire from bows to keep attackers away?":
            "Fired from a bow, and they fall like rain.",
        "What were the tooth-like gaps along the top of castle walls, for shooting through, called?":
            "The up-and-down pattern along the top of a castle wall.",
        "Vikings sailed the seas in long, narrow wooden boats called...":
            "Narrow, wooden, with a dragon carved on the front.",
        "What deadly sickness swept through the Middle Ages, known as the Black...":
            "A terrible plague, and the colour is already in its name.",
        "Who served a knight, carried his armour, and hoped one day to become a knight himself?":
            "A knight's helper and apprentice, hoping for his own spurs one day.",
        "Roughly how many days did it take to dry and wrap a body into a mummy?":
            "About ten weeks of careful work.",
        "Which pharaoh built the Great Pyramid, the largest one of all?":
            "He built the biggest one of all at Giza.",
        "What golden covering was placed over a mummy's face, like Tutankhamun's famous one?":
            "Gold, moulded to the shape of a face, and laid over the bandages.",
        "The Valley of the Kings was a hidden desert place where Egyptian pharaohs were...":
            "It is a valley full of hidden tombs. What happened there?",
        "Which ancient wonder was a giant lighthouse in the Egyptian city of Alexandria?":
            "It stood in a harbour and guided ships with its fire.",
        "What was the ancient Egyptian symbol of life, shaped like a looped cross?":
            "A cross with a loop on top, and it stood for living.",
        "For about how long did the Great Pyramid remain the tallest building in the whole world?":
            "Longer than from the Romans until now.",
        "What do we call the carved stone coffin, often beautifully decorated, that held a mummy?":
            "The heavy stone box the wrapped body was laid inside.",
        "Which everyday liquid did Egyptians press from reeds into sheets to write on?":
            "Careful — the question contains a trap. Nothing was pressed out of anything.",
        "Which precious deep-blue stone did the Egyptians prize for jewellery, brought from far away?":
            "A rich blue stone, carried thousands of miles from the mountains.",
        "Which ancient people built a buried army of life-sized clay soldiers, the Terracotta Army?":
            "They also built a very long wall, and they invented paper.",
        "What precious cloth, spun by silkworms, did China trade along the Silk Road?":
            "It is spun by worms and it is smooth and shining.",
        "Which ancient people of Central America built step-pyramids, alongside the Maya?":
            "Their capital was where Mexico City stands today.",
        "What mysterious ring of giant standing stones was built long ago in England?":
            "Huge stones standing in a circle on Salisbury Plain.",
        "Which ancient land between two great rivers is often called the 'cradle of civilisation'?":
            "'Meso' means between, and 'potamos' means river.",
        "The first known writing, pressed into wet clay with a wedge-shaped tool, was called...":
            "Its name means 'wedge-shaped', for the marks the tool left.",
        "Which ancient king is famous for writing down one of the first sets of laws?":
            "His code was carved on a tall black pillar for all to read.",
        "Which South American empire built the mountain city of Machu Picchu?":
            "They ruled the Andes and built roads across the mountains.",
        "Which round invention, first used in ancient Mesopotamia, changed travel forever?":
            "Before it, everything heavy had to be dragged.",
        "Which ancient people of Central America created an incredibly accurate 365-day calendar?":
            "They counted the days of the year almost exactly right, in Central America.",
        "Which archaeologist discovered Tutankhamun's tomb in 1922?":
            "He peered into the tomb and said he could see wonderful things.",
        "Which volcano erupted in 79 AD, burying the Roman town of Pompeii?":
            "It still looms over the Bay of Naples today.",
        "Cleopatra was the last pharaoh; which ancient kingdom did she rule?":
            "The land of the pharaohs and the Nile.",
        "Which young king conquered a vast empire stretching from Greece to India, called Alexander the...?":
            "His name means exactly what he was, and he never lost a battle.",
        "Roughly how long ago were the Great Pyramids of Egypt built?":
            "Older than the Romans by more than twice over.",
        "In roughly which year did the Western Roman Empire finally collapse?":
            "About fifteen hundred years ago.",
        "What was the name of the ancient Greek city taken with the trick of the wooden horse?":
            "The city the wooden horse got into.",
        "Which wonder was a fabled terraced garden said to have bloomed in the city of...?":
            "The gardens are the other famous thing from this city, with its tower.",
        "Hatshepsut was unusual as an Egyptian ruler because she was a...":
            "Almost every ruler of Egypt was a man. She was the exception.",
        "Which ancient sea-traders invented an early alphabet that our own letters grew from?":
            "They sailed from Lebanon, and our own letters grew from their marks.",
        "Which ancient people are credited with inventing writing first, in Mesopotamia?":
            "They lived in Mesopotamia, and their name begins like 'summer'.",
        "Which ancient Greek city is often called the birthplace of democracy?":
            "The city of the Parthenon.",
        "Which famous Greek doctor gave his name to the promise doctors still make today?":
            "Doctors still swear an oath that carries his name.",
        "Which ancient wonder is the only one still standing today?":
            "Of the seven, only one is still there — and it is in Egypt.",
        "What was the name of the huge ancient library in the Egyptian city of Alexandria?":
            "It held every scroll in the world, and it burned.",
        "Which wise ancient Chinese thinker's teachings guided China for many centuries?":
            "His sayings begin 'The Master said', and China followed them for centuries.",
        "Which metal, made by mixing copper and tin, gave a whole age of history its name?":
            "Copper and tin, melted together, and an age is named after it.",
        "Which general famously led an army, with war elephants, over the mountains to attack Rome?":
            "He crossed the Alps with elephants.",
        "Which ancient people built towering step-temples called ziggurats in Mesopotamia?":
            "Their hanging gardens were a wonder, and their step-temples were ziggurats.",
        "What do we call the long stretch of history before writing was invented?":
            "'Pre' means before — before anybody wrote anything down.",
        // MARK: Champion's Summit

        "Which sport's most famous tournament is played on the grass courts of Wimbledon?":
            "Rackets, a net, and strawberries and cream in the crowd.",
        "Which is the fastest animal on land?":
            "Spotted, long-legged, and it can only sprint in short bursts.",
        "In Greek myth, which winged horse could soar through the sky?":
            "A white horse with feathers, and a famous flying-school brand is named after it.",
        "Chocolate is made from the beans of which plant?":
            "The bean grows in a pod on a tropical tree, and the powder is bitter.",
        "Roughly how long does sunlight take to travel from the Sun to the Earth?":
            "About long enough to boil an egg.",
        "Who painted the famous smiling portrait known as the 'Mona Lisa'?":
            "He was Italian, and he also drew flying machines in his notebooks.",
        "How many strings does a standard guitar have?":
            "Two more than a violin has.",
        "How many teeth does a full-grown adult usually have?":
            "Four more than the baby teeth you lose, and it includes the wisdom ones.",
        "The famous flag called the 'Union Jack' belongs to which country?":
            "Red, white and blue crosses laid one over another.",
        "Who invented the printing press with movable metal type, spreading books across Europe?":
            "A German goldsmith, and a famous Bible carries his name.",
        "In a game of football, how many players from each team are on the pitch?":
            "Ten out on the field, plus the one in the goal.",
        "In Norse mythology, which mighty god carried a magic hammer?":
            "Thursday is named after him.",
        "Which country is famous for inventing the rice-and-fish dish called sushi?":
            "The land of the rising sun.",
        "Who painted the swirling night sky in the famous artwork 'The Starry Night'?":
            "A Dutchman who famously cut off part of his own ear.",
        "Which is the strongest muscle in the human body for its size?":
            "You use it every time you chew, and it can crush with huge force.",
        "Which country currently has the most people living in it?":
            "It recently overtook China.",
        "Who is credited with building the first practical petrol-powered car?":
            "A German engineer, and a famous car company still carries his name.",
        "How many keys does a standard full-size piano have?":
            "Black ones and white ones, and there are more than eighty.",
        "What is 11 multiplied by 11?":
            "A pair of elevens.",
        "What do we call a rock from space that survives its fiery fall and lands on Earth?":
            "A shooting star that made it all the way down.",
        "In Greek myth, who had snakes for hair and could turn people to stone with a glance?":
            "Look at her and you would never look at anything again.",
        "About how far do runners travel in a full marathon race?":
            "The distance from a Greek battlefield to Athens, or so the legend goes.",
        "Which planet is the hottest in our Solar System?":
            "Not the closest to the Sun, but it is wrapped in a thick blanket of cloud.",
        "The flaky, curved pastry called a croissant comes from which country?":
            "The land of the Eiffel Tower.",
        "Which three colours are the 'primary' colours that can be mixed to make the others?":
            "The three you cannot make by mixing any others.",
        "Which Scottish inventor greatly improved the steam engine that powered the Industrial Revolution?":
            "A unit of electrical power is named after him.",
        "What is unique to every single person, so no two are ever exactly alike, even in twins?":
            "Detectives dust for them at the scene of a crime.",
        "Which country's flag is green with a yellow diamond and a blue globe of stars?":
            "The land of the Amazon and the carnival.",
        "Which famous composer kept writing beautiful music even after he became completely deaf?":
            "He was German, and his Fifth Symphony begins with four famous notes.",
        "A bat and a ball cost 11 coins together. The bat costs 10 coins. How much does the ball cost?":
            "Take the cost of the bat away from the total.",
        "In Norse mythology, what is the name of the great hall where brave warriors go after death?":
            "The Norse heaven, where the slain feast with Odin.",
        "What do the five interlocking rings of the Olympic symbol stand for?":
            "Count the rings, then count the great landmasses.",
        "Which animal was the first living creature to orbit the Earth in a spacecraft?":
            "A Soviet stray called Laika.",
        "Which precious spice, once worth its weight in gold, comes from the crocus flower?":
            "It is red, it is a thread, and it colours rice yellow.",
        "What do we call a figure or model carved from stone, wood or metal?":
            "A statue is one of these.",
        "Who discovered penicillin, the first antibiotic medicine, quite by accident?":
            "A Scottish doctor, and he left a dish out by mistake.",
        "How many pairs of ribs does a typical person have in their chest?":
            "One set on each side for every month of the year.",
        "Which is the smallest continent on Earth?":
            "It is also a country all by itself.",
        "In legend, which magical bird bursts into flames and is then reborn from its own ashes?":
            "The bird of fire, reborn from its own ashes.",
        "A train leaves at 2 o'clock and arrives at 5 o'clock. How long was the journey?":
            "Count on from two until you reach five.",
        "Which sport is played by hitting a feathered 'shuttlecock' over a net?":
            "Like tennis, but the thing you hit has feathers and drops suddenly.",
        "In Greek myth, the Minotaur was a monster with the body of a man and the head of a...?":
            "It lived in a maze, and it snorted and pawed the ground.",
        "What do we call a huge cloud of gas and dust in space where brand-new stars are born?":
            "A nursery for stars, made of gas and dust.",
        "Which popular drink is made from roasted beans and is famous for waking people up?":
            "It grows in Brazil and Ethiopia, and it is served hot and black.",
        "What do we call a picture that an artist paints of themselves?":
            "The artist looked in the mirror to paint it.",
        "What did Tim Berners-Lee invent in 1989, letting people browse linked pages online?":
            "Three initials you type at the front of an address.",
        "Which organ in your body can grow back even if part of it is removed?":
            "Even if surgeons take half of it away, it grows back.",
        "What do we call a large group of musicians playing many different instruments together?":
            "Violins, trumpets and drums, all following one person with a stick.",
        "Which mountainous country has the only national flag in the world that is not a rectangle?":
            "It is two triangles stacked, high in the Himalayas.",
        "What is one quarter of 100?":
            "Cut a hundred in half, then in half again.",
        "In Norse mythology, who is the mischievous trickster god, forever causing trouble?":
            "The Norse trickster, and a shape-shifter.",
        "In which sport would you try to score a 'slam dunk'?":
            "You would be jumping high and pushing a ball downwards through a hoop.",
        "Which planet is tipped so far over that it seems to roll around the Sun on its side?":
            "It lies on its side.",
        "Most of the cheese we eat is made from the milk of which farm animal?":
            "It says 'moo'.",
        "Which artist carved the famous marble statue of 'David' and painted the Sistine Chapel ceiling?":
            "An Italian, and he spent four years on his back painting a ceiling in Rome.",
        "Which invention, first demonstrated by John Logie Baird, brought moving pictures into people's homes?":
            "A box in the corner of the sitting room.",
        "About how many bones is a human baby born with, far more than a grown-up has?":
            "Many of them later fuse together, which is why grown-ups have fewer.",
        "Which country's flag shows a white crescent moon and a star on a red background?":
            "A crescent and a star, on a country that sits in two continents.",
        "What do we call the fearsome one-eyed giants of ancient Greek mythology?":
            "'Cyclo' means circle, and 'ops' means eye.",
        "How many months of the year have exactly 31 days?":
            "The same as the number of days in a week.",
        "In Greek myth, whose wax wings melted when he flew too close to the Sun?":
            "His father built the wings, and his father's name was Daedalus.",
        "How many points is a 'touchdown' worth in American football?":
            "The same as the number of sides on a dice.",
        "What is the name of the American space agency that runs Moon and Mars missions?":
            "Four initials, and the American space agency.",
        "Popcorn is made by heating the dried kernels of which crop until they burst?":
            "It grows on a cob, and each kernel explodes when it is heated.",
        "What do we call art made by sticking pieces of paper, cloth and other bits onto a surface?":
            "The French word means 'to glue'.",
        "Who invented dynamite and later left his fortune to create a famous set of prizes?":
            "He was Swedish, and a peace prize is awarded in his name each year.",
        "Which pair of bean-shaped organs filters your blood and makes urine?":
            "There are two of them, and they are shaped like beans.",
        "What is the capital city of Greece, home of ancient temples like the Parthenon?":
            "The city of the Parthenon.",
        "In the Greek legend, everything that greedy King Midas touched turned into what?":
            "He could not eat, because his dinner turned into the same thing.",
        "I am thinking of a number. If you double it, you get 18. What is my number?":
            "Cut eighteen in half.",
        "Every four years, the greatest athletes gather to compete in which giant sporting event?":
            "Five rings, a torch, and a flame carried across the world.",
        "In Greek myth, which fierce three-headed dog guarded the gates of the underworld?":
            "It guarded the land of the dead, and it had more heads than any dog should.",
        "What do we call a star that reaches the end of its life and explodes in a dazzling burst?":
            "The word has 'new' buried inside it, though it marks an ending.",
        "Which sweet nut is ground up to make marzipan and grows on trees in warm lands?":
            "It is inside a peach-like shell, and it flavours Bakewell tart.",
        "Which style of painting, meaning 'impression', used dabs of colour, with artists like Monet?":
            "Monet's water lilies are the most famous examples.",
        "Which scientist developed one of the first successful vaccines against the disease polio?":
            "An American doctor, and his name sounds like a common seasoning.",
        "How many chambers, or rooms, does the human heart have?":
            "Two at the top and two at the bottom.",
        "Which is the longest mountain range in the world, running down the edge of South America?":
            "It runs all the way down the western edge of South America.",
        "In Greek myth, which speedy god wearing winged sandals was the messenger of the gods?":
            "A brand of luxury scarves is named after him, and he had winged sandals.",
        "If 3 people take 3 hours to build 3 walls, how long for 6 people to build 6 walls?":
            "Twice as many people, but also twice as many walls to build.",
        "Which country has won the football World Cup more times than any other?":
            "They have won five times, and they play in yellow.",
        "In Norse myth, what is the name of the shimmering rainbow bridge to the home of the gods?":
            "It shimmers in the sky, and Asgard is at the other end of it.",
        "After the Sun, which is the closest star to our Earth?":
            "Its name begins like 'proximity', which means nearness.",
        "The sweet flavour of vanilla, loved in ice cream, comes from the pod of which type of flower?":
            "It is a flower, and its pods are cured until they turn black and fragrant.",
        "Which Spanish artist helped invent the Cubism style and painted the huge anti-war work 'Guernica'?":
            "He was Spanish, and he painted faces with both eyes on one side.",
        "Which inventor designed early mechanical computers and is called the 'father of the computer'?":
            "He was English, and he designed an 'Analytical Engine' that was never finished.",
        "Roughly how many times does a human heart beat in a single day?":
            "About seventy beats a minute, all day and all night.",
        "Which is the deepest lake in the world, holding a fifth of all the fresh water on Earth's surface?":
            "It is in Siberia, and it freezes over every winter.",
        "In Greek myth, which hero beheaded the snake-haired Medusa and later rescued Andromeda?":
            "He used a polished shield so he would not have to look at her directly.",
        "A clock takes 5 seconds to strike 6 o'clock. How many seconds does it take to strike 12 o'clock?":
            "Count the gaps between the strikes, not the strikes themselves.",
        "In tennis, what special word is used when the score reaches 40 points each, all square?":
            "It comes from the French for 'two', because you must now win by two.",
        "In Norse mythology, what is the name of the great final battle at the end of the world?":
            "The Norse end of the world, and a famous opera cycle ends with it.",
        "What do we call the vast shell of icy objects at the very edge of our Solar System, where many comets begin?":
            "Named after a Dutch astronomer, and it lies extremely far out.",
        "Which country grows and produces more coffee than any other in the world?":
            "The same country that has won the most World Cups.",
        "Which art movement, led by artists like Salvador Dalí, painted strange, dreamlike, impossible scenes?":
            "Melting clocks and impossible staircases.",
        "Who captured some of the first practical photographs, fixing images onto shiny silver plates?":
            "A Frenchman, and early photographs are named after him.",
        "What is the smallest bone in the whole human body, hidden deep inside your ear?":
            "Three tiny ones pass sound along inside your ear, and this is the last.",
        "What do we call the imaginary line on Earth where each new calendar day officially begins?":
            "It runs down the middle of the Pacific, and crossing it moves you a whole day.",
        "In Greek myth, which giant was condemned to hold up the sky on his shoulders forever?":
            "A book of maps is named after him.",
        "What number comes next in this expert sequence: 1, 2, 6, 24, 120, ...?":
            "Multiply by two, then by three, then by four, and keep going."
    ]
}
