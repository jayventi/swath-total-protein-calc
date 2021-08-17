# cvs config helpers ## main > walk_csv_config_tree ###################

# csv string handling and parsing functions
# TODO move all csv helper functions into a CSVWalkConfigTree()
is_comment_str =  function(x, com_chr='#') {
  x_trim = str_trim(x, "left")
  result = (str_sub(x_trim,1,1) == com_chr)
  return(result)
}

is_na_or_whitespace = function(x) {
  result = TRUE
  if(! is.na(x)){
    result = grepl("^\\s*$", x)
  }
  return(result)
}

is_key = function(x) {return(grepl("\\:$", x))}

get_key_nam = function(x, com_chr='\\:') {
  x_trim = str_trim(x, "left")
  com_chr_inx = gregexpr( x_trim, pattern = com_chr)
  return(str_sub(x_trim,1, com_chr_inx[[1]]-1))
}

is_v_comment_or_blank =  function(v, control='BOTH',com_chr='#') {
  first_non_empty_comm = FALSE
  first_non_blank_sene = FALSE
  for( element in 1:length(v)){
    if (! first_non_empty_comm & ! first_non_blank_sene){
      if (!is_na_or_whitespace(v[element])) { 
        first_non_blank_sene = TRUE
        if(is_comment_str(v[element], com_chr)){first_non_empty_comm = TRUE}
      }
    }
  } 
  if (control=='COMMENT'){result=first_non_empty_comm
  } else if (control=='BLANK'){result != first_non_blank_sene
  } else {result = (first_non_empty_comm | ! first_non_blank_sene)}
  return(result)
}

get_key_index = function(v) {
  key_inx = 0
  for(inx in 1:length(v) ){
    if (key_inx == 0){
      if (is_key(v[inx])){
        key_inx = inx
      }
    }
  }
  return(key_inx) 
}

get_list_from_row = function(row, key_inx) {
  result = list()
  key_nam = ''
  v_out = vector()
  key_nam = get_key_nam(row[key_inx])
  for(inx in (key_inx+1):length(row) ){    print( row[inx])
    if (! is_na_or_whitespace(row[inx])){
      if (!is.na(as.numeric(row[inx]))){
        v_out[inx-key_inx] = as.integer(row[inx])
      } else {
        v_out[inx-key_inx] = (row[inx])
      } 
    }
  }
  result[[key_nam]] = v_out
  return(result)
}

#  helper functions for walking the configuration tree 

set_n_leaf = function(n, working_str, leaf, line_list) {
  eval_str = paste('n',working_str,'[["',leaf,'"]] = unlist(line_list[[1]])',sep = "")
  eval(parse(text=eval_str))
  return(n)
}

set_n_parent = function(n, working_str,parent){
  eval_str = paste('n',working_str,'[["parent"]] = parent',sep = "")
  eval(parse(text=eval_str))
  return(n)  
}

get_n_parent = function(n, working_str){
  eval_str = paste('parent = n',working_str,'[["parent"]]',sep = "")
  eval(parse(text=eval_str))
  return(parent)  
}

# main walking function, walks the CSV file and builds a configuration list with the same 
#  hierarchical arrangement as the CSV following the CSV layout rules 
walk_csv_config_tree = function(raw_csv_config) {
  n = list()
  working = ''
  level = 0
  for (line_n in 1:nrow(raw_csv_config)){
    raw_line = raw_csv_config[line_n,]
    if (! is_v_comment_or_blank(raw_line)){ # skip comment_or_blank lines
      key_inx = get_key_index(raw_line)
      line_list = get_list_from_row(raw_line, key_inx)
      key_nam = get_key_nam(raw_line[key_inx])
      # cat('line_n:',line_n,'key_nam:',key_nam,'level:',level,'key_inx:',key_inx,'working:',working,'\n')
      if (key_inx > level ){ # go down a level
        level = level + 1
        if (length(line_list[[1]]) == 0){ # if not a leaf
          parent = working
          working = paste(working,'[["',key_nam,'"]]',sep = "") # setup new working
          n = set_n_parent(n, working, parent) # set parent = working
        }
      } else if (key_inx < level){ # go up a level
        level = level - 1
        #cat('<go up a level>','key_nam',key_nam,'\n')
        working = get_n_parent(config, working)
        if (length(line_list[[1]]) == 0){ # if not a leaf
          working = paste(working,'[["',key_nam,'"]]',sep = "") # setup new working
        }
      }
      if (length(line_list[[1]]) > 0) { # at a leaf node process the leaf
        n = set_n_leaf(n, working, key_nam, line_list)
      }
    }
  }
  return(n)
}

# config = list()
# config = walk_csv_config_tree(raw_csv_config)