using Plots
using LinearAlgebra

OUTPUT_DIR = "output"

function get_bernoulli(p::Float64)::Int
    if rand() < p
        return 1
    else
        return 0
    end
end

function calculate_mean(dist::Array{Int,1})::Float64
    return sum(dist) / length(dist)
end

function get_mean_teoretical(p::Float64)::Float64
    return p
end

function calculate_variance(dist::Array{Int,1}, mean::Float64)::Float64
    return sum((x - mean)^2 for x in dist) / length(dist)
end

function get_variance_teoretical(p::Float64)::Float64
    return p * (1 - p)
end

function get_distribution(n::Int, p::Float64, points::Vector{Int})
    dist::Vector{Int} = Array{Int,1}(undef, n)
    mean_arr::Vector{Float64} = zeros(length(points))
    var_arr::Vector{Float64} = zeros(length(points))
    count::Int = 1
    for i in 1:n
        dist[i] = get_bernoulli(p)
        if i in points
            mean = calculate_mean(dist[1:i])
            variance = calculate_variance(dist[1:i], mean)
            mean_arr[count] = mean
            var_arr[count] = variance
            count += 1
        end
    end
    return dist, mean_arr, var_arr
end

function main()
    if !isdir(OUTPUT_DIR)
        mkpath(OUTPUT_DIR)
    end
    n::Int = 10^7 + 1
    p::Float64 = 0.5
    powers = 2:7
    points::Vector{Int} = [10^i for i in powers]
    points_len = length(points)
    dist, mean, variance = @time get_distribution(n, p, points)
    mean_teoretical = get_mean_teoretical(p) .* ones(points_len)
    mean_error = abs.((mean_teoretical - mean) / mean_teoretical)
    variance_teoretical = get_variance_teoretical(p) .* ones(points_len)
    variance_error = abs.((variance_teoretical - variance) / variance_teoretical)


    scatter(powers, mean, label="mean computed")
    plot!(powers, mean_teoretical, label="mean teoretical")
    savefig("$OUTPUT_DIR/mean.png")
    scatter(powers, variance, label="variance computed")
    plot!(powers, variance_teoretical, label="variance teoretical")
    savefig("$OUTPUT_DIR/variance.png")
    scatter(powers, 100 * mean_error, title="mean error", xlabel="10^k", ylabel="error [%]", label=nothing, yscale=:log10)
    savefig("$OUTPUT_DIR/mean_error.png")
    scatter(powers, 100 * variance_error, title="variance error", xlabel="10^k", ylabel="error [%]", label=nothing, yscale=:log10)
    savefig("$OUTPUT_DIR/variance_error.png")

end
main()