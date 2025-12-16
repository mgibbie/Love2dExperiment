$jokers = @{
    "j_sly" = @{key="j_sly";name="Sly Joker";order=11;rarity=1;cost=3;pos=@{x=7;y=0};config=@{t_chips=50;type="Pair"};effect="Type Chips";description="+50 Chips if played hand contains a Pair"}
    "j_wily" = @{key="j_wily";name="Wily Joker";order=12;rarity=1;cost=4;pos=@{x=8;y=0};config=@{t_chips=100;type="Three of a Kind"};effect="Type Chips";description="+100 Chips if played hand contains Three of a Kind"}
    "j_clever" = @{key="j_clever";name="Clever Joker";order=13;rarity=1;cost=4;pos=@{x=9;y=0};config=@{t_chips=80;type="Two Pair"};effect="Type Chips";description="+80 Chips if played hand contains Two Pair"}
    "j_devious" = @{key="j_devious";name="Devious Joker";order=14;rarity=1;cost=4;pos=@{x=0;y=1};config=@{t_chips=100;type="Straight"};effect="Type Chips";description="+100 Chips if played hand contains a Straight"}
    "j_crafty" = @{key="j_crafty";name="Crafty Joker";order=15;rarity=1;cost=4;pos=@{x=1;y=1};config=@{t_chips=80;type="Flush"};effect="Type Chips";description="+80 Chips if played hand contains a Flush"}
    "j_half" = @{key="j_half";name="Half Joker";order=16;rarity=1;cost=5;pos=@{x=2;y=1};config=@{extra=@{mult=20}};effect="Mult if 3 or fewer";description="+20 Mult if played hand contains 3 or fewer cards"}
    "j_stencil" = @{key="j_stencil";name="Joker Stencil";order=17;rarity=2;cost=8;pos=@{x=3;y=1};effect="Mult per empty slot";description="X1 Mult for each empty Joker slot"}
    "j_four_fingers" = @{key="j_four_fingers";name="Four Fingers";order=18;rarity=2;cost=7;pos=@{x=4;y=1};effect="Hand modifier";description="All Flushes and Straights can be made with 4 cards"}
    "j_mime" = @{key="j_mime";name="Mime";order=19;rarity=2;cost=5;pos=@{x=5;y=1};config=@{extra=1};effect="Retrigger";description="Retrigger all card held in hand abilities"}
    "j_credit_card" = @{key="j_credit_card";name="Credit Card";order=20;rarity=1;cost=1;pos=@{x=0;y=2};config=@{extra=20};effect="Economy";description="Go up to -`$20 in debt"}
    "j_ceremonial" = @{key="j_ceremonial";name="Ceremonial Dagger";order=21;rarity=2;cost=6;pos=@{x=1;y=2};config=@{mult=0};effect="Destroy and gain";description="When Blind is selected, destroy Joker to the right and permanently add double its sell value to this Mult"}
    "j_banner" = @{key="j_banner";name="Banner";order=22;rarity=1;cost=5;pos=@{x=2;y=2};config=@{extra=30};effect="Chips per discard";description="+30 Chips for each remaining discard"}
    "j_mystic_summit" = @{key="j_mystic_summit";name="Mystic Summit";order=23;rarity=1;cost=5;pos=@{x=3;y=2};config=@{extra=@{mult=15;d_remaining=0}};effect="Conditional Mult";description="+15 Mult when 0 discards remaining"}
    "j_marble" = @{key="j_marble";name="Marble Joker";order=24;rarity=2;cost=6;pos=@{x=4;y=2};config=@{extra=1};effect="Add Stone";description="Adds a Stone card to deck when Blind is selected"}
    "j_loyalty_card" = @{key="j_loyalty_card";name="Loyalty Card";order=25;rarity=2;cost=5;pos=@{x=5;y=2};config=@{extra=@{Xmult=4;every=6}};effect="X Mult every X";description="X4 Mult every 6 hands played"}
    "j_8_ball" = @{key="j_8_ball";name="8 Ball";order=26;rarity=1;cost=5;pos=@{x=6;y=2};config=@{extra=4};effect="Create Tarot";description="1 in 4 chance for each played 8 to create a Tarot card when scored"}
    "j_misprint" = @{key="j_misprint";name="Misprint";order=27;rarity=1;cost=4;pos=@{x=7;y=2};config=@{extra=@{min=0;max=23}};effect="Random Mult";description="+0-23 Mult"}
    "j_dusk" = @{key="j_dusk";name="Dusk";order=28;rarity=2;cost=5;pos=@{x=8;y=2};config=@{extra=2};effect="Retrigger last hand";description="Retrigger all played cards in final hand of round"}
    "j_raised_fist" = @{key="j_raised_fist";name="Raised Fist";order=29;rarity=1;cost=5;pos=@{x=9;y=2};effect="Mult from held";description="Adds double the rank of lowest ranked card held in hand to Mult"}
    "j_chaos" = @{key="j_chaos";name="Chaos the Clown";order=30;rarity=1;cost=4;pos=@{x=0;y=3};config=@{extra=1};effect="Free reroll";description="1 free Reroll per shop"}
}

