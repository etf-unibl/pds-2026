## Dokumentovanje dizajna

Svaki dizajn mora biti dokumentovan posebnim komentarima u VHDL opisu, iz kojih alat [*Doxygen*](https://www.doxygen.nl) generiše HTML dokumentaciju. Dokumentacija se automatski generiše i objavljuje na adresi `https://etf-unibl.github.io/pds-2026/` nakon svake integracije u granu `assignments` ([Automatske provjere](automated-checks.md#dokumentacija-na-github-pages)). **Dokumentovanje dizajna je obavezno i ocjenjuje se.**

Ovo uputstvo je sažetak dijela *Doxygen* dokumentacije koji se odnosi na VHDL ([Documenting the code: VHDL](https://www.doxygen.nl/manual/docblocks.html#vhdlblocks)).

### Doxygen komentari u VHDL opisu

*Doxygen* obrađuje samo komentare koji počinju sa `--!`. Obični komentari (`--`) se ignorišu, pa se mogu koristiti za napomene koje ne treba da budu dio dokumentacije.

- **Kratak opis** (*brief*): jedna linija `--!` neposredno ispred elementa koji se dokumentuje.
- **Detaljan opis** (*details*): više uzastopnih linija koje počinju sa `--!`. Bez komande `@brief` *Doxygen* ih sve prikazuje kao detaljan opis, a element nema kratak opis.
- Komentar se uvijek nalazi **ispred** elementa koji opisuje. Jedini izuzetak su portovi (i generici), za koje komentar može stajati i **iza** elementa, u istoj liniji, i tada predstavlja kratak opis tog porta.

Kratak i detaljan opis označite eksplicitno komandama `@brief` i `@details`, kao u primjeru ispod. Sljedeće greške *Doxygen* ne prijavljuje, nego element ostaje sa pogrešnim ili bez opisa:

- prazna linija **unutar** komentara: dijelovi se spajaju u kratak opis, a `@details` se prikazuje kao tekst;
- komentar na kraju linije porta iza kojeg slijedi linija `--!` ispred sljedećeg porta: spajaju se i oba se vezuju za sljedeći port. U jednoj listi portova koristite ili komentare na kraju linija ili komentare ispred portova;
- više naziva u jednoj deklaraciji (`signal a, b : std_logic;`): dokumentovan je samo prvi naziv;
- proces bez labele: prikazuje se kao `PROCESS_0`, `PROCESS_1`, ...;
- komentar iza kojeg ne slijedi element (npr. ispred `end architecture`): odbacuje se.

Prazna linija **između** komentara i elementa je dozvoljena.

### Najčešće komande

| Komanda | Značenje |
| ------ | ------ |
| `@file` | označava da se komentar odnosi na cijeli fajl |
| `@brief` | kratak opis (jedna rečenica) |
| `@details` | detaljan opis |
| `@note` | napomena koja se posebno ističe |
| `@warning` | upozorenje (npr. ograničenja dizajna) |
| `@see` | referenca na povezani element (npr. drugi entitet) |
| `@image` | slika u opisu (npr. blok šema, dijagram stanja), vidjeti [Slike u dokumentaciji](#slike-u-dokumentaciji) |

Kompletan spisak komandi dat je u [*Doxygen* dokumentaciji](https://www.doxygen.nl/manual/commands.html). Unutar opisa mogu se koristiti i liste (linije koje počinju sa `-`).

### Šta je potrebno dokumentovati

Minimalno, u svakom fajlu dizajna potrebno je dokumentovati:

1. **fajl** - kratak opis sadržaja fajla (`@file` i `@brief`),
2. **entitet** - kratak opis i detaljan opis funkcionalnosti (šta kolo radi, kako se koristi, vremensko ponašanje ako je bitno),
3. **svaki generik i port** - kratak opis (značenje, jedinica ili kodovanje, aktivni nivo signala),
4. **arhitekturu** - kratak opis i detaljan opis načina realizacije,
5. **procese, značajne signale, konstante, tipove i instance komponenti** - kratak opis njihove uloge.

*Testbench* fajlovi (`*_tb.vhd`) se ne uključuju u generisanu dokumentaciju, ali i u njima treba komentarisati šta se i kako testira.

*Doxygen* komentari se pišu **pored** obaveznog zaglavlja fajla, koje je propisano uputstvom [Pravila za formatiranje VHDL opisa](vhdl-code-style.md). Nakon dodavanja komentara provjerite stil komandom `vhdl-style <N>`.

### Primjer

Primjer dokumentovanog multipleksera 2:1 koji prolazi provjeru stila (zaglavlje fajla je izostavljeno). Prazna linija između komentara i `entity` / `architecture` je obavezna po `vhdl-style` pravilima; *Doxygen* i dalje vezuje komentar za element.

```vhdl
--! @file
--! @brief 2:1 multiplexer

library ieee;
use ieee.std_logic_1164.all;

--! @brief 2:1 multiplexer
--! @details Selects one of the two data inputs. When sel_i is '0'
--! the output follows a_i, otherwise it follows b_i.

entity mux2 is
  port (
    a_i   : in    std_logic;  --! First data input
    b_i   : in    std_logic;  --! Second data input
    sel_i : in    std_logic;  --! Select input ('0' selects a_i)
    y_o   : out   std_logic); --! Multiplexer output
end entity mux2;

--! @brief Dataflow architecture of the multiplexer
--! @details The output is driven by a single conditional
--! signal assignment, so the circuit is purely combinational.

architecture arch of mux2 is

begin

  y_o <= a_i when sel_i = '0' else
         b_i;

end architecture arch;
```

Za sekvencijalna kola na isti način se dokumentuju procesi i signali, uvijek komentarom ispred elementa:

```vhdl
  --! Current value of the counter
  signal count : unsigned(3 downto 0);

  --! @brief Counter register
  --! @details Synchronous reset; the counter wraps around after 15.
  count_reg : process(clk_i) is
```

### Slike u dokumentaciji

Dokumentaciju možete dopuniti slikama, npr. blok šemom, dijagramom stanja ili vremenskim dijagramom. Slike se smještaju u folder `images` unutar foldera zadatka i predaju zajedno sa VHDL opisima:

```
assignments/
└── 55/
    ├── images/
    │   ├── 55_block_diagram.png
    │   └── 55_fsm.svg
    ├── traffic_light.vhd
    └── traffic_light_tb.vhd
```

- Koristite formate **PNG** i **SVG**. Fajlovi `*.jpg` su navedeni u fajlu `.gitignore` (u tom formatu alat *Quartus* snima neke svoje izlaze), pa ih *Git* ne bi dodao u komit.
- Naziv slike **počinje brojem zadatka** (`55_fsm.svg`, a ne `fsm.svg`). *Doxygen* kopira slike svih zadataka u isti folder generisane dokumentacije, pa bi slika istog naziva iz drugog zadatka zamijenila vašu, bez upozorenja.
- Slika se ubacuje komandom `@image html <naziv> "<natpis>"` u komentaru elementa uz koji treba da stoji (najčešće entitet ili arhitektura). Navodi se samo naziv fajla, bez putanje, a tekst pod navodnicima se prikazuje kao natpis ispod slike. Linija sa komandom je dio istog komentara, bez prazne linije ispred nje.

```vhdl
--! @brief Traffic light controller
--! @details Moore state machine with four states, shown in the
--! state diagram below.
--! @image html 55_fsm.svg "State diagram of the controller"

entity traffic_light is
```

Koristite komandu `@image`, a ne *Markdown* zapis slike (`![natpis]` i naziv fajla u zagradama). Ako slika nedostaje ili joj je naziv pogrešno napisan, *Doxygen* uz komandu `@image` ispisuje upozorenje `image file ... is not found in IMAGE_PATH`, a uz *Markdown* zapis samo prikaže neispravnu sliku. Prije predaje provjerite slike u [lokalnom pregledu](#lokalni-pregled-dokumentacije).

### Pomoć AI asistenta

Dodatak `pds-docs` AI asistenata kursa ([uputstvo za AI alate](https://github.com/etf-unibl/pds-marketplace/blob/main/docs/students.sr.md)) može da:

- uz vašu potvrdu doda **kostur dokumentacije** u fajl dizajna: kratke opise koje čita iz koda i oznake `TODO` za detaljne opise. To je jedina izmjena koju asistent smije da napravi u `assignments/`: dodaje samo `--!` komentare, a kod i komentare koje ste vi napisali nikad ne mijenja;
- **pregleda** vašu dokumentaciju prema zahtjevima iznad i greškama navedenim u ovom uputstvu, kao savjet: komentare ispravljate sami;
- napravi stranice **lokalno**, kao što je opisano ispod.

Svaku oznaku `TODO` (detaljne opise) pišete sami, svojim riječima, i provjeravate generisane kratke opise. Komentari dokumentacije se ne smatraju kodom koji je generisao AI: za njih u komitu nije potrebna linija `AI-assisted-by:` ([Predaja zadataka](assignment-submission.md)).

### Lokalni pregled dokumentacije

Prije predaje, izgled dokumentacije možete provjeriti lokalno:

1. Instalirajte *Doxygen* sa stranice [Doxygen download](https://www.doxygen.nl/download.html).
2. U folderu `assignments` repozitorijuma pokrenite:

   ```
   doxygen Doxyfile
   ```

3. Otvorite fajl `assignments/html/index.html` u web pregledaču i pronađite svoj dizajn (npr. u meniju **Design Unit List**). Ako ste dodali slike, provjerite da li se prikazuju i da li je *Doxygen* za njih ispisao upozorenje.

Folder `html` se ne predaje (naveden je u fajlu `.gitignore`). Podešavanja u fajlu `Doxyfile` ne mijenjajte, jer se isti fajl koristi za objavljivanje dokumentacije na *GitHub Pages*.
