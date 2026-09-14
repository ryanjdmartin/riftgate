# Concept intake

Drop rough concepts here, in batches, by category. Batches of five to ten vet best because
balance is relative within a category.

Flow:

1. Write a batch file in the right folder, e.g. `components/batch-01-halvard-melee.md`,
   using `TEMPLATE.md`. Fantasy first, numbers second. Rough is fine.
2. Ask for the batch to be vetted. Each entry comes back as keep, revise, or cut, with the
   reason, checked against four things: does it break a design test, does it duplicate
   something already in the set, does it pose or answer a real question rather than being a
   stat line, and does it create or break a synergy with what exists.
3. Vetted entries are written into `content/*.json`. The validator in the test suite enforces
   the bible's rules automatically, so a concept that breaks one fails the build.
4. New mechanic terms go into `content/vocabulary.json` first, with status `planned` or `idea`,
   and `docs/vocabulary.md` is regenerated.

Folders:

- `chassis/` silhouettes, stats, passives, makers
- `components/` faces and component passives
- `foes/` enemies inside a skirmish, and the question each poses
- `factions/` signatures, answers, rosters, injuries, reward bias
- `mechanics/` new keywords, statuses, triggers, and anything for the vocabulary
