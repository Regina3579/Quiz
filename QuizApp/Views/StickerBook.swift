//
//  StickerBook.swift
//  QuizApp
//
//  The child's very own sticker book. Gems earned from quizzes can be spent
//  in the sticker shop, and owned stickers can be placed anywhere across the
//  book's pages — dragged, resized and peeled off freely.
//
//  Stickers currently use cheerful emoji as placeholders. When real sticker
//  artwork is added to Assets.xcassets, set each Sticker's `imageName` and it
//  will show the picture instead of the emoji automatically.
//

import SwiftUI

// MARK: - Models

/// A collectable sticker sold in the shop.
struct Sticker: Identifiable, Hashable {
    let id: String
    let emoji: String
    let cost: Int
    /// Optional asset name for real sticker art (falls back to the emoji).
    var imageName: String? = nil
}

/// A sticker the child has stuck into their book at a spot on a page.
struct PlacedSticker: Identifiable, Codable, Hashable {
    var id = UUID()
    var stickerID: String
    var page: Int
    /// Position as a fraction of the page (0…1) so it survives rotation/resize.
    var x: Double
    var y: Double
    var scale: Double = 1
    var rotation: Double = 0
}

/// A little text box the child has dropped onto a page. Like a sticker it
/// lives at a fraction of the page so it survives rotation and resizing, and
/// it can be dragged anywhere and written in.
struct PlacedNote: Identifiable, Codable, Hashable {
    var id = UUID()
    var page: Int
    /// Position as a fraction of the page (0…1).
    var x: Double
    var y: Double
    var text: String = ""
}

/// A themed group of stickers in the shop (e.g. "Animal Kingdom"). Each
/// category has a Cute tier (50 gems) and an Epic tier (100 gems).
struct StickerCategory: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let cute: [Sticker]
    let epic: [Sticker]

    var count: Int { cute.count + epic.count }
}

/// The stickers available in the shop, organised into themed categories.
/// Every 50 gems buys one sticker: the Cute tier is 50 gems each and the
/// fancier Epic tier is 100 gems each.
enum StickerCatalog {
    static let cuteCost = 50
    static let epicCost = 100

    private static func cuteSticker(_ n: Int) -> Sticker {
        Sticker(id: "animal_c\(n)", emoji: "🐾", cost: cuteCost,
                imageName: String(format: "StickerC%02d", n))
    }
    private static func epicSticker(_ n: Int) -> Sticker {
        Sticker(id: "animal_e\(n)", emoji: "👑", cost: epicCost,
                imageName: String(format: "StickerE%02d", n))
    }

    /// 🦁 Animal Kingdom — a hand-picked set of cute and epic animals.
    static let animalKingdom = StickerCategory(
        id: "animals",
        name: "Animal Kingdom",
        emoji: "🦁",
        cute: [
            cuteSticker(1),   // lion
            cuteSticker(2),   // tiger
            cuteSticker(4),   // monkey
            cuteSticker(5),   // giraffe
            cuteSticker(6),   // panda
            cuteSticker(8),   // cat
            cuteSticker(9),   // dog
            cuteSticker(11),  // otter
            cuteSticker(12),  // hedgehog
            cuteSticker(13)   // raccoon
        ],
        epic: [
            epicSticker(18),  // pink deer
            epicSticker(19),  // gold lion
            epicSticker(20),  // fairy bunny
            epicSticker(21),  // crowned unicorn
            epicSticker(22),  // royal elephant
            epicSticker(23)   // flower deer
        ]
    )

