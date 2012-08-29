CREATE TABLE deck (
    deck_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    notes TEXT
);

CREATE TABLE deck_card_map (
    deck_id INTEGER,
    card_id INTEGER
);
