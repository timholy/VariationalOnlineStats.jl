# VariationalOnlineStats

[![codecov.io](http://codecov.io/github/timholy/VariationalOnlineStats.jl/coverage.svg?branch=master)](http://codecov.io/github/timholy/VariationalOnlineStats.jl?branch=master)

This package provides an online estimate (`O(1)` in storage and `O(N)` in operations) of the [median](https://en.wikipedia.org/wiki/Median).
It should be emphasized that this is approximate and influenced by sample order, with the worst accuracy for sorted data:

```julia
julia> using Statistics, VariationalOnlineStats

julia> median(1:101)
51.0

julia> MedianOnline(1:101)
MedianOnline(med=34.683520091205864, mad=33.301973872578365, n=101)   # pretty far off

julia> using Random

julia> MedianOnline(randperm(101))
MedianOnline(med=49.04313591042025, mad=26.084366886470903, n=101)    # reasonably close
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

For a much broader package (but which doesn't include the median), see [OnlineStats](https://github.com/joshday/OnlineStats.jl).


This package is registered in [HolyLabRegistry](https://github.com/HolyLab/HolyLabRegistry).
