document.addEventListener('DOMContentLoaded', function () {
  const adviceIdElem = document.getElementById('advice-id');
  const adviceTextElem = document.getElementById('advice-text');
  const diceBtn = document.getElementById('dice-btn');
  const dividerImg = document.getElementById('divider-img');

  function setDivider() {
    if (window.innerWidth <= 500) {
      dividerImg.src = './images/pattern-divider-mobile.svg';
    } else {
      dividerImg.src = './images/pattern-divider-desktop.svg';
    }
  }

  async function fetchAdvice() {
    diceBtn.disabled = true;
    try {
      const res = await fetch('https://api.adviceslip.com/advice', { cache: 'no-cache' });
      const data = await res.json();
      adviceIdElem.textContent = data.slip.id;
      adviceTextElem.textContent = `"${data.slip.advice}"`;
    } catch (err) {
      adviceTextElem.textContent = 'Failed to fetch advice. Please try again!';
    } finally {
      diceBtn.disabled = false;
    }
  }

  diceBtn.addEventListener('click', fetchAdvice);
  window.addEventListener('resize', setDivider);
  setDivider();
});
