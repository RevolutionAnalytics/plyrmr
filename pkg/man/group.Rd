\name{group}
\alias{group}
\alias{group.f}
\alias{gather}
\alias{ungroup}
\alias{is.grouped}

\title{Control grouping of data sets}
\description{
A data set in \code{plyrmr} , as represented by a pipe, is always grouped in one way or another. This means  that every computation acting on a pipe, acts on a subset of the data at a time. By contolling the group definition, we can implement complex algorithms while never loading all data into main memory, which wouldn't be feasible. The functions documented here allow to do that in \code{\link{plyrmr}}.
}
\usage{
group(.data, \dots)
group.f(.data, .f, \dots)
gather(.data)
ungroup(.data, ...)
is.grouped(.data)
}
\arguments{
  \item{.data}{A data sets represented by a pipe.}
  \item{.f}{Function with data frame argument and value}
  \item{\dots}{For \code{group.f}, additional arguments to \code{f}; for \code{group}, expressions that define grouping, such as column names (these are evaluated according to \link{non standard evaluation} rules); for \code{ungroup}, columns to remove from the grouping definition}
  \item{.envir}{environment in which to evaluate \dots arguments}
}

\details{\code{group} is inspired by the SQL \code{GROUP BY} statement and is analogous but not identical to \code{dplyr:::group_by}. In its simplest form, it allows to select some columns or variables to define the grouping, specified as \dots arguments. This means all rows sharing the same values for the grouping columns become part of the same group. The next step in complexity is grouping by R expressions, also specified as \dots arguments and evaluated according to \link{non standard evaluation} rules. An additional level in flexibility is offered by \code{group.f}, which allows to compute the grouping columns in a general R function that is only restricted to accept and return a data frame. \code{gather} is a shorthand for \code{group(data, constant)} which implies that all data should belong to single group. Multiple grouping operations applied to the same data set accumulate in the sense that each grouping is seen as a refinement of the existing one (this is a major departure from the equivalent SQL operation). Therefore \code{group(group(input(mtcars), cyl), mpg)} is equivalent to \code{group(input(mtcars), cyl, mpg)}. \code{ungroup} with no additional arguments resets the grouping to the initial state, which is of arbitrary grouping (arbitrary grouping is best for performance). \code{is.grouped} tests if a data set is already grouped in any way other than arbitrary grouping.}

\value{A data set represented by a pipe for all but \code{is.grouped}, which return a \code{logical}, where \code{FALSE} stands for arbitrary grouping}

\examples{
as.data.frame(
  transmute(
    group(
      input(mtcars), 
      cyl), 
    mean(mpg)))
    
as.data.frame(
  transmute(
    group.f(
      input(mtcars), 
      function(x) x$cyl), 
    mean(mpg)))
   
as.data.frame(
  gapply(
    gather(
      input(mtcars)),
    mergeable(function(x) t(colSums(x)))))
}
