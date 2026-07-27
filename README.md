---

# 🎮 R7RS Scheme Tetris Worlds Engine

An object-oriented implementation of **Tetris Worlds** written in modular **R7RS Scheme**. Developed as part of the *Programmeerproject 1* curriculum at the **Vrije Universiteit Brussel (VUB)** (Academic Year 2024–2025), this engine explores message-passing Abstract Data Types (ADTs), functional design patterns, custom physics, and interactive graphics engines.

---

## 🌟 Features & Game Modes

The engine features a fully functional main menu with individual state and high-score tracking across three distinct game modes:

### 🕹️ Game Modes

* **Classic Tetris:** Traditional Tetris experience with line-clear animations, level scaling, piece preview queueing, and standard scoring.


* **Bomb Tetris:** Spawns single 1x2 explosive **`B`** Tetrominoes. Includes a 20-second active countdown timer. If a line clear includes an unexploded bomb, it clears surrounding rows as a bonus. Uncleared bombs detonate in a $2 \times 2$ grid radius.


* **Gravity Tetris:** Features structural physics mechanics. Unsupported floating blocks ("zwevende blokken") automatically fall downward due to gravity, allowing cascade line clears.



### 🛠️ Core Gameplay Mechanics

* **Hold System (`Vasthouden`):** Swap and hold a Tetromino for tactical deployment using `H` or `Shift`.


* **Piece Preview (`Voorvertoning`):** Displays a live queue of the next 3 upcoming Tetrominoes.


* **Level Progression:** Dynamic level scaling that speeds up block drop rates every 10 cleared lines.


* **High Score System:** Persistent score and high-score tracking per game mode on the main menu interface.


* **Custom Graphics & Animations:** Built using the VUB `pp1 graphics` engine with line-highlighting flashing effects before line deletion.



---

## 🏗️ Project Architecture & ADTs

The project is structured into modular Abstract Data Types (ADTs) using closure-based message passing (`dispatch` procedures) to achieve clean Object-Oriented Programming (OOP) in Scheme:

```text
├── start.rkt          # Main execution entry point[cite: 4]
├── spelwereld.rkt     # Central controller ADT (Game loop, state updates, key inputs)[cite: 3, 17]
├── speelveld.rkt      # Grid playfield ADT (Collision, line removal, gravity, bombs)[cite: 2, 17]
├── tetromino.rkt      # Tetromino ADT (Piece shapes, coordinates, rotation matrices)[cite: 7, 17]
├── teken.rkt          # Drawing ADT (Renders layers, sprites, menu UI via pp1 graphics)[cite: 6, 17]
├── voorvertoning.rkt  # Piece Preview ADT (3-piece random queue generator)[cite: 9, 17]
├── vasthouden.rkt     # Hold Queue ADT (Piece storage & swapping)[cite: 8, 17]
├── status.rkt         # State Manager ADT (Tracks global and mode states)[cite: 5, 17]
├── score.rkt          # Score ADT (Tracks active and mode high scores)[cite: 1, 17]
├── level.rkt          # Level ADT (Calculates line clear progression and fall thresholds)[cite: 12, 13, 17]
├── animatie.rkt       # Line Clear Animation ADT (Flash layer timing control)[cite: 10, 14, 17]
├── data.rkt           # Dynamic mode dynamic binder/configuration module[cite: 11, 17]
├── game-data.rkt      # Helper procedures, grid state vectors, timer utilities[cite: 2, 12]
└── constanten.rkt     # Global constants, colors, window dimensions, piece matrix data[cite: 6, 15]

```

### Dependency Flow

```text
                  +-------------------+
                  |   pp1 graphics    |
                  +---------+---------+
                            ^
                            |
+-----------+     +---------+---------+     +-----------+
| Speelveld +---->|      Teken        +---->|   Status  |
+-----+-----+     +---------+---------+     +-----+-----+
      |                     ^                     ^
      v                     |                     |
+-----+-----+     +---------+---------+           |
| Animatie  |<----+    Spelwereld     +-----------+
+-----------+     +----+----+----+----+
                       |    |    |
       +---------------+    |    +---------------+
       |                    v                    |
+------+----+     +---------+---------+    +-----+-----+
|   Level   |     |    Vasthouden     |    |   Score   |
+-----------+     +-------------------+    +-----------+
                            |
                            v
                  +---------+---------+
                  |    Tetromino      |
                  +-------------------+

```

---

## ⌨️ Controls & Keybindings

| Key | Context | Function |
| --- | --- | --- |
| `Enter` / `Return` | Main Menu | Start **Classic Tetris**<br> |
| `Z` | Main Menu | Start **Bomb Tetris**<br> |
| `G` | Main Menu | Start **Gravity Tetris**<br> |
| `Left` / `Right` | In-Game | Move Tetromino left / right

 |
| `Down` | In-Game | Soft Drop (Accelerate downward)

 |
| `Space` | In-Game | Hard Drop (Instant drop to floor)

 |
| `R` / `X` | In-Game | Rotate Tetromino 90° clockwise

 |
| `H` / `Shift` | In-Game | Hold / Swap current piece

 |
| `B` | Game Over | Return to Main Menu

 |

---

## ⚙️ Installation & Running

### Prerequisites

* [Racket](https://racket-lang.org/) (v8.0 or newer recommended)


* `r7rs` library package enabled in DrRacket / Racket environment


* `pp1 graphics` library provided in course workspace



### Execution

1. Clone the repository:
```bash
git clone https://github.com/yourusername/r7rs-scheme-tetris.git
cd r7rs-scheme-tetris

```


2. Run the main entry point file:
```bash
racket start.rkt

```


*Alternatively, open `start.rkt` in DrRacket and click **Run**.*

---

## 📄 Academic Context

* **Course:** Programmeerproject 1 (2024–2025)


* **Institution:** Vrije Universiteit Brussel (VUB) — Faculty of Science, Computer Science Department


* **Supervisors:** Prof. Dr. Elisa Gonzalez Boix, Bjarno Oeyen, Carlos Rojas Castillo