# Continue with more jokers (batch 2)
$jokers["j_fibonacci"] = @{key="j_fibonacci";name="Fibonacci";order=31;rarity=2;cost=7;pos=@{x=1;y=3};config=@{extra=8};effect="Rank Mult";description="Each played Ace, 2, 3, 5, or 8 gives +8 Mult when scored"}
$jokers["j_steel_joker"] = @{key="j_steel_joker";name="Steel Joker";order=32;rarity=2;cost=7;pos=@{x=2;y=3};config=@{extra=0.2};effect="X Mult per Steel";description="Gives X0.2 Mult for each Steel Card in your full deck"}
$jokers["j_scary_face"] = @{key="j_scary_face";name="Scary Face";order=33;rarity=1;cost=4;pos=@{x=3;y=3};config=@{extra=30};effect="Face Chips";description="Played face cards give +30 Chips when scored"}
$jokers["j_abstract"] = @{key="j_abstract";name="Abstract Joker";order=34;rarity=1;cost=4;pos=@{x=4;y=3};config=@{extra=3};effect="Mult per Joker";description="+3 Mult for each Joker"}
$jokers["j_delayed_grat"] = @{key="j_delayed_grat";name="Delayed Gratification";order=35;rarity=1;cost=4;pos=@{x=5;y=3};config=@{extra=2};effect="Economy";description="Earn `$2 per discard if no discards are used by end of round"}
$jokers["j_hack"] = @{key="j_hack";name="Hack";order=36;rarity=2;cost=6;pos=@{x=6;y=3};config=@{extra=1};effect="Retrigger";description="Retrigger each played 2, 3, 4, or 5"}
$jokers["j_pareidolia"] = @{key="j_pareidolia";name="Pareidolia";order=37;rarity=2;cost=5;pos=@{x=7;y=3};effect="All face cards";description="All cards are considered face cards"}
$jokers["j_gros_michel"] = @{key="j_gros_michel";name="Gros Michel";order=38;rarity=1;cost=5;pos=@{x=8;y=3};config=@{extra=@{mult=15;odds=6}};effect="Mult + Destroy";description="+15 Mult. 1 in 6 chance this is destroyed at end of round"}
$jokers["j_even_steven"] = @{key="j_even_steven";name="Even Steven";order=39;rarity=1;cost=4;pos=@{x=9;y=3};config=@{extra=4};effect="Even Mult";description="Played cards with even rank give +4 Mult when scored"}
$jokers["j_odd_todd"] = @{key="j_odd_todd";name="Odd Todd";order=40;rarity=1;cost=4;pos=@{x=0;y=4};config=@{extra=31};effect="Odd Chips";description="Played cards with odd rank give +31 Chips when scored"}
$jokers["j_scholar"] = @{key="j_scholar";name="Scholar";order=41;rarity=1;cost=4;pos=@{x=1;y=4};config=@{extra=@{chips=20;mult=4}};effect="Ace bonus";description="Played Aces give +20 Chips and +4 Mult when scored"}
$jokers["j_business"] = @{key="j_business";name="Business Card";order=42;rarity=1;cost=4;pos=@{x=2;y=4};config=@{extra=2};effect="Face Money";description="Played face cards have a 1 in 2 chance to give `$2 when scored"}
$jokers["j_supernova"] = @{key="j_supernova";name="Supernova";order=43;rarity=1;cost=5;pos=@{x=3;y=4};effect="Mult per hand played";description="Adds the number of times poker hand has been played to Mult"}
$jokers["j_ride_the_bus"] = @{key="j_ride_the_bus";name="Ride the Bus";order=44;rarity=1;cost=6;pos=@{x=4;y=4};config=@{extra=@{mult=1}};effect="Streak Mult";description="+1 Mult per consecutive hand played without a scoring face card"}
$jokers["j_space"] = @{key="j_space";name="Space Joker";order=45;rarity=2;cost=5;pos=@{x=5;y=4};config=@{extra=4};effect="Level up chance";description="1 in 4 chance to upgrade level of played poker hand"}
$jokers["j_egg"] = @{key="j_egg";name="Egg";order=46;rarity=1;cost=4;pos=@{x=6;y=4};config=@{extra=3};effect="Economy";description="Gains `$3 of sell value at end of round"}
$jokers["j_burglar"] = @{key="j_burglar";name="Burglar";order=47;rarity=2;cost=6;pos=@{x=7;y=4};config=@{extra=3};effect="Blind bonus";description="When Blind is selected, gain +3 Hands and lose all discards"}
$jokers["j_blackboard"] = @{key="j_blackboard";name="Blackboard";order=48;rarity=2;cost=6;pos=@{x=8;y=4};config=@{extra=3};effect="X Mult if all black";description="X3 Mult if all cards held in hand are Spades or Clubs"}
$jokers["j_runner"] = @{key="j_runner";name="Runner";order=49;rarity=1;cost=5;pos=@{x=9;y=4};config=@{extra=@{chips=15}};effect="Chip growth";description="Gains +15 Chips if played hand contains a Straight"}
$jokers["j_ice_cream"] = @{key="j_ice_cream";name="Ice Cream";order=50;rarity=1;cost=5;pos=@{x=0;y=5};config=@{extra=@{chips=100}};effect="Chips decay";description="+100 Chips. -5 Chips for every hand played"}

