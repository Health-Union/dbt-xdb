from typing import List
import re
import os
import sys
from dataclasses import dataclass

@dataclass
class Macro:
    name: str
    module: str
    
    @property
    def is_private(self)->bool:
        return self.name.startswith('_')

    @property
    def expected_model(self)->str:
        return f"/app/models/under_test/{self.name}_test.sql"


def macro_has_matching_test_model(macro):
    """ checks tha there is a matching test model
    for a given macro. """
    return os.path.exists(macro.expected_model)

def macro_is_called_in_model(macro):
    """ checks that the subject macro is called 
    in the given test model."""
    executed_macro_pattern = fr'\{{\{{\s*xdb\.{macro.name}\(.*\)\s*\}}\}}'
    with open(macro.expected_model,'r') as model:
        return bool(re.search(executed_macro_pattern,model.read()))

def macro_model_has_tests():
    """ checks that the matching macro test 
    model is actually tested. """
    pass

def lint_macro_lowercase_name(macro):
    """ checks that all macros are lowercase."""
    return macro.name.islower()

def lint_private_macros_are_namespaced():
    """ checks that all private macros are namespaced 
    to a public macro in the same module."""
    pass

def _extract_macro_name(signature:str)->str:
    start_stub = ' macro '
    start = signature.index(start_stub) + len(start_stub)
    end = signature.index('(') 
    return signature[start:end]
 
def get_all_eligible_macros()->List[Macro]:
    """ finds and returns all eligible macros."""
    root='/dbt-xdb/macros'
    for base, dirs, files in os.walk(root):
        if base != root + '/utilities':
            macro_files = [os.path.join(base,filename) for filename in files if filename.endswith('.sql')]
    
    macros = list()
    macro_regex=r'\{%-?\s*macro\s+\w*\(.*\)\s*-?%\}'
    for module in macro_files:        
        with open(module, 'r') as module_file:
            matches = [re.search(macro_regex, line) for line in module_file]
            macro_signatures = [match.group() for match in matches if match]
        for signature in macro_signatures:
            macros.append(Macro(_extract_macro_name(signature),
                                module))
    return macros  

def build_coverage_matrix():
    results = list()
    macros = get_all_eligible_macros()
    for macro in macros:
        result = dict(results=dict())
        result['macro'] = macro.name
        result['results']['has_model'] = macro_has_matching_test_model(macro)
        result['model_path'] = macro.expected_model if result['results']['has_model'] else ''
        result['results']['called_in_model'] = result['results']['has_model'] and\
             macro_is_called_in_model(macro)
        result['results']['lint_casing'] = lint_macro_lowercase_name(macro)
        results.append(result)
    return results

def coverage_passes():
    return all([all(result.items()) for result in build_coverage_matrix()])
 

if __name__ == '__main__':
    cov = coverage_passes()
    if '-v' in sys.argv:
        print(build_coverage_matrix())
    else:
        print("coverage passed" if cov else "coverage failed")          
    sys.exit(int(not cov)) 
