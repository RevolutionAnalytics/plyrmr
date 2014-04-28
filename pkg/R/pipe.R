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

# function manip
.options = new.env()
.options$context = sparkR.init()

set.context =
	function()
		.options$context = sparkR.init()


#pipes

print.pipe =
	function(x, ...) {
		print(as.data.frame(sample(x, method = "any", n = 100)))
		invisible(x)}

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

mergeable = 
	function(f, flag = TRUE) 
		structure(f, mergeable = flag)

vectorized = 
	function(f, flag = TRUE) 
		structure(f, vectorized = flag)

is.mergeable = 
	function(f) 
		default(attr(f, "mergeable", exact=TRUE), FALSE)

is.vectorized = 
	function(f) 
		default(attr(f, "vectorized", exact=TRUE), FALSE)

keycols = 
	function(kv)
		attributes(kv)[['keys']]

set.keycols = 
	function(kv, keycols) {
		attr(kv, 'keys') = keycols
		kv}

add.keycols = 
	function(kv, keycols) {
		attr(kv, 'keys') = union(keycols(kv), keycols)
		kv}

rm.keycols = 
	function(kv, keycols) {
		attr(kv, 'keys') = setdiff(keycols(kv), keycols)
		kv}

keys = function(kv) kv[, keycols(kv), drop = FALSE]
values = function(kv) kv[, setdiff(names(kv), keycols(kv))]

keyval = 
	function (key, val = NULL) {
		if (missing(val)) 
			keyval(key = NULL, val = key)
		else set.keycols(recycle.keyval(key, val), names(key))}

recycle.keyval = 
	function (k, v) {
		if(is.null(k))
			v
		else {
			if ((nrow(k) == nrow(v)) || is.null(k)) 
				cbind(k, v)
			else {
				if (nrow(v) == 0) 
					NULL
				else {
					as.data.frame(do.call(cbind, c(k, v)))}}}}

rdd.list2kv =
	function(ll) 
		do.call(
			rbind, 
			lapply(
				ll,
				function(l) {
					if(is.data.frame(l)) l 
					else {
						if(is.data.frame(l[[2]]))
							l[[2]]
						else
							do.call(rbind, l[[2]])}}))

kv2rdd.list = 
	function(kv) {
		k = keys(kv)
		if(ncol(k) == 0)
			list(kv)
		else
			mapply(
				function(x, y) list(k = x, v = y), 
				lapply(
					split(k, k, drop = TRUE), function(x) digest(unique(x))), 
				split(kv, k, drop = TRUE), 
				SIMPLIFY = FALSE)}


gapply = 
	function(.data, .f, ...) 
		as.pipe(
			lapplyPartition(
				rdd(.data), 
				function(x) {
					kv = rdd.list2kv(x)
					k = keys(kv)
					kv = make.f1(.f, ...)(kv)
					kv2rdd.list(safe.cbind.kv(k, kv))}))

group = 
	function(.data, ..., .envir = parent.frame()) {
		force(.envir)
		dot.args = dots(...)
		group.f(
			.data, 
			function(.y) 
				do.call(CurryHalfLazy(transmute, .envir = .envir), c(list(.y), dot.args)))}

group.f =
	function(.data, .f, ...) {
		f1 = make.f1(.f, ...)
		as.pipe(
			groupByKey(
				lapplyPartition(
					rdd(.data),
					function(x) {
						kv = rdd.list2kv(x)
						k = keys(kv)
						new.keys = f1(kv)
						kv2rdd.list(
							keyval(
								safe.cbind(k, new.keys), 
								safe.cbind(v, v[, setdiff(names(x), new.keys)])))}),
			10L))} #TODO: review constant here

ungroup = 
	function(.data, ...) {
		if(is.grouped(.data) && !is.null(.data$reduce)) {
			.data$ungroup = TRUE
			.data$ungroup.args = named_dots(...)
			phase1 = input(run(.data, input.format = "native"))
			if(length(.data$ungroup.args) == 0)
				phase1
			else 
				group.f(phase1, function(x) data.frame(.gather = 1))}
		else {
			if (is.grouped(.data)) {
				.data$group = NULL
				.data$ungroup = FALSE #what happens to ungroup.vars here
				.data}
			.data}}

gather = 
	function(.data) {
		if(is.grouped(.data)) 
			.data
		else {
			pipe = group(.data, .gather = 1)
			pipe$recursive.group = TRUE
			pipe}}

is.grouped = 
	function(.data)
		!is.null(.data[["group"]])

output = 
	function(.data, path = NULL, format = "native", input.format = format) {
		if(missing(input.format) && !is.character(format))
			stop("need to specify a custom input format for a custom output")
		.data[["output.format"]] = format
		.data[["output"]] = path
		as.big.data(.data, input.format)}


as.pipe = function(x, ...) UseMethod("as.pipe")

as.pipe.RDD = 
	function(x, ...) 
		structure(
			list(rdd = x),
			class = "pipe")

rdd = 
	function(x) 
		x[["rdd"]]

as.pipe.data.frame = 
	function(x, ...) 
		as.pipe(
			parallelize(
				.options$context, 
				kv2rdd.list(
					keyval(x))))


as.data.frame.pipe =
	function(x, ...)
		as.data.frame(
			SparkR::collect(rdd(x)))

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