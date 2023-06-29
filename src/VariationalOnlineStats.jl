module VariationalOnlineStats

using Statistics
using Base.Iterators

export MedianOnline

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

function Base.show(io::IO, m::MedianOnline{T}) where {T<:AbstractFloat}
    print(io, "MedianOnline(med=", m.med, ", mad=", m.mad, ", n=", m.n, ")")
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

- `updater.med` is an estimate of the median of `list`;
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



(::Type{T})(m::MedianOnline{T}) where {T<:Number} = m.med
(::Type{T})(m::MedianOnline{T}) where T = m.med
(::Type{T})(m::MedianOnline{<:Number}) where {T<:Number} = convert(T, m.med)

end # module
