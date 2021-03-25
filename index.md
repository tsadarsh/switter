# Detailed walkthrough of switter

Switter scraps your Twitter bookmark and writes the following data to a markdown file:
 1. Tweeter name
 2. Tweeter username
 3. URL of the tweet
 4. Date of the tweet

## Technologies
Scripts written in Bash automates the scraping of Twitter bookmarks.

## Why this project started?
This project was born from Crio.Do's #IBelieveInDoing event. 

# Code walkthrough

## About Webdriver
From [chromedriver.chromium.org](https://chromedriver.chromium.org/home):
> WebDriver is an open-source tool for automated testing of web apps across many browsers. It provides capabilities for navigating to web pages, user input, JavaScript execution, and more.  ChromeDriver is a standalone server that implements the W3C WebDriver standard.

Do we need WebDriver to scrap information from the web? No. Using WebDriver makes scrapping easy. You get to see the browser operated remotely which is cool and makes the process intuitive.

## About jq
From [stedolan.github.io](https://stedolan.github.io/jq/):
> jq is a lightweight and flexible command-line JSON processor.

Responses returned by the browser is in JSON format. To filter required values jq comes to the rescue. If you are familiar with Python using jq cannot be easier.

## About cut command
`cut` is a command-line tool to remove sections from each line of files. By specifying delimiters we can strip the unwanted parts of the text. Go through `man cut` to get more idea of this tool

`-d` or `--delimiter` takes a character argument and uses it to cut the provided text to fields.

`-f` or  `--fields` takes an integer as the index value to return the field.
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
To redirect output from one command/process as input to the next command/process is done by separating the commands/processes by `|`. This vertical bar is the **pipe**.

We can pipe echo to cut to get the same output as before:
```bash
echo "a-b" | cut -d '-' -f 1
echo "a-b" | cut -d '-' -f 2
```

## How to POST and GET data using curl
`curl` is a command-line tool and library to transfer data HTML or to a server. Get the whole HTML of the google search page by:

```bash
curl www.google.com
```
```
Output

<!doctype html><html itemscope="" itemtype="http://schema.org/WebPage" lang="en-IN"><head><meta content="text/html; charset=UTF-8" ...
```

To POST HTTP data use `-d` or `--data <data>`
To GET HTTP data use `-G` or `--get`

## Starting remote browser and using XPath
Here we are working with the Google Chrome browser. So we install ChromeDriver from [here](https://chromedriver.chromium.org/downloads).

Start WebDriver:
```bash
# to run ChromeDriver as background process, append '&'
./ chromedriver &
```
ChromeDriver starts on port 9515.

Initiate new session and start remote chrome browser
```bash
curl -d '{"desiredCapabilities":{"browserName":"chrome"}}' http://localhost:9515/session
```
*The above part is unclear even to me. How does this POST data start chrome browser? It would be more intuitive if `./chromdriver` started the browser. Help needed!*

Tip: Pipe the above script to jq. Neater output guaranteed.

Note the **sessionId**. Assign it to a vaiable, say *sid*
```bash
sid="<your sessionId>"
``` 

## Navigating to websites and XPath
curl communicates with the remote browser using endpoints specified by [W3C](https://w3c.github.io/webdriver/#endpoints).

We can navigate to Twitter log-in page using `/session/{session id}/url` endpoint.
```bash
curl -d '{"url":"https://twitter.com/login"}' http://localhost:9515/session/$sid/url
```
**Note: Here `'{"url":"https://twitter.com/login"}'` is the JSON argument.**

This gets us to the Twitter log in page. Now how do we enter the username and password?

### XPath to the rescue
There are a couple of methods we can use to find the elements present on a web-page. `/session/{session id}/elements` returns all the accessible elements with the property specified in the JSON argument.  
Hover over the username or password field in the remote browser or a new browser and `Ctrl+Shift+I` to open the **Inspector** tab. This allows developers(like you) to interact with the HTML.
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

Tip: The *Log in* button gets enabled only after the username and password field are not empty.

Move to bookmarks page:
```bash
curl -d '{"url":"https://twitter.com/i/bookmarks"}' http://localhost:9515/session/$sid/url
```

### Getting data from tweets and redirecting to file
**Inspect** (`Ctrl+Shift+I`) the tweets and find the xpath of the necessary elements. 
If desired values in a visible text, use this endpoint:
```/session/{session id}/element/{element id}/text```

If the desired value is an attribute value, use this endpoint:
```/session/{session id}/element/{element id}/attribute/{}.```

Filter the output using jq

```bash
curl -G http://localhost:9515/seesion/$sid/element/$eid/text | jq '.value'
```

#### Redirecting to file
Redirection to file is very simple in Linux. Use `>` to overwrite and `>>` to append data to the output file.

```bash
curl -G http://localhost:9515/session/$sid/element/$eid/attribute/href | jq '.value' | cut -d'"' -f 2 >> $fileName.md
```

# Corner cases
There are many more cases one needs to take care of when writing a script. I've mentioned some of the important cases *switter* take care:
 1. Log in failed
 2. Close port after abrupt shutdown
 3. Scroll to the end of the bookmarks page before scraping the tweets

# Conclusion
By using `for`, `while` and `if-else` loops and conditions in Bash switter scraps all the available bookmarked tweets. The scraped data is written to a file named as the user's `fileName` input.

# References
[Selenium Wiki](https://github.com/SeleniumHQ/selenium/wiki/JsonWireProtocol)
[W3C docs on WebDriver](https://w3c.github.io/webdriver/)
[Bash arrays](https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays)
[Bash for loops](https://linuxize.com/post/bash-for-loop/)
[Scroll to end - Javascript](https://stackoverflow.com/a/12293212/12808184)
[jq](https://stedolan.github.io/jq/)
