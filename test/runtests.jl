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
end
