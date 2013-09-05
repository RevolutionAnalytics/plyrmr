\name{where}
\alias{where}
\alias{select}
\title{
Functions to perform sql-like operations on data frames and pipes.
}
\description{
These functions accept a data set, represented by a pipe or a data frame, and apply the operations specified by the other arguments, which are evaluated according to non standard evaluation rules.
where allows to select or filter a subset of the rows. Additional arguments should evaluate to logical or numeric and are used as row indexes. In the case of logical, they logical and of the arguments is the overall filter. In the case of numeric, a single \dots arguments should be specified. Normal recycling rules apply. select allows to select or generate new columns from a data set. Additional arguments become columns of the new data set and normal recycling rules apply. In the method for pipes, for both functions, additional arguments are evaluated for each group of the pipe.
}
\usage{
where(.data, \dots)
\method{where}{data.frame}(.data, \dots, .envir = parent.frame())
\method{where}{pipe}(.data, \dots, .envir = parent.frame())
select(.data, \dots)
\method{select}{data.frame}(.data, \dots, .replace = TRUE, .envir = parent.frame())
\method{select}{pipe}(.data, \dots, .replace = TRUE, .envir = parent.frame())
}
\arguments{
  \item{.data}{A data set represented by a pipe}
  \item{\dots}{Additional arguments interpreted as filtering criteria by where and data columns by select}
  \item{.replace}{whether to replace}
  \item{.envir}{environment in which to evaluate the \dots arguments}
}
\details{
select may be more powerful  than its name suggests. It can perform filtering but also aggregation, and the aggregation, unlike plyr::summarize, doesn't have to result in a single row per group. where and select are more appropriate for programming then they base and plyr equivalent, transform, subset, mutate and summarize, because of the additional .envir argument which allows to specify an evaluation environment different from that of the caller. See tests/non-standard-eval.R for examples of select and where working in contexts where the other functions don't.
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
