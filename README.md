
##  SWATH-MS Total Protein Approach Calculator


Automates the time-consuming process of calculating label free protein concentration using the Total Protein Approach from SWATH-MS data.

## Description

This R script takes a SWATH-MS output .cvs file from Spectronaut (or equivalent software) and calculates the protein concentration (default pmol/mg protein) using the Total Protein Approach. 

* Protein concentration (pmol/mg protein) = (Total Intensity/(Total Protein Intensity * MW (g/mol)) * 10^9
* Note: 10^9 conversion factor can be changed

The data frame is formatted with proteins designated by rows and samples by columns. The current code will work with any number of target rows and column samples.

The current configuration expects the first column to be PG.MolecularWeight containing a list of molecular weights. The code is written to take the first MW value in the list and will then separate it into its own column. 

Samples are expected to start at the sixth column of the data frame. The format of each column sample name dictates that it should have a prefix of "[i]", where i is a non-critical label (i.e., number from 1 to the total number of samples, the same number repeated, or letter). The script identifies the column name as a sample from the "[ ]" characters.

The code proceeds to calculate sums of protein intensity for each sample column, ignoring non-numeric data. Where non-numeric data appears in the sample columns any text will be replaced with an NA and appear as a blank in the .csv output file.

The final result is a separate output .csv file with the title of [TPA-calc_{timestamp}_{input file name}] containing the original first five columns (as references) plus an additional column with a single molecular weight titled PG.first_Weight inserted in the second position.

The output Total Protein Approach calculations appear in the  sample columns beginning at the seventh position, which have the original name of the samples with the suffix of .calc1.

The calculations are delivered in the form of one sequential script swath_total_protein_approach_calc.R.

Only one step is required and that is to run the script once per calculation. 


## Getting Started

### Dependencies

* R Version 1.4.1103 or later
* Spectronaut (or equivalent software)
* Script known to run in MacOS, Ubuntu 18, and Windows 10

### Installing

1) Install R 1.4 or later (from r.project.org select "download R" and choose preferred CRAN mirror site to get software)
https://www.r-project.org/
2) Install RStudio Version 1.4.1 or later (optional, useful if code is to be modified)
https://www.rstudio.com/products/rstudio/download/
3) Install swath-total-protein-approach-calc project by Git clone of https://github.com/teresasierra/swath-total-protein-approach-calc.git
* Select Code
* Download Zip
* Extract Zip
* Store project in desired location

Done.

### Executing Program

1) Place one SWATH formatted .cvs file in the input_file directory found immediately under the main swath-total-protein-approach-calc project directory.
* You may only process one file at a time, the calculations will abort if there's more than one file present. Any file name name is acceptable, it will be detected and used as a base name.
* Template_File.csv is an example of how the data frame is to be set up. "PG.MolecularWeight" and "[ ]" are critical names for the script to identify the first molecular weight and samples, in column one and column six respectively.
2)  Run the sswath_total_protein_approach_calc.R script either in RStudio or at the command line, RStudio is recommended.
* Open RStudio
* Open Project: swath-total-protein-calc.Rproj
* Open File: swath_total_protein_approach_calc.R
* If you are not changing the conversion factor (10^9), highlight rows 1 to 168 of the script
* Select Run
* To clean up project, highlight rows 179 to 185 of the script and select Run

```
"C:\Program Files\R\R-4.1\bin\Rscript.exe" C:\Users\myusername\Documents\R\SWATHTotProteinCalc\swath_tot_protein_calc.R
```
* An example of command line syntax is given above, the specifics may vary based on R version and OS. 
3)  Output files will be found in the output_files directory. They have the effects of TPA-calc_ followed by timestamp and the original input file name and a copy of the original input file will end up in the raw_input_history directory. The original file will be deleted on the successful completion of the calculations.

## Authors

Contributors names and contact info:

* [Jay Venti](jayventi@gmail.com)  
* [Teresa Sierra](teresa_sierra@uri.edu)  

## License
This project is licensed under the GPL-2
* [GNU GENERAL PUBLIC LICENSE
Version 2](https://www.r-project.org/Licenses/GPL-2)

## Acknowledgments

[Dr. Akhlaghi Lab](https://web.uri.edu/pharmacy/research/akhlaghi/)
* Dr. Nick DaSilva
* Dr. Ben Barlock
* Dr. Rohitash Jamwal

[Bioinformatics (BPS542)](https://web.uri.edu/pharmacy/2013/08/16/bps542-bioinformatics-i/)
* Dr. Christopher Hemme
* Dr. Lenore Martin
* Hep4Life Team (Winifer Ali, Qiwen Chen, and Sabah Ummie)


