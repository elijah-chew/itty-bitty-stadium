# Itty Bitty Stadium

Build a football stadium.

The player owns a bare plot and constructs a ground piece by piece: pitch, goals, stands, a gym, a hotel, and the other club buildings. The stadium is the game. A valid ground can host a match. Each league above the kickabout asks for something the last league did not: a changing room, then a training gym, then amenities, then a club hotel, then a home jersey. The payout buys the next piece.

Audience is kids to teens. The sport is association football (soccer). The menu layout follows a venue-builder: a title card, a save slot, a world HUD, and a sidebar for events, objectives, sponsors, upgrades, and kits. This is not a race track, and it is not a playable 22-player match.

Six players share a server. Each has a plot. Others may look. They cannot edit your ground or take your cash. The board ranks lifetime reputation.

## Verbs

- **Claim** a plot. The player picks one of the six plots. A taken plot stays taken. Choosing again returns the plot you already own. A new profile starts with 12,000 cash, 0 fans, 0 reputation, and an empty 12 by 16 grid.
- **Place** a piece on an empty in-bounds cell. Grass, stands, and buildings occupy one cell. A goal also stores a facing: north, east, south, or west. The cell must be empty and the player must afford the cost.
- **Remove** a piece. The full cost is refunded. The build stays editable, including while a match is counting down. The match result uses the stadium as it was at kickoff.
- **Expand** the land. Each expansion adds a strip 4 cells wide on the east side and costs 5,000, then 12,000, then 25,000. The fourth expansion fails. Width goes from 12 to 24. Height stays 16.
- **Host** a named competition, or ask for the best one the stadium currently qualifies for. A second host fails while a match is in progress. After 30 seconds the match pays out.
- **Claim an objective** once its condition is true. Claiming twice fails.
- **Own 2x Money.** A profile flag. It changes the next cash payout. It does not rewrite the current balance.
- **Buy a cash pack.** A fixed cash grant, once per purchase id.
- **Buy a jersey** and wear it. Home Stripes costs 4,000, Gold Hoops costs 12,000, and the Night Kit costs 25,000. The cup final refuses a club with no jersey. Buying another kit replaces the one you wear.

Sponsor rewards are not a separate verb. They pay automatically on the match that finishes the contract.

## Pieces

| Piece | Cost | Effect |
| --- | --- | --- |
| Grass | 250 | Pitch cell. A 5v5 pitch of grass is 6,000 |
| Goal | 1,500 | Required in a pair, with a facing |
| Small stand | 2,500 | Straight section on the touchline, +1,000 seats |
| Medium stand | 6,000 | Straight section, +3,000 seats |
| Corner stand | 3,500 | 90 degree corner of the bowl, +800 seats |
| Angle stand | 3,000 | Kink at the end of a side, +1,200 seats |
| Changing room | 4,000 | Facility for Sunday league |
| Floodlights | 8,000 | Facility for the regional cup |
| Ticket office | 5,000 | Facility for the national league |
| Medical room | 7,500 | Facility for the national league |
| Scoreboard | 10,000 | Facility for the cup final |
| Club shop | 12,000 | Facility for the cup final |
| Training gym | 15,000 | Facility for the town club |
| Amenities | 20,000 | Canteen, physio, and lounge. Facility for the regional cup |
| Club hotel | 35,000 | Facility for the national league |
| Food stand | 2,000 | Matchday food. Pays 200, plus 100 for every 50 people in attendance |

Stands and buildings sit off the grass because a cell holds one piece. Several stands add their capacity together. One of each facility is enough. Extras still count as having that facility.

## A valid pitch

All grass cells form one solid rectangle. The bounding box is full: no holes, no second blob of grass.

The rectangle is at least 4 by 6, which is a 5v5 pitch. A 7v7 pitch is at least 6 by 10. An 11v11 pitch is at least 8 by 14. A bigger pitch can host a smaller game. Town club and every league above it require 11v11.

Exactly two goals sit centered on the short ends, one cell outside the grass, facing the pitch.

- If the pitch is taller than it is wide, the short ends are the north and south edges. The center column is `minX + floor((width - 1) / 2)`. The north goal faces south. The south goal faces north.
- If the pitch is wider than it is tall, the short ends are the west and east edges. The center row uses the same centering rule. The west goal faces east. The east goal faces west.
- If the pitch is square and still at least 4 by 6, either opposite pair is accepted.

