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
                        macros.append((macro,os.path.join('macros',name),))
                        macro=list()
        
    if len(macros) > 0:
        with open(docs_file,'w') as f:
            f.write(header_text)

    for macro, filepath in macros:
        declaration=macro[0][macro[0].index('{%')+2:macro[0].index('%}')].replace('-','').replace('macro','').strip()
        dec_name = declaration[:declaration.index('(')]
        dec_args = declaration.replace(dec_name,'').replace(')','').replace('(','').replace(' ','').split(',')
        dec_args = map(lambda x : x.split('=')[0], dec_args)
        description,returns = '',''
        args=list()    
        arg_types = dict()
        in_docs,in_description,in_args,in_return= False,False,False,False
        for line in macro[1:-1]:
            if re.match(comments_start,line):
                in_docs, in_description = True,True

            if re.match(return_start,line):
                in_return,in_args,in_description = True,False,False
            if re.match(args_start,line):
                in_return,in_args,in_description = False,True,False
               

            if in_description:
                description += line.replace('{#','').replace('#}','')

            if in_args:
                if 'ARGS:' not in line.upper():
                    types=line[line.index('(')+1 : line.index(')')]
                    key=line[line.index('-')+1:line.index('(')].strip()
                    arg_types[key]=types
                    args.append(line)
            
            if in_return:
                returns += line.replace('RETURNS:','').replace('returns:','').replace('{#','').replace('#}','')

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
                name = arg[arg.index('- ')+1 : arg.index('(')].strip()
                desc = arg[arg.index(')')+1:].strip()
                md.write(f'\n- {name} {desc}')
            md.write(f'\n\n**Returns**: {returns}')
    print('docs built.')
            
            
if __name__ == '__main__':
    macrodocs(*sys.argv[1:])
