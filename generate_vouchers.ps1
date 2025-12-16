# Generate Voucher files
$vouchers = @{
    "v_overstock_norm" = @{key="v_overstock_norm";name="Overstock";order=1;pos=@{x=0;y=0};set="Voucher";cost=10;effect="Extra Card Slot";description="+1 card slot available in shop"}
    "v_overstock_plus" = @{key="v_overstock_plus";name="Overstock Plus";order=2;pos=@{x=1;y=0};set="Voucher";cost=10;requires="v_overstock_norm";effect="Extra Card Slot";description="+1 card slot available in shop"}
    "v_clearance_sale" = @{key="v_clearance_sale";name="Clearance Sale";order=3;pos=@{x=2;y=0};set="Voucher";cost=10;config=@{extra=25};effect="Shop Discount";description="All cards and packs in shop are 25% off"}
    "v_liquidation" = @{key="v_liquidation";name="Liquidation";order=4;pos=@{x=3;y=0};set="Voucher";cost=10;requires="v_clearance_sale";config=@{extra=25};effect="Shop Discount";description="All cards and packs in shop are 50% off"}
    "v_hone" = @{key="v_hone";name="Hone";order=5;pos=@{x=4;y=0};set="Voucher";cost=10;effect="Foil Chance";description="Foil, Holographic, and Polychrome cards appear 2X more often"}
    "v_glow_up" = @{key="v_glow_up";name="Glow Up";order=6;pos=@{x=5;y=0};set="Voucher";cost=10;requires="v_hone";effect="Foil Chance";description="Foil, Holographic, and Polychrome cards appear 4X more often"}
    "v_reroll_surplus" = @{key="v_reroll_surplus";name="Reroll Surplus";order=7;pos=@{x=6;y=0};set="Voucher";cost=10;effect="Reroll Cost";description="Rerolls cost `$2 less"}
    "v_reroll_glut" = @{key="v_reroll_glut";name="Reroll Glut";order=8;pos=@{x=7;y=0};set="Voucher";cost=10;requires="v_reroll_surplus";effect="Reroll Cost";description="Rerolls cost `$2 less"}
    "v_crystal_ball" = @{key="v_crystal_ball";name="Crystal Ball";order=9;pos=@{x=8;y=0};set="Voucher";cost=10;effect="Consumable Slot";description="+1 consumable slot"}
    "v_omen_globe" = @{key="v_omen_globe";name="Omen Globe";order=10;pos=@{x=9;y=0};set="Voucher";cost=10;requires="v_crystal_ball";effect="Spectral Chance";description="Spectral cards may appear in Arcana Packs"}
    "v_telescope" = @{key="v_telescope";name="Telescope";order=11;pos=@{x=0;y=1};set="Voucher";cost=10;effect="Celestial Chance";description="Celestial Packs always contain the Planet card for your most played poker hand"}
    "v_observatory" = @{key="v_observatory";name="Observatory";order=12;pos=@{x=1;y=1};set="Voucher";cost=10;requires="v_telescope";effect="Planet Mult";description="Planet cards give X1.5 Mult for their specified poker hand"}
    "v_grabber" = @{key="v_grabber";name="Grabber";order=13;pos=@{x=2;y=1};set="Voucher";cost=10;effect="Hand Bonus";description="Permanently gain +1 hand per round"}
    "v_nacho_tong" = @{key="v_nacho_tong";name="Nacho Tong";order=14;pos=@{x=3;y=1};set="Voucher";cost=10;requires="v_grabber";effect="Hand Bonus";description="Permanently gain +1 hand per round"}
    "v_wasteful" = @{key="v_wasteful";name="Wasteful";order=15;pos=@{x=4;y=1};set="Voucher";cost=10;effect="Discard Bonus";description="Permanently gain +1 discard each round"}
    "v_recyclomancy" = @{key="v_recyclomancy";name="Recyclomancy";order=16;pos=@{x=5;y=1};set="Voucher";cost=10;requires="v_wasteful";effect="Discard Bonus";description="Permanently gain +1 discard each round"}
    "v_tarot_merchant" = @{key="v_tarot_merchant";name="Tarot Merchant";order=17;pos=@{x=6;y=1};set="Voucher";cost=10;effect="Tarot Chance";description="Tarot cards appear 2X more frequently in the shop"}
    "v_tarot_tycoon" = @{key="v_tarot_tycoon";name="Tarot Tycoon";order=18;pos=@{x=7;y=1};set="Voucher";cost=10;requires="v_tarot_merchant";effect="Tarot Chance";description="Tarot cards appear 4X more frequently in the shop"}
    "v_planet_merchant" = @{key="v_planet_merchant";name="Planet Merchant";order=19;pos=@{x=8;y=1};set="Voucher";cost=10;effect="Planet Chance";description="Planet cards appear 2X more frequently in the shop"}
    "v_planet_tycoon" = @{key="v_planet_tycoon";name="Planet Tycoon";order=20;pos=@{x=9;y=1};set="Voucher";cost=10;requires="v_planet_merchant";effect="Planet Chance";description="Planet cards appear 4X more frequently in the shop"}
    "v_seed_money" = @{key="v_seed_money";name="Seed Money";order=21;pos=@{x=0;y=2};set="Voucher";cost=10;effect="Interest";description="Raise interest cap by `$25"}
    "v_money_tree" = @{key="v_money_tree";name="Money Tree";order=22;pos=@{x=1;y=2};set="Voucher";cost=10;requires="v_seed_money";effect="Interest";description="Raise interest cap by `$25"}
    "v_blank" = @{key="v_blank";name="Blank";order=23;pos=@{x=2;y=2};set="Voucher";cost=10;effect="Joker Slot";description="+1 Joker Slot"}
    "v_antimatter" = @{key="v_antimatter";name="Antimatter";order=24;pos=@{x=3;y=2};set="Voucher";cost=10;requires="v_blank";effect="Joker Slot";description="+1 Joker Slot"}
    "v_magic_trick" = @{key="v_magic_trick";name="Magic Trick";order=25;pos=@{x=4;y=2};set="Voucher";cost=10;effect="Shop Cards";description="Playing cards can appear in the shop"}
    "v_illusion" = @{key="v_illusion";name="Illusion";order=26;pos=@{x=5;y=2};set="Voucher";cost=10;requires="v_magic_trick";effect="Shop Cards";description="Playing cards in shop may have an Enhancement, Edition, and/or Seal"}
    "v_hieroglyph" = @{key="v_hieroglyph";name="Hieroglyph";order=27;pos=@{x=6;y=2};set="Voucher";cost=10;effect="Ante Skip";description="-1 Ante, -1 hand each round"}
    "v_petroglyph" = @{key="v_petroglyph";name="Petroglyph";order=28;pos=@{x=7;y=2};set="Voucher";cost=10;requires="v_hieroglyph";effect="Ante Skip";description="-1 Ante, -1 discard each round"}
    "v_directors_cut" = @{key="v_directors_cut";name="Director's Cut";order=29;pos=@{x=8;y=2};set="Voucher";cost=10;effect="Reroll Bosses";description="Reroll the Boss Blind 1 time per Ante"}
    "v_retcon" = @{key="v_retcon";name="Retcon";order=30;pos=@{x=9;y=2};set="Voucher";cost=10;requires="v_directors_cut";effect="Reroll Bosses";description="Reroll the Boss Blind unlimited times, `$10 per Reroll"}
    "v_paint_brush" = @{key="v_paint_brush";name="Paint Brush";order=31;pos=@{x=0;y=3};set="Voucher";cost=10;effect="Hand Size";description="+1 hand size"}
    "v_palette" = @{key="v_palette";name="Palette";order=32;pos=@{x=1;y=3};set="Voucher";cost=10;requires="v_paint_brush";effect="Hand Size";description="+1 hand size"}
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

$count = 0
foreach ($key in $vouchers.Keys) {
    $v = $vouchers[$key]
    $content = "-- Voucher: $($v.name)`nreturn $(ConvertToLua $v)`n"
    Set-Content -Path "micatro/data/vouchers/$key.lua" -Value $content -Encoding UTF8
    $count++
}
Write-Host "Generated $count voucher files"

