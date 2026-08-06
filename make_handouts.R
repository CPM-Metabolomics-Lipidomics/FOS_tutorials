#!/usr/bin/env Rscript
# ---------------------------------------------------------------------------
# Build static handouts from the learnr tutorials.
#
# Turns each interactive tutorial into a self-contained document in which
# every code box has been RUN (code + output shown) and every quiz question
# is printed with its correct answer and explanation.
#
# Usage:
#   Rscript make_handouts.R            # HTML + PDF for all tutorials
#   Rscript make_handouts.R html       # HTML only (fast, keeps interactivity)
#   Rscript make_handouts.R pdf
#   Rscript make_handouts.R html Iris-dataset
#
# Output goes to ./handouts/
# ---------------------------------------------------------------------------

suppressWarnings(suppressMessages(library(rmarkdown)))

args     <- commandArgs(trailingOnly = TRUE)
formats  <- if (length(args) >= 1) args[1] else "both"
only     <- if (length(args) >= 2) args[-1] else NULL

root     <- normalizePath(".")
year_dir <- file.path(root, "FOS", "2026")
out_dir  <- file.path(root, "handouts")
dir.create(out_dir, showWarnings = FALSE)

tutorials <- list.dirs(year_dir, recursive = FALSE)
tutorials <- tutorials[file.exists(file.path(tutorials, "index.Rmd"))]
if (!is.null(only)) tutorials <- tutorials[basename(tutorials) %in% only]

# --- the shim chunk injected into every handout ----------------------------
# It replaces the learnr quiz functions with printable equivalents, and the
# two interactive widgets with static ones so the document renders to PDF.
shim_file <- file.path(root, "handout_shims.R")
stopifnot(file.exists(shim_file))

# local = TRUE sources into the calling (knit) environment, so the definitions
# are visible to every later chunk.
SHIM <- paste(
  "```{r handout-shims, include=FALSE}",
  paste0('source("', shim_file, '", local = TRUE)'),
  "```",
  sep = "\n"
)

# --- helpers ---------------------------------------------------------------

chunk_header_info <- function(line) {
  inner <- sub("^```\\{r\\s*", "", sub("\\}\\s*$", "", line))
  parts <- trimws(strsplit(inner, ",")[[1]])
  list(label = parts[1], opts = parts[-1], raw = inner)
}

# Rewrite one chunk header for static rendering
rewrite_header <- function(info, is_quiz) {
  keep <- info$opts[!grepl("^(exercise|exercise\\.setup|exercise\\.timelimit|echo|results|include)\\s*=",
                           info$opts)]
  if (is_quiz) {
    opts <- c(info$label, "echo=FALSE", "results='asis'", keep)
  } else if (grepl("^(setup|prep-|handout-)", info$label)) {
    opts <- c(info$label, "include=FALSE", keep)
  } else {
    opts <- c(info$label, "echo=TRUE", keep)
  }
  paste0("```{r ", paste(opts, collapse = ", "), "}")
}

# Normalise code for comparison: drop comments and collapse whitespace, so a
# solution chunk that is just the exercise code without its comments counts as
# a duplicate and is not printed twice.
norm <- function(x) {
  x <- sub("#.*$", "", x)
  x <- x[nzchar(trimws(x))]
  gsub("\\s+", " ", trimws(paste(x, collapse = " ")))
}

