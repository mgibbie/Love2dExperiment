# Generate Tarot files
$tarots = @{
    "c_fool" = @{key="c_fool";name="The Fool";order=1;pos=@{x=0;y=0};set="Tarot";cost=3;effect="last_tarot";description="Creates the last Tarot or Planet card used during this run"}
    "c_magician" = @{key="c_magician";name="The Magician";order=2;pos=@{x=1;y=0};set="Tarot";cost=3;config=@{mod_conv="m_lucky";max_highlighted=2};effect="Enhance";description="Enhances 1 selected card into a Lucky Card"}
    "c_high_priestess" = @{key="c_high_priestess";name="The High Priestess";order=3;pos=@{x=2;y=0};set="Tarot";cost=3;config=@{planets=2};effect="Round Bonus";description="Creates up to 2 random Planet cards"}
    "c_empress" = @{key="c_empress";name="The Empress";order=4;pos=@{x=3;y=0};set="Tarot";cost=3;config=@{mod_conv="m_mult";max_highlighted=2};effect="Enhance";description="Enhances 1 selected card into a Mult Card"}
    "c_emperor" = @{key="c_emperor";name="The Emperor";order=5;pos=@{x=4;y=0};set="Tarot";cost=3;config=@{tarots=2};effect="Round Bonus";description="Creates up to 2 random Tarot cards"}
    "c_heirophant" = @{key="c_heirophant";name="The Hierophant";order=6;pos=@{x=5;y=0};set="Tarot";cost=3;config=@{mod_conv="m_bonus";max_highlighted=2};effect="Enhance";description="Enhances up to 2 selected cards into Bonus Cards"}
    "c_lovers" = @{key="c_lovers";name="The Lovers";order=7;pos=@{x=6;y=0};set="Tarot";cost=3;config=@{mod_conv="m_wild";max_highlighted=1};effect="Enhance";description="Enhances 1 selected card into a Wild Card"}
    "c_chariot" = @{key="c_chariot";name="The Chariot";order=8;pos=@{x=7;y=0};set="Tarot";cost=3;config=@{mod_conv="m_steel";max_highlighted=1};effect="Enhance";description="Enhances 1 selected card into a Steel Card"}
    "c_justice" = @{key="c_justice";name="Justice";order=9;pos=@{x=8;y=0};set="Tarot";cost=3;config=@{mod_conv="m_glass";max_highlighted=1};effect="Enhance";description="Enhances 1 selected card into a Glass Card"}
    "c_hermit" = @{key="c_hermit";name="The Hermit";order=10;pos=@{x=9;y=0};set="Tarot";cost=3;config=@{extra=20};effect="Dollar Doubler";description="Doubles money (Max `$20)"}
    "c_wheel_of_fortune" = @{key="c_wheel_of_fortune";name="The Wheel of Fortune";order=11;pos=@{x=0;y=1};set="Tarot";cost=3;config=@{extra=4};effect="Round Bonus";description="1 in 4 chance to add Foil, Holographic, or Polychrome edition to a random Joker"}
    "c_strength" = @{key="c_strength";name="Strength";order=12;pos=@{x=1;y=1};set="Tarot";cost=3;config=@{mod_conv="up_rank";max_highlighted=2};effect="Round Bonus";description="Increases rank of up to 2 selected cards by 1"}
    "c_hanged_man" = @{key="c_hanged_man";name="The Hanged Man";order=13;pos=@{x=2;y=1};set="Tarot";cost=3;config=@{max_highlighted=2};effect="Round Bonus";description="Destroys up to 2 selected cards"}
    "c_death" = @{key="c_death";name="Death";order=14;pos=@{x=3;y=1};set="Tarot";cost=3;config=@{max_highlighted=2};effect="Round Bonus";description="Select 2 cards, convert the left card into the right card"}
    "c_temperance" = @{key="c_temperance";name="Temperance";order=15;pos=@{x=4;y=1};set="Tarot";cost=3;config=@{extra=50};effect="Dollar Bonus";description="Gives the total sell value of all current Jokers (Max `$50)"}
    "c_devil" = @{key="c_devil";name="The Devil";order=16;pos=@{x=5;y=1};set="Tarot";cost=3;config=@{mod_conv="m_gold";max_highlighted=1};effect="Enhance";description="Enhances 1 selected card into a Gold Card"}
    "c_tower" = @{key="c_tower";name="The Tower";order=17;pos=@{x=6;y=1};set="Tarot";cost=3;config=@{mod_conv="m_stone";max_highlighted=1};effect="Enhance";description="Enhances 1 selected card into a Stone Card"}
    "c_star" = @{key="c_star";name="The Star";order=18;pos=@{x=7;y=1};set="Tarot";cost=3;config=@{suit_conv="Diamonds";max_highlighted=3};effect="Round Bonus";description="Converts up to 3 selected cards to Diamonds"}
    "c_moon" = @{key="c_moon";name="The Moon";order=19;pos=@{x=8;y=1};set="Tarot";cost=3;config=@{suit_conv="Clubs";max_highlighted=3};effect="Round Bonus";description="Converts up to 3 selected cards to Clubs"}
    "c_sun" = @{key="c_sun";name="The Sun";order=20;pos=@{x=9;y=1};set="Tarot";cost=3;config=@{suit_conv="Hearts";max_highlighted=3};effect="Round Bonus";description="Converts up to 3 selected cards to Hearts"}
    "c_judgement" = @{key="c_judgement";name="Judgement";order=21;pos=@{x=0;y=2};set="Tarot";cost=3;effect="Round Bonus";description="Creates a random Joker card"}
    "c_world" = @{key="c_world";name="The World";order=22;pos=@{x=1;y=2};set="Tarot";cost=3;config=@{suit_conv="Spades";max_highlighted=3};effect="Round Bonus";description="Converts up to 3 selected cards to Spades"}
}

