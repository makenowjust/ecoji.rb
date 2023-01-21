import fs from "fs";

import { bootstrap } from "./bootstrap";

const main = async () => {
  const app = document.querySelector("#app")!;
  app.innerHTML = '<p class="loading">Loading Ruby (ruby.wasm)...</p>';
  const vm = await bootstrap();
  app.innerHTML = '<p class="loading">Evaluating Ruby code...</p>';
  vm.eval(fs.readFileSync(__dirname + "/main.rb", "utf8"));
};

document.addEventListener("DOMContentLoaded", () => {
  main().catch((err) => console.error(err));
});
