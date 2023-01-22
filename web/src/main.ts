import fs from "fs";

import { bootstrap } from "./bootstrap";

const main = async () => {
  const loading = document.querySelector(".loading")!;
  loading.innerHTML = "Loading Ruby (ruby.wasm).";
  const vm = await bootstrap();
  loading.innerHTML = "Evaluating Ruby code.";
  vm.eval(fs.readFileSync(__dirname + "/main.rb", "utf8"));
};

document.addEventListener("DOMContentLoaded", () => {
  main().catch((err) => console.error(err));
});