# Batch 3: Jokers 51-100
$jokers["j_dna"] = @{key="j_dna";name="DNA";order=51;rarity=3;cost=8;pos=@{x=1;y=5};config=@{extra=1};effect="Copy card";description="If first hand of round has only 1 card, add a permanent copy to deck and draw it to hand"}
$jokers["j_splash"] = @{key="j_splash";name="Splash";order=52;rarity=1;cost=3;pos=@{x=2;y=5};effect="All cards score";description="Every played card counts in scoring"}
$jokers["j_blue_joker"] = @{key="j_blue_joker";name="Blue Joker";order=53;rarity=1;cost=5;pos=@{x=3;y=5};config=@{extra=2};effect="Chips per deck card";description="+2 Chips for each remaining card in deck"}
$jokers["j_sixth_sense"] = @{key="j_sixth_sense";name="Sixth Sense";order=54;rarity=2;cost=6;pos=@{x=4;y=5};config=@{extra=1};effect="Destroy and create";description="If first hand of round is a single 6, destroy it and create a Spectral card"}
$jokers["j_constellation"] = @{key="j_constellation";name="Constellation";order=55;rarity=2;cost=6;pos=@{x=5;y=5};config=@{extra=@{Xmult=0.1}};effect="X Mult growth";description="Gains X0.1 Mult every time a Planet card is used"}
$jokers["j_hiker"] = @{key="j_hiker";name="Hiker";order=56;rarity=2;cost=5;pos=@{x=6;y=5};config=@{extra=5};effect="Permanent chips";description="Every played card permanently gains +5 Chips when scored"}
$jokers["j_faceless"] = @{key="j_faceless";name="Faceless Joker";order=57;rarity=1;cost=4;pos=@{x=7;y=5};config=@{extra=@{faces=3;dollars=5}};effect="Economy";description="Earn `$5 if 3 or more face cards are discarded at the same time"}
$jokers["j_green_joker"] = @{key="j_green_joker";name="Green Joker";order=58;rarity=1;cost=4;pos=@{x=8;y=5};config=@{extra=@{mult=1}};effect="Mult growth/decay";description="+1 Mult per hand played. -1 Mult per discard"}
$jokers["j_superposition"] = @{key="j_superposition";name="Superposition";order=59;rarity=1;cost=4;pos=@{x=9;y=5};config=@{extra=1};effect="Create Tarot";description="Create a Tarot card if poker hand contains an Ace and a Straight"}
$jokers["j_todo_list"] = @{key="j_todo_list";name="To Do List";order=60;rarity=1;cost=4;pos=@{x=0;y=6};config=@{extra=@{dollars=4;poker_hand="High Card"}};effect="Economy";description="Earn `$4 if poker hand is a High Card, poker hand changes at end of round"}
$jokers["j_cavendish"] = @{key="j_cavendish";name="Cavendish";order=61;rarity=1;cost=4;pos=@{x=1;y=6};config=@{extra=@{Xmult=3;odds=1000}};effect="X Mult + Destroy";description="X3 Mult. 1 in 1000 chance this card is destroyed at end of round"}
$jokers["j_card_sharp"] = @{key="j_card_sharp";name="Card Sharp";order=62;rarity=2;cost=6;pos=@{x=2;y=6};config=@{extra=3};effect="X Mult on repeat";description="X3 Mult if played poker hand has already been played this round"}
$jokers["j_red_card"] = @{key="j_red_card";name="Red Card";order=63;rarity=1;cost=5;pos=@{x=3;y=6};config=@{extra=@{mult=3}};effect="Mult per reroll";description="+3 Mult for each reroll in the shop"}
$jokers["j_madness"] = @{key="j_madness";name="Madness";order=64;rarity=2;cost=7;pos=@{x=4;y=6};config=@{extra=@{Xmult=0.5}};effect="X Mult + Destroy random";description="When Blind is selected, gain X0.5 Mult and destroy a random Joker"}
$jokers["j_square"] = @{key="j_square";name="Square Joker";order=65;rarity=1;cost=4;pos=@{x=5;y=6};config=@{extra=@{chips=4}};effect="Chip growth";description="Gains +4 Chips if played hand has exactly 4 cards"}
$jokers["j_seance"] = @{key="j_seance";name="Seance";order=66;rarity=3;cost=6;pos=@{x=6;y=6};config=@{extra=@{poker_hand="Straight Flush"}};effect="Create Spectral";description="Create a random Spectral card if poker hand is a Straight Flush"}
$jokers["j_riff_raff"] = @{key="j_riff_raff";name="Riff-Raff";order=67;rarity=1;cost=5;pos=@{x=7;y=6};config=@{extra=2};effect="Create Jokers";description="When Blind is selected, create 2 Common Jokers"}
$jokers["j_vampire"] = @{key="j_vampire";name="Vampire";order=68;rarity=2;cost=7;pos=@{x=8;y=6};config=@{extra=@{Xmult=0.1}};effect="X Mult per enh removed";description="Gains X0.1 Mult per scoring Enhanced card played, removes card Enhancement"}
$jokers["j_shortcut"] = @{key="j_shortcut";name="Shortcut";order=69;rarity=2;cost=7;pos=@{x=9;y=6};config=@{extra=1};effect="Straight gaps";description="Allows Straights to be made with gaps of 1 rank"}
$jokers["j_hologram"] = @{key="j_hologram";name="Hologram";order=70;rarity=2;cost=7;pos=@{x=0;y=7};config=@{extra=@{Xmult=0.25}};effect="X Mult per card added";description="Gains X0.25 Mult every time a card is added to your deck"}
$jokers["j_vagabond"] = @{key="j_vagabond";name="Vagabond";order=71;rarity=3;cost=8;pos=@{x=1;y=7};config=@{extra=4};effect="Create Tarot";description="Create a Tarot card if hand is played with `$4 or less"}
$jokers["j_baron"] = @{key="j_baron";name="Baron";order=72;rarity=3;cost=8;pos=@{x=2;y=7};config=@{extra=1.5};effect="King X Mult";description="Each King held in hand gives X1.5 Mult"}
$jokers["j_cloud_9"] = @{key="j_cloud_9";name="Cloud 9";order=73;rarity=2;cost=6;pos=@{x=3;y=7};config=@{extra=1};effect="Economy";description="Earn `$1 for each 9 in your full deck at end of round"}
$jokers["j_rocket"] = @{key="j_rocket";name="Rocket";order=74;rarity=2;cost=6;pos=@{x=4;y=7};config=@{extra=@{dollars=1;mult=2}};effect="Economy growth";description="Earn `$1 at end of round. Payout increases by `$2 when Boss Blind is defeated"}
$jokers["j_obelisk"] = @{key="j_obelisk";name="Obelisk";order=75;rarity=3;cost=8;pos=@{x=5;y=7};config=@{extra=@{Xmult=0.2}};effect="X Mult growth";description="Gains X0.2 Mult per consecutive hand played without playing most played hand"}
$jokers["j_midas_mask"] = @{key="j_midas_mask";name="Midas Mask";order=76;rarity=2;cost=6;pos=@{x=6;y=7};effect="Gold face cards";description="All played face cards become Gold cards when scored"}
$jokers["j_luchador"] = @{key="j_luchador";name="Luchador";order=77;rarity=2;cost=5;pos=@{x=7;y=7};config=@{extra=5};effect="Disable Boss";description="Sell this card to disable current Boss Blind effect"}
$jokers["j_photograph"] = @{key="j_photograph";name="Photograph";order=78;rarity=1;cost=5;pos=@{x=8;y=7};config=@{extra=2};effect="First face X Mult";description="First played face card gives X2 Mult when scored"}
$jokers["j_gift"] = @{key="j_gift";name="Gift Card";order=79;rarity=2;cost=6;pos=@{x=9;y=7};config=@{extra=1};effect="Economy";description="Add `$1 of sell value to every Joker and Consumable at end of round"}
$jokers["j_turtle_bean"] = @{key="j_turtle_bean";name="Turtle Bean";order=80;rarity=2;cost=6;pos=@{x=0;y=8};config=@{extra=@{h_size=5}};effect="Hand size";description="+5 hand size, reduces by 1 each round"}
$jokers["j_erosion"] = @{key="j_erosion";name="Erosion";order=81;rarity=2;cost=6;pos=@{x=1;y=8};config=@{extra=4};effect="Mult per card below 52";description="+4 Mult for each card below 52 in your full deck"}
$jokers["j_reserved_parking"] = @{key="j_reserved_parking";name="Reserved Parking";order=82;rarity=2;cost=6;pos=@{x=2;y=8};config=@{extra=@{odds=2}};effect="Face in hand money";description="Each face card held in hand has a 1 in 2 chance to give `$1"}
$jokers["j_mail"] = @{key="j_mail";name="Mail-In Rebate";order=83;rarity=1;cost=4;pos=@{x=3;y=8};config=@{extra=@{dollars=5;rank="2"}};effect="Economy";description="Earn `$5 for each discarded 2, rank changes each round"}
$jokers["j_to_the_moon"] = @{key="j_to_the_moon";name="To the Moon";order=84;rarity=2;cost=5;pos=@{x=4;y=8};config=@{extra=1};effect="Economy";description="Earn an extra `$1 of interest per `$5 you have at end of round"}
$jokers["j_hallucination"] = @{key="j_hallucination";name="Hallucination";order=85;rarity=1;cost=4;pos=@{x=5;y=8};config=@{extra=2};effect="Create Tarot";description="1 in 2 chance to create a Tarot card when any Booster Pack is opened"}
$jokers["j_fortune_teller"] = @{key="j_fortune_teller";name="Fortune Teller";order=86;rarity=1;cost=6;pos=@{x=6;y=8};config=@{extra=@{mult=1}};effect="Mult per Tarot used";description="+1 Mult per Tarot card used this run"}
$jokers["j_juggler"] = @{key="j_juggler";name="Juggler";order=87;rarity=1;cost=4;pos=@{x=7;y=8};config=@{extra=1};effect="Hand size";description="+1 hand size"}
$jokers["j_drunkard"] = @{key="j_drunkard";name="Drunkard";order=88;rarity=1;cost=4;pos=@{x=8;y=8};config=@{extra=1};effect="Discards";description="+1 discard each round"}
$jokers["j_stone"] = @{key="j_stone";name="Stone Joker";order=89;rarity=2;cost=6;pos=@{x=9;y=8};config=@{extra=25};effect="Chips per Stone";description="+25 Chips for each Stone Card in your full deck"}
$jokers["j_golden"] = @{key="j_golden";name="Golden Joker";order=90;rarity=1;cost=6;pos=@{x=0;y=9};config=@{extra=4};effect="Economy";description="Earn `$4 at end of round"}
$jokers["j_lucky_cat"] = @{key="j_lucky_cat";name="Lucky Cat";order=91;rarity=2;cost=6;pos=@{x=1;y=9};config=@{extra=@{Xmult=0.25}};effect="X Mult per Lucky";description="Gains X0.25 Mult each time a Lucky card successfully triggers"}
$jokers["j_baseball"] = @{key="j_baseball";name="Baseball Card";order=92;rarity=3;cost=8;pos=@{x=2;y=9};config=@{extra=1.5};effect="Uncommon X Mult";description="Uncommon Jokers each give X1.5 Mult"}
$jokers["j_bull"] = @{key="j_bull";name="Bull";order=93;rarity=2;cost=6;pos=@{x=3;y=9};config=@{extra=2};effect="Chips per dollar";description="+2 Chips for each `$1 you have"}
$jokers["j_diet_cola"] = @{key="j_diet_cola";name="Diet Cola";order=94;rarity=2;cost=6;pos=@{x=4;y=9};config=@{extra=1};effect="Free tag";description="Sell this card to create a free Double Tag"}
$jokers["j_trading"] = @{key="j_trading";name="Trading Card";order=95;rarity=2;cost=6;pos=@{x=5;y=9};config=@{extra=3};effect="Economy on discard";description="If first discard of round has only 1 card, destroy it and earn `$3"}
$jokers["j_flash"] = @{key="j_flash";name="Flash Card";order=96;rarity=2;cost=5;pos=@{x=6;y=9};config=@{extra=@{mult=2}};effect="Mult per reroll";description="+2 Mult per reroll in the shop this run"}
$jokers["j_popcorn"] = @{key="j_popcorn";name="Popcorn";order=97;rarity=1;cost=5;pos=@{x=7;y=9};config=@{extra=@{mult=20}};effect="Mult decay";description="+20 Mult. -4 Mult per round played"}
$jokers["j_trousers"] = @{key="j_trousers";name="Spare Trousers";order=98;rarity=2;cost=6;pos=@{x=8;y=9};config=@{extra=@{mult=2}};effect="Mult per Two Pair";description="+2 Mult if played hand contains a Two Pair"}
$jokers["j_ancient"] = @{key="j_ancient";name="Ancient Joker";order=99;rarity=3;cost=8;pos=@{x=9;y=9};config=@{extra=@{Xmult=1.5;suit="Spades"}};effect="Suit X Mult";description="Each played card with matching suit gives X1.5 Mult when scored, suit changes at end of round"}
$jokers["j_ramen"] = @{key="j_ramen";name="Ramen";order=100;rarity=2;cost=6;pos=@{x=0;y=10};config=@{extra=@{Xmult=2}};effect="X Mult decay";description="X2 Mult. Loses X0.01 Mult per card discarded"}

