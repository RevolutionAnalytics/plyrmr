





# plyrmr

The goal of this package is to allow convenient processing on a Hadoop cluster of large data sets. It is based on `rmr2` but should be easier to use and more abstracted from the underlying mapreduce computational model. `plyrmr` provides

* Hadoop-capable versions of well known `data.frame` functions: `transform`, `subset`, `mutate`, `summarize`, `melt`, `dcast` and more from packages `base`, `plyr` and `reshape2`.
* New `data.frame` functions which are also Hadoop-capable that are more suitable for development than some of the above: `select` and `where`.
* Simple but powerful ways of converting any `data.frame` functions to Hadoop-capable ones: `do` and `magic.wand`.
* Simple but powerful ways of aggregating  data: `group.`, `group.f`, `group.together` and `ungroup`.
* All of the above can be combined by normal functional composition: *delayed evaluation* helps mitigating any performance penalty of doing so by minimizing the number of Hadoop jobs launched to evaluate an expression.

See the [tutorial](docs/tutorial.md) for a gentle introduction.



