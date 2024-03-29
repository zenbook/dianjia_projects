# X-MOOM数据处理
# 由于使用了for循环，处理效率较低，需花费较长时间

# 加载包
library(tidyverse)
library(lubridate)

# 加载数据 ============================================================

## 2013-2015销售额
sale_2013_2015 <- read.table(file = "E:/dianjia/project_data/xmoom/sale_2013_2015.csv",
                             header = TRUE, 
                             sep = ',', 
                             stringsAsFactors = FALSE)

## 2016销售额
sale_2016 <- read.table(file = "E:/dianjia/project_data/xmoom/sale_2016.csv",
                        header = TRUE, 
                        sep = ',', 
                        stringsAsFactors = FALSE)

## 2017销售额
sale_2017 <- read.table(file = "E:/dianjia/project_data/xmoom/sale_2017.csv",
                        header = TRUE, 
                        sep = ',', 
                        stringsAsFactors = FALSE)

## 2018Q1销售额
sale_2018_q1 <- read.table(file = "./sale_2018q1.txt",
                           header = TRUE,
                           sep = '\t',
                           fileEncoding = "utf-16",
                           stringsAsFactors = FALSE)

## union 2013-2017的5年数据
sale_2013_2017 <- sale_2013_2015 %>% 
  rbind(sale_2016) %>% 
  rbind(sale_2017)



### skc销售和库存数据
## 2016销售额
skc_sale_2016 <- read.table(file = "E:/dianjia/project_data/xmoom/skc_sale_2016.csv",
                             header = TRUE, 
                             sep = ',', 
                             stringsAsFactors = FALSE)

## 2017销售额
skc_sale_2017 <- read.table(file = "E:/dianjia/project_data/xmoom/skc_sale_2017.csv",
                            header = TRUE, 
                            sep = ',', 
                            stringsAsFactors = FALSE)
## 201801—201802销售额
skc_sale_201801_201802 <- read.table(file = "E:/dianjia/project_data/xmoom/skc_sale_201801_201802.csv",
                        header = TRUE, 
                        sep = ',', 
                        stringsAsFactors = FALSE)
## 销售数据合并到一张表
skc_sale_2016_201802 <- skc_sale_2016 %>% 
  rbind(skc_sale_2017) %>% 
  rbind(skc_sale_201801_201802)
skc_sale_2016_201802$日期 <- as.Date(skc_sale_2016_201802$日期)


write.csv(skc_sale_2016_201802, 
          file = 'E:/dianjia/project_data/xmoom/skc_sale_2016_201802.csv', 
          row.names = FALSE)

## 20170228库存
skc_stock_20170228 <- read.table(file = "E:/dianjia/project_data/xmoom/skc_stock_20170228.csv",
                            header = TRUE, 
                            sep = ',', 
                            stringsAsFactors = FALSE)
## 创建列，把商品代码和颜色名称合并
skc_stock_20170228$goods_color <- paste(skc_stock_20170228$商品代码, skc_stock_20170228$色号名称, sep = ':')
names(skc_stock_20170228)[3] <- '库存件数2017'
## 20180228库存
skc_stock_20180228 <- read.table(file = "E:/dianjia/project_data/xmoom/skc_stock_20180228.csv",
                                 header = TRUE, 
                                 sep = ',', 
                                 stringsAsFactors = FALSE)
## 创建列，把商品代码和颜色名称合并
skc_stock_20180228$goods_color <- paste(skc_stock_20180228$商品代码, skc_stock_20180228$色号名称, sep = ':')
names(skc_stock_20180228)[3] <- '库存件数2018'
## full join两个库存表
skc_stock_20170228_20180228 <- full_join(x = skc_stock_20170228[, c(3, 4)], 
                                         y = skc_stock_20180228[, c(3, 4)], 
                                         by = c('goods_color' = 'goods_color'))

write.csv(skc_stock_20170228_20180228, 
          file = 'E:/dianjia/project_data/xmoom/skc_stock_20170228_20180228.csv', 
          row.names = FALSE)




