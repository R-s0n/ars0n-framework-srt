document.getElementById('get-target-domains').addEventListener('click', () => {
  console.log("Click Registered!")
  browser.tabs.query({ active: true, currentWindow: true }).then((tabs) => {
    browser.tabs.sendMessage(tabs[0].id, { action: 'get_domains' });
  });
});
