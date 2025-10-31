#!/usr/bin/env node

import { program } from "commander";

program
  .name("xe")
  .description("A lightweight, universal package manager")
  .version("1.0.0");

program
  .command("hello")
  .description("Print hello world")
  .action(() => {
    console.log("Hello, world!");
  });

program.parse();
