#An R script for reformating the ZZ output Dipole-Dipole files into Res2D format

#Before running this script you need to output the Dipole-Dipole INP file using the ZZ Rdatacheck software.
#It is recommended to tick the "Output all data(no filter)" option and then press "Output INP File button"

#Read in INV file preserving file structure and deleting the first 74 lines (Default is ALine-1_IV_inv_Dpdp.inp)
DD<- read.table("ALine-1_IV_inv_Dpdp.inp",skip = 75, header = FALSE)

#FORMAT THE DATA This section changes the ZZ data output into Res2D format

#Define the electrode spacing, you need to enter the value below (default is 0.5)
Elect <- 0.5

#Define the file name, you need to enter the value below (default is A Line DD)
Name <- "A Line DD"

#Remove the unnecessary columns
DD<-DD[-c(6:8)]

#Add the extra columns required for Res2D format, run each line one at a time
DD$V6 <- 4
DD$V7 <- (DD$V1 * Elect - Elect)
DD$V8 <- 0
DD$V9 <- (DD$V2 * Elect - Elect)
DD$V10 <- 0
DD$V11 <- (DD$V3 * Elect - Elect)
DD$V12 <- 0
DD$V13 <- (DD$V4 * Elect - Elect)
DD$V14 <- 0

#Remove the unnecessary additional columns
DD<-DD[-c(1:4)]

#Move the resistance column to the end
DD <- DD[c("V6", "V7", "V8", "V9", "V10", "V11", "V12", "V13", "V14", "V5")]

#VISUALIZE AND FILTER This section allows you to filter out the large and small values that can make inverstions unstable

#Create a Histogram to see the distribution of data values
hist(DD$V5, breaks=20)

#What are the 10 most negative resistivity values?
head(sort(DD$V5),10)

#What are the 10 least negative resistivity values?
tail(sort(DD$V5),10)

#OPTIONAL STEP Use Rosner's test (Which assumes a Gaussian distribution so may not be valid) to identify outliers

#Install the EnvStats Package
install.packages("EnvStats")

#Open the EnvStates Library
library(EnvStats)

#Perform the Rosner's Test to see which of the 10 extreme values are outliers. Any values that return the result "True" in the outlier column should be deleted
Rosner <- rosnerTest(DD$V5, k = 10)
Rosner

#Having chosen which values you want to remove, remove all rows with a data value greater than a value (default is -100)
DD <- subset(DD, V5 > -100)

#Having chosen which values you want to remove, remove all rows with a data value less than a value (default is -2)
DD <- subset(DD, V5 < -02)

#OUTPUTTING THE RES2D File

#Count the number of data rows in the file
Rows <- nrow(DD)

#Creating a TxT file in Res2D format with the Original File Name
printer1<- file(Name,"w")
write(sprintf(Name), printer1, append=TRUE) 
write(Elect,printer1,append=TRUE)
write("11",printer1,append=TRUE)
write("3",printer1,append=TRUE)
write("Type of Measurment",printer1,append=TRUE)
write("1",printer1,append=TRUE)
write(Rows,printer1,append=TRUE)
write("1",printer1,append=TRUE)
write("0",printer1,append=TRUE)
write.table(DD,printer1, append = TRUE, sep = "        ", row.names = FALSE, col.names = FALSE)
close(printer1)
