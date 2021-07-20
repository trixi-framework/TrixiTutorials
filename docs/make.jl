using Documenter
using HTTP
using Literate
import Pkg
using Trixi

# Switch variable if documentation should be build if URLs are not valid.
switch = true

# Creating tutorials for these files:
files = [
    "Adding a new equation" => "adding_a_new_equation.jl",
    "Differentiable programming" => "differentiable_programming.jl",
    ]

repo_src        = joinpath(@__DIR__, "src", "files")

pages_dir       = joinpath(@__DIR__, "src", "pages")
notebooks_dir   = joinpath(@__DIR__, "src", "notebooks")

Sys.rm(pages_dir;       recursive=true, force=true)
Sys.rm(notebooks_dir;   recursive=true, force=true)

# Preprocess files to add reference web links automatically.
trixi_version = Pkg.dependencies()[Pkg.project().dependencies["Trixi"]].version
trixi_link = "https://trixi-framework.github.io/Trixi.jl/v$trixi_version/"
function preprocess_links(content)
    # Replacing `@trixi-docs:` in `content` with the defined `trixi_link`
    content = replace(content, "@trixi-docs:" => trixi_link)
    # Searching for `[`Example`](@trixi-ref)` in content and replace it with `[`Example`](trixi_link/reference_trixi/#Trixi.Example)`.
    content = replace(content, r"\[`(?<ref>\w+)`\]\(@trixi-ref\)" => SubstitutionString("[`(\\g<ref>)`]($(trixi_link)reference-trixi/#Trixi.\\g<ref>)"))
end

function postprocess_links(content)
    if occursin(r"\(https://[^\(\)]+\)", content)
        matches = collect(eachmatch(r"\(https://[^\(\)]+\)", content))
        for i in 1:length(matches)
            link = string(chop(matches[i].match, head=1, tail=1))
            try 
                HTTP.get(link, retry=false, connect_timeout=10)
            catch
                if switch
                    @warn "URL doesn't exist: " link
                else 
                    error("URL doesn't exist: ", link)
                end
            end
        end
    end
    return content
end

binder_logo = "https://mybinder.org/badge_logo.svg"
nbviewer_logo = "https://img.shields.io/badge/show-nbviewer-579ACA.svg"

binder_url = joinpath("@__BINDER_ROOT_URL__","dev/notebooks")
@info "" binder_url
# nbviewer_url = joinpath("@__NBVIEWER_ROOT_URL__","dev/notebooks")

binder_url = joinpath("https://mybinder.org/v2/gh/trixi-framework/TrixiTutorials/gh-pages?filepath=dev/notebooks/")
nbviewer_url = joinpath("https://nbviewer.jupyter.org/github/trixi-framework/TrixiTutorials/blob/gh-pages/dev/notebooks/")

binder_badge = string("# [![](", binder_logo, ")](", binder_url, ")")
nbviewer_badge = string("# [![](", nbviewer_logo, ")](", nbviewer_url, ")")

# Add introduction file (index.jl) to navigation menu
pages = ["Introduction" => "index.md"]
# Generate markdown for index.jl
function preprocess_docs(content)
    return string("# # TrixiTutorials.jl", "\n", binder_badge, "\n", nbviewer_badge, "\n\n",
                  preprocess_links(content))
end
Literate.markdown(joinpath(repo_src, "index.jl"), joinpath(pages_dir, ".."); name="index", documenter=false,
                  execute=true, preprocess=preprocess_docs, postprocess=postprocess_links)
# TODO: With `documenter=false` there is no `link to source` in html file. With `true` the link is not defined because of some `<unkown>`.

# Create markdown and notebook files for other src files.
for (i, (title, filename)) in enumerate(files)
    tutorial_title = string("# # Tutorial ", i, ": ", title)
    tutorial_file = string(splitext(filename)[1])

    notebook_filename = string(tutorial_file, ".ipynb")
    markdown_filename = string(tutorial_file, ".md")
    
    binder_badge_ = string("# [![](", binder_logo, ")](", joinpath(binder_url, notebook_filename), ")")
    nbviewer_badge_ = string("# [![](", nbviewer_logo, ")](", joinpath(nbviewer_url, notebook_filename), ")")
    
    # Generate notebooks
    function preprocess_notebook(content)
        return string(tutorial_title, "\n\n", preprocess_links(content))
    end

    Literate.notebook(joinpath(repo_src,filename), notebooks_dir; name=tutorial_file,
                      execute=true, preprocess=preprocess_notebook,)

    # Generate markdowns
    function preprocess_docs(content)
        return string(tutorial_title, "\n", binder_badge_, "\n", nbviewer_badge_, "\n\n",
                      preprocess_links(content))
    end
    Literate.markdown(joinpath(repo_src, filename), pages_dir; name=tutorial_file, documenter=false,
                      execute=true, preprocess=preprocess_docs, postprocess=postprocess_links)

    # Add to navigation menu
    push!(pages, (title => joinpath("pages", markdown_filename)))
end

# Create documentation with Documenter.jl
makedocs(
    # Set sitename to Trixi
    sitename="TrixiTutorials",
    # Provide additional formatting options
    format = Documenter.HTML(
        # Disable pretty URLs during manual testing
        prettyurls = get(ENV, "CI", nothing) == "true",
        # Explicitly add favicon as asset
        assets = ["assets/favicon.ico"],
        # Set canonical URL to GitHub pages URL
        canonical = "https://trixi-framework.github.io/TrixiTutorials/stable"
    ),
    # Explicitly specify documentation structure
    pages = pages,
    strict = true # to make the GitHub action fail when doctests fail, see https://github.com/neuropsychology/Psycho.jl/issues/34
)

deploydocs(
    repo = "github.com/trixi-framework/TrixiTutorials.jl",
    devbranch = "main",
    # push_preview = true,
)