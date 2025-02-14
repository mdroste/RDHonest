#' Class Constructor for \code{"RDData"}
#'
#' Convert data to a standardized format for use with low-level functions. If
#' the cutoff for treatment is non-zero, shift the running variable so that the
#' cutoff is at zero.
#' @param d a data frame or a list with first column corresponding to the
#'     outcome variable, second column corresponding to the running variable and
#'     optionally a column called \code{"sigma2"} that corresponds to the
#'     conditional variance of the outcome (or an estimate of the conditional
#'     variance)
#' @param cutoff specifies the cutoff for the running variable
#' @return An object of class \code{"RDData"}, which is a list containing the
#'     following components:
#'
#'     \describe{
#'
#'     \item{Ym}{Outcome vector for observations below cutoff}
#'
#'     \item{Yp}{Outcome vector for observations above cutoff}
#'
#'     \item{Xm}{Running variable for observations below cutoff}
#'
#'     \item{Xp}{Running variable for observations above cutoff}
#'
#'     \item{sigma2m}{Conditional variance of the outcome for observations below
#'     cutoff}
#'
#'     \item{sigma2p}{Conditional variance of the outcome for observations above
#'     cutoff}
#'
#'     \item{orig.cutoff}{Original cutoff}
#'
#'     \item{var.names}{Names of the outcome and the running variable in
#'     supplied data frame}
#'
#'     }
#' @seealso \code{\link{FRDData}} for fuzzy RD, and \code{\link{LPPData}} for
#'     inference at a point
#' @examples
#' ## Transform Lee data
#' d <- RDData(lee08, cutoff=0)
#' @export
RDData <- function(d, cutoff) {

    if(is.unsorted(d[[2]]))
        d <- d[sort(d[[2]], index.return=TRUE)$ix, ]

    X <- d[[2]] - cutoff
    df <- list(Ym=d[[1]][X<0], Yp=d[[1]][X>=0], Xm=X[X<0], Xp=X[X>=0],
               orig.cutoff=cutoff, var.names=names(d)[1:2])
    df$sigma2m <- d$sigma2[X<0]
    df$sigma2p <- d$sigma2[X>=0]

    structure(df, class="RDData")
}


#' Class Constructor for \code{"FRDData"}
#'
#' Convert data to a standardized format for use with low-level functions. If
#' the cutoff for treatment is non-zero, shift the running variable so that the
#' cutoff is at zero.
#' @param d list with first element corresponding to the outcome vector, second
#'     element to the treatment vector, third element to running variable
#'     vector, and optionally an element called \code{"sigma2"} that is a matrix
#'     with four columns corresponding to the \code{[1, 1]}, \code{[1, 2]},
#'     \code{[2, 1]}, and \code{[2, 2]} elements of the conditional variance
#'     matrix of the outcome and the treatment (or an estimate of the
#'     conditional variance matrix)
#' @param cutoff specifies the cutoff for the running variable
#' @return An object of class \code{"FRDData"}, which is a list containing the
#'     following components:
#'
#'     \describe{
#'
#'     \item{Ym}{Matrix of outcomes and treatments for observations below
#'     cutoff}
#'
#'     \item{Yp}{Matrix of outcomes and treatments for observations above
#'     cutoff}
#'
#'     \item{Xm}{Running variable for observations below cutoff}
#'
#'     \item{Xp}{Running variable for observations above cutoff}
#'
#'     \item{sigma2m}{Matrix of conditional covariances for the outcome and the
#'     treatment for observations below cutoff}
#'
#'     \item{sigma2p}{Matrix of conditional covariances for the outcome and the
#'     treatment for observations above cutoff}
#'
#'     \item{orig.cutoff}{Original cutoff}
#'
#'     \item{var.names}{Names of the outcome, the treatment, and the running
#'     variable in supplied data frame}
#'
#'     }
#' @seealso \code{\link{RDData}} for sharp RD, and \code{\link{LPPData}} for
#'     inference at a point
#' @examples
#' ## Transform retirement data
#' d <- FRDData(rcp[, c(6, 3, 2)], cutoff=0)
#' ## Outcome in logs
#' d <- FRDData(cbind(logcn=log(rcp[, 6]), rcp[, c(3, 2)]), cutoff=0)
#' @export
FRDData <- function(d, cutoff) {
    if(is.unsorted(d[[3]]))
        d <- d[sort(d[[3]], index.return=TRUE)$ix, ]
    X <- d[[3]] - cutoff
    df <- list(Ym=cbind(d[[1]][X<0], d[[2]][X<0]),
               Yp=cbind(d[[1]][X>=0], d[[2]][X>=0]),
               Xm=X[X<0], Xp=X[X>=0], orig.cutoff=cutoff,
               var.names=names(d)[1:3])

    df$sigma2m <- d$sigma2[X<0, ]
    df$sigma2p <- d$sigma2[X>=0, ]

    structure(df, class="FRDData")
}


