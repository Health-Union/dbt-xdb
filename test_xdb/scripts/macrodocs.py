import re
import os
import sys


def macrodocs(macros_folder, docs_file, header_text, prefix=None):
    prefix = prefix + '.' if prefix else ''
    print('building docs...')
    macros = []
    macro_start = re.compile(r'{%(-)?\s+macro .+\s+(-)?%}')
    comments_start = re.compile(r'^\s*{#.*')
    comments_end = re.compile(r'.*#}')
    args_start = re.compile(r'(?i)^\s*ARGS:\s*$')
    return_start = re.compile(r'(?i)^\s*RETURNS:')
    support_start = re.compile(r'(?i)^\s*SUPPORTS:')
    macro_end = re.compile(r'{%(-)?\s+endmacro\s+(-)?%}')
    for root, dirs, files in os.walk(macros_folder):
        for name in filter(lambda x: x.endswith('.sql'), files):
            print(f'Found macro {os.path.join(root,name)}.')
            with open(os.path.join(root,name)) as f:
                in_macro=False
                macro=list()
                for line in f.readlines():
                    in_macro = True if re.match(macro_start,line) else in_macro
                    if in_macro:
                        macro.append(line)
                    if re.match(macro_end,line):
                        in_macro=False
                        macros.append((macro,os.path.join('../macros',name),))
                        macro=list()    
    
    if len(macros) > 0:
        macros.sort(key=lambda tup : tup[0])
        with open(docs_file,'w') as f:
            f.write(header_text)

    

    for macro, filepath in macros:
        try:
            declaration=macro[0][macro[0].index('{%')+2:macro[0].index('%}')].replace('-','').replace('macro','').strip()
            dec_name = declaration[:declaration.index('(')]
            dec_args = declaration.replace(dec_name,'').replace(')','').replace('(','').replace(' ','').split(',')
            dec_args = map(lambda x : x.split('=')[0], dec_args)
            description,returns = '',''
            args=list()    
            arg_types = dict()
            supports = list()
            in_docs,in_description,in_args,in_return,in_support = False,False,False,False,False
            for line in macro[1:-1]:
                if re.match(comments_start,line):
                    in_docs, in_description = True,True

                if re.match(return_start,line):
                    in_return,in_args,in_description,in_support = True,False,False,False
                if re.match(args_start,line):
                    in_return,in_args,in_description,in_support = False,True,False,False
                if re.match(support_start,line):
                    in_return,in_args,in_description,in_support = False,False,False,True

                if in_description:
                    description += line.replace('{#','').replace('#}','').replace('/*','').replace('*/','')

                if in_args:
                    if 'ARGS:' not in line.upper():
                        if line.count('-') > 0:
                            types=line[line.index('(')+1 : line.index(')')]
                            key=line[line.index('-')+1:line.index('(')].strip()
                            arg_types[key]=types
                        args.append(line.strip())
                
                if in_return:
                    returns += line.replace('RETURNS:','').replace('returns:','').replace('{#','').replace('#}','')

                if in_support:
                    support_line = line.replace('{#','').replace('#}','').strip()
                    if 'SUPPORTS:' not in support_line.upper() and support_line.count('-') > 0:
                        val=support_line[support_line.index('-')+1:].strip()
                        supports.append(val)

                if re.match(comments_end,line):
                    break

            with open(docs_file,'a') as md:
                md.write(f'\n### [{dec_name}]({filepath})')
                md.write(f'\n**{prefix + dec_name}** (')
                arg_string =''
                for arg in dec_args:
                    arg_string +=f'**{arg}** _{arg_types.get(arg)}_, '
                md.write(f'{arg_string[:-2]})\n')    
                md.write('\n'+description.strip() +'\n')
                for arg in args:
                    if arg.count('-') > 0:
                        name = arg[arg.index('- ')+1 : arg.index('(')].strip()
                        desc = arg[arg.index(')')+1:].strip()
                        md.write(f'\n- {name} {desc}')
                    else:
                        md.write(f'\n  - {arg}')
                md.write(f'\n\n**Returns**: {returns}')
                md.write(f'\n##### Supports: _{", ".join(supports)}_')
                md.write('\n----')
        except:
            print(f'Failed to build docs for {dec_name} in {filepath}')
            print(f'Line: {line}')
            raise
    print('docs built.')
            
            
if __name__ == '__main__':
    macrodocs(*sys.argv[1:])
