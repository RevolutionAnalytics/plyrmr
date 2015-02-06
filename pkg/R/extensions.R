# Copyright 2014 Revolution Analytics
#    
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

is.generic = 
	function(f) 
		length(methods(f)) > 0

magic.wand = 
	function(
		f, 
		non.standard.args = FALSE, 
		envir = parent.frame(), 
		mergeable = FALSE, 
		vectorized = FALSE){
		f.name = as.character(substitute(f))
		f.data.frame = {
			if(is.generic(f))
				getMethodS3(f.name, "data.frame")
			else f}
		if(is.primitive(f)) stop ("Can't do  magic on primitive functions yet")
		setMethodS3(
			f.name,
			"data.frame",
			f.data.frame,
			overwrite = FALSE,
			envir = envir,
			appendVarArgs = FALSE)
		setMethodS3(
			f.name,
			"pipe", 
			if(non.standard.args) {
				f_ = match.fun(paste0(f.name, "_"))
				function(.data, ...) 
					do.call(gapply, c(list(.data, vectorized(mergeable(f_, mergeable), vectorized)), lazy_dots(...)))}
			else
				function(.data, ...)
					do.call(gapply, c(list(.data, vectorized(mergeable(f, mergeable), vectorized)), list(...))),
			envir = envir,
			appendVarArgs = FALSE)} 

extend = 
	function(pack = c("dplyr"), envir = parent.frame()) {
		pack = match.arg(pack)
		switch(
			pack,
			dplyr = {
				magic.wand(filter, non.standard.args = TRUE, envir = envir, vectorized = TRUE)
				magic.wand(mutate, non.standard.args = TRUE, envir = envir, vectorized = TRUE)
				magic.wand(summarize, non.standard.args = TRUE, envir = envir, vectorized = TRUE)
				magic.wand(summarise, non.standard.args = TRUE, envir = envir, vectorized = TRUE)				
				assign("summarize_mergeable", dplyr::summarise, envir = envir)
				assign("summarise_mergeable", dplyr::summarise, envir = envir)
				magic.wand(
					summarize_mergeable, 
					non.standard.args = TRUE, 
					envir = envir, 
					vectorized = TRUE, 
					mergeable = TRUE)
				magic.wand(
					summarise_mergeable, 
					non.standard.args = TRUE, 
					envir = envir, 
					vectorized = TRUE, 
					mergeable = TRUE)})}



