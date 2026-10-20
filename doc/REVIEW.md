# Revue de code des dépôts `ip/`

Revue en lecture seule du 2026-10-15, limitée à trois axes : les **bugs**, les **gains de surface** et les **gains de consommation**. Le style et la documentation ne sont pas traités.

> **État : revue terminée, 8 lots sur 8.** Les constats « Vérifié » ont été établis en lisant le code. Lors de l'assemblage, les bugs critiques et majeurs les plus lourds de conséquences ont été recoupés dans le code ou sur la CI GitHub : OB8-B1, SOC-B1, SOC-B2, TIMER-B6 et WRV-B1. GEN-B1 a été corrigé après lecture du source de FuseSoC 2.4.6.

## Périmètre et méthode

- **Commits revus.** C'est le commit extrait de chaque sous-module, donné dans le tableau de synthèse. Il y a deux exceptions :
  - `asylum-processor-WardRV` est revu sur la branche `debug_unit`, au commit `d4f2859`.
  - `asylum-component-timer` est revu sur `origin/main` (`2c4983c`), qui est plus récent que le commit enregistré dans asylum-project (`afaafd7`).
- **Exclusions.** Le code tiers n'est pas revu :
  - `xilinx-primitive-unisim` : bibliothèque de simulation Xilinx ;
  - `xilinx-processor-kcpsm3/hdl/kcpsm3.vhd` : seule son intégration est revue ;
  - les modèles de flash de `asylum-communication-spi/models` ;
  - les toolchains `pbcc` et `sdcc` de `asylum-utils-generators/tools`.
- **Méthode.** Le code est lu par lots de dépôts. Chaque constat a été vérifié en remontant aux déclarations, aux génériques, aux valeurs par défaut et aux process qui pilotent les signaux. Les constats se répartissent ainsi :
  - **Vérifié** : le chemin de code a été lu de bout en bout ;
  - **Probable** : le constat est plausible, mais n'a pas été prouvé, par exemple parce qu'il dépend de l'outil de synthèse ou du composant externe.
  
  Aucune simulation ni synthèse n'a été relancée pour cette revue, sauf mention contraire.
- **Estimations de surface.** Elles sont données pour le FPGA NanoXplore NG-MEDIUM (LUT4), en ordre de grandeur. Elles restent à confirmer par un rapport de synthèse.
- **Consommation.** Il s'agit de la puissance dynamique : activité des registres et des bus, logique qui tourne au repos. Sur FPGA, il n'y a pas de clock gating. Les gains viennent donc des enables et de l'isolation des opérandes.
- **Identifiants des constats.** `<IP>-B<n>` pour les bugs, `<IP>-S<n>` pour la surface, `<IP>-C<n>` pour la consommation.
  - Sévérité des bugs : Critique, Majeure ou Mineure.
  - Gain en surface ou en consommation : Fort, Moyen ou Faible.

**CI GitHub sur `main`** (relevé du 2026-10-15) :
- **En succès :** tous les dépôts qui ont une CI, sauf les deux suivants.
- **En échec :**
  - `asylum-utils-generators` (`6691a9f`, 2026-09-30) ;
  - `asylum-component-timer` au commit enregistré dans asylum-project (`afaafd7`). Le commit suivant, `2c4983c`, repasse au vert (voir TIMER-B6).
- **Sans CI :** `xilinx-primitive-unisim` et `xilinx-processor-kcpsm3`.

## Synthèse par dépôt

Nombre de constats par catégorie (bugs par sévérité). Les gains de surface et de consommation sont détaillés et chiffrés dans chaque section.

