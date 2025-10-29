
def read_grammar(filename):
    grammar = {}
    with open(filename, 'r', encoding='utf-8') as file: 
        for line in file:
            line = line.strip()
            if not line:
                continue
            if '->' in line:
                parts = line.split('->', 1)
            elif '→' in line:
                parts = line.split('→', 1)
            else:
                print(f"Skipping invalid line (no arrow found): {line}")
                continue
            if len(parts) != 2:
                print(f"Skipping invalid line (cannot unpack): {line}")
                continue
            lhs = parts[0].strip()
            rhs = parts[1].strip()
            productions = [p.strip() for p in rhs.split('|')]
            grammar[lhs] = productions
    return grammar

def eliminate_left_recursion(grammar):
    new_grammar = {}
    
    for non_terminal, productions in grammar.items():
        recursive = []
        non_recursive = []
        
        for prod in productions:
            if prod.startswith(non_terminal):
                
                recursive.append(prod[len(non_terminal):].strip())  
            else:
                non_recursive.append(prod)
        
        if recursive:
            new_non_terminal = non_terminal + "'"
            new_grammar[non_terminal] = [nr + " " + new_non_terminal for nr in non_recursive]
            new_grammar[new_non_terminal] = [r + " " + new_non_terminal for r in recursive] + ['ε']
        else:
            new_grammar[non_terminal] = productions
    
    return new_grammar


def print_grammar(grammar):
    for non_terminal, productions in grammar.items():
        print(f"{non_terminal} → {' | '.join(productions)}")


if __name__ == "__main__":
    filename = "grammar.txt"  
    grammar = read_grammar(filename)
    
    print("Original Grammar:")
    print_grammar(grammar)
    
    grammar_no_left_recursion = eliminate_left_recursion(grammar)
    print("\nGrammar after eliminating left recursion:")
    print_grammar(grammar_no_left_recursion)
