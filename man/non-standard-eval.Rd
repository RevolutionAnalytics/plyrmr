\name{non standard evaluation}
\alias{non standard evaluation}
\title{Non standard evaluation for \dots arguments}
\description{Several functions accepting a data set, represented by a pipe or a data frame, followed by \dots arguments do not evaluate the latter according to the normal rules of the R language but in an environment that includes the variables contained in the data set itself. By default, the parent of this environemnt is the local environment where the function is called, but, whenever a .envir argument is present, this can be specified by the user, for example for where and select. The latter feature may not be of much use in interactive R session but is necessary for programming. Other types of non standard evaluation exist, such as for the select argument of subset, please see the manual for base::subset for details}
\examples{
t = 4
as.data.frame(where(input(mtcars), cyl > t))
# t from the caller environment, cyl from the data
}