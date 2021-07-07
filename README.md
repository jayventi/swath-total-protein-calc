
##  SWATH Total Protein Approach Calculator



  Automates the time-consuming process of calculating Total protein intensity for SWATH samples.

## Description

This our calculation engine takes a cvs input file in the SWATH format and calculates the total protein intensity. the data is formatted with targets on rows and samples in the columns. The current configuration expects the first column to be PG.MolecularWeight containing a list of molecular weights, this code is designed to only work with the first element in the list. It starts by separating the first molecular weight element into its own column. samples are expected to start after the fifth column having a format where each column samples name has a prefix of "[i]" where i is a label that runs from 1 to the total number of samples. The current code will work with any number of column samples, and any number of row targets. the could proceeds to calculate sums for each sample ignoring non-numeric data. It then calculates total protein intensity as follows.

(pmol/mg protein) = (Total Intensity/(Total Protein Sum*MW (g/mol))*10^9

Where non-numeric data appears in the sample columns any text will be replaced with a R NA, and will appear as a blank in the csv output.

The final result is a separate csv with the title of [stp-calc_{timestamp}_{input file name}] containing the original first five columns plus a column with a single molecular weight appearing in the second position titled PG.first_Weight, following by the remaining 2:5 original columns these are added to the output as reference. The output calculations appear in the following sample calculation columns which have the original name of the samples with the suffix of .cal1. 
The calculations are delivered in the form of one sequential script swath_tot_protein_calc.R only one step is required and that is to run the script once per calculation. 


## Getting Started

### Dependencies

* R Version 1.4.1103 or later
* known to run in Windows 10 and Ubuntu 18

### Installing

* 1) Install R 1.4 or later
* 2) Install RStudio Version 1.4.1 or later ( optional, useful if code is to modified)
* 3) Install swath-total-protein-calc project by Git clone of https://github.com/teresasierra/swath-total-protein-calc

Done that's all that's required you should now have a main directory SWATHTotProteinCalc where you intended to place it.

### Executing program

* 1) Place one SWATH formatted cvs file in the input_file directory found immediately under the main SWATHTotProteinCalc project directory. you may only process one file at a time, the calculations will abort if there's more than one file present. Any file name name is acceptable, it will be detected and used as a base name and following steps.
* 2)  Run the swath_tot_protein_calc.R script either in RStudio or at the command line, RStudio is recommended. An example of command line syntax is given below the specifics may vary based on R version and OS. 
```
"C:\Program Files\R\R-4.1\bin\Rscript.exe" C:\Users\myusername\Documents\R\SWATHTotProteinCalc\swath_tot_protein_calc.R
```
* 3)  Output files will be found in the output_files directory, They have the effects of stp-calc_ followed by timestamp and the original input file stain, a copy of the original input file will end up in the raw_input_history directory. The original file will be deleted on the successful completion of the calculations.

## Authors

Contributors names and contact info

ex. [Jay Venti](jayventi@gmail.com)  
ex. [@DomPizzie](https://twitter.com/dompizzie

## License
This project is licensed under the GPL-2, [GNU GENERAL PUBLIC LICENSE
Version 2](https://www.r-project.org/Licenses/GPL-2)

## Acknowledgments

Inspiration, code snippets, etc.
* [awesome-readme](https://github.com/matiassingers/awesome-readme)
* [PurpleBooth](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2)
* [dbader](https://github.com/dbader/readme-template)
* [zenorocha](https://gist.github.com/zenorocha/4526327)
* [fvcproductions](https://gist.github.com/fvcproductions/1bfc2d4aecb01a834b46)


