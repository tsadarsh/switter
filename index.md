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

## Code walkthrough

### About Webdriver
From [chromedriver.chromium.org](https://chromedriver.chromium.org/home):
> WebDriver is an open source tool for automated testing of webapps across many browsers. It provides capabilities for navigating to web pages, user input, JavaScript execution, and more.  ChromeDriver is a standalone server that implements the W3C WebDriver standard.

Do we need webdriver to scrap information from web? No. Using webdriver makes scrapping easy. You get to see the browser operated remotely which is cool and makes the process intuitive.

### About jq
From [stedolan.github.io](https://stedolan.github.io/jq/):
> jq is a lightweight and flexible command-line JSON processor.

Responses returned by the browser is in JSON format. To filter required values jq comes to the rescue. If you are familiar with Python using jq cannot be more easier.

### About cut command
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

### About piping
To redirect output from one command/process as input to next command/process is done by seperating the commands/processes by `|`. This vertical bar is pipe.

We can pipe echo to cut to get the same output as before:
```bash
echo "a-b" | cut -d '-' -f 1
echo "a-b" | cut -d '-' -f 2
```
