module VariationalOnlineStats

using Statistics
using Base.Iterators

export MedianOnline

struct MedianOnline{T}
    med::T   # median
    mad::T   # mean absolute deviation
    n::Int
end
(::Type{MedianOnline{T}})(x) where T = MedianOnline{T}(x, zero(T), 1)

MedianOnline(x::T) where {T<:AbstractFloat} = MedianOnline{T}(x)

function MedianOnline{T}(v::AbstractVector{<:Number}) where {T<:AbstractFloat}
    m = MedianOnline{T}(first(v))
    for x in drop(v, 1)
        m = median(m, x)
    end
    m
end
MedianOnline(v::AbstractVector{T}) where {T<:AbstractFloat} = MedianOnline{T}(v)

@inline function Statistics.median(m::MedianOnline{T}, x) where {T}
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
