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

.spark.options = new.env()

spark.options =
	function(...) {
		args = dots(...)
		unnamed.args = {
			if(is.null(names(args)))
				args
			else
				args[names(args) == ""]}
		named.args = args[names(args) != ""]
		retval = list()
		if("context" %in% unnamed.args)
			retval = c(retval, .spark.options$context)
		if("context" %in% names(named.args)) 
			if (is.null(.spark.options$context)) {
				if(is.null(named.args$context))
					.spark.options$context = sparkR.init()
				else 
					.spark.options$context = named.args$context}
	retval}

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

keys.spark = function(kv) kv[, keycols(kv), drop = FALSE]
values.spark = function(kv) kv[, setdiff(names(kv), keycols(kv)), drop = FALSE]

keyval.spark = 
	function (key, val = NULL) {
		if (missing(val)) 
			keyval.spark(key = NULL, val = key)
		else set.keycols(recycle.keyval.spark(key, val), names(key))}

recycle.keyval.spark = 
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
		k = keys.spark(kv)
		if(ncol(k) == 0)
			list(kv)
		else
			mapply(
				function(x, y) list(k = x, v = y), 
				lapply(
					unname(split(k, k, drop = TRUE)), 
					function(x) {
						x = unique(x)
						attributes(x) = NULL
						digest(x)}), 
				unname(split(kv, k, drop = TRUE)), 
				SIMPLIFY = FALSE)}

# core pipes, apply functions and grouping

include.packages =
	function(which = names(sessionInfo()$other))
		sapply(which, Curry(includePackage, sc = .spark.options$context))

drop.gather.spark = 
	function(x) {
		if(is.element(".gather", names(x)))
			rm.keycols(select(x, -.gather), ".gather")
		else x }

gapply.pipespark = 
	function(.data, .f, ...) {
		f1 = make.f1(.f, ...)
		include.packages()
		f.reduce = 
			function(x, y) 
				f(list(x,y))[[1]][[2]]
		f = 
			function(part) {
				if(length(part) == 0)				
					NULL
				else {
					kv = rdd.list2kv(part)
					k = keys.spark(kv)
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
											unique(keys.spark(x)), 
											f1(drop.gather.spark(x))))))}}
		rdd = as.RDD(.data)
		as.pipespark(
			if(is.grouped(.data)) {
				if(is.mergeable(.f))
					reduceByKey(rdd, f.reduce, 10L)
				else
					lapplyPartition(groupByKey(rdd, 10L), f)}
			else
				lapplyPartition(rdd, f),
			grouped = is.grouped(.data))}

group.f.pipespark =
	function(.data, .f, ...) {
		include.packages()
		f1 = make.f1(.f, ...)
		as.pipespark(
			lapplyPartition(
				as.RDD(.data),
				function(part) {
					kv = rdd.list2kv(part)
					k = keys.spark(kv)
					new.keys = f1(kv)
					kv2rdd.list(
						keyval.spark(
							safe.cbind(k, new.keys), 
							safe.cbind(new.keys, kv)))}),
			grouped = TRUE)} 

ungroup.pipespark = 
	function(.data, ...) {
		include.packages()
		ungroup.args = dots(...)
		reset.grouping = length(ungroup.args) == 0
		as.pipespark(	
			lapplyPartition(
				as.RDD(.data),
				function(part) {
					kv  = rdd.list2kv(part)
					k = keys.spark(kv)
					kv2rdd.list(
						keyval.spark(
							if(reset.grouping)
								NULL
							else
								k[, setdiff(names(k), as.character(ungroup.args)), drop = FALSE], 
							kv))}),
			grouped = !reset.grouping)} #TODO: review constant here						

is.grouped.pipespark = 
	function(.data) 
		has.property(.data, "grouped")

gather.pipespark = 
	function(.data) 
		group(.data, .gather = 1)

available.spark.formats = 
	function()
		c("R.serialize", "csv", "json")

output.pipespark = 
	function(.data, path, format = available.spark.formats(), ...) {
		format = match.arg(format)
		if(format == "R.serialize")
			saveAsObjectFile(as.RDD(.data), path)
		else
			saveAsTextFile(
				lapplyPartition(
					as.RDD(.data), 
					function(xx) {
						kv = rdd.list2kv(xx)
						if(format == "csv"){
							write.table(kv, textConnection("tcout", "w"), ...)
							paste(tcout, collapse = "\n")}
						else
							toJSON(kv)}),
					path)
		path}

as.RDD = function(x,...) UseMethod("as.RDD")

as.pipespark = 
	function(x, ...)
		UseMethod("as.pipespark")

as.pipespark.RDD = 
	function(x, ...) 
		structure(
			list(rdd = x),
			class = c("pipespark", "pipe"),
			...)

as.RDD.pipespark= 
	function(x, ...) 
		x[["rdd"]]

as.pipespark.data.frame = 
	function(x, ...)
		as.pipespark(as.RDD(x))

as.data.frame.pipespark =
	function(x, ...)
		as.data.frame(as.RDD(x), ...)

as.data.frame.RDD = 
	function(x, ...)
		drop.gather.spark(rdd.list2kv(SparkR::collect(x)))

as.RDD.data.frame = 
	function(x, ...) 
		parallelize(
			.spark.options$context, 
			kv2rdd.list(
				keyval.spark(x)))

as.pipespark.character =
	function(x, format = available.spark.formats(), ...) {
		format = match.arg(format)
		as.pipespark(
			if(format == "R.serialize")
				objectFile(.spark.options$context, x)
			else
				lapplyPartition(
					textFile(.spark.options$context, x),
					function(x) {
						if(format == "csv")
							list(read.table(textConnection(unlist(x)), ...))
						else
							list(as.data.frame(fromJSON(unlist(x))))}))}

col.select = 
	function(x, cols) {
		if(is.null(cols)) x
		else x[, cols, drop = FALSE]}

merge.helper.pipespark = 
	function(x,	y,	by.x,	by.y, outer, reduce) {
		as.pipe(
			SparkR::lapply(
				join(
					as.RDD(group.f(x, Curry(col.select, cols = by.x))),
					as.RDD(group.f(y, Curry(col.select, cols = by.y))),
					4L),
				function(x)
					reduce(NULL, x[[2]][[1]], x[[2]][[2]])))}

rbind.pipespark = function(...) {
	args = list(...)
	as.pipe(
		unionRDD(
			as.RDD(args[[1]]), 
			if(length(args) <=2)
				as.RDD(args[[2]])
			else
				as.RDD(rbind(args[-1]))))}
