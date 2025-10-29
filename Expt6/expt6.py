EPSILON = 'ε'

def read_grammar_from_file(filename):
    grammar = {}
    with open(filename, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "->" not in line:
                print(f"Skipping invalid line: {line}")
                continue
            head, body = line.split("->")
            head = head.strip()
            productions = [prod.strip().split() for prod in body.split("|")]
            grammar[head] = productions
    return grammar


def read_input_string(filename):
    with open(filename, "r") as f:
        line = f.readline().strip()
    return line.split()


class Grammar:
    def __init__(self, rules):
        self.rules = rules
        self.nonterminals = set(rules.keys())
        self.terminals = set(
            sym for rhs in rules.values() for prod in rhs for sym in prod
            if sym not in self.nonterminals and sym != EPSILON
        )
        self.terminals.add('$')


def first_sets(grammar):
    FIRST = {A: set() for A in grammar.nonterminals}
    for t in grammar.terminals:
        FIRST[t] = {t}
    FIRST[EPSILON] = {EPSILON}

    changed = True
    while changed:
        changed = False
        for A in grammar.nonterminals:
            for production in grammar.rules[A]:
                old_size = len(FIRST[A])
                for X in production:
                    FIRST[A].update(FIRST[X] - {EPSILON})
                    if EPSILON not in FIRST[X]:
                        break
                else:
                    FIRST[A].add(EPSILON)
                if len(FIRST[A]) != old_size:
                    changed = True
    return FIRST


def follow_sets(grammar, FIRST):
    FOLLOW = {A: set() for A in grammar.nonterminals}
    start_symbol = next(iter(grammar.rules))
    FOLLOW[start_symbol].add('$')

    changed = True
    while changed:
        changed = False
        for A, productions in grammar.rules.items():
            for prod in productions:
                for i, B in enumerate(prod):
                    if B in grammar.nonterminals:
                        after = prod[i + 1:]
                        if after:
                            first_after = set()
                            for sym in after:
                                first_after |= FIRST[sym] - {EPSILON}
                                if EPSILON not in FIRST[sym]:
                                    break
                            else:
                                first_after.add(EPSILON)
                            old = len(FOLLOW[B])
                            FOLLOW[B] |= first_after - {EPSILON}
                            if EPSILON in first_after:
                                FOLLOW[B] |= FOLLOW[A]
                            if len(FOLLOW[B]) != old:
                                changed = True
                        else:
                            old = len(FOLLOW[B])
                            FOLLOW[B] |= FOLLOW[A]
                            if len(FOLLOW[B]) != old:
                                changed = True
    return FOLLOW


def construct_parsing_table(grammar, FIRST, FOLLOW):
    table = {A: {} for A in grammar.nonterminals}
    for A in grammar.nonterminals:
        for production in grammar.rules[A]:
            first_prod = set()
            for sym in production:
                first_prod |= FIRST[sym] - {EPSILON}
                if EPSILON not in FIRST[sym]:
                    break
            else:
                first_prod.add(EPSILON)
            for terminal in first_prod - {EPSILON}:
                table[A][terminal] = production
            if EPSILON in first_prod:
                for b in FOLLOW[A]:
                    table[A][b] = production
    return table


def parse_string(grammar, table, input_tokens):
    stack = ['$', next(iter(grammar.rules))]
    input_tokens.append('$')
    index = 0

    print("\n{:<25} {:<25} {}".format("Stack", "Input", "Action"))
    print("-" * 65)

    while stack:
        top = stack[-1]
        current = input_tokens[index]
        print(f"{' '.join(stack):<25} {' '.join(input_tokens[index:]):<25}", end=' ')

        if top == current == '$':
            print("Accept")
            return True

        elif top == current:
            stack.pop()
            index += 1
            print(f"Match {current}")

        elif top in grammar.terminals:
            print(f"Error: Unexpected '{current}'")
            return False

        elif current in table[top]:
            production = table[top][current]
            stack.pop()
            if production != [EPSILON]:
                for sym in reversed(production):
                    stack.append(sym)
            print(f"{top} -> {' '.join(production)}")

        else:
            print(f"Error: No rule for [{top}, {current}]")
            return False

    print("Input not accepted.")
    return False


def demo():
    grammar_rules = read_grammar_from_file("grammar.txt")
    grammar = Grammar(grammar_rules)

    FIRST = first_sets(grammar)
    FOLLOW = follow_sets(grammar, FIRST)
    TABLE = construct_parsing_table(grammar, FIRST, FOLLOW)

    print("\nFIRST Sets")
    for k, v in FIRST.items():
        if k in grammar.nonterminals:
            print(f"FIRST({k}) = {v}")

    print("\nFOLLOW Sets")
    for k, v in FOLLOW.items():
        print(f"FOLLOW({k}) = {v}")

    terminals = sorted(list(grammar.terminals - {'$'})) + ['$']
    header = ["NT"] + terminals
    row_format = "{:>10}" * len(header)
    print("\nParse Table")
    print(row_format.format(*header))
    print("-" * (11 * len(header)))

    for A in grammar.nonterminals:
        row = [A]
        for a in terminals:
            if a in TABLE[A]:
                prod = " ".join(TABLE[A][a])
                row.append(f"{A}->{prod}")
            else:
                row.append("")
        print(row_format.format(*row))

    tokens = read_input_string("input.txt")
    print("\nInput String:", " ".join(tokens))
    parse_string(grammar, TABLE, tokens)


if __name__ == "__main__":
    demo()
