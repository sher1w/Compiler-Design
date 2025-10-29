
from collections import defaultdict


def read_grammar(filename):
    grammar = defaultdict(list)
    with open(filename, 'r', encoding='utf-8') as file:   
        for line in file:
            line = line.strip()
            if not line:
                continue
            lhs, rhs = line.split("->")
            lhs = lhs.strip()
            alternatives = []
            for alt in rhs.split('|'):
                symbols = [sym if sym != 'epsilon' else 'ε' for sym in alt.strip().split()]
                alternatives.append(symbols)
            grammar[lhs].extend(alternatives)
    return grammar

def compute_first(grammar):
    first = defaultdict(set)

    def first_of(symbol):
        if symbol in first:
            return first[symbol]
       
        if symbol not in grammar:
            first[symbol].add(symbol)
            return first[symbol]
        for production in grammar[symbol]:
            if production == ['ε']:
                first[symbol].add('ε')
            else:
                for sym in production:
                    sym_first = first_of(sym)
                    first[symbol].update(sym_first - {'ε'})
                    if 'ε' not in sym_first:
                        break
                else:
                    first[symbol].add('ε')
        return first[symbol]

    for non_terminal in grammar:
        first_of(non_terminal)

    return first


def compute_follow(grammar, first, start_symbol):
    follow = defaultdict(set)
    follow[start_symbol].add('$')  

    changed = True
    while changed:
        changed = False
        for lhs in grammar:
            for production in grammar[lhs]:
                for i, B in enumerate(production):
                    if B in grammar:  
                        rest = production[i+1:]
                        temp = set()
                        if rest:
                            for sym in rest:
                                temp.update(first[sym] - {'ε'})
                                if 'ε' not in first[sym]:
                                    break
                            else:
                                temp.update(follow[lhs])
                        else:
                            temp.update(follow[lhs])
                        if not temp.issubset(follow[B]):
                            follow[B].update(temp)
                            changed = True
    return follow


if __name__ == "__main__":
    filename = "grammar.txt"
    grammar = read_grammar(filename)
    print("Grammar:")
    for k, v in grammar.items():
        formatted = [[sym if sym != 'ε' else 'ε' for sym in prod] for prod in v]
        print(f"{k} -> {formatted}")

    first = compute_first(grammar)
    print("\nFIRST sets:")
    for non_terminal, fset in first.items():
        fset_str = ', '.join(['ε' if x == 'ε' else x for x in fset])
        print(f"FIRST({non_terminal}) = {{ {fset_str} }}")

    start_symbol = list(grammar.keys())[0]
    follow = compute_follow(grammar, first, start_symbol)
    print("\nFOLLOW sets:")
    for non_terminal, fset in follow.items():
        fset_str = ', '.join(['ε' if x == 'ε' else x for x in fset])
        print(f"FOLLOW({non_terminal}) = {{ {fset_str} }}")
