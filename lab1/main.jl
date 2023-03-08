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

    p_points = [0.1, 0.5, 0.9]
    points::Vector{Int} = [10^i for i in 2:7]
    mean_errors = []
    variance_errors = []
    points_len = length(points)
    for (i, p) in enumerate(p_points)
        println("p = $p")
        dist, mean, variance = get_distribution(n, p, points)
        mean_teoretical = get_mean_teoretical(p)
        mean_error = abs.((mean_teoretical .- mean) / mean_teoretical)
        variance_teoretical = get_variance_teoretical(p)
        variance_error = abs.((variance_teoretical .- variance) / variance_teoretical)
        # push to mean_errors
        push!(mean_errors, mean_error)
        # push to variances_errors
        push!(variance_errors, variance_error)
    end

    labels = ["p = 0.1" "p = 0.5" "p = 0.9"]

    scatter(points, 100 .* [mean_errors], title="mean error", xlabel="n", ylabel="error [%]", label=labels, xscale=:log10, yscale=:log10)
    savefig("$OUTPUT_DIR/mean_error.png")

    plot()

    scatter(points, 100 .* [variance_errors], title="variance error", xlabel="n", ylabel="error [%]", label=labels, xscale=:log10, yscale=:log10)

    savefig("$OUTPUT_DIR/variance_error.png")


end
main()