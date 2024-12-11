#A R script for reformating the ZZ output Wenner files into Res2D format

#Version 1.1 
#Updated 11/12/2024 to remove the Rosner's Test option and to include topography

#Before running this script you need to output the Wenner INP file using the ZZ Rdatacheck software.
#It is recommended to tick the "Output all data(no filter)" option and then press "Output INP File button"

#Read in INV file preserving file structure and deleting the first 74 lines (Default is ALine-1_IV_inv_Wenner.inp)
wenner<- read.table("ALine-1_IV_inv_Wenner.inp",skip = 75, header = FALSE)

#FORMAT THE DATA This section changes the ZZ data output into Res2D format

#Define the electrode spacing, you need to enter the value below (default is 0.5)
Elect <- 0.5

#Define the file name, you need to enter the value below (default is A Line Wenner)
Name <- "A Line Wenner"

#Remove the unnecessary columns
wenner<-wenner[-c(6:8)]

#Add the extra columns required for Res2D format, run each line one at a time
wenner$V6 <- 4
wenner$V7 <- (wenner$V1 * Elect - Elect)
wenner$V8 <- 0
wenner$V9 <- (wenner$V2 * Elect - Elect)
wenner$V10 <- 0
wenner$V11 <- (wenner$V3 * Elect - Elect)
wenner$V12 <- 0
wenner$V13 <- (wenner$V4 * Elect - Elect)
wenner$V14 <- 0

#Remove the unnecessary additional columns
wenner<-wenner[-c(1:4)]

#Move the resistance column to the end
wenner <- wenner[c("V6", "V7", "V8", "V9", "V10", "V11", "V12", "V13", "V14", "V5")]

#VISUALIZE AND FILTER This section allows you to filter out the large and small values that can make inverstions unstable

#Create a Histogram to see the distribution of data values
hist(wenner$V5, breaks=20)

#What are the 10 minimum resistivity values?
head(sort(wenner$V5),10)

#What are the 10 maximum resistivity values?
tail(sort(wenner$V5),10)

#Having chosen which values you want to remove, remove all rows with a data value greater than a value (default is 100)
wenner <- subset(wenner, V5 < 100)

#Having chosen which values you want to remove, remove all rows with a data value less than a value (default is 2)
wenner <- subset(wenner, V5 > 2)

#OUTPUTTING THE RES2D File

#Count the number of data rows in the file
Rows <- nrow(wenner)

#Creating a TxT file in Res2D format with the Original File Name
printer1<- file(Name,"w")
write(sprintf(Name), printer1, append=TRUE) 
write(Elect,printer1,append=TRUE)
write("11",printer1,append=TRUE)
write("1",printer1,append=TRUE)
write("Type of Measurment",printer1,append=TRUE)
write("1",printer1,append=TRUE)
write(Rows,printer1,append=TRUE)
write("1",printer1,append=TRUE)
write("0",printer1,append=TRUE)
write.table(wenner,printer1, append = TRUE, sep = "        ", row.names = FALSE, col.names = FALSE)
#Only run rows 75-78 if you want to include topography values in the output
write("Topography in separate list",printer1,append=TRUE)
write("1",printer1,append=TRUE)
write("64",printer1,append=TRUE)
write("0, ",printer1,append=TRUE)
close(printer1)

