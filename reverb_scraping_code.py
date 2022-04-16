#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov 25 17:36:34 2018

@author: thomas ray
"""

import itertools
import requests
from bs4 import BeautifulSoup
from lxml import html
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time

##write out text file
outfile = "guitars_strat.txt"
header = ('title','condition','brand','model','finish','categories','year','strings','handed','fretboard_material','body_type','price','shipping')
with open(outfile, 'w') as file:
    for v in header:
        file.write(v + '\t')
    file.write('\n')

##get urls with selenium
item_urls = []
urls_list = []

for i in range(24,45):
    #url = 'https://reverb.com/marketplace/electric-guitars?query=Fender+Stratocaster'
    url = 'https://reverb.com/marketplace/electric-guitars?query=Fender%20Stratocaster&page='+str(i)
    driver = webdriver.Firefox()
    driver.get(url)
    elems = driver.find_elements_by_xpath("//a[@href]")
    for elem in elems:
        urls_list.append(elem.get_attribute("href"))    
    driver.quit()

##get all item urls into own list
#item_urls = []
    for string in urls_list:
            if 'item' in string:
                item_urls.append(string)
    urls_list = []

#loop through item_urls + snag attributes from webpage

for link in item_urls:
    page = requests.get(link)
    soup = BeautifulSoup(page.content, 'html.parser')
    print(link)
    try:
        attr_items = ["title", soup.find(class_="heading-1 product-title").get_text()] + [attributes.text for attributes in soup.find_all(class_="description-section__spec-list")]
    #attr_items.append('price' + ' ' + soup.find(class_="big-price").get_text())
    #attr_items.append('price' + ' ' + soup.find(class_="listing-price").get_text())
        attr_items.extend(str('price' + ' ' + soup.find(itemprop="price").get_text()).split())
    except:
        pass
    # above line is to fix change in html format      

##put attributes in dictionary
    newlist1 = list()
    for line in attr_items:
        line = line.rstrip('\n').lstrip('\n')
        line = line.split('\n')
        newlist1.append(line)
        attr_clean = [item for sublist in newlist1 for item in sublist]
        attr_clean = list(filter(None, attr_clean))
    attr_dict = dict(itertools.zip_longest(*[iter(attr_clean)] * 2, fillvalue=""))
#print(attr_dict)

##pick the right keys, write to list, write to file
##second key list is to fix change in html format    
    line_to_write = []
    #key_list = ['title','Condition:','Brand:','Model:','Finish:','Categories:','Year:','Number of Strings','Right / Left Handed','Fretboard Material','Body Type','price ','+']
    key_list = ['title','Condition:','Brand:','Model:','Finish:','Categories:','Year:','Number of Strings','Right / Left Handed','Fretboard Material','Body Type','price','+']
    for k in key_list:
        if k in attr_dict:
            line_to_write.append(attr_dict[k])
        if k not in attr_dict:
            line_to_write.append('null')
    with open('guitars_strat.txt', 'a') as ofile:
        for v in line_to_write:
            ofile.write(v + '\t')       
        ofile.write('\n')
        time.sleep(10)
        #maybe sleeping will trick them?!

    
        