skc_stock_20170228[1:10, c(1,2)]



str(skc_stock_20170228_20180228)

View(head(sale_skc_2016, 30))



sale_2016 %>% 
  group_by(商品属性6名称) %>% 
  summarise(goods_n = n())








## 处理基础字段 ===================================================
## 去掉部分字段：拨段名称(重)15、商品属性6名称17、商品年份(重)23
sale_2013_2017 <- sale_2013_2017[, c(1:14, 16, 18:22, 24:30)]

## 设置2013_2017字段名称为英文
colnames(sale_2013_2017) <- c('sale_year', 'sale_month', 'sale_date', 'qudao', 'region', 
                              'store_id', 'store_name', 'store_level_name', 'store_level_id', 
                              'order_id', 'goods_year', 'sale_price', 'origin_price', 
                              'boduan_name', 'kuoxing', 'cat1_name', 'cat2_name', 'origin_cat', 
                              'designer', 'season', 'goods_name', 'order_type', 'goods_id', 
                              'goods_num', 'origin_amount', 'sale_amount', 'settel_amount')

## 剔除origin_price = 0 的记录
sale_2013_2017 <- sale_2013_2017 %>% 
  filter(origin_price > 0)

## 根据日期生成季度字段
sale_2013_2017$sale_quarter <- quarter(sale_2013_2017$sale_date)

## 修改sale_date字段的类型为日期
sale_2013_2017$sale_date <- as.Date(sale_2013_2017$sale_date)

## 处理年份 =======================================================

## 处理goods_year为数字，不足4位的补足成4位，前面加20
### 两种方法：str_sub(), str_replace()
for (i in 1:length(sale_2013_2017$goods_year)){
  if (sale_2013_2017$goods_year[i] == '未定义'){
    sale_2013_2017$goods_year[i] = '未定义'
  }else if (nchar(sale_2013_2017$goods_year[i]) == 5){
    sale_2013_2017$goods_year[i] = str_replace(sale_2013_2017$goods_year[i], '年', '')
  }else {
    sale_2013_2017$goods_year[i] = paste('20', 
                                      str_replace(sale_2013_2017$goods_year[i], '年', ''),
                                      sep = '')
  }
}

## 处理季节 =======================================================

## 商品季节中去除年份
for (i in 1:length(sale_2013_2017$season)){
  if(sale_2013_2017$season[i] == '未定义'){
    sale_2013_2017$goods_season[i] = '未定义'
  } else {
    sale_2013_2017$goods_season[i] = str_sub(sale_2013_2017$season[i], 4, 4)
  }
}
sale_2013_2017$season <- NULL

## 商品季节：1-春、2-夏、3-秋、4-冬、5-未定义
### 1-春
sale_chun <- sale_2013_2017 %>% 
  filter(goods_season == '春') %>% 
  mutate(goods_season = paste('1', '春', sep = '-'))
### 2-夏
sale_xia <- sale_2013_2017 %>% 
  filter(goods_season == '夏') %>% 
  mutate(goods_season = paste('2', '夏', sep = '-'))
### 3-秋
sale_qiu <- sale_2013_2017 %>% 
  filter(goods_season == '秋') %>% 
  mutate(goods_season = paste('3', '秋', sep = '-'))
### 4-冬
sale_dong <- sale_2013_2017 %>% 
  filter(goods_season == '冬') %>% 
  mutate(goods_season = paste('4', '冬', sep = '-'))
### 5-未定义
sale_weidingyi <- sale_2013_2017 %>% 
  filter(goods_season == '未定义') %>% 
  mutate(goods_season = paste('5', '未定义', sep = '-'))
### rbind
sale_2013_2017 <- sale_chun %>% 
  rbind(sale_xia) %>% 
  rbind(sale_qiu) %>% 
  rbind(sale_dong) %>% 
  rbind(sale_weidingyi)