# Batch 4: Jokers 101-150
$jokers["j_walkie_talkie"] = @{key="j_walkie_talkie";name="Walkie Talkie";order=101;rarity=1;cost=4;pos=@{x=1;y=10};config=@{extra=@{chips=10;mult=4}};effect="10 and 4 bonus";description="Each played 10 or 4 gives +10 Chips and +4 Mult when scored"}
$jokers["j_selzer"] = @{key="j_selzer";name="Seltzer";order=102;rarity=2;cost=6;pos=@{x=2;y=10};config=@{extra=10};effect="Retrigger decay";description="Retrigger all played cards for next 10 hands"}
$jokers["j_castle"] = @{key="j_castle";name="Castle";order=103;rarity=2;cost=6;pos=@{x=3;y=10};config=@{extra=@{chips=3;suit="Spades"}};effect="Chip growth";description="+3 Chips per discarded card matching suit, suit changes each round"}
$jokers["j_smiley"] = @{key="j_smiley";name="Smiley Face";order=104;rarity=1;cost=4;pos=@{x=4;y=10};config=@{extra=5};effect="Face Mult";description="Played face cards give +5 Mult when scored"}
$jokers["j_campfire"] = @{key="j_campfire";name="Campfire";order=105;rarity=3;cost=8;pos=@{x=5;y=10};config=@{extra=@{Xmult=0.25}};effect="X Mult growth";description="Gains X0.25 Mult for each card sold, resets when Boss Blind is defeated"}
$jokers["j_ticket"] = @{key="j_ticket";name="Golden Ticket";order=106;rarity=1;cost=5;pos=@{x=6;y=10};config=@{extra=4};effect="Gold Money";description="Played Gold cards earn `$4 when scored"}
$jokers["j_mr_bones"] = @{key="j_mr_bones";name="Mr. Bones";order=107;rarity=2;cost=6;pos=@{x=7;y=10};config=@{extra=1};effect="Prevent death";description="Prevents death if chips scored are at least 25% of required chips. Self destructs."}
$jokers["j_acrobat"] = @{key="j_acrobat";name="Acrobat";order=108;rarity=2;cost=6;pos=@{x=8;y=10};config=@{extra=3};effect="X Mult last hand";description="X3 Mult on final hand of round"}
$jokers["j_sock_and_buskin"] = @{key="j_sock_and_buskin";name="Sock and Buskin";order=109;rarity=2;cost=6;pos=@{x=9;y=10};config=@{extra=1};effect="Retrigger face";description="Retrigger all played face cards"}
$jokers["j_swashbuckler"] = @{key="j_swashbuckler";name="Swashbuckler";order=110;rarity=1;cost=4;pos=@{x=0;y=11};config=@{extra=@{mult=1}};effect="Mult per Joker sell";description="+1 Mult for every Joker sold this run. Gains Mult equal to sell value of Joker to the left when acquired"}
$jokers["j_troubadour"] = @{key="j_troubadour";name="Troubadour";order=111;rarity=2;cost=6;pos=@{x=1;y=11};config=@{extra=@{h_size=2;h_plays=-1}};effect="Hand size/plays";description="+2 hand size, -1 hand per round"}
$jokers["j_certificate"] = @{key="j_certificate";name="Certificate";order=112;rarity=2;cost=6;pos=@{x=2;y=11};config=@{extra=1};effect="Random card";description="When round begins, add a random playing card with a random seal to your hand"}
$jokers["j_smeared"] = @{key="j_smeared";name="Smeared Joker";order=113;rarity=2;cost=6;pos=@{x=3;y=11};effect="Suit merge";description="Hearts and Diamonds count as the same suit. Spades and Clubs count as the same suit."}
$jokers["j_throwback"] = @{key="j_throwback";name="Throwback";order=114;rarity=2;cost=6;pos=@{x=4;y=11};config=@{extra=@{Xmult=0.25}};effect="X Mult per skip";description="X0.25 Mult for each Blind skipped this run"}
$jokers["j_hanging_chad"] = @{key="j_hanging_chad";name="Hanging Chad";order=115;rarity=1;cost=4;pos=@{x=5;y=11};config=@{extra=2};effect="Retrigger first";description="Retrigger first played card used in scoring 2 additional times"}
$jokers["j_rough_gem"] = @{key="j_rough_gem";name="Rough Gem";order=116;rarity=2;cost=7;pos=@{x=6;y=11};config=@{extra=1};effect="Diamond money";description="Played cards with Diamond suit earn `$1 when scored"}
$jokers["j_bloodstone"] = @{key="j_bloodstone";name="Bloodstone";order=117;rarity=2;cost=7;pos=@{x=7;y=11};config=@{extra=@{odds=2;Xmult=1.5}};effect="Heart X Mult";description="1 in 2 chance for played cards with Heart suit to give X1.5 Mult when scored"}
$jokers["j_arrowhead"] = @{key="j_arrowhead";name="Arrowhead";order=118;rarity=2;cost=7;pos=@{x=8;y=11};config=@{extra=50};effect="Spade Chips";description="Played cards with Spade suit give +50 Chips when scored"}
$jokers["j_onyx_agate"] = @{key="j_onyx_agate";name="Onyx Agate";order=119;rarity=2;cost=7;pos=@{x=9;y=11};config=@{extra=7};effect="Club Mult";description="Played cards with Club suit give +7 Mult when scored"}
$jokers["j_glass"] = @{key="j_glass";name="Glass Joker";order=120;rarity=2;cost=6;pos=@{x=0;y=12};config=@{extra=@{Xmult=0.75}};effect="X Mult per Glass";description="Gains X0.75 Mult for every Glass Card that is destroyed"}
$jokers["j_ring_master"] = @{key="j_ring_master";name="Showman";order=121;rarity=2;cost=5;pos=@{x=1;y=12};effect="Allow duplicates";description="Joker, Tarot, Planet, and Spectral cards may appear multiple times"}
$jokers["j_flower_pot"] = @{key="j_flower_pot";name="Flower Pot";order=122;rarity=2;cost=6;pos=@{x=2;y=12};config=@{extra=3};effect="X Mult if 4 suits";description="X3 Mult if poker hand contains a Diamond, Club, Heart, and Spade card"}
$jokers["j_blueprint"] = @{key="j_blueprint";name="Blueprint";order=123;rarity=3;cost=10;pos=@{x=3;y=12};effect="Copy Joker";description="Copies ability of Joker to the right"}
$jokers["j_wee"] = @{key="j_wee";name="Wee Joker";order=124;rarity=3;cost=8;pos=@{x=4;y=12};config=@{extra=@{chips=8}};effect="Chips per 2 scored";description="+8 Chips for each 2 played that scores this run"}
$jokers["j_merry_andy"] = @{key="j_merry_andy";name="Merry Andy";order=125;rarity=2;cost=6;pos=@{x=5;y=12};config=@{extra=@{d_size=3;h_size=-1}};effect="Discards/Hand size";description="+3 discards each round, -1 hand size"}
$jokers["j_oops"] = @{key="j_oops";name="Oops! All 6s";order=126;rarity=2;cost=6;pos=@{x=6;y=12};effect="Double odds";description="Doubles all listed probabilities"}
$jokers["j_idol"] = @{key="j_idol";name="The Idol";order=127;rarity=2;cost=6;pos=@{x=7;y=12};config=@{extra=@{Xmult=2;rank="A";suit="Spades"}};effect="Specific X Mult";description="Each Ace of Spades played gives X2 Mult when scored, card changes each round"}
$jokers["j_seeing_double"] = @{key="j_seeing_double";name="Seeing Double";order=128;rarity=2;cost=6;pos=@{x=8;y=12};config=@{extra=2};effect="X Mult on Club+";description="X2 Mult if played hand has a scoring Club card and a scoring card of any other suit"}
$jokers["j_matador"] = @{key="j_matador";name="Matador";order=129;rarity=2;cost=6;pos=@{x=9;y=12};config=@{extra=8};effect="Boss Blind money";description="Earn `$8 if played hand triggers Boss Blind ability"}
$jokers["j_hit_the_road"] = @{key="j_hit_the_road";name="Hit the Road";order=130;rarity=3;cost=8;pos=@{x=0;y=13};config=@{extra=@{Xmult=0.5}};effect="X Mult per Jack";description="Gains X0.5 Mult for each Jack discarded this round"}
$jokers["j_duo"] = @{key="j_duo";name="The Duo";order=131;rarity=3;cost=8;pos=@{x=1;y=13};config=@{extra=2};effect="Pair X Mult";description="X2 Mult if played hand contains a Pair"}
$jokers["j_trio"] = @{key="j_trio";name="The Trio";order=132;rarity=3;cost=8;pos=@{x=2;y=13};config=@{extra=3};effect="Three X Mult";description="X3 Mult if played hand contains Three of a Kind"}
$jokers["j_family"] = @{key="j_family";name="The Family";order=133;rarity=3;cost=8;pos=@{x=3;y=13};config=@{extra=4};effect="Four X Mult";description="X4 Mult if played hand contains Four of a Kind"}
$jokers["j_order"] = @{key="j_order";name="The Order";order=134;rarity=3;cost=8;pos=@{x=4;y=13};config=@{extra=3};effect="Straight X Mult";description="X3 Mult if played hand contains a Straight"}
$jokers["j_tribe"] = @{key="j_tribe";name="The Tribe";order=135;rarity=3;cost=8;pos=@{x=5;y=13};config=@{extra=2};effect="Flush X Mult";description="X2 Mult if played hand contains a Flush"}
$jokers["j_stuntman"] = @{key="j_stuntman";name="Stuntman";order=136;rarity=2;cost=6;pos=@{x=6;y=13};config=@{extra=@{chips=250;h_size=-2}};effect="Chips + less hand";description="+250 Chips, -2 hand size"}
$jokers["j_invisible"] = @{key="j_invisible";name="Invisible Joker";order=137;rarity=3;cost=8;pos=@{x=7;y=13};config=@{extra=2};effect="Duplicate Joker";description="After 2 rounds, sell this card to Duplicate a random Joker"}
$jokers["j_brainstorm"] = @{key="j_brainstorm";name="Brainstorm";order=138;rarity=3;cost=10;pos=@{x=8;y=13};effect="Copy leftmost";description="Copies the ability of leftmost Joker"}
$jokers["j_satellite"] = @{key="j_satellite";name="Satellite";order=139;rarity=2;cost=5;pos=@{x=9;y=13};config=@{extra=1};effect="Planet money";description="Earn `$1 for each Planet card used this run at end of round"}
$jokers["j_shoot_the_moon"] = @{key="j_shoot_the_moon";name="Shoot the Moon";order=140;rarity=1;cost=5;pos=@{x=0;y=14};config=@{extra=13};effect="Queen Mult";description="Each Queen held in hand gives +13 Mult"}
$jokers["j_drivers_license"] = @{key="j_drivers_license";name="Driver's License";order=141;rarity=3;cost=8;pos=@{x=1;y=14};config=@{extra=@{Xmult=3;enhanced_count=16}};effect="Enhanced X Mult";description="X3 Mult if you have at least 16 Enhanced cards in your full deck"}
$jokers["j_cartomancer"] = @{key="j_cartomancer";name="Cartomancer";order=142;rarity=2;cost=6;pos=@{x=2;y=14};config=@{extra=1};effect="Create Tarot";description="Create a Tarot card when Blind is selected"}
$jokers["j_astronomer"] = @{key="j_astronomer";name="Astronomer";order=143;rarity=2;cost=8;pos=@{x=3;y=14};effect="Planet discount";description="All Planet cards in shop are free"}
$jokers["j_burnt"] = @{key="j_burnt";name="Burnt Joker";order=144;rarity=2;cost=6;pos=@{x=4;y=14};config=@{extra=1};effect="Level up hand";description="Upgrade the level of the first discarded poker hand each round"}
$jokers["j_bootstraps"] = @{key="j_bootstraps";name="Bootstraps";order=145;rarity=2;cost=6;pos=@{x=5;y=14};config=@{extra=@{mult=2;dollars=5}};effect="Mult per `$5";description="+2 Mult for every `$5 you have"}
$jokers["j_caino"] = @{key="j_caino";name="Canio";order=146;rarity=4;cost=20;pos=@{x=0;y=0};soul_pos=@{x=0;y=1};config=@{extra=@{Xmult=1}};effect="X Mult per face destroy";description="Gains X1 Mult when a face card is destroyed"}
$jokers["j_triboulet"] = @{key="j_triboulet";name="Triboulet";order=147;rarity=4;cost=20;pos=@{x=1;y=0};soul_pos=@{x=1;y=1};config=@{extra=2};effect="K/Q X Mult";description="Played Kings and Queens each give X2 Mult when scored"}
$jokers["j_yorick"] = @{key="j_yorick";name="Yorick";order=148;rarity=4;cost=20;pos=@{x=2;y=0};soul_pos=@{x=2;y=1};config=@{extra=@{Xmult=1;discards=23}};effect="X Mult per discards";description="Gains X1 Mult every 23 cards discarded. X5 Mult"}
$jokers["j_chicot"] = @{key="j_chicot";name="Chicot";order=149;rarity=4;cost=20;pos=@{x=3;y=0};soul_pos=@{x=3;y=1};effect="Disable Boss";description="Disables effect of every Boss Blind"}
$jokers["j_perkeo"] = @{key="j_perkeo";name="Perkeo";order=150;rarity=4;cost=20;pos=@{x=4;y=0};soul_pos=@{x=4;y=1};config=@{extra=1};effect="Copy Consumable";description="Creates a Negative copy of 1 random consumable card in your possession at the end of the shop"}

function ConvertToLua($obj, $indent = "") {
    if ($obj -is [hashtable]) {
        $parts = @()
        foreach ($key in $obj.Keys | Sort-Object) {
            $val = ConvertToLua $obj[$key] "$indent    "
            $parts += "$key = $val"
        }
        return "{$($parts -join ', ')}"
    } elseif ($obj -is [array]) {
        $items = $obj | ForEach-Object { ConvertToLua $_ "$indent    " }
        return "{$($items -join ', ')}"
    } elseif ($obj -is [bool]) {
        return $obj.ToString().ToLower()
    } elseif ($obj -is [int] -or $obj -is [double] -or $obj -is [float]) {
        return $obj.ToString()
    } elseif ($obj -is [string]) {
        return "`"$obj`""
    }
    return "nil"
}

# Generate files
$count = 0
foreach ($key in $jokers.Keys) {
    $joker = $jokers[$key]
    $luaContent = "-- Joker: $($joker.name)`nreturn $(ConvertToLua $joker)`n"
    $path = "micatro/data/jokers/$key.lua"
    Set-Content -Path $path -Value $luaContent -Encoding UTF8
    $count++
}
Write-Host "Generated $count joker files"

