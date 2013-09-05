\name{moving.window}
\alias{moving.window}
\title{
Compute a function on a moving window of the data.
}
\description{
}
\usage{
moving.window(x, index, window, R = rmr.options("keyval.length"))
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
  \item{R}{
Only for performance, size of the reduce size groups, see details
}
}
\details{

}
\value{
A pipe with the results of applying f to each window}
\examples{
as.data.frame(
  do(
    moving.window(
      input(data.frame(t= 1:20)), 
      "t", 
      3), 
    function(x) 
      if(nrow(x) >= 3) 
        list(t = filter(x$t, rep(1/3,3)))))
}
