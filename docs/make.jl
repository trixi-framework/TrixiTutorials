using Documenter
using Literate
import Pkg
using Trixi

# Function to create markdown and notebook files for specific file
function create_files(title, file; folder="")
    notebook_filename = "$(splitext(file)[1]).ipynb"

    binder_badge   = string("# [![]($binder_logo)](",   joinpath(binder_url,   folder, notebook_filename), ")")
    nbviewer_badge = string("# [![]($nbviewer_logo)](", joinpath(nbviewer_url, folder, notebook_filename), ")")
    download_badge = string("# [![]($download_logo)](", joinpath(download_url, folder, notebook_filename), ")")
    
    # Generate notebooks
    function preprocess_notebook(content)
        return string("# # $title\n\n", preprocess_links(content))
    end
    Literate.notebook(joinpath(repo_src, folder, file), joinpath(notebooks_dir, folder); preprocess=preprocess_notebook, credit=false)

    # Generate markdowns
    function preprocess_docs(content)
        return string("# # $title\n $binder_badge\n $nbviewer_badge\n $download_badge\n\n", preprocess_links(content))
    end
    Literate.markdown(joinpath(repo_src, folder, file), joinpath(pages_dir, folder); execute=false, codefence="```julia" => "```", preprocess=preprocess_docs,)

end

# Creating tutorials for the following files:
# Normal structure: "title" => "filename.jl"
# If there are several files for one topic and folder, the structure is:
#   "title" => ["subtitle 1" => ("folder 1", "filename 1.jl"),
#               "subtitle 2" => ("folder 2", "filename 2.jl")]
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

# Function that replaces `@trixi-docs` and `@trixi-ref` with the links to the Trixi documentation
function preprocess_links(content)
    # Replacing `@trixi-docs:` in `content` with the defined `trixi_link`
    content = replace(content, "@trixi-docs:" => trixi_link)
    # Searching for `[`Example`](@trixi-ref)` in content and replace it with `[`Example`](trixi_link/reference_trixi/#Trixi.Example)`.
    content = replace(content, r"\[`(?<ref>\w+)`\]\(@trixi-ref\)" => SubstitutionString("[`\\g<ref>`]($(trixi_link)reference-trixi/#Trixi.\\g<ref>)"))
end

binder_logo   = "https://mybinder.org/badge_logo.svg"
nbviewer_logo = "https://raw.githubusercontent.com/jupyter/design/master/logos/Badges/nbviewer_badge.svg"
download_logo = "https://camo.githubusercontent.com/aea75103f6d9f690a19cb0e17c06f984ab0f472d9e6fe4eadaa0cc438ba88ada/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f646f776e6c6f61642d6e6f7465626f6f6b2d627269676874677265656e"

# binder_url = joinpath("@__BINDER_ROOT_URL__", "dev/notebooks")
# nbviewer_url = joinpath("@__NBVIEWER_ROOT_URL__", "dev/notebooks")

binder_url   = "https://mybinder.org/v2/gh/trixi-framework/TrixiTutorials/gh-pages?filepath=dev/notebooks/"
nbviewer_url = "https://nbviewer.jupyter.org/github/trixi-framework/TrixiTutorials/blob/gh-pages/dev/notebooks/"
download_url = "https://raw.githubusercontent.com/trixi-framework/TrixiTutorials/gh-pages/dev/notebooks/"

# Navigation system for makedocs
pages = []

# Generate markdown for index.jl
Literate.markdown(joinpath(repo_src, "index.jl"), joinpath(pages_dir, ".."); execute=true, preprocess=preprocess_links,)
push!(pages, ("Introduction" => "index.md"))

# Create markdown and notebook files for tutorials.
for (i, (title, filename)) in enumerate(files)
    # Several files of one topic are created seperately and pushed to pages together.
    if filename isa Vector
        vector = []
        for j in 1:length(filename)
            create_files("Tutorial $i.$j: $title: $(filename[j][1])", filename[j][2][2]; folder=filename[j][2][1])

            push!(vector, "$i.$j $(filename[j][1])" => joinpath("pages", "$(filename[j][2][1])/$(splitext(filename[j][2][2])[1]).md"))
        end
        # Add to navigation menu
        push!(pages, ("$i $title" => vector))
    else # Single files
        create_files("Tutorial $i: $title", filename)
        # Add to navigation menu
        push!(pages, ("$i $title" => joinpath("pages", "$(splitext(filename)[1]).md")))
    end
end

# Create documentation with Documenter.jl
makedocs(
    # Set sitename to Trixi
    sitename = "Tutorials for Trixi.jl",
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
    linkcheck = true, # checks external links using curl
    strict = get(ENV, "CI", nothing) == "true"
    # to make the GitHub action fail when doctests fail, see https://github.com/neuropsychology/Psycho.jl/issues/34
)

deploydocs(
    repo = "github.com/trixi-framework/TrixiTutorials.jl",
    devbranch = "main",
    # push_preview = true,
)
