# Run from the website root after installing logical from the same source checkout.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop("Usage: Rscript scripts/build-articles.R path/to/logical")
source_dir <- normalizePath(args[[1]], mustWork = TRUE)
output_dir <- normalizePath("docs/articles", mustWork = TRUE)
pandoc <- Sys.which("pandoc")
if (!nzchar(pandoc)) stop("pandoc must be on PATH")
slugs <- c("overview", "theory", "application-1-district-predictions",
           "application-2-racial-margin", "application-3-jurisdiction-counts",
           "application-4-redistricting", "application-5-sweet-spot")
labels <- c("Overview", "Theory", paste("Application", 1:5))
sha <- system2("git", c("-C", shQuote(source_dir), "rev-parse", "HEAD"), stdout = TRUE)
if (length(sha) != 1L || !grepl("^[a-f0-9]{40}$", sha)) stop("Cannot identify package commit")
old_dir <- setwd(output_dir)
for (i in seq_along(slugs)) {
  slug <- slugs[[i]]
  input <- file.path(source_dir, "vignettes", paste0(slug, ".Rmd"))
  if (!file.exists(input)) stop("Missing vignette: ", input)
  knitr::opts_chunk$set(error = FALSE, cache = FALSE, dev = "png",
                       fig.path = paste0("figure/", slug, "-"))
  markdown <- tempfile(fileext = ".md")
  fragment <- tempfile(fileext = ".html")
  knitr::knit(input, output = markdown, envir = new.env(), quiet = TRUE)
  title <- yaml::yaml.load(paste(readLines(input, warn = FALSE)[
    2:(which(readLines(input, warn = FALSE) == "---")[[2]] - 1)], collapse = "\n"))$title
  status <- system2(pandoc, c(shQuote(markdown), "--from=markdown", "--to=html5",
                             "--mathjax", "--output", shQuote(fragment)))
  if (status != 0L) stop("Pandoc failed: ", slug)
  escape <- function(x) gsub('"', "&quot;", gsub("<", "&lt;", gsub("&", "&amp;", x, fixed = TRUE), fixed = TRUE), fixed = TRUE)
  nav <- paste(vapply(seq_along(slugs), function(j) sprintf(
    '<a%s href="%s.html">%s</a>', if (i == j) ' aria-current="page"' else "",
    slugs[[j]], labels[[j]]), character(1)), collapse = "")
  html <- c('<!doctype html>', '<html lang="en"><head><meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1">',
    sprintf('<title>%s · logical</title>', escape(title)),
    '<link rel="stylesheet" href="../styles.css">',
    '<script defer src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script></head>',
    '<body><header class="site-header"><a class="site-brand" href="../">logical</a>',
    paste0('<nav class="site-nav" aria-label="Vignette navigation"><a href="../">Home</a>', nav, '</nav></header>'),
    sprintf('<main><h1>%s</h1>', escape(title)), readLines(fragment, warn = FALSE),
    '</main>', sprintf('<footer>Built from <a href="https://github.com/YukiAtsusaka/logical/blob/%s/vignettes/%s.Rmd">package source %s</a>.</footer>', sha, slug, substr(sha, 1, 7)),
    '</body></html>')
  writeLines(html, paste0(slug, ".html"), useBytes = TRUE)
  unlink(c(markdown, fragment))
  message("Built ", slug)
}
setwd(old_dir)
