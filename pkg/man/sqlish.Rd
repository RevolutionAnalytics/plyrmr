\name{sqlish}
\alias{where}
\alias{transmute}
\alias{bind.cols}
\alias{select}
\title{
Functions to perform generic data manipulation.
}
\description{
These functions implement common data manipulation tasks with methods for Hadoop data sets and data frames. They all accept the data as their first argument,
followed by additional arguments that detail the manupulation to be performed.}
\usage{
where(.data, .cond)
\method{where}{data.frame}(.data, .cond)
\method{where}{pipe}(.data, .cond)
bind.cols(.data, \dots)
\method{bind.cols}{data.frame}(.data, \dots)
\method{bind.cols}{pipe}(.data, \dots)
select(.data, \dots)
\method{select}{data.frame}(.data, \dots)
\method{select}{pipe}(.data, \dots)
transmute(.data, \dots)
\method{transmute}{data.frame}(.data, \dots, .cbind = FALSE, .columns = if (.cbind) names(.data) else NULL)
\method{transmute}{pipe}(.data, \dots, .cbind = FALSE, .columns = NULL, .mergeable = FALSE)
}
\arguments{
  \item{.data}{A data set represented by a pipe or a data.frame}
  \item{\dots}{Additional arguments interpreted as columns}
  \item{.cond}{Expression to evaluate to logical and used to transmute rows of the data}
  \item{.cbind}{whether to cbind new columns}
  \item{.columns}{data columns to keep, as a character vector of names}
  \item{.mergeable}{whether the transmutation described by a certain call to \code{transmute} satisfies the properties of mergeability see \code{\link{mergeable}}}
}
\details{
\describe{
\item{\code{transmute}}{generalizes the functionality of \code{\link[base:transform]{base::transform}} and \code{\link[plyr:summarize]{plyr::summarize}}, to express general data transformation, including the common case of multi-row summaries, such as quantiles. When argument \code{.cbind} is \code{FALSE}, the default, the first argument columns are discarded and the ones defined in the \dots arguments are used to form a new data frame. In this case the number of rows returned can be different from the number of rows in the \code{.data} argument, subsuming the capabilities of both Hive's UDTF and \code{\link[plyr:summarize]{plyr::summarize}}, that is expansion or reduction of the output as compared to the input. When \code{.cbind} is \code{TRUE} the behavior is more like \code{transform} and the numbers of rows returned remains the same as in \code{.data}. Recycling rules are applied to the \dots arguments. Fractional recycling, when the longest argument length is not an integer multiple of the others, is allowed but triggers a warning.}
\item{\code{bind.cols}}{is just a shortcut for \code{transmute} with \code{.cbind} set to TRUE, but it's an  important enough special case to deserve its own name.}
\item{\code{select}}{is a direct big data equivalent of \code{\link[dplyr:select]{dplyr::select}}; see that function for details.}
\item{\code{where}}{focuses only on the selection of rows, not columns.}}
All functions have methods for data frames and pipes. These functions are more usable for programming than their equivalents in \link{base} and \link{plyr}. See \file{tests/non-standard-eval.R} for examples of \code{transmute} and \code{where} working in contexts where the other functions don't. For \code{transmute}, \code{bind.cols} and \code{where} the \dots and \code{.cond} arguments are evaluated accoding to \link{non standard evaluation} rules. \code{select} follows different rules that are specialized for selection, see \code{\link[dplyr:select]{dplyr::select}}
}
\value{The same type as the first argument, either a data frame or a pipe.}
\examples{
#data.frame
where(mtcars, cyl>4 & mpg > 15)
#pipe
as.data.frame(where(input(mtcars), cyl > 4 & mpg > 15))
# select two columns
as.data.frame(transmute(input(mtcars), cyl, mpg))
# create additional column
as.data.frame(transmute(input(mtcars), ratio = cyl/mpg, .cbind = TRUE))
# summaries
as.data.frame(transmute(input(mtcars), mean(cyl), mean(mpg)))
# summaries by groups
as.data.frame(transmute(group(input(mtcars), cyl), mean(mpg)))
}
