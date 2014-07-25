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

backends = c("local", "hadoop", "spark")

all.backends = 
	function(block, skip = c()) {
		pf = parent.frame()
		block = substitute(block) 
		lapply(
			setdiff(backends, skip),
			function(be) {
			plyrmr.options(backend = be) 
			eval(block, envir = pf)})}

.options = new.env()
.options$backend = "hadoop"

plyrmr.options = 
	function(...) {
		retval = list()
		args = dots(...)
		unnamed.args = {
			if(is.null(names(args)))
				args
			else
				args[names(args) == ""]}
		if(is.element("backend", unnamed.args)) {
			retval = c(retval, .options$backend)
			args = setdiff(args, "backend")}
		if(is.element("backend", names(args))) {
			.options$backend = eval(args[["backend"]], envir = parent.frame())
			switch(
				.options$backend,
				local =  rmr.options(backend = "local"),
				hadoop = rmr.options(backend = "hadoop"),
				spark = {
					library(SparkR)
					warning("Spark backend only partially implemented")
					spark.options()})}
		if(.options$backend == "spark") {
			retval = c(retval, do.call(spark.options, args))}
		else 
			if(is.element(.options$backend, c("local", "hadoop")))
				retval = c(retval, do.call(rmr.options, lapply(args, eval, envir = parent.frame())))
	retval}


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

ungroup = 
	function(.data, ...)
		UseMethod("ungroup")

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

as.pipe = 
	function(x, ...) {
		if(plyrmr.options("backend")[[1]] == "spark")
			UseMethod("as.pipespark")
		else 
			UseMethod("as.pipermr")}

input = as.pipe

