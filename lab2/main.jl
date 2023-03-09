using Plots

OUTPUT = "output"

f(x::Float64) = 4 / 5 * (1 + x - x^3)


function compound_process_generator()::Float64
    g1 = 0.8
    u1 = rand()
    u2 = rand()
    if u1 <= g1
        return u2
    else
        return sqrt(1 - sqrt(1 - u2))
    end
end

function markov_chain_generator(n::Int, Δ::Float64)::Array{Float64,1}
    numbers = zeros(n)
    numbers[1] = rand()
    for i in 3:n
        u1 = rand()
        u2 = rand()
        new_x = numbers[i-1] + Δ * (2u1 - 1)
        p = min(1, f(new_x) / f(numbers[i-1]))
        if u2 <= p && new_x >= 0 && new_x <= 1
            numbers[i] = new_x
        else
            numbers[i] = numbers[i-1]
        end
    end
    return numbers
end

function elimination_method_generator()::Float64
    u1 = rand()
    g2 = 1.15 * rand()
    while g2 > f(u1)
        u1 = rand()
        g2 = 1.15 * rand()
    end
    return u1

end

function generate_numbers(generator::Function, n::Int)::Array{Float64,1}
    numbers = zeros(n)
    for i in 1:n
        numbers[i] = generator()
    end
    return numbers
end

function create_histogram(numbers::Array{Float64,1}, title::String)
    range = 0:0.01:1
    filename = replace(title, " " => "_") * ".png"
    histogram(numbers, bins=10, xlabel="x", ylabel="y", title=title, legend=false, normalize=:pdf, ylims=(0.8, 1.2))
    teoretical_density = f.(range)
    plot!(range, teoretical_density, label="teoretyczna wartość")
    savefig(joinpath(OUTPUT, filename))
end

function chi_square_test(numbers::Array{Float64,1}, n::Int)::Float64
    range = 0:0.01:1
    teoretical_density = f.(range)
    observed_density = zeros(length(range))
    for i in 1:lastindex(range)
        observed_density[i] = sum(x -> x >= range[i] && x < range[i+1], numbers)
    end
    observed_density = observed_density ./ n
    return sum((teoretical_density[i] - observed_density[i])^2 / teoretical_density[i] for i in 1:length(range))
end

function main()
    n = 10^6
    compound_numbers = generate_numbers(compound_process_generator, n)
    markov_numbers_d05 = markov_chain_generator(n, 0.5)
    markov_numbers_d005 = markov_chain_generator(n, 0.05)
    elimination_numbers = generate_numbers(elimination_method_generator, n)

    numbers = Dict(
        "Rozklad zlozony" => compound_numbers,
        "Lancuch Markowa delta 0.5" => markov_numbers_d05,
        "Lancuch Markowa delta 0.05" => markov_numbers_d005,
        "Metoda eliminacji" => elimination_numbers)

    results = Dict()
    for (title, numbers) in numbers
        create_histogram(numbers, title)
        results[title] = chi_square_test(numbers, n)
    end

    # plot results with titles on x axis
    scatter(collect(keys(results)), collect(values(results)), xlabel="Metoda", ylabel="Wynik testu chi-kwadrat", title="Wyniki testu chi-kwadrat", legend=false)
    savefig(joinpath(OUTPUT, "chi_square_test.png"))

end

if !isdir(OUTPUT)
    mkpath(OUTPUT)
end
main()