    private static func galaxySticker(_ n: Int) -> Sticker {
        Sticker(id: "galaxy_c\(n)", emoji: "🚀", cost: cuteCost,
                imageName: String(format: "StickerG%02d", n))
    }
    private static func galaxyEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "galaxy_e\(n)", emoji: "🌌", cost: epicCost,
                imageName: String(format: "StickerGE%02d", n))
    }

    /// 🚀 Galaxy Quest — cute space explorers and friendly planets.
    static let galaxyQuest = StickerCategory(
        id: "galaxy",
        name: "Galaxy Quest",
        emoji: "🚀",
        cute: [
            galaxySticker(1),  // astronaut penguin
            galaxySticker(2),  // smiling ringed planet
            galaxySticker(3),  // bunny on a rocket
            galaxySticker(4),  // astronaut boy on the moon
            galaxySticker(5)   // astronaut elephant
        ],
        epic: [
            galaxyEpicSticker(1),  // star fighter streaking past a galaxy
            galaxyEpicSticker(2),  // astronaut watching a ringed planet
            galaxyEpicSticker(3),  // star wizard juggling planets
            galaxyEpicSticker(4),  // unicorn astronaut on a cloud
            galaxyEpicSticker(5),  // alien flying a saucer
            galaxyEpicSticker(6),   // robot astronaut hugging a star
            galaxyEpicSticker(7),   // smiling sun with wavy flame rays
            galaxyEpicSticker(8),   // planet Earth, Americas facing out
            galaxyEpicSticker(9),   // ringed gas giant among sparkles
            galaxyEpicSticker(10),  // cratered asteroid studded with gems
            galaxyEpicSticker(11)   // shooting star with a glittering tail
        ]
    )

    private static func dinoSticker(_ n: Int) -> Sticker {
        Sticker(id: "dino_c\(n)", emoji: "🦕", cost: cuteCost,
                imageName: String(format: "StickerD%02d", n))
    }
    private static func dinoEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "dino_e\(n)", emoji: "🦖", cost: epicCost,
                imageName: String(format: "StickerDE%02d", n))
    }

    /// 🦖 Dino Valley — friendly baby dinosaurs from the prehistoric trail.
    static let dinoValley = StickerCategory(
        id: "dino",
        name: "Dino Valley",
        emoji: "🦖",
        cute: [
            dinoSticker(1),  // baby T. rex by a footprint sign
            dinoSticker(2),  // brachiosaurus munching leaves
            dinoSticker(3),  // triceratops with a flower crown
            dinoSticker(4),  // stegosaurus with sunset plates
            dinoSticker(5),  // hatchling in a cracked egg
            dinoSticker(6),  // blue pterodactyl gliding, wings spread
            dinoSticker(7)   // teal triceratops with a spotted frill
        ],
        epic: [
            dinoEpicSticker(1),  // crystal ankylosaurus with a gem club
            dinoEpicSticker(2),  // spinosaurus before a volcano
            dinoEpicSticker(3),  // T. rex wearing a leaf necklace
            dinoEpicSticker(4),  // crystal triceratops in blossom
            dinoEpicSticker(5),  // roaring T. rex at sunset
            dinoEpicSticker(6),  // crowned crystal T. rex by a waterfall
            dinoEpicSticker(7),  // chef triceratops with a burger
            dinoEpicSticker(8)   // pterodactyl trailing a ribbon of sparkles
        ]
    )

    private static func oceanSticker(_ n: Int) -> Sticker {
        Sticker(id: "ocean_c\(n)", emoji: "🐬", cost: cuteCost,
                imageName: String(format: "StickerO%02d", n))
    }
    private static func oceanEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "ocean_e\(n)", emoji: "🌊", cost: epicCost,
                imageName: String(format: "StickerOE%02d", n))
    }

    /// 🐬 Ocean Paradise — cheerful friends from the reef and the waves.
    static let oceanParadise = StickerCategory(
        id: "ocean",
        name: "Ocean Paradise",
        emoji: "🐬",
        cute: [
            oceanSticker(1),  // leaping dolphin in a splash
            oceanSticker(2),  // spouting whale over a wave
            oceanSticker(3),  // sea turtle above the coral
            oceanSticker(4),  // octopus with a pearl
            oceanSticker(5),   // crab holding a scallop shell
            oceanSticker(6),   // clownfish in a pink anemone
            oceanSticker(7),   // seahorse with a rainbow fin
            oceanSticker(8),   // pufferfish over the coral
            oceanSticker(9),   // seal pup with a starfish friend
            oceanSticker(10)   // squid among the bubbles
        ],
        epic: [
            oceanEpicSticker(1),  // galaxy orca full of stars
            oceanEpicSticker(2),  // crowned whale shark with pearls
            oceanEpicSticker(3),  // jewelled lobster by a treasure chest
            oceanEpicSticker(4),  // angelfish queen before a coral palace
            oceanEpicSticker(5),  // dolphin leaping through a wave
            oceanEpicSticker(6),  // crowned lionfish over the reef
            oceanEpicSticker(7),  // pearl nautilus princess
            oceanEpicSticker(8)   // rainbow mantis shrimp on the gems
        ]
    )

    private static func explorerSticker(_ n: Int) -> Sticker {
        Sticker(id: "explorer_c\(n)", emoji: "🧭", cost: cuteCost,
                imageName: String(format: "StickerX%02d", n))
    }
    private static func explorerEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "explorer_e\(n)", emoji: "🌍", cost: epicCost,
                imageName: String(format: "StickerXE%02d", n))
    }

    /// 🧭 Explorer's Trail — wandering the world, one landmark at a time.
    static let explorersTrail = StickerCategory(
        id: "explorer",
        name: "Explorer's Trail",
        emoji: "🧭",
        cute: [
            explorerSticker(1),  // explorer girl with binoculars and a globe
            explorerSticker(2),  // hot-air balloon over the world
            explorerSticker(3),  // smiling suitcase ready to travel
            explorerSticker(4),  // London bus by Big Ben
            explorerSticker(5)   // Paris and the Eiffel Tower
        ],
        epic: [
            explorerEpicSticker(1),  // Golden World Explorer globe
            explorerEpicSticker(2),  // explorers at the Colosseum
            explorerEpicSticker(3),  // golden globe and world landmarks
            explorerEpicSticker(4),  // yellow road-trip car in the mountains
            explorerEpicSticker(5)   // London bus with binoculars and a puppy
        ]
    )

    private static func blossomSticker(_ n: Int) -> Sticker {
        Sticker(id: "blossom_c\(n)", emoji: "🌺", cost: cuteCost,
                imageName: String(format: "StickerB%02d", n))
    }
    private static func blossomEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "blossom_e\(n)", emoji: "🌸", cost: epicCost,
                imageName: String(format: "StickerBE%02d", n))
    }

    /// 🌺 Blossom Garden — spring in the flower beds.
    static let blossomGarden = StickerCategory(
        id: "blossom",
        name: "Blossom Garden",
        emoji: "🌺",
        cute: [
            blossomSticker(1),  // smiling bouquet with a little chick
            blossomSticker(2),  // glitter butterfly on a pink daisy
            blossomSticker(3),  // watering can full of blossom
            blossomSticker(4),  // cherry tree shedding petals
            blossomSticker(5),  // ladybird resting on a daisy
            blossomSticker(6),  // toadstool cottage in the flower bed
            blossomSticker(7),  // blossom tree with a swing and a bluebird
            blossomSticker(8),  // garden gate, "Good Things Grow Here"
            blossomSticker(9),  // bluebird on a flowering birdhouse
            blossomSticker(10), // kitten hugging a star
            blossomSticker(11), // bluebird singing on a blossom branch
            blossomSticker(12)  // lilac blossom tree shedding petals
        ],
        epic: [
            blossomEpicSticker(1),  // rainbow unicorn in the blossom
            blossomEpicSticker(2),  // wisteria gazebo with golden lanterns
            blossomEpicSticker(3),  // crowned golden songbird
            blossomEpicSticker(4),  // fawn with blossoming antlers
            blossomEpicSticker(5),  // moonlit blossom tree over the water
            blossomEpicSticker(6),  // crowned butterfly with heart wings
            blossomEpicSticker(7),  // lantern-lit gazebo with pink curtains
            blossomEpicSticker(8),  // jewelled golden butterfly
            blossomEpicSticker(9),  // hummingbird at a sparkling lotus
            blossomEpicSticker(10)  // smiling blossom with golden stamens
        ]
    )

    private static func scienceSticker(_ n: Int) -> Sticker {
        Sticker(id: "science_c\(n)", emoji: "🔬", cost: cuteCost,
                imageName: String(format: "StickerS%02d", n))
    }

    private static func scienceEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "science_e\(n)", emoji: "⚗️", cost: epicCost,
                imageName: String(format: "StickerSE%02d", n))
    }

    /// 🔬 Science Lab — bubbling experiments and cheerful little scientists,
    /// with a grander laboratory in the Epic tier.
    static let scienceLab = StickerCategory(
        id: "science",
        name: "Science Lab",
        emoji: "🔬",
        cute: [
            scienceSticker(1),  // bubbling volcano with flasks
            scienceSticker(2),  // rainbow DNA helix
            scienceSticker(3),  // lab mouse at the Mini Lab
            scienceSticker(4),  // robot holding a pink flask
            scienceSticker(5),  // smiling atom
            scienceSticker(6),  // microscope reading "Explore Learn Grow"
            scienceSticker(7),  // three flasks on a stack of science books
            scienceSticker(8),  // light bulb in goggles with "Bright Ideas"
            scienceSticker(9),  // galaxy flask holding a test tube
            scienceSticker(10)  // rack of five bubbling test tubes
        ],
        epic: [
            scienceEpicSticker(1),  // golden DNA chamber among the crystals
            scienceEpicSticker(2),  // rocket on its gantry at the crystal pad
            scienceEpicSticker(3),  // glass observatory dome with telescopes
            scienceEpicSticker(4),  // bench of galaxy flasks under the planets
            scienceEpicSticker(5)   // golden telescope full of stars
        ]
    )

    /// "BC" rather than "B", which Blossom Garden already uses.
    private static func brainSticker(_ n: Int) -> Sticker {
        Sticker(id: "brain_c\(n)", emoji: "🏰", cost: cuteCost,
                imageName: String(format: "StickerBC%02d", n))
    }

    private static func brainEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "brain_e\(n)", emoji: "👑", cost: epicCost,
                imageName: String(format: "StickerBCE%02d", n))
    }

    /// 🏰 Brain Castle — numbers, shapes and puzzles to think with, and a
    /// grander realm of them in the Epic tier.
    static let brainCastle = StickerCategory(
        id: "brain",
        name: "Brain Castle",
        emoji: "🏰",
        cute: [
            brainSticker(1),  // graduate brain with a pencil and sums
            brainSticker(2),  // crowned tower of number blocks
            brainSticker(3),  // smiling abacus, "Small Steps Big Minds"
            brainSticker(4),  // caterpillar counting one to ten
            brainSticker(5),  // geometry shapes on a stack of books
            brainSticker(6),  // crowned star with a trophy, "You Did It!"
            brainSticker(7),  // fraction pizza, "Share Divide Learn"
            brainSticker(8),  // alarm clock, "Time to Learn!"
            brainSticker(9),  // heart jigsaw, "Math Is Fun!"
            brainSticker(10)  // balance scales weighing number blocks
        ],
        epic: [
            brainEpicSticker(1),  // the Infinity Gateway of numbers
            brainEpicSticker(2),  // explorer girl and her dragon at the chest
            brainEpicSticker(3),  // crowned brain among the formulas
            brainEpicSticker(4),  // astronaut girl riding a rocket past Earth
            brainEpicSticker(5)   // Brain Castle itself, "Knowledge Lives Here!"
        ]
    )

    private static func ancientSticker(_ n: Int) -> Sticker {
        Sticker(id: "ancient_c\(n)", emoji: "👑", cost: cuteCost,
                imageName: String(format: "StickerA%02d", n))
    }

    private static func ancientEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "ancient_e\(n)", emoji: "🏛️", cost: epicCost,
                imageName: String(format: "StickerAE%02d", n))
    }

    /// 👑 Ancient Kingdom — Greece, Egypt and Rome, and the treasures they
    /// left behind, with grander relics in the Epic tier.
    static let ancientKingdom = StickerCategory(
        id: "ancient",
        name: "Ancient Kingdom",
        emoji: "👑",
        cute: [
            ancientSticker(1),  // Greek urn spilling gems and coins
            ancientSticker(2),  // camel resting at the pyramid
            ancientSticker(3),  // laurel-crowned girl at a Greek temple
            ancientSticker(4),  // Egyptian cat in a golden collar
            ancientSticker(5),  // Roman shield, helmet and sword
            ancientSticker(6),  // kitten in a pharaoh's headdress
            ancientSticker(7),  // lion of the Ishtar Gate
            ancientSticker(8),  // Aztec sun temple with a toucan
            ancientSticker(9),  // camel in festival tassels
            ancientSticker(10)  // desert tent with a lantern and maps
        ],
        epic: [
            ancientEpicSticker(1),  // pharaoh kitten among the treasure
            ancientEpicSticker(2),  // the Sphinx between two braziers
            ancientEpicSticker(3),  // Horus falcon over the pyramids
            ancientEpicSticker(4),  // treasure chest of ankhs and gems
            ancientEpicSticker(5),  // Anubis gateway onto the pyramids
            ancientEpicSticker(6),  // hanging gardens of Babylon
            ancientEpicSticker(7),  // golden temple valley at sunrise
            ancientEpicSticker(8)   // palace floating on the clouds
        ]
    )

    /// "CS" rather than "C", which Animal Kingdom already uses.
    private static func championSticker(_ n: Int) -> Sticker {
        Sticker(id: "champion_c\(n)", emoji: "🏆", cost: cuteCost,
                imageName: String(format: "StickerCS%02d", n))
    }

    private static func championEpicSticker(_ n: Int) -> Sticker {
        Sticker(id: "champion_e\(n)", emoji: "✨", cost: epicCost,
                imageName: String(format: "StickerCSE%02d", n))
    }

    /// 🏆 Champion's Summit — the last adventure gathers friends from all the
    /// others.
    static let championsSummit = StickerCategory(
        id: "champion",
        name: "Champion's Summit",
        emoji: "🏆",
        cute: [
            championSticker(1),  // lion cub in a jewelled crown
            championSticker(2),  // baby elephant sitting up
            championSticker(3),  // penguin with its flippers out
            championSticker(4),  // dolphin leaping from the splash
            championSticker(5),  // smiling globe on a golden stand
            championSticker(6),  // astronaut child waving
            championSticker(7),  // fox cub with a bushy tail
            championSticker(8),  // owl in a mortarboard, reading
            championSticker(9),  // lion cub with a full mane
            // 10 was a second baby elephant, near enough to championSticker(2)
            // that the pair read as a repeat. Removed; the number is not
            // reused, so nothing a child already placed shifts under them.
            championSticker(11), // winking star with little stars around it
            championSticker(12), // fluffy kitten in a pink heart collar
            championSticker(13)  // winking sun with pointed rays
        ],
        epic: [
            championEpicSticker(1),  // purple butterfly with heart-patterned wings
            championEpicSticker(2),  // rainbow arch between two smiling clouds
            championEpicSticker(3),  // crowned heart trailing sparkles
            championEpicSticker(4),  // jewelled magic book ringed with light
            championEpicSticker(5),  // erupting volcano under a starry ash cloud
            championEpicSticker(6),  // gold cup set with pink hearts
            championEpicSticker(7),  // rainbow diamond in a ring of sparkles
            championEpicSticker(8),  // pink spellbook with a jewelled heart
            championEpicSticker(9),  // winking pink flower on green leaves
            championEpicSticker(10)  // winking gold crown of hearts and gems
        ]
    )

    /// All ten adventures now have a shelf of their own.
    static let categories: [StickerCategory] = [
        animalKingdom, galaxyQuest, dinoValley, oceanParadise, explorersTrail,
        blossomGarden, scienceLab, brainCastle, ancientKingdom, championsSummit
    ]

    /// The ten a child can buy without Pro: the first Cute sticker on each
    /// adventure's shelf. One from every adventure rather than ten from one,
    /// so the free taster covers the whole book instead of finishing a corner
    /// of it — and so whichever adventure a child loves, there is a sticker in
    /// it they can actually have.
    static let freeSampleIDs: Set<String> = Set(categories.compactMap { $0.cute.first?.id })

    static let all: [Sticker] = categories.flatMap { $0.cute + $0.epic }

    static let byID: [String: Sticker] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.id, $0) })
}

