# One idea's trip through Level Room

Each step names who acts, in which room, and what they are allowed to do.

1. **Someone posts an idea** in the public `arcade` room:
   `idea: a harbour at night where cranes block two lanes at a time`

2. **Scorekeeper** (custom, no model) takes the text after `idea:`, strips
   mentions, links and code, caps the length, and posts it in the private
   `workshop` as `New idea from <person>: "<idea>"`. Nothing from the arcade
   reaches the workshop in any other way.

3. **Designer** (Claude, read-only tools) replies with one sentence and one
   ```json block: a whole `level-room/1` level.

4. **Checker** (custom, no model) answers in the thread:
   - structure checks (segment lengths, obstacle spacing, climbs, limits);
   - a search over the game's own simulation for a clean run inside the time
     limit;
   - difficulty 1–10, the clean-run time, and a PNG map with the run drawn on.
   On **FAIL** it lists each problem with where it is and how to fix it, and
   mentions the Designer, who posts a corrected level (at most three tries).
   On **PASS** it saves the level as `data/candidates/<slug>.json` and
   mentions the Publisher with `publish <slug>`.

5. **Publisher** (Claude, Bash allowed but auto mode off) reads the candidate
   and asks to run `node tools/publish.js data/candidates/<slug>.json --json`.
   **The owner approves** the command in the thread. Publish refuses anything
   that fails the check, gives each version its own link, and links a "v2" to
   the version before it.

6. **Scorekeeper** sees the new publication and posts the link, a QR code and
   the map in the `arcade`.

7. **People play.** Every finished run is posted to the results endpoint
   (time, coins, falls and hits with the exact track position). The owner
   can also ask the Publisher for `playtest <slug>`: 30 simulated players,
   marked as simulated.

8. **Scorekeeper reports** after a quiet spell or a batch of runs: plays,
   finish rate, clean-run rate, times, and the trouble spots tied to a track
   segment. If people struggle (finish under 80%, clean runs under 60%, or
   one spot catching a quarter of runs) it asks the Designer for a v2.

9. **Designer** posts a v2 that changes only those spots and says what it
   changed. The trip repeats from step 4, and the next report compares v2
   with v1.
