using VariationalOnlineStats
using Test, Statistics

@testset "MedianOnline" begin
    for n = 1:2
        for i = 1:100
            x = rand(n)
            @test Float64(MedianOnline(x)) ≈ median(x)
        end
    end

    @test Float64(MedianOnline(Float64[1, 3, 2])) ≈ 2.0
    @test Float64(MedianOnline(Float64[3, 1, 2])) ≈ 2.0
    @test abs(Float64(MedianOnline(Float64[1, 2, 3])) - 2) < 0.1
    @test abs(Float64(MedianOnline(Float64[3, 2, 1])) - 2) < 0.1

    v = [1, 11, 10, 2, 3, 9, 8, 4, 5, 7, 6]
    @test abs(Float64(MedianOnline{Float64}(v)) - 6) < 0.1
    @test Float64(MedianOnline{Float64}(1:11)) > 4.5
    @test Float64(MedianOnline{Float64}(11:-1:1)) < 7.5
    m = MedianOnline(v)
    m2 = MedianOnline(first(v))
    for x in Iterators.drop(v, 1)
        m2 = median(m2, x)
    end
    @test m == m2

    m = MedianOnline([1, 3, 2])
    @test eval(Meta.parse(repr(m))) == m
end

@testset "MedianSampleOnline" begin
    words = split("""
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
    Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
    Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    """)
    w = first(words)
    updater = MedianSampleOnline(length(w), w)
    for w in Iterators.drop(words, 1)
        updater = median(updater, length(w), w)
    end
    @test length(updater.sample) == 5
end