// MARK: - How much of the book opens

/// How long the sticker book is, and how much of it a player can fill in.
///
/// The book is twenty-five pages, and every one of them turns for everybody.
/// Without Pro the first five are the ones you can put things on; the other
/// twenty are there to be looked at, each wearing its own little crown lock.
///
/// Shutting the far pages away entirely would have been easier, and worse: a
/// book that stops at five looks like a book with five pages. A book that
/// turns all the way through and shows twenty crowned pages waiting is the
/// same offer told honestly, and a child can see exactly what it is.
///
/// Both numbers live here rather than inside the book view because the Pro
/// page quotes them too, and a paywall promising a length the book does not
/// have would be a lie the moment either number changed.
enum StickerBookPages {
    static let total = 25
    static let free = 5

    /// Whether this page is one the player can stick things on. Pro opens
    /// all of them; without it, the first `free` are yours.
    static func isLocked(_ page: Int) -> Bool {
        guard !Pro.isActive else { return false }
        return page >= free
    }

    /// True while some of the book is still behind Pro.
    static var isGated: Bool { !Pro.isActive }

    /// How the locked stretch is described wherever it is named: "6–25".
    static var lockedRange: String { "\(free + 1)–\(total)" }
}

// MARK: - Sticker glyph

/// Draws a sticker: the real artwork if it has one, otherwise the emoji.
struct StickerGlyph: View {
    let sticker: Sticker
    var size: CGFloat