# Generate Planet files
$planets = @{
    "c_mercury" = @{key="c_mercury";name="Mercury";order=1;pos=@{x=0;y=0};set="Planet";cost=3;config=@{hand_type="High Card";mult=1;chips=10};effect="Level Up";description="+1 level to High Card"}
    "c_venus" = @{key="c_venus";name="Venus";order=2;pos=@{x=1;y=0};set="Planet";cost=3;config=@{hand_type="Pair";mult=1;chips=15};effect="Level Up";description="+1 level to Pair"}
    "c_earth" = @{key="c_earth";name="Earth";order=3;pos=@{x=2;y=0};set="Planet";cost=3;config=@{hand_type="Two Pair";mult=1;chips=20};effect="Level Up";description="+1 level to Two Pair"}
    "c_mars" = @{key="c_mars";name="Mars";order=4;pos=@{x=3;y=0};set="Planet";cost=3;config=@{hand_type="Three of a Kind";mult=2;chips=20};effect="Level Up";description="+1 level to Three of a Kind"}
    "c_jupiter" = @{key="c_jupiter";name="Jupiter";order=5;pos=@{x=4;y=0};set="Planet";cost=3;config=@{hand_type="Straight";mult=2;chips=30};effect="Level Up";description="+1 level to Straight"}
    "c_saturn" = @{key="c_saturn";name="Saturn";order=6;pos=@{x=5;y=0};set="Planet";cost=3;config=@{hand_type="Flush";mult=2;chips=15};effect="Level Up";description="+1 level to Flush"}
    "c_uranus" = @{key="c_uranus";name="Uranus";order=7;pos=@{x=6;y=0};set="Planet";cost=3;config=@{hand_type="Full House";mult=2;chips=25};effect="Level Up";description="+1 level to Full House"}
    "c_neptune" = @{key="c_neptune";name="Neptune";order=8;pos=@{x=7;y=0};set="Planet";cost=3;config=@{hand_type="Four of a Kind";mult=3;chips=30};effect="Level Up";description="+1 level to Four of a Kind"}
    "c_pluto" = @{key="c_pluto";name="Pluto";order=9;pos=@{x=8;y=0};set="Planet";cost=3;config=@{hand_type="Straight Flush";mult=4;chips=40};effect="Level Up";description="+1 level to Straight Flush"}
    "c_planet_x" = @{key="c_planet_x";name="Planet X";order=10;pos=@{x=9;y=0};set="Planet";cost=3;config=@{hand_type="Five of a Kind";mult=3;chips=35};effect="Level Up";description="+1 level to Five of a Kind"}
    "c_ceres" = @{key="c_ceres";name="Ceres";order=11;pos=@{x=0;y=1};set="Planet";cost=3;config=@{hand_type="Flush House";mult=4;chips=40};effect="Level Up";description="+1 level to Flush House"}
    "c_eris" = @{key="c_eris";name="Eris";order=12;pos=@{x=1;y=1};set="Planet";cost=3;config=@{hand_type="Flush Five";mult=3;chips=50};effect="Level Up";description="+1 level to Flush Five"}
}

