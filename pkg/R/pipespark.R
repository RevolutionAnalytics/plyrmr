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
					x = safe.cbind.kv(k, v)
					rownames(x) = make.unique(cbind(rownames(v), 1:nrow(x))[,1])
					x}}}}

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

is.grouped = 
	function(.data) 
		has.property(.data, "grouped")

gather = 
	function(.data) 
		group(.data, .gather = 1)

output = 
	function(.data, path = NULL, format = "native", input.format = format) {
		stop('not implemented yet')}

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