    var body: some View {
        Group {
            if let name = sticker.imageName {
                Image(name).resizable().scaledToFit()
            } else {
                Text(sticker.emoji).font(.system(size: size * 0.9))
            }
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
    }
}

// MARK: - Map button (a cute little closed book)

/// The "My Sticker Book" cover art used as the button on the Adventure Map.
struct StickerBookIcon: View {
    var body: some View {
        Image("StickerBookCover")
            .resizable()
            .scaledToFit()
            .frame(width: 66, height: 66)
            .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
    }
}

// MARK: - Sticker book

struct StickerBookView: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss

    private let totalPages = StickerBookPages.total
    /// Whether the page on screen is one of the crowned ones. Read fresh every
    /// time the body runs, so buying Pro from inside the book unlocks the rest
    /// of it at once.
    private var currentPageLocked: Bool { StickerBookPages.isLocked(currentPage) }

    @State private var currentPage = 0
    @State private var showShop = false
    /// Raised by asking to put something on a crowned page.
    @State private var showPageGate = false
    @State private var showPro = false
    /// Bumped when the Pro page closes, purely to re-run the body so
    /// the locks are read again. `Pro.isActive` is a UserDefaults read and
    /// SwiftUI has no way to notice it changing on its own.
    @State private var proRefresh = 0
    /// The leaf currently being turned, if any.
    @State private var flip: FlipState?
    /// How far the turning leaf has rotated, in degrees.
    @State private var leafAngle: Double = 0
    @State private var isFlipping = false

    /// Describes a page turn in progress: which spread we are leaving, which
    /// we are heading to, and whether the leaf is still on its way to the
    /// spine (`.lifting`) or coming back down on the other side (`.landing`).
    private struct FlipState {
        enum Stage { case lifting, landing }
        let forward: Bool
        let from: Int
        let to: Int
        var stage: Stage
    }

