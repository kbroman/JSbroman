set.seed(59173720)
dat <- data.frame(x=rnorm(100), y=rnorm(100), z=sample(1:3, 100, repl=TRUE))
dat[,2] <- 2*dat[,1]*dat[,3] + dat[,2]

library(RJSONIO)
cat( toJSON(apply(dat, 1, as.list)), file="dat.json")
