# Detailed walkthrough of switter

Switter scraps your Twitter bookmark and writes the following data to a markdown file:
 1. Tweeter name
 2. Tweeter username
 3. URL of tweet
 4. Date of tweet

## Technologies
Scripts written in Bash automates scraping of Twitter bookmarks.

## Why this project started?
This project was born from Crio.Do's #IBelieveInDoing event. 

# Code walkthrough

## About Webdriver
From [chromedriver.chromium.org](https://chromedriver.chromium.org/home):
> WebDriver is an open source tool for automated testing of webapps across many browsers. It provides capabilities for navigating to web pages, user input, JavaScript execution, and more.  ChromeDriver is a standalone server that implements the W3C WebDriver standard.

Do we need webdriver to scrap information from web? No. Using webdriver makes scrapping easy. You get to see the browser operated remotely which is cool and makes the process intuitive.

## About jq
From [stedolan.github.io](https://stedolan.github.io/jq/):
> jq is a lightweight and flexible command-line JSON processor.

Responses returned by the browser is in JSON format. To filter required values jq comes to the rescue. If you are familiar with Python using jq cannot be more easier.

## About cut command
cut is a command-line tool to remove sections from each line of files. By specifing delimitors we can strip the unwanted parts of text. Go through `man cut` to get more idea of this tool

`-d` or `--delimiter` takes a character argument and uses it to cut the provided text to fields.

`-f` or  `--fields` takes in interger as index value to return the field.
Here is an example

```bash
# Input a-b
cut -d '-' -f 1
cut -d '-' -f 2
```
```
Output

a
b
```

## About piping
To redirect output from one command/process as input to next command/process is done by seperating the commands/processes by `|`. This vertical bar is pipe.

We can pipe echo to cut to get the same output as before:
```bash
echo "a-b" | cut -d '-' -f 1
echo "a-b" | cut -d '-' -f 2
```

## How to POST and GET data using curl
curl is a command-line tool and library to transfer data from or to a server. Get the whole html of google search page by:

```bash
curl www.google.com
```
```
Output

<!doctype html><html itemscope="" itemtype="http://schema.org/WebPage" lang="en-IN"><head><meta content="text/html; charset=UTF-8" ...
```

To POST HTTP data use `-d` or `--data <data>`
To GET HTTP data use `-G` or `--get`

## Starting remote browser and using xpath
Here we are working with Google Chrome browser. So we install ChromeDriver from [here](https://chromedriver.chromium.org/downloads).

Start WebDriver:
```bash
# to run chromedriver as background process, append '&'
./ chromedriver &
```
ChromeDriver starts on port 9515.

Initiate new session and start remote chrome browser
```bash
curl -d '{"desiredCapabilities":{"browserName":"chrome"}}' http://localhost:9515/session
```
*The above part is unclear even to me. How does this POST data start chrome browser? It would be more intuitive if `./chromdriver` started the browser. Help needed!*

Tip: Pipe the above script to jq. Neater output guarenteed.

Note the **sessionId**. Assign it to a vaiable, say *sid*
```bash
sid="<your sessionId>"
``` 

## Navigating to websites and xpath
curl communicates with the remote browser using endpoints specified by [W3C](https://w3c.github.io/webdriver/#endpoints).

We can navigate to Twitter log-in page using `/session/{session id}/url` endpoint.
```bash
curl -d '{"url":"https://twitter.com/login"}' http://localhost:9515/session/$sid/url
```
**Note: Here `'{"url":"https://twitter.com/login"}'` is the JSON argument.**

This gets us to the Twitter login page. Now how do we enter the username and password?

### xpath to the rescue
There are a couple of methods we can use to find the elements present on a web-page. `/session/{session id}/elements` returns all the accesible elements with the property specified in the JSON argument.  
Hover over username or password field in the remote browser or a new browser and `Ctrl+Shift+I` to open the **Inspector** tab. This allows developers(like you) to interact with the html.
< image >
Right click (make sure the username field is highlighted) and *Copy>Copy full XPath*. 
The copied xpath looks like this:
```
/html/body/div/div/div/div[2]/main/div/div/div[2]/form/div/div[1]/label/div/div[2]/div/input
```
We can now get the element id (*ELEMENT*)
```bash
curl -d '{"using":"xpath","value":"/html/body/div/div/div/div[2]/main/div/div/div[2]/form/div/div[1]/label/div/div[2]/div/input"}' http://localhost:9515/session/$sid/element
```
Note: The outdated [Selenium wiki](https://github.com/SeleniumHQ/selenium/wiki/JsonWireProtocol#sessionsessionidelement) lists available strategies to search for an element. 

To post the data (username) to the element:
```bash
# replace $username_element_id with element id from previous step
curl -d '{"value":["tsadarsh_me"]}' http://localhost:9515/session/$sid/element/$username_element_id/value | jq
```

Similarly password field is also filled. To click *Log in* use `/session/{session id}/element/{element it}/click` endpoint.

Tip: The *Log in* button gets enabled only after username and password field are not empty.

Move to bookmarks page:
```bash
curl -d '{"url":"https://twitter.com/i/bookmarks"}' http://localhost:9515/session/$sid/url
```