    /// The leaf stops just short of edge-on. At exactly 90° the perspective
    /// projection is degenerate and produces non-finite geometry, so the
    /// content swap happens here instead.
    private let leafEdge: Double = 88
    /// The text box currently open for typing, if any.
    @State private var editingNote: UUID?
    @State private var showTips = false
    /// The tips card shows itself the first time the book is ever opened.
    @AppStorage("quizspark.book.tipsSeen") private var tipsSeen = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.62, green: 0.78, blue: 1.00),
                        Color(red: 0.86, green: 0.80, blue: 1.00),
                        Color(red: 1.00, green: 0.85, blue: 0.95)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                // The book, with clear space above and below, then the
                // controls. Only laid out once the container reports a usable
                // size, so the inner padding can never produce a negative
                // dimension.
                if geo.size.width > 120 && geo.size.height > 120 {
                    VStack(spacing: 10) {
                        Spacer(minLength: 6)
                        bookArea
                            .frame(width: geo.size.width - 24,
                                   height: geo.size.height * 0.58)
                        controlBar
                            // Kept on this view rather than the root: two
                            // sheets on one view conflict, and the shop
                            // already owns the root's sheet.
                            .sheet(isPresented: $showTips,
                                   onDismiss: { tipsSeen = true }) {
                                StickerBookTipsCard()
                            }
                        Spacer(minLength: 6)
                    }
                }

                // What the crown on a page means. An overlay rather than a
                // sheet: the book stays visible behind it, so what is being
                // offered is obvious.
                if showPageGate {
                    BookPageGate(freePages: StickerBookPages.free,
                                 totalPages: totalPages,
                                 onSeePro: {
                                     showPageGate = false
                                     showPro = true
                                 },
                                 onClose: { showPageGate = false })
                        .transition(.opacity)
                        .zIndex(5)
                }
            }
        }
        // Turning the page puts away whatever was being typed.
        .onChange(of: currentPage) { _ in editingNote = nil }
        .onAppear {
            // Show the child how it works once, then never unprompted again.
            if !tipsSeen {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showTips = true
                }
            }
        }
        .sheet(isPresented: $showShop) {
            StickerShopSheet { sticker in
                // Drop the new sticker in the middle of the current page.
                // Checked again here and not only on the button: Pro can
                // lapse while the shop is open, and a sticker landing on a
                // crowned page would be lost the next time the book is read.
                guard !currentPageLocked else { raiseGate(); return }
                progress.placeSticker(sticker.id, page: currentPage, x: 0.5, y: 0.5)
                Haptics.play(.light)
                Sound.stickerPop()
            }
            .environmentObject(progress)
        }
    }

    /// A pink circular button gradient, matching the storybook look.
    private var pinkButton: LinearGradient {
        LinearGradient(colors: [
            Color(red: 1.00, green: 0.46, blue: 0.72),
            Color(red: 1.00, green: 0.30, blue: 0.58)
        ], startPoint: .top, endPoint: .bottom)
    }

    // MARK: - The virtual book

    /// A thick pink-to-purple book cover.
    private var coverGradient: LinearGradient {
        LinearGradient(colors: [
            Color(red: 1.00, green: 0.44, blue: 0.72),
            Color(red: 0.62, green: 0.36, blue: 0.96)
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var bookArea: some View {
        ZStack {
            bookCover
            pageSpread
            closeOverlay
            arrowsOverlay
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    if value.translation.width < -40 { turn(forward: true) }
                    else if value.translation.width > 40 { turn(forward: false) }
                }
        )
        // Hung here and not on the root: the root's sheet belongs to the
        // shop, and two sheets on one view fight each other.
        .sheet(isPresented: $showPro, onDismiss: { proRefresh += 1 }) {
            ProUnlockView(reason: .sticker)
        }
    }

    /// The thick pink/purple book cover.
    private var bookCover: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(coverGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(.white.opacity(0.4), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.3), radius: 16, y: 10)
            .padding(.horizontal, 10)
    }

    /// The open cream two-page spread, inset so the cover shows as a thick
    /// edge. A page turn lifts a single leaf around the spine in the middle,
    /// the way a real book does, rather than swinging the whole spread.
    private var pageSpread: some View {
        ZStack {
            baseSpread
            if let f = flip {
                turningLeaf(f)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    /// What lies flat on the table: mid-turn the two halves come from
    /// different spreads, so the page being uncovered shows through.
    @ViewBuilder
    private var baseSpread: some View {
        if let f = flip {
            let leftPage = f.forward ? f.from : f.to
            let rightPage = f.forward ? f.to : f.from
            ZStack {
                leaf(page: leftPage, side: .left)
                leaf(page: rightPage, side: .right)
            }
        } else {
            page(currentPage)
        }
    }

    /// One page of the book, told whether it is crowned and what to do about
    /// it. Built here so the flipping leaf and the flat page cannot disagree.
    private func page(_ number: Int) -> some View {
        StickerPageView(page: number, totalPages: totalPages,
                        locked: StickerBookPages.isLocked(number),
                        editing: $editingNote,
                        onLockedTap: raiseGate)
    }

    /// The single leaf in the air, rotating about the spine.
    private func turningLeaf(_ f: FlipState) -> some View {
        // Lifting shows the face we are leaving; landing shows the far side of
        // the same leaf, which is a page of the spread we are turning to.
        let side: LeafSide
        let page: Int
        switch (f.forward, f.stage) {
        case (true, .lifting):   side = .right; page = f.from
        case (true, .landing):   side = .left;  page = f.to
        case (false, .lifting):  side = .left;  page = f.from
        case (false, .landing):  side = .right; page = f.to
        }

        // Paper darkens as it stands up, which sells the lift.
        let shade = min(0.45, abs(leafAngle) / leafEdge * 0.45)

        return leaf(page: page, side: side)
            .overlay(LeafClip(side: side).fill(Color.black.opacity(shade)))
            .rotation3DEffect(.degrees(leafAngle),
                              axis: (x: 0, y: 1, z: 0),
                              anchor: .center,
                              perspective: 0.5)
            .shadow(color: .black.opacity(0.35), radius: 10,
                    x: f.forward ? -8 : 8)
    }

    /// One half of a spread, clipped down the spine.
    private func leaf(page number: Int, side: LeafSide) -> some View {
        page(number).clipShape(LeafClip(side: side))
    }

    /// The small close button in the top-right corner of the book.
    private var closeOverlay: some View {
        VStack {
            HStack {
                Spacer()
                roundButton(system: "xmark", enabled: true) {
                    Haptics.play(.light)
                    dismiss()
                }
            }
            Spacer()
        }
        .padding(.top, 4)
        .padding(.trailing, 2)
    }

    /// The page-turn arrows on the left and right sides. Both work the whole
    /// way through the book: the crowned pages are there to be walked past
    /// and looked at, so nothing stops the turn.
    private var arrowsOverlay: some View {
        HStack {
            roundButton(system: "chevron.left", enabled: currentPage > 0) {
                turn(forward: false)
            }
            Spacer()
            roundButton(system: "chevron.right", enabled: currentPage < totalPages - 1) {
                turn(forward: true)
            }
        }
    }

    private var controlBar: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Button {
                    Haptics.play(.light)
                    // Opening the shop from a crowned page would end with a
                    // sticker that had nowhere to land.
                    if currentPageLocked { raiseGate() } else { showShop = true }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: currentPageLocked ? "crown.fill" : "plus.circle.fill")
                        Text("Add Stickers")
                    }
                    .font(Theme.bold(17))
                    .foregroundColor(.white)
                    .padding(.vertical, 13)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Theme.nextButton)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                }
                .buttonStyle(PressableButtonStyle())

                // Drops a fresh text box onto the page, ready to type in.
                Button {
                    Haptics.play(.light)
                    guard !currentPageLocked else { raiseGate(); return }
                    Sound.stickerPop()
                    editingNote = progress.addNote(page: currentPage, x: 0.5, y: 0.42)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: currentPageLocked ? "crown.fill" : "textformat")
                        Text("Text")
                    }
                    .font(Theme.bold(17))
                    .foregroundColor(.white)
                    .padding(.vertical, 13)
                    .padding(.horizontal, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(pinkButton)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Add a text box")
            }

            // Just the page count, with a quiet way to ask how things work.
            HStack(spacing: 8) {
                // The count never shrinks: the book is twenty-five pages long
                // for everyone, and page 19 is page 19 whether or not it is
                // one you can stick things on yet.
                Text("Page \(currentPage + 1) of \(totalPages)")
                    .font(Theme.medium(11))
                    .foregroundColor(Theme.inkSoft)

                // Only while standing on a crowned page, so the reminder
                // appears where it is the answer to something.
                if currentPageLocked {
                    Button {
                        Haptics.play(.light)
                        withAnimation(.easeOut(duration: 0.2)) { showPageGate = true }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill").font(.system(size: 9))
                            Text("Pro page").font(Theme.bold(11))
                        }
                        .foregroundColor(Color(red: 0.62, green: 0.38, blue: 0.02))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color(red: 1.00, green: 0.88, blue: 0.52)))
                        .overlay(Capsule().stroke(.white.opacity(0.9), lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }

                Button {
                    Haptics.play(.light)
                    showTips = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "lightbulb.fill").font(.system(size: 9))
                        Text("Tips").font(Theme.bold(11))
                    }
                    .foregroundColor(Theme.inkSoft)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(.white.opacity(0.75)))
                    .overlay(Capsule().stroke(Theme.inkSoft.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("How the sticker book works")
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 8)
    }

    private func roundButton(system: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(Theme.bold(18))
                .foregroundColor(.white)
                .frame(width: 46, height: 46)
                .background(Circle().fill(enabled ? AnyShapeStyle(pinkButton)
                                                  : AnyShapeStyle(Color.gray.opacity(0.4))))
                .overlay(Circle().stroke(.white.opacity(0.75), lineWidth: 2))
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!enabled)
    }

    /// Brings up the card that says what the crown on the page means. Every
    /// road to it comes through here — the page itself, the caption pill, and
    /// the two buttons that would otherwise put something down on it.
    private func raiseGate() {
        Haptics.play(.light)
        withAnimation(.easeOut(duration: 0.2)) { showPageGate = true }
    }

    /// Turns a single leaf around the spine, the way a real book does: the
    /// half nearest the edge lifts, stands up at the middle, then falls flat
    /// on the other side. Done in two stages so the leaf never crosses the
    /// degenerate 90° point with its content on the wrong face.
    private func turn(forward: Bool) {
        guard !isFlipping else { return }
        let target = currentPage + (forward ? 1 : -1)
        guard target >= 0 && target < totalPages else { return }

        isFlipping = true
        Haptics.play(.light)
        Sound.pageFlip()

        flip = FlipState(forward: forward, from: currentPage, to: target, stage: .lifting)
        leafAngle = 0

        // Stage 1: the leaf lifts off the page and stands up at the spine.
        let lifted = forward ? -leafEdge : leafEdge
        withAnimation(.easeIn(duration: 0.26)) { leafAngle = lifted }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            // Stage 2: swap to the leaf's far side and let it fall flat.
            flip?.stage = .landing
            leafAngle = -lifted
            withAnimation(.easeOut(duration: 0.26)) { leafAngle = 0 }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.27) {
                currentPage = target
                flip = nil
                leafAngle = 0
                isFlipping = false
            }
        }
    }
}

// MARK: - How the book works

/// A small, friendly card explaining the gestures. It appears by itself the
/// first time the book is opened and is available from the Tips button after
/// that, so the page itself stays clear of instructions.
private struct StickerBookTipsCard: View {
    @Environment(\.dismiss) private var dismiss

