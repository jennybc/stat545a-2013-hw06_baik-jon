options(rstudio.markdownToHTML = function(inputFile, outputFile) {
     require(markdown)
     require(stringr)
     
     ## make easy to toggle base64 encoding of images and perhaps other things ...
     htmlOptions <- markdownHTMLOptions(defaults = TRUE)
     ## htmlOptions <- htmlOptions[htmlOptions != 'base64_images']
     
     ## you must customize for where YOU store CSS
     if(str_detect(version$os, "darwin")) {
      # Mac
      pathToCSS <-  "~/Dropbox/"
     } else {
      # Windows
      pathToCSS <- "C:/Users/Jonathan/Dropbox/"
     }
     
     pathToCSS <- paste0(pathToCSS, "School/Grad/STAT545A/stat545a-hw06/",
                         "stat545a-2013-hw06_baik-jon/",
                         "css/jasonm23-markdown-css-themes/markdown7.css")
     
     markdownToHTML(inputFile, outputFile, options = htmlOptions, 
                    stylesheet = pathToCSS)
 })

options(rpubs.upload.method = "internal")