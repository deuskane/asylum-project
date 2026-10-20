# Corrections des bugs de la revue `ip/`

Ce fichier fait suite à [REVIEW.md](REVIEW.md). Il recense les branches de correction créées entre le 2026-10-17 et le 2026-10-20 pour chaque bug (critique, majeur et mineur) des dépôts `ip/asylum*`, ainsi que les merges à faire et l'impact de chaque correctif sur la compatibilité.

> **État : toutes les branches sont locales, rien n'est poussé.** SSH vers GitHub est bloqué depuis l'hôte. Pour pousser toutes les branches `fix/*` et `lint_ghdl`, lancer depuis le terminal VS Code, qui s'authentifie en HTTPS :
> `./push_fix_branches.sh` à la racine d'asylum-project (`-n` pour un essai à blanc).

## Conventions

- **Une branche par bug**, nommée `fix/<id>-<slug>`. Chaque branche part de la base du dépôt, et non d'une autre branche de correction : on peut donc les merger dans n'importe quel ordre, aux conflits près listés plus bas.
  - Base : `origin/main` partout, sauf WardRV, dont les branches partent de `origin/debug_unit` (`d4f2859`, le commit revu). Leur PR vise donc `debug_unit`.
  - Le timer part de `origin/main` = `2c4983c`, plus récent que le commit enregistré dans asylum-project.
  - Les générateurs partent de `origin/main` = `4a431a7`, un commit après celui de la revue.
- **Commits** : auteur et committer `deuskane <deuskane@gmail.com>`, sans `Co-Authored-By`. La dernière ligne du corps est `Review: <ID>`. Aucune branche n'a d'upstream configuré.
- **Versions** : aucune version de `.core` ni table de révision n'a été modifiée, pour que les branches restent indépendantes. Le numéro de version est à incrémenter au moment du merge.
- **État des dépôts** : chaque sous-module est revenu sur son commit ou sa branche d'origine, avec un arbre propre.
- **Validation** :
  - Outils : FuseSoC 2.4.6 avec GHDL 6.0.0 (gcc) dans podman. Ont aussi servi la toolchain PicoBlaze (picoasm, sdcc/pbcc) recompilée pour OpenBlaze8, et un conteneur dédié avec riscv64-unknown-elf-gcc pour PicoSoC.
  - **Pas d'outil NanoXplore** (nxmap) ni d'OpenOCD sur l'hôte : tout ce qui en dépend est marqué « non vérifié ».
  - Les hooks FuseSoC ne sont pas exécutés par le script de simulation.
  - **Attention :** la première version du script de simulation ne passait pas les génériques des cibles (`parameters:`). Toutes les validations listées ici ont été refaites avec le script corrigé, ou concernent des cibles sans génériques.
  - Conséquence de ce défaut : les modèles de flash SPI `cy15b104qs`, `cy15v104qs`, `m45pe80` et `s25fl064p` n'ont jamais réellement tourné. Voir [Limites](#limites-et-points-non-vérifiés).

Légende de la colonne **Compat** :

- **Compatible** : aucune modification nécessaire chez les utilisateurs existants.
- **Rupture** : un changement d'API (port, générique, carte de registres, sens d'un bit, type de fichier, cible) ou de comportement par défaut qu'un utilisateur existant peut voir.

## Synthèse

| Dépôt | Bugs | Branches | Ruptures | Base |
|-------|:---:|:---:|:---:|------|
| asylum-processor-WardRV | 3 | 3 | 0 | `origin/debug_unit` d4f2859 |
| asylum-processor-OpenBlaze8 | 7 (OB8-B1..B5, KC3-B2, KC3-B4) | 7 | 3 | `origin/main` 84a0104 |
| asylum-soc-picosoc | 8 | 8 | 2 | `origin/main` 86be6ef |
| asylum-infrastructure_icn | 4 | 4 | 1 | `origin/main` 622a34f |
| asylum-target-techmap | 2 | 2 | 0 | `origin/main` 309cdb8 |
| asylum-communication-spi | 7 | 7 | 3 | `origin/main` 85d9809 |
| asylum-communication-uart | 7 | 7 | 3 | `origin/main` 5e2d28d |
| asylum-component-gpio | 7 | 7 | 4 | `origin/main` a9c0b96 |
| asylum-component-timer | 6 | 5 (B6 déjà corrigé) | 3 | `origin/main` 2c4983c |
| asylum-component-clock_divider | 2 | 2 | 0 | `origin/main` 494f311 |
| asylum-component-crc | 2 | 2 | 2 | `origin/main` 9064414 |
| asylum-component-fifo | 2 | 2 | 1 | `origin/main` 926192a |
| asylum-component-ram | 3 | 3 | 1 | `origin/main` c0b50c3 |
| asylum-component-stack | 2 (STACK-B1, KC3-B3) | 2 | 1 | `origin/main` 4d28fea |
| asylum-system-gic | 4 | 4 | 2 | `origin/main` 9903d4a |
| asylum-system-mailbox | 2 | 2 | 1 | `origin/main` 7534a86 |
| asylum-system-spinlock | 1 | 1 | 0 | `origin/main` 0e0a370 |
| asylum-utils-pkg | 5 | 5 | 1 | `origin/main` 194bbae |
| asylum-utils-generators | 8 + 1 compagnon de SOC-B3 | 9 | 3 | `origin/main` 4a431a7 |

Deux bugs de REVIEW.md n'ont pas de branche :

- **KC3-B1** (cible `default` de `kcpsm3.core`) : il est dans `xilinx-processor-kcpsm3`, hors du périmètre `ip/asylum*`. Correctif proposé par la revue : `analyze_options: ["-fsynopsys","-frelaxed"]`.
- **TIMER-B6** : déjà corrigé sur `main` (`2c4983c`). `afaafd7` échoue en simulation (RC=2) et `2c4983c` passe. Il reste à avancer le sous-module dans asylum-project.

## Branches par dépôt

### asylum-processor-WardRV

| ID | Sév. | Branche | Commit(s) | Correctif | Validation | Compat | Commentaires |
|----|------|---------|-----------|-----------|------------|--------|--------------|
| WRV-B1 | Majeure | `fix/wrv-b1-mtvec-mode` | 1c1a12e | `mtvec_r <= wdata(31:2) & "00"` : MODE est câblé à 0 (WARL), donc le PC de trap et le `dpc` du debug sont toujours alignés. README mis à jour. | Firmware de test (scratch) : la base échoue, la branche passe. 88/88 sims (ACT3, ACT4, debug) et `lint_ghdl_synth` 6/6 PASS. | Compatible (un logiciel qui écrit MODE=1 relit 0, comportement WARL légal) | Pas de test commité, pour éviter un conflit avec le TB de B2. Un check WARL pourra être ajouté dans `esw/irq` après le merge. |
| WRV-B2 | Mineure | `fix/wrv-b2-irq-csr-write` | cd3e115 (fix) + a4010d7 (test) | Le trap utilise la valeur de `mstatus.MIE` / `mie.MEIE` en cours d'écriture : pas d'IT après un masquage, IT immédiate après un démasquage (priv spec §3.1.9). | Nouvelle cible `sim_irq` (pilote `meip_i`) : échoue sur la base, passe avec le fix, y compris avec DEBUG/triggers. 89/89 sims PASS. | Compatible | Écart avec la revue, qui proposait seulement de retarder l'IT d'une instruction. Le firmware de test est généré sans toolchain (`esw/irq/gen_irq_fw.py`) et le `.hex` est commité. |
| WRV-B3 | Mineure | `fix/wrv-b3-imem2sbi-cs` | 04e5e44 (fix) + 8e40396 (test) | `sbi_ini_o.cs` est piloté en `S_TRANSFER`. L'additionneur d'adresse est remplacé par une concaténation. | Nouveau banc `sim_bridge_imem2sbi` : 16/16 checks. La base échoue au 1er fetch (`cs='U'`). | Compatible | — |

### asylum-processor-OpenBlaze8

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| OB8-B1 | Critique | `fix/ob8-b1-out-port-check` | 1d6000e | Une divergence de `out_port` est maintenant une `assert ... severity failure`. Seul le trigger « Test OK » met `test_done` à 1. | 45/45 PASS. Avec une faute injectée, `main` sort en PASS (rc=0) et la branche échoue. | Compatible (TB) | — |
| OB8-B2 | Majeure | `fix/ob8-b2-io-port-timing` | 08fb6f3 | `REGFILE_SYNC_READ` passe à `false` par défaut (entité et composant). Le TB pilote `in_port` à partir du `port_id` du DUT et vérifie aussi le cycle qui précède le strobe. Ajout d'un 2e DUT en `REGFILE_SYNC_READ=true` et du test `test_042_in_out_indirect`. | 46/46 PASS. Un DUT en lecture synchrone échoue sur le nouveau TB, et l'ancien TB masquait le bug. | **Rupture** (génériques par défaut) : une instance qui laissait `REGFILE_SYNC_READ` par défaut passe en lecture asynchrone, avec le timing KCPSM3 et plus de surface. `sbi_OpenBlaze8` était déjà à `false`. Avec `true`, `in_port` doit être décodé de façon combinatoire (documenté). | Les 2 configurations sont testées par le 2e DUT plutôt que par une cible séparée. Conflit README avec B3 et B5. |
| OB8-B3 | Mineure | `fix/ob8-b3-generic-checks` | e075ada | Asserts d'élaboration : DATA_WIDTH=8, REGFILE_DEPTH=16, 1≤ADDR_INST_WIDTH≤10, RAM_DEPTH≤2**DATA_WIDTH. Le `7` de l'ALU est remplacé par `size_data-1`. | 45/45 PASS. Des génériques invalides donnent un message explicite au lieu d'un « bound check failure ». | Compatible (seules des configurations qui ne fonctionnaient pas sont refusées) | Conflit README avec B2 (table des paramètres). |
| OB8-B4 | Mineure | `fix/ob8-b4-sync-reset` | 0b710b1 | `cycle_phase` passe en reset synchrone comme le reste du cœur. Documenté : reset synchrone, à synchroniser au niveau SoC. Le nom du port `arstn_i` est conservé. | 45/45 PASS | **Rupture** (comportement) : une impulsion de reset sans front d'horloge ne remet plus `cycle_phase` à 0. Aucun changement si le reset est synchrone de l'horloge. | Suivi PicoSoC : passer `arst_b_i` par un synchroniseur de reset. |
| OB8-B5 | Mineure | `fix/ob8-b5-sim-target` | 04d5b77 | La cible `sim` ajoute `files_sim` et `pbcc_dep`, et génère `test_000_default`. | `sim` échoue sur `main` et passe sur la branche. | Compatible | Conflit README avec B2 (table des cibles). |
| KC3-B2 | Mineure | `fix/kc3-b2-reset-delay` | b51c746 | `reset_internal <= reset_r(0)` (2 cycles comme KCPSM3). Le TB relâche les deux resets ensemble. | 45/45 PASS. L'ancien RTL échoue avec le nouveau TB. | **Rupture** (timing) : le 1er fetch arrive 2 cycles plus tard après le reset, PicoSoC compris. | — |
| KC3-B4 | Mineure | `fix/kc3-b4-registered-strobes` | 661b156 | `read_strobe` et `write_strobe` sortent de bascules (`inst and cycle_0`). | 45/45 PASS, avec comparaison des strobes à chaque cycle. | Compatible (même timing au cycle près, sans glitch) | Le chemin de stall SBI n'est pas simulé dans ce dépôt (PicoSoC le couvre). |

