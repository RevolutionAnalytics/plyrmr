\name{where}
\alias{where}
\alias{select}
\title{
Functions to perform sql-like operations.
}
\description{
These functions accept a data set, represented by a pipe or a data frame, and apply the operations specified by the \dots arguments, which are evaluated according to \link{non standard evaluation} rules.
\code{where} allows to filter a subset of the rows. Additional arguments should evaluate to logical or numeric and are used as row indexes. In the case of logical, the element-wise logical and of the arguments is the computed filter. In the case of numeric, a single \dots arguments should be specified. Normal recycling rules apply. \code{select} allows to select or generate new columns from a data set. Additional arguments become columns of the new data set and normal recycling rules apply. In the method for pipes, for both functions, additional arguments are evaluated for each group of the pipe.
}
\usage{
where(.data, \dots)
\method{where}{data.frame}(.data, .cond, .envir = parent.frame())
\method{where}{pipe}(.data, .cond, .envir = parent.frame())
select(.data, \dots)
\method{select}{data.frame}(.data, \dots, .replace = TRUE, .envir = parent.frame())
\method{select}{pipe}(.data, \dots, .replace = TRUE, .envir = parent.frame())
}
\arguments{
  \item{.data}{A data set represented by a pipe}
  \item{\dots}{Additional arguments interpreted as columns by \code{select}}
  \item{.cond}{Expression to evaluate to logical and used to select rows of the data}
  \item{.replace}{whether to replace existing columns}
  \item{.envir}{environment in which to evaluate the \dots arguments}
}
\details{
\code{select} tries to merge the functionality of \code{base::transform}, \code{plyr::mutate}, \code{plyr::summarize} and the SQL statement by the same name. When argument \code{.replace} is \code{TRUE}, the default, the first argument columns are discarded and the ones defined in the \dots arguments are used to form a new data frame. In this case the number of rows returned can be different from the number of rows in the \code{.data} argument but not necessarily one as it is the case for \code{summarize}. When \code{.replace} is \code{FALSE} the behavior is more like \code{transform} and the numbers of rows returned remains the same as in \code{.data}. Recycling rules are applied to the \dots arguments. \code{where} is somewhat equivalent to \code{base::subset}, but focuses only on the selection of rows, not columns. Both functions have methods for data frames and pipes. \code{where} and \code{select} are more appropriate for programming then they \code{base} and \code{plyr} equivalent, \code{transform}, \code{subset}, \code{mutate} and \code{summarize}, because of the additional \code{.envir} argument which allows to specify an evaluation environment different from that of the caller. See \file{tests/non-standard-eval.R} for examples of \code{select} and \code{where} working in contexts where the other functions don't.
}
\value{
The same type as the first argument, either a data frame or a pipe.
}
\examples{
#data.frame
where(mtcars, cyl>4, mpg > 15)
#pipe
as.data.frame(where(input(mtcars), cyl > 4, mpg > 15))
# select two columns
as.data.frame(select(input(mtcars), cyl, mpg))
# create additional column
as.data.frame(select(input(mtcars), ratio = cyl/mpg, .replace = FALSE))
# summaries
as.data.frame(select(input(mtcars), mean(cyl), mean(mpg)))
# summaries by groups
as.data.frame(select(group(input(mtcars), cyl), mean(mpg)))
}
