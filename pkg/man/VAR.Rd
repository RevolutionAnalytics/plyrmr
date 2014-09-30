\name{VAR}
\alias{VAR}
\title{
Helper to create R expression dynamically based on the content of variables.
}
\description{
Create expressions based on the contents of integer and character variables, specifically referring to data.frame columns by name or position. 
}
\usage{
VAR(x)
}
\arguments{
  \item{x}{The name of a columns as a character string of length 1 or the position of a column as integer vector also of length 1.}}
  
\details{
It's convenient to write simple data.frame transformation as \code{bind.cols(mtcars, z = mpg/carb)} but hard to generalize. For instance, what if we wanted to use this expression inside another function that takes the names of the two columsn to operate on as arguments? \code{VAR} helps with that allowing to write expressions such as \code{bind.cols(mtcars, z = VAR(name.1)/VAR(name.2))}. It also works with the column position as an integer. 
}
\value{
The value is an implmentation detail as this function should only be used while specifying arguments for \code{bind.cols}, \code{transmute} and other functions in \code{plyrmr} taking expressions as arguments.
}
\examples{
head(bind.cols(mtcars, z = VAR(1)/2))
head(bind.cols(mtcars, z = VAR("carb")/2))}
