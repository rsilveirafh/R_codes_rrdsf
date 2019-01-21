#A for loop in R to do an ANOVA or Kruskall-Wallis depending 
#on the normality (shapiro.test) and homocedasticity (bartlett.test)

#Banco de dados - armazenar em um dataframe chamado "spp"
spp <- read.csv("arquivo.csv", h=T, sep=";")
#Anexar "spp"
attach(spp)
#Variaveis nas colunas, amostras nas linhas
#Em "imod", "imod2" e "barl", mudar a variavel preditora (neste caso, tipo_cerrado)

for (i in names(spp[-1])){
	shap <- shapiro.test(spp[[i]])
	barl <- bartlett.test(spp[[i]], tipo_cerrado)
	cat(paste('\n############################\n'))
	cat(paste('\nShapiro de:', i, '\n'))
	print(shap)
	cat(paste('\nBartlett de:', i, '\n'))
	print(barl)
	fshap <- format(shap$p.value, scientific=FALSE)
	barl <- format(barl$p.value, scientific=FALSE)
	if (fshap < 0.05 & barl < 0.05){
		imod <- summary(aov(spp[[i]] ~ tipo_cerrado))
		cat(paste('\nANOVA de:', i, '\n'))
		print(imod)
	}else{
		imod2 <- kruskal.test(spp[[i]] ~ tipo_cerrado)
		cat(paste('\nKruskal Test de:', i, '\n'))
		print(imod2)
	}
	
}