| Dépôt | Commit revu | État | Bug critique | Bug majeur | Bug mineur | Surface | Consommation |
|-------|-------------|------|:---:|:---:|:---:|:---:|:---:|
| [asylum-processor-WardRV](#asylum-processor-wardrv) | `d4f2859` | Revu |  | 1 | 2 | 6 | 4 |
| [asylum-processor-OpenBlaze8](#asylum-processor-openblaze8) | `84a0104` | Revu | 1 | 1 | 3 | 5 | 3 |
| [xilinx-processor-kcpsm3](#xilinx-processor-kcpsm3) | `5517bf1` | Revu |  |  | 4 |  |  |
| [asylum-soc-picosoc](#asylum-soc-picosoc) | `86be6ef` | Revu |  | 5 | 3 | 2 | 2 |
| [asylum-infrastructure_icn](#asylum-infrastructure_icn) | `622a34f` | Revu |  | 1 | 3 | 2 | 1 |
| [asylum-target-techmap](#asylum-target-techmap) | `309cdb8` | Revu |  |  | 2 |  |  |
| [asylum-communication-spi](#asylum-communication-spi) | `85d9809` | Revu |  | 2 | 5 | 4 | 2 |
| [asylum-communication-uart](#asylum-communication-uart) | `5e2d28d` | Revu | 2 | 3 | 2 | 3 | 1 |
| [asylum-component-gpio](#asylum-component-gpio) | `a9c0b96` | Revu | 1 | 2 | 4 | 3 | 1 |
| [asylum-component-timer](#asylum-component-timer) | `2c4983c` | Revu |  | 3 | 3 | 3 |  |
| [asylum-component-clock_divider](#asylum-component-clock_divider) | `494f311` | Revu |  |  | 2 | 1 |  |
| [asylum-component-crc](#asylum-component-crc) | `9064414` | Revu |  |  | 2 | 1 |  |
| [asylum-component-fifo](#asylum-component-fifo) | `926192a` | Revu |  |  | 2 | 1 | 1 |
| [asylum-component-ram](#asylum-component-ram) | `c0b50c3` | Revu |  |  | 3 | 1 | 1 |
| [asylum-component-stack](#asylum-component-stack) | `4d28fea` | Revu |  |  | 1 | 2 |  |
| [asylum-system-gic](#asylum-system-gic) | `9903d4a` | Revu |  | 1 | 3 | 1 | 1 |
| [asylum-system-mailbox](#asylum-system-mailbox) | `7534a86` | Revu |  | 1 | 1 | 1 | 1 |
| [asylum-system-spinlock](#asylum-system-spinlock) | `0e0a370` | Revu |  |  | 1 | 1 |  |
| [asylum-utils-pkg](#asylum-utils-pkg) | `194bbae` | Revu |  | 1 | 4 | 2 | 1 |
| [asylum-utils-generators](#asylum-utils-generators) | `123a693` | Revu |  | 2 | 6 | 2 | 1 |
| xilinx-primitive-unisim | `f6800b4` | Hors périmètre (bibliothèque de simulation Xilinx) | | | | | |
| **Total** | | | **4** | **23** | **56** | **41** | **20** |

## Constats transverses

Ces problèmes se répètent d'une IP à l'autre. Les corriger à la source les règle pour toutes les IPs à la fois : dans le générateur regtool, dans `GIC_core`, dans `ram_*` ou dans un autre composant partagé.

### Bugs

1. **Des entrées asynchrones arrivent sans synchroniseur.**
   - RX de l'UART (UART-B1).
   - Broches GPIO, pour la détection de front comme pour la lecture (GPIO-B1, GPIO-B2).
   - Bouton d'IT utilisateur de PicoSoC (SOC-B1) : c'est une régression, le `sync2dff` a été retiré.
   
   PicoSoC branche ses pads directement sur ces entrées. `sync2dffrn` existe, mais n'a aucun attribut qui le protège de l'optimisation (TMAP-B1).
2. **Les testbenches laissent passer des régressions.**
   - OpenBlaze8 déclare un PASS quand `out_port` diverge (OB8-B1, critique).
   - Le port d'entrée du DUT est piloté par la référence, ce qui masque OB8-B2.
   - Dans PicoSoC, l'IT et l'UART ne sont jamais vérifiées (SOC-B4), et les simulations multi-CPU n'ont aucun critère de succès (SOC-B5).
   - L'arbitrage de l'ICN n'est jamais exercé (ICN-B1).
   - Aucun banc WardRV ne pilote `meip_i`, si bien que WRV-B2 n'est pas vu.
   - Des attentes n'ont pas de timeout (TIMER-B5, SPI-B7).
   
   Conséquence : une CI verte ne garantit pas l'absence de ces bugs.
3. **Un W1C l'emporte sur un événement matériel du même cycle.** Le modèle `rw1c` de `csr_reg.vhd` calcule `q_next = d_hw and not wd`. Une impulsion qui tombe sur le cycle d'acquittement est perdue : c'est le cas d'un front GPIO ou d'un tick du timer en autostart. Voir GIC-B1, GPIO-B3 et TIMER-B2. Les modèles à effet de lecture ont le même défaut de priorité (GEN-B5).
   - Correction : ajouter à regtool un modèle « set prioritaire », soit `q_next = (q and not clr) or set`.
4. **L'IMR filtre à la capture et non en sortie.** Un événement masqué n'est jamais mémorisé et aucun polling n'est possible. Masquer une ligne déjà pendante ne fait pas tomber `it_o`. Voir GIC-B2, GPIO-B4 et TIMER-B3. Ce comportement vient de `GIC_core`.
5. **Des accès CSR bloquants sans registre d'état peuvent geler tout un interconnect.** La lecture d'une FIFO vide, ou l'écriture dans une FIFO pleine, maintient `ready=0`, et `sbi_icn_mux_mst` garde alors le bus. Voir SPI-B1, MBX-B1, UART-B5 et ICN-B3.
   - Correction : un registre `status` (empty, full, busy) dans chaque IP à FIFO, et une option non bloquante dans `csr_fifo`.
6. **Les valeurs sur plusieurs octets sont mises à jour sans atomicité.** C'est le cas de `init` du timer (TIMER-B4) et du diviseur de baud de l'UART (UART-B7).
7. **La chaîne logicielle produit du firmware faux ou périmé, sans aucun message.**
   - rvcc ne met jamais la `.bss` à zéro (GEN-B2).
   - Les sections `.srodata` et `.sbss` échappent au linker script, et la pile n'est pas réservée (GEN-B3).
   - Les en-têtes, dont les `*_csr.h` générés, ne sont pas des dépendances du firmware (GEN-B1).
8. **Les flows FuseSoC sont fragiles.**
   - Des fichiers VHDL-2008 sont déclarés `vhdlSource` (GPIO-B7, FIFO-B2, RAM-B2). Seul GHDL les accepte, parce qu'il passe tout en `--std=08`.
   - Des cibles make par défaut n'existent pas (FIFO-B1, RAM-B1).
   - Des cibles sont inutilisables : `sim` d'OpenBlaze8 (OB8-B5), `default` de kcpsm3 (KC3-B1), Basys/ISE (SOC-B6).
   - Des noms de cibles sont inversés (RAM-B1).
   - Le dépôt des générateurs a une CI rouge et sans cible (GEN-B4).

### Surface

9. **Les mémoires sont en lecture asynchrone par défaut, donc réalisées en bascules.** C'est de loin le plus gros gain de surface du projet. Les blocs RAM du NG-MEDIUM sont à lecture synchrone. Les mémoires concernées :
   - le banc de registres WardRV, ≈1024 FF (RAM-S1). Le cycle `S_DECODE` inutilisé peut absorber la latence de lecture (WRV-C2) ;
   - le scratchpad, la pile et le register file d'OpenBlaze8, ≈830 FF, ou ≈2400 FF en configuration PicoSoC (OB8-S1, OB8-S2, OB8-S3, STACK-S1) ;
   - les FIFO générées (FIFO-S1).
10. **Les ALU ne partagent pas leurs opérateurs.**
    - WardRV a 2 additionneurs, 2 comparateurs et 3 décaleurs là où un additionneur et un décaleur suffisent (WRV-S1, ≈ −200 à −300 LUT).
    - OpenBlaze8 a 4 additionneurs de 9 bits au lieu d'un seul (OB8-S4).
11. **Des registres sont surdimensionnés ou instanciés pour rien.** Deux leviers les corrigent tous : rendre la largeur des champs paramétrable dans regtool, et utiliser l'attribut `enable` déjà supporté. Les cas relevés :
    - CSR de WardRV stockés sur 32 bits (WRV-S3, ≈ −120 FF) ;
    - tableaux du Debug Module dimensionnés au maximum (WRV-S2, jusqu'à 768 FF) ;
    - champs CSR de 8 bits quels que soient NB_IO ou le nombre de lignes (GPIO-S3, GIC-S1) ;
    - verrou de 8 bits pour un seul bit utile (SPIN-S1) ;
    - timer figé à 32 bits (TIMER-S1) et compteurs de baud figés à 16 bits (UART-S1) ;
    - isr et imr présents sans aucune IRQ (GPIO-S1, SOC-S2) ;
    - aucun moyen de retirer un périphérique de PicoSoC (SOC-S1).
    
    Les mux de lecture CSR sont en plus générés en chaîne de priorité plutôt qu'en ET-OU (GEN-S1).

### Consommation

12. **Les cœurs tournent au repos et perdent des cycles.**
    - WFI est exécuté comme un NOP (WRV-C1).
    - Le cycle `S_DECODE` de WardRV est vide (WRV-C2, −20 % de cycles).
    - Un hart arrêté tourne en boucle dans la ROM de debug (WRV-C4).
13. **Le bus d'adresse et de données commute à chaque instruction et part vers tout le SoC.** OpenBlaze8 sort `alu_op1`/`alu_op2` sur le bus, l'isolation étant commentée (OB8-C3). Le bus traverse ensuite les deux niveaux d'ICN sans masquage (SOC-C2, ICN-C1). L'unité de debug de WardRV suit le PC même hors mode debug (WRV-C3).
14. **Des mémoires sont lues deux fois pour une seule lecture utile.** C'est le cas de la ROM d'instructions et du register file d'OpenBlaze8 (OB8-C1, OB8-C2), et de `sbi_ram` en `SYNC_READ` (RAM-C1).
15. **Des compteurs tournent en roue libre au repos.** C'est le cas du prescaler SPI (SPI-C1) et du générateur de baud TX de l'UART (UART-C1). Une FIFO vide relit aussi sa RAM à chaque cycle (FIFO-C1).
16. **Des sorties de debug restent actives alors que le debug est désactivé.** L'horloge et l'état de l'UART sortent sur 8 pads quand `DEBUG_ENABLE=false` (SOC-C1).

## Priorités recommandées

1. **Fiabiliser la vérification.** Sans cela, la CI ne peut pas valider les corrections suivantes.
   - Corriger le faux PASS d'OpenBlaze8 (OB8-B1).
   - Piloter `in_port` depuis le DUT (OB8-B2).
   - Ajouter les checks IT et UART, ainsi que les checks multi-CPU, à PicoSoC (SOC-B4, SOC-B5).
   - Tester l'arbitrage de l'ICN (ICN-B1).
   - Piloter `meip_i` dans un banc WardRV.
2. **Synchroniser les entrées asynchrones** (UART-B1, GPIO-B1/B2, SOC-B1), avec les attributs de TMAP-B1. Coût : +2 FF par ligne.
3. **Corriger les bugs fonctionnels majeurs isolés.**
   - TX de l'UART accepte l'octet sans le charger (UART-B2).
   - `mtvec.MODE` est recopié dans le PC (WRV-B1).
   - Les pads SPI de la carte NG-MEDIUM sont mal nommés (SOC-B2).
   - Le lock-step et le TMR ne comparent pas le bus de données (SOC-B3).
   - Le runtime rvcc ne met pas la `.bss` à zéro et laisse échapper `.srodata` (GEN-B2, GEN-B3).
4. **Revoir les interruptions et les accès bloquants.**
   - W1C contre événement matériel, à corriger dans regtool (point 3).
   - IMR à appliquer en sortie (point 4).
   - Registres d'état et accès non bloquants (point 5).
5. **Vérifier la tolérance aux fautes et l'état de la CI.**
   - PKG-B1 : vérifier sur le rapport NXmap que le TMR de `ft_dff` n'a pas été fusionné.
   - TIMER-B6 : avancer le sous-module timer à `2c4983c`, puisque la CI échoue au commit enregistré.
   - GEN-B4 : réparer la CI des générateurs ou la retirer.
6. **Surface**, par ordre de gain :
   - passer les mémoires en lecture synchrone (point 9) ;
   - partager les opérateurs des ALU (point 10) ;
   - réduire les CSR de WardRV et les tableaux du Debug Module (WRV-S3, WRV-S2) ;
   - ajouter des génériques `HAVE_*` à PicoSoC (SOC-S1) ;
   - générer des mux de lecture ET-OU dans regtool (GEN-S1).
7. **Consommation**, par ordre de gain :
   - implémenter WFI et supprimer `S_DECODE` dans WardRV (WRV-C1, WRV-C2) ;
   - isoler le bus d'OpenBlaze8 et de l'ICN (point 13) ;
   - supprimer les doubles lectures de ROM et de RAM (point 14) ;
   - geler les compteurs au repos (point 15) ;
   - couper `debug_o` (SOC-C1).

# Constats par dépôt

## asylum-processor-WardRV

> Revu sur la branche `debug_unit` (`d4f2859`) : cœur FSM + unité de debug. Les constats sur l'unité de debug (WRV-S2, S6, C3, C4) ne concernent que les configurations `DEBUG_ENABLE=true` ; PicoSoC instancie aujourd'hui `sbi_WardRV_fsm` sans debug. Le banc de registres en lecture asynchrone est traité dans RAM-S1.

### WRV-B1 — `mtvec.MODE` inscriptible et recopié tel quel dans le PC
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-processor-WardRV/hdl/fsm/WardRV_fsm_csr.vhd:130 ; hdl/fsm/WardRV_fsm.vhd:601
- Constat : `mtvec_r <= csr_wdata_i` écrit les 32 bits, y compris MODE (bits 1:0). Au trap, on fait `pc_r_next_core <= csr_mtvec` sans masquage. Le README annonce pourtant « direct mode » uniquement. Le même `mtvec_i` non masqué sert aussi à `dpc` dans `trap_enter` (WardRV_fsm_debug.vhd:241).
- Scénario / justification : un logiciel écrit `mtvec = base | 1` (mode vectorisé). La relecture renvoie 1, ce qui viole WARL : le logiciel croit le mode vectorisé actif. À l'interruption, `pc_r = base+1` au lieu de `base+4*11`. Le bit 0 se propage ensuite :
  - dans `pc_seq_r`, donc dans les adresses de retour de JAL/JALR ;
  - dans AUIPC (`pc + imm`), ce qui donne des adresses `%pcrel` décalées de 1, donc des loads désalignés traités en silence (pas d'exception de désalignement) ;
  - dans `mepc ← pc_r` (`trap_pc`), alors que `mepc[1:0]` doit valoir 0 avec IALIGN=32.

  Dans PicoSoC (`IADDR_ALIGN_BITS=2`), le fetch reste aligné, donc la corruption ne se voit pas tout de suite.
- Correction proposée : `mtvec_r <= csr_wdata_i(31 downto 2) & "00"` (MODE câblé à 0), ou implémenter le mode vectorisé. On gagne aussi 2 FF, et `pc_r(1:0)`, `pc_seq_r(1:0)`, `mepc(1:0)` deviennent des constantes.
- Confiance : Vérifié (l.130 et l.601 relues lors de l'assemblage)

### WRV-B2 — Interruption prise juste après l'instruction qui la masque
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-processor-WardRV/hdl/fsm/WardRV_fsm_csr.vhd:142 ; hdl/fsm/WardRV_fsm.vhd:709
- Constat : en `S_WRITEBACK`, `trap_valid` est calculé à partir de `mstatus_r(3)` / `mie_r(11)` registrés, alors que `csr_we` réécrit ces registres sur le même front.
- Scénario / justification : on exécute `csrci mstatus,8` (ou `csrc mie,MEIE`) alors que `meip_i=1`.
  - On passe quand même en `S_TRAP`, et le handler s'exécute après une instruction qui a déjà mis MIE à 0.
  - En `S_TRAP`, `MPIE ← MIE` vaut alors 0 : le handler voit un état précédent faux.
  - Cela contredit la priv spec §3.1.9 : les conditions doivent être réévaluées « immediately following an explicit write » à mstatus/mie.
  - Aucun banc ne pilote `meip_i` (`'0'` dans tb_WardRV, tb_WardRV_debug et tb_WardRV_openocd), donc le chemin d'interruption n'est jamais testé dans ce dépôt.
- Correction proposée : `trap_valid <= (dbg_irq and not (csr_we and (dec_csr_addr = CSR_MSTATUS or dec_csr_addr = CSR_MIE))) or dbg_exception`. L'interruption est alors réévaluée à l'instruction suivante. Coût : ~3 LUT. Ajouter aussi un test qui pilote `meip_i`.
- Confiance : Vérifié

### WRV-B3 — `imem2sbi` ne pilote pas `sbi_ini_o.cs`
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-processor-WardRV/hdl/bridge/imem2sbi.vhd:137-140
- Constat : `sbi_ini_t` contient `cs/re/we/addr/wdata` (asylum-utils-pkg/hdl/sbi_pkg.vhd:41-47), mais le pont n'affecte que `addr`, `wdata`, `we` et `re`. `cs` reste à `'U'` en simulation et non piloté en synthèse.
- Scénario / justification : les cibles SBI décodent `cs` (sbi_ram : `ready <= sbi_ini_i.cs` / `ready_r <= cs and not ready_r`). `ready` ne monte donc jamais : le pont reste en `S_TRANSFER` et le cœur en `S_FETCH`. Le pont n'est instancié nulle part aujourd'hui (`sbi_WardRV_fsm` utilise `ics_o`/`iaddr_o`), mais il est livré dans `files_hdl`.
- Correction proposée : `sbi_ini_o.cs <= '1' when state_r = S_TRANSFER else '0';` (comme `dmem2sbi`). Remplacer aussi l'additionneur d'adresse par une concaténation `addr_r(..2) & byte_cnt_r`, et ajouter un test minimal.
- Confiance : Vérifié

### WRV-S1 — ALU : 4 chaînes add/compare et 3 barrel shifters distincts
- Catégorie : Surface
- Sévérité : Gain Fort
- Emplacement : asylum-processor-WardRV/hdl/fsm/WardRV_fsm_alu.vhd:67-90
- Constat : chaque branche du `case` instancie son propre opérateur :
  - `+` (l.69) et `-` sur 33 bits (l.74) ;
  - `<` signé (SLT, l.83) et `<` non signé (SLTU, l.86) ;
  - `shift_left`, `shift_right` non signé et `shift_right` signé (l.80, 89, 90) ;
  - puis un mux de résultat 11:1 sur 32 bits.

  Les outils ne partagent généralement pas $add/$sub/$lt entre branches. Le flag overflow (sign xor ovf) est déjà calculé pour SUB.
- Scénario / justification :
  - SLT = `sign_o` du soustracteur et SLTU = borrow, donc les deux comparateurs sont redondants avec SUB.
  - ADD et SUB peuvent tenir dans un seul additionneur (`b xor sub`, carry-in = sub).
  - SLL = reverse(SRL(reverse(a))) et SRA = SRL avec bit de remplissage `a(31)` : un seul décaleur suffit.
  - Estimation NG-MEDIUM : on retire 1 additionneur (~33 LUT + 1 chaîne), 2 comparateurs (~64 LUT + 2 chaînes) et 2 décaleurs (~2×100-160 LUT). Les muxes d'inversion coûtent ~64 LUT. **Bilan ≈ −200 à −300 LUT**, avec un mux de résultat plus petit.
  - Bonus consommation : un seul décaleur commute au lieu de trois à chaque changement d'opérande (FETCH→DECODE→BRANCH).
- Correction proposée : réécrire l'ALU sur le schéma « 1 additionneur/soustracteur + 1 décaleur + logique ». Coût : réécriture d'un bloc de ~100 lignes. Risque modéré, couvert par les 39 cibles ACT3 et la suite ACT4.
- Confiance : Vérifié (structure RTL) ; chiffrage estimé, à confirmer sur le rapport nxmap

### WRV-S2 — Debug Module : `data_r`/`progbuf_r` dimensionnés au maximum
- Catégorie : Surface
- Sévérité : Gain Fort si non élagué par l'outil (sinon nul)
- Emplacement : asylum-processor-WardRV/hdl/debug/WardRV_dbg_dm.vhd:144-145, 388, 484, 497 ; hdl/debug/WardRV_dbg_dm_mem.vhd:52-53
- Constat : `data_r` fait toujours 12×32 FF et `progbuf_r` 16×32 FF, quels que soient `DATA_COUNT` et `PROGBUF_SIZE` (2 et 2 par défaut). Les écritures utilisent un index dynamique obtenu par soustraction (`dmi_addr - DM_DATA0`, `mem_data_idx`). Prouver que les index ≥ COUNT sont inatteignables demande une analyse SAT du chemin d'enable.
- Scénario / justification : si le synthétiseur ne prouve pas ces enables à 0, jusqu'à (10+14)×32 = **768 FF** restent dans le netlist, avec leurs décodeurs et le clear `dmactive`. C'est l'ordre de grandeur du cœur hors banc de registres.
- Correction proposée : déclarer `data_r(0 to DATA_COUNT-1)` et `progbuf_r(0 to PROGBUF_SIZE-1)`, puis compléter les tableaux d'entrée de `dm_mem` par des constantes. Indexer par les bits de poids faible (`dmi_addr(3 downto 0)`) plutôt que par soustraction. Coût nul ; vérifier le nombre de FF avant/après dans le rapport nxmap (cible `lint_ghdl_synth` ou emu).
- Confiance : Probable

### WRV-S3 — CSR machine stockés sur 32 bits alors que peu de bits servent
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-processor-WardRV/hdl/fsm/WardRV_fsm_csr.vhd:66-72, 119, 127-134
- Constat :
  - `mstatus_r` : 32 FF, seuls MIE/MPIE servent. MPP est inscriptible alors qu'il doit valoir 11 en lecture seule sur un hart M-only (WARL violé).
  - `mie_r` : 32 FF, seul MEIE (bit 11) est lu par `trap_mirq`.
  - `mcause_r` : 32 FF pour 2 valeurs possibles (3 et 0x8000000B) ; mcause est WLRL, 1+4 bits suffisent.
  - `mtval_r` : 32 FF remis à 0 à chaque trap ; la spec autorise un mtval en lecture seule à zéro.
  - `mtvec_r(1:0)` : voir WRV-B1.
- Scénario / justification : ≈ 120 FF et 3 entrées 32 bits du mux de lecture `csr_rdata_o` (≈ 60-90 LUT), soit environ 20 % des FF du cœur hors banc de registres.
- Correction proposée : ne stocker que les bits implémentés et recomposer la valeur à la lecture :
  - mstatus : `x"00001800"` OR les bits MPIE et MIE stockés ;
  - mie : MEIE au bit 11 ;
  - mcause : `irq & "000..." & code(3:0)` ;
  - mtval : 0, écritures ignorées.

  Risque faible ; relancer les tests privilégiés ACT4.
- Confiance : Vérifié

### WRV-S4 — `pc_seq_r` redondant : calculer PC+4 en WRITEBACK
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-processor-WardRV/hdl/fsm/WardRV_fsm.vhd:356, 605, 611, 626
- Constat : `pc_seq_r` (32 FF) mémorise PC+4 calculé en FETCH. Il n'est consommé qu'en WRITEBACK : lien `RD_SRC_PC_PLUS4`, `pc_r_next_core`, et `pc_next_i` vers `dpc` (halt/step). Or l'ALU est libre en WRITEBACK : `alu_res_r` n'est chargé qu'en EXECUTE et le trigger n'utilise `alu_res` qu'en EXECUTE.
- Scénario / justification : −32 FF (−30 avec WRV-B1).
- Correction proposée : faire calculer PC+4 par l'ALU en `S_WRITEBACK` et utiliser `alu_res` à la place de `pc_seq_r`. Coût : chemin ALU → `pc_r`/regfile en WRITEBACK, de même profondeur que le chemin EXECUTE existant. Risque faible.
- Confiance : Vérifié

### WRV-S5 — `dmem_rdata_r` fusionnable dans `alu_res_r`, et chargé aussi sur les stores
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-processor-WardRV/hdl/fsm/WardRV_fsm_memory.vhd:100-108 ; hdl/fsm/WardRV_fsm.vhd:355, 440
- Constat : pour un load, `alu_res_r` (l'adresse) ne sert plus après MEMORY : le PC suivant vient de `pc_seq_r`, `csr_we=0`, et le regfile lit `dmem_rdata_r`. De plus, `dmem_rdata_r` est chargé sur `dmem_valid_r and ready` sans tester `we`, donc ses 32 FF commutent inutilement à chaque store.
- Scénario / justification : −32 FF et une entrée 32 bits de mux.
- Correction proposée : écrire la donnée alignée dans `alu_res_r` en fin de MEMORY pour les loads (`alu_res_r_we = execute or (memory and ready and not we)`) et retirer l'entrée `RD_SRC_MEM` du mux de writeback. La trace de simulation (`mem_addr` en WRITEBACK) est à adapter. À défaut, ajouter au moins `we_i='0'` à la condition de chargement.
- Confiance : Vérifié

### WRV-S6 — Unité de debug : registres dupliqués
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-processor-WardRV/hdl/debug/WardRV_dbg_dmi_cdc.vhd:70-72, 126-128 ; hdl/debug/WardRV_dbg_dtm.vhd:99-100, 140, 198 ; hdl/debug/WardRV_dbg_sba.vhd:73, 193-197 ; hdl/fsm/WardRV_fsm_trigger.vhd:83-87
- Constat :
  - La réponse DMI est stockée trois fois : `res_*_r` côté clk (34 FF), `rsp_*_r` côté TCK (34 FF) et `data_r` dans le DTM (32 FF). `res_data_r` reste pourtant stable jusqu'à la réponse suivante, qui ne peut arriver qu'après le Capture-DR qui consomme la précédente.
  - `addr_r` du DTM (7 FF) double `req_addr_r` du CDC, chargé sur le même front.
  - `sbaddr_r` et son incrémenteur font 32 bits alors que `dmem2sbi` n'utilise que `SBA_ADDR_WIDTH` (8 par défaut). Comme ces bits sont lisibles par DMI, l'outil ne les élague pas.
  - `addr_match` contient deux comparateurs `>=` et `<` complémentaires, appelés deux fois par trigger.
- Scénario / justification : environ −66 FF (réponse DMI), −7 FF (adresse), −24 FF (sbaddr), ≈ −2 comparateurs par trigger.
- Correction proposée :
  - le DTM capture directement `res_data_r` (chemin quasi-statique, même contrainte que le payload actuel), avec un drapeau « cleared » pour `dmihardreset`/discard ;
  - réutiliser `req_addr_r` pour l'adresse du DTM ;
  - ramener `sbaddr_r` à `SBA_ADDR_WIDTH` bits, bits hauts lus à 0 (conformité à vérifier côté spec) ;
  - calculer `lt` une seule fois et en déduire GE.

  Risque : CDC, à revalider avec `sim_debug_tap` en horloges lente et rapide.
- Confiance : Vérifié (structure) ; partie sbaddr et gain triggers : Probable

### WRV-C1 — WFI exécuté comme NOP : aucun mode veille
- Catégorie : Consommation
- Sévérité : Gain Fort (firmware piloté par interruptions)
- Emplacement : asylum-processor-WardRV/hdl/fsm/WardRV_fsm_decode.vhd:315-333 (F12_WFI non décodé, donc `I_UNKNOWN`) ; hdl/RV_pkg.vhd:86
- Constat : WFI est traité comme un NOP (README l.480). Une boucle d'attente `wfi; j loop` refait sans cesse FETCH/DECODE/EXECUTE/WRITEBACK. La ROM/RAM d'instructions (`ics_o`), la mémoire de registres, l'ALU et les bus commutent en permanence.
- Scénario / justification : WFI en NOP est légal, mais c'est le principal levier de puissance au repos. Pendant l'attente, le cœur et la mémoire d'instructions descendraient presque à la seule activité de l'arbre d'horloge.
- Correction proposée :
  - Décoder WFI et ajouter un état `S_WFI` après WRITEBACK (PC déjà à +4).
  - Y rester tant que `mip(11) and mie(11)` vaut 0 (réveil indépendant de `mstatus.MIE`, comme le veut la spec) et que `haltreq` vaut 0 (la Debug Spec impose le réveil sur haltreq).
  - Garder WFI comme NOP en mode debug et pendant un step.
  - Option : exporter un `sleep_o` pour le clock gating SoC.

  Coût : 1 état et ~10 LUT. Risque faible.
- Confiance : Vérifié

### WRV-C2 — État `S_DECODE` vide : un cycle perdu par instruction
- Catégorie : Consommation
- Sévérité : Gain Moyen
- Emplacement : asylum-processor-WardRV/hdl/fsm/WardRV_fsm.vhd:676-680 (et `state_is_decode` l.649, jamais utilisé)
- Constat : rien n'est registré à la fin de DECODE :
  - `inst_r` est chargé en fin de FETCH ;
  - le décodeur est combinatoire et la lecture des registres asynchrone (RAM-S1) ;
  - en DECODE, l'ALU reçoit déjà les commandes d'EXECUTE (`when others`), et `alu_res_r` n'est chargé qu'en EXECUTE.
- Scénario / justification : le chemin `inst_r → decode → regfile → ALU → alu_res_r` est de toute façon mono-cycle pour la STA (aucune contrainte multicycle dans le dépôt). DECODE n'apporte donc aucune marge de timing. Avec `sbi_WardRV_fsm` (FETCH = 2 cycles via `ics_r`), une instruction ALU passerait de 5 à 4 cycles (−20 % d'énergie par instruction : arbre d'horloge, FF, bus). Loads et branches gagnent 1 cycle chacun, soit +25 % de performance.
- Correction proposée : passer directement de `S_FETCH` à `S_EXECUTE`. Alternative : garder ce cycle et l'utiliser pour une lecture synchrone du banc de registres (correctif RAM-S1 avec `SYNC_READ=true`, adresses issues de `inst_r`), ce qui rend RAM-S1 gratuit en performance. Risque faible : `WardRV_fsm_debug` n'utilise que reset/execute/writeback/trap.
- Confiance : Vérifié

### WRV-C3 — Mémoire de debug et triggers actifs hors mode debug
- Catégorie : Consommation
- Sévérité : Gain Faible à Moyen (configurations avec `DEBUG_ENABLE`)
- Emplacement : asylum-processor-WardRV/hdl/fsm/WardRV_fsm.vhd:575-577 ; hdl/debug/WardRV_dbg_dm_mem.vhd:105-151 ; hdl/fsm/WardRV_fsm_trigger.vhd:216-226
- Constat :
  - `dbg_sbi_ini_o.addr` suit `pc_r(10:0)` ou l'adresse dmem, et `dbg_sbi_ini_o.wdata` suit le `wdata` dmem, sans qualification par `dbg_debug_mode`.
  - Le mux de lecture combinatoire de `dm_mem` (ROM 21 mots, WHERETO, 8 mots abstract, progbuf, data, flags, sur 32 bits) se réévalue à chaque changement de PC, et `data_wdata_o` fait commuter les muxes D de `data_r`. Tout cela alors que `cs=0` hors mode debug.
  - Les comparateurs de triggers évaluent `pc` et `alu_res` à chaque cycle, même avec `m_r = 0`.
- Scénario / justification : supprime l'activité de l'unité de debug en fonctionnement normal ; gain non chiffré.
- Correction proposée : forcer `addr` à 0 quand `dbg_debug_mode='0'` et masquer `wdata` par `dmem_dbg` (~43 portes AND). Option : figer les entrées des comparateurs quand `or m_r = '0'`. Coût ≤ 50 LUT, risque nul.
- Confiance : Vérifié (structure) ; gain non chiffré

### WRV-C4 — Hart arrêté qui tourne en boucle dans la ROM de debug
- Catégorie : Consommation
- Sévérité : Gain Faible (uniquement pendant un halt)
- Emplacement : asylum-processor-WardRV/hdl/debug/WardRV_dbg_rom_pkg.vhd (mots 6-12, `_poll`) ; hdl/debug/WardRV_dbg_dm_mem.vhd:138
- Constat : en halt, le hart exécute en continu 7 instructions (`lw FLAGS` deux fois, `andi`, `bnez` deux fois, `j`). Fetch, ALU, banc de registres et bus restent pleinement actifs pendant toute la session de debug, et FLAGS est lu deux fois par itération.
- Scénario / justification : activité inutile pendant toute la durée d'un halt.
- Correction proposée : dans `dm_mem`, maintenir `ready=0` sur une lecture de FLAGS tant que `flag_go = flag_resume = 0` ; le hart se fige alors en `S_MEMORY` (~5 LUT). Avec `dmactive=0`, le comportement reste celui d'aujourd'hui (attente infinie). À défaut, ne faire qu'un seul `lw` par itération dans la ROM.
- Confiance : Vérifié

**Synthèse WardRV** : le seul bug fonctionnel sérieux est WRV-B1 (`mtvec.MODE` recopié dans le PC). Il casse WARL et peut corrompre en silence `mepc`, AUIPC et les adresses de retour dès qu'un logiciel écrit un `mtvec` non aligné. WRV-B2 (interruption prise après son masquage) reste invisible faute de test qui pilote `meip_i`. Les plus gros gains de surface sont dans l'ALU (WRV-S1, ≈ −200 à −300 LUT), en plus de RAM-S1, puis dans les CSR (WRV-S3, ≈ −120 FF), et potentiellement dans les tableaux du Debug Module (WRV-S2, jusqu'à 768 FF, à confirmer sur rapport). Côté consommation, implémenter WFI (WRV-C1) et supprimer le cycle `S_DECODE` vide (WRV-C2, −20 % de cycles), ou l'utiliser pour la lecture synchrone du banc de registres, sont les deux leviers majeurs à faible coût.

## asylum-processor-OpenBlaze8

### OB8-B1 — TB : une divergence de out_port termine la simulation en succès (faux PASS)
- Catégorie : Bug
- Sévérité : Critique
- Emplacement : asylum-processor-OpenBlaze8/sim/tb_OpenBlaze8.vhd:323-329 (voir aussi 186 et 286-294)
- Constat : quand `dut_out_port_o /= ref_out_port_o` sous write_strobe, le TB fait seulement un `report`, donc avec la sévérité par défaut `note`, puis `test_done <= '1'`. Ce signal arrête l'horloge (l.186) et satisfait l'assert de timeout (l.290). GHDL sort donc avec le code 0 et la CI (statut de sortie de fusesoc) passe au vert.
- Scénario / justification : le DUT écrit une mauvaise valeur sur un port (valeurs WATCH, résultat d'ALU faux avec un flot de contrôle identique, etc.). On obtient un message « note », la simulation s'arrête et le test est déclaré PASS. Si le DUT écrit FA sur E0 alors que la référence écrit autre chose, le `case` de la l.349 affiche même « Test OK ».
- Correction proposée : `assert dut_out_port_o = ref_out_port_o report ... severity failure;`. Ne mettre `test_done` à '1' que sur le trigger OK.
- Confiance : Vérifié (relu lors de l'assemblage : `report` sans sévérité puis `test_done <= '1'`)

### OB8-B2 — REGFILE_SYNC_READ=true (valeur par défaut) : port_id/out_port valides 1 cycle au lieu de 2, INPUT sX,(sY) faux ; le TB masque le problème
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-processor-OpenBlaze8/hdl/OpenBlaze8.vhd:38, hdl/OpenBlaze8_RegFile.vhd:65-98, hdl/OpenBlaze8_LoadStore.vhd:63-64, sim/tb_OpenBlaze8.vhd:216-241
- Constat : `port_id_o = alu_op2` est la sortie registrée de RAMy, chargée au front de fin de phase 0. Pendant la phase 0 d'un INPUT/OUTPUT indirect, port_id (et out_port = sX) affichent encore la valeur lue pour une instruction précédente. Dans KCPSM3, `port_id <= second_operand` vient d'une RAM16X1D à lecture asynchrone et reste valide sur les 2 cycles (kcpsm3.vhd:857-858).
- Scénario / justification : `LOAD s1,05 ; INPUT s0,(s1)` avec un périphérique qui registre son mux d'entrée sur port_id à chaque front. C'est le schéma pipeliné permis par PicoBlaze, et c'est aussi celui du modèle `p_mem` du TB. La donnée capturée en fin de phase 0 correspond à l'ancien port_id, donc s0 reçoit la donnée d'un autre port. Le TB ne peut pas le voir, pour trois raisons :
  - `dut_in_port_i` est calculé à partir de `ref_port_id_o` ;
  - port_id n'est comparé que sous strobe ;
  - aucun .psm n'utilise IN/OUT indirect.

  Le wrapper SBI n'est pas touché : cs n'est actif qu'en phase 1.
- Correction proposée : passer REGFILE_SYNC_READ=false par défaut pour l'entité OpenBlaze8 (remplaçant direct de KCPSM3), ou documenter la contrainte (in_port combinatoire). Dans le TB :
  - piloter `dut_in_port_i` par un modèle alimenté par `dut_port_id_o` ;
  - ajouter un test `INPUT/OUTPUT sX,(sY)` ;
  - ajouter une cible REGFILE_SYNC_READ=false. C'est le défaut de sbi_OpenBlaze8 et cette configuration n'est jamais simulée.
- Confiance : Vérifié (lecture RTL et chronogramme, non simulé)

### OB8-B3 — Génériques DATA_WIDTH / REGFILE_DEPTH / ADDR_INST_WIDTH>10 non fonctionnels
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-processor-OpenBlaze8/hdl/OpenBlaze8.vhd:75-76,85,89 ; hdl/OpenBlaze8_Decode.vhd:44-45 ; hdl/OpenBlaze8_ALU.vhd:157
- Constat : Decode sort les numéros de registre sur 4 bits fixes, branchés sur `reg1_addr/reg2_addr` qui font log2(REGFILE_DEPTH) bits. `decode_address`/`decode_imm` sont des alias de `decode_imm10(10 downto 1)`. L'ALU code en dur `alu_op1_i(7 downto 1)`.
- Scénario / justification : REGFILE_DEPTH≠16, DATA_WIDTH≠8 ou ADDR_INST_WIDTH>10 provoquent une erreur d'élaboration (largeur de port ou indice hors bornes). Seuls STACK_DEPTH, RAM_DEPTH, ADDR_INST_WIDTH≤10 et REGFILE_SYNC_READ sont réellement paramétrables.
- Correction proposée : passer ces génériques en constantes, ou ajouter des `assert` d'élaboration ; remplacer le `7` par `size_data-1`.
- Confiance : Vérifié

### OB8-B4 — sbi_OpenBlaze8 : reset documenté asynchrone, mais appliqué de façon synchrone partout sauf cycle_phase
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-processor-OpenBlaze8/hdl/sbi_OpenBlaze8.vhd:73,89 ; hdl/OpenBlaze8_Clock.vhd:73-85 ; PC, Flags, Interrupt et stack.vhd ont un reset dans le front d'horloge
- Constat : `arstn_i` est commenté « asynchronous reset ». Seul `cycle_phase_r` a un reset asynchrone ; le PC, les flags, le masque d'IT et le pointeur de pile sont en reset synchrone.
- Scénario / justification : impulsion de reset sans front d'horloge (horloge gatée pendant le reset) : cycle_phase repasse à 0, mais pas le PC, les flags, le masque ni la pile, et le CPU repart en milieu de programme, IT éventuellement démasquées. Relâchement asynchrone non synchronisé : cycle_phase et le PC peuvent sortir du reset sur des fronts différents.
- Correction proposée : un seul style de reset (tout synchrone, cycle_phase compris), avec documentation « reset à synchroniser au niveau SoC ».
- Confiance : Vérifié (impact selon le générateur de reset)

### OB8-B5 — Cible `sim` du .core inutilisable
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-processor-OpenBlaze8/OpenBlaze8.core:329-337
- Constat : la cible déclare `toplevel: tb_OpenBlaze8` mais n'hérite que de `files_hdl`. Le TB, kcpsm3 et la ROM générée sont absents.
- Scénario / justification : `make TARGET=sim` (cible listée dans mk/targets.txt) échoue à l'élaboration.
- Correction proposée : en faire une ancre YAML non exposée (sans toplevel ni description), ou y ajouter `files_sim` et un generate par défaut.
- Confiance : Vérifié

### OB8-S1 — Scratchpad en lecture asynchrone forcée : ni BRAM, ni RFB synchrone
- Catégorie : Surface
- Sévérité : Gain Fort
- Emplacement : asylum-processor-OpenBlaze8/hdl/OpenBlaze8_RAM.vhd:60-64 ; hdl/OpenBlaze8_Control.vhd:343
- Constat : `ram_1r1w` est instancié avec `SYNC_READ => false`, et `re_i` (ram_read_en) est ignoré. Les blocs RAM de NG-MEDIUM sont à lecture synchrone. Sauf mappage RFB d'une lecture asynchrone par nxmap, la mémoire est réalisée en FF + mux :
  - 64×8 : ≈512 FF + ≈170 LUT4 ;
  - PicoSoC (RAM_DEPTH=256) : ≈2048 FF + ≈700 LUT.

  En plus, l'adresse (alu_op2) change à chaque instruction : l'arbre de mux commute en permanence (consommation).
- Scénario / justification : avec REGFILE_SYNC_READ=false, sY est valide dès la phase 0. On peut lire de façon synchrone au front de fin de phase 0 (`re = inst_fetch and cycle_0`) ; la donnée est valide en phase 1 et l'écriture du STORE en fin de phase 1 ne change pas (lecture après écriture correcte). Avec REGFILE_SYNC_READ=true, l'adresse indirecte n'existe qu'en phase 1.
- Correction proposée : générique RAM_SYNC_READ, autorisé quand REGFILE_SYNC_READ=false. Pour le mode synchrone : lecture sur front descendant en phase 1, ou write-back différé avec bypass (risque élevé). Gain : −512 FF / −170 LUT (−2048 FF en config PicoSoC) contre 1 RFB/BRAM. Risque moyen.
- Confiance : Vérifié (structure) / Probable (mappage nxmap)

### OB8-S2 — Pile d'appel en lecture asynchrone alors qu'un préchargement synchrone du sommet suffit
- Catégorie : Surface
- Sévérité : Gain Fort
- Emplacement : asylum-processor-OpenBlaze8/hdl/OpenBlaze8_Stack.vhd:61-66 ; asylum-component-stack/hdl/stack.vhd:158
- Constat : la pile 32×10 passe par `ram_1r1w SYNC_READ=>false` : 320 FF + ≈110 LUT de mux si elle est réalisée en FF. Le pop n'est consommé qu'au front de fin de phase 0, et le pointeur et la RAM ne changent qu'à ce front.
- Scénario / justification : lire `ram(ptr-1)` au front de fin de phase 1 (`re = cycle_1`) donne le bon sommet dans tous les enchaînements, vérifiés sur le chronogramme : CALL→RETURN, IT→RETURNI en 3FF, RETURN→RETURN, ainsi que pendant les stalls cke. C'est le schéma de KCPSM3 (RAM32X1S + FD, kcpsm3.vhd:1358-1387).
- Correction proposée : ajouter un générique SYNC_READ au composant stack (voir STACK-S1), ou une pile locale avec sommet préchargé. Gain : −320 FF / −≈110 LUT contre 1 RFB. Risque moyen (le composant est partagé).
- Confiance : Vérifié (timing) / Probable (mappage)

### OB8-S3 — Register file dupliqué (2 × ram_1r1w) au lieu de ram_2r1w
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-processor-OpenBlaze8/hdl/OpenBlaze8_RegFile.vhd:65-98
- Constat : RAMx et RAMy sont deux copies 16×8 avec le même port d'écriture. En réalisation FF (REGFILE_SYNC_READ=false, défaut de sbi_OpenBlaze8), cela fait 256 FF et 2 décodeurs d'écriture. `asylum.ram_2r1w`, déjà présent dans la même bibliothèque, offre un tableau unique à 2 ports de lecture.
- Scénario / justification : sémantique identique (re0/re1, SYNC_READ).
- Correction proposée : instancier ram_2r1w. Gain : −128 FF / −≈16 LUT en FF, neutre si mappé en RFB (2 blocs dans tous les cas). Risque faible.
- Confiance : Vérifié (structure) / Probable (mappage)

### OB8-S4 — ALU : 4 additionneurs/soustracteurs de 9 bits au lieu d'un seul
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-processor-OpenBlaze8/hdl/OpenBlaze8_ALU.vhd:128-142
- Constat : `res_add_nc`, `res_add_c` (3 opérandes), `res_sub_nc` et `res_sub_c` (3 opérandes) sont tous calculés, puis passent par 3 mux de 9 bits. Le comparateur `test_gt` (l.194) est mort.
- Scénario / justification : un seul additionneur avec retenue d'entrée couvre tous les cas :
  - `sub = alu_op_arith_i` ;
  - `cin = sub xor (alu_op_arith_cy_i and flag_c_i)` ;
  - `sum = ('0'&op1) + ('0'&(op2 xor sub)) + cin` ;
  - `C = sum(9) xor sub`.

  On retrouve bien ADD (cin=0), ADDCY (cin=C), SUB (op1+~op2+1), SUBCY (op1+~op2+not C) et COMPARE (cy=0).
- Correction proposée : la formule ci-dessus. Gain : −3 à −5 additionneurs de 9 bits et −2 mux, soit ≈ −30 à −50 LUT, avec moins de commutation. Risque faible : couvert par les tests 012-017 et les tests C (ADDCY/SUBCY).
- Confiance : Vérifié (structure) / Probable (chiffrage)

### OB8-S5 — Pile : compteur nb_elt et logique full/empty inutiles avec OVERWRITE=1
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-processor-OpenBlaze8/hdl/OpenBlaze8_Stack.vhd:61-66 ; asylum-component-stack/hdl/stack.vhd:61,86-92
- Constat : avec OVERWRITE=1, nb_elt (6 FF) ne sert qu'à bloquer le pop sur pile vide. push_ack et pop_val ne sont pas utilisés.
- Scénario / justification : un pointeur cyclique de 5 bits (comme KCPSM3) suffit, et il supprime l'écart décrit en KC3-B3.
- Correction proposée : pointeur seul. Gain : −6 FF / −≈10 LUT. Risque faible.
- Confiance : Vérifié

### OB8-C1 — ROM d'instructions lue à chaque cycle, alors qu'une lecture sur deux est redondante
- Catégorie : Consommation
- Sévérité : Gain Fort
- Emplacement : asylum-processor-OpenBlaze8/hdl/sbi_OpenBlaze8.vhd:75 ; hdl/OpenBlaze8_Control.vhd:217
- Constat : `ics_o <= cke`. Le PC n'est écrit qu'en fin de phase 0 : à ce front, la ROM échantillonne l'ancien PC et relit le même mot. Seule la lecture de fin de phase 1 est utile, y compris après un saut ou une IT.
- Scénario / justification : la moitié des lectures de la BRAM 1K×18 est gaspillée, et c'est souvent le premier poste de consommation dynamique du sous-système CPU.
- Correction proposée : exposer la phase et écrire `ics_o <= cke and (cycle_phase or reset)`. Il faut garder la lecture pendant le reset pour présenter I(0) au premier cycle. Gain : −50 % de lectures ROM. Risque faible.
- Confiance : Vérifié

### OB8-C2 — Lecture synchrone du register file active sur les deux phases
- Catégorie : Consommation
- Sévérité : Gain Moyen
- Emplacement : asylum-processor-OpenBlaze8/hdl/OpenBlaze8_Control.vhd:277-289
- Constat : `regx_read_en`/`regy_read_en` ne sont pas qualifiés par la phase. En mode SYNC_READ, `rdata_r` est rechargé en fin de phase 0 (lecture utile) et en fin de phase 1. Cette seconde valeur n'est consommée par personne : ALU, flags, strobes et écriture scratchpad n'agissent qu'en phase 1, après la relecture de la phase 0 suivante.
- Scénario / justification : 2 lectures RFB par copie et par instruction au lieu d'une ; port_id, out_port et l'ALU commutent en plus en phase 0.
- Correction proposée : ajouter `and cycle_0` aux deux enables. Gain : −50 % de lectures du register file. Risque faible.
- Confiance : Vérifié

### OB8-C3 — port_id_o / out_port_o commutent à chaque instruction (gating commenté)
- Catégorie : Consommation
- Sévérité : Gain Moyen
- Emplacement : asylum-processor-OpenBlaze8/hdl/OpenBlaze8_LoadStore.vhd:63-64 (gating commenté l.67-70, `io_access_en_i` inutilisé)
- Constat : port_id et out_port suivent alu_op2/alu_op1 à chaque lecture de registre ou immédiat. Dans sbi_OpenBlaze8, ce sont `sbi_ini_o.addr/wdata` : les décodeurs d'adresse et la distribution de wdata du SoC commutent même sans accès IO.
- Scénario / justification : `io_access_en` est vrai sur les 2 phases de IN/OUT, donc le gating conserve la sémantique KCPSM3 « valide 2 cycles ».
- Correction proposée : réactiver le gating avec `io_access_en_i` (16 LUT), ou un registre de maintien activé par io_access_en (16 FF, aucune commutation hors IO). Gain : la commutation du bus IO tombe au taux d'instructions IO. Risque faible.
- Confiance : Vérifié

**Synthèse OpenBlaze8**
- Le décodage a été vérifié opcode par opcode (opcodes, conditions Z/NZ/C/NC), ainsi que les flags Z/C (logique, TEST parité, COMPARE, ADDCY/SUBCY, décalages), les interruptions, RETURNI (sauvegarde/restauration des flags, vecteur 3FF, ack) et les 2 cycles par instruction : aucun bug fonctionnel dans ALU, Control, Flags ou Interrupt.
- Le risque principal est côté vérification : OB8-B1 transforme une divergence out_port en PASS, et le TB fournit au DUT le port d'entrée de la référence, ce qui masque OB8-B2 (INPUT indirect faux en configuration par défaut).
- En surface, le poste dominant sur NG-MEDIUM est fait des trois mémoires à lecture asynchrone (scratchpad, pile, register file en mode async) : ≈830 FF en config par défaut, ≈2400 FF en config PicoSoC (RAM_DEPTH=256), si elles sont réalisées en FF. Le partage de l'additionneur ALU est un gain sûr et à faible risque.
- En consommation, la ROM et le register file sont lus deux fois par instruction, et le bus IO n'est pas gaté ; les trois corrections sont simples.

## xilinx-processor-kcpsm3

> Le code Xilinx (`hdl/kcpsm3.vhd`) n'est pas revu ; seuls l'intégration et les écarts de comportement avec OpenBlaze8 le sont.

### KC3-B1 — Cible `default` de kcpsm3.core sans -fsynopsys : flow GHDL autonome cassé
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : xilinx-processor-kcpsm3/kcpsm3.core:29-32
- Constat : `analyze_options: []`. La dépendance unisim, qui n'a elle-même aucune option d'outil, fait analyser ses 1132 primitives. Certaines, comme ARAMB36_INTERNAL ou BUFGMUX_CTRL, font `use ieee.std_logic_arith`, que GHDL refuse sans `-fsynopsys`.
- Scénario / justification : `fusesoc run --target default xilinx:processor:kcpsm` échoue. OpenBlaze8 ne fonctionne que parce que sa cible sim impose `-fsynopsys -frelaxed`.
- Correction proposée : `analyze_options: ["-fsynopsys","-frelaxed"]`.
- Confiance : Probable (non exécuté)

### KC3-B2 — Écart : OpenBlaze8 sort du reset 2 cycles plus tôt que KCPSM3 (masqué par le TB)
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-processor-OpenBlaze8/hdl/OpenBlaze8_Clock.vhd:53-65 ; kcpsm3.vhd:302-312 ; tb_OpenBlaze8.vhd:204-207
- Constat : dans KCPSM3, `internal_reset` est le reset retardé par 2 FDS. OB8 possède `reset_r`, mais fait `reset_internal <= reset_i` (la version `reset_r(0)` est commentée) : le premier fetch arrive 2 cycles avant KCPSM3. Le TB relâche `dut_reset_i` 2 périodes après `ref_reset_i` pour compenser.
- Scénario / justification : en remplacement direct, toute logique calée sur le relâchement du reset voit un décalage de 2 cycles. Le reset interne n'est pas non plus filtré comme dans KCPSM3.
- Correction proposée : `reset_internal <= reset_r(0)` (les FF existent déjà) et relâcher les deux resets ensemble dans le TB.
- Confiance : Vérifié

### KC3-B3 — Écart : comportement de la pile en sous-dépassement
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-stack/hdl/stack.vhd:86-92 (via OpenBlaze8_Stack.vhd:61-66) ; kcpsm3.vhd:1389-1404
- Constat : dans KCPSM3, le pointeur de 5 bits est purement cyclique et décrémente à chaque RETURN/RETURNI. Dans OB8, nb_elt sature à 32 ; un RETURN sur pile vide ne décrémente pas le pointeur mais renvoie quand même `ram(ptr-1)`.
- Scénario / justification : 33 CALL puis 34 RETURN. Les 33 premiers RETURN sont identiques. Au 34e, KCPSM3 lit l'entrée `ptr0-1` alors qu'OB8 relit `ptr0` (pointeur bloqué) ; les CALL suivants écrivent ensuite à des adresses différentes. Seul un firmware fautif est concerné, et aucun test ne le couvre (test_032 = 31 niveaux).
- Correction proposée : pointeur cyclique (OB8-S5).
- Confiance : Vérifié

### KC3-B4 — Écart : read_strobe/write_strobe combinatoires dans OB8, registrés dans KCPSM3
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-processor-OpenBlaze8/hdl/OpenBlaze8_Control.vhd:337-338, hdl/OpenBlaze8_LoadStore.vhd:61-62 ; kcpsm3.vhd:1321-1340
- Constat : dans OB8, les strobes valent `décodage(instruction_i) and cycle_phase`, avec instruction_i en sortie de ROM. KCPSM3 les sort directement de FDR.
- Scénario / justification : glitches possibles au changement de phase ou d'instruction, gênants pour un périphérique qui utilise le strobe en logique asynchrone ou comme latch ; chemin combinatoire ROM → décodage → périphérique dans le même cycle ; dans sbi_OpenBlaze8, ce chemin remonte jusqu'au cke de tout le cœur.
- Correction proposée : registrer les strobes (`strobe_r <= inst_x and cycle_0`) : +2 FF, même timing externe que KCPSM3.
- Confiance : Probable (impact selon les périphériques)

**Synthèse kcpsm3**
- L'intégration convient à l'usage TB (fichiers dans work, la VLNV `xilinx:processor:kcpsm:1.30` satisfait la dépendance d'OB8), mais la cible autonome n'a pas les options GHDL nécessaires.
- Aucun écart sur le jeu d'instructions, les flags, la latence et l'ack d'IT, la logique ENABLE pendant une IT (correctif v1.30), l'adressage scratchpad 6 bits, la profondeur de pile 32 ni le timing 2 cycles.
- Écarts relevés : latence de reset (KC3-B2), port_id/out_port valides 1 cycle en REGFILE_SYNC_READ=true (OB8-B2), sous-dépassement de pile (KC3-B3), strobes combinatoires (KC3-B4).

## asylum-soc-picosoc

### SOC-B1 — it_user_i (bouton poussoir) entre dans le GIC sans synchroniseur (régression du commit dbd21c8)
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-soc-picosoc/hdl/PicoSoC_user.vhd:232-233 (GIC_ITS_SYNC_ENABLE), :381, :385-396 ; hdl/PicoSoC_top.vhd:204-214
- Constat : `GIC_ITS_SYNC_ENABLE := (GIC_IT_USER => '0', others => '0')`. it_user_i est relié au pad PA14, le bouton S12 (pads.py:20). Dans le top, il ne traverse qu'un inverseur. sbi_GIC le recopie ensuite tel quel (`gen_syncdff_b`) vers GIC_core : `isr = (imr and its) or isr_i`, échantillonné à chaque cycle (`hw2sw.isr.we='1'`), et `itm_o = reduce_or(isr)` pilote l'interruption du CPU. Le commit dbd21c8 « Move it sync dff into GIC » a supprimé le sync2dff du top, mais il a laissé le bit de synchro à '0' dans le GIC.
- Scénario / justification : un front asynchrone proche du front d'horloge rend la bascule ISR métastable. La valeur passe en combinatoire vers le CPU, avec une seule bascule pour se résoudre. Avec NB_CPU>1, chaque cluster échantillonne le signal indépendamment. De plus, le GIC est sensible au niveau : un appui maintenu (~100 ms) réarme l'ISR après chaque effacement, d'où une rafale d'IT (LED1 s'incrémente des milliers de fois).
- Correction proposée : `GIC_IT_USER => '1'` (2 FF par cluster). Ajouter idéalement une détection de front et un anti-rebond avant le GIC.
- Confiance : Vérifié (constante relue lors de l'assemblage)

### SOC-B2 — pads.py NG-MEDIUM : les noms des ports SPI n'existent pas dans le top
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-soc-picosoc/boards/NanoXplore-DK625V0/pads.py:51-54 vs hdl/PicoSoC_top.vhd:91-93
- Constat : pads.py contraint `spi_sclk_o`, `spi_cs_b_o`, `spi_mosi_o` et `spi_miso_i`. Le top expose `spi_sclk_io`, `spi_cs_b_io` et `spi_io_io(7:0)` (USER_SPI_NB_IO=8, non exposé dans le .core). Aucun des 10 ports SPI n'est donc contraint. options.py force `AllowUnconfiguredIOs='Yes'`, présenté comme un contournement.
- Scénario / justification : soit nxmap rejette les pads inconnus, soit il place librement les 10 IO SPI. Dans les deux cas, la flash SPI de la DK625V0 n'est pas connectée et les cibles emu_ng_medium_*_spi / *_spi_mem ne peuvent pas fonctionner sur carte.
- Correction proposée : renommer en `spi_sclk_io`, `spi_cs_b_io`, `spi_io_io[SPI_IO_MOSI]` et `spi_io_io[SPI_IO_MISO]` (plus WP/HOLD s'ils sont câblés). Exposer USER_SPI_NB_IO dans le .core, aligné sur les lignes réellement câblées (voir SOC-B7). Supprimer ensuite AllowUnconfiguredIOs.
- Confiance : Vérifié pour l'incohérence de noms (relue lors de l'assemblage) ; réaction exacte de nxmap Probable

### SOC-B3 — Lock-step/TMR : le comparateur ignore le bus de données
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-soc-picosoc/hdl/cpu_safety.vhd:207-212 et 259-271 (lignes `--or (cpuX_sbi_ini ...)` commentées), 316-320
- Constat : `diff` ne compare que ics, iaddr et it_ack. En lock-step, la sortie SBI est celle du seul CPU0 (`sbi_ini_o <= cpu0_sbi_ini(0)`).
- Scénario / justification : une faute dans l'ALU ou le banc de registres du CPU0 peut ne pas modifier le flot de contrôle (valeur écrite par OUTPUT/STORE, adresse d'IO calculée). La donnée corrompue part alors vers l'ICN sans diff, donc sans reset par le superviseur. En TMR, le vote masque le CPU qui diverge sur les données mais ne le signale jamais : les fautes s'accumulent en silence jusqu'à une 2e faute.
- Correction proposée : comparer cs, re et we, ainsi que addr et wdata qualifiés par cs (masqués quand cs=0, pour éviter les faux positifs sur des valeurs sans importance). Le pipeline retardé `cpu0_sbi_ini(i)` existe déjà (l.171). Coût : ≈19 XOR et une réduction par paire.
- Confiance : Vérifié

### SOC-B4 — tb_PicoSoC : l'interruption et la sortie UART ne sont jamais vérifiées
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-soc-picosoc/sim/tb_PicoSoC.vhd:95 (alias `led_it` jamais lu), 299-311, 170-173 (`uart_tx_o => open`), 346-349 ; PicoSoC.core:1267 (sim_soc4_*_fault_c_user_uart)
- Constat :
  - La séquence « User Interruption » pulse it_user_i sans aucun check. LED1, incrémentée par l'ISR de user.c, n'est jamais comparée.
  - uart_tx_o n'est pas observé. Les cibles *_c_user_uart, *_uart_spi et *_uart_spi_mem (lecture flash SPI, tests spinlock/mailbox affichés sur l'UART) ne vérifient que la recopie switch→LED.
  - L'étape « Inject error in CPU0 in continue » injecte en réalité sur inject_error_i(1) et se termine sans check.
  - sim_soc4_{openblaze8,wardrv_fsm}_fault_c_user_uart ont USER_FAULT_INJECTION=false : la branche TMR n'est pas exécutée, malgré le nom de la cible.
- Scénario / justification : SOC-B1, une IT jamais servie, ou une régression SPI/spinlock/mailbox passent toutes en vert.
- Correction proposée :
  - après chaque pulse, `await_value(led_it, …)` ;
  - un `uart_expect` UVVM sur uart_tx_o (comme dans tb_PicoSoC_modbus_rtu) ;
  - corriger l'index de l'étape « in continue » et y ajouter un check ;
  - pour les cibles *_fault_c_user_uart, passer USER_FAULT_INJECTION=true ou les renommer.
- Confiance : Vérifié

### SOC-B5 — Les simulations multi-CPU (soc1x2/x4/x6) n'ont aucun critère de succès
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-soc-picosoc/PicoSoC.core:1853-1939 (TEST_SUITE=none) ; sim/tb_PicoSoC.vhd:243-258 et 430-439
- Constat : avec TEST_SUITE="none", le TB attend TB_WATCHDOG_TIME puis rapporte « Test OK », et l'UART n'est pas observée. Le watchdog part un front plus tard : quand il fait `run(1)`, l'horloge est déjà arrêtée par test_done, si bien que son assert ne s'exécute jamais.
- Scénario / justification : ce sont les seules configurations où ICN2 a plusieurs maîtres (arbitrage, spinlock, RAM2 partagée). Un interblocage ICN (cf. MBX-B1, SPI-B1) ou une famine passent en vert.
- Correction proposée : vérifier la sortie UART de user_hello.c, ou un motif en RAM2/LED. Échouer si rien n'est observé avant le watchdog.
- Confiance : Vérifié

### SOC-B6 — Les cibles Basys (ISE) ne sont pas synthétisables
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-soc-picosoc/PicoSoC.core:474-500 et 1319-1345 (default_tool ise, `TARGET: XILINX_UNISIM`)
- Constat : XST (ISE) ne supporte pas VHDL-2008. Or la chaîne en utilise des constructions :
  - éléments de record non contraints dans sbi_pkg ;
  - `process (ALL)` et `or` unaire dans sbi_icn ;
  - `else generate` dans cpu_safety.

  Par ailleurs, target_techmap n'a pas de branche XILINX : le flag fait retomber sur le cbufg générique, qui n'est qu'un fil.
- Scénario / justification : `fusesoc run --target emu_basys_*` échoue dès l'analyse.
- Correction proposée : supprimer ces cibles, ou les porter vers un outil compatible VHDL-2008.
- Confiance : Probable (non exécuté)

### SOC-B7 — USER_SPI_NB_IO < 8 laisse des bits de spi_io_i non pilotés
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-soc-picosoc/hdl/PicoSoC_top.vhd:144, 268-270, 349-360
- Constat : spi_io_i fait 8 bits, mais seuls les bits 0..USER_SPI_NB_IO-1 sont pilotés par les iobuf. Le `resize(...,8)` de la ligne 270 porte sur un vecteur qui fait déjà 8 bits : il ne fait rien. Avec USER_SPI_NB_IO>8, l'indexation sort des bornes.
- Scénario / justification : avec 2 ou 4 lignes (correctif naturel de SOC-B2), io_i(NB_IO..7) vaut 'U' en simulation et n'est pas piloté en synthèse, alors que HANDLE_HOLD_WP=true exploite io(2..3).
- Correction proposée : `resize(unsigned(spi_io_i(USER_SPI_NB_IO-1 downto 0)),8)`, plus `assert USER_SPI_NB_IO <= 8`.
- Confiance : Vérifié

### SOC-B8 — Dans ICN1, la largeur d'adresse de la cible ICN2 est tirée de la largeur de données
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-soc-picosoc/hdl/PicoSoC_user.vhd:162
- Constat : `ICN1_TARGET_ICN2 => CPU_DMEM_DATA_WIDTH` au lieu de CPU_DMEM_ADDR_WIDTH. Or sbi_icn.vhd:292 exige ADDR_WIDTH = addr'length pour un default slave externe.
- Scénario / justification : latent (8 = 8). La simulation échoue et le décodage devient faux dès que SBI_DATA_WIDTH ≠ SBI_ADDR_WIDTH.
- Correction proposée : utiliser CPU_DMEM_ADDR_WIDTH.
- Confiance : Vérifié

### SOC-S1 — Aucun générique ne permet de retirer des périphériques
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-soc-picosoc/hdl/PicoSoC_user.vhd:536-640 (SPI, timer, CRC, spinlock, mailbox, RAM2) et 170-207
- Constat : toutes les cibles emu_* ont USER_NB_CPU=1. Spinlock, mailbox (4 FIFO de 4×8 rebouclées hw2sw<=sw2hw) et RAM2 « partagée » ne servent qu'en multi-CPU. user_modbus_rtu.c n'utilise ni SPI, ni mailbox, ni spinlock, ni RAM2. user.c n'utilise spinlock et mailbox que pour un auto-test affiché sur l'UART.
- Scénario / justification : estimation des gains :
  - mailbox : ≈128 bits de stockage, ~30 FF de pointeurs/compteurs et le CSR (~150-250 FF/LUT) ;
  - RAM2 64×8 : 1 bloc RAM NG-MEDIUM ou 512 FF selon le mapping ;
  - SPI (3 FIFO, 8 lignes) et CRC16 : plusieurs dizaines de FF chacun ;
  - s'y ajoutent les wrappers et décodeurs correspondants d'ICN2.
- Correction proposée : génériques HAVE_SPI / HAVE_CRC / HAVE_TIMER / HAVE_MAILBOX / HAVE_SPINLOCK et RAM2_DEPTH=0, avec mailbox et spinlock par défaut à `NB_CPU>1`. Générer ICN2 sans ces cibles et ajouter les `#ifdef` dans esw. Risque faible : un accès à un périphérique absent lit 0 via le default slave, sans blocage.
- Confiance : Vérifié pour les instanciations ; Probable pour les gains chiffrés

### SOC-S2 — GPIO_irq utilisé pour des sorties pures (LED, reset user)
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-soc-picosoc/hdl/PicoSoC_user.vhd:467-508 ; hdl/PicoSoC_supervisor.vhd:208-249
- Constat : 4 instances de sbi_GPIO_irq ont IRQ_POSEDGE/NEGEDGE=X"00" et data_i constant. Elles conservent quand même les registres isr (rw1c) et imr (rw, relisible donc non élagable) avec leur mux de lecture.
- Scénario / justification : gain ≈8 FF imr + 8 FF isr par instance, soit ~30-60 FF au total. Les FF isr ne disparaissent que si l'outil détecte la constante séquentielle. Même constat que GPIO-S1, vu côté SoC.
- Correction proposée : utiliser sbi_GPIO, ou ajouter un générique IRQ_ENABLE à GPIO_irq (GPIO-S1). Risque : les offsets diffèrent (data à 0x0 vs 0x2), donc les drivers gpio_* sont à adapter.
- Confiance : Vérifié pour la structure ; Probable pour le gain

### SOC-C1 — Avec DEBUG_ENABLE=false, l'horloge et l'état UART sortent sur 8 pads
- Catégorie : Consommation
- Sévérité : Gain Moyen
- Emplacement : asylum-soc-picosoc/hdl/PicoSoC_top.vhd:404-413 ; boards/NanoXplore-DK625V0/pads.py:65-77 (LVCMOS 16 mA)
- Constat : toutes les cibles emu_ng_medium ont DEBUG_ENABLE=false. La branche `gen_debug_b` sort pourtant `clk` (12,5 ou 6,25 MHz), bit_cnt et state du récepteur UART, ainsi que uart_rx et uart_tx.
- Scénario / justification : le seul pad d'horloge consomme ≈ C·V²·f ≈ 10-15 pF × 3,3² × 12,5 MHz ≈ 1,5-2 mW, sans compter le bruit SSO et la sortie de l'horloge globale vers une IO. C'est du même ordre que la dynamique logique d'un cœur 8 bits à 12,5 MHz.
- Correction proposée : `debug_o <= (others => '0')` quand DEBUG_ENABLE=false. Risque nul.
- Confiance : Vérifié

### SOC-C2 — Bus OpenBlaze8 : adresse et données commutent à chaque instruction et partent vers tout le SoC
- Catégorie : Consommation
- Sévérité : Gain Moyen
- Emplacement : asylum-soc-picosoc/hdl/cpu_safety.vhd:316-320 → hdl/PicoSoC_user.vhd:334. Source : OpenBlaze8.vhd:124-126 (`io_addr` = alu_op2, `io_data_write` = alu_op1), OpenBlaze8_LoadStore.vhd:63-64 (isolation commentée l.67-69)
- Constat : addr et wdata changent à chaque instruction ALU, même sans IO. Ils traversent ICN1 (GIC, RAM1) puis ICN2 (10 cibles) sans masquage (voir ICN-C1). Seul cs est qualifié. Voir aussi OB8-C3 (même cause, côté processeur).
- Scénario / justification : 16 nets à fort fanout (~25 récepteurs : décodeurs, mux de lecture CSR, ports d'adresse RAM) ne commuteraient plus que pendant les accès IO, soit quelques % des cycles.
- Correction proposée : un seul point d'isolation par CPU entre cpu_safety et icn1_sbi_inim : `addr/wdata <= … when cs='1' else (others=>'0')`, ou un registre maintenu (≈16 LUT par CPU). À limiter à OpenBlaze8 : les sorties de WardRV sont déjà registrées (dmem2sbi). Risque : +1 niveau de LUT ; ne pas placer l'isolation avant le comparateur lock-step.
- Confiance : Vérifié pour le chemin ; Probable pour le gain

**Synthèse PicoSoC**
- 3 bugs matériels majeurs : IT utilisateur non synchronisée (régression dbd21c8), SPI non contraint sur la carte NG-MEDIUM, lock-step/TMR aveugle au bus de données.
- 2 bugs de testbench majeurs : interruption, sortie UART et multi-CPU ne sont jamais vérifiés, ce qui laisse passer SOC-B1 et les blocages ICN.
- Surface : des génériques HAVE_* pour retirer mailbox, spinlock, RAM2, SPI et CRC des configurations mono-CPU.
- Consommation : neutraliser debug_o quand DEBUG_ENABLE=false et isoler le bus OpenBlaze8.

## asylum-infrastructure_icn

### ICN-B1 — TB : l'arbitrage n'est jamais exercé et les configurations du SoC ne sont pas couvertes
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-infrastructure_icn/sim/tb_sbi_icn.vhd:56-57, 80-81, 171-173, 205-219 ; sim/tb_sbi_icn_suite_pkg.vhd:78-103
- Constat : un seul process enchaîne des sbi_write/sbi_check bloquants, donc les 2 maîtres ne sont jamais actifs en même temps. Contention, famine et double grant ne sont pas testés, et rr_ptr n'a aucun effet observable. Seule la configuration "roundrobin" / "mux" / "binary" / default slave interne est simulée, avec un répondeur `ready=cs` combinatoire. Le SoC utilise au contraire :
  - MASTER_SEL "fix" et TARGET_SEL "or" (zeroing) ;
  - un default slave externe (ICN1) ;
  - des cibles à wait-states (RAM SYNC_READ, CSR busy).
- Scénario / justification : une régression d'arbitrage ou de zeroing "or" passe en vert dans sim_basic et sim_pipe.
- Correction proposée : un process (ou VVC UVVM) par maître avec accès simultanés et vérification de l'ordre et du nombre de grants. Ajouter des génériques de TB pour MASTER_SEL, TARGET_SEL, INTERNAL_DEFAULT_SLAVE et l'encodage, des cibles avec wait-states, et les cibles FuseSoC correspondantes.
- Confiance : Vérifié

### ICN-B2 — Encodage one-hot : les sélections multiples ne sont pas détectées
- Catégorie : Bug
- Sévérité : Mineure (latent, le SoC est en "binary")
- Emplacement : asylum-infrastructure_icn/hdl/sbi_wrapper_target.vhd:102 ; hdl/sbi_icn.vhd:269-276 et 297-309
- Constat : en one_hot, `cs = ini_cs and addr(IDX)`, alors que l'IP reçoit `addr(SIZE_ADDR_IP-1 downto 0)`. Rien ne vérifie que l'IDX de chaque cible est ≥ TARGET_ADDR_WIDTH de toutes les cibles. Le test de recouvrement compare des intervalles binaires, sans signification dans ce mode.
- Scénario / justification : avec la carte d'origine du superviseur en one_hot (LED0 0x10, LED1 0x20, GIC 0x40, RAM 0x80 W=7), un accès RAM à 0x90 sélectionne à la fois RAM et LED0. L'écriture est doublée et, en "or", rdata et ready sont OR-és : lecture corrompue, ou ready anticipé par la cible la plus rapide. Si IDX < TARGET_ADDR_WIDTH de la cible elle-même, la moitié de ses registres devient inaccessible.
- Correction proposée : en one_hot, `assert TARGET_ADDR_WIDTH(t) <= onehot_to_integer(TARGET_ID(u))` pour tout couple (t,u).
- Confiance : Vérifié

### ICN-B3 — busy du mux maître ne retombe que sur ready
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-infrastructure_icn/hdl/sbi_icn_mux_mst.vhd:65, 100, 112
- Constat : si le maître élu retire cs avant ready, plus aucune cible ne voit cs (`cs and busy`). busy reste à 1 et master_id reste figé : les autres maîtres sont bloqués jusqu'au prochain accès de ce maître.
- Scénario / justification : OpenBlaze8 décode idata en combinatoire. Une injection de faute (inject_error_i asynchrone, XOR sur l'opcode) pendant un accès bloqué (mailbox, SPI) fait chuter cs. Sur ICN2 multi-maîtres, les autres CPU sont gelés, et sans superviseur (cibles soc2 *fault*) rien ne les réinitialise.
- Correction proposée : `elsif sbi_tgt_i.ready='1' or sbi_inis_i(master_id).cs='0' then busy <= '0';`, plus une assertion de protocole en simulation.
- Confiance : Vérifié pour le code ; Probable pour le scénario

### ICN-B4 — Une cible de largeur 0 est rejetée à tort en simulation
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-infrastructure_icn/hdl/sbi_icn.vhd:281
- Constat : avec TARGET_ADDR_WIDTH=0 (périphérique à un registre, RAM DEPTH=1), la tranche est nulle. Le `"/="(unsigned nul, natural)` de numeric_std renvoie alors TRUE, ce qui déclenche « ID must have the lower 0 bits set to 0 » en `severity failure`.
- Scénario / justification : toute cible à registre unique fait échouer la simulation dès l'élaboration.
- Correction proposée : `if TARGET_ADDR_WIDTH(tgt) > 0 and …`.
- Confiance : Vérifié (lecture, non exécuté)

### ICN-S1 — Arbitre inutile quand NB_MASTER=1
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-infrastructure_icn/hdl/sbi_icn_mux_mst.vhd:47-71, 109-118
- Constat : avec NB_MASTER=1 (ICN1 de chaque cluster, ICN du superviseur), le registre busy et l'élection sont quand même instanciés. Ils imposent un cycle d'arbitrage puis un cycle de bulle par transaction, soit +2 cycles par IO périphérique via ICN1→ICN2.
- Scénario / justification : gain d'environ 1 FF et ~3 LUT par ICN, et surtout −1 cycle de stall CPU par accès.
- Correction proposée : `gen_single: if NB_MASTER=1 generate sbi_ini_o <= sbi_inis_i(0); sbi_tgts_o(0) <= sbi_tgt_i;`. Risque : c'est aujourd'hui la bulle d'ICN1 qui empêche un CPU prioritaire de monopoliser ICN2 en "fix". Si on la supprime, passer ICN2 en "roundrobin" quand NB_CPU>1.
- Confiance : Vérifié

### ICN-S2 — sbi_pipe registre tout le record cible, y compris info.name (128 bits)
- Catégorie : Surface
- Sévérité : Gain Faible (seulement avec PIPEIN/PIPEOUT activés)
- Emplacement : asylum-infrastructure_icn/hdl/sbi_pipe.vhd:78, 94
- Constat : `sbi_tgt_o <= sbi_tgt_i` capture rdata, ready et info.name : une string(1 to 16), soit 128 bits constants, sans reset. Les champs non resetés dans un process à reset asynchrone ajoutent aussi un enable « not reset ».
- Scénario / justification : jusqu'à 128 FF par pipe si l'outil ne propage pas la constante (non vérifié pour nxmap).
- Correction proposée : ne registrer que rdata et ready, et passer info.name en combinatoire.
- Confiance : Probable

### ICN-C1 — Adresse, données, re et we sont diffusés à toutes les cibles, même au repos
- Catégorie : Consommation
- Sévérité : Gain Moyen
- Emplacement : asylum-infrastructure_icn/hdl/sbi_icn_mux_mst.vhd:111 ; hdl/sbi_wrapper_target.vhd:141-145
- Constat : mux_mst recopie `sbi_inis_i(master_id)` même quand busy=0 ; seul cs est masqué. Chaque wrapper transmet addr locale, wdata, re et we à son IP quel que soit cs. Toute commutation côté maître (cf. SOC-C2) atteint donc les décodeurs, les mux de lecture CSR et les ports RAM des deux niveaux d'ICN.
- Scénario / justification : sur ICN2 (10 cibles), ~18 nets × 10 charges ne commuteraient plus que pendant les transactions.
- Correction proposée : masquer addr, wdata, re et we par busy dans mux_mst (≈18 LUT par ICN), ou les tenir dans un registre chargé au grant. Ne masquer par cs dans le wrapper que pour les cibles coûteuses comme les RAM, car cela coûte ~(W+10) LUT par cible. Risque : +1 LUT sur le chemin addr→décodage. Le zeroing par cs en mode "or" reste nécessaire, car les CSR générés calculent rdata et `ready = not busy` même sans cs.
- Confiance : Vérifié pour les chemins ; Probable pour le gain

**Synthèse ICN**
- Décodage binaire et mux de réponse "or" corrects pour la carte actuelle.
- Le défaut principal est le TB : l'arbitrage n'est jamais exercé et les configurations "fix", "or" et default slave externe du SoC ne sont pas couvertes.
- Bugs latents : recouvrement one-hot non vérifié, busy figé si cs tombe, cible de largeur 0 rejetée.
- Gains : masquer le bus au repos (consommation) et supprimer l'arbitre quand NB_MASTER=1 (−1 cycle par accès).

## asylum-target-techmap

### TMAP-B1 — Les synchroniseurs n'ont aucun attribut de protection et pas de variante NG-MEDIUM
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-target-techmap/hdl/generic/sync2dff.vhd:41-52 ; hdl/generic/sync2dffrn.vhd:42-57 (repris tels quels par target_ng_medium.core)
- Constat : aucun attribut ASYNC_REG, syn_preserve, keep ou dont_touch, et aucune contrainte de placement rapproché. Les outils peuvent donc retimer, dupliquer ou fusionner la 1re bascule. sync2dff (sans reset) est un registre à décalage de 2 que les flots Xilinx peuvent inférer en SRL.
- Scénario / justification : le MTBF n'est pas garanti alors que ces cellules servent aux resets (PicoSoC_top), à cts (UART), à la CDC du debug WardRV, et à l'IT du GIC une fois SOC-B1 corrigé.
- Correction proposée : attributs sur q_r (ASYNC_REG, syn_keep/syn_preserve et l'équivalent nxmap), plus un faux chemin sur d_i documenté.
- Confiance : Probable (dépend du comportement des outils)

### TMAP-B2 — cgate sur NG-MEDIUM : un latch et un AND en logique générale
- Catégorie : Bug
- Sévérité : Mineure (cellule non instanciée aujourd'hui)
- Emplacement : asylum-target-techmap/target_ng_medium.core:37 ; hdl/generic/cgate.vhd:47-56
- Constat : la cible NG-MEDIUM réutilise la cellule générique : un latch transparent sur clk_i bas suivi d'un AND en LUT. L'horloge quitte le réseau global, le latch est réalisé en logique (boucle combinatoire si la fabric n'en a pas), et il échappe à la STA ; un glitch est possible via le skew entre clk_i et cke_l. cbufg a pourtant une version NX dédiée : les deux cibles ne sont pas équivalentes en implémentation.
- Scénario / justification : le premier usage, déjà annoncé dans spi_master.vhd:477 (« need cgate »), produirait une horloge dérivée non fiable sur NG-MEDIUM.
- Correction proposée : une implémentation NG-MEDIUM sur primitive d'horloge (NX_GCK en mode gating, ou WFG avec enable). À défaut, un `assert false severity failure` dans la version NG.
- Confiance : Probable

**Synthèse techmap**
- Seul cbufg diffère entre générique et NG-MEDIUM, et il est équivalent fonctionnellement.
- Synchroniseurs et cgate sont partagés sans adaptation NG-MEDIUM : pas d'attributs anti-optimisation, et un clock gating en logique impropre sur FPGA.
- Rien de bloquant aujourd'hui, mais c'est à traiter avant d'activer la synchro IT (SOC-B1) et le clock gating.

## asylum-communication-spi

### SPI-B1 — Le bus SBI peut se bloquer définitivement : accès bloquants, sans registre d'état ni timeout
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-communication-spi/hdl/csr/SPI.hjson:44-49,68-72 ; hdl/sbi_SPI.vhd:39-41 ; hdl/spi_master.vhd:395
- Constat : `data` et `cmd` sont des `csr_fifo` en BLOCKING_READ/WRITE. Avec `DEPTH_*=0` (valeur par défaut de `sbi_SPI`), `sbi_tgt_o.ready` suit directement le tready/tvalid du maître (branches `gen_depth_*_eq_0` de csr_fifo). Aucun registre n'expose les niveaux des FIFO ni un état busy : les signaux `sw2hw_empty/full` existent dans `SPI_sw2hw_t` mais aucun registre ne les porte. Enfin, POSTAMBLE reste bloqué tant que `rx_tvalid_r=1`.
- Scénario / justification : avec DEPTH_TX=DEPTH_RX=0, une commande full-duplex de 3 octets ou plus, où le logiciel écrit tous les octets TX puis lit les RX (c'est la séquence de `test_single` du tb basic) : RX0 est poussé, puis START de l'octet 1 accepte TX1 ; POSTAMBLE de l'octet 1 attend la lecture de RX0 ; pendant ce temps, le CPU est figé dans l'écriture de TX2, qui attend START de l'octet 2. C'est un interblocage : même l'écriture de `cfg` devient impossible, seul le reset global débloque. En général, la séquence « tout écrire puis tout lire » se bloque dès que N > DEPTH_TX + DEPTH_RX + 2 (le mode KEEP autorise 64 octets). Le même blocage se produit si l'on écrit `cmd`/`data` avec `spi_enable=0` et DEPTH=0, ou si l'on lit `data` sans commande RX en cours.
- Correction proposée : ajouter un registre `status` en lecture seule exposant les flags empty/full de data/cmd et un bit busy (l'adressage passe à 3 bits). Documenter la contrainte d'entrelacement écriture/lecture. Alternative : passer en non bloquant avec ces flags de statut.
- Confiance : Vérifié

### SPI-B2 — Le logiciel ne peut pas savoir quand une transaction est finie ; `spi_enable=0` la coupe et laisse CS#/SCLK flottants
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-communication-spi/hdl/sbi_SPI.vhd:104,165 ; hdl/spi_master.vhd:189-193 ; hdl/csr/SPI.hjson:135-170
- Constat : `cfg.spi_enable` sert de reset asynchrone à `spi_master`. Aucun bit n'indique la fin d'une transaction. En reset, `cs_b_oe`, `sclk_oe` et `io_oe` passent à 0 : CS# n'est pas forcé à 1, il flotte. Les FIFO CSR sont remises à zéro par `arst_b_i` global, pas par `spi_enable` : elles ne sont pas vidées.
- Scénario / justification : le logiciel pousse WREN puis PP (TX seul, last=1) et écrit ensuite `cfg` pour désactiver ou pour changer CPOL/CPHA/prescaler : le transfert est coupé au milieu d'un octet et, sans pull-up sur la carte, CS# flotte. À la réactivation, les commandes restées en FIFO partent immédiatement (c'est l'état laissé par le test 5 du tb basic).
- Correction proposée : ajouter un bit `status.busy` = (state_r≠IDLE ou cs_b_r=0 ou FIFO cmd non vide). Quand l'IP est désactivée, garder les OE de CS# et SCLK actifs avec CS#=1 et SCLK=CPOL. Vider les FIFO lorsque `spi_enable=0`.
- Confiance : Vérifié

### SPI-B3 — CS# peut ne rester haut qu'une seule période SCLK entre deux transactions (tSHSL)
- Catégorie : Bug
- Sévérité : Mineure (Majeure si ratio ≤ 1 avec des flashs à tSHSL long)
- Emplacement : asylum-communication-spi/hdl/spi_master.vhd:429-436 (DONE), 263-267 (START)
- Constat : CS# remonte sur un `bit_sample` (DONE). Si une commande attend déjà en FIFO, il redescend au `bit_sample` suivant. Le temps CS# haut vaut donc 2·(ratio+1)·Tclk et n'est pas paramétrable.
- Scénario / justification : à 50 MHz, CS# reste haut 40 ns avec ratio=0 et 80 ns avec ratio=1. Or M25P40 demande tSHSL ≥ 100 ns et S25FL512S tCS ≥ 50 ns hors lecture. Une séquence STOP suivie d'une nouvelle commande, préchargées dans DEPTH_CMD, viole donc ce temps. Le tb models ne le voit pas car le CPU ajoute plusieurs cycles SBI entre les deux.
- Correction proposée : ajouter un compteur de garde « CS high » (générique ou champ CSR) en DONE/IDLE avant d'autoriser START.
- Confiance : Probable

### SPI-B4 — HOLD#/WP# sont pilotés à 0 hors transaction et basculent sur le même front que CS#
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-communication-spi/hdl/spi_master.vhd:205-211, 314-320, 438-444
- Constat : avec `HANDLE_HOLD_WP=true`, HOLD# et WP# sont pilotés à '0' (actifs) en reset et après DONE. Ils repassent à '1' sur le même front que la descente de CS# (START) et retombent sur le même front que sa remontée (DONE). Le README documente « low in reset ».
- Scénario / justification : avec un skew pad/routage, le flash peut voir CS#=0 et HOLD#=0 avec SCK bas : il entre et sort d'un état hold parasite en début de trame. WP#=0 au front montant de CS# d'un WRSR peut faire rejeter l'écriture du registre d'état en protection matérielle (SRWD=1).
- Correction proposée : piloter HOLD#/WP# à '1' en reset, IDLE et DONE, et ne les relâcher que pour les phases quad/octal.
- Confiance : Probable

### SPI-B5 — MISO n'a qu'une demi-période SCLK d'aller-retour, sans registres d'E/S
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-communication-spi/hdl/spi_master.vhd:370-378, 471-472, 477
- Constat : MISO et les IO sont échantillonnés sur le front clk qui bascule `sclk_r`. Le budget aller-retour vaut donc (ratio+1)·Tclk − (clk→pad + tV flash + pad d'entrée + setup). De plus, `sclk_o` est un XOR combinatoire (il ne sort pas d'un FF) et `io_i` n'est pas registré.
- Scénario / justification : ratio=0 est autorisé et testé. À 50 MHz cela laisse 20 ns pour un tV d'environ 6-8 ns plus deux traversées de pads NG-MEDIUM : la marge est quasi nulle. Au-delà d'environ 60 MHz, c'est impossible. La simulation à délai nul ne le détecte pas.
- Correction proposée : ajouter une option « sample delay » ; faire sortir `sclk_o` d'un registre et registrer `io_i` en IOB ; ajouter une contrainte multicycle et documenter le ratio minimal.
- Confiance : Probable

### SPI-B6 — Une commande KEEP avec last=1 devient un STOP si la configuration sauvegardée a tx=rx=0
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-communication-spi/hdl/spi_master.vhd:246-251 ; hdl/sbi_SPI.vhd:131-137
- Constat : STOP est décodé sur les `enable_rx/tx` effectifs. En mode KEEP, ces valeurs viennent des registres sauvegardés.
- Scénario / justification : une configuration dummy (tx=rx=0) suivie d'une commande KEEP avec last=1 et nb_bytes=N donne un STOP : les N+1 octets dummy ne sont pas générés et CS# remonte aussitôt.
- Correction proposée : ne décoder STOP que si cfg=0, en calculant `cmd_stop` dans `sbi_SPI` à partir des champs bruts.
- Confiance : Vérifié

### SPI-B7 — tb models : la boucle de polling RDSR n'est pas bornée et compare tout SR1
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-communication-spi/sim/models/tb_SPI.vhd:555-562
- Constat : la boucle est `while rdata /= x"00"`, sans limite d'itérations, alors qu'elle ne devrait tester que WIP (bit 0).
- Scénario / justification : si un bit P_ERR, E_ERR, BP ou SRWD est à 1, la simulation boucle jusqu'au timeout CI au lieu d'échouer proprement.
- Correction proposée : tester `rdata(0)`, borner la boucle et lever un `alert(ERROR)` en cas de dépassement.
- Confiance : Vérifié

### SPI-S1 — La logique dual/quad/octal est toujours synthétisée
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-communication-spi/hdl/spi_master.vhd:98-99, 280-292, 337-350, 375-378, 455-456 ; hdl/sbi_SPI.vhd:107,133
- Constat : sont toujours présents : `io_o_r` et `io_oe_r` sur 8 bits chacun ; des mux 4:1 sur `data_tx_r` et `data_rx_r` ; le décalage `cnt_bit_off` et un additionneur 4 bits ; `cmd_size_r` en double (spi_master et sbi_SPI). Le mode octal n'est testé par aucun tb.
- Scénario / justification : en SPI simple, on économise environ 10-16 FF et 25-35 LUT (LUT4), soit environ 20 % de `spi_master`. En quad maximum, environ 8 FF et 10 LUT. Risque faible.
- Correction proposée : ajouter un générique `MAX_LANES` (1/2/4/8, défaut 8 = comportement actuel) qui borne les vecteurs et les mux.
- Confiance : Vérifié

### SPI-S2 — Compteur d'octets doublé
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-communication-spi/hdl/spi_master.vhd:108, 119, 243, 405-421
- Constat : `cnt_byte_r` (6 FF, en incrément) coexiste avec `cmd_nb_bytes_r` (6 FF) et un comparateur d'égalité 6 bits.
- Scénario / justification : un seul décompteur chargé en IDLE et testé à zéro suffit. Gain d'environ 6 FF et 3-4 LUT. Risque très faible.
- Correction proposée : remplacer le couple par ce décompteur.
- Confiance : Vérifié

### SPI-S3 — Registres KEEP dupliqués entre sbi_SPI et spi_master
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-communication-spi/hdl/sbi_SPI.vhd:105-133 ; hdl/spi_master.vhd:241-244
- Constat : `sbi_SPI` mémorise `enable_tx/rx` et `size` (4 FF + 4 mux) alors que `spi_master` les mémorise déjà dans `cmd_*_r`.
- Scénario / justification : gain d'environ 4 FF et 4 LUT, et suppression d'un reset logiciel. Cela corrige aussi SPI-B6. Risque faible.
- Correction proposée : ajouter une entrée `cmd_keep_i` à `spi_master` qui empêche le rechargement de ces champs.
- Confiance : Vérifié

### SPI-S4 — 11 FF sans reset dans un process à reset asynchrone
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-communication-spi/hdl/spi_master.vhd:116-120, 240-244 (absents du bloc reset 187-211)
- Constat : `cmd_tlast_r`, `cmd_enable_rx_r`, `cmd_enable_tx_r`, `cmd_nb_bytes_r` et `cmd_size_r` ne sont pas remis à zéro. Garder leur valeur pendant le reset impose un clock-enable dérivé de `arst_b_i` (= `spi_enable`). En simulation, `cmd_size_r='U'` provoque une métavaleur dans `to_integer`.
- Scénario / justification : gain d'environ 3-6 LUT. Risque nul.
- Correction proposée : les ajouter au reset.
- Confiance : Vérifié

### SPI-C1 — Prescaler en roue libre en IDLE
- Catégorie : Consommation
- Sévérité : Gain Moyen
- Emplacement : asylum-communication-spi/hdl/spi_master.vhd:145-174
- Constat : le compteur 8 bits, `cycle_phase_r` et les impulsions posedge/negedge tournent en permanence dès que `spi_enable=1`. Le code le note lui-même en TODO.
- Scénario / justification : en idle, c'est quasiment toute l'activité de l'IP (environ 2 basculements de FF par cycle plus le comparateur). Un contrôleur de flash est idle la plupart du temps.
- Correction proposée : en IDLE, forcer `prescaler_cnt_r <= ratio` et `cycle_phase_r <= '0'`. START et DONE attendent un front S, donc le protocole n'est pas modifié. Risque faible, à une réserve près : cela réduit encore le temps CS# haut, à combiner avec SPI-B3.
- Confiance : Vérifié

### SPI-C2 — Basculements inutiles à chaque octet
- Catégorie : Consommation
- Sévérité : Gain Faible
- Emplacement : asylum-communication-spi/hdl/spi_master.vhd:272, 335-351, 370-379
- Constat : (a) START remet `io_o_r` à 0 à chaque octet, et en CPHA=0 le front H9 sort les zéros décalés : MOSI (ou IO0-3 en quad) repasse à 0 entre les octets. (b) `data_rx_r` est décalé même quand `enable_rx=0`.
- Scénario / justification : (a) jusqu'à 2 transitions de pad par octet sur une charge de 10-20 pF, soit environ 15-25 % des transitions MOSI. (b) 8 FF basculent inutilement pendant les transferts TX seuls.
- Correction proposée : ne pas effacer `io_o_r`, puisque seul `io_oe` compte. Conditionner le décalage RX par `cmd_enable_rx_r or cfg_loopback_i`. Risque nul.
- Confiance : Vérifié

**Synthèse SPI**
- Le moteur de protocole (CPOL/CPHA, MSB first, dual/quad/octal, dernier bit, CS#) est correct d'après la trace temporelle.
- Les vrais risques sont au niveau système : accès SBI bloquants sans statut ni timeout (interblocage du CPU avec DEPTH=0 par défaut), absence d'indication busy, et `spi_enable` utilisé comme reset.
- Côté timing flash, à vérifier selon le composant : temps CS# haut d'une seule période SCLK, HOLD#/WP# basculés en même temps que CS#, et demi-période seulement pour l'aller-retour MISO.
- Le principal gain de surface est un générique `MAX_LANES` (environ 20 % de `spi_master`). Pour la consommation : geler le prescaler en IDLE et ne plus remettre MOSI à 0 entre les octets.

## asylum-communication-uart

### UART-B1 — L'entrée RX n'est pas synchronisée
- Catégorie : Bug
- Sévérité : Critique
- Emplacement : asylum-communication-uart/hdl/sbi_uart.vhd:319-320 ; hdl/uart_rx_axis.vhd:129-147,156
- Constat : `uart_rx_i` attaque directement la FSM RX (transition IDLE→START, test de faux start et décalage). À l'inverse, CTS# passe bien par `sync2dffrn` (l.147-153). Confirmé aussi côté SoC : `asylum-soc-picosoc/hdl/PicoSoC_top.vhd:273` fait `uart_rx <= uart_rx_i` sans synchroniseur.
- Scénario / justification : métastabilité sur l'entrée ; `state_r` peut prendre un code incohérent, surtout si la synthèse l'encode en one-hot, et la branche `others` est souvent supprimée par l'outil : la RX peut se verrouiller. En START, le même échantillon asynchrone sert à la fois au test de faux start et au décalage.
- Correction proposée : synchroniser sur 2 FF à reset '1' avant le mux de loopback, par exemple `sync2dffrn` sur `not uart_rx_i` puis inversion, puisque `sync2dffrn` se remet à '0'. Ajouter éventuellement un filtre majoritaire et compenser la latence au demi-bit (voir UART-S3).
- Confiance : Vérifié

### UART-B2 — TX signale ready sans charger l'octet : perte silencieuse avec CTS# inactif ou TX désactivé
- Catégorie : Bug
- Sévérité : Critique
- Emplacement : asylum-communication-uart/hdl/uart_tx_axis.vhd:174, 214-215 ; hdl/sbi_uart.vhd:219, 238, 324
- Constat : `s_axis_tready_o = not uart_tx_active_r`, alors que le chargement exige aussi `uart_cts_b_i='0'`. Par ailleurs `tx_enable` sert de reset et force `active_r=0`, donc tready=1 pendant le reset.
- Scénario / justification : (1) avec `cts_enable=1` et CTS# inactif, la FIFO TX est vidée à raison d'un octet par cycle sans rien émettre ; en DEPTH_TX=0, l'écriture SBI se termine sans erreur. (2) Avec `tx_enable=0`, qui est la valeur de reset, tout octet écrit avant l'activation est jeté. (3) L'écho `tx_use_loopback` a le même défaut. tb_uart ne teste jamais CTS ni la désactivation de TX.
- Correction proposée : tready = `not active_r and not uart_cts_b_i and enabled`, où `enabled` est un FF qui vaut '0' en reset. Ajouter les tests correspondants.
- Confiance : Vérifié

### UART-B3 — Débordement RX silencieux, RTS# retiré trop tard
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-communication-uart/hdl/uart_rx_axis.vhd:165-181 ; hdl/sbi_uart.vhd:279-281
- Constat : l'état STOP écrit `tdata` et `tvalid` sans vérifier qu'un octet attend déjà. Si la FIFO est pleine, ou si DEPTH_RX=0 (défaut) et que le logiciel n'a pas lu l'octet, celui-ci est écrasé. C'est une violation AXIS et aucun flag d'overrun n'existe. RTS# n'est retiré qu'à FIFO pleine.
- Scénario / justification : avec RTS, le correspondant envoie souvent encore 1 à 3 octets après le retrait. Il ne reste qu'un octet de marge, celui de `m_axis_tdata_o`, donc on perd des données malgré le contrôle de flux.
- Correction proposée : ajouter un flag d'overrun persistant, lu par registre de statut et source d'IT, sans écraser l'octet en attente. Retirer RTS# à un seuil « presque plein » (DEPTH−k) à partir de `nb_elt`.
- Confiance : Vérifié

### UART-B4 — Bit de stop jamais vérifié, erreurs de trame et de parité invisibles pour le logiciel
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-communication-uart/hdl/uart_rx_axis.vhd:165-178 ; hdl/sbi_uart.vhd:312
- Constat : l'échantillon `uart_rx_data_r(BIT_STOP)` n'est jamais lu. `parity_error_o` est laissé `open`, seulement visible en debug, et ne porte que sur la dernière trame, pas sur l'octet lu en FIFO.
- Scénario / justification : ligne en break, ou débranchée sans pull-up : après chaque STOP la FSM repasse IDLE→START et produit un flot continu de 0x00 valides, qui déclenche aussi l'IT. Un stop à 0 donne un octet faux puis une resynchronisation sur un faux start. Activer la parité RX n'a aucun effet visible par le logiciel.
- Correction proposée : calculer `framing_error = not stop`. Stocker {break, trame, parité} avec l'octet (FIFO de 11 bits) ou dans des bits persistants d'un registre de statut avec IT. Après une erreur de trame, attendre que la ligne revienne à 1.
- Confiance : Vérifié

### UART-B5 — Les sources d'interruption TX sont inexploitables et il n'y a pas de registre d'état
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-communication-uart/hdl/sbi_uart.vhd:358-366 ; hdl/csr/UART.hjson:32-65
- Constat : les sources sont {rx_full, rx_not_empty, tx_full, tx_not_empty}. Il n'existe aucune source « TX vide » ou « TX non pleine ». Avec DEPTH_TX=0, tx_full et tx_not_empty valent tous deux « émetteur occupé ». La lecture de `data` est bloquante.
- Scénario / justification : un driver TX piloté par interruption est impossible. Lire `data` sans caractère disponible bloque le CPU indéfiniment.
- Correction proposée : remplacer `it_tx_empty_b` par `tx_empty` et/ou `tx_not_full`. Ajouter un registre de statut en lecture seule à l'adresse libre x3.
- Confiance : Vérifié

### UART-B6 — RTS# combinatoire, sujet aux glitchs
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-communication-uart/hdl/sbi_uart.vhd:279-281, 358
- Constat : `uart_rts_b_o` vaut le flag full de `fifo_sync`, calculé par comparaison combinatoire des pointeurs, et sort sur un pad sans registre.
- Scénario / justification : lors des transitions multi-bits des pointeurs, des glitchs apparaissent sur RTS#. Un 16550 en face peut les voir comme des changements de CTS (delta-CTS).
- Correction proposée : ajouter un FF de sortie.
- Confiance : Probable

### UART-B7 — Mise à jour non atomique du diviseur de baud sur 16 bits
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-communication-uart/hdl/csr/UART.hjson:164-200 ; hdl/sbi_uart.vhd:182-183
- Constat : le diviseur est fait de deux registres 8 bits (LSB et MSB) appliqués immédiatement.
- Scénario / justification : en changeant le débit pendant une trame, une valeur intermédiaire {MSB ancien, LSB nouveau} est utilisée et produit un bit de durée erronée.
- Correction proposée : passer par un registre shadow chargé à l'écriture du MSB, ou documenter qu'il faut désactiver TX/RX avant le changement.
- Confiance : Vérifié

### UART-S1 — Compteurs de baud figés à 16 bits, le générique BAUD_TICK_CNT_WIDTH est inutilisable
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-communication-uart/hdl/sbi_uart.vhd:48, 94, 134, 208, 293 ; hdl/csr/UART.hjson:16
- Constat : `baud_tick_cnt_max` est déclaré sur 16 bits et branché sur un port de `BAUD_TICK_CNT_WIDTH` bits, et le générique CSR est fixé à (15 downto 0). Toute autre valeur casse l'élaboration. Les deux compteurs restent donc à 16 bits, même quand `USER_DEFINE_BAUD_TICK=false` où le maximum est une constante.
- Scénario / justification : à 50 MHz / 115200, 9 bits suffisent, soit environ −14 FF et −15 LUT (comparateurs =0 et =M/2, mux de rechargement). Risque faible.
- Correction proposée : prendre une largeur effective `clog2(BAUD_TICK_CNT_MAX_INT+1)` quand le diviseur est fixe, et faire un `resize` de `baud_tick_cnt_max`.
- Confiance : Vérifié

### UART-S2 — Compteurs de bits en code thermomètre de 10 bits (TX et RX)
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-communication-uart/hdl/uart_tx_axis.vhd:166, 211-235 ; hdl/uart_rx_axis.vhd:82, 117-160
- Constat : TX et RX ont chacun un compteur thermomètre de 10 FF à côté de leur registre à décalage.
- Scénario / justification : une sentinelle suffit. En TX, on décale des '0' et la fin est détectée quand `data_r(MSB..1)=0`. En RX, un marqueur '1' préchargé atteint le bit 0. Gain d'environ −18 FF pour +3 LUT. Risque faible à moyen à cause de la longueur de trame variable avec la parité.
- Correction proposée : remplacer les deux compteurs par cette sentinelle.
- Confiance : Vérifié

### UART-S3 — Comparateur de demi-bit sur 15 bits, échantillonnage RX en retard
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-communication-uart/hdl/uart_baud_rate_gen.vhd:47, 54, 83-86
- Constat : le demi-bit est détecté par `cnt = max/2`, un comparateur 15 bits plus 1 FF. Le premier échantillon tombe environ 4 cycles après le milieu théorique du bit de start.
- Scénario / justification : précharger le compteur avec max/2 − latence au démarrage, puis max à chaque rechargement, supprime le comparateur (environ −6 LUT, −1 FF) et compense la latence, y compris celle ajoutée par la correction d'UART-B1. Risque faible.
- Correction proposée : faire de l'événement `cnt=0` l'instant d'échantillonnage.
- Confiance : Vérifié

### UART-C1 — Générateur de baud TX en roue libre
- Catégorie : Consommation
- Sévérité : Gain Moyen
- Emplacement : asylum-communication-uart/hdl/sbi_uart.vhd:211
- Constat : `tx_baud_tick_en <= '1'` : le compteur 16 bits tourne en permanence dès `tx_enable=1`, même FIFO vide. Le générateur RX, lui, est déjà gaté.
- Scénario / justification : en idle, cela représente l'essentiel de la puissance dynamique de l'IP hors arbre d'horloge (environ 2 basculements de FF par cycle plus le comparateur 16 bits).
- Correction proposée : `en = tx_active or tx_tvalid`. La détection de front recharge le compteur, donc le premier bit de start part M+1 cycles après l'arrivée de la donnée et le bit de stop reste d'au moins un bit. Risque faible.
- Confiance : Vérifié

**Synthèse UART**
- Deux bugs critiques : RX non synchronisé (y compris dans `PicoSoC_top`) et TX qui accepte l'octet sans le charger, d'où des pertes avec CTS# ou TX désactivé. tb_uart ne couvre ni CTS, ni RTS, ni l'overrun.
- Le logiciel ne voit aucune erreur RX : overrun silencieux, bit de stop non vérifié (break → 0x00 en boucle), parité non remontée. Les interruptions TX sont inexploitables et il n'y a pas de registre d'état.
- Pour la surface, rendre la largeur des compteurs de baud réellement paramétrable (environ −14 FF) et utiliser une sentinelle à la place des compteurs thermomètre. Pour la consommation, couper le générateur de baud TX hors émission.

## asylum-component-gpio

### GPIO-B1 — Détection de front sur une broche non synchronisée
- Catégorie : Bug
- Sévérité : Critique
- Emplacement : asylum-component-gpio/hdl/GPIO_irq_core.vhd:77,107-122 (et asylum-system-gic/hdl/GIC_core.vhd:56)
- Constat : `data_in` est `data_i` brut, sans registre. `data_in_posedge <= data_in and not data_in_r` passe en combinatoire par `GIC_core` (`isr = (imr and its) or isr_i`) jusqu'à l'entrée D des bascules `isr` (csr_reg rw1c, `hw_we='1'`). `data_in_r` est la seule bascule, et elle sert de référence au front, pas de synchroniseur.
- Scénario / justification : une broche bascule près du front d'horloge. `data_in_r` voit déjà la nouvelle valeur, mais le chemin plus long vers `isr` voit encore l'ancienne. Le front n'est vu à '1' sur aucun cycle et l'événement est perdu. Dans l'autre ordre, on obtient un `isr` métastable ou un événement en double. PicoSoC est touché directement : `switch_i` arrive des pads sans synchronisation (PicoSoC_user.vhd:444-458, IRQ_POSEDGE et IRQ_NEGEDGE à X"FF").
- Correction proposée : instancier `sync2dffrn` (asylum-target-techmap/hdl/generic/sync2dffrn.vhd) pour chaque ligne, dans une boucle generate sur NB_IO. Faire ensuite `data_in <= resize(data_sync)` et calculer le front entre `data_sync` et `data_sync_r`. Ajouter la dépendance `asylum:target:techmap`. Coût : +2 FF par ligne (le FF de front existe déjà).
- Confiance : Vérifié

### GPIO-B2 — Lecture des broches sans synchroniseur (0 FF en version irq, 1 FF sinon)
- Catégorie : Bug
- Sévérité : Majeure (sbi_GPIO_irq) / Mineure (sbi_GPIO)
- Emplacement : asylum-component-gpio/hdl/GPIO_irq_core.vhd:83-84 ; asylum-component-gpio/hdl/GPIO_core.vhd:83-88 (+ hdl/csr/GPIO.hjson:50-64)
- Constat : en version irq, `data` est un registre `ext` : `csr_ext` fait `sw_rd_o <= hw_wd_i`. Le chemin va donc en pur combinatoire du pad à `sbi_tgt_o.rdata`, puis à l'ICN, puis au registre du CPU. En version non-irq, il n'y a qu'une seule bascule (`data_in`, csr_reg "ro", `hw_we='1'`), suivie des muxes CSR et ICN.
- Scénario / justification : métastabilité possible dans le CPU. Une lecture sur 8 bits peut aussi être incohérente, les bits n'étant pas échantillonnés au même instant. Avec une seule bascule, le temps de résolution laissé est égal à la période moins le chemin de bus.
- Correction proposée : en irq, lire `data_sync` (le synchroniseur de GPIO-B1 sert aux deux usages). En non-irq, ajouter un étage avant le registre CSR `data_in`, qui devient ainsi le 2e étage (+1 FF par ligne).
- Confiance : Vérifié

### GPIO-B3 — Effacement W1C de l'ISR simultané à un front : l'événement est perdu
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-component-gpio/hdl/GPIO_irq_core.vhd:124 ; asylum-utils-generators/tools/regtool/hdl/csr_reg.vhd:90-98
- Constat : `hw2sw_o.isr.we <= '1'` en permanence et le modèle rw1c calcule `q_next = d_hw and not wd`. Si le logiciel écrit 1 sur le bit i au cycle même où un front arrive sur la ligne i, le bit est remis à 0. Le front ne dure qu'un cycle et ne sera jamais représenté.
- Scénario / justification : une ISR classique fait `v=ISR; ISR=v;`. Un nouveau front sur la même ligne pendant le cycle d'écriture est perdu définitivement.
- Correction proposée : donner la priorité au matériel, soit `isr_next = (isr and not clr) or (imr and its)`. Côté générateur, cela revient à fournir à rw1c une entrée « set » au lieu de la valeur complète (voir GEN). Contournement possible dans l'IP : `its_hold_r <= gic_it`, puis `its = gic_it or (its_hold_r and sw2hw_i.isr.we)` (+1 FF par ligne).
- Confiance : Vérifié

### GPIO-B4 — L'IMR filtre à l'entrée de l'ISR et non en sortie
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-system-gic/hdl/GIC_core.vhd:56-58 (utilisé par GPIO_irq_core.vhd:126-133)
- Constat : `isr = (imr and its) or isr_i` et `itm_o = reduce_or(isr_i)`. Un front qui survient pendant que l'IMR est à 0 n'est jamais mémorisé. Inversement, remettre l'IMR à 0 ne fait pas tomber `it_o` si l'ISR est déjà positionné.
- Scénario / justification : impossible de fonctionner en polling sur l'ISR avec l'IT masquée. Les événements survenus pendant une section critique masquée sont perdus. Masquer une ligne déjà pendante laisse `it_o` actif.
- Correction proposée : `isr = its or isr_i` et `itm_o = reduce_or(isr_i and imr_i)`. Cela impacte aussi le timer (TB section 6) et le GIC.
- Confiance : Vérifié

### GPIO-B5 — Lecture-modification-écriture sur `data` : la sortie des lignes en entrée est corrompue
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-gpio/hdl/GPIO_irq_core.vhd:83-84,97-99 ; hdl/csr/GPIO_irq.hjson:51-67
- Constat : sur les lignes en entrée, une lecture de `data` renvoie la broche, alors qu'une écriture met à jour `data_out_r` sur toutes les lignes. Contrairement à `sbi_GPIO` (`data_out` à x3), la version irq n'offre aucun moyen de relire `data_out_r`.
- Scénario / justification : `DATA |= 1<<k` recopie le niveau courant des broches d'entrée dans `data_out_r`. Quand ces lignes passent ensuite en sortie, elles pilotent une valeur périmée.
- Correction proposée : ajouter au hjson un registre `data_out` relisible, ou des registres set/clear en écriture seule.
- Confiance : Vérifié

### GPIO-B6 — Interruptions levées sur des lignes configurées en sortie
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-gpio/hdl/GPIO_irq_core.vhd:118-122
- Constat : la détection de front ne tient pas compte de `data_oe`. Si `data_i` reboucle le pad, toute écriture logicielle sur une sortie dont le bit IRQ_POSEDGE ou IRQ_NEGEDGE est actif lève une interruption.
- Scénario / justification : comportement non documenté dans le README. Il provoque des IT parasites sur des lignes bidirectionnelles.
- Correction proposée : `gic_it <= (...) and not sw2hw_i.data_oe.value`, ou documenter ce comportement comme voulu.
- Confiance : Vérifié (comportement) ; savoir si c'est un bug dépend de la spec.

### GPIO-B7 — Cible `default` de GPIO.core non élaborable, type de fichier sans standard
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-gpio/GPIO.core:66-72,96-105
- Constat : le toplevel `sbi_GPIO` a un générique `DATA_OE_INIT` sans valeur par défaut et des ports `sbi_ini_t`/`sbi_tgt_t` non contraints, si bien que `fusesoc run --target default` devrait échouer à l'élaboration. Par ailleurs, le fileset `hdl` est en `vhdlSource`, alors que le code est en VHDL-2008. GHDL s'en accommode parce qu'edalize passe tout en `--std=08` en cas de mélange, mais un flow qui choisit le standard fichier par fichier (Vivado `read_vhdl`) échouerait. timer.core utilise bien `vhdlSource-2008`.
- Scénario / justification : `make default` en échec. Fragilité pour les flows non-GHDL.
- Correction proposée : passer le fileset `hdl` en `vhdlSource-2008`. Pour `default`, prendre une coquille contrainte comme toplevel ou passer les génériques via `parameters`.
- Confiance : Probable (non exécuté)

### GPIO-S1 — isr/imr non supprimables quand aucune IRQ n'est utilisée
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-component-gpio/hdl/csr/GPIO_irq.hjson:17-50
- Constat : avec IRQ_POSEDGE et IRQ_NEGEDGE à 0, `gic_it` vaut 0, mais `imr` (8 FF accessibles en écriture logicielle) et `isr` (8 FF rebouclés, séquentiellement constants) restent en place, avec leur décodage et leur mux de lecture. PicoSoC instancie 4 GPIO_irq dans ce cas : LED0 et LED1, dans user et dans supervisor.
- Scénario / justification : environ 16 FF et 10 à 16 LUT par instance, soit à peu près 64 FF et 50 LUT sur PicoSoC. `imr` n'est jamais élagué. Pour `isr`, l'élagage dépend de l'outil (Probable qu'il soit conservé).
- Correction proposée : ajouter un paramètre booléen `IT_ENABLE` et mettre `enable: "IT_ENABLE"` sur isr/imr. regtool le supporte déjà (cf. SPI.hjson:179). Autre option : utiliser `sbi_GPIO` pour les LEDs. Risque faible, les registres absents relisent 0.
- Confiance : Vérifié (imr) / Probable (isr)

### GPIO-S2 — Direction non figeable par générique
- Catégorie : Surface
- Sévérité : Gain Faible à Moyen
- Emplacement : asylum-component-gpio/hdl/csr/GPIO.hjson:34-49 ; hdl/csr/GPIO_irq.hjson:68-84
- Constat : `data_oe` coûte toujours 8 FF plus le décodage, même quand `data_oe_o` est laissé ouvert (cas des LEDs et du switch PicoSoC). Le code généré prévoit déjà la branche `gen_data_oe_b`, qui donne `sw2hw_o.data_oe.value <= DATA_OE_INIT` (GPIO_csr.vhd:293-303).
- Scénario / justification : 8 FF et environ 8 LUT par instance, environ 40 FF sur PicoSoC.
- Correction proposée : ajouter un paramètre booléen `DATA_OE_RW` avec `enable: "DATA_OE_RW"` sur `data_oe`. Risque faible ; c'est l'équivalent de l'ancien DATA_OE_FORCE.
- Confiance : Vérifié

### GPIO-S3 — Largeur CSR fixée à 8 bits quel que soit NB_IO
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-component-gpio/hdl/csr/GPIO.hjson:28,43,74 ; GPIO_irq.hjson:27,45,62,79
- Constat : avec NB_IO inférieur à 8, les bits [7:NB_IO] de data_oe et data_out (sbi_GPIO) ainsi que de data_oe, imr et isr (version irq) restent accessibles en écriture logicielle, donc ne sont pas élagués. Seuls les bits `data_in` constants disparaissent.
- Scénario / justification : avec NB_IO=4, 8 FF perdus pour sbi_GPIO et 8 à 12 FF pour sbi_GPIO_irq.
- Correction proposée : rendre la largeur des champs paramétrable par NB_IO. Cela demande un support générateur.
- Confiance : Vérifié

### GPIO-C1 — Logique d'entrée active sur des lignes en sortie ou masquées
- Catégorie : Consommation
- Sévérité : Gain Faible
- Emplacement : asylum-component-gpio/hdl/GPIO_irq_core.vhd:83-84,107-122 ; hdl/GPIO_core.vhd:87-88
- Constat : `data_in_r` et la logique de front tournent à chaque cycle sur toutes les lignes activées par générique, y compris en sortie ou quand l'IMR est à 0. En version irq, chaque transition de broche se propage en combinatoire jusqu'au mux rdata et à l'ICN dès que l'adresse `data` reste sélectionnée.
- Scénario / justification : l'activité est proportionnelle au taux de basculement des broches, donc faible. L'élagage statique par génériques existe déjà.
- Correction proposée : le synchroniseur de B1/B2 coupe déjà la propagation vers le bus. La qualification par `not data_oe` (B6) supprime l'activité utile sur les sorties. Gater par l'IMR n'est pas recommandé : il faudrait gérer un front parasite au démasquage.
- Confiance : Vérifié

**Synthèse GPIO**
- Le risque principal tient aux entrées non synchronisées de `sbi_GPIO_irq` (front d'IT et lecture), version utilisée telle quelle par PicoSoC sur `switch_i` venant des pads. La correction est peu coûteuse grâce à `sync2dffrn` (+2 FF par ligne).
- Interruptions : perte d'événement lors d'une collision W1C (rw1c avec `hw_we` permanent) et IMR qui filtre en entrée, hérité de GIC_core et partagé avec le timer.
- Surface : les gains passent par l'attribut `enable` de regtool (isr/imr sans IRQ, data_oe figé), soit environ 16 à 24 FF par instance et environ 100 FF sur PicoSoC. Gain de consommation négligeable.
- Non retenus car documentés dans le README : `cke_i` inutilisé, et largeur de 8 bits imposée à DATA_OE_INIT et IRQ_*. Les testbenches sont opérants, mais ne couvrent ni la collision W1C, ni la synchronisation, ni les IT sur sorties.

## asylum-component-timer

> Commit revu : `2c4983c` (`origin/main`), plus récent que le commit enregistré dans asylum-project (`afaafd7`). Sauf mention contraire, les constats valent pour les deux versions.

### TIMER-B1 — Source d'IT au niveau `cnt=0` : impossible à acquitter en one-shot, IT parasite à l'arrêt
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-component-timer/hdl/timer_core.vhd:100,110 (2c4983c ; même code dans afaafd7 à 97,106)
- Constat : `gic_it(0) <= timer_done = (cnt = 0)` est un niveau, non qualifié par `enable` ni par `clear`. En one-shot, le compteur reste à 0, donc un effacement W1C de l'ISR est annulé dès le cycle suivant. Après reset, init=0 et le compteur est à 0 : `done` vaut 1 en permanence.
- Scénario / justification : un handler qui se contente d'acquitter l'ISR boucle indéfiniment, il doit aussi masquer ou recharger. Si le logiciel démasque l'IMR avant d'avoir programmé init, ou quand le timer est arrêté à 0, l'IT part immédiatement. Ce comportement est documenté (README « Design Notes ») et figé dans le TB (sections 3 et 7), mais reste un piège.
- Correction proposée : rendre l'événement impulsionnel : `gic_it(0) <= timer_done and not timer_done_r and control.enable`, avec `timer_done_r` remis à '1' au reset (+1 FF). Mettre à jour les sections 3 et 7 du TB ainsi que le README.
- Confiance : Vérifié

### TIMER-B2 — Collision W1C / rechargement : un tick est perdu en autostart
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-component-timer/hdl/timer_core.vhd:101,108 ; asylum-utils-generators/tools/regtool/hdl/csr_reg.vhd:90-98
- Constat : en autostart, `done` ne dure qu'un cycle. Si le logiciel écrit 1 dans l'ISR pendant ce cycle, `q_next = d_hw and not wd` vaut 0 et l'événement est perdu. C'est le même mécanisme que GPIO-B3.
- Scénario / justification : tick RTOS dont la période est proche de la latence du handler. La probabilité d'une collision est d'environ 1/(init+1) par IT.
- Correction proposée : la même que GPIO-B3, priorité au « set » matériel ou réinjection via `sw2hw.isr.we`.
- Confiance : Vérifié

### TIMER-B3 — L'IMR filtre à l'entrée : aucun mode polling possible
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-system-gic/hdl/GIC_core.vhd:56-58 via asylum-component-timer/hdl/timer_core.vhd:112-119
- Constat : avec l'IMR à 0, l'ISR ne passe jamais à 1 (le TB le vérifie à la section 6, « Masked : isr not set »). On ne peut donc pas sonder l'expiration sans interruption. C'est le même mécanisme que GPIO-B4.
- Scénario / justification : un pilote en polling ne voit jamais l'expiration.
- Correction proposée : celle de GPIO-B4.
- Confiance : Vérifié

### TIMER-B4 — Valeur initiale 32 bits mise à jour de façon non atomique
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-timer/hdl/timer_core.vhd:75-78,84-86
- Constat : `timer_init` est formé de 4 registres d'un octet écrits séparément, et il est utilisé directement à chaque rechargement.
- Scénario / justification : en autostart, un passage à 0 entre l'écriture de byte0 et celle de byte3 recharge une valeur mixte. Par exemple, de 0x0000FFFF vers 0x00010000, on obtient 0x0000FF00, soit une période aberrante.
- Correction proposée : n'appliquer la nouvelle valeur qu'à l'écriture de byte3 (registre ombre, +32 FF), ou documenter la procédure (mettre clear=1 pendant la mise à jour). Remarque : le compteur n'est pas lisible par le logiciel, donc la question d'une lecture cohérente ne se pose pas.
- Confiance : Vérifié

### TIMER-B5 — Le TB attend sans limite : une régression bloque la CI au lieu d'échouer
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-timer/sim/tb_sbi_timer.vhd:325,336,344-347 (2c4983c)
- Constat : `wait until timer_cnt = 0`, `wait until it_o = '1'` et `while timer_cnt /= 0 loop` n'ont ni timeout ni watchdog, alors que `clock_generator` tourne sans fin.
- Scénario / justification : si le compteur reste bloqué ou si `it_o` ne monte jamais, la simulation ne se termine pas. Le job CI tourne jusqu'à son timeout au lieu d'échouer.
- Correction proposée : ajouter un `watchdog_timer` UVVM, ou des `wait until ... for T` suivis d'un `check_value`.
- Confiance : Vérifié

### TIMER-B6 — (afaafd7 seulement) Le TB lit un nom externe, non supporté par GHDL gcc/llvm
- Catégorie : Bug
- Sévérité : Majeure (flow CI)
- Emplacement : asylum-component-timer/sim/tb_sbi_timer.vhd (afaafd7) : `alias timer_cnt is <<signal .tb_sbi_timer.ins_dut.ins_timer.timer_cnt_r ...>>`
- Constat : dans le commit extrait par le superprojet, le TB lit le compteur par nom externe. Avec GHDL 6.0.0 gcc/llvm (image asylum-ci), la lecture d'un nom externe termine silencieusement le processus (rc=255).
- Scénario / justification : `sim_sbi_timer` échoue en CI sur afaafd7. C'est corrigé dans 2c4983c via le port `timer_cnt_o`.
- Correction proposée : avancer le sous-module à 2c4983c. Le README de 2c4983c (section Verification) cite encore le nom externe.
- Confiance : Vérifié (alias `<<signal ...>>` ligne 104 d'afaafd7 ; CI GitHub : afaafd7 en échec le 2026-10-09, 2c4983c en succès le 2026-10-10)

### TIMER-S1 — Largeur de 32 bits non paramétrable
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-component-timer/hdl/timer_core.vhd:61-62,75-78 ; hdl/csr/timer.hjson:76-135
- Constat : init (32 FF), compteur (32 FF), décrémenteur 32 bits, mux de rechargement et détection de zéro sont fixes.
- Scénario / justification : en 16 bits, on économise environ 32 FF et 40 LUT4 (carry, mux, zéro, 2 entrées de mux de lecture). Avec un prescaler optionnel (le TICK de timer_v1), un compteur 16 bits plus un prescaler 8 bits couvre 2^24 cycles.
- Correction proposée : générique WIDTH, et paramètres booléens avec `enable` regtool sur timer_byte2/3. Risque faible, la valeur par défaut reste 32.
- Confiance : Vérifié

### TIMER-S2 — Comparateur `cnt = 0` sur 32 bits redondant avec le décrémenteur
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-component-timer/hdl/timer_core.vhd:90,100
- Constat : le NOR 32 entrées (environ 11 LUT4 sur 3 niveaux) est calculé alors que le décrémenteur `cnt-1` sur chaîne de carry fournit gratuitement la retenue « cnt = 0 ».
- Scénario / justification : environ 11 LUT gagnées.
- Correction proposée : `dec := ('0' & cnt) - 1; done <= dec(32)`. Risque faible ; vérifier le timing en sortie de chaîne de carry sur NG-MEDIUM.
- Confiance : Vérifié

### TIMER-S3 — Valeur init conservée en double même sans autoreload
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-component-timer/hdl/timer_core.vhd:75-93 ; hdl/csr/timer.hjson:76-135
- Constat : les 32 FF de `timer_byte*` ne servent qu'au rechargement (clear ou autostart) à côté du compteur de 32 FF. Pour un usage one-shot, l'écriture pourrait charger directement le compteur, par exemple avec `hwtype ext` sur les octets.
- Scénario / justification : environ 32 FF et le mux de rechargement en moins. Risque moyen : la sémantique logicielle change (les octets relisent le compteur, ce qui pose alors la question d'une lecture 32 bits cohérente).
- Correction proposée : générique booléen AUTORELOAD (défaut true) qui sélectionne l'une des deux architectures.
- Confiance : Vérifié

**Synthèse TIMER**
- 2c4983c corrige le TB d'afaafd7 (nom externe incompatible avec GHDL gcc) : le sous-module est à avancer. Tous les autres constats valent pour les deux versions.
- La sémantique d'IT est le point faible : source au niveau (one-shot impossible à acquitter, IT parasite à l'arrêt), collision W1C en autostart, IMR filtrante. Ces choix sont documentés et figés dans le TB, donc à mettre à jour ensemble.
- Période = init+1 (documentée dans le README, cohérente) ; compteur non lisible par le logiciel, donc pas de problème de lecture cohérente ; seul défaut d'atomicité : la mise à jour de init.
- Surface : WIDTH paramétrable (Moyen), retenue du décrémenteur (Faible), option sans autoreload (Moyen). Consommation : rien de significatif, le compteur est bien figé par enable, timer_disable_i et done, et le rechargement continu sous clear=1 ne fait pas basculer de bits. `timer_v1.vhd` reste dans `files_hdl` sans coût de surface.

## asylum-component-clock_divider

### CLKDIV-B1 — Mode « 50% » avec RATIO impair : rapport cyclique faux dès que cke_i n'est pas maintenu à 1
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-clock_divider/hdl/clock_divider.vhd:157-170 (et 126-129)
- Constat : la bascule sur front descendant `clk_div_neg_r`, qui ajoute la demi-période, est elle aussi validée par `cke_i`. La correction de T/2 n'est donc juste que si cke_i='1' en permanence. Sinon, le résultat dépend du domaine qui génère cke_i. En plus, le chemin cke_i → bascule sur front descendant est un chemin en demi-période.
- Scénario / justification : RATIO=3 avec cke_i actif 1 cycle sur 2. On attend une période de 6T et un niveau haut de 3T. `clk_div_pos_r` est haut pendant 2T. Si cke_i vient de logique sur front montant (cas usuel), la bascule négative voit le cke du cycle suivant : neg_r est en retard de 1,5T, le niveau haut dure 3,5T (58 %). Si cke_i change sur front descendant (convention du TB), le niveau haut dure 2,5T (42 %). Le TB ne vérifie pas le temps haut en « 50% » sous cke (sim/tb_clock_divider.vhd:266-272), donc ce cas n'est pas couvert. Aucun impact dans PicoSoC (cke_i='1').
- Correction proposée : retirer `cke_i` de la bascule négative (`clk_div_neg_r <= clk_div_pos_r` à chaque front descendant). Cela supprime le chemin en demi-période et rend le résultat (pos_r retardé de T/2) indépendant de la convention de cke ; le gel sur cke_i=0 reste assuré par pos_r. Documenter que le mode impair ne vaut 50 % qu'avec cke_i='1', et vérifier le temps haut attendu dans le TB.
- Confiance : Vérifié

### CLKDIV-B2 — RATIO=1 : cke_i et arstn_i sont ignorés
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-clock_divider/hdl/clock_divider.vhd:85-88
- Constat : avec RATIO=1, on a `clk_div_o <= clk_i`. Il n'y a ni gel quand cke_i=0, ni sortie à 0 pendant le reset, ni cbufg. Pour RATIO≥2, le contrat est différent. Le TB fige ce comportement (l.249-252), mais l'entité ne le documente pas (le port est commenté « Clock Enable »).
- Scénario / justification : quand RATIO est calculé (PicoSoC : `FSYS/FSYS_INT`), passer de 2 à 1 change silencieusement la sémantique. Un design qui utilise cke_i pour arrêter l'horloge dérivée, ou qui compte sur clk_div_o=0 pendant le reset, fonctionne à RATIO=2 mais plus à RATIO=1.
- Correction proposée : documenter ce comportement dans l'en-tête et le README. Si un gel est nécessaire, passer par une primitive de clock gating du techmap (et non une porte LUT).
- Confiance : Vérifié

### CLKDIV-S1 — Mode « 50% » avec RATIO pair : compteur + comparateur remplaçables par une bascule toggle
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-component-clock_divider/hdl/clock_divider.vhd:115-116, 137-138
- Constat : en mode pair, le compteur va de 0 à RATIO-1 (clog2(RATIO) bits) et le design compare `>= RATIO_HIGH`. Un compteur modulo RATIO/2 qui fait basculer `clk_div_pos_r` produit exactement la même forme d'onde.
- Scénario / justification : gain de 1 FF et du comparateur (1 à 3 LUT4) par instance. Risque faible : il faut conserver la phase après reset (premier front au 1er front de clk_i, `exp_first_rise`=1 dans le TB).
- Correction proposée : générer un compteur de taille clog2(RATIO/2) et faire `pos_r <= not pos_r` au passage à 0 quand `RATIO mod 2 = 0`.
- Confiance : Vérifié

**Synthèse clock_divider** : aucun bug dans l'usage réel (PicoSoC : cke_i='1', RATIO pair ou 1). Les défauts se limitent au mode « 50% » impair quand cke_i n'est pas constant et à la sémantique de RATIO=1. La surface est déjà quasi minimale (gain d'1 FF en mode pair). Aucun gain de consommation : le compteur est déjà conditionné par cke_i.

## asylum-component-crc

### CRC-B1 — Génériques par défaut incohérents : CRC non standard, et POLYNOM par défaut figé à 16 bits
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-crc/hdl/crc_core.vhd:37-39 ; hdl/sbi_crc.vhd:41-43 ; hdl/crc_pkg.vhd (composants)
- Constat : les valeurs par défaut sont `POLYNOM=x"1021"` (forme non réfléchie), `SHIFT_LEFT=false` (décalage à droite, qui exige un polynôme réfléchi) et `LSB_FIRST=false`. Un décalage à droite avec Q équivaut à un décalage à gauche avec reverse(Q) : la configuration par défaut calcule donc le polynôme normal 0x8408, avec des données MSB en premier dans un registre réfléchi. Cela ne correspond à aucun CRC du catalogue (ni CCITT, ni XMODEM, ni KERMIT). La cible FuseSoC `default` (toplevel sbi_crc) synthétise ce CRC. De plus, le littéral par défaut de POLYNOM fait 16 bits : tout WIDTH_CRC≠16 sans POLYNOM explicite casse l'élaboration (longueurs différentes), sans message clair.
- Scénario / justification : une instance qui ne surcharge que WIDTH ou XOR_OUT produit des CRC incompatibles avec tout équipement tiers. PicoSoC n'est pas touché, car il surcharge tout (0xA001, décalage à droite, LSB en premier).
- Correction proposée : mettre `SHIFT_LEFT=true` par défaut (donne CRC-16/XMODEM avec la graine 0, CCITT-FALSE avec la graine 0xFFFF), ou `POLYNOM=x"8408"` avec `LSB_FIRST=true` (KERMIT). Ajouter une assertion d'avertissement sur la combinaison SHIFT_LEFT=false + LSB_FIRST=false + REFLECT_IN=false.
- Confiance : Vérifié

### CRC-B2 — Le CRC lu dans le cycle qui suit l'écriture de data0 est l'ancien
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-crc/hdl/sbi_crc.vhd:124-127 ; asylum-utils-generators/tools/regtool/hdl/csr_reg.vhd:187,193
- Constat : data0 est un registre csr_reg, donc `sw2hw.data0.we` est le strobe d'écriture registré (`q_sw_we_r`). `crc_r` n'est mis à jour qu'à la fin du cycle suivant l'écriture. Or crc0/crc1 sont en « ext », donc lus en combinatoire. Une lecture juste après l'écriture de data0 renvoie l'ancien CRC, sans état d'attente : le TB l'impose (tb_crc.vhd:256-257, T5). Une écriture de crc0/crc1 dans ce même cycle écrase la mise à jour sans le signaler (T6).
- Scénario / justification : un maître capable d'enchaîner « écriture data0 » puis « lecture crc0 » au cycle suivant lit une valeur périmée. OpenBlaze8 (2 cycles par instruction) n'est pas exposé. Pour d'autres maîtres ou ponts SBI, ce n'est pas vérifié.
- Correction proposée : faire la mise à jour dans le cycle d'écriture : passer data0 en `hwtype "ext"` (`csr_ext` transmet `sw_wd_i`/`sw_we_i` en combinatoire), puis `crc_r <= crc_next` avec `d_i = data1 & wdata`. Garder un registre local de 8 bits seulement si la relecture de data0 est nécessaire. Le risque disparaît, et on gagne 1 FF (strobe), éventuellement 8 FF.
- Confiance : Probable (le comportement est vérifié ; l'exposition des maîtres ne l'est pas)

### CRC-S1 — Registre data1 instancié même quand WIDTH_DATA ≤ 8
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-component-crc/hdl/csr/crc.hjson (data1) ; hdl/csr/crc_csr.vhd:232-291
- Constat : data1 est en « rw », donc lisible par le logiciel. Ses 8 FF et son entrée dans le multiplexeur de lecture sont conservés par la synthèse, alors que crc_core ignore ces bits quand WIDTH_DATA ≤ 8 (PicoSoC : WIDTH_DATA=8). Même chose pour l'entrée de multiplexeur de crc1 quand WIDTH_CRC ≤ 8 (crc1 est « ext », donc sans FF).
- Scénario / justification : gain d'environ 8 FF et 4 à 8 LUT4 par sbi_crc 8 bits. Risque faible : la carte d'adresses ne change pas et data1 se lit à 0. Le TB T2 (tb_crc.vhd:187-188) est à adapter.
- Correction proposée : regtool sait déjà rendre un registre conditionnel avec `enable : "<param bool>"` (UART.hjson:171, SPI.hjson:179). Ajouter des paramètres DATA1_ENABLE / CRC1_ENABLE pilotés par sbi_crc (WIDTH_DATA>8 / WIDTH_CRC>8).
- Confiance : Vérifié

**Synthèse crc** : le cœur combinatoire est correct (le TB le compare à un modèle Rocksoft indépendant sur 10 configurations, dont la largeur 5 bits et les données 16 bits). Les risques sont les valeurs par défaut piégeuses et une latence de 1 cycle visible par le logiciel. Gain de surface faible (8 FF). Aucun gain de consommation : les entrées du cœur ne bougent qu'aux écritures.

## asylum-component-fifo

### FIFO-B1 — mk/defs.mk : la cible make par défaut n'existe pas
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-fifo/mk/defs.mk:2
- Constat : `TARGET ?= sim_fifo_sync_read_sync` n'existe pas dans FIFO.core, dont les cibles sont `sim_fifo_depth{1,8}_read_{async,sync}`.
- Scénario / justification : `make target`, `run`, `setup` ou `build` sans TARGET échouent dans fusesoc. La CI n'est pas touchée, car elle utilise targets.txt.
- Correction proposée : `TARGET ?= sim_fifo_depth8_read_sync`.
- Confiance : Vérifié

### FIFO-B2 — fifo_sync.vhd est déclaré en VHDL-93 mais utilise is_x(unsigned), qui est du VHDL-2008
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-fifo/hdl/fifo_sync.vhd:252 ; FIFO.core:358
- Constat : `IS_X` sur UNSIGNED n'existe dans numeric_std qu'à partir de VHDL-2008. La synthèse l'ignore (zone translate_off) et GHDL passe tout en `--std=08` parce que utils:pkg est en 2008. En revanche, un simulateur qui respecte le standard déclaré fichier par fichier (Questa ou Xsim via edalize, où vhdlSource donne 93/2002) refusera de compiler.
- Scénario / justification : un flow de simulation autre que GHDL casse.
- Correction proposée : déclarer `file_type: vhdlSource-2008`, ce qui est cohérent avec la dépendance à ram_pkg/sbi_pkg, ou remplacer is_x par une boucle sur std_logic.
- Confiance : Probable

### FIFO-S1 — La lecture asynchrone par défaut ne peut pas être changée depuis csr_fifo
- Catégorie : Surface
- Sévérité : Gain Faible pour PicoSoC (profondeur 4) / Fort pour des FIFO profondes
- Emplacement : asylum-component-fifo/hdl/fifo_sync.vhd:41 ; asylum-utils-generators/tools/regtool/hdl/csr_fifo.vhd:99-104, 144-149
- Constat : SYNC_READ vaut false par défaut, et csr_fifo ne transmet pas ce générique. Toutes les FIFO UART/SPI/mailbox générées par regtool sont donc en lecture asynchrone : pas de bloc RAM possible, stockage en DEPTH×WIDTH FF plus un multiplexeur de lecture.
- Scénario / justification : en 4×8 (mailbox PicoSoC), des FF sont le bon choix. En 64×8 (UART/SPI), cela coûte 512 FF et environ 170 LUT4, contre un seul bloc RAM.
- Correction proposée : exposer SYNC_READ (ou un seuil sur DEPTH×WIDTH) dans csr_fifo/regtool, et garder false pour les petites profondeurs.
- Confiance : Probable (le mapping nxmap sur NG-MEDIUM n'est pas vérifié ; FF + multiplexeur certains avec le techmap générique)

### FIFO-C1 — SYNC_READ : la RAM est lue à chaque cycle où m_axis_tready_i=1, même FIFO vide
- Catégorie : Consommation
- Sévérité : Gain Moyen en SYNC_READ (gain nul aujourd'hui : aucune instance SYNC_READ dans le dépôt)
- Emplacement : asylum-component-fifo/hdl/fifo_sync.vhd:205
- Constat : `ram_re <= m_axis_tready_i`. FIFO vide et consommateur prêt (cas typique au repos) : le bloc RAM lit `rptr_next` à chaque cycle.
- Scénario / justification : les valeurs lues pendant que la FIFO est vide ne servent jamais. Le push suivant dans une FIFO vide passe par le registre de bypass (l.229-233), la RAM est relue au moment du transfert, et quand tvalid=1 on a déjà `re = transfer`.
- Correction proposée : `ram_re <= m_axis_transfer`. C'est fonctionnellement équivalent et supprime toutes les lectures RAM au repos. Risque nul ; les tests T7/T8 au cycle près le couvrent.
- Confiance : Vérifié

**Synthèse fifo** : les pointeurs avec bit de tour et les flags sont corrects et compacts. Le bypass SYNC_READ est correct, y compris push+pop avec 1 mot et DEPTH=1. Le seul gain notable est `ram_re = m_axis_transfer` (consommation en SYNC_READ). Côté flow : cible make par défaut cassée et fichier déclaré en VHDL-93 à tort.

## asylum-component-ram

### RAM-B1 — Cibles FuseSoC aux noms inversés et cible make par défaut absente
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-ram/ram.core:69-131 ; mk/defs.mk:2
- Constat : `sim_16x8b_sync_read` et `sim_64x32b_sync_read` tournent avec SYNC_READ=false (l.78, 110), et les cibles `*_async_read` avec SYNC_READ=true (l.94, 126). Les descriptions suivent les valeurs, pas les noms. De plus, `TARGET ?= sim_basic` n'existe pas.
- Scénario / justification : les jobs CI portent le mauvais nom (un échec sur « sync_read » concerne en réalité la lecture asynchrone). `make run` et `make target` échouent.
- Correction proposée : inverser les noms (ou les valeurs) et mettre `TARGET ?= sim_16x8b_sync_read`.
- Confiance : Vérifié

### RAM-B2 — sbi_ram.vhd et ram_pkg.vhd exigent VHDL-2008 mais sont déclarés vhdlSource
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-ram/ram.core:42 ; hdl/sbi_ram.vhd:65 (`sbi_ini_i.wdata'length` sur un élément de record non contraint), 117 (`to_string(DEPTH)`) ; hdl/ram_pkg.vhd (composant sbi_ram avec sbi_ini_t)
- Constat : les records non contraints et `to_string(integer)` sont du VHDL-2008. GHDL passe parce que FuseSoC force `--std=08`. Un backend qui compile fichier par fichier selon le type déclaré (Vivado `read_vhdl` sans `-vhdl2008`, Questa) échoue. ram_pkg est aussi utilisé par fifo_sync et stack.
- Scénario / justification : la synthèse ou la simulation de PicoSoC avec un outil autre que GHDL casse.
- Correction proposée : passer files_hdl en `file_type: vhdlSource-2008`.
- Confiance : Probable (backend nxmap non vérifié)

### RAM-B3 — Lecture pendant écriture (SYNC_READ) : comportement « ancienne donnée » ni documenté ni garanti sur cible
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-ram/hdl/ram_1r1w.vhd:87-100 ; hdl/ram_2r1w.vhd:90-115
- Constat : en RTL, une lecture et une écriture à la même adresse dans le même cycle renvoient l'ancienne donnée (read-first), et le TB T3 l'impose. Une fois inféré en bloc RAM double port, le comportement en collision dépend du mode de la primitive (souvent indéfini ou write-first).
- Scénario / justification : il y a un risque de divergence entre simulation et matériel pour qui s'appuie sur ce comportement. Exemple : OpenBlaze8_RegFile, avec `REGFILE_SYNC_READ=true` par défaut (OpenBlaze8.vhd:38) et `raddr = waddr = regx_addr_i`. fifo_sync évite le problème grâce à son bypass (l.229).
- Correction proposée : documenter le contrat de lecture pendant écriture dans l'en-tête. Ajouter soit un bypass explicite (générique RDW = "old"/"new"), soit une assertion de simulation sur collision, et vérifier le mode NX_RAM choisi dans le rapport nxmap.
- Confiance : Probable

### RAM-S1 — Lecture asynchrone par défaut : aucune RAM bloc, coût majeur pour WardRV et OpenBlaze8
- Catégorie : Surface
- Sévérité : Gain Fort
- Emplacement : asylum-component-ram/hdl/ram_1r1w.vhd:36,106-111 ; hdl/ram_2r1w.vhd:35,117-122 ; hdl/ram_1rw.vhd:36,102-107. Utilisateurs : asylum-processor-WardRV/hdl/fsm/WardRV_fsm_regfile.vhd:50-55 (ram_2r1w 32×32, SYNC_READ=false), OpenBlaze8_RAM.vhd:64 (64×8, asynchrone), stack.vhd:158
- Constat : SYNC_READ vaut false par défaut. Une lecture asynchrone ne peut pas aller dans NX_RAM (lecture synchrone) ni dans aucun bloc RAM. Elle finit en FF plus multiplexeurs : c'est certain avec le techmap générique, et probable sur NG-MEDIUM, qui n'a pas de RAM distribuée en LUT.
- Scénario / justification : banc de registres WardRV : 1024 FF, plus 2 × 32 bits de multiplexeur 32:1 (environ 650 à 1300 LUT4), plus le décodage d'écriture. RAM OpenBlaze8 : 512 FF. En SYNC_READ, ram_2r1w est dupliquée sur 2 blocs, ce qui reste bien moins cher.
- Correction proposée : passer SYNC_READ=true par défaut et documenter la latence de lecture. Côté WardRV, présenter les adresses rs1/rs2 un cycle plus tôt. Garder la lecture asynchrone pour les mémoires très petites. Risque moyen : +1 cycle de latence chez les utilisateurs.
- Confiance : Probable (mapping nxmap non vérifié)

### RAM-C1 — sbi_ram en SYNC_READ : chaque accès SBI fait 2 accès RAM, et l'écriture subit un état d'attente inutile
- Catégorie : Consommation
- Sévérité : Gain Moyen
- Emplacement : asylum-component-ram/hdl/sbi_ram.vhd:71, 85-97
- Constat : `cs_i` de ram_1rw est directement le cs SBI. `ready_r` monte un cycle après cs, et le maître maintient cs pendant ce cycle d'attente. La RAM est donc validée 2 cycles par accès : lecture double (`cs and not we`) ou écriture double de la même donnée. L'état d'attente n'a aucune utilité pour une écriture.
- Scénario / justification : dans PicoSoC, les RAM supervisor, RAM1 et RAM2 sont toutes en SYNC_READ=true. Corriger divise par deux les cycles où la RAM de données est validée et retire 1 cycle à chaque écriture.
- Correction proposée : `cs_i => sbi_ini_i.cs and not ready_r` ; `ready <= (cs and we) or ready_r` ; `ready_r <= cs and not we and not ready_r`. Adapter `check_sbi_wait` pour les écritures dans sim/tb_ram.vhd (Test 7). Risque faible.
- Confiance : Vérifié

**Synthèse ram** : l'inférence est propre (pas de reset sur le tableau, re et cke respectés). Mais la lecture asynchrone par défaut est le principal surcoût du projet (banc de registres WardRV, RAM OpenBlaze8). sbi_ram double inutilement les accès RAM. Côté .core : noms de cibles inversés et VHDL-2008 non déclaré.

## asylum-component-stack

### STACK-B1 — Reset synchrone sur un port nommé arstn_i
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-component-stack/hdl/stack.vhd:41, 110-118
- Constat : `arstn_i` n'est échantillonné que dans la branche `rising_edge`, c'est donc un reset synchrone. Pourtant, la convention asylum `arst*_i` désigne un reset asynchrone. Le TB T6 fige le comportement synchrone.
- Scénario / justification : un utilisateur qui branche un reset système asynchrone (par exemple arst_b de PicoSoC) n'obtient aucun reset si l'horloge est arrêtée, et crée un chemin asynchrone vers synchrone non contraint. OpenBlaze8 n'est pas touché : il pilote ce port avec un reset synchrone.
- Correction proposée : renommer le port en `srstn_i` et le documenter, ou passer à un reset asynchrone (`process(clk_i, arstn_i)`).
- Confiance : Vérifié

### STACK-S1 — Mémoire forcée en lecture asynchrone : pile entièrement en bascules
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-component-stack/hdl/stack.vhd:154-158
- Constat : `SYNC_READ => false` est codé en dur, car le sommet doit être disponible en combinatoire sur `pop_data_o`. Avec OpenBlaze8 (size_stack=32, largeur 10), cela fait 320 FF plus 10 multiplexeurs 32:1 (environ 100 LUT4 ou plus).
- Scénario / justification : avec un registre de sommet (TOS) et une RAM synchrone pour le reste, environ 300 FF et 100 LUT4 passent dans un bloc RAM. Risque moyen : il faut prélire « sommet-1 » pour les pops consécutifs et le cas push+pop simultanés ; les TB T4/T7 au cycle près le valideraient.
- Correction proposée : ajouter un générique SYNC_READ avec un registre TOS. Sur un push : écrire TOS en RAM, puis `TOS <= push_data`. Sur un pop : `TOS <= rdata`, la RAM lisant en permanence `top-1`.
- Confiance : Probable (mapping NX non vérifié)

### STACK-S2 — ptr_last_r redondant avec nb_elt_r quand OVERWRITE=0, et décrémenteur sur l'adresse de lecture
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-component-stack/hdl/stack.vhd:61-62, 110-141, 147-152
- Constat : avec OVERWRITE=0, un push n'a lieu que si la pile n'est pas pleine. ptr_last_r et nb_elt_r font donc +1 au push, -1 au pop, restent stables sur push+pop et partent de 0 au reset : on a toujours `ptr_last_r = nb_elt_r mod DEPTH`. En plus, `ram_read_addr = ptr_last_r - 1` place un décrémenteur sur le chemin de lecture asynchrone et sur le multiplexeur d'adresse d'écriture.
- Scénario / justification : pour DEPTH=32, gain d'environ 5 FF et 10 LUT4, et chemin de lecture plus court. Risque faible.
- Correction proposée : quand OVERWRITE=0, prendre `ptr = nb_elt_r(lsb)`. Dans le cas général, mémoriser `ptr_top_r` (l'index du sommet) au lieu de ptr_last_r ; l'adresse de push devient `ptr_top_r + 1`, avec le même incrémenteur.
- Confiance : Vérifié

**Synthèse stack** : fonctionnellement correct (ordre LIFO, push+pop, OVERWRITE, cke_i ; vérifié par trace et par le TB). Gains de surface possibles avec un registre de sommet et une RAM synchrone, et en supprimant un pointeur redondant. Le reset est synchrone malgré son nom. Une profondeur non puissance de 2 est tronquée sans avertissement (même cause `log2` que MBX-B2).

## asylum-system-gic

### GIC-B1 — Un W1C l'emporte sur une interruption du même cycle : l'impulsion est perdue
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-system-gic/hdl/GIC_core.vhd:56, asylum-system-gic/hdl/sbi_GIC.vhd:122, asylum-utils-generators/tools/regtool/hdl/csr_reg.vhd:90-98 (modèle `rw1c`)
- Constat : `isr_o = (imr and its) or isr` est écrit à chaque cycle. Dans `csr_reg` rw1c, `q_next = d_hw and (not sw_wd)`. Quand le logiciel efface le bit i (W1C) dans le même cycle où la ligne i devient active, c'est l'effacement qui gagne.
- Scénario / justification : avec une source en niveau, le bit se réarme au cycle suivant (le test T7 de tb_GIC fige d'ailleurs ce comportement). Avec une source impulsionnelle, l'événement disparaît sans trace. `GIC_core` est réutilisé par le GPIO (`GPIO_irq_core.vhd`, fronts d'une seule période) et par le timer (`timer_core.vhd`, `timer_done` ne dure qu'un cycle en `autostart`). Un tick ou un front qui tombe pile sur le cycle d'acquittement est donc perdu.
- Correction proposée : donner la priorité à la mise à 1 : `q_next = (q and not clr) or set`, avec `GIC_core` qui ne fournit que `set = imr and its`. Cela demande un nouveau modèle regtool (ne pas modifier `rw1c` tel quel, car les autres IPs passent `hw_wd = set or q`). Variante locale sans toucher regtool : décoder la remise à zéro depuis `sbi_ini_i` (cs, we, addr = ISR) et rejouer au cycle suivant les bits perdus, soit `lost_r <= (imr and its) and clr`, puis `isr_o = (imr and its) or lost_r or isr_i` (8 FF). Ajouter le test d'une impulsion coïncidant avec le W1C et adapter T7.
- Confiance : Vérifié

### GIC-B2 — Masquage : un événement masqué est perdu, et masquer ne coupe pas `itm_o`
- Catégorie : Bug
- Sévérité : Mineure (comportement documenté dans le README et testé en T8, mais piégeux)
- Emplacement : asylum-system-gic/hdl/GIC_core.vhd:56-58
- Constat : l'IMR agit à la capture (`imr and its`), alors que `itm_o = reduce_or(isr)` n'est pas masqué.
- Scénario / justification : (1) un front GPIO ou un tick timer qui arrive pendant que la ligne est masquée n'est jamais mémorisé. (2) Masquer une ligne déjà pendante (section critique) laisse `itm_o` à 1 : le CPU repart dans le handler en boucle tant que le bit n'est pas effacé. Par ailleurs, un événement survenu entre la lecture de l'ISR et son W1C fusionne avec le bit déjà levé, puis il est effacé avec lui (le logiciel doit acquitter avant de traiter).
- Correction proposée : mémoriser le statut brut (`isr_next = its or isr`) et masquer en sortie (`itm_o = or(isr and imr)`), soit 8 AND. Sinon, documenter explicitement la perte des impulsions masquées dans le README de GIC_core et des IPs qui l'utilisent.
- Confiance : Vérifié

### GIC-B3 — L'association ligne → bit ISR dépend de la direction et des bornes des vecteurs
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-system-gic/hdl/GIC_core.vhd:55, asylum-system-gic/hdl/sbi_GIC.vhd:76-95
- Constat : `resize(unsigned(its_i), ...)` prend `its_i'left` comme MSB. Avec un `its_i` ascendant `(0 to N-1)`, la ligne 0 tombe sur ISR(N-1), et l'association est inversée en silence. La boucle `for i in ITS_SYNC_ENABLE'range` indexe `its_i(i)` par indice absolu : un littéral `"001"` (plage 0 to 2) synchronise la ligne 2, pas la ligne 0. Avec des bornes différentes, par exemple `its_i(3 downto 1)`, on obtient une erreur d'index et des `its_sync` non pilotés. Enfin, `GIC_core` n'a pas d'assertion de longueur : si `its_i'length > 8`, `resize` tronque sans rien dire pour les utilisateurs directs.
- Scénario / justification : le README annonce « line i = ISR bit i » et ne met en garde que pour `ITS_SYNC_ENABLE`.
- Correction proposée : normaliser avec des alias `alias its_n : std_logic_vector(its_i'length-1 downto 0) is its_i;` (idem pour `ITS_SYNC_ENABLE`) et boucler sur `0 to its_i'length-1`. Ajouter `assert its_i'length <= isr_i'length` dans `GIC_core`.
- Confiance : Vérifié

### GIC-B4 — `it_ctrl` : l'acquittement l'emporte sur un front du même cycle
- Catégorie : Bug
- Sévérité : Mineure (entité compilée mais instanciée nulle part)
- Emplacement : asylum-system-gic/hdl/it_ctrl.vhd:55-58
- Constat : `if it_ack_i='1' then it_val_r<='0' elsif it='1'` : un front qui coïncide avec l'acquittement est perdu.
- Scénario / justification : même course que GIC-B1, pour quiconque réutiliserait ce bloc fourni par le paquetage.
- Correction proposée : `it_val_r <= it or (it_val_r and not it_ack_i)`, ou retirer `it_ctrl` du fileset et du paquetage.
- Confiance : Vérifié

### GIC-S1 — IMR et ISR font toujours 8 bits, quel que soit le nombre de lignes
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-system-gic/hdl/csr/GIC.hjson:20,37
- Constat : avec N < 8 lignes (PicoSoC : 3 lignes, NB_CPU+1 instances), les 8-N bits d'IMR restent des FF accessibles en lecture/écriture. Les 8-N bits d'ISR, constants à 0 après reset, ne sont supprimés que si l'outil fait de la propagation séquentielle de constantes.
- Scénario / justification : jusqu'à 10 FF et environ 5-10 LUT par instance.
- Correction proposée : rendre la largeur des champs paramétrable (paramètre hjson `NB_LINES`, si regtool le permet comme pour les profondeurs de la mailbox). Risque faible.
- Confiance : Vérifié (suppression éventuelle des bits ISR par l'outil : Probable)

### GIC-C1 — L'ISR est réécrit à chaque cycle (`hw2sw.isr.we <= '1'`)
- Catégorie : Consommation
- Sévérité : Gain Faible
- Emplacement : asylum-system-gic/hdl/sbi_GIC.vhd:122 (même motif dans uart, timer et gpio)
- Constat : sans enable matériel, la bascule ISR est chargée en permanence (avec D = Q au repos).
- Scénario / justification : sur FPGA, pas de clock gating et pas de bascule de données au repos, donc gain quasi nul. Sur un flow ASIC, `we = or(imr and its)` permettrait d'insérer un ICG sur l'ISR. L'équivalence fonctionnelle est vérifiée : si `we = 0`, `d_hw = q`.
- Correction proposée : `hw2sw.isr.we <= or(sw2hw.imr.enable and its)`, seulement si une cible ASIC est visée.
- Confiance : Vérifié

**Synthèse GIC** : le GIC n'a ni priorité ni vectorisation (le logiciel balaie l'ISR), donc il n'y a pas d'arbre d'arbitrage à optimiser. Le risque principal est la course W1C contre un nouvel événement (GIC-B1), partagée par `GIC_core` dans l'UART, le GPIO (fronts) et le timer (autostart). Les sémantiques de masquage et d'indexation sont mineures ou documentées. Les gains surface et consommation sont marginaux.

## asylum-system-mailbox

### MBX-B1 — Lecture et écriture bloquantes sans registre d'état ni interruption : tout l'ICN2 peut geler
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-system-mailbox/hdl/csr/mailbox.hjson:41-42,64-65 ; asylum-utils-generators/tools/regtool/hdl/csr_fifo.vhd:172-190 ; asylum-infrastructure_icn/hdl/sbi_icn_mux_mst.vhd:61-65
- Constat : une lecture d'un canal vide (ou une écriture dans un canal plein) maintient `ready = 0`. `sbi_icn_mux_mst` garde `busy = 1` et le maître courant tant que `ready = 0`, donc aucun autre maître n'accède plus à l'ICN2. Aucun registre d'état et aucune sortie d'interruption ne permettent de savoir sans risque si des données sont disponibles. Les drapeaux `sw2hw.fifoN.*_empty/full` existent mais ne sont pas exploités.
- Scénario / justification : PicoSoC avec NB_CPU > 1. Le CPU récepteur fait `mailbox_pop()` avant que l'émetteur ait écrit. L'ICN2 se fige (UART, timer, spinlock, RAM2 et la mailbox elle-même), l'émetteur ne peut plus écrire : interblocage permanent jusqu'au reset. Le README le reconnaît, mais seul un protocole logiciel externe (compteur en RAM partagée) protège.
- Correction proposée : ajouter un registre `status` en lecture seule (par canal : `data_avail = not (hw2sw_empty and sw2hw_empty)`, `full = sw2hw_full`, à adapter quand une profondeur vaut 0) et une sortie `it_o` (canal non vide) branchable sur le GIC. Autre option : `BLOCKING_READ: False` avec un bit `valid` dans la donnée. Garder le mode bloquant en option générique.
- Confiance : Vérifié

### MBX-B2 — Aucune vérification que les profondeurs sont des puissances de 2
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-system-mailbox/hdl/sbi_mailbox.vhd:122-128
- Constat : `fifo_sync` dimensionne son adresse avec `clog2(DEPTH)`, `ram_1r1w` avec `log2(DEPTH)` (arrondi inférieur). Une profondeur de 3, 5, 6… provoque une erreur de largeur de port à l'élaboration, au fond de fifo/ram, avant même l'assertion de `ram_1r1w`.
- Scénario / justification : `--FIFO0_DEPTH_TX=6` produit un message cryptique au lieu d'un diagnostic lisible, alors que le README impose des puissances de 2.
- Correction proposée : `assert FIFOn_DEPTH_xx = 0 or is_pow2(FIFOn_DEPTH_xx) severity failure` dans `sbi_mailbox`.
- Confiance : Vérifié

### MBX-S1 — Deux FIFO en série par canal alors qu'une seule suffit (bouclage matériel)
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-system-mailbox/hdl/sbi_mailbox.vhd:95-101 ; configuration PicoSoC_user (4/4 par canal)
- Constat : la FIFO TX alimente directement la FIFO RX, ce qui n'apporte que de la latence (≥ 2 cycles avant lecture) et une logique de contrôle en double.
- Scénario / justification : une FIFO de profondeur 4 sur 8 bits coûte environ 38 FF (6 de pointeurs, 32 de données) et environ 20-25 LUT4. À capacité égale (TX=0, RX=8), on gagne environ 4 FF et environ 8-10 LUT par canal. Si 4 octets suffisent (TX=0, RX=4), on gagne environ 38 FF et environ 25 LUT par canal, soit environ 76 FF pour l'IP. Cette configuration est déjà couverte par `sim_mailbox_depth0`.
- Correction proposée : dans PicoSoC, `MAILBOX_FIFOn_DEPTH_TX = 0`. À terme, ne garder qu'une profondeur par canal. Risque faible.
- Confiance : Vérifié (estimations : Probable)

### MBX-C1 — Chaque octet est écrit puis lu deux fois en mémoire
- Catégorie : Consommation
- Sévérité : Gain Faible
- Emplacement : idem MBX-S1
- Constat : un octet traverse deux RAM `ram_1r1w` et deux paires de pointeurs.
- Scénario / justification : l'activité de stockage est doublée par octet échangé. Le trafic mailbox étant faible, le gain absolu l'est aussi.
- Correction proposée : couverte par MBX-S1 (une seule FIFO).
- Confiance : Vérifié

**Synthèse mailbox** : il n'y a ni débordement ni corruption (écriture bloquante), et aucun accès réellement simultané n'est possible puisque l'ICN sérialise les maîtres. En revanche, l'absence d'état et d'interruption combinée aux accès bloquants peut geler tout l'ICN2 en multi-CPU (MBX-B1). Le gain de surface le plus simple passe par la configuration des profondeurs (TX=0).

## asylum-system-spinlock

### SPIN-B1 — Pas de propriétaire : n'importe quel maître ou n'importe quelle lecture modifie le verrou
- Catégorie : Bug
- Sévérité : Mineure (limite de conception)
- Emplacement : asylum-system-spinlock/hdl/csr/spinlock.hjson:13,31 ; csr_reg.vhd:163-177 (`rsw0c`) ; `sbi_ini_t` sans identifiant de maître
- Constat : la libération (écriture de 0x00) n'est pas contrôlée, donc un autre CPU, ou un code fautif, peut libérer un verrou qu'il ne détient pas. À l'inverse, toute lecture prend le verrou, y compris une lecture « diagnostique » (dump mémoire par le débogueur, `puthex` de user.c:338-341) : le verrou reste alors pris sans propriétaire.
- Scénario / justification : CPU0 détient lock0 et CPU1 écrit 0x00 par erreur, la section critique n'est plus protégée et rien ne le signale. L'atomicité, elle, est correcte : l'ICN sérialise les maîtres (`sbi_icn_mux_mst`), donc deux test-and-set ne peuvent pas avoir lieu dans le même cycle.
- Correction proposée : stocker un identifiant de propriétaire. Soit l'ICN fournit l'index du maître (`master_id` existe dans `sbi_icn_mux_mst`), soit le logiciel écrit son ID (compare-and-set : écriture acceptée seulement si le verrou est libre, libération seulement si la valeur écrite égale le propriétaire). Ajouter un registre « peek » sans effet de bord.
- Confiance : Vérifié

### SPIN-S1 — Verrou sur 8 bits alors qu'un seul bit porte l'information
- Catégorie : Surface
- Sévérité : Gain Faible (absolu), environ 85 % des FF de l'IP
- Emplacement : asylum-system-spinlock/hdl/csr/spinlock.hjson:20,38
- Constat : les 8 bits sont toujours mis à 1 ensemble à la lecture. Les seules valeurs utiles sont « 0 » et « non nul », sauf écritures partielles.
- Scénario / justification : 2 × 8 FF ramenés à 2 FF, et le multiplexeur de lecture 8 bits à 1 bit : environ 14 FF et 7 LUT de moins. Le code embarqué teste `!= 0`, mais `user.c` affiche la valeur, qui passerait de FF à 01 : risque si une simulation compare la sortie UART.
- Correction proposée : `bits: "0:0"`, avec retour 0x00 ou 0x01.
- Confiance : Vérifié

**Synthèse spinlock** : l'atomicité est correcte (test-and-set en un accès, maîtres sérialisés par `sbi_icn_mux_mst`, reset à « libre »). Les limites : pas de propriétaire et une lecture avec effet de bord. 7 des 8 bits par verrou sont inutiles.

## asylum-utils-pkg

### PKG-B1 — TMR : les trois copies risquent d'être fusionnées par la synthèse (`syn_preserve` non portable)
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-utils-pkg/hdl/ft_dff.vhd:53-54,78-81
- Constat : avec `SELF_REFRESH = false` (cas des cibles `emu_ng_medium_*`), les trois copies de chaque bit sont des DFFE strictement identiques (même D `data_i(j)`, même enable `we_i`, même reset 0). Seul l'attribut Synplify `syn_preserve` les protège. Yosys/ghdl ne reconnaissent que `keep` (et `opt_merge` fusionne les FF identiques) ; la prise en charge par NXmap n'est pas vérifiée.
- Scénario / justification : après fusion, `maj(a,a,a) = a` et `error_* = 0` en constante : le TMR ne protège plus rien, sans aucune alerte. La CI ne lance pas les cibles NXmap. Vérification simple : le rapport de `emu_ng_medium_ft_dff_tmr` doit montrer environ 163 FF (33 en entrée + 96 + 34 en sortie). Environ 99 FF signifie que les copies ont été fusionnées.
- Correction proposée : ajouter `keep`/`syn_keep` et l'attribut équivalent NXmap, ou instancier trois registres distincts (générés, chacun avec son attribut). Contrôler le nombre de FF dans les cibles emu.
- Confiance : Probable

### PKG-B2 — ECC : un syndrome hors du mot (code raccourci) est signalé « corrigé » sans rien corriger
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-utils-pkg/hdl/ft_pkg_body.vhd:459-471
- Constat : si la parité globale est fausse et que le syndrome s ≥ N (pour k=32 : N=39, et s de 39 à 63 sont possibles), `data_mask(s)` sort de la tranche `(N-1 downto 0)`. Aucun bit n'est inversé, mais `error_corrected = 1` alors que la donnée reste corrompue.
- Scénario / justification : erreurs impaires ≥ 3 ; environ 39 % des syndromes possibles sont invalides pour k=32. `tb_ft_ecc32` (cas « correction outside the data ») fige ce comportement. Placement des bits, syndrome, parité globale et détection double erreur sont par ailleurs corrects (vérifiés pour k = 1 à 502).
- Correction proposée : `elsif err_idx(0)='1' and to_integer(syndrome) < DATA_ENC_SIZE then` correction, sinon détecté et non corrigé (environ 3-4 LUT). Adapter `tb_ft_ecc32`.
- Confiance : Vérifié

### PKG-B3 — Fonctions qui supposent un vecteur indexé `(N-1 downto 0)` ou à partir de 0
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : logic_pkg.vhd:110 (`reverse_bits`) ; convert_pkg.vhd:54-56 (`onehot_to_integer`) ; string_pkg.vhd:34,48 (`str2(i)` avec les indices de `str1`) ; sbi_pkg.vhd:188 / pbi_pkg.vhd:135 (`i0(0)`) ; ft_pkg_body.vhd:81,99-100,401-403,451 (décodage ECC et TMR)
- Constat : indexation absolue ou tranches `downto`. Avec `v(8 downto 1)`, `reverse_bits` lit `v(-1)`. `string_eq("abc", s(5 to 7))` sort des bornes. `"or"` sur un tableau qui ne contient pas l'indice 0 échoue. `ft_dec` (entité autonome à ports non contraints) branché sur une tranche `x(77 downto 39)` ou sur un vecteur ascendant tombe en erreur d'index ou de direction (`data_enc(0)`, `downto 1`). Le décodage parité, qui utilise `'high`/`'low`, est correct.
- Scénario / justification : le README ne signale que `reverse_bits` et `string_eq`. Aucun usage actuel n'est fautif (crc_core, sbi_wrapper_target et ft_dff sont à base 0), mais ce sont des pièges pour tout nouvel utilisateur.
- Correction proposée : normaliser en tête de chaque fonction avec `alias vn : std_logic_vector(v'length-1 downto 0) is v;`, utiliser `i0(i0'low)` et, pour les chaînes, comparer par position relative.
- Confiance : Vérifié

### PKG-B4 — Cas limites non protégés (ECC largeur 0, longueurs ECC invalides, `clog2` > 2**30)
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : ft_pkg_body.vhd:317,425,444 ; math_pkg.vhd:59-61
- Constat : `ft_dff` avec `WIDTH=0` et `USE_ECC` échoue à l'élaboration (`data_enc(0)` sur un tableau nul, puis `2**(-1)`), alors que NONE, parité et TMR acceptent 0. `decode(FT_ECC)` n'accepte que N = `encoded_size(k)` : pour N = 9, 17, 33, 65…, `reencode := encode(...)` donne une erreur de longueur sans message clair. `clog2(i)` déborde (`pow2*2` = 2**31) pour i > 2**30, y compris `natural'high`. `log2(0)` et `clog2(0)` renvoient 0 silencieusement.
- Scénario / justification : `ft_dec` est utilisé seul sur une largeur arbitraire, ou `clog2(natural'high)` sert de valeur sentinelle.
- Correction proposée : assertions explicites (`WIDTH > 0` pour ECC, `encoded_size(decoded_size(N)) = N`) et boucle `clog2` sans débordement (`while (i-1)/2**r > 0`, ou condition `pow2 < i` avec un garde-fou).
- Confiance : Vérifié

### PKG-B5 — `string_pkg.to_string` est un homographe de `ieee.std_logic_1164.to_string` en VHDL-2008
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-utils-pkg/hdl/string_pkg.vhd:22-23,56,67
- Constat : en 2008, `std_logic_vector` et `std_logic` sont des sous-types de `std_ulogic(_vector)`. Avec `use ieee.std_logic_1164.all` et `use asylum.string_pkg.all`, l'appel est ambigu (aucun des deux n'est directement visible). Seul GHDL `-frelaxed` l'accepte (cas de `tb_GPIO_vs_v1`). De plus, `to_string(std_logic)` renvoie `'1'` avec les apostrophes, contre `1` côté IEEE.
- Scénario / justification : compilation en échec avec NVC, Questa ou GHDL sans `-frelaxed`.
- Correction proposée : renommer (`slv_to_string`) ou réserver ces fonctions au VHDL-93.
- Confiance : Probable

### PKG-S1 — `SELF_REFRESH` ECC instancie un second encodeur complet
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-utils-pkg/hdl/ft_dff.vhd:70-75 ; ft_pkg_body.vhd:470
- Constat : `data_dec_enc <= encode(data_dec)` recalcule les 6 arbres de Hamming et la parité globale (38 entrées), alors que le décodeur calcule déjà `data_corrected = data_enc xor mask`, qui est un mot de code valide.
- Scénario / justification : pour WIDTH=32, environ 40-55 LUT4 d'encodeur, remplacés par environ 7 XOR sur les positions de parité, soit environ 35-45 LUT4 de moins. Le chemin critique registre → décodeur → encodeur → mux est aussi raccourci. Pour le TMR (simple câblage) et la parité (jamais « corrigée »), rien à gagner.
- Correction proposée : exposer une fonction `correct(data_enc, FT_ECC)` (ou un port de `ft_dec`) qui rend le mot corrigé, et réécrire ce mot. Risque faible, couvert par `tb_ft_dff`.
- Confiance : Vérifié (estimation : Probable)

### PKG-S2 — Pas de générique pour un ECC SEC seul (sans DED)
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : ft_pkg_body.vhd:30,50 (`ded : boolean := true` interne, non exposé)
- Constat : la parité globale coûte 1 FF et deux XOR à environ 38-39 entrées (encodeur et décodeur), soit environ 13 LUT4 chacune pour k=32.
- Scénario / justification : utile pour des registres peu critiques. Risque : une double erreur serait alors mal corrigée sans détection.
- Correction proposée : nouvelle valeur `USE_ECC_SEC` dans `ft_algo_t`, qui transmet `ded => false`.
- Confiance : Vérifié

### PKG-C1 — L'encodeur commute sur chaque changement de `data_i`, même sans `we_i`
- Catégorie : Consommation
- Sévérité : Gain Faible
- Emplacement : asylum-utils-pkg/hdl/ft_dff.vhd:57-62
- Constat : `ft_enc` est purement combinatoire sur `data_i`. Ses arbres XOR (ECC, parité) commutent, avec des glitches, dès que le bus d'entrée bouge, alors que le registre n'est chargé qu'avec `we_i`.
- Scénario / justification : `data_i` partagé par un bus actif. En revanche, `SELF_REFRESH` ne recalcule rien en permanence : chargement seulement sur `we_i` ou `error_corrected`, décodeur statique tant que le registre ne change pas.
- Correction proposée : isolation d'opérande (`data_i and we_i`) seulement si `data_i` est très actif, car elle coûte environ W LUT sur NG-MEDIUM (LUT4).
- Confiance : Probable

**Synthèse utils-pkg** : l'ECC SECDED est correct (placement, syndrome, parité globale, détection double erreur, tailles non standard de k=1 à 502), et le reset de `ft_dff` est un mot de code valide. Le risque majeur est l'efficacité réelle du TMR après synthèse (PKG-B1, à confirmer sur le rapport NXmap). Le reste concerne des cas limites d'indexation et de largeur, plus un encodeur redondant en `SELF_REFRESH` ECC.

## asylum-utils-generators

### GEN-B1 — pbcc / rvcc : les en-têtes inclus ne sont pas des dépendances, le firmware peut rester périmé
- Catégorie : Bug
- Sévérité : Mineure (builds locaux incrémentaux ; la CI part de zéro)
- Emplacement : asylum-utils-generators/generators/pbcc/templates/Makefile.j2:7,17-18,36 ; generators/rvcc/templates/Makefile.j2:28-29,83 et règle `$(ELF): $(SRC) $(LINK_LD_FILE)` ; generators.core:74,111,148 (`cache_type : generator`)
- Constat : la ROM du firmware ne dépend que du `.c` (pbcc : `$(FILE_PSM) : $(FILE_C)`) ou de `start.S` + `.c` + `link.ld` (rvcc). Les en-têtes inclus ne sont pas suivis : `addrmap_user.h`, `modbus_rtu.h`, et les `*_csr.h` générés par regtool, ajoutés via `-I ../*-gen_csr_*`.
  - En mode `cache_type: generator`, FuseSoC 2.4.6 relance toujours le générateur, mais dans le même répertoire, sans le vider (`edalizer.py`, `generate()`). C'est donc `make` qui décide de reconstruire.
  - Le Makefile de regtool dépend correctement du `.hjson` et des sources de regtool : les CSR, eux, sont bien régénérés.
- Scénario / justification : on ajoute un registre dans `UART.hjson`, ce qui décale les offsets. `UART_csr.vhd` et `UART_csr.h` sont régénérés, mais la ROM du firmware n'est pas recompilée, puisque `user.c` n'a pas changé. La simulation locale tourne alors avec un firmware qui utilise les anciens offsets, sans aucun message.
  - FuseSoC signale en outre que le mode `cache_type: generator` est déprécié (« Support for generator-side cachable cores are deprecated and will be removed »).
- Correction proposée : générer les dépendances (`-MMD -MP` avec `-include $(DEP)` pour rvcc ; équivalent ou dépendance explicite aux `*_csr.h` et en-têtes du répertoire pour pbcc). À terme, passer à `cache_type: input` avec `file_input_parameters`, ou à aucun cache.
- Confiance : Vérifié (source FuseSoC 2.4.6 et templates relus lors de l'assemblage). La revue initiale affirmait que FuseSoC réutilisait la sortie en cache sans relancer le générateur ; c'est faux pour le mode `generator`, et le constat a été corrigé.

### GEN-B2 — rvcc `start.S` : la `.bss` n'est jamais mise à zéro
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-utils-generators/generators/rvcc/templates/start.S:7-17 (boucle commentée), link.ld:50-58
- Constat : la boucle de remise à zéro de la `.bss` est entièrement commentée. Le linker script accepte pourtant une `.bss` non vide (seules `.data` et `.rodata` sont interdites par ASSERT). La RAM (`asylum-component-ram/hdl/ram_1rw.vhd:55`, `signal ram_r : ram_t;`) n'a ni valeur initiale ni reset.
- Scénario / justification : `static uint8_t cnt;` ou une variable globale non initialisée vaut `'U'` en simulation. Sur FPGA, après un reset à chaud (sans reconfiguration), elle garde la valeur du run précédent. Cela viole la sémantique C (initialisation à zéro), sans aucun avertissement.
- Correction proposée : réactiver la boucle avec `la t0,_bss_start ; la t1,_ebss` et une boucle `sw zero` tant que `t0 < t1`, au lieu du `la t1,_bss_size` actuel. Inclure `.sbss*` dans `.bss` (voir GEN-B3). Sinon, interdire la `.bss` par ASSERT comme `.data`.
- Confiance : Vérifié

### GEN-B3 — rvcc `link.ld` : `.srodata*` et `.sbss*` ne sont pas captés, l'ASSERT « rodata vide » est contournable, la pile n'est pas réservée
- Catégorie : Bug
- Sévérité : Majeure
- Emplacement : asylum-utils-generators/generators/rvcc/templates/link.ld:24-31, 50-66 ; Makefile.j2:71-72
- Constat : seules `.rodata*`, `.data*`, `.sdata*` et `.bss*` sont listées. GCC RISC-V place les petites constantes (≤ 8 octets, `-msmall-data-limit=8` par défaut, `.srodata.<sym>` avec `-fdata-sections`, `.srodata.cst*`) et les petites variables globales non initialisées (`.sbss`) dans des sections non listées. Le linker les place alors en orphelines.
- Scénario / justification : `static const uint8_t lut[8]` part en `.srodata.lut`. L'orpheline est placée près de `.rodata`, donc en ROM, et l'ASSERT `SIZEOF(.rodata)==0` passe. La SoC est Harvard : la ROM n'est accessible que par `iaddr`/`idata`. Le `lw` sur cette adresse passe par le bus SBI et lit une autre cible, sans erreur. Par ailleurs, `STACK_SIZE` n'est jamais réservé dans RAM_LOC (128 o) : `-Wl,-z,stack-size` n'a aucun effet en bare-metal. La `.bss` peut donc occuper 120 o sans erreur de lien, et la pile écrase les variables.
- Correction proposée : ajouter `*(.srodata) *(.srodata.*)` dans `.rodata` et `*(.sbss) *(.sbss.*) *(.scommon)` dans `.bss`, ou compiler avec `-msmall-data-limit=0`. Ajouter `ASSERT(_estack - _ebss >= STACK_SIZE)` en passant `--defsym STACK_SIZE=…`.
- Confiance : Probable (placement des orphelines non testé : pas de toolchain RISC-V sur l'hôte)

### GEN-B4 — Cause de l'échec CI sur `main` (6691a9f)
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-utils-generators/.github/workflows/ci.yml@6691a9f ; infra/asylum-ci/.github/workflows/vhdl-ci.yml@fe8bc8b
- Constat : le workflow réutilisable (version du 2026-09-30) exécute `make TARGETS_FILTER=. nonreg NONREG=sim STEP="setup build"` à la racine du dépôt. Or ce dépôt n'a ni `Makefile` racine, ni `mk/defs.mk`, ni cible `nonreg`/sim (`generators.core` ne contient que la cible `default`/`deps`). Les autres IP en ont un, par exemple `asylum-component-gpio/Makefile:72`.
- Scénario / justification : `make` s'arrête sur « No rule to make target 'nonreg' ». Le workflow a été retiré en 8fd6c58, d'où un statut rouge figé sur 6691a9f. Remettre le même `ci.yml` échouerait encore : le `vhdl-ci.yml@main` actuel exige l'entrée `name` et n'accepte plus `nonreg_type`.
- Correction proposée : soit ne pas activer de CI sim pour ce dépôt, soit ajouter un Makefile avec des cibles `nonreg_*` et un test (par exemple une régénération de `examples/example1` suivie d'une compilation GHDL), puis appeler le workflow avec `name: <cible>`.
- Confiance : Vérifié (structure du dépôt et du workflow) ; le log CI n'a pas été consulté.

### GEN-B5 — Modèles `rsw1c`/`rcw1s`/`rsw0c` : l'effet de bord de lecture est perdu dès que `hw_we='1'` (complément à GIC-B1)
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-utils-generators/tools/regtool/hdl/csr_reg.vhd:138-140, 154-156, 170-172
- Constat : `d_hw <= hw_wd_i when hw_we_i='1' else (set/clear) when sw_re_i='1' else q_r`. Dès que le matériel écrit, la mise à 1 ou à 0 déclenchée par la lecture est ignorée.
- Scénario / justification : toutes les IP pilotent `hw2sw.<reg>.we <= '1'` en permanence (gpio, uart, timer, gic). Un registre `rcw1s` (clear-on-read) piloté de la même façon ne s'effacerait donc jamais à la lecture. Le défaut est latent : aujourd'hui seul spinlock utilise `rsw0c`, avec `hwaccess: none`.
- Correction proposée : appliquer l'effet de lecture après la donnée matérielle, par exemple `d_hw <= hw_wd_i when hw_we_i='1' else q_r; q_next <= (d_hw or RD_SET) and not RD_CLR and d_sw…`. On peut aussi documenter que `hw_we` doit être un événement et non une constante '1'.
- Confiance : Vérifié (code) ; latent dans les IP actuelles.

### GEN-B6 — Constantes d'enum `_RAW` : largeur VHDL fausse et valeur C non convertie
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-utils-generators/tools/regtool/regtool.py:586 (VHDL), :424 (C)
- Constat : en VHDL, `_RAW` est déclaré sur `reg['width']`, qui est la somme des largeurs des champs et non `csr['width']`, alors que la valeur est décalée de `field['lsb']`. En C, la chaîne `enum['value']` est recopiée brute (`({enum['value']}<<lsb)`) au lieu de passer par `parse_value`.
- Scénario / justification : un registre avec un seul champ `7:6` et un enum de valeur 3 produit `std_logic_vector(2-1 downto 0) := "11000000"`, d'où une erreur d'élaboration. Une valeur `"x3"` ou `"b11"` produit `(x3<<6)` en C, qui ne compile pas. Le défaut est masqué dans SPI parce que le registre CMD couvre les 8 bits avec des valeurs décimales.
- Correction proposée : utiliser `csr['width']` pour `_RAW` et écrire `parse_value(enum['value'])` (en hexadécimal) dans le `.h`.
- Confiance : Vérifié (générateur) ; latent dans les sorties actuelles.

### GEN-B7 — Registre FIFO désactivé (`enable` = false) : drapeaux FIFO non pilotés
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-utils-generators/tools/regtool/regtool.py:1018-1032
- Constat : la branche `gen_<reg>_b` pilote les champs de données et les signaux `re`/`we` (`ready`/`valid`). Elle ne pilote pas `sw2hw_o.<reg>.sw2hw_empty/sw2hw_full/hw2sw_empty/hw2sw_full`, alors que ces champs existent dans le record (l. 555-562).
- Scénario / justification : une FIFO paramétrée désactivée laisse ces drapeaux à `'U'` en simulation et non pilotés en synthèse. UART, par exemple, s'en sert pour ses interruptions (`sbi_uart.vhd:358-361`).
- Correction proposée : dans la branche `_b`, émettre `…_empty <= '1'; …_full <= '0';` pour les registres de type `fifo`.
- Confiance : Vérifié (générateur) ; aucune IP ne désactive de FIFO aujourd'hui.

### GEN-B8 — rvcc : ROM figée à 1024×32 bits, incohérente avec `link.ld` (32 Kio)
- Catégorie : Bug
- Sévérité : Mineure
- Emplacement : asylum-utils-generators/generators/rvcc/templates/Makefile.j2:122, 126 ; gen_rom/gen_rom.py:42 ; link.ld:6
- Constat : `gen_rom.py` est appelé sans `--addr-width`/`--data-width`, donc avec les valeurs par défaut 10 et 32 (4 Kio), et `rvcc.py` n'expose aucun paramètre de taille. Le linker script annonce pourtant une ROM de 32 Kio. Par ailleurs, gen_rom émet des `x"<val>"`, ce qui n'est correct que si `data_width` est un multiple de 4 et égal à 4 × le nombre de chiffres hexadécimaux par ligne.
- Scénario / justification : un programme de 5 Kio passe l'édition de liens, puis échoue tard dans gen_rom (« too large »). Il est impossible d'agrandir la ROM ou de la réduire pour un petit programme.
- Correction proposée : ajouter un paramètre `addr_width` à rvcc, le passer à gen_rom pour la ROM et pour le paquetage, et générer `LENGTH = 4 << addr_width` dans `link.ld`.
- Confiance : Vérifié

### GEN-S1 — Mux de lecture CSR en chaîne de priorité `when … else` sur N registres
- Catégorie : Surface
- Sévérité : Gain Moyen
- Emplacement : asylum-utils-generators/tools/regtool/regtool.py:1035-1048 ; sortie réelle `asylum-communication-uart/hdl/csr/UART_csr.vhd:833-840` (7 niveaux), `GPIO_irq_csr.vhd:452-469`
- Constat : `sig_rdata`, `sig_rbusy` et `sig_wbusy` sont générés en cascade `X when rcs_X='1' else …`. Les `rcs` sont pourtant mutuellement exclusifs (adresses uniques vérifiées par `AddrMap`). L'outil de synthèse ne le prouve pas forcément et construit alors N étages de multiplexeurs 2:1 par bit.
- Scénario / justification : sur NG-MEDIUM (LUT4), un étage `rcs ? d : prev` coûte environ 1 LUT4 par bit, soit environ N×W LUT pour la chaîne. Un ET-OU one-hot coûte ⌈N/2⌉ + ⌈(⌈N/2⌉-1)/3⌉ LUT par bit. Gain estimé : environ 2 LUT/bit pour N=7 (UART, timer : ≈ 16 LUT4 par bloc), environ 1 LUT/bit pour N=2 à 4 (≈ 8 LUT4 par bloc). Sur les 9 blocs CSR (36 registres, tous de 8 bits), cela donne environ 50 à 90 LUT4, moins les bits constants à 0. La profondeur logique passe aussi de N niveaux à environ 2.
- Correction proposée : générer `sig_rdata <= (isr_rdata and (sig_rdata'range => isr_re)) or (imr_rdata and …) or …`, ou une boucle `v := v or …`. Utiliser `<reg>_re`, déjà calculé, comme sélection, ce qui règle aussi GEN-C1. Pour `rbusy`/`wbusy`, même construction, ou omission complète quand aucun registre n'est une FIFO bloquante.
- Confiance : Vérifié (structure générée) ; gain Probable (dépend de la détection d'exclusivité par nxmap ou Yosys).

### GEN-S2 — Deux bascules de strobe par `csr_reg` et `re`/`we` exportés systématiquement
- Catégorie : Surface
- Sévérité : Gain Faible
- Emplacement : asylum-utils-generators/tools/regtool/hdl/csr_reg.vhd:179-193 ; regtool.py:546-549, 957-964
- Constat : chaque instance `csr_reg` registre `sw_we_i` et `sw_re_i` (`q_sw_we_r`, `q_sw_re_r`). Les champs `sw2hw.<reg>.re` et `.we` sont exportés pour tout registre lisible ou inscriptible, même quand le cœur ne s'en sert pas (`imr`, `ctrl_*`, `data_oe`…).
- Scénario / justification : il y a environ 27 instances `csr_reg` dans les IP, soit au plus environ 54 FF. Elles sont supprimées si la hiérarchie est aplatie et que la sortie n'a pas de charge. Elles restent si la hiérarchie est conservée (keep_hierarchy ou synthèse par blocs).
- Correction proposée : ajouter des attributs hjson (`hwre`/`hwwe` à false par défaut) qui retirent les champs du record et passent des génériques `HAS_RE`/`HAS_WE` à `csr_reg`.
- Confiance : Probable

### GEN-C1 — Données de lecture CSR non qualifiées par `cs`/`re`
- Catégorie : Consommation
- Sévérité : Gain Faible
- Emplacement : asylum-utils-generators/tools/regtool/regtool.py:854, 1045-1048 ; sortie `GPIO_irq_csr.vhd:178, 464-469`
- Constat : `<reg>_rcs` ne dépend que de l'adresse, si bien que `sbi_tgt_o.rdata` commute à chaque changement d'adresse sur le bus partagé ou de valeur matérielle (registres `ext` tels que GPIO `data`, tête de FIFO, ISR), même sans lecture. Le défaut est fonctionnellement sans conséquence : `sbi_wrapper_target` (TGT_ZEROING, mode "or") masque `rdata` et `ready` par `cs`.
- Scénario / justification : l'activité reste dans le mux de lecture de chaque bloc. Elle est arrêtée au wrapper ICN, au prix de W+1 portes ET par cible.
- Correction proposée : sélectionner avec `<reg>_re` (`cs and re and rcs`, déjà généré) dans le mux ET-OU de GEN-S1, ce qui ne coûte rien. Les cibles regtool rendent alors 0 hors accès, et l'ICN pourrait se passer du zeroing pour elles.
- Confiance : Vérifié (structure) ; gain Faible estimé.

**Synthèse generators** : les briques `csr_reg`, `csr_ext` et `csr_fifo` ainsi que le code VHDL généré sont fonctionnellement cohérents pour les cas réellement utilisés : empaquetage des champs, INIT, `wo`, alias et décodage d'adresse vérifiés sur GPIO et UART. Le `ready`/`rdata` non masqué par `cs` est compensé par l'ICN. Les risques principaux concernent le runtime rvcc (`.bss` jamais mise à zéro, petites sections non captées par `link.ld`) et le suivi des dépendances du firmware (GEN-B1). Dans regtool lui-même, il ne reste que des bugs latents (enum `_RAW`, FIFO désactivée, effets de lecture `rsw*`/`rcw*` avec `hw_we='1'`), en plus de la priorité W1C déjà relevée (GIC-B1). Le seul gain de surface notable est le mux de lecture en chaîne de priorité (environ 50 à 90 LUT4 sur la SoC). La CI échoue parce que le dépôt n'a ni Makefile ni cible `nonreg`, alors que le workflow appelé les attend.
