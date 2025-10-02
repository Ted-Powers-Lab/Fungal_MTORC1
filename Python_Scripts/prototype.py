import subprocess
from pathlib import Path

#directory = Path('/quobyte/ikorfgrp/project/torture/Fungal_Search/Proteomes')
directory = Path('/quobyte/ikorfgrp/project/torture/Test_Ground/Andreana_Test_Ground/ncbi_dataset/ncbi_dataset/'
                 'data')
outputDirectory = '/quobyte/ikorfgrp/project/torture/Test_Ground/Andreana_Test_Ground/'

#Recursively search directory for fasta files and run Busco on them
def processFasta(p):
    for fastaFile in p.rglob('*.fa*'):
        #Get accession number
        acc = fastaFile.parts
        substring = 'GC'
        acc = list(s for s in acc if substring in s)
        acc = ", ".join(acc)
        #Run Busco
        command = ['busco', f'-i {fastaFile}', '-o  Busco_Results', '-m proteins',
                   f'--out_path {outputDirectory}']
        subprocess.run(command)

processFasta(directory)