### 季节编码
sale_2013_2017$goods_season_id <- as.integer(str_sub(sale_2013_2017$goods_season, 1, 1))

## 处理过季 =======================================================

## 过季商品标记
### sale_year - goods_year
sale_2013_2017$sale_goods_year <- sale_2013_2017$sale_year - as.integer(sale_2013_2017$goods_year)
### sale_quater - goods_season_id
sale_2013_2017$sale_goods_season <- sale_2013_2017$sale_quarter - sale_2013_2017$goods_season_id

### 如果年份是未定义，则不知是否过季
### 如果商品年份小于销售年份，则是过季商品
### 如果商品年份=销售年份，但是销售季度>商品季节+1，则是过季商品
### 其他的是应季商品
for (i in 1:length(sale_2013_2017$sale_quarter)){
  if (is.na(sale_2013_2017$sale_goods_year[i])) {
    sale_2013_2017$is_guoji[i] = '未知'
  } else if(sale_2013_2017$sale_goods_year[i] > 0){
    sale_2013_2017$is_guoji[i] = '过季'
  } else if(sale_2013_2017$sale_goods_season[i] > 1){
    sale_2013_2017$is_guoji[i] = '过季'
  } else {
    sale_2013_2017$is_guoji[i] = '应季'
  }
}

## 处理一二级类目 =================================================

## 处理异常数据
sale_2013_2017[sale_2013_2017$cat1_name == '未定义' & 
              sale_2013_2017$cat2_name == 'GA皮草', 
            "cat1_name"] <- 'G皮草'
sale_2013_2017[sale_2013_2017$cat1_name == '未定义' & 
              sale_2013_2017$cat2_name == 'ND长裤', 
            "cat1_name"] <- 'N牛仔裤'

## 处理只有一个二级类目的一级类目，部分的二级类目是"未定义"
## cat1_name %in% c('G皮草', 'J马夹', 'TZ套装')
## cat2_name %in% c('GA皮草', 'JA马夹', 'TZ套装')
sale_2013_2017[sale_2013_2017$cat1_name == 'G皮草' & 
              sale_2013_2017$cat2_name == '未定义', 
            "cat2_name"] <- 'GA皮草'
sale_2013_2017[sale_2013_2017$cat1_name == 'J马夹' & 
              sale_2013_2017$cat2_name == '未定义', 
            "cat2_name"] <- 'JA马夹'
sale_2013_2017[sale_2013_2017$cat1_name == 'TZ套装' & 
              sale_2013_2017$cat2_name == '未定义', 
            "cat2_name"] <- 'TZ套装'

## 老的类目：'女装'和'未定义'
## 套装：一级类目=二级类目='TZ'
## 剩余的一级类目提取第一个字符，二级类目提取前两个字符
for (i in 1:length(sale_2013_2017$cat1_name)){
  if (sale_2013_2017$cat1_name[i] %in% c('女装', '未定义')) {
    sale_2013_2017$cat1_id[i] = sale_2013_2017$cat1_name[i]
    sale_2013_2017$cat2_id[i] = sale_2013_2017$cat2_name[i]
  } else if(sale_2013_2017$cat2_name[i] == '未定义'){
    sale_2013_2017$cat1_id[i] = str_sub(sale_2013_2017$cat1_name, 1, 1)
    sale_2013_2017$cat2_id[i] = '未定义'
  } else if(sale_2013_2017$cat1_name[i] == 'TZ套装'){
    sale_2013_2017$cat1_id[i] = 'TZ'
    sale_2013_2017$cat2_id[i] = 'TZ'
  } else {
    sale_2013_2017$cat1_id[i] = str_sub(sale_2013_2017$cat1_name, 1, 1)
    sale_2013_2017$cat2_id[i] = str_sub(sale_2013_2017$cat2_name, 1, 2)
  }
}


## 把数据写出 =================================================
write.csv(sale_2013_2017, 
          file = 'E:/dianjia/project_data/xmoom/sale_2013_2017.csv', 
          row.names = FALSE)
