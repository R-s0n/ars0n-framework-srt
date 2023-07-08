const array1 = [];
const array2 = [];

window.onload = () => {
  const buttons = document.querySelectorAll('.target-show-scope-url-list-url-information');
  buttons.forEach((button) => {
    button.click();
  });

  setTimeout(() => {
    const ruleRows = document.querySelectorAll('div.rule-row');
    ruleRows.forEach((ruleRow) => {
      const ruleStatusIn = ruleRow.querySelector('span.rule-status-in');
      const ruleName = ruleRow.querySelector('span.rule-name').textContent;
      if (ruleStatusIn) {
        if (ruleName.startsWith('*')) {
          array1.push(ruleName);
        } else {
          array2.push(ruleName);
        }
      }
    });

    console.log('Array 1:', array1);
    console.log('Array 2:', array2);
  }, 1000);
};
