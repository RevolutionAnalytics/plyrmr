# Copyright 2013 Revolution Analytics
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

where = function(.data, ...) UseMethod("where")

setMethodS3(
	"where",
	"data.frame",
	function(.data, ..., envir = parent.frame()) {
		force(envir)
		cond = 
			non.standard.eval(
				.data, 
				..., 
				.named = FALSE, 
				.envir = .envir)
		.data[Reduce(`&`, cond), , drop = FALSE]})

#(function(){x = 5; where(mtcars, cyl>x)})()

select = function(.data, ..., .replace = TRUE) UseMethod("select")
setMethodS3(
	"select",
	"data.frame",
	function(.data, ..., .replace = TRUE, envir = parent.frame()) {
		force(envir)
		args = 
			non.standard.eval(
			.data, 
			...,
			.named = TRUE,
			.envir = .envir)
		newcols = splat(data.frame)(c(args, list(stringsAsFactors = FALSE)))
		if(.replace)  newcols
		else cbind(.data, newcols)})

#(function(){v = 5;  select(mtcars, cy32 = cyl^2, carb + 5)})()

suppressWarnings(
	setMethodS3(
		"sample",
		"data.frame",
		function(x, method = c("any", "Bernoulli"), ...) {
			switch(
				match.arg(method),
				any = head(x, list(...)[['n']]),
				Bernoulli = 
					x[runif(length(x)) < list(...)[["p"]],, drop = FALSE])}))
