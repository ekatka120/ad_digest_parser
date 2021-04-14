install.packages(c("RSelenium", "rvest"))
library("RSelenium")
library("rvest")

#получение сайтов, которые я буду парсить
driver <- rsDriver(browser=c("chrome"), chromever = '87.0.4280.20')
remote_driver <- driver[["client"]]
remote_driver$open()
remote_driver$navigate("https://www.admagazine.ru/adlist/")
for (i in 1:25)
{
  webElem <- remote_driver$findElement("css", "body")
  webElem$sendKeysToElement(list(key = "end"))
}
ad_html <- remote_driver$getPageSource()[[1]]
ad <- read_html(ad_html)
remote_driver$close()

res <- ad %>% html_nodes(xpath='//a[@class="link link--dark valign-middle"]')
links <- html_attr(res, "href")
urls = paste0("https://www.admagazine.ru", links, "#/")

#массивы, для создания дата фрейма
names = c()
phones = c()
emails = c()
websites = c()
instagrams = c()
facebooks = c()

#последовательный парсинг отдельных страниц
for (x in 1:length(urls))
{
  phone = NA
  email = NA
  name = NA
  website = NA
  instagram = NA
  facebook = NA
  url_des = urls[x]
  des = read_html(url_des)
  des_res <- des %>%
    html_nodes(xpath='//div[@class="col-12 col-12--12 col-12--md-6 col-12--lg-12 col-12--xl-6"]') %>%
    html_nodes(xpath='div')
  name <- des %>% html_nodes(xpath='//div[@class="article__top"]') %>%
    html_nodes(xpath='h1') %>%
    html_text()
  for (i in 1:length(des_res))
  {
    info <- des_res[i] %>% html_nodes(xpath='div/svg/use')
    type_of_info <- html_attr(info, name = "xlink:href")
    info <- des_res[i] %>% html_nodes(xpath='div/a')
    req_info <- html_text(info)
    if (type_of_info == "#phone")
      phone = req_info
    if (type_of_info == "#mail")
      email = req_info  
    if (type_of_info == "#globe")
      website = req_info
    if (type_of_info == "#inst")
      instagram = req_info
    if (type_of_info == "#fb")
      facebook = req_info
  }
  names = c(names, name)
  phones = c(phones, phone)
  emails = c(emails, email)
  websites = c(websites, website)
  instagrams = c(instagrams, instagram)
  facebooks = c(facebooks, facebook)
}

df = data.frame(NAME = names, PHONE = phones, EMAILS = emails,
                WEBSITES = websites, INSTAGRAM = instagrams,
                FACEBOOKS = facebooks)
#результирующая таблица 
df