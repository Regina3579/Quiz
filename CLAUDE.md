# QuizSpark — Project Notes

A kid-friendly (ages 7+) iOS quiz game built in SwiftUI, structured as an
**Adventure Map** of islands. Each island has a winding trail of **10 levels**,
and each level has **10 questions**. Clearing a level earns up to 3 stars and
unlocks the next; completing an island unlocks the next island. Progress is
saved via `GameProgress` (UserDefaults).

## Question authoring rules (ALWAYS follow these)

When adding or editing quiz content in `QuizApp/Data/QuizData.swift`:

1. **Structure:** every island has 10 levels; every level has exactly 10
   questions with 4 options each.
2. **Difficulty ladder (per level, ALWAYS):** difficulty ramps up across the
   10 levels of every island. Base everything on a 7+ year old.
   - **Levels 1–2 — Normal:** everyday facts, not baby-easy but comfortable.
   - **Levels 3–5 — Medium-hard:** needs some thinking; less obvious facts.
   - **Levels 6–8 — Hard:** specific names, numbers, and deeper facts.
   - **Levels 9–10 — Very hard:** genuinely challenging, precise, expert-for-kids.
   Use real, well-researched facts (real names, real numbers). No trick
   questions — hard should mean "more knowledge required," not "confusing."
3. **Uniqueness:** no duplicate questions within an island. Vary the topics
   across the 10 levels (sub-themes) so it feels like a journey.
4. **Explanations:** every question gets a rich explanation of about
   **4–6 lines (~40–55 words)** written warmly for kids — a mini fun-fact
   paragraph, not a single line. It appears in the "Did you know?" box.
   **Do NOT restate the answer.** Teach an interesting fact ABOUT the answer.
   Bad: "The tallest animal is the giraffe." Good: "A giraffe's neck can be
   2 metres long, yet it has only seven neck bones — the same as you!"
   Assume the child already knows the correct choice; tell them something new.
5. **Answer-position mixing (IMPORTANT):** the correct answer must NOT always
   be option A. Spread correct answers roughly equally across A/B/C/D. The
   same position may repeat **twice in a row occasionally**, but **never three
   or more times in a row**. Do not rely on runtime shuffling — bake the
   varied `correctIndex` into the data itself.
   - A helper approach: author with the correct answer first, then run a
     redistribution pass that moves each correct answer to a target position
     following a balanced, no-3-in-a-row pattern (see git history for the
     script used on the first four islands).
6. **Strings:** use single quotes `'...'` for any quotation *inside* an
   explanation or prompt (the Swift string literal uses double quotes).

## Validation before committing content

- Confirm 10 levels / 100 questions per finished island.
- Confirm every question has 4 options and a valid `correctIndex` (0–3).
- Confirm the correct-answer position distribution is balanced (A/B/C/D each
  used a similar number of times) with no run of 3+ identical positions.
- Confirm the file's braces/parens/brackets balance and quote count is even.

## Islands (map order) & status

1. 🦁 Jungle Kingdom — ✅ 10 levels
2. 🚀 Galaxy Quest — ✅ 10 levels
3. 🦖 Dino Valley — ✅ 10 levels (rich explanations)
4. 🐬 Ocean Paradise — ✅ 10 levels (rich explanations)
5. 🧭 Explorer's Trail — ✅ 10 levels (rich explanations)
6. 🌺 Blossom Garden — ✅ 10 levels (rich explanations)
7. 🔬 Science Lab — ✅ 10 levels (rich explanations)
8. 🏰 Brain Castle — ✅ 10 levels (rich explanations)
9. 👑 Ancient Kingdom — ✅ 10 levels (rich explanations)
10. 🏆 Champion's Summit — ✅ 10 levels (mixed grand challenge, rich explanations)

## Xcode project note

The project uses the classic explicit `project.pbxproj` format. **New Swift
files must be registered** in `QuizApp.xcodeproj/project.pbxproj` (add a
PBXBuildFile, PBXFileReference, the group child, and the Sources build-phase
entry) or they won't compile. Files added inside `Assets.xcassets` do NOT need
project edits.
