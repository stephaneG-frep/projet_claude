# Le simulateur CPU — ASMForge

## Objectif et périmètre de sécurité

Le simulateur d'ASMForge est un **interpréteur pédagogique isolé**, écrit entièrement en Dart pur (`lib/core/simulator/`), sans aucune dépendance Flutter. Conformément à la section 39 du cahier des charges :

- Il n'exécute **jamais** de code natif : il ne fait qu'interpréter un sous-ensemble d'instructions dans une machine virtuelle purement logicielle.
- Il n'accède à aucun fichier, aucun réseau, aucun processus externe.
- Toute sa mémoire (registres, flags, mémoire simulée, pile) vit dans des objets Dart ordinaires, réinitialisés à chaque `reset()`.

## Pipeline

```
Source (String)
   │
   ▼
Tokenizer            → List<SourceLine>   (commentaires retirés, étiquettes et mnémoniques séparés)
   │
   ▼
AssemblyParser        → ParsedProgram      (List<Instruction> + table des étiquettes)
   │
   ▼
CpuSimulator.step()   → StepResult         (registres/flags modifiés, écritures mémoire, explication)
```

Chaque étage est testé indépendamment (`test/parser/assembly_parser_test.dart`, `test/simulator/cpu_simulator_test.dart`).

## Composants

| Fichier | Rôle |
|---|---|
| `tokenizer.dart` | Découpe le texte source en lignes exploitables (étiquette, mnémonique, opérandes). |
| `assembly_parser.dart` | Construit les `Instruction` et la table des étiquettes ; valide la syntaxe et le nombre/type d'opérandes. |
| `operand.dart` | Types d'opérandes : registre, immédiat, mémoire indirecte, étiquette. |
| `register_bank.dart` | Les 9 registres simulés (RAX, RBX, RCX, RDX, RSI, RDI, RSP, RBP, RIP). |
| `flag_register.dart` | ZF, CF, SF, OF. |
| `memory_manager.dart` | Mémoire simulée de 4096 octets, adressable par octet ou par mot de 8 octets (little-endian). |
| `stack_manager.dart` | PUSH/POP au-dessus de la mémoire, pilotant RSP. |
| `arithmetic.dart` | Calculs avec drapeaux, en 64 bits non signés exacts via `BigInt` (indépendant de la plateforme). |
| `cpu_simulator.dart` | Orchestrateur : `loadProgram`, `step`, `reset`, `runUntilPause`. |
| `explanation_generator.dart` | Génère les explications en français après chaque instruction (section 20 — sans IA externe). |
| `breakpoint_manager.dart` | Points d'arrêt par numéro de ligne source. |
| `execution_history.dart` | Historique des pas exécutés (`StepResult`). |
| `program_runner.dart` | Exécute un programme jusqu'à son terme et vérifie des conditions finales (utilisé par exercices, missions, projets). |
| `simulator_exceptions.dart` | Exceptions pédagogiques (`AsmParseException`, `AsmRuntimeException`) avec messages en français et suggestions (distance de Levenshtein). |

## Instructions supportées (21)

`MOV`, `ADD`, `SUB`, `INC`, `DEC`, `MUL`, `DIV`, `CMP`, `JMP`, `JE`, `JNE`, `JG`, `JL`, `JGE`, `JLE`, `PUSH`, `POP`, `CALL`, `RET`, `NOP`, `HLT`.

Chacune est documentée en détail (syntaxe, flags affectés, exemple, pièges fréquents) dans `assets/content/reference/reference.json`, affiché dans l'écran Référence de l'application.

## Simplifications pédagogiques assumées

Ces choix sont documentés ici et dans la Référence in-app, conformément à la règle « ne bloque pas tout le projet, explique la limitation, implémente la meilleure alternative fiable » (section 50) :

- **`MUL`** : sur un vrai x86-64, `MUL r64` produit un résultat 128 bits dans la paire `RDX:RAX`. ASMForge ne conserve que les 64 bits de poids faible dans `RAX`, et active `CF`/`OF` si le résultat réel aurait dépassé 64 bits — ce qui reste un signal correct de dépassement, sans complexifier l'apprentissage avec une paire de registres à ce stade.
- **`DIV`** : le dividende est uniquement `RAX` (et non la paire `RDX:RAX` comme sur du x86-64 réel) ; le quotient va dans `RAX`, le reste dans `RDX`, en arithmétique non signée.
- **Adressage mémoire** : seules les formes `[registre]`, `[registre+imm]`, `[registre-imm]` et `[imm]` sont supportées (pas d'échelle `[base + index*scale + disp]`).
- **`RIP`** représente l'index de l'instruction courante dans le programme analysé, pas une adresse mémoire réelle de code — cohérent avec le fait qu'ASMForge ne produit pas de vrai binaire.
- **`CALL`/`RET`** empilent/dépilent cet index d'instruction (et non une adresse mémoire de retour réelle), pour rester cohérents avec la représentation de `RIP` ci-dessus.
- **Directives NASM** (`section`, `global`, `extern`, `bits`, `default`) sont reconnues et ignorées silencieusement par le tokenizer, pour permettre de coller un extrait de programme NASM réel (Module 11) sans erreur de syntaxe bloquante — mais aucune sémantique de section ni aucun appel système n'est simulée.
- **Limite anti-boucle infinie** : `CpuSimulator.instructionLimit` (20 000 instructions) interrompt toute exécution qui dépasserait ce seuil, avec un message pédagogique explicite plutôt qu'un blocage de l'interface (section 36/37).
- **Précision entière** : les registres et la mémoire utilisent le type `int` de Dart (entier natif 64 bits sur les plateformes non-Web ; sur le Web, limité à la précision sûre de JavaScript, soit 2^53). Les calculs de flags utilisent `BigInt` en interne pour rester exacts indépendamment de la plateforme, mais la valeur stockée après coup reste soumise à cette limite native de `int`.

## Gestion des erreurs pédagogiques

Toute erreur (syntaxe, exécution) est une exception typée (`AsmParseException` ou `AsmRuntimeException`) portant un message humain en français, éventuellement une ligne source, et si pertinent une suggestion de correction (ex. « Le registre RXA n'existe pas. Vouliez-vous écrire RAX ? »). Aucune erreur brute (code numérique, exception Dart non traduite) n'est montrée à l'utilisateur final.
