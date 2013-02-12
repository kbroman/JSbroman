# Simulate genotype and phenotype data and write to JSON file

library(qtl)

set.seed(29231551)
n.mar <- 11
map <- sim.map(100, n.mar, anchor.tel=TRUE, include.x=FALSE, eq.spacing=TRUE)
names(map[[1]]) <- paste0("M", 1:n.mar)

x <- sim.cross(map, type="f2", n.ind=100, model=c(1, 25, 1, 0.5))

gnames <- qtl:::getgenonames(class(x)[1], class(x$geno[[1]]), "full", getsex(x), attributes(x))


# write data to JSON file
library(RJSONIO)
cat0 <- function(...) cat(..., sep="", file="data.json")
cat0a <- function(...) cat(..., sep="", file="data.json", append=TRUE)
cat0("{\n\"markers\" : ", toJSON(markernames(x)), ",\n\n")
cat0a("\"pheno\" :\n", toJSON(x$pheno[,1], digits=8), ",\n\n")
cat0a("\"genonames\" :\n", toJSON(gnames), ",\n\n")
cat0a("\"geno\" :\n", toJSON(pull.geno(x)), "\n\n")
cat0a("}\n")
