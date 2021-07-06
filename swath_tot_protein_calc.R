# File:     swath_tot_protein_calc.R
# Project:  URI SWATH Protein Calc ???
# For:      Protein Lab
# Authors:  Jay Venti, 20mtns.com, jayventi@gmail.com
#           Teresa Sierra, 
# Date:     2021-06-26
# License:  u Version 2, or Version 3

# INSTALL AND LOAD PACKAGES ################################
library(datasets)  # Load base packages manually

# Installs pacman ("package manager") if needed
if (!require("pacman")) install.packages("pacman")

# Use pacman to load add-on packages as desired
pacman::p_load(pacman, rio) 

# system configuration  #######################################

MOL_CONVERTION <- as.double(10^9) # MW (g/mol))*10^9

input_dir <- "input_file"
output_dir <- "output_files"
input_hist_dir <- "raw_input_history"
output_file_prfx <- "stp-calc_"
hist_file_prfx <- "raw_input_"


# Setup paths, file names ##################################
# setup time, clean exit

# clean exit
stop_quietly <- function() {
  opt <- options(show.error.messages = FALSE)
  on.exit(options(opt))
  stop()
}

## setup time for greater accuracy:
op <- options(digits.secs = 6)
Sys.time()
options(op)

# set up all fall pathfile names
# discover name of file and input directory
input_files <- list.files(input_dir, pattern=NULL, 
                          all.files=FALSE, full.names=FALSE)
# make sure there's only one file in the input directory otherwise 
# abort execution
if (length(input_files) > 1){
  print("Only one file at a time")
  stop_quietly}
# we are good to go only one file!

# setup input data_filepath
data_filepath <- paste(input_dir,"/", input_files, sep="")

# setup hist_file name with timestamp
# locale-specific version of date()
Sys.time()
time_stamp <- format(Sys.time(), "%y-%m-%d-%H-%M")
hist_file <- paste(input_hist_dir, "/", hist_file_prfx, 
                   time_stamp, "_",input_files, sep="")

# backup input file data_filepath to hist_file
file.copy(from=data_filepath, to=hist_file, overwrite = TRUE, 
          recursive = FALSE, copy.mode = TRUE)

# setup output flie name
output_file <- paste(output_dir, "/", output_file_prfx, 
                   time_stamp, "_",input_files, sep="")

# IMPORTING df_swath WITH RIO ##############################
df_swath <- import(data_filepath)
head(df_swath)

# Get all samples cols names indf_swath ####################
col_names <- colnames(df_swath)
pattern <- "\\["
samples_cols <- grep(pattern, col_names, value = TRUE)

# Get first PG.MolecularWeight from list ###################
# add the first weight value G.first_Weight as a new column 
# to df_swath
PG.MolecularWeight_slists <- df_swath$PG.MolecularWeight
# head(PG.MolecularWeight_slists)
# print(PG.MolecularWeight_slists[1])
split.PG <-unlist(strsplit(PG.MolecularWeight_slists, ";"))
# head(split.PG)

# set up blank holding vector
PG.first_Weight <- vector()
df_swath_row_cn <- nrow(df_swath)
# print(df_swath_row_cn)
# print(length(PG.MolecularWeight_slists))

# step through and grab each element in the list
for(x in 1:df_swath_row_cn){
  first_elem <- strsplit(PG.MolecularWeight_slists[x], ";")[[1]][1]
  # print(first_elem)
  PG.first_Weight[x] <- first_elem
}
df_swath$PG.first_Weight <- PG.first_Weight
# head(df_swath[1:3, c("PG.MolecularWeight","PG.first_Weight")])

# cal sums for samples cols ################################
# print(df_swath[samples_cols[[1]]][1:16,c(1)])
sumes.SWATH.samples <-c()
# step through and process each sample column
for( j in 1:length(samples_cols)){ # length(samples_cols
  sum <- 0
  #print(samples_cols[[j]])
  # step through and sum each real number in each row
  for(i in 1:df_swath_row_cn){
    svalue <- df_swath[samples_cols[[j]]][i,c(1)]
    #print(as.double(svalue))
    if (suppressWarnings(!is.na(as.double(svalue)))){
      sum = sum + as.double(svalue)
    }
  }
  # load each summit into the sumes vector
  sumes.SWATH.samples[samples_cols[[j]]] <- sum
}
# print(sumes.SWATH.samples)

# Build output df_SWATH_step1 ###############################
# initialize output df_SWATH_step1 from fist 6 column of df_swath
PG.first_Weight_inx <- grep("PG.first_Weight", colnames(df_swath))
df_SWATH_step1 <- df_swath[ c(1,PG.first_Weight_inx[[1]],2:5)]
# print (df_SWATH_step1[1:3,])


# Total protein intensity calculation function 
# (pmol/mg protein) = (Total Intensity/(Total Protein Sum*MW (g/mol))*10^9
cal1 <- function(Intensity, Sum, MolWeight) {
  #print(Intensity)
  if (suppressWarnings(!is.na(as.double(Intensity)))) 
    return(as.double(Intensity)/(Sum * as.double(MolWeight))* MOL_CONVERTION) 
  else 
    return(NA)}# NULL

# for testing fixed example of the function
# print(cal1("12468.06", 12468.06, 2429640))

# apply cal1 to each number value of intensity in the input df and 
#  store the results and the df
# for each sample
for( j in 1:length(samples_cols)){  
  new_col_name <- paste(samples_cols[[j]], ".cal1", sep = "")
  print(new_col_name)
  
  temp <- rep(NA, df_swath_row_cn)
  # print(sumes.SWATH.samples[[j]])
  initial  <- df_swath[samples_cols[[j]]]
  # print(initial[[1]][1:6])
  # for each row
  sum <- sumes.SWATH.samples[[j]]
  for (i in 1:df_swath_row_cn) { # df_swath_row_cn
    #print(initial[[1]][i])
    MW  <- df_SWATH_step1$PG.first_Weight[i]
    # print(MW)
    
    # apply the function and generate a temporary column
    temp[[i]] <- cal1(initial[[1]][i], sum, MW)
  } 
  # build up the output df one sample column at a time  
df_SWATH_step1[new_col_name] <-c(temp)
}

# export WITH RIO #######################################
export(df_SWATH_step1, output_file,)

# CLEAN UP ##############################################

# delete input file data_filepath
file.remove(data_filepath) 

# Clear environment
rm(list = ls()) 

# Clear packages
p_unload(all)  # Remove all add-ons

# Clear console
cat("\014")  # ctrl+L

# Clear mind :) (:
