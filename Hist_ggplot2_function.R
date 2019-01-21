library(ggplot2)
#funcao para plotar histogramas com a curva de densidade kernel, salvando o pdf
plotHist <- function(x, na.rm = TRUE) {
   nm <- names(x)
   for (i in seq_along(nm)) {
      p <- ggplot(x, aes_string(x = nm[i])) +
         geom_density(alpha = .2, fill = "#FF6666")
      pdf(paste0("Hist", i, "_",nm[i], ".pdf"))
      print(p)
      dev.off()
   }
}

#rodando a funcao
plotHist(x)
