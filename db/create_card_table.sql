CREATE TABLE card (
    card_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    description TEXT,
    flavor_text TEXT,
    type TEXT,
    subtype TEXT,
    power TEXT,
    toughness TEXT,
    generic_mana INTEGER,
    specific_mana TEXT,
    converted_mana INTEGER,
    edition TEXT,
    rarity TEXT,
    quantity INTEGER,
    notes TEXT
);