    private let tips: [(icon: String, title: String, detail: String)] = [
        ("✋", "Move it",   "Drag a sticker or a text box anywhere you like"),
        ("✏️", "Write",     "Tap a text box to write in it, then tap Done"),
        ("🤏", "Resize",    "Pinch a sticker to make it bigger or smaller"),
        ("🗑", "Take it off", "Press and hold a sticker or a text box to remove it"),
        ("📖", "Turn over", "Swipe the page, or tap the arrows at the sides")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // A soft handle-ish header rather than a heavy title bar.
            VStack(spacing: 4) {
                Text("✨").font(.system(size: 26))
                Text("Your Sticker Book")
                    .font(Theme.display(22))
                    .foregroundColor(Theme.ink)
            }
            .padding(.top, 22)
            .padding(.bottom, 14)

            VStack(spacing: 10) {
                ForEach(tips, id: \.title) { tip in
                    row(tip)
                }
            }
            .padding(.horizontal, 20)

            Button {
                Haptics.play(.light)
                dismiss()
            } label: {
                Text("Got it!")
                    .font(Theme.bold(17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Theme.nextButton))
                    .shadow(color: .black.opacity(0.18), radius: 5, y: 3)
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [
                Color(red: 1.00, green: 0.98, blue: 0.94),
                Color(red: 1.00, green: 0.93, blue: 0.95)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
        .presentationDetents([.height(460)])
        .presentationDragIndicator(.visible)
    }

    private func row(_ tip: (icon: String, title: String, detail: String)) -> some View {
        HStack(spacing: 12) {
            Text(tip.icon)
                .font(.system(size: 20))
                .frame(width: 40, height: 40)
                .background(Circle().fill(.white))
                .overlay(Circle().stroke(Theme.inkSoft.opacity(0.18), lineWidth: 1))

            VStack(alignment: .leading, spacing: 1) {
                Text(tip.title)
                    .font(Theme.bold(14))
                    .foregroundColor(Theme.ink)
                Text(tip.detail)
                    .font(Theme.medium(12))
                    .foregroundColor(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - The end of the free pages

/// The card that explains the crown, raised by tapping a locked page or by
/// trying to put something on one.
///
/// It says what is there rather than what is missing: the first pages are the
/// child's, and the crowned ones are what Pro adds. There is no countdown and
/// no nagging — it only ever appears in answer to a tap, and another tap
/// anywhere outside it puts it away.
private struct BookPageGate: View {
    let freePages: Int
    let totalPages: Int
    let onSeePro: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.32)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { Haptics.play(.light); onClose() }

            VStack(spacing: 10) {
                // The same crown lock that sits on the page, so the card is
                // plainly the answer to the thing that was just tapped.
                CrownLock(size: 72)
                    .padding(.top, 4)

                Text("Unlock full sticker book with Pro.")
                    .font(Theme.display(19))
                    .foregroundColor(Theme.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Pages 1–\(freePages) are yours to fill. Pro unlocks pages \(freePages + 1)–\(totalPages), and every sticker in the shop.")
                    .font(Theme.medium(13))
                    .foregroundColor(Theme.inkSoft)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)

                Button {
                    Haptics.play(.light)
                    onSeePro()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill").font(.system(size: 15, weight: .black))
                        Text("See Pro").font(Theme.bold(17))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Capsule().fill(LinearGradient(
                        colors: [Color(red: 1.00, green: 0.85, blue: 0.30),
                                 Color(red: 0.97, green: 0.62, blue: 0.09)],
                        startPoint: .top, endPoint: .bottom)))
                    .overlay(Capsule().stroke(.white.opacity(0.85), lineWidth: 2))
                    .shadow(color: .black.opacity(0.22), radius: 6, y: 3)
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, 6)

                Button {
                    Haptics.play(.light)
                    onClose()
                } label: {
                    Text("Keep looking")
                        .font(Theme.bold(14))
                        .foregroundColor(Theme.inkSoft)
                        .padding(.vertical, 4)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(colors: [
                        Color(red: 1.00, green: 0.99, blue: 0.95),
                        Color(red: 1.00, green: 0.94, blue: 0.96)
                    ], startPoint: .top, endPoint: .bottom))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(.white, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.3), radius: 18, y: 10)
            .padding(.horizontal, 28)
        }
    }
}

// MARK: - Leaf clipping

/// Which half of the spread a leaf is.
private enum LeafSide { case left, right }

/// Clips a spread down the spine so only one leaf shows.
private struct LeafClip: Shape {
    let side: LeafSide

    func path(in rect: CGRect) -> Path {
        let half = rect.width / 2
        let r = side == .left
            ? CGRect(x: rect.minX, y: rect.minY, width: half, height: rect.height)
            : CGRect(x: rect.midX, y: rect.minY, width: half, height: rect.height)
        return Path(r)
    }
}

// MARK: - A single book page

private struct StickerPageView: View {
    let page: Int
    let totalPages: Int
    /// A page beyond the free ones: shown in full, wearing its crown lock,
    /// but not one you can put anything on yet.
    var locked: Bool = false
    /// The text box open for typing, shared so only one is ever open.
    @Binding var editing: UUID?
    var onLockedTap: () -> Void = {}
    @EnvironmentObject private var progress: GameProgress

    /// A soft pastel tint that varies gently from page to page.
    private var pageTint: Color {
        let tints: [Color] = [
            Color(red: 1.00, green: 0.98, blue: 0.92),
            Color(red: 0.94, green: 0.99, blue: 0.95),
            Color(red: 0.95, green: 0.96, blue: 1.00),
            Color(red: 1.00, green: 0.95, blue: 0.97),
            Color(red: 0.98, green: 0.97, blue: 1.00)
        ]
        return tints[page % tints.count]
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // The open two-page book spread (cream paper).
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(pageTint)
                    .overlay(
                        // Soft shadow down the centre — the book's spine/gutter.
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.20), .black.opacity(0.20), .clear],
                            startPoint: .leading, endPoint: .trailing)
                            .frame(width: 40)
                            .blur(radius: 4)
                    )
                    .overlay(
                        // A crisp centre crease line.
                        Rectangle()
                            .fill(.black.opacity(0.10))
                            .frame(width: 1.5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white, lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 14, y: 8)

                // One faint page number per spread, so the book counts the same
                // way the caption underneath it does.
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(page + 1)")
                            .font(Theme.bold(14))
                            .foregroundColor(Theme.inkSoft.opacity(0.30))
                            .padding(.trailing, 22)
                    }
                    .padding(.bottom, 14)
                }

                // Plain paper — stickers go wherever the child wants them.
                // On a crowned page anything already there still shows, it
                // just cannot be picked up: a lapsed subscription should not
                // look like a book that has been emptied.
                Group {
                    ForEach(progress.stickers(onPage: page)) { placed in
                        PlacedStickerView(placed: placed, pageSize: geo.size)
                    }

                    // Text boxes sit above the stickers so they stay readable.
                    ForEach(progress.notes(onPage: page)) { note in
                        PlacedNoteView(note: note, pageSize: geo.size, editing: $editing)
                    }
                }
                .allowsHitTesting(!locked)

