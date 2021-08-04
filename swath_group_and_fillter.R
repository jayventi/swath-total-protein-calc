# File:     swath_group_and_fillter.R
# Project:  URI SWATH-MS Total Protein Approach Calculation
# For:      Dr. Akhlaghi Lab
# Authors:  Jay Venti, 20mtns.com, jayventi@gmail.com
#           Teresa Sierra, teresa_sierra@uri.edu
# Date:     2021-08--01
# License:  GNU Version 2

# ###############################################################
# INSTALL AND LOAD PACKAGES #####################################
library(datasets)  # Load base packages manually

# Installs pacman ("package manager") if needed
if (!require("pacman")) install.packages("pacman")
# Installs stringi ("Character String Processing Facilities") if needed
if (!require("stringi")) install.packages("stringi")
# Installs yaml ("Convert R Data to YAML and Back") if needed
if (!require("yaml")) install.packages("yaml")

# Use pacman to load add-on packages as desired
pacman::p_load(pacman, rio) 

# system configuration  ##########################################

input_dir <- "group_and_fillter_input_files"
output_dir <- "output_files"
config_file <- "group_and_fillter.yaml"
output_file_prfx <- 'filltered_'

# setup helpers ###############################################
# clean exit TODO move to a helper.R
stop_quietly <- function() {
  opt <- options(show.error.messages = FALSE)
  on.exit(options(opt))
  stop()
}

# get config parameters #######################################
config_filepath <- paste(input_dir,"/", config_file, sep="")
config_dict <- read_yaml(config_filepath) 
sample_sets_cn <- length(config_dict$sample_sets)
# setup input data frame #######################################
# set up all pathfile names
# discover name of file and input directory
input_files <- list.files(input_dir, pattern='*.csv', 
                          all.files=FALSE, full.names=FALSE)

# make sure there's only one file in the input directory otherwise 
# abort execution
if (length(input_files) != 1){
  print("Only one file at a time or no file present at all")
  stop_quietly}
# we are good to go only one file!

# setup input data_filepath
data_filepath <- paste(input_dir,"/", input_files, sep="")

# ###############################################################
# IMPORTING cal1 df_swath WITH RIO ##############################
cal1_swath_df <- import(data_filepath)

# ###############################################################
# step through and build vector of rows to be filter out ########
cal1_df_row_cn = nrow(cal1_swath_df)
row_exclusion_v = c()
row_exclusion_inx = 0
for( row in 1:cal1_df_row_cn  ){ # l cal1_df_row_cn
  #print(paste('\nrow:',row))
  keep_row = TRUE
  for(set in 1:sample_sets_cn){
    sample_sets_v = unlist(config_dict$sample_sets[set])
    not_na_data_cn = 0
    for( col in sample_sets_v){
      if(! is.na(cal1_swath_df[row, col])){not_na_data_cn = not_na_data_cn+1}
    }
    #print(paste('not_na_data_cn',not_na_data_cn,'keep_row',keep_row))
    if(  not_na_data_cn <  config_dict$rules) { keep_row = FALSE
    }
  }
  if(keep_row == FALSE) {
    row_exclusion_inx = row_exclusion_inx + 1
    row_exclusion_v[row_exclusion_inx] = row}
} 
#print(paste('length(row_exclusion_v)',  length(row_exclusion_v)))
#print(paste('row_exclusion_v', row_exclusion_v))

# ###############################################################
# Build output cal1_output_df ###################################
# initialize output cal1_output_df from fist 6 column of cal1_swath_df
cal1_output_df <- cal1_swath_df[1:6]
for(set in 1:sample_sets_cn){
  set_name = names(config_dict$sample_sets)[set]
  sample_sets_v = unlist(config_dict$sample_sets[set])
  for( col in sample_sets_v){
    new_col_name = paste(set_name, '.', col, sep = '')
    cal1_output_df[[new_col_name]] <- cal1_swath_df[, col]
  }
}

# # delete rows not meeting requirement given in rule ############
print(paste('nrow(cal1_output_df)', nrow(cal1_output_df)))
cal1_output_df = cal1_output_df[-row_exclusion_v, ]
print(paste('nrow(cal1_output_df)', nrow(cal1_output_df)))

# ##### output cal1_output_df as csv file ########################

# locale-specific version of date()
Sys.time()
time_stamp <- format(Sys.time(), "%y-%m-%d-%H-%M")
# setup output file name
output_file <- paste(output_dir, "/", output_file_prfx, input_files, sep="")

# export with RIO ################################################
export(cal1_output_df, output_file,)
