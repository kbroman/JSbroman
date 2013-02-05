# Convert data for hypo expression arrays to JSON file with
#   - quantiles for boxplot-like figure
#   - counts for histograms

load("~/Projects/Attie/GoldStandard/Expression/MLRatios/F2.mlratio.hypo.RData")
# hypo.mlratio is dimension 40572 (transcripts) x 494 (mice)

# calculate quantiles
qu <- c(0.01, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.999)
quant <- apply(hypo.mlratio, 2, quantile, qu, na.rm=TRUE)
ord <- rev(order(quant[5,])) # ordered array indices, by array medians

## the many boxplots figure
#plot(quant[5,o], type="l", lwd=2, ylim=c(-1, 1))
#for(i in 1:4) {
#  lines(quant[i,o], col=c("blue", "green", "red", "orange")[i])
#  lines(quant[10-i,o], col=c("blue", "green", "red", "orange")[i])
#}

## a portion of the boxplots
#boxplot(hypo.mlratio[,o[seq(1, length(o), by=5)]], outline=FALSE, las=2)

# counts for histograms
br <- seq(-2, 2, len=201)
counts <- apply(hypo.mlratio, 2, function(a) hist(a, breaks=br, plot=FALSE)$counts)

mice <- colnames(hypo.mlratio)
mice.ordered <- mice[o]

# write data to JSON file
library(RJSONIO)
cat0 <- function(...) cat(..., sep="", file="../hypo.json")
cat0a <- function(...) cat(..., sep="", file="../hypo.json", append=TRUE)
cat0("// hypo data summaries\n\n")
cat0a("// mice, ordered by median expression\n")
cat0a("ind = \n", toJSON(mice.ordered), "\n\n")
cat0a("// values at which quantiles calculated\n", "qu =\n", toJSON(qu), "\n\n")
cat0a("// histogram breaks\n", "br =\n", toJSON(br), "\n\n")
cat0a("// quantiles\n", "quant =\n", toJSON(quant), "\n\n")
cat0a("// histogram counts\n", "counts =\n", toJSON(counts), "\n")