                if locked {
                    lockedVeil
                }
            }
        }
    }

    /// What a crowned page wears: a wash of frosted paper, the crown lock
    /// itself, and one line saying which pages these are. The paper colour
    /// still shows through, so it reads as a page of this book that is not
    /// open yet rather than a grey slab dropped over the top of it.
    private var lockedVeil: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.62))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(LinearGradient(
                            colors: [Color(red: 1.00, green: 0.88, blue: 0.45),
                                     Color(red: 0.97, green: 0.66, blue: 0.12)],
                            startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 3)
                )

            VStack(spacing: 8) {
                CrownLock(size: 74)

                Text("Pro Page")
                    .font(Theme.display(17))
                    .foregroundColor(Color(red: 0.55, green: 0.33, blue: 0.02))

                Text("Pages \(StickerBookPages.lockedRange) unlock with Pro")
                    .font(Theme.medium(11))
                    .foregroundColor(Theme.inkSoft)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    Image(systemName: "crown.fill").font(.system(size: 10))
                    Text("Unlock").font(Theme.bold(12))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(LinearGradient(
                    colors: [Color(red: 1.00, green: 0.85, blue: 0.30),
                             Color(red: 0.97, green: 0.62, blue: 0.09)],
                    startPoint: .top, endPoint: .bottom)))
                .overlay(Capsule().stroke(.white.opacity(0.9), lineWidth: 1.5))
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                .padding(.top, 2)
            }
            .padding(.horizontal, 12)
        }
        // The whole page is the button. A child who taps a locked page
        // expects something to happen, and hunting for a small pill is not
        // it — but it stays a tap, never a drag, so turning still works.
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture(perform: onLockedTap)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(page + 1), unlocks with Pro")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - The crown lock

/// The little gold padlock, crown and all, that sits on a page waiting for
/// Pro. Drawn rather than painted so it costs nothing and scales to any page.
private struct CrownLock: View {
    var size: CGFloat = 74

    private var gold: LinearGradient {
        LinearGradient(colors: [
            Color(red: 1.00, green: 0.90, blue: 0.45),
            Color(red: 0.97, green: 0.62, blue: 0.09)
        ], startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        ZStack {
            // A soft pillow so the gold reads against any page tint.
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: size, height: size)
                .shadow(color: Color(red: 0.97, green: 0.62, blue: 0.09).opacity(0.45),
                        radius: size * 0.12, y: size * 0.04)

            Circle()
                .strokeBorder(gold, lineWidth: size * 0.05)
                .frame(width: size, height: size)

            Image(systemName: "lock.fill")
                .font(.system(size: size * 0.46, weight: .black))
                .foregroundStyle(gold)
                .offset(y: size * 0.04)

            // The crown, perched on the rim and tipped a little so it looks
            // put on rather than printed.
            Image(systemName: "crown.fill")
                .font(.system(size: size * 0.32, weight: .black))
                .foregroundStyle(gold)
                .shadow(color: .white, radius: 2)
                .rotationEffect(.degrees(-10))
                .offset(y: -size * 0.46)

            // Two small sparkles, the same ones the shop's epic stickers use.
            Text("✨")
                .font(.system(size: size * 0.20))
                .offset(x: size * 0.42, y: -size * 0.22)
            Text("✨")
                .font(.system(size: size * 0.14))
                .offset(x: -size * 0.44, y: size * 0.26)
        }
        .frame(width: size, height: size * 1.3)
    }
}

// MARK: - A text box the child can move around the page and write in

/// A little card of paper the child drops on a page. Drag it anywhere; tap it
/// to type. Long-press removes it, matching how stickers behave.
private struct PlacedNoteView: View {
    let note: PlacedNote
    let pageSize: CGSize
    @Binding var editing: UUID?
    @EnvironmentObject private var progress: GameProgress

    @State private var dragOffset: CGSize = .zero
    @State private var draft = ""
    @FocusState private var focused: Bool

    /// Enough for a couple of lines in a child's handwriting.
    private let limit = 120

    private var isEditing: Bool { editing == note.id }
    private var boxWidth: CGFloat { max(120, pageSize.width * 0.30) }

    var body: some View {
        let baseX = note.x * pageSize.width
        let baseY = note.y * pageSize.height

        card
            .frame(width: boxWidth)
            .position(x: baseX + dragOffset.width, y: baseY + dragOffset.height)
            // While typing, the box stays put so the drag can't fight the
            // keyboard or the text selection.
            .gesture(isEditing ? nil : dragGesture(baseX: baseX, baseY: baseY))
            .simultaneousGesture(isEditing ? nil : deleteGesture)
            .onAppear {
                draft = note.text
                if isEditing { focused = true }
            }
            .onChange(of: isEditing) { nowEditing in
                if nowEditing {
                    draft = note.text
                    focused = true
                } else {
                    focused = false
                }
            }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 6) {
            if isEditing {
                TextField("Write here…", text: $draft, axis: .vertical)
                    .font(Theme.medium(13))
                    .foregroundColor(Theme.ink)
                    .lineLimit(1...4)
                    .focused($focused)
                    .onChange(of: draft) { value in
                        if value.count > limit {
                            draft = String(value.prefix(limit))
                            return
                        }
                        progress.setNoteText(note.id, text: value)
                    }

                Button("Done") {
                    Haptics.play(.light)
                    progress.setNoteText(note.id, text: draft)
                    editing = nil
                }
                .font(Theme.bold(12))
                .foregroundColor(Color(red: 0.545, green: 0.361, blue: 0.965))
            } else {
                Text(note.text.isEmpty ? "Tap to write…" : note.text)
                    .font(Theme.medium(13))
                    .foregroundColor(note.text.isEmpty ? Theme.inkSoft : Theme.ink)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.didYouKnow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isEditing ? Color(red: 0.545, green: 0.361, blue: 0.965)
                                  : Theme.inkSoft.opacity(0.35),
                        lineWidth: isEditing ? 2 : 1.5)
        )
        .shadow(color: .black.opacity(0.18), radius: 5, y: 3)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                Haptics.play(.light)
                editing = note.id
            }
        }
    }

    private func dragGesture(baseX: CGFloat, baseY: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in dragOffset = value.translation }
            .onEnded { value in
                let nx = clamp((baseX + value.translation.width) / pageSize.width)
                let ny = clamp((baseY + value.translation.height) / pageSize.height)
                dragOffset = .zero
                progress.moveNote(note.id, x: nx, y: ny)
            }
    }

    private var deleteGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.6)
            .onEnded { _ in
                Haptics.play(.success)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    progress.removeNote(note.id)
                }
            }
    }

    private func clamp(_ v: CGFloat) -> Double {
        Double(min(max(v, 0.08), 0.92))
    }
}

// MARK: - A placed sticker the child can move, resize and remove

