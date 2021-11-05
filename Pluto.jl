### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 28582666-3e4e-11ec-22b2-ad718e070e01
begin

using Agents, Random

mutable struct SugarSeeker <: AbstractAgent
    id::Int
    pos::Dims{2}
    vision::Int
    metabolic_rate::Int
    age::Int
    max_age::Int
    wealth::Int
end
	
end 

# ╔═╡ e2f25f40-01cb-4aff-b574-281aaea8cff8
begin


function distances(pos, sugar_peaks, max_sugar)
    all_dists = Array{Int,1}(undef, length(sugar_peaks))
    for (ind, peak) in enumerate(sugar_peaks)
        d = round(Int, sqrt(sum((pos .- peak) .^ 2)))
        all_dists[ind] = d
    end
    return minimum(all_dists)
end

function sugar_caps(dims, sugar_peaks, max_sugar, dia = 4)
    sugar_capacities = zeros(Int, dims)
    for i in 1:dims[1], j in 1:dims[2]
        sugar_capacities[i, j] = distances((i, j), sugar_peaks, max_sugar)
    end
    for i in 1:dims[1]
        for j in 1:dims[2]
            sugar_capacities[i, j] = max(0, max_sugar - (sugar_capacities[i, j] ÷ dia))
        end
    end
    return sugar_capacities
end

"Create a sugarscape ABM"
function sugarscape(;
    dims = (50, 50),
    sugar_peaks = ((10, 40), (40, 10)),
    growth_rate = 1,
    N = 250,
    w0_dist = (5, 25),
    metabolic_rate_dist = (1, 4),
    vision_dist = (1, 6),
    max_age_dist = (60, 100),
    max_sugar = 4,
    seed = 42
)
    sugar_capacities = sugar_caps(dims, sugar_peaks, max_sugar, 6)
    sugar_values = deepcopy(sugar_capacities)
    space = GridSpace(dims)
    properties = Dict(
        :growth_rate => growth_rate,
        :N => N,
        :w0_dist => w0_dist,
        :metabolic_rate_dist => metabolic_rate_dist,
        :vision_dist => vision_dist,
        :max_age_dist => max_age_dist,
        :sugar_values => sugar_values,
        :sugar_capacities => sugar_capacities,
    )
    model = AgentBasedModel(
        SugarSeeker,
        space,
        scheduler = Schedulers.randomly,
        properties = properties,
        rng = MersenneTwister(seed)
    )
    for ag in 1:N
        add_agent_single!(
            model,
            rand(model.rng, vision_dist[1]:vision_dist[2]),
            rand(model.rng, metabolic_rate_dist[1]:metabolic_rate_dist[2]),
            0,
            rand(model.rng, max_age_dist[1]:max_age_dist[2]),
            rand(model.rng, w0_dist[1]:w0_dist[2]),
        )
    end
    return model
end

model = sugarscape()
	
end 

# ╔═╡ 3da65696-ee6a-4a3c-8b6c-8736251e1ab5
begin
	
	using CairoMakie

fig = Figure(resolution = (600, 600))
ax, hm = heatmap(fig[1,1], model.sugar_capacities; colormap=cgrad(:thermal))
Colorbar(fig[1, 2], hm, width = 20)
fig
	
end 

# ╔═╡ Cell order:
# ╠═28582666-3e4e-11ec-22b2-ad718e070e01
# ╠═e2f25f40-01cb-4aff-b574-281aaea8cff8
# ╠═3da65696-ee6a-4a3c-8b6c-8736251e1ab5
