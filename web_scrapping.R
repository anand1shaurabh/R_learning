# This is an example script for web scrapping. I used this to download COVID-19 bulletins in PDF.

# loading packages 

library(rvest)
library(stringr)
library(stringr)   
library(XML)
library(rvest)
library(tidyverse)

#read base page for daily bulletins
kl<-read_html("http://dhs.kerala.gov.in/%e0%b4%a1%e0%b5%86%e0%b4%af%e0%b4%bf%e0%b4%b2%e0%b4%bf-%e0%b4%ac%e0%b5%81%e0%b4%b3%e0%b5%8d%e0%b4%b3%e0%b4%b1%e0%b5%8d%e0%b4%b1%e0%b4%bf%e0%b4%a8%e0%b5%8d%e2%80%8d/")

#collect all the links present on base page
kl_url<- kl %>% 
  html_nodes("a") %>% 
  html_attr("href")
kl_url<-as.data.frame(kl_url)    
View(kl_url)

#subset only for bulletin links 
kl_url_cleaned<-kl_url[77:289,]
View(kl_url_cleaned)

#appendng base home page to the url links
kl_url_cleaned2<-c()
for(i in kl_url_cleaned){
  value<-paste("http://dhs.kerala.gov.in",i, sep = "")
  kl_url_cleaned2<-append(kl_url_cleaned2, value)
}

kl_url_cleaned3<-as.data.frame(kl_url_cleaned2)
colnames(kl_url_cleaned3)<-c("baseurl")
View(kl_url_cleaned3)

# extracting the report date and adding to it to the data frame
#created fresh data frame becuase "mutate" did not function
reportdate<- c()
for (i in baseurl){ 
 temp<-str_replace(substr(i, nchar(i)-(9+1),
                           nchar(i)),"/", "" )
  reportdate<-append(reportdate, temp)}

reportdate<-as.data.frame(reportdate)

kl_url_cleaned4<-cbind(kl_url_cleaned3,reportdate)
View(kl_url_cleaned4)


#create a list of all pdf links on the site
all.pdf.url<-c()
for(i in kl_url_cleaned4$baseurl){
  doc.html <- htmlParse(i)
  doc.links <- xpathSApply(doc.html, "//a/@href")
  pdf.url <- as.character(doc.links[grep('pdf', doc.links)])
  all.pdf.url<-append(all.pdf.url,pdf.url)
}

all.pdf.url_mod<-as.data.frame(all.pdf.url) #all pdf url
all.pdf.url_mod<-all.pdf.url_mod[312:425,] # second lot, subset of all pdf url due to change in lenght of file names

#downloading pdf first lot, clear variable j before runing
for (j in all.pdf.url){
  download.file(paste("http://dhs.kerala.gov.in",j, sep=""),
                substr(j, nchar(j)-(19+1),nchar(j)) , 
                    method = 'auto', quiet = FALSE, mode = "wb")
}  

#vdownloading pdf second lot, clear variable j before runing 
for (j in all.pdf.url){
  download.file(paste("http://dhs.kerala.gov.in",j, sep=""),
                substr(j, nchar(j)-(14+1),nchar(j)) , 
                method = 'auto', quiet = FALSE, mode = "wb")
}