Any other goal count, position, or facing makes the pitch invalid. A goal cell that would fall outside the grid is invalid, so the pitch cannot touch the border on its short ends.

## Attendance and fans

Capacity is the sum of the stands. A small stand holds 1,000. A medium stand holds 3,000. Attendance is the lower of capacity and current fans, so an empty giant ground does not sell out. Ticket cash is one ticket price for every 50 people in attendance, rounded down. A full small stand still pays about what it did when the seats were counted in the tens.

Fans gained when a match pays is the greater of that competition's minimum fans and `floor(attendance / 2)`. Only the kickabout has a minimum, and it is 5, so the first match still finds an audience. Later competitions grow fans from attendance alone.

## Competitions

Host a named competition, or leave the name empty. An empty name hosts your current league, or a kickabout if the club is not founded yet. You can only play league fixtures in the division you are in.

Every tier has its own gate. The event panel lists what is still missing: the pitch, the seat count, each building, and the jersey when that tier asks for one.

| Competition | Needs | Capacity | Base cash | Ticket price | Win bonus | Minimum new fans |
| --- | --- | --- | --- | --- | --- | --- |
| Kickabout | A valid pitch | 0 | 400 | 20 | 200 | 5 |
| Sunday league | Changing room | 1,000 | 800 | 50 | 400 | 0 |
| Town club | Training gym | 2,500 | 1,200 | 80 | 600 | 0 |
| Regional cup | Floodlights and amenities | 4,000 | 1,500 | 100 | 800 | 0 |
| National league | Ticket office, medical room, and club hotel | 10,000 | 3,000 | 200 | 1,500 | 0 |
| Cup final | Scoreboard, club shop, and a home jersey. Premier clubs only | 20,000 | 6,000 | 400 | 3,000 | 0 |
| Premier league | Scoreboard, club shop, and a home jersey | 20,000 | 8,000 | 500 | 4,000 | 0 |

A match lasts 30 seconds. The scoreline is seeded from the kickoff venue: pitch width, pitch height, capacity, the set of facilities, and the jersey. The same seed and the same venue always produce the same score. Each side scores 0 to 5. Home goals greater than away is a win. Equal goals is a draw.

Cash paid at the whistle is `(base cash + ticket cash + win bonus) × money multiplier`. The win bonus is 0 unless the home side wins. Fans and reputation are not multiplied.

Reputation for every competition: win +2, draw +1, loss +0. Lifetime reputation adds the same positive amount and is what the board ranks.

## Building the bowl

Stands do not sit in the middle of the grass. They snap to the ring around a valid pitch.

- A click on the pitch, or one cell off a legal slot, snaps to that slot. The stand is turned to face the grass. You cannot face it outward.
- **Straight** sections run along a touchline or a goal line. A small straight holds 1,000. A large straight holds 3,000.
- **Corners** snap to the four diagonal cells outside the pitch corners. A corner holds 800.
- **Angles** snap to the first and last cell of each side, so the bowl can kink instead of turning only on a sharp corner. An angle holds 1,200.
- A piece that is more than one cell from a slot of its shape is rejected. Club buildings (the gym, the hotel, the amenities) sit off that ring.

## Your club and the pyramid

Founding a club needs a Sunday-ready ground, a name of 3 to 24 letters, and two colours from navy, white, red, gold, green, and black. The new club starts in the Sunday league.

A season is 6 matches in your current league. A win is 3 points, a draw is 1. Kickabout friendlies and the cup final do not count. You can host a league match only in the league you are in.

| League | After 6 matches |
| --- | --- |
| Sunday | 12 or more points promotes to the town club. No relegation. |
| Town, regional, national | 12 or more promotes, if the next ground is already built. 4 or fewer relegates one tier. |
| Premier | 4 or fewer relegates to the national league. There is no league above it. |

Promotion into a league still needs that league's buildings, seats, and jersey. Points alone do not skip a missing gym or hotel. The cup final can be hosted only while the club is in the premier league.

## Making the club pay

Tickets are not the only income.

- Each food stand pays 200 on a match, plus 100 for every 50 people in attendance.
- A club shop pays 400 in merch, plus 80 for every 100 fans. The jersey you are wearing adds 250.
- 2x Money doubles that income with the rest of the match payout.

Side tasks can be finished once per hosted match, then again after the next match:

