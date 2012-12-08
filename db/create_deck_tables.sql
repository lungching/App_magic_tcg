CREATE TABLE deck (
    deck_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    notes TEXT
);

CREATE TABLE deck_card_map (
    map_id INTEGER PRIMARY KEY AUTOINCREMENT,
    deck_id INTEGER,
    card_id INTEGER,
    quantity INTEGER,
    is_sideboard INTEGER
);