#' Class Constructor for \code{"LPPData"}
#'
#' Convert data to standardized format for use with low-level functions. If the
#' point of interest \eqn{x_0} is non-zero, shift the independent variable so
#' that it is at zero.
#' @param d a data frame or a list with first column corresponding to the
#'     outcome variable, second column corresponding to the independent variable
#'     and optionally a column called \code{"sigma2"} that corresponds to the
#'     conditional variance of the outcome (or an estimate of the conditional
#'     variance)
#' @param point specifies the point \eqn{x_0} at which to calculate the
#'     conditional mean
#' @return An object of class \code{"LPPData"}, which is a list containing the
#'     following components:
#'
#'     \describe{
#'
#'     \item{Y}{Outcome vector}
#'
#'     \item{X}{Independent variable}
#'
#'     \item{sigma2}{Conditional variance of the outcome}
#'
#'     \item{orig.point}{Original value of \eqn{x_0}}
#'
#'     \item{var.names}{Names of outcome and independent variable in supplied
#'     data frame}
#'
#'     }
#' @seealso \code{\link{FRDData}} for fuzzy RD, and \code{\link{RDData}} for
#'     sharp RD
#' @examples
#' ## Transform Lee data
#' d1 <- LPPData(lee08[lee08$margin>=0, ], point=0)
#' d2 <- LPPData(lee08, point=50)
#' @export
LPPData <- function(d, point) {

    if(is.unsorted(d[[2]]))
        d <- d[sort(d[[2]], index.return=TRUE)$ix, ]

    df <- list(Y=d[[1]], X=d[[2]] - point,
               orig.point=point, var.names=names(d)[1:2])
    df$sigma2 <- d$sigma2

    structure(df, class="LPPData")
}



## Find interval containing zero of a function, then find the zero
## Search an interval for a root of \code{f},
## @param f function whose root we're looking for
## @param ival upper endpoint of initial interval in which to search
## @param negative logical: should the lower endpoint be \code{1/ival} (if the
##     root is guaranteed to be positive), or \code{-ival}?
FindZero <- function(f, ival=1.1, negative=TRUE) {
    minval <- function(ival) if (negative==TRUE) -ival else min(1/ival, 1e-3)

    while(sign(f(ival))==sign(f(minval(ival))))
            ival <- 2*ival
    stats::uniroot(f, c(minval(ival), ival), tol=.Machine$double.eps^0.75)$root
}



## check class of object
CheckClass <- function(x, class)
    if(!inherits(x, class)) stop(paste0("Object ", deparse(substitute(x)),
                                        " needs to be class ", class, "!"))


## Modified golden section for unimodal piecewise constant function
gss <- function(f, xs) {
    gr <- (sqrt(5) + 1) / 2
    a <- 1
    b <- length(xs)
    c <- round(b - (b - a) / gr)
    d <- round(a + (b - a) / gr)

    while (b - a > 100) {
        if (f(xs[c]) < f(xs[d])) {
            b <- d
        } else {
            a <- c
        }

        # recompute both c and d
        c <- round(b - (b - a) / gr)
        d <- round(a + (b - a) / gr)
    }

    supp <- xs[a:b]
    supp[which.min(vapply(supp, f, numeric(1)))]
}


## ## Split function into k bits and optimize on each bit in case not convex
## CarefulOptim <- function(f, interval, k=10) {
##     ## intervals
##     s <- seq(interval[1], interval[2], length.out=k+1)
##     s <- matrix(c(s[-length(s)], s[-1]), ncol=2)

##     obj <- rep(0, k)
##     arg <- rep(0, k)
##     for (j in 1:k){
##         r <- stats::optimize(f, s[j, ])
##         arg[j] <- r$minimum
##         obj[j] <- r$objective
##     }
##     jopt <- which.min(obj)
##     list(objective=obj[jopt], minimum=arg[jopt])
## }
