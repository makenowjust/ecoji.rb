import fs from "fs";

import { RubyVM } from "ruby-head-wasm-wasi/dist/index";
import { WASI } from "@wasmer/wasi";
import { WasmFs } from "@wasmer/wasmfs";
import browserBindings from "@wasmer/wasi/lib/bindings/browser";

export const bootstrap = async (): Promise<RubyVM> => {
  const buffer = fs.readFileSync(
    __dirname + "/../../build/ruby+stdlib.packed.wasm"
  );
  const module = await WebAssembly.compile(buffer);

  const wasmFs = new WasmFs();
  const wasi = new WASI({
    bindings: {
      ...browserBindings,
      fs: wasmFs.fs,
    },
  });

  const originalWriteSync = wasmFs.fs.writeSync;
  const stdOutErrBuffers: Record<number, string> = { [1]: "", [2]: "" };
  wasmFs.fs.writeSync = (...args: any[]): any => {
    let fd: number = args[0];
    let text: string;
    if (args.length === 4) {
      text = args[1];
    } else {
      let buffer = args[1];
      text = new TextDecoder("utf-8").decode(buffer);
    }
    const handlers: Record<number, (line: string) => void> = {
      [1]: (line: string) => console.log(line),
      [2]: (line: string) => console.warn(line),
    };
    if (handlers[fd]) {
      text = stdOutErrBuffers[fd] + text;
      let i = text.lastIndexOf("\n");
      if (i >= 0) {
        handlers[fd](text.substring(0, i + 1));
        text = text.substring(i + 1);
      }
      stdOutErrBuffers[fd] = text;
    }
    return (originalWriteSync as any)(...args);
  };

  const vm = new RubyVM();
  const imports = {
    wasi_snapshot_preview1: wasi.wasiImport,
  };
  vm.addToImports(imports);

  const instance = await WebAssembly.instantiate(module, imports);
  await vm.setInstance(instance);

  wasi.setMemory(instance.exports.memory as WebAssembly.Memory);
  // Manually call `_initialize`, which is a part of reactor model ABI,
  // because the WASI polyfill doesn't support it yet.
  (instance.exports._initialize as Function)();
  vm.initialize();

  vm.printVersion();
  vm.eval('$LOAD_PATH.unshift "/ecoji"');

  return vm;
};
