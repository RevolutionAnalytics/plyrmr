# What's new in `plyrmr` 0.3.0

This is mostly a stability release and the main addition is behind the scenes, a set of unit tests that cover the most important functions in plyrmr. This is a more usable plyrmr and closer to a 1.0 release. But there are also some visible changes.

# Features

* partial `ungroup`: before it could only reset the current grouping and start from scratch. Now it can remove columns from the current grouping, or, otherwise stated, make the grouping coarser. For instance, `input(mtcars) %|% group(car, cyl) %|% ungroup(cyl)` is equivalent to `input(mtcars) %|% group(carb)`. 
* extension packs: version 0.2.0 cut down on API redundancy, but reduced user choice. So we brought back at least some of the most loved legacy functions like `transform` as extension packs. They are not part of "core plyrmr" but can be defined with `extend(pack)`, where `pack` is one of `base` (for `transform` and `subset`) or `dplyr` (for `mutate`, `summarize` or `filter`).
* `quantile.cols` returns exact results for smaller data sets (or large date sets that are grouped into smaller ones).
* `count.cols` doesn't drop numeric columns anymore 

# Bugs
* support for row names reinstated #36
* argument order in `top.k` and `bottom.k` corrected
* `top.k` and `bottom.k` don't reset grouping anymore
* handling of ungroup on ungrouped pipes
