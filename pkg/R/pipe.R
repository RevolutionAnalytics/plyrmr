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

#options

.options = new.env()
.options$context = NULL

set.context =
	function(sc = sparkR.init())
		.options$context = sc

#function manip

make.f1 = 
	function(f, ...) {
		dot.args = dots(...)
		function(.x) {
			.y = do.call(f, c(list(.x), dot.args))
			if(is.data.frame(.y))
				.y else {
					if(is.matrix(.y))
						as.data.frame(.y, stringsAsFactors = F)
					else 
						data.frame(x = .y, stringsAsFactors = F)}}}

#pipe defs

print.pipe =
	function(x, ...) {
		print(as.data.frame(sample(x, method = "any", n = 100)))
		invisible(x)}

mergeable = 
	function(f, flag = TRUE) 
		structure(f, mergeable = flag)

vectorized = 
	function(f, flag = TRUE) 
		structure(f, vectorized = flag)

has.property = function (x, name)
	default(attr(x, name, exact = TRUE), FALSE)

is.mergeable = 
	function(f) 
		has.property(f, "mergeable")

is.vectorized = 
	function(f) 
		has.property(f, "vectorized")


gapply = 
	function(.data, .f, ...)
		UseMethod("gapply")

group.f =
	function(.data, .f, ...)
		UseMethod("group.f")

gather =
	function(.data)
		UseMethod("gather")

is.grouped = 
	function(.data)
		UseMethod("is.grouped")
	
output = 
	function(.data, path = NULL, format = "native", input.format = format) 
		UseMethod("output")

group = 
	function(.data, ..., .envir = parent.frame()) {
		force(.envir)
		dot.args = dots(...)
		group.f(
			.data, 
			function(.y) 
				do.call(CurryHalfLazy(transmute, .envir = .envir), c(list(.y), dot.args)))}

as.pipe = function(x, ...) UseMethod("as.pipe")

input = as.pipe

is.generic = 
	function(f) 
		length(methods(f)) > 0

magic.wand = 
	function(f, non.standard.args = TRUE, add.envir.arg = non.standard.args, envir = parent.frame(), mergeable = FALSE, ...){
		suppressPackageStartupMessages(library(R.methodsS3))
		f.name = as.character(substitute(f))
		f.data.frame = {
			if(is.generic(f))
				getMethodS3(f.name, "data.frame")
			else f}
		g = {
			if(add.envir.arg)
				non.standard.eval.patch(f.data.frame)
			else
				f.data.frame}
		setMethodS3(
			f.name,
			"data.frame",
			g,
			overwrite = FALSE,
			envir = envir)
		setMethodS3(
			f.name,
			"pipe", 
			if(non.standard.args)
				function(.data, ..., .envir = parent.frame()) {
					.envir = copy.env(.envir)
					curried.g = CurryHalfLazy(g, .envir = .envir)
					gapply(.data, mergeable(curried.g, mergeable), ...)}
			else
				function(.data, ...)
					do.call(gapply, c(list(.data, mergeable(g, mergeable)), list(...))),
			envir = envir)} 