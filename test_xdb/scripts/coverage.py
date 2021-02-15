from typing import List, Tuple, Optional
import re
import os
import sys
import yaml
from dataclasses import dataclass


@dataclass
class TestCase:
    name: str
    test_count: int
    not_null_count: int


@dataclass
class Macro:
    name: str
    module: str
    test_cases: Optional[TestCase]=None

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
        return bool(re.search(executed_macro_pattern,model.read().replace('\n','')))

def get_all_tests()->Tuple[TestCase]:
    """gets all the tests, matching macro names, quality and counts.
    """
    
    def count_tests(model:dict )->Tuple[int,int]:
        tests = [test for column in model.get('columns', tuple() )
             for test in column.get('tests', tuple() ) ]
        return len(tests) , len([test for test in tests if str(test) == 'not_null' ]) 
    test_cases = list()
    test_root = '/app/models/schema_tests'
    for root, dir, filenames in os.walk(test_root):
        test_files = [os.path.join(root,filename) for filename in filenames
             if filename.endswith('.yml')]
    for test_file in test_files:
        with open(test_file) as f:
            schema = yaml.safe_load(f)
        for model in schema.get('models',tuple()):
            test_cases.append(TestCase(
                   model.get('name','')[: (-1 * len('_test'))],
                   *count_tests(model))) 
    return test_cases

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
        if  root + '/utilities' not in base:
            macro_files = [os.path.join(base,filename) for filename in files if filename.endswith('.sql')]
    
    macros = list()
    macro_regex=r'\{%-?\s*macro\s+\w*\(.*\)\s*-?%\}'
    for module in macro_files:        
        with open(module, 'r') as module_file:
            if "xdb: nocoverage" in module_file.readline():
                continue
            module_file.seek(0)
            matches = [re.search(macro_regex, line) for line in module_file]
            macro_signatures = [match.group() for match in matches if match]
        for signature in macro_signatures:
            macros.append(Macro(_extract_macro_name(signature),
                                module))
    return macros  

def build_coverage_matrix():
    results = list()
    macros = get_all_eligible_macros()
    tests = get_all_tests()
    for macro in macros:

        result = dict(results=dict())
        result['macro'] = macro.name
        result['is_private'] = macro.is_private
        result['results']['has_model'] = macro_has_matching_test_model(macro)
        result['model_path'] = macro.expected_model if result['results']['has_model'] else ''
        result['results']['called_in_model'] = result['results']['has_model'] and\
             macro_is_called_in_model(macro)
        result['results']['lint_casing'] = lint_macro_lowercase_name(macro)
        result['results']['test_count'] = 0
        result['results']['not_null_count'] = 0

        for test in tests:
            if test.name == macro.name:
                result['results']['test_count'] = test.test_count
                result['results']['not_null_count'] = test.not_null_count
        results.append(result)
    return results

def coverage_passes():
    public_macro_results = [macro for macro in build_coverage_matrix() if not macro['is_private'] ]
    failed_macros=list()
    for result in public_macro_results:
        if not all(list(result['results'].values())[:-1] ):
            failed_macros.append(result)
    if failed_macros:
        print("\nThe following macros failed:")
        for macro in failed_macros:
            red = '\033[0;31m'
            clear = '\033[0m'
            print(f"""{macro['macro']}:
   has a model:{red if not macro['results']['has_model'] else '' }{macro['results']['has_model']}{clear}
   macro called in model: {red if not macro['results']['called_in_model'] else '' }{macro['results']['called_in_model']}{clear}
   macro correctly titled: {red if not macro['results']['lint_casing'] else '' }{macro['results']['lint_casing']}{clear}
   total tests: {red if macro['results']['test_count'] == 0 else '' }{macro['results']['test_count']}{clear}
   not_null tests: { red if (macro['results']['test_count'] == macro['results']['not_null_count'])  else '' }{macro['results']['not_null_count']}{clear}   
""")
    else:
        print('\n\n\033[0;32mCoverage passed!\033[0m\n\n')
    return len(failed_macros)

if __name__ == '__main__':
    if '-v' in sys.argv:
        print(build_coverage_matrix())
    sys.exit(coverage_passes()) 
