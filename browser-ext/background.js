browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
  console.log("Message Received!")  
  if (message.action === 'get_domains') {
      browser.tabs.executeScript({ file: 'content_script.js' });
    }
  });
  