# Generate Spectral files
$spectrals = @{
    "c_familiar" = @{key="c_familiar";name="Familiar";order=1;pos=@{x=0;y=0};set="Spectral";cost=4;effect="Destroy and Enhance";description="Destroy 1 random card in your hand, add 3 random Enhanced face cards to your hand"}
    "c_grim" = @{key="c_grim";name="Grim";order=2;pos=@{x=1;y=0};set="Spectral";cost=4;effect="Destroy and Add";description="Destroy 1 random card in your hand, add 2 random Enhanced Aces to your hand"}
    "c_incantation" = @{key="c_incantation";name="Incantation";order=3;pos=@{x=2;y=0};set="Spectral";cost=4;effect="Destroy and Add";description="Destroy 1 random card in your hand, add 4 random Enhanced numbered cards to your hand"}
    "c_talisman" = @{key="c_talisman";name="Talisman";order=4;pos=@{x=3;y=0};set="Spectral";cost=4;config=@{seal="Gold"};effect="Add Seal";description="Add a Gold Seal to 1 selected card in your hand"}
    "c_aura" = @{key="c_aura";name="Aura";order=5;pos=@{x=4;y=0};set="Spectral";cost=4;effect="Add Edition";description="Add Foil, Holographic, or Polychrome to 1 selected card in hand"}
    "c_wraith" = @{key="c_wraith";name="Wraith";order=6;pos=@{x=5;y=0};set="Spectral";cost=4;effect="Create Joker";description="Creates a random Rare Joker, sets money to `$0"}
    "c_sigil" = @{key="c_sigil";name="Sigil";order=7;pos=@{x=6;y=0};set="Spectral";cost=4;effect="Convert";description="Converts all cards in hand to a single random suit"}
    "c_ouija" = @{key="c_ouija";name="Ouija";order=8;pos=@{x=7;y=0};set="Spectral";cost=4;effect="Convert and Reduce";description="Converts all cards in hand to a single random rank, -1 hand size"}
    "c_ectoplasm" = @{key="c_ectoplasm";name="Ectoplasm";order=9;pos=@{x=8;y=0};set="Spectral";cost=4;effect="Add Negative";description="Add Negative to a random Joker, -1 hand size"}
    "c_immolate" = @{key="c_immolate";name="Immolate";order=10;pos=@{x=9;y=0};set="Spectral";cost=4;config=@{extra=20};effect="Destroy for Money";description="Destroys 5 random cards in hand, gain `$20"}
    "c_ankh" = @{key="c_ankh";name="Ankh";order=11;pos=@{x=0;y=1};set="Spectral";cost=4;effect="Copy Joker";description="Create a copy of a random Joker, destroy all other Jokers"}
    "c_deja_vu" = @{key="c_deja_vu";name="Deja Vu";order=12;pos=@{x=1;y=1};set="Spectral";cost=4;config=@{seal="Red"};effect="Add Seal";description="Add a Red Seal to 1 selected card in your hand"}
    "c_hex" = @{key="c_hex";name="Hex";order=13;pos=@{x=2;y=1};set="Spectral";cost=4;effect="Add Polychrome";description="Add Polychrome to a random Joker, destroy all other Jokers"}
    "c_trance" = @{key="c_trance";name="Trance";order=14;pos=@{x=3;y=1};set="Spectral";cost=4;config=@{seal="Blue"};effect="Add Seal";description="Add a Blue Seal to 1 selected card in your hand"}
    "c_medium" = @{key="c_medium";name="Medium";order=15;pos=@{x=4;y=1};set="Spectral";cost=4;config=@{seal="Purple"};effect="Add Seal";description="Add a Purple Seal to 1 selected card in your hand"}
    "c_cryptid" = @{key="c_cryptid";name="Cryptid";order=16;pos=@{x=5;y=1};set="Spectral";cost=4;effect="Copy Card";description="Create 2 copies of 1 selected card in your hand"}
    "c_soul" = @{key="c_soul";name="The Soul";order=17;pos=@{x=6;y=1};set="Spectral";cost=4;effect="Create Legendary";description="Creates a Legendary Joker"}
    "c_black_hole" = @{key="c_black_hole";name="Black Hole";order=18;pos=@{x=7;y=1};set="Spectral";cost=4;effect="Level Up All";description="Upgrade every poker hand by 1 level"}
}

function ConvertToLua($obj) {
    if ($obj -is [hashtable]) {
        $parts = @()
        foreach ($key in $obj.Keys | Sort-Object) {
            $val = ConvertToLua $obj[$key]
            $parts += "$key = $val"
        }
        return "{$($parts -join ', ')}"
    } elseif ($obj -is [bool]) {
        return $obj.ToString().ToLower()
    } elseif ($obj -is [int] -or $obj -is [double]) {
        return $obj.ToString()
    } elseif ($obj -is [string]) {
        return "`"$obj`""
    }
    return "nil"
}

# Generate tarots
$count = 0
foreach ($key in $tarots.Keys) {
    $t = $tarots[$key]
    $content = "-- Tarot: $($t.name)`nreturn $(ConvertToLua $t)`n"
    Set-Content -Path "micatro/data/tarots/$key.lua" -Value $content -Encoding UTF8
    $count++
}
Write-Host "Generated $count tarot files"

# Generate planets
$count = 0
foreach ($key in $planets.Keys) {
    $p = $planets[$key]
    $content = "-- Planet: $($p.name)`nreturn $(ConvertToLua $p)`n"
    Set-Content -Path "micatro/data/planets/$key.lua" -Value $content -Encoding UTF8
    $count++
}
Write-Host "Generated $count planet files"

# Generate spectrals
$count = 0
foreach ($key in $spectrals.Keys) {
    $s = $spectrals[$key]
    $content = "-- Spectral: $($s.name)`nreturn $(ConvertToLua $s)`n"
    Set-Content -Path "micatro/data/spectrals/$key.lua" -Value $content -Encoding UTF8
    $count++
}
Write-Host "Generated $count spectral files"

