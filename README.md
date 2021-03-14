1. Start Webdriver
  > ./chromedriver &
2. Start chrome web session using curl:
  > curl -d '{"desiredCapabilities":{"browserName":"chrome"}}' http://localhost/9515/session
3. Save Session ID (sid)
4. For request:
  > curl -d '{"url":"https:www.google.com"}' http://localhost:9515/session/<sid>/url
