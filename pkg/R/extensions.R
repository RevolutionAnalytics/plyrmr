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
		non.standard.args = TRUE, 
		add.envir.arg = non.standard.args, 
		envir = parent.frame(), 
		mergeable = FALSE, 
		vectorized = FALSE){
		f.name = as.character(substitute(f))
		f.data.frame = {
			if(is.generic(f))
				getMethodS3(f.name, "data.frame")
			else f}
		f.data.frame.eval.patch = {
			if(add.envir.arg)
				non.standard.eval.patch(f.data.frame)
			else
				f.data.frame}
		setMethodS3(
			f.name,
			"data.frame",
			f.data.frame.eval.patch,
			overwrite = FALSE,
			envir = envir)
		setMethodS3(
			f.name,
			"pipe", 
			if(non.standard.args)
				function(.data, ..., .envir = parent.frame()) {
					.envir = copy.env(.envir)
					curried.f = CurryHalfLazy(if(add.envir.arg) non.standard.eval.patch(f) else f, .envir = .envir)
					gapply(.data, vectorized(mergeable(curried.f, mergeable), vectorized), ...)}
			else
				function(.data, ...)
					do.call(gapply, c(list(.data, vectorized(mergeable(f, mergeable), vectorized)), list(...))),
			envir = envir)} 

extend = 
	function(pack = c("base", "dplyr"), envir = parent.frame()) {
		pack = match.arg(pack)
		switch(
			pack,
			base = {
				magic.wand(transform, non.standard.args = TRUE, envir = envir)
				magic.wand(subset, non.standard.args = TRUE, envir = envir)},
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



