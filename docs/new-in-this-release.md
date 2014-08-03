# What's new in `plyrmr` 0.4.0

## Features

* system of backends *a là* rmr2: use "local" for learning and debugging, no Hadoop needed; use "hadoop" for real work on a cluster; don't use "spark" yet as it's not ready for prime time, but we are working on it.
* system of options also inspired by rmr2: with `plyrmr.options` you can set the backend or any other option that's relevant to the current backend. Right now that just means that arguments other than `backend` will be forwarded to `rmr.options`, but in the future that will change (as the spark backend is independent of rmr2)
* Support for fast aggregation using vectorized operations and the `dplyr` extension.


## Bugs

* Requires `rmr2` 3.1.3 or higher to pick up some upstream fixes in factor handling.