private struct PlacedStickerView: View {
    let placed: PlacedSticker
    let pageSize: CGSize
    @EnvironmentObject private var progress: GameProgress

    @State private var dragOffset: CGSize = .zero
    @State private var liveScale: CGFloat = 1

    private var sticker: Sticker? { StickerCatalog.byID[placed.stickerID] }

    var body: some View {
        if let sticker {
            let baseX = placed.x * pageSize.width
            let baseY = placed.y * pageSize.height

            StickerGlyph(sticker: sticker, size: 74)
                .scaleEffect(CGFloat(placed.scale) * liveScale)
                .position(x: baseX + dragOffset.width, y: baseY + dragOffset.height)
                .gesture(
                    DragGesture()
                        .onChanged { value in dragOffset = value.translation }
                        .onEnded { value in
                            let nx = clamp((baseX + value.translation.width) / pageSize.width)
                            let ny = clamp((baseY + value.translation.height) / pageSize.height)
                            dragOffset = .zero
                            progress.updatePlaced(placed.id, x: nx, y: ny,
                                                  scale: placed.scale, rotation: placed.rotation)
                        }
                )
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in liveScale = value }
                        .onEnded { value in
                            let newScale = min(max(placed.scale * Double(value), 0.5), 2.6)
                            liveScale = 1
                            progress.updatePlaced(placed.id, x: placed.x, y: placed.y,
                                                  scale: newScale, rotation: placed.rotation)
                        }
                )
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.6)
                        .onEnded { _ in
                            Haptics.play(.success)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                progress.removePlaced(placed.id)
                            }
                        }
                )
        }
    }

    private func clamp(_ v: CGFloat) -> Double {
        Double(min(max(v, 0.05), 0.95))
    }
}

// MARK: - Sticker shop

struct StickerShopSheet: View {
    @EnvironmentObject private var progress: GameProgress
    @Environment(\.dismiss) private var dismiss

    /// Called when the child taps an owned sticker to place it in the book.
    let onPlace: (Sticker) -> Void

    /// The category being browsed, or nil while choosing a category.
    @State private var selected: StickerCategory?

    /// Raised by tapping a sticker that needs Pro.
    @State private var showPro = false

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: 14)]

    var body: some View {
        VStack(spacing: 12) {
            topBar

            if let category = selected {
                stickerList(category)
            } else {
                categoryList
            }
        }
        .sheet(isPresented: $showPro) {
            ProUnlockView(reason: .sticker)
        }
        .background(Theme.homeBackground.ignoresSafeArea())
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            if selected != nil {
                Button {
                    Haptics.play(.light)
                    withAnimation(.easeInOut(duration: 0.2)) { selected = nil }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(Theme.bold(16))
                        .foregroundColor(Theme.ink)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.black.opacity(0.06)))
                }
            }

            Text(selected?.name ?? "Sticker Shop")
                .font(Theme.display(22))
                .foregroundColor(Theme.ink)

            Spacer()

            HStack(spacing: 5) {
                GemIcon(size: 18)
                Text("\(progress.gems)")
                    .font(Theme.bold(15))
                    .foregroundStyle(Theme.gemPink)
            }
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(Capsule().fill(Color.black.opacity(0.06)))
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
    }

    private var categoryList: some View {
        VStack(spacing: 14) {
            Text("Pick a collection to explore!")
                .font(Theme.medium(13))
                .foregroundColor(Theme.inkSoft)

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(StickerCatalog.categories) { category in
                        categoryCard(category)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
        }
    }

    private func categoryCard(_ category: StickerCategory) -> some View {
        Button {
            Haptics.play(.light)
            withAnimation(.easeInOut(duration: 0.2)) { selected = category }
        } label: {
            HStack(spacing: 14) {
                Text(category.emoji).font(.system(size: 44))
                VStack(alignment: .leading, spacing: 3) {
                    Text(category.name)
                        .font(Theme.display(20))
                        .foregroundColor(Theme.ink)
                    Text("\(category.count) stickers")
                        .font(Theme.medium(13))
                        .foregroundColor(Theme.inkSoft)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(Theme.bold(16))
                    .foregroundColor(Theme.inkSoft)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func stickerList(_ category: StickerCategory) -> some View {
        VStack(spacing: 8) {
            Text("Buy stickers with your gems, then tap one to stick it in your book!")
                .font(Theme.medium(13))
                .foregroundColor(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            ScrollView {
                if !category.cute.isEmpty {
                    section(title: "🌸 Cute Collection",
                            subtitle: "50 gems each",
                            stickers: category.cute)
                }

                if !category.epic.isEmpty {
                    section(title: "✨ Epic Collection",
                            subtitle: "100 gems each",
                            stickers: category.epic)
                        .padding(.top, 4)
                }
            }
        }
    }

    private func section(title: String, subtitle: String, stickers: [Sticker]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(title).font(Theme.display(18)).foregroundColor(Theme.ink)
                Text(subtitle)
                    .font(Theme.bold(12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 3)
                    .background(Capsule().fill(Theme.inkSoft.opacity(0.8)))
                Spacer()
            }
            .padding(.horizontal, 18)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(stickers) { shopCell($0) }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
        }
    }

    private func shopCell(_ sticker: Sticker) -> some View {
        let owned = progress.owns(sticker)
        let locked = progress.needsPro(sticker)
        let affordable = progress.gems >= sticker.cost

        return VStack(spacing: 8) {
            // A locked sticker is still shown in full, only dimmed. The whole
            // point of leaving the book open is that a child can see what is
            // on the shelves; hiding them would make the shop a wall.
            StickerGlyph(sticker: sticker, size: 58)
                .opacity(owned || (affordable && !locked) ? 1 : 0.5)
                .grayscale(owned || (affordable && !locked) ? 0 : 0.6)

            if owned {
                Label("Place", systemImage: "hand.tap.fill")
                    .font(Theme.bold(12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(Capsule().fill(Theme.correct))
            } else if locked {
                // A price it cannot pay would be a lie, so it shows the reason
                // instead.
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill").font(.system(size: 11, weight: .bold))
                    Text("PRO").font(Theme.bold(12))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(Capsule().fill(Color(red: 0.93, green: 0.55, blue: 0.16)))
            } else {
                HStack(spacing: 4) {
                    GemIcon(size: 15)
                    Text("\(sticker.cost)")
                        .font(Theme.bold(13))
                        .foregroundStyle(affordable ? AnyShapeStyle(Theme.gemPink)
                                                    : AnyShapeStyle(Theme.inkSoft))
                }
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(Capsule().fill(Color.white.opacity(0.85)))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(owned ? Theme.correct.opacity(0.6)
                        : locked ? Color(red: 0.93, green: 0.55, blue: 0.16).opacity(0.5)
                        : .white,
                        lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if owned {
                onPlace(sticker)
                dismiss()
            } else if locked {
                Haptics.play(.light)
                showPro = true
            } else if affordable {
                Haptics.play(.success)
                progress.buySticker(sticker)
            } else {
                Haptics.play(.error)
            }
        }
    }
}

#Preview {
    StickerBookView().environmentObject(GameProgress())
}