### asylum-soc-picosoc

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| SOC-B1 | Majeure | `fix/soc-b1-it-user-sync` | b209098 | `GIC_ITS_SYNC_ENABLE(GIC_IT_USER) = '1'` : synchroniseur 2 FF dans le GIC. | Avec le TB de B4 : `_c_user_uart` OB8/WardRV, soc4 OB8 fault et soc3 WardRV fault RC=0. LED1 +1 par impulsion. | Compatible (+2 cycles de latence sur l'IT bouton) | Pas d'anti-rebond : le GIC reste sensible au niveau. Les vecteurs sont en `downto 0`, donc compatibles avec GIC-B3. |
| SOC-B2 | Majeure | `fix/soc-b2-ngmedium-spi-pads` | 1369a7e | `pads.py` utilise `spi_sclk_io`, `spi_cs_b_io` et `spi_io_io[0/1]`. Nouveau paramètre `USER_SPI_NB_IO`, mis à 2 dans les 22 cibles `emu_ng_medium`. | Élaboration GHDL de `PicoSoC_top` avec NB_IO=2 ; cohérence des noms de pads. **nxmap non lancé.** | Compatible | À merger **avec SOC-B7**, sinon les entrées SPI 2..7 ne sont pas pilotées. `AllowUnconfiguredIOs` est conservé, à retirer après un passage nxmap. |
| SOC-B3 | Majeure | `fix/soc-b3-lockstep-data-compare` | 3b2278f | `diff` compare cs/re/we, l'adresse quand cs=1 et `wdata` quand we=1, pour chaque paire de CPU. | 9/10 cibles lock-step/TMR PASS. **`sim_soc4_wardrv_fsm_fault_c_user_modbus_rtu` échoue** sans le compagnon generators. | Compatible (interface) | **Dépendance** : `asylum-utils-generators` `fix/soc-b3-rvcc-clear-regs` (remise à 0 de x1..x31 dans `start.S`). Sans lui, un CPU WardRV relancé après une faute garde des registres périmés et le comparateur, qui fonctionne correctement, le détecte. |
| SOC-B4 | Majeure | `fix/soc-b4-tb-it-uart-check` | 43add1c | `tb_PicoSoC` : `TEST_IT` (LED1, timeout, pas d'IT en trop), `TEST_UART` (récepteur UVVM qui vérifie la bannière et chaque ligne), et vérification du reset et de la reprise en lock-step. | 25/25 cibles tb_PicoSoC PASS. 2 mutations (IT débranchée, valeur du mailbox altérée) échouent bien. | **Rupture** (cibles) : `sim_soc4_*_fault_c_user_uart` est renommée `sim_soc4_*_c_user_uart` (sans injection de faute). `targets.txt`, `ci.yml` et le README sont mis à jour. | Avec l'injection active, le TMR WardRV échouait (faute injectée pendant un stall de `putchar`). |
| SOC-B5 | Majeure | `fix/soc-b5-multicpu-success` | a862b2a | `TEST_SUITE=hello` pour soc1x2/x4/x6 : on attend que chaque CPU ait pris le spinlock (LED1 = 2^N-1) et que le compteur ait bougé. `user_hello.c` affiche le masque, et chaque CPU marque une pause après avoir relâché le verrou. | x2/x4/x6 RC=0 (masques 03/0F/3F). | Compatible (firmware de démonstration modifié) | Le critère a révélé une famine : seul le CPU0 prenait le verrou. La pause dans `user_hello.c` corrige ce défaut. |
| SOC-B6 | Mineure | `fix/soc-b6-basys-targets` | 72a20e9 | Retrait des deux cibles `emu_basys` (ISE) et du fileset `files_basys`. `pads.ucf` est conservé. | Le core se parse et la liste des cibles est cohérente. | **Rupture** (cibles retirées) | — |
| SOC-B7 | Mineure | `fix/soc-b7-spi-io-resize` | 98b2d2e | `spi_io_*` est dimensionné à `USER_SPI_NB_IO`, les entrées non câblées valent 0. `assert USER_SPI_NB_IO <= 8`. | Avec NB_IO=2, `UUUUUUZZ` devient `000000ZZ`. Sims spi et spi_mem RC=0. | Compatible | À merger avec SOC-B2. |
| SOC-B8 | Mineure | `fix/soc-b8-icn2-addr-width` | 95927e4 | La largeur de la cible ICN2 dans ICN1 vaut `CPU_DMEM_ADDR_WIDTH`. | soc1 OB8 uart, soc1x2 hello, soc3 modbus RC=0 | Compatible | — |

Les 8 branches fusionnées ensemble (essai) passent 34/35 cibles. La seule cible en échec est celle de SOC-B3. Avec le compagnon generators `fix/soc-b3-rvcc-clear-regs` (d9aeab0), elle passe.

### asylum-infrastructure_icn

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| ICN-B1 | Majeure | `fix/icn-b1-tb-arbitration` | ff03194 | TC4 : 2 maîtres en contention, ordre de grant, alternance en round-robin, priorité en `fix`. Moniteur « au plus un ready ». Cibles avec états d'attente. Nouveaux génériques de TB. Nouvelles cibles `sim_soc` et `sim_one_hot`. | 4 cibles PASS. 4 bugs injectés sont tous détectés. | Compatible (TB) | En `fix` avec PIPEIN, M1 obtient le bus entre deux accès de M0 (le pipe lâche la requête). Seuls l'ordre M0 d'abord et l'intégrité sont vérifiés. |
| ICN-B2 | Mineure | `fix/icn-b2-onehot-overlap` | f4e22de | En `one_hot`, une carte dont la largeur d'adresse d'une cible couvre le bit de sélection d'une cible est refusée à l'élaboration. | La carte de la revue et un auto-chevauchement sont refusés ; une carte valide passe. | **Rupture** (élaboration) : les cartes one-hot qui se chevauchent sont désormais refusées. Elles étaient déjà fausses. PicoSoC est en binaire et n'est pas touché. | — |
| ICN-B3 | Mineure | `fix/icn-b3-busy-release` | 8ae2f98 | `busy` retombe aussi quand le maître qui a le bus relâche `cs`, avec un warning de simulation. | M1 est servi en 3 cycles, alors qu'il restait bloqué sur la base. | Compatible | Abandonner un accès reste une violation de protocole. Seul le blocage des autres maîtres est corrigé. |
| ICN-B4 | Mineure | `fix/icn-b4-zero-width-target` | 8ebf9ff | Le contrôle d'alignement binaire est sauté si `TARGET_ADDR_WIDTH = 0`. | Une cible d'un seul registre échoue sur la base et passe sur la branche. | Compatible | — |

### asylum-target-techmap

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| TMAP-B1 | Mineure | `fix/tmap-b1-sync-attributes` | 533269c | `ASYNC_REG`, `SHREG_EXTRACT="NO"` et `syn_preserve` sur `q_r` de `sync2dff` et `sync2dffrn`. Le README rappelle le false path vers `q_r(0)`. | `sim_techmap` PASS, `lint_generic` RC=0 | Compatible | **Non vérifié avec NXmap** : syntaxe d'attribut et équivalent d'`ASYNC_REG` à confirmer. |
| TMAP-B2 | Mineure | `fix/tmap-b2-ng-medium-cgate` | 84908b5 | `hdl/ng_medium/cgate.vhd` utilise le switch d'horloge `NX_CKS` au lieu d'un latch suivi d'un ET. | Élaboration avec une bibliothèque nx factice ; `sim_techmap` PASS. **Ni simulé ni synthétisé avec la vraie bibliothèque NanoXplore.** | Compatible (interface) ; l'implémentation NG-MEDIUM change | Ports et génériques de `NX_CKS` repris des cellules yosys : passage nxmap obligatoire avant le merge. |

### asylum-communication-spi

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| SPI-B1 | Majeure | `fix/spi-b1-status-reg` | e54c67f | Registre `status` à 0x4 : empty/full des FIFO tx, rx et cmd, plus `busy` (nouvelle sortie `spi_master.busy_o`). Registre `ext`, écritures ignorées. | `sim_basic` (nouvelle section status), `sim_s25fl512s` PASS | **Rupture** : `SPI_ADDR_WIDTH` passe de 2 à 3 (fenêtre SBI de 4 à 8 octets ; registres 0..3 inchangés). Nouveau port `busy_o`, peut rester ouvert. `SPI_sw2hw_t`/`SPI_hw2sw_t` gagnent un champ. | PicoSoC : la fenêtre SPI devient 0x18–0x1F, sans chevauchement avec l'UART (0x20). Pas de timeout ni de mode non bloquant : il faudrait une option `csr_fifo`. |
| SPI-B2 | Majeure | `fix/spi-b2-disable-safe` | 5d15210 | CS#=1 et SCLK=CPOL pilotés en reset et quand le SPI est désactivé. Avec `spi_enable=0`, les FIFO cmd et TX sont acquittées : les commandes sont jetées et les écritures ne bloquent pas. | `sim_basic` (abandon en CPOL=1, commandes jetées), `sim_s25fl512s` PASS | **Rupture** (comportement) : les pads CS# et SCLK sont pilotés en reset et à l'arrêt (ils étaient en haute impédance). Les commandes et octets TX écrits pendant la désactivation sont perdus au lieu d'être mis en file. | La FIFO RX n'est pas vidée (pas de pop matériel dans `csr_fifo`). La fin de transaction se lit dans `status.busy`, qui n'existe que sur B1. |
| SPI-B3 | Mineure | `fix/spi-b3-cs-high-guard` | 2cb7ae0 | Générique `CS_HIGH_MIN_CYCLES` (0 par défaut) : temps minimal CS# haut entre deux transactions. | Garde à 10 : 12 cycles mesurés. Avec 0, l'alerte attendue se déclenche. | Compatible | PicoSoC peut le régler selon sa flash. Conflit README avec B5. |
| SPI-B4 | Mineure | `fix/spi-b4-hold-wp-idle` | 6e4914d | Avec `HANDLE_HOLD_WP=true`, HOLD#/WP# sont à 1 en reset et hors transfert, et ne bougent que quand ils servent de lignes de données. | m25p40, s25fl512s, s35hl256t, at25df161 PASS. L'ancien RTL échoue. | **Rupture** (comportement par défaut avec `HANDLE_HOLD_WP=true`, cas de PicoSoC) : WP#/HOLD# sont hauts au repos au lieu d'être bas. C'est le changement voulu. | — |
| SPI-B5 | Mineure | `fix/spi-b5-rx-late-sample` | 151715b | Générique `RX_LATE_SAMPLE` (`false` par défaut) : registres d'entrée et échantillonnage décalé, ce qui laisse une période SCLK entière d'aller-retour. Section Timing dans le README. | `sim_basic` (timing par défaut identique) et nouvelle cible `sim_basic_late` PASS. Option désactivée, `sim_basic_late` échoue. | Compatible | SCLK ne sort toujours pas d'un registre (documenté). Conflit README avec B3. |
| SPI-B6 | Mineure | `fix/spi-b6-keep-stop` | 9bd8571 | Nouvelle entrée `cmd_keep_i` (défaut '0') : le STOP n'est décodé que pour une commande CONFIG. | `sim_basic` (CONFIG + KEEP last donne 4 octets) | Compatible (port avec valeur par défaut) | — |
| SPI-B7 | Mineure | `fix/spi-b7-rdsr-poll-bound` | c1d138b | La boucle RDSR ne teste que WIP, est bornée à 10 000 itérations et lève une alerte ERROR. | `sim_s25fl512s` PASS (832 polls) | Compatible (TB) | — |

Les 7 branches fusionnées (essai) passent `sim_basic`, `sim_basic_late`, `sim_s25fl512s` et `sim_m25p40`.

### asylum-communication-uart

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| UART-B1 | Critique | `fix/uart-b1-rx-sync` | 5456f3a | `uart_rx_i` passe par `sync2dffrn`, avec inversion avant et après pour lire '1' (repos) pendant le reset. | `sim_basic` PASS (tests RX existants : nominal, dérive ±3 %, glitch) | Compatible (+2 cycles de latence RX) | Le synchroniseur RX de `PicoSoC_top` devient redondant. |
| UART-B2 | Critique | `fix/uart-b2-tx-ready` | 251c18a | `tready = enable_r and not active and not CTS#` : l'octet n'est plus consommé quand TX est désactivé ou CTS# inactif. | Nouveau test 10 : il échoue sur l'ancien RTL et passe sur la branche. | **Rupture** (comportement) : avec `DEPTH_TX=0`, écrire `data` alors que TX est désactivé ou CTS# inactif **bloque le bus** au lieu de perdre l'octet (documenté). | PicoSoC n'est pas touché : TX est activé en premier et CTS# est à 0. |
| UART-B3 | Majeure | `fix/uart-b3-rx-overrun` | c36cd44 | Une trame reçue alors qu'un octet est en attente est jetée et signalée par `err_overrun_o`, qui positionne le bit collant `status.rx_overrun` (bit 4, source d'IT 4). RTS# retombe à max(DEPTH_RX-2,1) octets. | Nouveau test 11 (seuil RTS#, overrun, IT) PASS | Compatible (carte étendue : `status`@0x3, bit 4 d'isr/imr). Changement : le seuil de RTS# est plus bas. | `sbi_uart` compte lui-même la FIFO RX (`csr_fifo` n'exporte pas `nb_elt`). |
| UART-B4 | Majeure | `fix/uart-b4-rx-frame-error` | b6445dc | Le bit de stop est vérifié, le break est détecté, et après une erreur de trame on attend le retour au repos. Bits collants `status` 7:5 (trame, parité, break), aussi sources d'IT. | Nouveau test 12 PASS. Sans l'attente du repos, le test de break échoue. | Compatible (carte étendue : bits 7:5 de `status`, d'isr et d'imr) | — |
| UART-B5 | Majeure | `fix/uart-b5-status-tx-irq` | 7699bf7 | Registre `status` à 0x3 : tx_empty, tx_full, rx_not_empty, rx_full. | Nouveau test 13 PASS | **Rupture** (sens d'un bit) : le bit 0 d'isr/imr passe de « TX non vide » à « FIFO TX vide ». | `UART_IT_TX_EMPTY_B` dans `PicoSoC/esw/include/uart.h` désigne déjà le bit 0 et n'est utilisé nulle part. |
| UART-B6 | Mineure | `fix/uart-b6-rts-register` | 9e883f8 | RTS# sort d'une bascule (reset '0', même fonction). | Nouveau test 14 PASS (fonctionnel ; un glitch ne se voit pas en RTL) | Compatible (RTS# 1 cycle plus tard) | — |
| UART-B7 | Mineure | `fix/uart-b7-baud-atomic` | 7bb5b4c | Le diviseur 16 bits est un registre fantôme, chargé avec {MSB, LSB} à l'écriture du MSB. | Nouveau test 15 : il échoue sur l'ancien RTL et passe sur la branche. | **Rupture** (logiciel) : il faut écrire le LSB **puis** le MSB. Un logiciel qui n'écrit que le LSB, ou le MSB d'abord, garde un diviseur périmé. | `uart_setup` de PicoSoC écrit déjà LSB puis MSB : il n'est pas touché. |

Le registre `status` est déclaré `ext` en `rw1c`, avec les écritures ignorées sur les bits FIFO. On évite ainsi le double pilote de `wbusy` que regtool 2.7.1 génère pour un registre `ro`. Le logiciel doit effacer le bit de `status` avant le bit d'isr.

### asylum-component-gpio

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| GPIO-B1 | Critique | `fix/gpio-b1-edge-sync` | 03d6155 | Un `sync2dff` 2 FF par ligne alimente `data_in` et la détection de front. Dépendance explicite à `asylum:target:techmap`. | `sim_testcase_irq` PASS | Compatible (+2 cycles de latence) ; nouvelle dépendance techmap | La métastabilité elle-même ne se simule pas. |
| GPIO-B2 | Majeure/Mineure | `fix/gpio-b2-input-sync` | 8a1a1da | `GPIO_core` registre `data_i` avant le CSR `data_in`, qui devient le 2e étage. | `sim_testcase` et `sim_testcase_vs_v1` PASS | Compatible (+1 cycle de latence) | — |
| GPIO-B3 | Majeure | `fix/gpio-b3-isr-w1c-race` | 3dcad4a | `its = gic_it or its_hold_r` quand `isr.we='1'` : un front effacé par le W1C est rejoué au cycle suivant. Correctif local, sans regtool. | Balayage de -4 à +3 cycles autour du W1C : sans le rejeu, échec au cycle de coïncidence. | Compatible | — |
| GPIO-B4 | Mineure | `fix/gpio-b4-imr-output` | 8d87451 | `GIC_core` reçoit un masque tout à 1, et `it_o = or(isr and imr)`. Fonctionne avec le GIC_core actuel comme avec la version GIC-B2. | `sim_testcase_irq` PASS (isr=0x0E attendu après un front masqué) | **Rupture** (comportement) : un front masqué est mémorisé dans l'ISR, et masquer une ligne pendante fait tomber `it_o`. | — |
| GPIO-B5 | Mineure | `fix/gpio-b5-data-out-readback` | 13f993c | Nouveau registre `data_out` à 0x4 (rw, ext) : on relit la valeur de sortie, donc le lecture-modification-écriture est sûr. CSR régénérés. | `sim_testcase_irq` PASS (RMW avec des directions mixtes) | **Rupture** : `GPIO_IRQ_ADDR_WIDTH` passe de 2 à 3 (fenêtre de 4 à 8 octets). **Casse PicoSoC** : SWITCH/LED0/LED1 sont à 0x04/0x08/0x0C, et l'ICN refuse les cibles désalignées. | Voir [Merges entre dépôts](#entre-dépôts). Alternative sans rupture : ignorer les écritures dans `data` sur les lignes en entrée, au prix de ne plus pouvoir préparer une sortie. |
| GPIO-B6 | Mineure | `fix/gpio-b6-irq-output-lines` | c8d81f0 | `gic_it` est masqué par `not data_oe` : pas d'IT sur une ligne en sortie. | `sim_testcase_irq` PASS | **Rupture** (comportement) : plus d'IT de front sur les lignes en sortie. | — |
| GPIO-B7 | Mineure | `fix/gpio-b7-default-target` | 7fdfbde | Fileset hdl en `vhdlSource-2008`. Nouveau top `syn/GPIO_top.vhd` pour la cible `default`. | `default` RC=0 (RC=2 sur la base), `sim_testcase_irq` PASS | **Rupture** (type de fichier) : compilation VHDL-2008 pour les outils fichier par fichier ; nouveau toplevel de la cible `default`. | — |

### asylum-component-timer

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| TIMER-B1 | Majeure | `fix/timer-b1-it-pulse` | 34fc1f7 | La source d'IT est un événement : `cnt=0` le cycle qui suit une décrémentation (+1 FF). | `sim_sbi_timer` PASS (134 checks). Le nouveau TB échoue sur l'ancien RTL. | **Rupture** (comportement) : plus d'IT sur un compteur arrêté à 0 (one-shot terminé, stop, reset). Avec `init=0`, aucune IT. | Écart avec la revue : on ne perd pas d'expiration si `enable` tombe au même cycle. |
| TIMER-B2 | Majeure | `fix/timer-b2-w1c-reinject` | c203909 | `gic_it <= done or (timer_it_r and isr.we)` : un tick effacé par le W1C est rejoué (+1 FF). | Balayage sur 8 phases : l'ancien RTL échoue à la collision. 148 checks PASS. | Compatible | Couvre un W1C par cycle. |
| TIMER-B3 | Mineure | `fix/timer-b3-imr-output` | dd0bbd2 | Même correctif que GPIO-B4 : masque tout à 1 sur `GIC_core` et `it_o = or(isr and imr)`. | 131 checks PASS | **Rupture** (comportement) : l'ISR mémorise les ticks masqués (polling possible), et masquer fait tomber `it_o`. | — |
| TIMER-B4 | Mineure | `fix/timer-b4-init-atomic` | a57975c | `init` 32 bits copié dans un registre fantôme à l'écriture de `byte3` (+32 FF). | Nouveau test : l'ancien RTL donne `A5332211`. 134 checks PASS. | **Rupture** (logiciel) : `byte3` doit être écrit en dernier. | `timer_wr()` de PicoSoC écrit déjà byte0..byte3 dans l'ordre. |
| TIMER-B5 | Mineure | `fix/timer-b5-tb-timeouts` | f908718 | Les attentes du TB sont bornées et vérifiées, avec un `watchdog_timer` UVVM de 100 µs. Le README ne cite plus le nom externe. | 138 checks PASS. Une faute injectée échoue vite au lieu de bloquer. | Compatible (TB) | — |
| TIMER-B6 | Majeure (CI) | *aucune* | — | Déjà corrigé par `2c4983c` sur `main`. | `afaafd7` RC=2, `2c4983c` PASS | — | Avancer le sous-module dans asylum-project. |

### asylum-component-clock_divider

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| CLKDIV-B1 | Mineure | `fix/clkdiv-b1-odd-duty-cke` | d6fd76b | `clk_div_neg_r` n'est plus gaté par `cke_i`. Le test 4 vérifie le 50 % avec `cke_i` changeant sur l'un ou l'autre front. | `sim_basic` PASS (744 checks). Le nouveau TB échoue sur l'ancien RTL. | Compatible (identique avec cke=1) | — |
| CLKDIV-B2 | Mineure | `fix/clkdiv-b2-ratio1-doc` | b8024bf | Documentation : RATIO=1 ignore `cke_i` et `arstn_i`, avec un renvoi vers le `cgate` de techmap. | `sim_basic` PASS | Compatible | Un vrai gating arrêterait l'horloge de PicoSoC pendant le reset. |

### asylum-component-crc

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| CRC-B1 | Mineure | `fix/crc-b1-default-generics` | a414037 | `SHIFT_LEFT=true` par défaut. `POLYNOM = crc_default_polynom(WIDTH_CRC)` (0x07, 0x1021, 0x04C11DB7 ; échec pour les autres largeurs). Warning en décalage à droite avec des données MSB d'abord. | 10/10 cibles PASS, plus le test T0 des génériques par défaut. | **Rupture** (génériques par défaut) : les valeurs par défaut calculent maintenant CRC-16/XMODEM. `crc_core` dépend de `crc_pkg`. | PicoSoC fixe tous ses génériques et n'est pas touché. La cible `default` n'a pas été élaborée seule. |
| CRC-B2 | Mineure | `fix/crc-b2-update-in-write-cycle` | dfbb3fb | `data0` devient `ext` : la CRC est mise à jour à la fin du cycle d'écriture de `data0`. CSR régénérés. | 10/10 cibles PASS (T5, T6) | **Rupture** (légère, timing) : la nouvelle CRC est lisible un cycle plus tôt, et une écriture de `crc0`/`crc1` juste après `data0` ne perd plus la mise à jour. Carte des registres inchangée. | Conflit possible avec B1 (README, HDL), non vérifié. |

### asylum-component-fifo

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| FIFO-B1 | Mineure | `fix/fifo-b1-default-target` | 86754ad | `TARGET ?= sim_fifo_depth8_read_sync`, et les noms de cibles du README sont corrigés. | `make -n run` résout la cible ; la simulation passe. | Compatible | — |
| FIFO-B2 | Mineure | `fix/fifo-b2-vhdl2008-filetype` | b15b443 | Fileset hdl en `vhdlSource-2008`. | `lint_ghdl` RC=0, 4/4 sims PASS | **Rupture** (type de fichier) : `fifo_pkg`/`fifo_sync` sont compilés en VHDL-2008 par les outils fichier par fichier. Aucun changement pour GHDL. | — |

### asylum-component-ram

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| RAM-B1 | Mineure | `fix/ram-b1-target-names` | 22b4c26 | Les valeurs de `SYNC_READ` correspondent au nom de chaque cible. `TARGET ?= sim_16x8b_sync_read`. | 4/4 PASS avec les bons génériques | Compatible (noms des jobs inchangés) | — |
| RAM-B2 | Mineure | `fix/ram-b2-vhdl2008-filetype` | b7cd49c | `files_hdl` en `vhdlSource-2008`. | 4/4 PASS, fifo depth8 PASS avec cette ram locale | **Rupture** (type de fichier) : `ram_pkg` et `ram_*` sont compilés en VHDL-2008, ce qui touche aussi fifo, stack et toutes les IPs qui les utilisent. Aucun changement pour GHDL. | — |
| RAM-B3 | Mineure | `fix/ram-b3-read-during-write` | 4d712c4 | Documentation seule : contrat « read-first » en `SYNC_READ`, comment le vérifier sur cible et comment ne pas en dépendre. | sim PASS | Compatible | Le vrai correctif (générique avec bypass, ou assertion) n'est pas fait : l'assertion se déclencherait à chaque écriture du register file d'OpenBlaze8. Mode de collision NX_RAM non vérifié. |

### asylum-component-stack

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| STACK-B1 | Mineure | `fix/stack-b1-async-reset` | e760cdf | Le reset sur `arstn_i` devient réellement asynchrone ; le nom du port est conservé. T6 vérifie l'effacement avant le front d'horloge. | `sim_basic`, `sim_overwrite` PASS ; OpenBlaze8 (copie de travail) `test_032` et `test_027` PASS | **Rupture** (comportement) : reset asynchrone. Même comportement au cycle près si le reset est synchrone de `clk_i`, ce qui est le cas d'OpenBlaze8. | Merge sans conflit avec KC3-B3 (vérifié). |
| KC3-B3 | Mineure | `fix/kc3-b3-cyclic-pointer` | 6bf54b3 | Générique opt-in `CYCLIC_PTR` (`false` par défaut ; exige `OVERWRITE/=0`) : un pop sur pile vide déplace quand même le pointeur, comme KCPSM3. Nouvelle cible `sim_cyclic` et test 8. | 3/3 sims PASS. Le test 8 échoue si le pop cyclique est désactivé. OB8 (copie de travail) avec `CYCLIC_PTR=>true` : `test_032`, `test_027`, `test_028` PASS. | Compatible (comportement par défaut inchangé ; générique ajouté au composant) | **Suivi OpenBlaze8** : passer `CYCLIC_PTR => true` dans `OpenBlaze8_Stack.vhd`, ajouter un test 33 CALL / 34 RETURN et dépendre de la version de stack qui a ce générique. |

### asylum-system-gic

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| GIC-B1 | Majeure | `fix/gic-b1-w1c-replay` | b119144 | Variante locale dans `sbi_GIC` (1 FF par ligne) : les lignes du cycle d'écriture de l'ISR sont réinjectées au cycle suivant. T7 teste une impulsion à -1, 0 et +1 cycle du W1C. | 4 cibles PASS. Le `sbi_GIC` de base échoue exactement au cycle de coïncidence. | Compatible | GPIO et timer instancient `GIC_core` directement : leur correctif est fait localement (GPIO-B3, TIMER-B2). |
| GIC-B2 | Mineure | `fix/gic-b2-mask-output` | 86e4b85 | `isr_next = its or isr` et `itm_o = or(isr and imr)`. T3/T4/T8/T9 et le README sont mis à jour. | 4 cibles PASS | **Rupture** (comportement) : l'ISR affiche aussi les lignes masquées, et masquer fait tomber `itm_o`. Touche tous les utilisateurs de `GIC_core`/`sbi_GIC`, **dont l'UART** (son TB pourra devoir être adapté). GPIO et timer restent compatibles grâce à leur masque tout à 1. | Corrige aussi GPIO-B4 et TIMER-B3 à la source. |
| GIC-B3 | Mineure | `fix/gic-b3-line-mapping` | 797b9bd | Alias normalisés `(length-1 downto 0)` pour `its_i` et `ITS_SYNC_ENABLE`, et boucle sur `0 to length-1`. `assert its_i'length <= isr_i'length`. Nouvelle cible `sim_gic_4_mixed`. | 3 cibles PASS. L'ancien HDL échoue sur le nouveau TB. | Compatible pour les vecteurs `(N-1 downto 0)`, dont PicoSoC. **Rupture** pour les vecteurs ascendants ou décalés : l'association ligne → bit se fait désormais par position. | — |
| GIC-B4 | Mineure | `fix/gic-b4-it-ctrl-edge` | 58976a8 | `it_val_r <= it or (it_val_r and not it_ack_i)` | TB de travail (non commité) PASS ; la base échoue sur les 2 cas front + ack. | Compatible (entité instanciée nulle part) | — |

### asylum-system-mailbox

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| MBX-B1 | Majeure | `fix/mbx-b1-status-nonblocking` | d97b029 | `status0` (0x1) et `status1` (0x3) : empty/full, aux adresses jusque-là libres. Génériques `BLOCKING_READ`/`BLOCKING_WRITE` (`true` par défaut). En mode non bloquant, une lecture sur FIFO vide renvoie une donnée invalide et une écriture sur FIFO pleine est jetée. CSR régénérés. | 5/5 cibles PASS, dont la nouvelle `sim_mailbox_nonblocking` | Compatible (comportement par défaut inchangé, nouveaux registres dans la fenêtre existante) | PicoSoC pourra utiliser le statut dans `mailbox_pop`/`mailbox_push`. Pas de sortie d'interruption ajoutée. |
| MBX-B2 | Mineure | `fix/mbx-b2-depth-pow2` | 25803f3 | Assert d'élaboration : profondeur nulle ou puissance de 2. | `sim_mailbox_depth0` PASS ; une profondeur de 6 donne le message attendu. | **Rupture** (élaboration) : une profondeur qui n'est pas une puissance de 2 est refusée. Elle était déjà tronquée en silence. | Les autres cibles n'ont pas été relancées sur cette branche. |

### asylum-system-spinlock

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| SPIN-B1 | Mineure (limite de conception) | `fix/spin-b1-owner-id` | 683e037 | Générique `OWNER_ID` (`false` par défaut, comportement `rsw0c` inchangé). Avec `true` : on prend le verrou en écrivant un ID (0x01–0x7F) et on le libère en écrivant 0x80+ID, ignoré si l'ID n'est pas le propriétaire. Les lectures n'ont plus d'effet de bord. Nouvelle cible `sim_spinlock_owner`. | `sim_spinlock` PASS (43 checks, identique à la base), `sim_spinlock_owner` PASS (59) | Compatible (mode par défaut inchangé ; les verrous deviennent des registres `ext`) | Protège contre une libération par erreur, pas contre du code malveillant. Un vrai contrôle du propriétaire demanderait un ID de maître dans `sbi_ini_t` (utils-pkg et ICN). Côté PicoSoC, le mode propriétaire demande des macros esw et `OWNER_ID=true`. |

### asylum-utils-pkg

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| PKG-B1 | Majeure | `fix/pkg-b1-tmr-keep-attr` | 9f73c2d | Le registre encodé de `ft_dff` porte `syn_keep`, `preserve`, `keep` et `dont_touch`, en plus de `syn_preserve`. Le README donne le nombre de registres attendu. | `sim_ft_dff`, `sim_ft_tmr` PASS ; GHDL synth émet les 5 attributs. | Compatible | **Correctif partiel.** Yosys fusionne toujours les copies (97 FF au lieu de 163), et aucun attribut VHDL ne l'en empêche. NXmap non vérifié : lancer `make emu_ng_medium_ft_dff_tmr` et attendre environ 163 registres. |
| PKG-B2 | Mineure | `fix/pkg-b2-ecc-syndrome-range` | 465fafe | La correction ECC n'est faite que si le syndrome tombe dans le mot. Sinon : « détecté, non corrigé ». | `sim_ft_ecc32`, `sim_ft_ecc4`, `sim_ft_dff` PASS ; syndromes 39..63 vérifiés. | Compatible (`error_corrected` ne change que pour des erreurs de 3 bits ou plus, signalées à tort comme corrigées) | — |
| PKG-B3 | Mineure | `fix/pkg-b3-index-ranges` | 25327f6 | Vecteurs normalisés (alias, positions relatives) dans `reverse_bits`, `onehot_to_integer`, `string_eq/ne`, le `"or"` des tableaux sbi/pbi et les fonctions ECC/TMR/parité. Noms des paramètres formels conservés. | 8/8 cibles PASS. `tb_logic_pkg` teste des tranches et des vecteurs ascendants ; il échoue sur l'ancien code. | Compatible (résultats identiques pour les vecteurs indexés à partir de 0) | Conflit avec B4 dans `ft_pkg_body.vhd`, voir plus bas. |
| PKG-B4 | Mineure | `fix/pkg-b4-corner-cases` | 1ae9d98 | ECC sur un mot vide (`ft_dff` WIDTH=0 avec ECC). `decode` vérifie les longueurs ECC et TMR. `clog2` est calculé par division et reste valide jusqu'à `natural'high`. | 8/8 cibles PASS, nouveaux tests | Compatible (`clog2`/`log2` identiques jusqu'à 2**30 ; `log2(0)` = `clog2(0)` = 0 conservé) | Ajoute un contrôle de longueur TMR, absent de la revue. |
| PKG-B5 | Mineure | `fix/pkg-b5-to-string-format` | 67e1ddc | `to_string(std_logic)` renvoie un caractère (`1`) comme le `to_string` de VHDL-2008, au lieu de `'1'`. Le README explique l'homographe. | `sim_logic_pkg` PASS | **Rupture** (mineure) : la chaîne fait 1 caractère au lieu de 3. Seul utilisateur trouvé : messages d'assertion de `asylum-component-gpio/sim/tb_GPIO_vs_v1.vhd`. | **La revue se trompait sur ce point** : il n'y a ni ambiguïté ni échec de compilation. GHDL `--std=08` sans `-frelaxed` et Questa `vcom -2008` compilent, car un homographe explicite masque le `TO_STRING` implicite (LRM 2008 §12.4). |

### asylum-utils-generators

| ID | Sév. | Branche | Commit | Correctif | Validation | Compat | Commentaires |
|----|------|---------|--------|-----------|------------|--------|--------------|
| GEN-B1 | Mineure | `fix/gen-b1-firmware-header-deps` | dee6845 | rvcc : la recette ELF écrit `build/<name>.d` (`gcc -MM -MP`), inclus par `-include`. pbcc : le `.psm` dépend de tous les `*.h` du répertoire source et des répertoires `-I`, y compris `../*-gen_csr_*`. | rvcc : le `.d` liste les `*_csr.h` et les en-têtes esw, et toucher `UART_csr.h` relance le build. pbcc : 21 en-têtes suivis, et toucher `GIC_csr.h` relance le build. | Compatible | pbcc : les en-têtes de sous-répertoires (`include/cpu/*.h`) ne sont pas suivis. Changer les cflags ne relance toujours pas l'édition de liens. |
| GEN-B2 | Majeure | `fix/gen-b2-rvcc-zero-bss` | 8489f13 | `start.S` met à zéro `[_bss_start, _ebss)` avec `sw zero`. L'ancien code commenté utilisait `_bss_size`, que ld évalue comme une adresse. | Édition de liens et désassemblage (gcc 10.2 / binutils 2.35) : bornes correctes, 4 mots mis à zéro pour 16 octets. `user.c` de PicoSoC se construit. **Pas exécuté dans une simulation.** | Compatible (les variables globales démarrent à 0) | Conflit de fichier avec le compagnon SOC-B3 (`start.S`), mais pas de conflit git : les modifications sont dans des blocs distincts. |
| GEN-B3 | Majeure | `fix/gen-b3-rvcc-link-sections` | fb874df | `link.ld` place `.srodata*` dans `.rodata`, ce qui la soumet à l'ASSERT « rodata vide », et `.sbss*`, `.scommon` et `COMMON` dans `.bss`. `_estack` devient une expression absolue. Ajout de `ASSERT(_estack - _ebss >= _stack_size)`. Le Makefile remplace `-z stack-size`, sans effet, par `--defsym=_stack_size=$(STACK_SIZE)`. `stack_size` est documenté. | Programmes de test liés : une petite table const déclenche l'erreur rodata, `.sbss` arrive dans `.bss`, l'ASSERT de pile se déclenche et se règle. Tous les firmwares rvcc de PicoSoC se lient, et la ROM de `user.c` est identique à la base. | **Rupture** (carte mémoire firmware) : avec `stack_size=128` par défaut, qui occupe toute `RAM_LOC`, **toute variable globale provoque une erreur de lien** (il faut réduire `stack_size`). Les petites constantes (≤8 octets) en `.srodata` déclenchent maintenant l'erreur rodata. Les firmwares PicoSoC actuels ne sont pas touchés. | Corrige aussi un bug de la base, hors revue : le `. & ~0xF` de `.stack` faisait échouer l'édition de liens dès que la RAM n'était pas un multiple de 16 octets. |
| GEN-B4 | Mineure | `fix/gen-b4-ci-regtool-target` | 962e156 | Makefile asylum standard (identique aux 17 copies des IPs), `mk/defs.mk`, `mk/targets.txt`, et cible `sim_regtool_example1` : regtool sur `examples/example1.hjson`, puis analyse, élaboration et exécution GHDL. `ci.yml` est généré par `make ci_generate`. | `asylum-sim.sh` RC=0 | Compatible (CI seulement) | `-Wall` sans `-Werror` : l'exemple généré produit encore le warning « `fifo_sw2hw_rdata_hw` never referenced ». |
| GEN-B5 | Mineure | `fix/gen-b5-csr-read-side-effect` | 3e00e24 | `csr_reg` (rsw1c/rsw0c/rcw1s) : l'effet de lecture est appliqué après la donnée matérielle, sur les bits effectivement lus. | TB `csr_reg` de travail : il échoue sur la base (rsw1c avec `hw_we='1'`) et passe sur la branche. `sim_spinlock` contre ces generators locaux : SUCCESS. | **Rupture** (sémantique des modèles regtool, seulement si `hw_we='1'` coïncide avec une lecture) : l'effet de lecture s'applique là où il était ignoré. Aucune IP actuelle n'est touchée. | — |
| GEN-B6 | Mineure | `fix/gen-b6-enum-raw-constants` | be1beda | En VHDL, `_RAW` est déclaré sur `csr['width']`. Dans l'en-tête C, l'enum et `_RAW` sont écrits en `0x<valeur analysée>`. | Régénération des 9 IPs (base contre branche) et d'un test d'enum : la base échoue à l'analyse GHDL et son en-tête ne compile pas ; la branche passe. Seule différence sur les 9 IPs : les valeurs d'enum de `SPI_csr.h` passent en hexadécimal. | Compatible (mêmes valeurs ; le texte de l'en-tête généré change) | — |
| GEN-B7 | Mineure | `fix/gen-b7-disabled-fifo-flags` | 5777789 | Registre FIFO désactivé : `*_empty` sont pilotés à '1' et `*_full` à '0', comme une FIFO vide. | TB GHDL (FIFO avec `enable=false`) : drapeaux à 'U' sur la base, corrects sur la branche. `UART_csr.vhd` gagne seulement ces lignes. | Compatible | — |
| GEN-B8 | Mineure | `fix/gen-b8-rvcc-rom-size` | 84994af | Nouveau paramètre rvcc `addr_width` (10 par défaut), passé à `gen_rom --addr-width`. `link.ld` prend `LENGTH = _rom_size` (4 << addr_width octets). Le Makefile n'est réécrit que s'il change. | Par défaut : hex, ROM et package identiques à la base. `addr_width=12` régénère sur 12 bits. `addr_width=8` donne « region ROM overflowed ». | **Rupture** (carte mémoire firmware) : la ROM de `link.ld` passe de 32 Kio à 4 Kio par défaut, la taille réelle. Un programme de 4 à 32 Kio échoue désormais à l'édition de liens au lieu d'échouer dans `gen_rom`. Interface générée inchangée par défaut. | Changer `addr_width` ne relance pas l'édition de liens de l'ELF ; `gen_rom` intercepte toujours une ROM trop petite. |
| (compagnon de SOC-B3) | — | `fix/soc-b3-rvcc-clear-regs` | d9aeab0 | `start.S` met d'abord x1..x31 à 0 (`.irp` + `li`, 31 `li` dans le désassemblage). | PicoSoC `sim_soc4_wardrv_fsm_fault_c_user_modbus_rtu` (instantané de `fix/soc-b3-lockstep-data-compare`, avec cette branche comme cores-root) : RC=0, « Simulation SUCCESS ». | Compatible (+124 octets de ROM par firmware rvcc) | À publier **avant ou avec** SOC-B3. |

Toolchain RISC-V utilisée : gcc-riscv64-unknown-elf 10.2 / binutils 2.35 (paquets Ubuntu 22.04). L'image CI utilise gcc 13 / binutils 2.42, **non testés**. Les 9 branches fusionnées ensemble (clone de travail) : tous les firmwares rvcc de PicoSoC se construisent, et les CSR des 9 IPs ainsi que les 2 hjson de test se régénèrent et passent l'analyse GHDL.

## Merges à faire

### Dans chaque dépôt

Les branches d'un même dépôt sont indépendantes. Les conflits connus sont listés ci-dessous. Pour ceux marqués « garder les deux », il suffit de conserver les deux textes.

| Dépôt | Ordre conseillé / conflits connus |
|-------|-----------------------------------|
| WardRV | B1, B2 et B3 dans n'importe quel ordre. B2 et B3 touchent `WardRV.core`, `mk/targets.txt` et le README à des endroits différents, sans conflit attendu. Après le merge : lancer `make ci_generate`, car le `ci.yml` de `debug_unit` n'a ni les jobs `sim_debug_*`, ni `sim_irq`, ni `sim_bridge_imem2sbi`. Le mode WARL de `mtvec` (B1) pourra ensuite être testé dans `esw/irq`. |
| OpenBlaze8 | Le code fusionne sans conflit (7 branches fusionnées : 47/47 PASS). README : B2 avec B3 (table des paramètres) et B2 avec B5 (table des cibles), garder les deux. |
| PicoSoC | Les 8 branches fusionnent sans conflit (vérifié). Merger **B2 avec B7**, et **B3 seulement avec le compagnon generators** (voir plus bas). |
| ICN | B1, B2 et B4 touchent `sbi_icn.vhd`, le TB ou le README : petits conflits textuels possibles dans le README. Les modifications HDL sont à des endroits distincts. |
| techmap | Pas de conflit attendu. TMAP-B2 seulement après un passage nxmap. |
| SPI | Seuls deux couples entrent en conflit, dans le README : B1 avec B2 (ligne `sim/basic` de la table de vérification) et B3 avec B5 (tables de paramètres). Garder les deux. Les 7 branches fusionnées passent les sims. |
| UART | Conflits réels : B3, B4 et B5 dans `UART.hjson` (champs de `status`, largeur d'isr/imr), dans `sbi_uart` (vecteur `it`, `hw2sw.status`, process de statut) et dans les CSR générés (**à régénérer après le merge**) ; B3 et B4 sur les ports de `uart_rx_axis`, le composant de `uart_pkg` et l'état STOP ; B3 et B6 sur l'affectation de `uart_rts_b`. Ordre conseillé : B1, B2, B6, B7, puis B5, B3, B4. Les tests 10 à 15 sont numérotés et se concatènent. |
| GPIO | B1, B3, B4 et B6 modifient des lignes voisines de `GPIO_irq_core.vhd`, `tb_GPIO_irq.vhd` et du README (« Edge Interrupts ») ; B1 et B2 réécrivent la même phrase du README. Résolution à la main. Ordre conseillé : B1, B2, B3, B4, B6, B5, B7. |
| timer | Les 5 branches touchent `timer_core.vhd`, le TB et le README (nombres de checks) : conflits certains. Deux conflits sont **sémantiques**. **B1 avec B2** : le registre de rejeu doit mémoriser l'événement et non le niveau, soit `timer_it_r <= timer_event; gic_it(0) <= timer_event or (timer_it_r and sw2hw_i.isr.we)`. **B1 avec B3** : merger B1 d'abord, puis rebaser B3 en gardant les attentes de B1 dans les sections 1, 3, 7 et 8 du TB, et la règle de B3 (masqué : isr à 1, `it_o` à 0). |
| clock_divider | Pas de conflit attendu. |
| crc | B1 et B2 touchent tous deux le README et le HDL. Le couple n'a pas été vérifié. |
| fifo, ram | Pas de conflit attendu. |
| stack | STACK-B1 et KC3-B3 fusionnent sans conflit (vérifié avec `git merge-tree`). |
| GIC | B1, B2 et B3 touchent `sbi_GIC`/`GIC_core`, le TB et le README : conflits probables. Ordre conseillé : B3, B2, B1, B4. |
| mailbox | B1 et B2 touchent `sbi_mailbox.vhd` : petit conflit possible. |
| utils-pkg | Seul B3 avec B4 entre en conflit, dans `hdl/ft_pkg_body.vhd` (déclarations et début du décodage ECC). Garder l'alias `enc` de B3, appliquer `max(REDUNDANCY_SIZE,1)` et les contrôles de B4, et utiliser `to_hstring(enc)`. Les 5 branches fusionnées dans l'ordre B1→B5 passent 8/8. Une résolution `rerere` est enregistrée dans `.git/modules/asylum-utils-pkg/rr-cache/a9bad52dc866ec9c6f96716985afaf9a3eab7614` : la supprimer si on ne veut pas qu'elle soit rejouée. |
| generators | Aucun conflit : vérifié par paire avec `git merge-tree`, puis merge des 9 branches dans un clone de travail. Certaines branches touchent les mêmes fichiers, mais dans des blocs distincts : B2 et le compagnon SOC-B3 (`start.S`), B1, B3 et B8 (`Makefile.j2`), B3 et B8 (`link.ld`), B3, B4 et B8 (`generators.core`). Publier le compagnon SOC-B3 avant ou avec PicoSoC. |

### Entre dépôts

| # | Dépendance | Action |
|---|-----------|--------|
| 1 | **SOC-B3 a besoin de `asylum-utils-generators` `fix/soc-b3-rvcc-clear-regs`** | Publier d'abord la version de generators qui remet x1..x31 à 0 dans `start.S`. Sans elle, `sim_soc4_wardrv_fsm_fault_c_user_modbus_rtu` passe au rouge. |
| 2 | **GPIO-B5 casse la carte d'adresses de PicoSoC** | `PicoSoC.core` accepte n'importe quelle GPIO `>=1.0.0` : la publication de GPIO avec B5 dans asylum-cores casse PicoSoC immédiatement. Avant ou avec cette publication, déplacer SWITCH/LED0/LED1 (0x04/0x08/0x0C) sur des créneaux de 8 octets alignés, par exemple dans la plage libre 0x30–0x3F (`esw/include/addrmap_user.h` et `PicoSoC_user.vhd`). Les adresses du superviseur (0x10, 0x20) ne bougent pas. Sinon, fixer la version de GPIO dans PicoSoC.core. |
| 3 | SPI-B1 agrandit la fenêtre SPI | Dans PicoSoC, le SPI à 0x18 occupe désormais 0x18–0x1F. Pas de chevauchement avec l'UART (0x20), mais à vérifier à l'intégration. |
| 4 | Contraintes de version `>=` dans PicoSoC.core | Toutes les IPs sont prises en `>=x.y.z`, donc toute rupture de la colonne Compat se propage dès la publication dans `lib/asylum-cores`. À relire avant de publier : GPIO-B4/B5/B6, TIMER-B1/B3/B4, UART-B2/B5/B7, GIC-B2, SPI-B1/B2/B4, CRC-B1/B2, OB8-B2/B4, KC3-B2, STACK-B1. |
| 5 | KC3-B3 (stack) → OpenBlaze8 | Après publication de stack avec `CYCLIC_PTR`, OpenBlaze8 doit instancier la pile avec `CYCLIC_PTR => true`, ajouter un test de sous-dépassement (33 CALL / 34 RETURN) et dépendre de cette version de stack. |
| 6 | OB8-B4 → PicoSoC | Ajouter un synchroniseur de reset sur `arst_b_i` dans PicoSoC, puisque le reset du cœur est désormais entièrement synchrone. |
| 7 | KC3-B2 → PicoSoC | Le premier fetch arrive 2 cycles plus tard. Rien à faire a priori, à surveiller si un TB compte les cycles. |
| 8 | GIC-B2 → UART | L'ISR de l'UART affichera aussi les sources masquées quand l'UART passera à cette version du GIC. Adapter le TB UART si besoin. |
| 9 | UART-B1 / UART-B5 → PicoSoC | Le synchroniseur RX de `PicoSoC_top` devient redondant (on peut le retirer). `UART_IT_TX_EMPTY_B` (bit 0) veut maintenant dire « FIFO TX vide ». |
| 10 | MBX-B1 / SPIN-B1 / SPI-B3/B5 → PicoSoC (optionnel) | Utiliser les registres de statut du mailbox dans `mailbox_pop`/`mailbox_push`. Le mode propriétaire du spinlock demande des macros esw et `OWNER_ID=true`. Régler `CS_HIGH_MIN_CYCLES`/`RX_LATE_SAMPLE` selon la flash. |
| 11 | RAM-B2 / FIFO-B2 / GPIO-B7 | Ces IPs passent en `vhdlSource-2008` : vérifier les flows non-GHDL (nxmap, Vivado) des IPs qui les utilisent. |

### Superprojet et bibliothèque de cores

1. Merger les branches dans chaque dépôt (PR GitHub), en incrémentant la version du `.core` : mineure pour un changement compatible, majeure ou mineure selon la politique habituelle pour une rupture.
2. Publier les nouvelles versions dans `lib/asylum-cores` dans l'ordre des dépendances : utils-pkg, generators, techmap, ram, fifo, stack, crc, clock_divider, GIC, mailbox, spinlock, ICN, GPIO, timer, UART, SPI, OpenBlaze8, WardRV, puis PicoSoC en dernier (actions 1, 2 et 5 ci-dessus).
3. Avancer les sous-modules dans asylum-project. Pour le timer, cela corrige aussi TIMER-B6 (`afaafd7` → au moins `2c4983c`).
4. Relancer la CI de chaque dépôt. WardRV : `make ci_generate` avant.

## Récapitulatif des ruptures de compatibilité

| Type | Bugs |
|------|------|
| Carte de registres / adresses | GPIO-B5 (fenêtre 4 → 8 octets), SPI-B1 (fenêtre 4 → 8 octets). Ajouts compatibles dans la fenêtre existante : UART-B3/B4/B5 (`status`@0x3), MBX-B1 (`status0/1`). |
| Sens d'un bit / comportement logiciel | UART-B5 (isr bit 0 : FIFO TX vide), UART-B7 (écrire LSB puis MSB), TIMER-B4 (écrire `byte3` en dernier), GIC-B2, GPIO-B4 et TIMER-B3 (ISR non masqué, IMR en sortie), TIMER-B1 (IT seulement à l'expiration), GPIO-B6 (pas d'IT sur les sorties), SPI-B2 (commandes jetées quand le SPI est désactivé), PKG-B5 (`to_string` sur 1 caractère) |
| Comportement matériel / timing | OB8-B4 (reset synchrone), STACK-B1 (reset asynchrone), KC3-B2 (+2 cycles de reset), UART-B2 (blocage avec `DEPTH_TX=0`), SPI-B2 (pads pilotés en reset), SPI-B4 (HOLD#/WP# hauts au repos), CRC-B2 (CRC lisible 1 cycle plus tôt), GIC-B3 (vecteurs ascendants) |
| Génériques par défaut | OB8-B2 (`REGFILE_SYNC_READ=false`), CRC-B1 (CRC standard par défaut) |
| Élaboration plus stricte | ICN-B2 (one-hot qui se chevauche), MBX-B2 (profondeurs puissances de 2). OB8-B3 refuse aussi des génériques, mais ils ne fonctionnaient déjà pas : il est classé compatible. |
| Type de fichier FuseSoC | FIFO-B2, RAM-B2, GPIO-B7 (`vhdlSource-2008`) |
| Cibles FuseSoC | SOC-B4 (cibles `*_fault_c_user_uart` renommées), SOC-B6 (cibles Basys retirées), GPIO-B7 (toplevel de `default`) |
| Firmware rvcc (carte mémoire) | GEN-B3 (la pile par défaut occupe toute la RAM : une variable globale demande de réduire `stack_size` ; les petites constantes `.srodata` déclenchent l'erreur rodata), GEN-B8 (ROM de `link.ld` ramenée de 32 Kio à 4 Kio par défaut) |
| Sémantique des modèles regtool | GEN-B5 (effet de lecture de rsw1c/rsw0c/rcw1s appliqué même quand `hw_we='1'`) |

Tous les autres correctifs sont compatibles. Ajouts compatibles de ports, génériques ou registres avec valeur par défaut : WRV-B2/B3, SPI-B3/B5/B6, MBX-B1, SPIN-B1, KC3-B3, CLKDIV, RAM-B1/B3, FIFO-B1, ICN-B1/B3/B4, TMAP-B1, PKG-B1..B4, GEN-B1/B2/B4/B6/B7 et le compagnon SOC-B3.

## Branches `lint_ghdl`

Ajoutées le 2026-10-20, hors revue, à la demande. Chaque dépôt `ip/asylum*` a une branche `lint_ghdl` : un commit deuskane, sans trailer ni upstream, depuis `origin/main` (WardRV : `origin/debug_unit`). Elle ajoute deux cibles FuseSoC :

- **`lint_ghdl`** : analyse et élaboration GHDL en `-Wall` du top de lint. L'étape `run` est une simulation vide.
- **`lint_ghdl_synth`** : la même analyse, puis un hook `post_run` (`syn/ghdl/ghdl_synth.sh`). Le hook lance `ghdl --synth --std=08 -Wall` sur une ou plusieurs configurations de génériques et échoue sur une erreur de synthèse ou un latch inféré. Il affiche le nombre de warnings par configuration. C'est le modèle du `lint_ghdl_synth` qui existait déjà dans WardRV.

Choix communs :

- **`-Wall` sans `-Werror`** : les warnings sont listés, pas corrigés, et le `-Werror` déjà présent dans le `lint_ghdl` de fifo est conservé.
- **Top** : quand les ports d'une IP ne sont pas contraints (records SBI), un wrapper `syn/ghdl/<Nom>_synth_top.vhd` est ajouté dans la bibliothèque `work`.
- **Fichiers** : `mk/targets.txt` est régénéré et le README est mis à jour.
- **CI** : les cibles ne sont **pas** en CI, car `make ci_generate` ne reprend que les `sim_*`. `make nonreg_lint` les lance toutes.

| Dépôt | Commit | Top de lint | Configurations de synthèse | `lint_ghdl` | `lint_ghdl_synth` | Conflits avec les `fix/*` |
|-------|--------|-------------|----------------------------|-------------|-------------------|---------------------------|
| clock_divider | 748869b | `clock_divider` | 5 | PASS, 0 warning | PASS | aucun |
| crc | 0c92ef6 | wrapper `sbi_crc_synth_top` | 6, dont MODBUS (PicoSoC) | PASS, 8 warnings (CSR généré) | PASS | aucun |
| fifo | 0149eb3 | `fifo_sync` (`lint_ghdl` existant gardé, `-Werror`) | 5 | PASS | PASS | README avec FIFO-B1 et FIFO-B2 |
| ram | 0744867 | wrapper (`ram_1r1w`, `ram_2r1w`, `ram_1rw`, `sbi_ram`) | 5 | PASS, 0 | PASS | `.core`, `mk/targets.txt` et README avec RAM-B1 ; README avec RAM-B2 |
| stack | bfcfdbe | `stack` | 4, dont la pile d'OpenBlaze8 | PASS, 0 | PASS | `.core`, `mk/targets.txt` et README avec KC3-B3 |
| utils-pkg | dba238c | wrapper `ft_synth_top` (`ft_dff`, `ft_enc`, `ft_dec` et tous les paquetages) | 5 : none, parité, TMR, ECC, ECC avec self-refresh | PASS, 5 warnings | PASS, 1 warning par configuration | aucun |
| techmap | 243a853 | wrapper avec une instance de chaque cellule générique (`target_generic.core`) | 3 | PASS, 0 | PASS, 3 warnings `inout` sans conséquence | aucun |
| generators | dda8523 | wrapper `csr_synth_top` (10 modèles de `csr_reg`, `csr_ext`, `csr_fifo`) | 5 | PASS, 0 | PASS | `generators.core` et `mk/targets.txt` (add/add) avec GEN-B4 ; `Makefile` et `mk/defs.mk` sont identiques et fusionnent sans conflit |
| gic | 1615e11 | wrapper (`sbi_GIC` et `it_ctrl`) | 4 | PASS, 3 warnings (CSR) | PASS | README avec GIC-B1 et GIC-B2 |
| mailbox | 3b9e139 | wrapper | 4, dont celle de PicoSoC | PASS, 4 warnings (CSR) | PASS | README et `mk/targets.txt` avec MBX-B1 |
| spinlock | 88b3223 | wrapper | 1 | PASS, 6 warnings (CSR) | PASS | README, `mk/targets.txt` et `.core` avec SPIN-B1 |
| timer | f29194c | wrapper (`sbi_timer` et `timer_v1`) | 2 | PASS, 10 warnings (CSR) | PASS | aucun |
| gpio | ca66743 | wrapper (`sbi_GPIO` et `sbi_GPIO_irq`) | 3 | PASS, 14 warnings (CSR) | **FAIL** (bug regtool, voir plus bas) | README avec GPIO-B1, B2 et B7 |
| uart | 0b86ddd | wrapper `sbi_UART_synth_top` | 5 | PASS, 7 warnings dans l'IP et 9 dans le CSR | PASS | README avec UART-B1 |
| spi | 5a8f82d | wrapper `sbi_SPI_synth_top` (`SPI.core` seulement) | 4 | PASS, 1 warning dans l'IP et 7 dans le CSR | PASS, 1 warning dans 3 configurations | `mk/targets.txt` avec SPI-B5 |
| icn | ab3e2af | wrapper et paquetage, carte d'adresses choisie par générique | 6 : ICN1/ICN2 de PicoSoC, round-robin, TB, pipes, one-hot | PASS, 0 | PASS | README et `mk/targets.txt` avec ICN-B1 |
| OpenBlaze8 | 230e207 | wrapper (`OpenBlaze8` et `sbi_OpenBlaze8`) | 4 | PASS, 0 | PASS | `mk/targets.txt` avec OB8-B2 ; README avec OB8-B5 |
| WardRV | e5449d1 | `WardRV_synth_top` existant | les 6 configurations existantes, maintenant en `-Wall` | PASS, 4 warnings | PASS, 1 warning par configuration | `WardRV.core` avec WRV-B3 |
| PicoSoC | b631597 | `PicoSoC_top`, sans wrapper | `lint_ghdl_synth` (OpenBlaze8) : 4 ; `lint_ghdl_synth_wardrv` (3e cible) : 3, dont multi-CPU | PASS, 73 warnings, dont 54 dans les CSR | **FAIL** sur la configuration `basys` (bug RTL déjà présent sur la base) ; `_wardrv` PASS | README avec SOC-B6 |

Les conflits listés se résolvent tous en gardant les deux côtés. Pour `mk/targets.txt`, il suffit de le régénérer avec `make mk/targets.txt`.

### Échecs révélés par le lint

Les deux échecs ont été conservés et sont documentés dans le commit et le README.

- **GPIO, `lint_ghdl_synth`.** `ghdl --synth` refuse le `GPIO_csr.vhd` commité : il y a des assignations multiples sur `data_wbusy` et `data_in_wbusy`.
  - Cause : bug de regtool 2.7.1. `regtool.py:904` écrit `<reg>_wbusy <= '0'` pour un registre sans écriture logicielle (`ro`) ou écrit via `alias_write`. `regtool.py:946` connecte en plus `sw_wbusy_o` à ce même signal.
  - Correctif : à faire dans `asylum-utils-generators`, puis régénérer `GPIO_csr.vhd`. Aucune branche `fix/gen-*` ne le corrige.
- **PicoSoC, configuration `basys` de `lint_ghdl_synth`.** `USER_NB_LED0` et `USER_NB_LED1` différents de 8 ne sont pas supportés :
  - `PicoSoC_user.vhd:481,504` : `data_i => X"00"` est câblé sur des GPIO de largeur `NB_LED*` ;
  - `PicoSoC_top.vhd:370` : `debug_o <= led0_user` est fixé à 8 bits.

  Après SOC-B6, qui retire les cibles Basys, on pourra retirer cette configuration, mais le bug reste pour toute carte qui a moins de 8 LEDs.

### Décisions à valider

- **techmap** : `cgate` est un latch voulu. Le wrapper a un générique `WITH_CGATE` : deux configurations synthétisent sans `cgate`, avec le contrôle strict des latches, et une configuration synthétise tout avec `--latches`. `target_ng_medium.core` n'est pas couvert, faute de bibliothèque `nx`.
- **PicoSoC** : une 3e cible, `lint_ghdl_synth_wardrv`, est ajoutée parce que la ROM est générée par CPU (pbcc ou rvcc) sous le même nom d'entité. Aucun générique ne permet de choisir l'une ou l'autre. Cette cible demande la toolchain RISC-V, et `make nonreg_lint` la lance aussi.
- **generators** : `mk/defs.mk`, repris tel quel de GEN-B4, a `TARGET ?= sim_regtool_example1`. Tant que GEN-B4 n'est pas mergé, `make` lancé sans cible n'a donc rien de valide à exécuter.

### Ajustements après le merge des `fix/*`

- **OpenBlaze8** : après OB8-B2, passer le défaut `REGFILE_SYNC_READ` du wrapper à `false` et échanger les noms des configurations `default` et `regfile_async`.
- **stack** : après KC3-B3, ajouter une configuration `CYCLIC_PTR=true`.
- **mailbox** : après MBX-B1, ajouter une configuration non bloquante.
- **spinlock** : après SPIN-B1, propager `OWNER_ID` dans le wrapper et ajouter une configuration `OWNER_ID=true`.
- **GPIO** : après GPIO-B7, le top `syn/GPIO_top.vhd` fait le même travail que le wrapper de lint. N'en garder qu'un.

### Warnings à corriger (code des IPs, pas les CSR générés)

- **WardRV** :
  - `others` redondants : `dmem2sbi.vhd:126`, `WardRV_fsm_alu.vhd:95`, `WardRV_fsm.vhd:716` ;
  - `WardRV_fsm.vhd:149` : `pending_report_r` n'est jamais référencé ;
  - `WardRV_fsm_csr.vhd:65` : `mhartid_r` n'est jamais assigné. Il devrait être une `constant`. C'est le warning de synthèse de chaque configuration.
- **UART** :
  - `sbi_uart.vhd:231,245,317,327` : labels de generate imbriqués qui masquent ceux du niveau supérieur (`-Whide`) ;
  - `sbi_uart.vhd:394` : `line_raw` n'est jamais utilisé ;
  - `uart_rx_axis.vhd:182` : `others` redondant.
- **SPI** : `spi_master.vhd:314` compare des `std_logic_vector` avec `<=`. La comparaison devrait se faire en `unsigned`.
- **utils-pkg** :
  - `ft_pkg_body.vhd:128,175,222,340` : `others` redondants ;
  - GHDL ignore l'attribut `syn_preserve` de `ft_dff.vhd:54`.
- **PicoSoC** :
  - `cpu_safety.vhd:366-388` : listes de sensibilité des process de rapport (`-Wsensitivity`) ;
  - `cpu_safety.vhd:103,114,129` : signaux non assignés selon le mode de sûreté ;
  - `PicoSoC_top.vhd:91-93` : ports `inout` SPI sans assignation ;
  - la simulation vide de `lint_ghdl` émet un « `NUMERIC_STD.TO_UNSIGNED: vector truncated` » à 1 ps, dont l'origine n'a pas été tracée.
- **regtool, à corriger dans le générateur** : dans tous les `*_csr.vhd`, choix `others` redondants et signaux `*_wdata_hw` ou fonctions `INIT_*` inutilisés. Le générateur de ROM laisse aussi un `rom` jamais assigné.

## Limites et points non vérifiés

- **NanoXplore (nxmap) non disponible** : TMAP-B1 (syntaxe des attributs), TMAP-B2 (primitive `NX_CKS`), SOC-B2 (pads), PKG-B1 (fusion des copies TMR), RAM-B3 (mode de collision NX_RAM). À valider avec un run nxmap avant de merger, au moins TMAP-B2 et SOC-B2.
- **OpenOCD/gdb non disponibles** : `cosim_openocd` de WardRV n'a pas été relancé.
- **Firmware rvcc** :
  - GEN-B2 et GEN-B3 ont été vérifiés par édition de liens et désassemblage, mais pas exécutés dans une simulation ;
  - toolchain gcc 10.2 / binutils 2.35, alors que la CI utilise gcc 13 / binutils 2.42.
- **SPI** : les modèles de flash `cy15b104qs`, `cy15v104qs`, `m45pe80` et `s25fl064p` n'ont jamais réellement tourné. L'ancien script ignorait `MODEL` et simulait m25p40 à leur place, donc leurs PASS de base étaient faux. Il faut les relancer.
- **Correctifs partiels** :
  - PKG-B1 : Yosys fusionne toujours les copies TMR.
  - RAM-B3 : documentation seule.
  - CLKDIV-B2 : documentation seule.
  - SPI-B1 : pas de timeout ni de mode non bloquant.
  - SPI-B2 : FIFO RX non vidée.
  - SPI-B5 : SCLK combinatoire.
  - SOC-B1 : pas d'anti-rebond.
  - ICN-B3 : un accès abandonné reste une violation de protocole.
- **Points de la revue contestés** :
  - PKG-B5 : pas d'ambiguïté en VHDL-2008.
  - WRV-B2 : un correctif plus complet que celui proposé.
  - TIMER-B1 : une condition d'événement différente.
  - OB8-B2 : un second DUT au lieu d'une cible séparée.

## Suivis hors revue relevés pendant les corrections

- **regtool 2.7.1** (`asylum-utils-generators`) :
  - un registre `ro` ou `alias_write` pilote deux fois `<reg>_wbusy`. C'est sans effet en simulation, mais c'est un multi-driver en synthèse. Le défaut est déjà présent dans le `GPIO_csr.vhd` commité (`data`). Les correctifs UART, GPIO, mailbox et SPI l'ont contourné avec des registres `ext` ;
  - `csr_fifo` n'exporte pas le nombre d'éléments (`nb_elt`) et n'a ni option non bloquante ni timeout. Il faudrait les ajouter, au bénéfice de UART-B3, SPI-B1 et MBX-B1 ;
  - il manque un modèle W1C « set prioritaire » (`q_next = (q and not clr) or set`). Il remplacerait les rejeux locaux de GIC-B1, GPIO-B3 et TIMER-B2.
- **PicoSoC** : `GIC_TIMER_MSK` vaut 0x03 dans `esw/include/addrmap_user.h`, alors qu'il devrait sans doute valoir 0x04 (bit 2).
- **GPIO** : `tb_GPIO_vs_v1` peut se passer de `-frelaxed`.
- **PicoSoC** : `esw/user_xmodem.c` ne compile pas avec gcc 10, même sur la base (erreur de syntaxe ligne 77). Aucune cible de simulation lancée ne l'utilise.
- **generators** :
  - le `link.ld` de base échouait dès que le contenu de la RAM n'était pas un multiple de 16 octets (corrigé par GEN-B3) ;
  - l'exemple regtool génère un signal non référencé (`fifo_sw2hw_rdata_hw`), ce qui empêche de passer la CI en `-Werror` ;
  - `cache_type: generator` est toujours en place (point « à terme » de la revue).
- **utils-pkg** : un vrai contrôle du propriétaire du spinlock demanderait un identifiant de maître dans `sbi_ini_t`.