convert <- function(rmd_path) {
  lines <- readLines(rmd_path, warn = FALSE)

  # ---- front matter ----
  fm_end <- which(lines == "---")[2]
  fm <- lines[1:fm_end]
  body <- lines[(fm_end + 1):length(lines)]

  get_field <- function(key) {
    hit <- grep(paste0("^", key, ":"), fm, value = TRUE)
    if (!length(hit)) return(NULL)
    trimws(gsub('"', "", sub(paste0("^", key, ":"), "", hit[1])))
  }
  title    <- get_field("title")
  subtitle <- get_field("subtitle")
  author   <- get_field("author")

  # ---- collect chunks ----
  starts <- grep("^```\\{r", body)
  ends   <- integer(length(starts))
  for (i in seq_along(starts)) {
    rest <- which(grepl("^```\\s*$", body) & seq_along(body) > starts[i])
    ends[i] <- rest[1]
  }
  labels <- vapply(body[starts], function(l) chunk_header_info(l)$label, character(1))

  # map exercise label -> its solution code, so we can decide whether to keep it
  sol_idx <- grep("-solution$", labels)
  sol_code <- setNames(
    lapply(sol_idx, function(i) body[(starts[i] + 1):(ends[i] - 1)]),
    sub("-solution$", "", labels[sol_idx])
  )

  drop <- rep(FALSE, length(body))
  new_body <- body

  for (i in seq_along(starts)) {
    lab  <- labels[i]
    code <- body[(starts[i] + 1):(ends[i] - 1)]
    info <- chunk_header_info(body[starts[i]])

    # solution chunks: drop when they merely repeat the exercise code,
    # otherwise keep as a non-evaluated "Solution" block
    if (grepl("-solution$", lab)) {
      ex <- sub("-solution$", "", lab)
      ex_i <- match(ex, labels)
      same <- !is.na(ex_i) && identical(norm(code), norm(body[(starts[ex_i] + 1):(ends[ex_i] - 1)]))
      if (same) {
        drop[starts[i]:ends[i]] <- TRUE
      } else {
        new_body[starts[i]] <- paste0("**Solution**\n\n```{r ", lab, ", eval=FALSE, echo=TRUE}")
      }
      next
    }

    is_quiz <- any(grepl("\\b(quiz|question)\\s*\\(", code))
    new_body[starts[i]] <- rewrite_header(info, is_quiz)

    # strip learnr-only calls from the setup chunk
    if (lab == "setup") {
      for (j in (starts[i] + 1):(ends[i] - 1)) {
        if (grepl("^\\s*library\\(learnr\\)", new_body[j]) ||
            grepl("^\\s*tutorial_options\\(", new_body[j])) {
          drop[j] <- TRUE
        }
      }
    }
  }

  new_body <- new_body[!drop]

  # ---- drop the "How to use this tutorial" section ----
  h <- grep("^## How to use this tutorial", new_body)
  if (length(h)) {
    nxt <- grep("^## ", new_body)
    nxt <- nxt[nxt > h[1]]
    stop_at <- if (length(nxt)) nxt[1] - 1 else length(new_body)
    new_body <- new_body[-(h[1]:stop_at)]
  }

  # ---- HTML callout divs -> markdown blockquotes ----
  out <- character(0); in_div <- FALSE
  for (ln in new_body) {
    if (grepl('^<div (class="alert|id=".*-hint")', ln)) { in_div <- TRUE; next }
    if (in_div && grepl("^</div>", ln))                 { in_div <- FALSE; out <- c(out, ""); next }
    out <- c(out, if (in_div && nzchar(trimws(ln))) paste0("> ", ln) else if (in_div) ">" else ln)
  }
  new_body <- out

  # ---- new front matter ----
  yaml_head <- c(
    "---",
    paste0('title: "', title, '"'),
    if (!is.null(subtitle)) paste0('subtitle: "', subtitle, '"'),
    if (!is.null(author))   paste0('author: "', author, '"'),
    'date: "Handout - generated `r format(Sys.Date(), \'%d %B %Y\')`"',
    "output:",
    "  html_document:",
    "    toc: true",
    "    toc_float: true",
    "    self_contained: true",
    "    theme: readable",
    "  pdf_document:",
    "    toc: true",
    # Default pdflatex handles the R-squared / 1-H characters fine. Do NOT
    # switch to lualatex/xelatex unless the OpenType Latin Modern fonts are
    # installed (texlive-fonts-recommended); without them both engines fail.
    "    number_sections: false",
    "geometry: margin=2.5cm",
    "---",
    "",
    paste0("> This is a static copy of the interactive tutorial. All code has ",
           "been run and the output is shown below it; every question is ",
           "printed with its correct answer marked and the explanation ",
           "underneath."),
    ""
  )

  c(yaml_head, SHIM, new_body)
}

# --- build ------------------------------------------------------------------
for (tut in tutorials) {
  name <- basename(tut)
  cat("\n=== ", name, " ===\n", sep = "")

  handout_rmd <- file.path(tut, paste0("handout_", name, ".Rmd"))
  writeLines(convert(file.path(tut, "index.Rmd")), handout_rmd)

  fmts <- switch(formats,
                 html = "html_document",
                 pdf  = "pdf_document",
                 c("html_document", "pdf_document"))

  for (f in fmts) {
    ok <- tryCatch({
      rmarkdown::render(handout_rmd, output_format = f,
                        output_dir = out_dir, quiet = TRUE,
                        knit_root_dir = tut, envir = new.env())
      TRUE
    }, error = function(e) { cat("  FAILED (", f, "): ", conditionMessage(e), "\n", sep = ""); FALSE })
    if (ok) {
      ext <- if (f == "pdf_document") "pdf" else "html"
      cat("  ", f, " -> handouts/handout_", name, ".", ext, "\n", sep = "")
    }
  }
  # tidy up intermediates left in the tutorial directory and next to the output
  unlink(handout_rmd)
  unlink(list.files(tut, pattern = "^handout_.*\\.(log|tex|aux|toc|out)$",
                    full.names = TRUE))
  unlink(list.files(tut, pattern = "^handout_.*_files$", full.names = TRUE),
         recursive = TRUE)
  unlink(file.path(tut, "Rplots.pdf"))
  unlink(list.files(out_dir, pattern = "\\.(tex|log|aux|toc|out)$",
                    full.names = TRUE))
}

cat("\nDone. Output in ", out_dir, "\n", sep = "")
