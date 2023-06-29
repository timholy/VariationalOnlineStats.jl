# VariationalOnlineStats

[![CI](https://github.com/timholy/VariationalOnlineStats.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/timholy/VariationalOnlineStats.jl/actions/workflows/ci.yml)
[![codecov.io](http://codecov.io/github/timholy/VariationalOnlineStats.jl/coverage.svg?branch=master)](http://codecov.io/github/timholy/VariationalOnlineStats.jl?branch=master)

This package provides an online estimate (`O(1)` in storage and `O(N)` in operations) of the [median](https://en.wikipedia.org/wiki/Median).
You can also use it to extract a "typical" sample object.
It should be emphasized that the results are approximate and influenced by sample order, with the worst accuracy for sorted data.

## Estimating the median

```julia
julia> using Statistics, VariationalOnlineStats

julia> median(1:101)
51.0

julia> MedianOnline(1:101)            # 1:101 is sorted, a worst-case scenario
MedianOnline(med=34.683520091205864, mad=33.301973872578365, n=101)   # pretty far off (`med`=median, `mad`=Mean Absolute Deviation (MAD))

julia> using Random

julia> MedianOnline(randperm(101))    # the same data, but randomly ordered
MedianOnline(med=49.04313591042025, mad=26.084366886470903, n=101)    # reasonably close (within MAD/sqrt(n))
```

You can also compute incrementally:

```julia
julia> updater = MedianOnline(1)
MedianOnline(med=1.0, mad=0.0, n=1)

julia> for i = 2:101
           updater = median(updater, i)
       end

julia> updater
MedianOnline(med=34.683520091205864, mad=33.301973872578365, n=101)
```

Like the true `median`, `MedianOnline` is "reasonably" insensitive to the distribution tails:

```julia
julia> list = vcat(1:100, 10^6);  # add one large outlier

julia> mean(list)                 # the mean is heavily influenced by the outlier
9950.990099009901

julia> median(list)               # the median is insensitive to the value of the outlier (other than by its ordering)
51.0

julia> MedianOnline(list[randperm(101)])    # this is far closer to the result from `median` than `mean`
MedianOnline(med=80.0, mad=9926.359535890528, n=101)
```

## Extracting a 'typical' example item

Another application of the package is to identify an object which is "typical" according to some measure.
This works using a different type of `updater`, `MedianSampleOnline` ("extract a median sample").
For example, let's extract a single word that is of "typical" length:

```julia
julia> using Statistics, VariationalOnlineStats

julia> words = split("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum");

julia> w = first(words)
"Lorem"

julia> updater = MedianSampleOnline(length(w), w)  # first arg is the measurement used to assess "typical", second is the item
MedianSampleOnline(med=5.0, sample="Lorem")

julia> for w in Iterators.drop(words, 1)
           updater = median(updater, length(w), w)
       end

julia> updater
MedianSampleOnline(med=5.0132505326993195, sample="nulla")

julia> median(length.(words))
5.0
```

Unlike `MedianOnline`, the display of `MedianSampleOnline` omits a certain amount of internal data and cannot be reconstructed by copy/pasting the printed output.

## Extra details

For a much broader package (but which doesn't include the median), see [OnlineStats](https://github.com/joshday/OnlineStats.jl).


This package is registered in [HolyLabRegistry](https://github.com/HolyLab/HolyLabRegistry).
