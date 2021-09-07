# File:     swath_group_and_filter.R
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
# Installs misc. helpers
if (!require("stringr")) install.packages("stringr")

# Use pacman to load add-on packages as desired
pacman::p_load(pacman, rio) 

# import private source
source("src/csv_walk_config_tree.R")

# system configuration  ###############################################

input_dir                 = "group_and_filter_input_files"
output_dir                = "output_files"
yaml_config_file          = "group_and_filter.yaml"
csv_config_file           = "group_and_filter_config.csv"
output_file_prfx          = 'filtered_'
output_file_excluded_prfx = 'excluded_'


# setup helpers #######################################################
# clean exit TODO move to a helper.R
stop_quietly <- function() {
  opt <- options(show.error.messages = FALSE)
  on.exit(options(opt))
  stop()
}

# get input_dir files  ################################################
input_files <- list.files(input_dir, pattern='*.csv', 
                          all.files=FALSE, full.names=FALSE)
# see if our fevered config file type csv is present 
is_csv_config_file = (csv_config_file %in% input_files)
if(is_csv_config_file){
  input_files = input_files[!(input_files %in% csv_config_file)]} # tricky :)
if (is_csv_config_file){
  # get csv system configuration  ######################################
  csv_config_filepath <- paste(input_dir,"/", csv_config_file, sep="")
  raw_csv_config = import(csv_config_filepath)
  config_dict =walk_csv_config_tree(raw_csv_config)                                                                                                                                    
}else{
  # get yaml system configuration  #####################################
  yaml_config_filepath <- paste(input_dir,"/", yaml_config_file, sep="")
  config_dict <- read_yaml(yaml_config_filepath) 
}
print(paste('input_files', input_files)) 


# setup system from config_dict  ########################################
group_set_columns_cn <- length(config_dict$group_set_columns)
# print(config_dict)

# setup input data frame #######################################
# set up all pathfile names
# discover name of file and input directory

# make sure there's only one file in the input directory otherwise 
# abort execution
if (length(input_files) != 1){
  print("Only one file at a time or no file present at all")
  stop_quietly()}
# we are good to go only one file!

# setup input data_filepath
data_filepath <- paste(input_dir,"/", input_files, sep="")
# print(data_filepath)
# ###############################################################
# IMPORTING cal1 df_swath WITH RIO ##############################
cal1_swath_df <- import(data_filepath)
#head(cal1_swath_df)

# ###############################################################
# Cheek that config_dict$group_set_columns columns exist  
#  in cal1_swath_df
cheek_ok = TRUE
nams_cal1_swath = names(cal1_swath_df)
for(set in 1:group_set_columns_cn){
  group_set_columns_v = unlist(config_dict$group_set_columns[set])
  for( col in group_set_columns_v){
    if(! col %in% nams_cal1_swath){
      print(paste('group_set_column', col, 'not in',input_files))
      cheek_ok = FALSE
    }
  }
}
if(!cheek_ok) {cat('\n>>> cheek_ok =FALSE, stop\n'); stop_quietly()}

# ###############################################################
# step through and build vector of rows to be filter out ########
cal1_df_row_cn = nrow(cal1_swath_df)
row_exclusion_v = c()
row_exclusion_inx = 0
for( row in 1:cal1_df_row_cn ) { # 4){ #  
  #print(paste('row:',row))
  if( (!(row %in% config_dict$target_whitelist_row_num))){
    keep_row = TRUE
    for(set in 1:group_set_columns_cn){
      group_set_columns_v = unlist(config_dict$group_set_columns[set])
      not_na_data_cn = 0
      #print(paste('group_set_columns_v:',group_set_columns_v))
      for( col in group_set_columns_v){
       if(! is.na(cal1_swath_df[row, col])){
          #print(paste('col:',col, 'row:',row, 'cal1_swath_df[row, ]', cal1_swath_df[row, ]))
          not_na_data_cn = not_na_data_cn+1}# ! is.na(cal1_swath_df[row, col])
      }
  
      if( (not_na_data_cn < config_dict$rules$min_replicates) | ! keep_row) { 
        keep_row = FALSE
      }
     # print(paste('not_na_data_cn',not_na_data_cn,'keep_row',keep_row))
    }
    if(keep_row == FALSE) {
     # print(paste('keep_row:',keep_row, 'Though OUT row'))
      row_exclusion_inx = row_exclusion_inx + 1
      row_exclusion_v[row_exclusion_inx] = row}
  }
} 
#print(paste('length(row_exclusion_v)',  length(row_exclusion_v)))
#print(paste('row_exclusion_v', row_exclusion_v))

# ###############################################################
# Build output cal1_output_df ###################################
# initialize output cal1_output_df from fist 6 column of cal1_swath_df
cal1_output_df <- cal1_swath_df[1:6]
for(set in 1:group_set_columns_cn){
  set_name = names(config_dict$group_set_columns)[set]
  group_set_columns_v = unlist(config_dict$group_set_columns[set])
  for( col in group_set_columns_v){
    new_col_name = paste(set_name, '.', col, sep = '')
    cal1_output_df[[new_col_name]] <- cal1_swath_df[, col]
  }
}

# # delete rows not meeting requirement given in rule ############

cat('\n## output summary ## #############################################\n')
print(paste('size of the data set before filtration', nrow(cal1_output_df)))
cal1_filtered_df = cal1_output_df[-row_exclusion_v, ]
cal1_excluded_df = cal1_output_df[row_exclusion_v, ]
print(paste('size of database after filtration', nrow(cal1_filtered_df)))
print(paste('size of exclusion data set', nrow(cal1_excluded_df)))
# ##### output cal1_output_df as csv file ########################

# locale-specific version of date()
Sys.time()
time_stamp <- format(Sys.time(), "%y-%m-%d-%H-%M")
# setup output file name
output_file_filtered = paste(output_dir, "/", output_file_prfx, input_files, sep="")
output_file_excluded = paste(output_dir, "/", output_file_excluded_prfx, input_files, sep="")
cat('target location of output file:',output_file_filtered, '\n\n')
# export with RIO ################################################
export(cal1_filtered_df, output_file_filtered,)
export(cal1_excluded_df, output_file_excluded,)
