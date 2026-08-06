# ---------------------------------------------------------------------------
# Static stand-ins for the interactive learnr / htmlwidget functions, used only
# when building the printable handouts (see make_handouts.R).
#
# This is sourced into the handout document, where it masks the real functions.
# ---------------------------------------------------------------------------

# Escape the characters that would otherwise be read as markdown. Backslash
# must come first so we do not double-escape our own additions.
.md_escape <- function(x) {
  if (is.null(x)) return(x)
  for (ch in c("\\", "_", "*", "$", "<", ">", "#", "~", "^", "[", "]")) {
    x <- gsub(ch, paste0("\\", ch), x, fixed = TRUE)
  }
  x
}

.q_counter <- local({
  i <- 0
  function() {
    i <<- i + 1
    i
  }
})

answer <- function(text, correct = FALSE, message = NULL, ...) {
  list(text = text, correct = isTRUE(correct))
}

# NOTE: this prints as a SIDE EFFECT rather than returning an object for knitr
# to auto-print. knitr calls print() from inside its own namespace, so an S3
# print method defined in the document environment would never be found.
question <- function(text, ..., type = NULL, correct = NULL, incorrect = NULL,
                     message = NULL, allow_retry = NULL,
                     random_answer_order = NULL, submit_button = NULL,
                     try_again_button = NULL, options = NULL, loading = NULL) {
  answers <- Filter(function(x) is.list(x) && !is.null(x$text), list(...))

  cat("\n**Question ", .q_counter(), ".** ", .md_escape(text), "\n\n", sep = "")
  for (a in answers) {
    if (isTRUE(a$correct)) {
      cat("- **", .md_escape(a$text), "** *(correct answer)*\n", sep = "")
    } else {
      cat("- ", .md_escape(a$text), "\n", sep = "")
    }
  }

  feedback <- Filter(Negate(is.null), list(correct, message))
  if (length(feedback)) {
    cat("\n> *Explanation.* ",
        .md_escape(paste(unlist(feedback), collapse = " ")), "\n", sep = "")
  }
  cat("\n")
  invisible(NULL)
}

# Forcing list(...) evaluates the question() calls, in order, for their output.
quiz <- function(..., caption = NULL) {
  invisible(list(...))
}

# --- interactive widgets ---------------------------------------------------
# DT::datatable and plotly do not render in PDF, so fall back to a plain table
# and to the underlying ggplot object.

`%||%` <- function(a, b) if (is.null(a)) b else a

datatable <- function(data, ..., caption = NULL) {
  knitr::kable(utils::head(as.data.frame(data), 10),
               caption = caption %||% "First 10 rows",
               row.names = FALSE)
}

ggplotly <- function(p, ...) p

# plotly::layout() is sometimes piped onto ggplotly() to set a title/subtitle.
# Translate that back into ggplot labels instead of failing.
layout <- function(p, ...) {
  if (!inherits(p, "ggplot")) return(p)
  ttl <- list(...)$title
  txt <- if (is.list(ttl)) ttl$text else if (is.character(ttl)) ttl else NULL
  if (!is.null(txt)) {
    strip <- function(s) trimws(gsub("<[^>]*>", "", s))
    parts <- strsplit(txt, "<br>", fixed = TRUE)[[1]]
    p <- p + ggplot2::labs(
      title    = strip(parts[1]),
      subtitle = if (length(parts) > 1) strip(paste(parts[-1], collapse = " ")) else NULL
    )
  }
  p
}
