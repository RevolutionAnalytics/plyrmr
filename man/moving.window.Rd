\name{moving.window}
\alias{moving.window}
\title{
Compute a function on a moving window of the data.
}
\usage{
moving.window(x, index, window, f, R = rmr.options("keyval.length"))
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
A pipe
}
  \item{index}{
How to sort the data (time dimension or other total order on the records)
}
  \item{window}{
Size of the window}
  \item{f}{
Function to compute on the window (takes and returns a data frame)}
  \item{R}{
Only for performance, size of the reduce size groups, see details
}
}
\details{

}
\value{
A pipe with the results of applying f to each window}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

}