| Task | Needs | Cash |
| --- | --- | --- |
| Run the grill | A food stand | 800 |
| Fold the shirts | The club shop | 1,200 |
| Kids' coaching | Nothing | 350 |

## Pitch expansion pass

Kickabout is 5v5. Sunday league is 7v7. Every league after that is 11v11.

The grass for an 11v11 pitch, at least 8 by 14, cannot be placed until the Pitch Expansion game pass is owned. The pass is permanent. It does not change cash already in the balance. Its dashboard id stays 0 until the pass exists. 5v5 and 7v7 pitches do not need it.

## Sponsors

Three contracts are active from the start. They pay once, on the match that brings hosted matches to the required count. The grant is multiplied by 2x Money. They do not pay fans or reputation.

| Contract | Matches hosted | Cash |
| --- | --- | --- |
| Two | 2 | 2,000 |
| Four | 4 | 5,000 |
| Six | 6 | 12,000 |

## Objectives

Each can be claimed once, after the condition is true. Cash is multiplied by 2x Money. Reputation is not.

| Objective | Condition | Cash | Reputation |
| --- | --- | --- | --- |
| Host a match | At least one match has paid out | 1,000 | 1 |
| Build a stand | At least one small or medium stand is on the grid | 1,500 | 1 |
| Expand once | Land has been expanded at least once | 2,000 | 1 |

## Monetisation

Robux prices are set on the Creator Dashboard. The simulation stores the cash each product grants, not the Robux price. The game pass id and the developer product ids stay 0 until those dashboard items exist.

**2x Money** is a permanent game pass, bought once. The profile flag `doubleMoney` makes the cash multiplier 2. Otherwise it is 1. The multiplier applies to match cash, sponsor cash, objective cash, and cash packs. Turning the flag on does not change cash already in the balance. A match still in its 30 seconds uses the multiplier at the whistle, which is the next payout.

**Cash packs** are repeatable developer products.

| Pack | Base cash | With 2x Money |
| --- | --- | --- |
| Small sack | 10,000 | 20,000 |
| Club chest | 50,000 | 100,000 |
| Stadium vault | 250,000 | 500,000 |

A purchase id grants cash once. The same id a second time does not pay again. An unknown product does not change cash and is not processed. Packs are a fixed amount of cash. There are no random paid crates.

## Screens

The menu is a dark sidebar and a cream page, with blue for the main action, green for start, and red for build. Labels are the club, not a race track.

1. **Title.** The stadium is blurred behind the name, a version line, and three buttons: Play, Changelog, Shop.
2. **Your club.** One save card shows the club name, cash, fans, and matches hosted, with Continue. A second slot starts a new club. A third slot is a Robux unlock. Each club saves on its own.
3. **Select a plot.** Six plots in the lobby. An open plot can be claimed. A taken plot shows that it is owned and cannot be selected. Confirming an open plot puts you on that ground. Coming back selects the same plot again.
4. **Ground.** Cash, fans, Shop, and Help sit along the top. The next fixture sits in the middle. A club card on the right says which league is ready and which building is still missing. Along the bottom: Club, Events, Build.
5. **Events.** The sidebar is Overview, Events, Objectives, Sponsors, Upgrades, Customise. Each league is a row. The open league lists what you still need, the payout, and Start. A league with a missing gym, hotel, or jersey stays closed.
6. **Objectives.** Groups of goals, each with cash and reputation, and a count of how many are done.
7. **Sponsors.** One contract at a time would be the later screen. This slice still pays the three match-count contracts from the table above.
8. **Upgrades.** Big buildings are bought once, then placed: gym, amenities, hotel, main stand. Placing is free after you own it. This slice still charges when the piece is placed.
9. **Customise.** Club name, colours, and the three jerseys. The worn jersey is what the cup final checks.
10. **Overview.** A small map of the pitch, seats, reputation, the current league, and the next missing requirement.
11. **Build.** A bar along the bottom: Pitch, Stands, Buildings, Scenery. The selected piece shows its cost. Rotate, remove, expand land, and a seat count stay on screen.
12. **Shop.** The cash packs, with the Robux price coming from the Creator Dashboard.

## Left out

A playable 22-player match, transfers, American football, and offline earnings. The menu and the six plots are created when you press Play. A club save lasts for that server visit. The store description stays with the owner.
