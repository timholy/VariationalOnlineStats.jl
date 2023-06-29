module VariationalOnlineStats

using Statistics
using Base.Iterators

export MedianOnline, MedianSampleOnline

struct MedianOnline{T<:AbstractFloat}
    med::T   # median
    mad::T   # mean absolute deviation
    n::Int
end
MedianOnline{T}(x) where T<:AbstractFloat = MedianOnline{T}(x, zero(T), 1)

MedianOnline(x::T) where {T<:AbstractFloat} = MedianOnline{T}(x)
MedianOnline(x::Number) = MedianOnline{float(typeof(x))}(x)

# For round-tripping with printing
MedianOnline(; med::T, mad::T, n::Int) where {T<:AbstractFloat} = MedianOnline{T}(med, mad, n)

function Base.show(io::IO, m::MedianOnline)
    print(io, "MedianOnline(med=", m.med, ", mad=", m.mad, ", n=", m.n, ")")
end


struct MedianSampleOnline{T<:AbstractFloat,S}
    med::T   # median
    mad::T   # mean absolute deviation
    n::Int
    Δx::T    # signed difference between the median and value corresponding to `sample`
    sample::S   # an object (sample) whose `x` value was reasonably close to the median
end
MedianSampleOnline{T,S}(x, s) where {T<:AbstractFloat,S} = MedianSampleOnline{T,S}(x, zero(T), 1, 0, s)

MedianSampleOnline(x::T, s::S) where {T<:AbstractFloat,S} = MedianSampleOnline{T,S}(x, s)
MedianSampleOnline(x::Number, s::S) where {S} = MedianSampleOnline{float(typeof(x)),S}(x, s)

function Base.show(io::IO, m::MedianSampleOnline)
    print(io, "MedianSampleOnline(med=", m.med, ", sample=", repr(m.sample), ")")
end


"""
    MedianOnline{T}(list) → updater
    MedianOnline(list) → updater

Return an `updater` object that stores an estimate of the median of `list`.
This is an online algorithm that uses constant memory and is `O(n)` in the length of `list`.
See [median(::MedianOnline, x)](@ref) for a description of `updater`.
"""
function MedianOnline{T}(v::AbstractVector{<:Number}) where {T<:AbstractFloat}
    m = MedianOnline{T}(first(v)::Number)
    for x in drop(v, 1)
        m = median(m, x::Number)
    end
    m
end
MedianOnline(v::AbstractVector{T}) where {T<:AbstractFloat} = MedianOnline{T}(v)
MedianOnline(v::AbstractVector{T}) where {T<:Number} = MedianOnline{float(T)}(v)

"""
    median(updater::MedianOnline, x) → updater′

Update the running median with new value `x`.

Upon return:

- `updater.med` is an estimate of the median of all `x` values seen so far;
- `updater.mad` is an estimate of the mean absolute deviation;
- `updater.n` is the number of values seen so far.
"""
function Statistics.median(m::MedianOnline{T}, x::Number) where {T}
    f = 1/(m.n + 1)  # fraction of contribution to mad
    Δx = x - m.med
    aΔx = abs(Δx)
    mad = (1-f) * m.mad + f * aΔx
    Δv = mad/m.n   # separation of the closest point among n from an
                   # exponential distribution with the given mad
    med = m.med + sign(Δx) * min(aΔx, Δv)
    MedianOnline{T}(med, mad, m.n+1)
end

"""
    median(updater::MedianSampleOnline, x, item) → updater′

Update with a new sample `item`. `x` is a numerical parameter corresponding to `item`; `updater′` attempts to estimate
the running median and a single `item` whose corresponding `x` value was reasonably close to the median.
See the README for an example.

Upon return:

- `updater.med` is an estimate of the median;
- `updater.sample` is the "typical" item.
"""
function Statistics.median(m::MedianSampleOnline{T,S}, x::Number, s) where {T,S}
    f = 1/(m.n + 1)  # fraction of contribution to mad
    Δx = x - m.med
    aΔx = abs(Δx)
    mad = (1-f) * m.mad + f * aΔx
    Δv = mad/m.n   # separation of the closest point among n from an
                   # exponential distribution with the given mad
    Δmed = sign(Δx) * min(aΔx, Δv)
    med = m.med + Δmed
    Δxspref = m.Δx - Δmed
    Δxs = x - med
    if abs(Δxspref) < abs(Δxs)
        snew = m.sample
        Δxnew = Δxspref
    else
        Δxnew = Δxs
        snew = s
    end
    MedianSampleOnline{T,S}(med, mad, m.n+1, Δxnew, snew)
end


(::Type{T})(m::MedianOnline{T}) where {T<:Number} = m.med
(::Type{T})(m::MedianOnline{T}) where T = m.med
(::Type{T})(m::MedianOnline{<:Number}) where {T<:Number} = convert(T, m.med)

end # module
