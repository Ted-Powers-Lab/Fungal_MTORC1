import sys
import os
import pathlib
import argparse
import glob
import csv
import subprocess

'''
PreProcessing.py

Purpose of this program is for running the HMMER suit of programs (specifically HMMSearch) on a wide variety of different
proteome sources while outputting results to appropriate results directories

This program takes in a hmm directory source and an overall proteome source directory and then recursively searches for appropriate files

This program was written by Sarah Huang with help from Kyle Johnson 2025



'''




#csv converter
def csv_converter(input_file, acc):
    final_list = []
    with open(input_file, mode='r') as f:
        reader = csv.reader(f, delimiter=' ', skipinitialspace=True)
        for row in reader:
            str_row = "".join(row)
            if str_row.startswith('#'):
                continue
            else:
                result_list = row[0:10]
                result_list.append(acc)
                final_list.append(result_list)

    return(final_list)







parser = argparse.ArgumentParser()
parser.add_argument("-hmm", help = "Put hmm directory path here")
parser.add_argument("-prot", help = "Put proteome directory path here")
args = parser.parse_args()

directory = args.hmm
directory2 = args.prot

contents = os.listdir(directory)

clades = ['Discoba', 'Metamonada', 'Stramenopiles', 'Alveolata', 'Rhizaria', 'Chlorophyta', 'Rhodophyta', 'Streptophyta',
          'Fungi', 'Metazoa']

#iterate hmm files
for hmm in pathlib.Path(directory).iterdir():
    if not hmm.is_file():
        continue
    else:
       hmmName = hmm.stem
       output_directory = f'Results/{hmmName}/'




#getting accession number and faa file from proteome
    for proteome in pathlib.Path(directory2).rglob('*.faa'):
        names = proteome.parts
        acc = proteome.parts
        substring = 'GC'
        acc = list(s for s in acc if substring in s)
        acc = ", ".join(acc)
        for item in clades:
            for element in names:
                if item == element:
                    cladeName = item
                else:
                    continue

        if not proteome.is_file():
            print("Item was not the appropriate file type")
            continue
        if proteome.suffix == ".faa":
            print("Item was a proper file and has the proper extension")
            command = ['hmmsearch', '--tblout', f"{output_directory}{cladeName}/{acc}_{hmmName}.out", str(hmm), str(proteome)]
            #check if directory exists
            if not os.path.exists(f'{output_directory}{cladeName}/'):
                print("Making a new directory")
                os.makedirs(f'{output_directory}{cladeName}/')
            else:
                print("No need for new directory")
            #make file inside output directory
            print("About to open a file and begin a hmmersearch")
            with open(f"{output_directory}{cladeName}/{acc}_{hmmName}.txt", 'w') as f:
                print("about to start hmmer")
                subprocess.run(command, stdout=f, text=True, check=True)

        else:
            continue

    for outfile in pathlib.Path(output_directory).rglob('*.out'):
        name = outfile.parts
        for item in name:
            for element in clades:
                if element == item:
                    additional_Name = element
                else:
                    continue

        acc_number = outfile.stem
        acc_number = "_".join(acc_number.split('_')[:2])
        file_name = outfile.stem
        final_directory = output_directory + '/' + additional_Name + '/' + file_name
        final_list = csv_converter(outfile, acc_number)

        #write csv file
        with open(f'{final_directory}.csv', mode='w') as new_csv:
            writer = csv.writer(new_csv)
            writer.writerow(
                ['tar', 'tar_acc', 'query', 'hmm_acc', 'full_e', 'full_score', 'full_bias', 'dom_e', 'dom_score',
                 'dom_bias', 'acc'])

            writer.writerows(final_list)









