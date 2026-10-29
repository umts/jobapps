import Inputmask from "inputmask";

document.addEventListener("DOMContentLoaded", () => {
  const im = new Inputmask({ mask: "(999) 999-9999" });
  im.mask(document.querySelectorAll("input.phone"));
});
