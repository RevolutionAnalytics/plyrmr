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
.options$context = sparkR.init()

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

is.grouped = 
	function(.data) 
		has.property(.data, "grouped")

# this is a new keyval light, breaking deps with rmr2 and using a different representation

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
				safe.cbind.kv(k, v)
			else {
				if (nrow(v) == 0) 
					NULL
				else {
					safe.cbind(
						as.data.frame(
							do.call(cbind, c(k, v))))}}}}

# conversion from and to rdd list representation (row first)

rdd.list2kv =
	function(ll) 
		do.call(
			rbind, 
			unname(
				lapply(
					ll,
					function(l) {
						if(is.data.frame(l)) l 
						else {
							if(is.data.frame(l[[2]]))
								l[[2]]
							else
								do.call(rbind, l[[2]])}})))

kv2rdd.list = 
	function(kv) {
		k = keys(kv)
		if(ncol(k) == 0)
			list(kv)
		else
			mapply(
				function(x, y) list(k = x, v = y), 
				lapply(
					unname(split(k, k, drop = TRUE)), 
					function(x) {
						row.names(x) = NULL
						digest(unique(x))}), 
				unname(split(kv, k, drop = TRUE)), 
				SIMPLIFY = FALSE)}

# core pipes, apply functions and grouping

include.packages =
	function(which = names(sessionInfo()$other))
		sapply(which, Curry(includePackage, sc = .options$context))

drop.gather = 
	function(x) {
		if(is.element(".gather", names(x)))
			rm.keycols(select(x, -.gather), ".gather")
		else x }

gapply = 
	function(.data, .f, ...) {
		include.packages()
		f = 
			function(part) {
				kv = rdd.list2kv(part)
				k = keys(kv)
				f1 = make.f1(.f, ...)
				kv2rdd.list(
					if(ncol(k) == 0)
						f1(kv)
					else
						do.call(
							rbind, 
							lapply(
								unname(split(kv, k, drop = TRUE)), 
								function(x) 
									safe.cbind.kv(
										unique(keys(x)), 
										f1(drop.gather(x))))))}
		rdd = as.RDD(.data)
		as.pipe(
			if(is.grouped(.data)) {
				if(is.mergeable(.f))
					lapplyPartition(reduceByKey(rdd, f, 10L), f)
				else
					lapplyPartition(groupByKey(rdd, 10L), f)}
			else
				lapplyPartition(rdd, f),
			grouped = is.grouped(.data))}

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
		include.packages()
		f1 = make.f1(.f, ...)
		as.pipe(
			lapplyPartition(
				as.RDD(.data),
				function(part) {
					kv = rdd.list2kv(part)
					k = keys(kv)
					new.keys = f1(kv)
					kv2rdd.list(
						keyval(
							safe.cbind(k, new.keys), 
							safe.cbind(new.keys, kv)))}),
			grouped = TRUE)} 

ungroup = 
	function(.data, ...) {
		include.packages()
		ungroup.args = dots(...)
		reset.grouping = length(ungroup.args) == 0
		as.pipe(	
			lapplyPartition(
				as.RDD(.data),
				function(part) {
					kv  = rdd.list2kv(part)
					k = keys(kv)
					kv2rdd.list(
						keyval(
							if(reset.grouping)
								NULL
							else
								k[, setdiff(names(k), as.character(ungroup.args)), drop = FALSE], 
							kv))}),
			grouped = !reset.grouping)} #TODO: review constant here						

gather = 
	function(.data) 
			group(.data, .gather = 1)

output = 
	function(.data, path = NULL, format = "native", input.format = format) {
		stop('not implemented yet')}

as.pipe = function(x, ...) UseMethod("as.pipe")
as.RDD = function(x,...) UseMethod("as.RDD")

as.pipe.RDD = 
	function(x, ...) 
		structure(
			list(rdd = x),
			class = "pipe",
			...)

as.RDD.pipe= 
	function(x, ...) 
		x[["rdd"]]

as.pipe.data.frame = 
	function(x, ...)
		as.pipe(as.RDD(x))

as.data.frame.pipe =
	function(x, ...)
		as.data.frame(as.RDD(x), ...)

as.data.frame.RDD = 
	function(x, ...)
		drop.gather(rdd.list2kv(SparkR::collect(x)))

as.RDD.data.frame = 
	function(x, ...) 
		parallelize(
			.options$context, 
			kv2rdd.list(
				keyval(x)))

as.pipe.character =
	function(x, ...)
		as.pipe(
		lapplyPartition(
			textFile(.options$context, x, minSplits = NULL),
			function(x)
				list(read.table(textConnection(unlist(x)), header= FALSE, ...))))

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